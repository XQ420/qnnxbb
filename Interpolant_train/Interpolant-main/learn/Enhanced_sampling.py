import math
from math import pi, cos, sin
import numpy as np


def Enhanceed_samples(s_i, s_u, id: str, samples_nums):
    if id == 'ex10':
        data_i = []
        data_u = []
        for i in np.linspace(1.45 * pi, 1.55 * pi, samples_nums):
            data_i.append([cos(i), 1 + sin(i)])
            data_u.append([2 * cos(i), 2 + 2 * sin(i)])
        data_i, data_u = np.array(data_i), np.array(data_u)
        return np.concatenate((s_i, data_i), axis=0), np.concatenate((s_u, data_u), axis=0)
    if id == 'sharpe7':
        data_i = []
        data_u = []
        for i in np.linspace(0.25 * pi, 0.75 * pi, samples_nums):
            data_i.append([cos(i), -1 + sin(i)])
        for i in np.linspace(1.25 * pi, 1.75 * pi, samples_nums):
            data_u.append([cos(i), 1 + sin(i)])
        data_i, data_u = np.array(data_i), np.array(data_u)
        return np.concatenate((s_i, data_i), axis=0), np.concatenate((s_u, data_u), axis=0)
    if id == 'ist22_1':
        data_i = []
        data_u = []
        for i in np.linspace(2, 3, 400):
            data_i.append([1, i])
            data_i.append([2, i - 1])

        for i in np.linspace(1, 2, 400):
            data_i.append([i, 2])
            data_i.append([i + 1, 1])

        for i in np.linspace(2.2, 3.2, 400):
            data_u.append([1.2, i])
            data_u.append([2.2, i - 1])

        for i in np.linspace(1.2, 2.2, 400):
            data_u.append([i, 2.2])
            data_u.append([i + 1, 1.2])
        data_i, data_u = np.array(data_i), np.array(data_u)
        return np.concatenate((s_i, data_i), axis=0), np.concatenate((s_u, data_u), axis=0)

    if id == 'face':
        data_i = []
        data_u = []
        for i in np.linspace(0, 2 * pi, samples_nums):
            data_i.append([-4 + cos(i), sin(i)])
            data_i.append([4 + cos(i), sin(i)])
            data_u.append([4 + 3 * cos(i), 3 * sin(i)])
            data_u.append([-4 + 3 * cos(i), 3 * sin(i)])
        data_i, data_u = np.array(data_i), np.array(data_u)
        s_u = s_u[:len(s_u) // 5, :]
        return np.concatenate((s_i, data_i), axis=0), np.concatenate((s_u, data_u), axis=0)

    if id == 'ultimate':
        data_i = []
        data_u = []

        for i in np.linspace(0, 2 * pi, 500):
            data_i.append([-1 + 0.2 * cos(i), 0.2 * sin(i)])
            data_i.append([1 + 0.3 * cos(i), 0.3 * sin(i)])
            data_i.append([1 + 0.95 * cos(i), 0.95 * sin(i)])
            data_i.append([-1 + 1.05 * cos(i), 1.05 * sin(i)])

            data_u.append([1 + 0.2 * cos(i), 0.2 * sin(i)])
            data_u.append([-1 + 0.3 * cos(i), 0.3 * sin(i)])
            data_u.append([-1 + 0.95 * cos(i), 0.95 * sin(i)])
            data_u.append([1 + 1.05 * cos(i), 1.05 * sin(i)])
        data_i, data_u = np.array(data_i), np.array(data_u)
        return np.concatenate((s_i, data_i), axis=0), np.concatenate((s_u, data_u), axis=0)

    if id == 'ist22_2':
        data_i = []
        data_u = []
        f1 = lambda x: -0.02526 * x ** 4 + 0.1754 * x ** 3 - 0.09786 * x ** 2 - 0.1743 * x + 2.273
        f2 = lambda x: -0.02925 * x ** 4 + 0.9181 * x ** 3 - 10.34 * x ** 2 + 49.44 * x - 79.93
        f3 = lambda x: 2.8 - (0.5 * x - 4) ** 2
        f4 = lambda x: 1.8 - (2 / 3 * x - 1.4) ** 2
        for i in np.linspace(0, 5, 500):
            data_i.append([i, f1(i)])
            data_u.append([i, f4(i)])

        for i in np.linspace(5, 10, 500):
            data_i.append([i, f2(i)])
            data_u.append([i, f3(i)])

        data_i, data_u = np.array(data_i), np.array(data_u)
        return np.concatenate((s_i, data_i), axis=0), np.concatenate((s_u, data_u), axis=0)

    if id == 'formast':
        data_i = []
        data_u = []
        f1 = lambda x: 0.07362 * x ** 4 - 0.4644 * x ** 3 + 0.1051 * x ** 2 + 1.967 * x + 0.002523
        f2 = lambda x: 0.125 * x ** 2 + 0.41
        f3 = lambda x: -0.5 * x + 6.04
        f4 = lambda x: -0.1734 * x ** 4 + 0.5633 * x ** 3 - 0.6995 * x ** 2 + 1.29 * x - 0.1115
        f5 = lambda x: -x ** 2 + 10 * x - 22.35

        for i in np.linspace(0, 2.5, 400):
            data_i.append([i, f1(i)])

        for i in np.linspace(2.5, 5, 400):
            data_i.append([i, f2(i)])

        for i in np.linspace(5, 6, 100):
            data_i.append([i, f3(i)])

        for i in np.linspace(0, 3, 400):
            data_u.append([i, f4(i)])

        for i in np.linspace(3, 6, 400):
            data_u.append([i, f5(i)])

        data_i, data_u = np.array(data_i), np.array(data_u)
        return np.concatenate((s_i, data_i), axis=0), np.concatenate((s_u, data_u), axis=0)