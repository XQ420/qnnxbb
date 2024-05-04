import time
from functools import reduce
from itertools import product
import sympy as sp
from SumOfSquares import SOSProblem
from benchmarks_1.Exampler_B import Example, get_example_by_name


class SosValidator_B():
    def __init__(self, example: Example, B) -> None:
        # self.x = sp.symbols(['x{}'.format(i + 1) for i in range(example.n)])
        self.ex = example
        self.Inits = example.I_zones
        self.Unsafes = example.U_zones
        # self.Invs = example.D_zones
        # self.f = [example.f[i](self.x) for i in range(self.n)]
        self.B = B
        self.var_count = 0

    def polynomial(self, n, deg=2):  # Generating polynomials of degree n-ary deg.

        x = sp.symbols([f'x{i + 1}' for i in range(n)])
        if deg == 2:
            parameters = []
            terms = []
            poly = 0
            parameters.append(sp.symbols('parameter' + str(self.var_count)))
            self.var_count += 1
            poly += parameters[-1]
            terms.append(1)
            for i in range(n):
                parameters.append(sp.symbols('parameter' + str(self.var_count)))
                self.var_count += 1
                terms.append(x[i])
                poly += parameters[-1] * terms[-1]
                parameters.append(sp.symbols('parameter' + str(self.var_count)))
                self.var_count += 1
                terms.append(x[i] ** 2)
                poly += parameters[-1] * terms[-1]
            for i in range(n):
                for j in range(i + 1, n):
                    parameters.append(sp.symbols('parameter' + str(self.var_count)))
                    self.var_count += 1
                    terms.append(x[i] * x[j])
                    poly += parameters[-1] * terms[-1]
            return poly, parameters, terms
        else:
            parameters = []
            terms = []
            exponents = list(product(range(deg + 1), repeat=n))  # Generate all possible combinations of indices.
            exponents = [e for e in exponents if sum(e) <= deg]  # Remove items with a count greater than deg.
            poly = 0
            for e in exponents:  # Generate all items.
                parameters.append(sp.symbols('parameter' + str(self.var_count)))
                self.var_count += 1
                terms.append(reduce(lambda a, b: a * b, [x[i] ** exp for i, exp in enumerate(e)]))
                poly += parameters[-1] * terms[-1]
            return poly, parameters, terms

    def SovleInit(self, deg=2):
        x = sp.symbols([f'x{i + 1}' for i in range(self.ex.n1)])
        Inits = self.Inits
        state = True
        if isinstance(self.B, str):
            self.B = sp.sympify(self.B)

        for i in range(len(Inits)):
            zone = Inits[i]
            prob_init = SOSProblem()
            B_I = -self.B

            for lam in zone:
                if deg == 0:
                    B_I = B_I - lam(x)
                else:
                    Pi, parameters, terms = self.polynomial(self.ex.n1, deg=deg)
                    prob_init.add_sos_constraint(Pi, x)
                    B_I = B_I - Pi * lam(x)

            if self.ex.I_eq is not None:
                for lam in self.ex.I_eq[i]:
                    Pi, parameters, terms = self.polynomial(self.ex.n1, deg=deg)
                    B_I = B_I - Pi * lam(x)

            B_I = sp.expand(B_I)
            ans = prob_init.add_sos_constraint(B_I, x)

            try:
                prob_init.solve(solver='mosek')
                vis = True
                print(sum(ans.get_sos_decomp()))
            except:
                vis = False

            state = state and vis
            if not state:
                return False

        return True

    def SovleUnsafe(self, deg=2):
        x = sp.symbols([f'x{i + 1}' for i in range(self.ex.n2)])
        Unsafe = self.Unsafes
        state = True
        if isinstance(self.B, str):
            self.B = sp.sympify(self.B)

        for i in range(len(Unsafe)):
            zone = Unsafe[i]
            prob_unsafe = SOSProblem()
            B_U = self.B

            for lam in zone:
                if deg == 0:
                    B_U = B_U - 1 * lam(x)
                else:
                    Qi, parameters, terms = self.polynomial(self.ex.n2, deg=deg)
                    prob_unsafe.add_sos_constraint(Qi, x)
                    B_U = B_U - Qi * lam(x)

            if self.ex.U_eq is not None:
                for lam in self.ex.U_eq[i]:
                    if deg == 0:
                        B_U = B_U - 1 * lam(x)
                    else:
                        Qi, parameters, terms = self.polynomial(self.ex.n2, deg=deg)
                        B_U = B_U - Qi * lam(x)

            B_U = sp.expand(B_U)
            prob_unsafe.add_sos_constraint(B_U, x)

            try:
                prob_unsafe.solve(solver='mosek')
                vis = True
            except:
                vis = False

            # print(vis)
            state = state and vis
            if not state:
                return False
            # print('___________________')

        return True

    # def SolveDiffB(self, deg=[2, 2]):
    #     prob_inv = SOSProblem()
    #     x = self.x
    #     Invs = self.Invs
    #     B = self.B
    #     DB = -sum([sp.diff(B, x[i]) * self.f[i] for i in range(self.n)])
    #     for i in range(self.n):
    #         Si, parameters, terms = self.polynomial(deg[0])
    #         prob_inv.add_sos_constraint(Si, x)
    #         DB = DB + Si * (x[i] - Invs[i][0]) * (x[i] - Invs[i][1])
    #
    #     R1, parameters, terms = self.polynomial(deg[1])
    #     DB = DB - B * R1
    #     DB = sp.expand(DB)
    #     prob_inv.add_sos_constraint(DB, x)
    #     try:
    #         prob_inv.solve(solver='mosek')
    #         return True
    #     except:
    #         return False

    def SolveAll(self, deg=(2, 2, 2, 2)):
        assert len(deg) == 4

        Init = self.SovleInit(deg[0])
        if not Init:
            print('The initial set is not satisfied.')
            return False
        print('The initial set is satisfied.')
        Unsafe = self.SovleUnsafe(deg[1])
        if not Unsafe:
            print('The unsafe set is not satisfied.')
            return False
        print('The unsafe set is satisfied.')
        # DB = self.SolveDiffB(deg[2:])
        # if not DB:
        #     print('The Lie derivative is not satisfied.')
        #     return False

        return True


if __name__ == '__main__':
    """
    test code!!
    """

    B = '0.24121679480978*x1**2 - 1.56855466400817*x1*x2 + 0.32509616287873*x1*x3 + 5.84234050584722*x1 + 0.680048799536104*x2**2 - 0.341745931386388*x2*x3 - 3.69253404577143*x2 - 5.41999031469323*x3**2 - 0.669406129286968*x3 + 0.782768118026565'

    ex = get_example_by_name('cav20_2')
    # Validator = SosValidator_B(ex, B=B)
    # t1 = time.time()
    # print('Init validation results:', Validator.SovleInit(4))
    # print('Unsafe validation results:', Validator.SovleUnsafe(6))
    # t2 = time.time()
    # print('validation time:{} s'.format(round(t2 - t1, 2)))

    x = sp.symbols([f'x{i + 1}' for i in range(7)])
    for lam in ex.U_zones[0]:
        print(lam(x))
