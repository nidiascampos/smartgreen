from filterpy.gh import GHFilter
import numpy as np
from filterpy.discrete_bayes import normalize

hallway = np.array([1, 1, 0, 0, 0, 0, 0, 0, 1, 0])
# belief = np.array([1./3, 1./3, 0, 0, 0, 0, 0, 0, 1/3, 0])


def update_belief(hall, belief, z, correct_scale):
    for i, val in enumerate(hall):
        if val == z:
            belief[i] *= correct_scale


belief = np.array([0.1] * 10)
reading = 1 # 1 is 'door'
update_belief(hallway, belief, z=reading, correct_scale=3.)
# belief = belief / sum(belief)  # normalizar
normalize(belief) # necessário normalizar para que o somatório dos valores resulte em 1 (ou seja, 100%)

print('belief:', belief)
print('sum =', sum(belief))