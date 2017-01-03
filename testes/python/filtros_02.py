from filterpy.gh import GHFilter
import numpy as np
from filterpy.discrete_bayes import normalize

hallway = np.array([1, 1, 0, 0, 0, 0, 0, 0, 1, 0])

hallway == 1
print(hallway)