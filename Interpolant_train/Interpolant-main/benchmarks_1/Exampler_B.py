import numpy as np


class Example:
    def __init__(self, n1, n2, h_n, I_zones, U_zones, D_zones, name, I_equation=None, U_equation=None):
        self.n1 = n1
        self.n2 = n2
        self.h_n = h_n
        self.I_zones = np.array(I_zones, dtype=object)  # initial set
        self.U_zones = np.array(U_zones, dtype=object)  # unsafe set
        self.D_zones = np.array(D_zones)
        self.name = name  # name or identifier
        self.I_eq = I_equation
        self.U_eq = U_equation


examples = {
    2: Example(
        n1=6,
        n2=6,
        h_n=2,
        I_zones=[[lambda x: 16 - (x[0] + x[1] - 4) ** 2 - 16 * (x[0] - x[1]) ** 2 - x[2] ** 2,
                  lambda x: x[0] + x[1] - x[3] ** 2 - (2 - x[3]) ** 2],
                 [lambda x: 16 - (x[0] + x[1] + 4) ** 2 - 16 * (x[0] - x[1]) ** 2 - x[4] ** 2,
                  lambda x: -x[0] - x[1] - x[5] ** 2 - (2 - x[5]) ** 2]],
        U_zones=[[lambda x: 16 - 16 * (x[0] + x[1]) ** 2 - (x[0] - x[1] + 4) ** 2 - x[2] ** 2,
                  lambda x: x[1] - x[0] - x[3] ** 2 - (1 - x[3]) ** 2],
                 [lambda x: 16 - 16 * (x[0] + x[1]) ** 2 - (x[0] - x[1] - 4) ** 2 - x[4] ** 2,
                  lambda x: x[0] - x[1] - x[5] ** 2 - (1 - x[5]) ** 2]],
        D_zones=[[-4, 4]] * 6,
        name='cav20_4'
    ),
    5: Example(
        n1=3,
        n2=3,
        h_n=2,
        I_zones=[[lambda x: -x[0] ** 2 + 4 * x[0] + x[1] - 4, lambda x: -x[0] - x[1] + 3 - x[2] ** 2]],
        U_zones=[[lambda x: -3 * x[0] ** 2 - x[1] ** 2 + 1, lambda x: x[1] - x[2] ** 2]],
        D_zones=[[-2, 2]] * 3,
        name='IJCAR16_1'
    ),
    7: Example(
        n1=4,
        n2=4,
        h_n=2,
        I_zones=[[lambda x: 1 - x[2] ** 2 - x[3] ** 2]],
        U_zones=[[lambda x: x[0] ** 2 - 2 * x[1] ** 2 - 4]],
        D_zones=[[-4, 4]] * 4,
        name='cav13_1',
        I_equation=[[lambda x: x[2] ** 2 + x[3] - 1 - x[0], lambda x: x[3] + x[0] * x[3] + 1 - x[1]]],
    )
}


def get_example_by_id(id: int):
    return examples[id]


def get_example_by_name(name: str):
    for ex in examples.values():
        if ex.name == name:
            return ex
    raise ValueError('The example {} was not found.'.format(name))
