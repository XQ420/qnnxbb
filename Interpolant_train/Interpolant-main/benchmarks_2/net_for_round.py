import torch.nn as nn
import torch
import sympy as sp
from utils.Config_B import CegisConfig


class Net(nn.Module):
    def __init__(self, config: CegisConfig, m: int, n: int):
        super(Net, self).__init__()
        self.name = config.EXAMPLE.name
        self.m = torch.tensor(m)
        self.n = torch.tensor(n)
        self.a = nn.init.uniform_(nn.Parameter(torch.empty(1)))
        self.b = nn.init.uniform_(nn.Parameter(torch.empty(1)))
        self.c = nn.init.uniform_(nn.Parameter(torch.empty(1)))

    def forward(self, x, y):
        # print(x[:, 0], self.a, self.a * x[:, 0])
        if self.name == 'sharpe1' or self.name == 'sharpe2':
            return self.a * x[:, 0] ** 2 + self.b * x[:, 1]
        elif self.name == 'halfplane':
            return self.a * x[:, 0] - self.a * x[:, 1] + self.b

    def get_barrier(self):
        x = sp.symbols(['x1', 'x2'])
        if self.name == 'sharpe1' or self.name == 'sharpe2':
            return self.a * x[0] ** 2 + self.b * x[1]
        elif self.name == 'halfplane':
            return self.a * x[0] - self.a * x[1] + self.b


class Learner(nn.Module):
    def __init__(self, config: CegisConfig):
        super(Learner, self).__init__()
        self.net = Net(config, *config.fixed_point)
        self.loss_weight = [1, 1]
        self.config = config

    def learn(self, optimizer, S, Sdot):
        """
        :param optimizer: torch optimiser
        :param S: tensor of data
        :param Sdot: tensor contain f(data)
        :param margin: performance threshold
        :return: --
        """

        assert (len(S) == len(Sdot))
        print('Init samples:', len(S[0]), 'Unsafe samples:', len(S[1]))
        learn_loops = self.config.LEARNING_LOOPS
        margin = self.config.MARGIN
        slope = 1e-3
        relu6 = torch.nn.ReLU6()
        for t in range(learn_loops):
            optimizer.zero_grad()

            B_i = self.net(S[0], Sdot[0])
            B_u = self.net(S[1], Sdot[1])
            # B_d, Bdot_d, __, yy = self.net(S[2], Sdot[2])
            # B_i = B_i[:, 0]
            # B_u = B_u[:, 0]
            # B_d = B_d[:, 0]
            # yy = yy[:, 0]
            accuracy_init = sum(B_i < -margin / 2).item() * 100 / len(S[0])
            accuracy_unsafe = sum(B_u > margin / 2).item() * 100 / len(S[1])

            loss = self.loss_weight[0] * (torch.relu(B_i + margin) - slope * relu6(-B_i - margin)).mean()
            loss = loss + self.loss_weight[1] * (torch.relu(-B_u + margin) - slope * relu6(B_u - margin)).mean()

            # belt_index = torch.nonzero(torch.abs(B_d) <= 5.0)
            #
            # dB_belt = torch.index_select(Bdot_d, dim=0, index=belt_index[:, 0])
            # if self.config.MULTIPLICATOR:
            #     dB_belt = Bdot_d - yy * B_d
            #     loss = loss + self.loss_weight[2] * (
            #             torch.relu(dB_belt + margin) - slope * relu6(-dB_belt - margin)).mean()
            # elif belt_index.nelement() != 0:
            #     loss = loss - self.loss_weight[2] * (relu6(-dB_belt + margin)).mean()
            # if dB_belt.shape[0] > 0:
            #     percent_belt = 100 * (sum(dB_belt <= -margin)).item() / dB_belt.shape[0]
            # else:
            #     percent_belt = 0

            if t % int(learn_loops / 10) == 0 or (
                    accuracy_init == 100 and accuracy_unsafe == 100):
                # belt = ('- points in belt: {}'.format(len(belt_index))) if not self.config.MULTIPLICATOR else ''
                print(t, "- loss:", loss.item(), '- accuracy init:', accuracy_init, 'accuracy unsafe:', accuracy_unsafe)

            loss.backward()
            optimizer.step()
            if (accuracy_init == 100 and accuracy_unsafe == 100):
                # print('Average multiplier size:', torch.mean(yy))
                break

        return {}


if __name__ == '__main__':
    net = Net()
    x = torch.tensor([[1, 1],
                      [2, 2],
                      [3, 3]])
    print(net(x))
