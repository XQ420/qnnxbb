import os

import torch
import timeit
import numpy as np

import benchmarks.Exampler_B
from utils.Config_B import CegisConfig
from benchmarks_2.net_for_round import Learner
from verify.CounterExampleFind_B import CounterExampleFinder
from verify.SosVerify_B import SosValidator_B
from learn.save_result import SaveResult
from learn.Enhanced_sampling import Enhanceed_samples
from plots.plot_h import plot


class Cegis:
    def __init__(self, config: CegisConfig):
        n = config.EXAMPLE.n
        self.ex = config.EXAMPLE
        self.n = n
        self.I_zones = config.EXAMPLE.I_zones
        self.U_zones = config.EXAMPLE.U_zones
        self.D_zones = np.array(config.EXAMPLE.D_zones, dtype=np.float32).T

        self.batch_size = config.BATCH_SIZE
        self.learning_rate = config.LEARNING_RATE
        self.Learner = Learner(config)

        self.optimizer = config.OPT(self.Learner.net.parameters(), lr=self.learning_rate)
        self.CounterExampleFinder = CounterExampleFinder(config.EXAMPLE, config)

        self.max_cegis_iter = 100
        self.DEG = config.DEG
        self.R_b = config.R_b

        self._assert_state()
        self._result = None
        self.config = config

    def solve(self):
        # check_mosek
        import mosek

        with mosek.Env() as env:
            with env.Task() as task:
                task.optimize()
                print('Mosek can be used normally.')

        S_i, S_u, Sdot_i, Sdot_u = self.generate_data()

        S, Sdot = [S_i, S_u], [Sdot_i, Sdot_u]

        # the CEGIS loop
        deg = self.DEG
        t_learn = 0
        t_cex = 0
        t_sos = 0
        for i in range(self.max_cegis_iter):
            t1 = timeit.default_timer()
            self.Learner.learn(self.optimizer, S, Sdot)
            t2 = timeit.default_timer()
            t_learn += t2 - t1
            B = self.Learner.net.get_barrier()

            print(f'iter: {i + 1} \nB = {B}')
            t3 = timeit.default_timer()
            Sos_Validator = SosValidator_B(self.ex, B)
            if self.config.EXAMPLE.name == 'halfplane' or Sos_Validator.SolveAll(deg=deg):
                print('SOS verification passed!')
                t4 = timeit.default_timer()
                t_sos += t4 - t3
                # saver = SaveResult(self.config, [t_learn, t_cex, t_sos, i + 1], B, self.Learner.net)
                # saver.save_all()
                break
            t4 = timeit.default_timer()
            t_sos += t4 - t3
            print('SOS verification failed!')
            # In the negative example of Lie derivative, the condition of B(x)==0 is relaxed to |B(x)|<=margin
            # to find a negative example, so the existence of a negative example does not mean that sos must
            # not be satisfied
            t5 = timeit.default_timer()
            samples, satisfy = self.CounterExampleFinder.get_counter_example(B)
            t6 = timeit.default_timer()
            t_cex += t6 - t5
            if satisfy:
                print('No counterexamples were found!')

            # if satisfy:
            #     # If no counterexample is found, but SOS fails, it may be that the number of multipliers is too low.
            #     deg[3] += 2

            S, Sdot = self.add_ces_to_data(S, Sdot, samples)
            print('-' * 200)
        print('Total learning time:{}'.format(t_learn))
        print('Total counter-examples generating time:{}'.format(t_cex))
        print('Total sos verifying time:{}'.format(t_sos))
        if self.ex.n == 2:
            plot(np.array(S_i), np.array(S_u), B)

    def add_ces_to_data(self, S, Sdot, ces):
        """
        :param S: torch tensor
        :param Sdot: torch tensor
        :param ces: list of ctx
        :return:
                S: torch tensor, added new ctx
                Sdot torch tensor, added  f(new_ctx)
        """
        assert len(ces) == 3

        for idx in range(3):
            if len(ces[idx]) != 0:
                print(f'Add {len(ces[idx])} counterexamples!')
                S[idx] = torch.cat([S[idx], ces[idx]], dim=0).detach()
                # dot_ces = self.x2dotx(ces[idx])
                # Sdot[idx] = torch.cat([Sdot[idx], dot_ces], dim=0).detach()

        return S, Sdot

    def generate_data(self):

        # I_len = self.I_zones[1] - self.I_zones[0]
        # U_len = self.U_zones[1] - self.U_zones[0]
        D_len = self.D_zones[1] - self.D_zones[0]

        # Let more sample points fall on the boundary.
        # times = 1 / (1 - self.R_b)
        N = 3 * self.batch_size  # 初始采样点
        S_d = np.random.rand(N, self.n)

        # S_i = torch.clamp((torch.rand([self.batch_size, self.n]) - 0.5) * times, -0.5, 0.5) + 0.5
        # S_u = torch.clamp((torch.rand([self.batch_size, self.n]) - 0.5) * times, -0.5, 0.5) + 0.5
        # S_d = torch.clamp((torch.rand([self.batch_size, self.n]) - 0.5) * times, -0.5, 0.5) + 0.5
        #
        # S_i = S_i * I_len + self.I_zones[0]
        # S_u = S_u * U_len + self.U_zones[0]

        S_d = S_d * D_len + self.D_zones[0]

        vis_I, vis_U = [False for _ in range(N)], [False for _ in range(N)]
        # print(S_d)
        for zone in self.I_zones:
            cur1 = [True for _ in range(N)]
            for lam in zone:
                cur2 = list(map(lam, S_d.tolist()))
                cur2 = [e >= 0 for e in cur2]
                cur1 = [(x and y) for x, y in zip(cur1, cur2)]
            vis_I = [(x or y) for x, y in zip(cur1, vis_I)]

        for zone in self.U_zones:
            cur1 = [True for _ in range(N)]
            for lam in zone:
                cur2 = list(map(lam, S_d.tolist()))
                cur2 = [e >= 0 for e in cur2]
                cur1 = [(x and y) for x, y in zip(cur1, cur2)]
            vis_U = [(x or y) for x, y in zip(cur1, vis_U)]

        I_indices = [pos for pos, vis in enumerate(vis_I) if vis]
        U_indices = [pos for pos, vis in enumerate(vis_U) if vis]
        # print(sum(vis_I), sum(vis_U))
        # print(I_indices)
        # print(U_indices)
        # Sdot_i, Sdot_d, Sdot_u = self.x2dotx(S_i), self.x2dotx(S_d), self.x2dotx(S_u)
        S_i = S_d[I_indices, :]
        S_u = S_d[U_indices, :]

        if self.config.Enhance:
            S_i, S_u = Enhanceed_samples(S_i, S_u, self.config.EXAMPLE.name, self.config.Enhanced_samples)
        # print(S_i)
        # print(S_u)
        return torch.tensor(S_i, dtype=torch.float32), torch.tensor(S_u, dtype=torch.float32), None, None

    # def x2dotx(self, X):
    #     f_x = []
    #     for x in X:
    #         f_x.append([self.f[i](x) for i in range(self.n)])
    #     return torch.Tensor(f_x)

    def _assert_state(self):
        assert self.batch_size > 0
        assert self.learning_rate > 0


if __name__ == '__main__':
    pass
