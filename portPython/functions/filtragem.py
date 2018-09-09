import numpy as np

################################################################################
# Criterios de remoção de outliers (página 45) - umidade de solo -> < 0 ou > 200
################################################################################
def filtragemForaEscopoUmidade(data):
	data.loc[(data['d15cm_modulo1'] < 0) | (data['d15cm_modulo1'] > 200), 'd15cm_modulo1'] = np.NaN
	data.loc[(data['d15cm_modulo2'] < 0) | (data['d15cm_modulo2'] > 200), 'd15cm_modulo2'] = np.NaN
	data.loc[(data['d15cm_modulo3'] < 0) | (data['d15cm_modulo3'] > 200), 'd15cm_modulo3'] = np.NaN
	data.loc[(data['d15cm_modulo4'] < 0) | (data['d15cm_modulo4'] > 200), 'd15cm_modulo4'] = np.NaN

	data.loc[(data['d45cm_modulo1'] < 0) | (data['d45cm_modulo1'] > 200), 'd45cm_modulo1'] = np.NaN
	data.loc[(data['d45cm_modulo2'] < 0) | (data['d45cm_modulo2'] > 200), 'd45cm_modulo2'] = np.NaN
	data.loc[(data['d45cm_modulo3'] < 0) | (data['d45cm_modulo3'] > 200), 'd45cm_modulo3'] = np.NaN
	data.loc[(data['d45cm_modulo4'] < 0) | (data['d45cm_modulo4'] > 200), 'd45cm_modulo4'] = np.NaN

	data.loc[(data['d75cm_modulo1'] < 0) | (data['d75cm_modulo1'] > 200), 'd75cm_modulo1'] = np.NaN
	data.loc[(data['d75cm_modulo2'] < 0) | (data['d75cm_modulo2'] > 200), 'd75cm_modulo2'] = np.NaN
	data.loc[(data['d75cm_modulo3'] < 0) | (data['d75cm_modulo3'] > 200), 'd75cm_modulo3'] = np.NaN
	data.loc[(data['d75cm_modulo4'] < 0) | (data['d75cm_modulo4'] > 200), 'd75cm_modulo4'] = np.NaN

##################################################################################
# Criterios de remoção de outliers (página 45) - temperatura do solo -> 20 ou > 32
##################################################################################
def filtragemForaEscopoTemperatura(data):
	data.loc[(data['temperature'] < 20) | (data['temperature'] > 32), 'temperature'] = np.NaN