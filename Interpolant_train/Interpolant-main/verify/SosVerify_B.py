import time
from functools import reduce
from itertools import product
import sympy as sp
from SumOfSquares import SOSProblem
from benchmarks.Exampler_B import Example, get_example_by_name


class SosValidator_B():
    def __init__(self, example: Example, B) -> None:
        self.x = sp.symbols(['x{}'.format(i + 1) for i in range(example.n)])
        self.n = example.n
        self.Inits = example.I_zones
        self.Unsafes = example.U_zones
        # self.Invs = example.D_zones
        # self.f = [example.f[i](self.x) for i in range(self.n)]
        self.B = B
        self.var_count = 0

    def polynomial(self, deg=2):  # Generating polynomials of degree n-ary deg.
        if deg == 2 and self.n > 8:
            parameters = []
            terms = []
            poly = 0
            parameters.append(sp.symbols('parameter' + str(self.var_count)))
            self.var_count += 1
            poly += parameters[-1]
            terms.append(1)
            for i in range(self.n):
                parameters.append(sp.symbols('parameter' + str(self.var_count)))
                self.var_count += 1
                terms.append(self.x[i])
                poly += parameters[-1] * terms[-1]
                parameters.append(sp.symbols('parameter' + str(self.var_count)))
                self.var_count += 1
                terms.append(self.x[i] ** 2)
                poly += parameters[-1] * terms[-1]
            for i in range(self.n):
                for j in range(i + 1, self.n):
                    parameters.append(sp.symbols('parameter' + str(self.var_count)))
                    self.var_count += 1
                    terms.append(self.x[i] * self.x[j])
                    poly += parameters[-1] * terms[-1]
            return poly, parameters, terms
        else:
            parameters = []
            terms = []
            exponents = list(product(range(deg + 1), repeat=self.n))  # Generate all possible combinations of indices.
            exponents = [e for e in exponents if sum(e) <= deg]  # Remove items with a count greater than deg.
            poly = 0
            for e in exponents:  # Generate all items.
                parameters.append(sp.symbols('parameter' + str(self.var_count)))
                self.var_count += 1
                terms.append(reduce(lambda a, b: a * b, [self.x[i] ** exp for i, exp in enumerate(e)]))
                poly += parameters[-1] * terms[-1]
            return poly, parameters, terms

    def SovleInit(self, deg=2):
        x = self.x
        Inits = self.Inits
        state = True
        if isinstance(self.B, str):
            self.B = sp.sympify(self.B)

        for zone in Inits:
            prob_init = SOSProblem()
            B_I = -self.B

            ans = []
            for lam in zone:
                Pi, parameters, terms = self.polynomial(deg)
                ans.append(prob_init.add_sos_constraint(Pi, x))
                B_I = B_I - Pi * lam(x)

            B_I = sp.expand(B_I)
            ans.append(prob_init.add_sos_constraint(B_I, x))

            try:
                prob_init.solve(solver='mosek')
                vis = True
                # for i in ans:
                #     print(sum(i.get_sos_decomp()))
            except:
                vis = False

            state = state and vis
            if not state:
                return False

        return True

    def SovleUnsafe(self, deg=2):
        x = self.x
        Unsafe = self.Unsafes
        state = True
        if isinstance(self.B, str):
            self.B = sp.sympify(self.B)

        for zone in Unsafe:
            prob_unsafe = SOSProblem()
            B_U = self.B

            for lam in zone:
                Qi, parameters, terms = self.polynomial(deg)
                prob_unsafe.add_sos_constraint(Qi, x)
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

    B = '-1.00351955604981*x1**4 + 0.852131578772854*x1**3*x2 + 14.0824781987576*x1**3 - 1.63406162504168*x1**2*x2**2 - 12.6644692827978*x1**2*x2 - 48.6249370749074*x1**2 + 0.758846638206991*x1*x2**3 + 14.0570784680139*x1*x2**2 + 22.6982056400938*x1*x2 + 57.9823407259286*x1 - 0.0472259058792438*x2**4 - 5.48118392207501*x2**3 - 6.67379226534615*x2**2 - 24.9521456761878*x2 - 2.0810785007266'

    Validator = SosValidator_B(get_example_by_name('formast'), B=B)
    t1 = time.time()
    print('Init validation results:', Validator.SovleInit(4))
    print('Unsafe validation results:', Validator.SovleUnsafe(6))
    t2 = time.time()
    print('validation time:{} s'.format(round(t2 - t1, 2)))
