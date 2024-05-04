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
        I_zones=[[lambda x: -(x[1] + 1) * x[1]]],
        U_zones=[[lambda x: 1 - (x[0] ** 2 + (x[1] - 1) ** 2)]],
        D_zones=[[-2, 2], [-1, 3]],  # 估计一个超矩形，包裹住所有区域,方便采样
        name='sharpe1'  # 有平移
    ),
    2: Example(
        n=2,
        I_zones=[[lambda x: x[1] - x[0], lambda x: x[0] + x[1]]],
        U_zones=[[lambda x: - x[0] ** 2 - x[1]]],
        D_zones=[[-2, 2], [-2, 2]],
        name='sharpe2'
    )
}


def get_example_by_id(id: int):
    return examples[id]


def get_example_by_name(name: str):
    for ex in examples.values():
        if ex.name == name:
            return ex
    raise ValueError('The example {} was not found.'.format(name))
