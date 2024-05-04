import numpy as np


class Example:
    def __init__(self, n, I_zones, U_zones, D_zones, name):
        self.n = n  # number of variables
        self.I_zones = np.array(I_zones, dtype=object)  # initial set
        self.U_zones = np.array(U_zones, dtype=object)  # unsafe set
        self.D_zones = np.array(D_zones)
        self.name = name  # name or identifier


examples = {
    1: Example(
        n=2,
        I_zones=[[lambda x: 1 - (x[0] ** 2 + (x[1] - 1) ** 2)]],
        U_zones=[[lambda x: x[0] ** 2 + (x[1] - 2) ** 2 - 4]],
        D_zones=[[-2, 2], [0, 4]],  # 估计一个超矩形，包裹住所有区域,方便采样
        name='sharpe6'
    ),
    2: Example(
        n=2,
        I_zones=[[lambda x: 1 - (x[0] ** 2 + (x[1] + 1) ** 2)]],
        U_zones=[[lambda x: 1 - (x[0] ** 2 + (x[1] - 1) ** 2)]],
        D_zones=[[-1, 1], [-2, 2]],
        name='sharpe7'
    ),
    4: Example(
        n=2,
        I_zones=[[lambda x: (1 - x[0]) * (x[0] + 1), lambda x: (3 - x[1]) * x[1]],
                 [lambda x: (2 - x[0]) * (x[0] - 1), lambda x: (2 - x[1]) * x[1]],
                 [lambda x: (3 - x[0]) * (x[0] - 2), lambda x: (1 - x[1]) * x[1]]],
        U_zones=[[lambda x: (x[0] - 1.2) * (5 - x[0]), lambda x: (x[1] - 2.2) * (5 - x[1])],
                 [lambda x: (2.2 - x[1]) * (x[1] - 1.2), lambda x: (x[0] - 2.2) * (5 - x[0])]],
        D_zones=[[-1, 5], [0, 5]],
        name='ist22_1'
    ),
    8: Example(
        n=2,
        I_zones=[[lambda x: 1 - (x[0] + 4) ** 2 - x[1] ** 2],
                 [lambda x: 1 - (x[0] - 4) ** 2 - x[1] ** 2]],
        U_zones=[[lambda x: (x[0] + 4) ** 2 + x[1] ** 2 - 9, lambda x: (x[0] - 4) ** 2 + x[1] ** 2 - 9,
                  lambda x: 64 - x[0] ** 2 - x[1] ** 2]],
        # lambda x: (x[0] + 8) * (8 - x[0]), lambda x: (x[1] + 4) * (4 - x[1])]],
        D_zones=[[-8, 8], [-4, 4]],
        name='face'
    ),
    12: Example(
        n=2,
        I_zones=[[lambda x: x[1] - x[0] ** 2 - 1]],
        U_zones=[[lambda x: x[0] ** 2 - x[1]]],
        D_zones=[[-4, 4], [-2, 10]],
        name='parabola'
    )
}


def get_example_by_id(id: int):
    return examples[id]


def get_example_by_name(name: str):
    for ex in examples.values():
        if ex.name == name:
            return ex
    raise ValueError('The example {} was not found.'.format(name))
