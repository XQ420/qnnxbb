import matplotlib.pyplot as plt
import numpy as np
import sympy as sp


def plot(SI, SU, hx=None):
    SI, SU = SI.T, SU.T
    plt.plot(SI[0], SI[1], '.')
    plt.plot(SU[0], SU[1], '.')

    x_max_limit = max(max(SI[0]), max(SU[0]))
    x_min_limit = min(min(SI[0]), min(SU[0]))
    y_max_limit = max(max(SI[1]), max(SU[1]))
    y_min_limit = min(min(SI[1]), min(SU[1]))
    if hx is not None:
        x, y = np.linspace(x_min_limit, x_max_limit, 100), np.linspace(y_min_limit, y_max_limit, 100)
        X, Y = np.meshgrid(x, y)

        s_x = sp.symbols(['x1', 'x2'])
        fun_hx = sp.lambdify(s_x, hx, 'numpy')
        value = fun_hx(X, Y)
        plt.contour(X, Y, value, 0, alpha=0.8, cmap=plt.cm.hot)

    plt.show()
