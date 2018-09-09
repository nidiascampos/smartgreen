import numpy as np
from scipy.special import erfc
from scipy import stats
from PyAstronomy import pyasl

##########################################################
# Fusão de dados dos sensores utilizando uma média regular
##########################################################
def basicFusion(sensor, metodo):
    fusedSensor = np.zeros((len(sensor), 1))

    if metodo == 'median':
        return sensor.median(axis=1)
    
    elif metodo == 'mean':
        return sensor.mean(axis=1)
        
    else:
        return fusedSensor
    
#############################################################
# Fusão de dados dos sensores utilizando o critério de Peirce
#############################################################
def peirceFusion(sensor):
    fusedSensor = np.zeros((len(sensor), 1))
    return fusedSensor
    
######################################################
# Fusão de dados dos sensores utilizando Chauvenet
# http://www.statisticshowto.com/chauvenets-criterion/
######################################################
def chauvenetFusion(sensor):
    mean = sensor.mean()            # Mean of incoming array y
    stdv = sensor.std()             # Its standard deviation
    N = len(sensor)                 # Lenght of incoming arrays
        
    criterion = 1.0/(2*N)           # Chauvenet's criterion
    d = abs(sensor-mean)/stdv       # Distance of a value to mean in stdv's
    d /= 2.0**0.5                   # The left and right tail threshold values
    prob = erfc(d)                  # Area normal dist
    filter = prob >= criterion      # The 'accept' filter array with booleans
    
#    return sensor[filter], sensor[~filter], filter  # Return the cleared version, the rejected version and the filter
    return basicFusion(sensor[filter], 'mean')
    
####################################################################
# Fusão de dados dos sensores utilizando zscore
# http://www.statisticshowto.com/probability-and-statistics/z-score/
####################################################################
def zscoreFusion(sensor):
    mean = sensor.mean()            # Mean of incoming array y
    stdv = sensor.std()             # Its standard deviation
        
    zscore = (sensor-mean)/stdv     # Distance of a value to mean in stdv's
    prob = erfc(zscore)             # Area normal dist
    filter = prob >= zscore         # The 'accept' filter array with booleans
    
#    return sensor[filter], sensor[~filter], filter  # Return the cleared version, the rejected version and the filter
    return basicFusion(sensor[filter], 'mean')

######################################################################################
# Fusão de dados dos sensores utilizando Generalized ESD
# https://www.itl.nist.gov/div898/handbook/eda/section3/eda35h3.htm
# https://www.hs.uni-hamburg.de/DE/Ins/Per/Czesla/PyA/PyA/pyaslDoc/aslDoc/outlier.html
######################################################################################
def gesdFusion(sensor, maxOLs = 6):
    for column in sensor:
        gesd = pyasl.generalizedESD(sensor[column], maxOLs)
        
        for outlier in gesd[1]:
            sensor[column][outlier] = np.NaN
        
    return basicFusion(sensor, 'mean')

##################################################################
# Fusão de dados dos sensores utilizando Modified zScore
# https://www.itl.nist.gov/div898/handbook/eda/section3/eda35h.htm
##################################################################
def mzscoreFusion(sensor):    
    median = sensor.median()                # Mediana do sensor
    MAD = abs(sensor - median).median()     # Median Absolute Deviation
        
    mzscore = (0.6745*(sensor-median))/MAD  # Cálculo do Modified ZScore
    prob = erfc(mzscore)                    # Area normal dist
    filter = prob >= mzscore                # The 'accept' filter array with booleans
    
#    return sensor[filter], sensor[~filter], filter  # Return the cleared version, the rejected version and the filter
    return basicFusion(sensor[filter], 'mean')