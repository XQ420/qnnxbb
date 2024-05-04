import sys

# sys.path.append('E:/Python/Interpolant')

from sharpe.cegis import Cegis
from utils.Config_B import CegisConfig
import timeit
import torch
import numpy as np
from benchmarks.Exampler_B import get_example_by_name, get_example_by_id
from plots.plot_barriers import plot_benchmark2d


def main():
    activations = ['SKIP'] * 1  # Only "SQUARE","SKIP","MUL" are optional.
    hidden_neurons = [20] * len(activations)
    example = get_example_by_name('sharpe7')
    start = timeit.default_timer()
    opts = {
        'Skip_bias': False,
        "Enhance": False,
        "Enhance_samples": 1000,
        "BIAS": True,
        "ACTIVATION": activations,
        "EXAMPLE": example,
        "N_HIDDEN_NEURONS": hidden_neurons,
        "BATCH_SIZE": 5000,
        "LEARNING_RATE": 0.1,
        "MARGIN": 0,
        "LOSS_WEIGHT": (1.0, 1.0, 1.0),  # # They are the weights of init loss, unsafe loss, and diffB loss.
        "DEG": [2, 2, 2, 1],  # Respectively represent the times of init, unsafe, diffB,
        # and unconstrained multipliers when verifying sos.
        "LEARNING_LOOPS": 1000,
    }
    Config = CegisConfig(**opts)
    c = Cegis(Config)
    c.generate_data()
    c.solve()
    end = timeit.default_timer()
    print('Elapsed Time: {}'.format(end - start))
    # plot_benchmark2d(example, c.Learner.net.get_barrier())


if __name__ == '__main__':
    np.random.seed(2023)
    torch.manual_seed(2023)
    main()
