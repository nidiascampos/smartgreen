import numpy as np
import pandas as pd

from functions.converter import converterChuva, converterUmidadeSolo
from functions.normalizar import normalizarDados, table2timetable, retime
from functions.filtragem import filtragemForaEscopoTemperatura, filtragemForaEscopoUmidade
from functions.fusao import basicFusion, applyPierce, chauvenetFusion, zscoreFusion, gesdFusion, mzscoreFusion

def main():
    # Recepção dos dados
    modulo1 = pd.read_csv('csv/modulo1.txt')
    modulo2 = pd.read_csv('csv/modulo2.txt')
    modulo3 = pd.read_csv('csv/modulo3.txt')
    modulo4 = pd.read_csv('csv/modulo4.txt')
    modulo5 = pd.read_csv('csv/modulo5_1.txt')
    modulo52 = pd.read_csv('csv/modulo5_2.txt')

    modulo1_ts = pd.read_csv('csv/modulo1_thingspeak.txt')
    modulo2_ts = pd.read_csv('csv/modulo2_thingspeak.txt')
    modulo3_ts = pd.read_csv('csv/modulo3_thingspeak.txt')
    modulo4_ts = pd.read_csv('csv/modulo4_thingspeak.txt')
    modulo5_ts = pd.read_csv('csv/modulo5_thingspeak.txt')

    # Tratamento dos dados do modulo 5_1
    modulo5 = table2timetable(modulo5)    # Transformar em Timestamp

    # Inserção de dados que possuem espaço em hora fechada
    # Matlab arrendondou o ultimo valor antes de deletar pra cima
    newMatlabData = table2timetable(pd.DataFrame({'when': '2017-04-27 14:00:00.000', 'module': 5, 'battery': 5.02608394622803, 'wetness': 888, 'rain': 0, 'temperature': 26.6875}, index=[0]))
    modulo5 = pd.concat([modulo5, newMatlabData])

    modulo5.index = modulo5.index.map(lambda x: x.replace(minute=0, second=0, microsecond=0))    # Normaliza os valores de hora para XX:00:00
    modulo5 = modulo5[~modulo5.index.duplicated(keep='first')]    # Deleta todos os dados duplicados permanecendo somente o primeiro
    
    # Andrei pegou a segunda linha ao invés da primeira (?)
    modulo5.loc[modulo5.index == '2017-04-27 11:00:00', 'module'] = 5
    modulo5.loc[modulo5.index == '2017-04-27 11:00:00', 'battery'] = 3.80656313896179
    modulo5.loc[modulo5.index == '2017-04-27 11:00:00', 'wetness'] = 1023
    modulo5.loc[modulo5.index == '2017-04-27 11:00:00', 'rain'] = 1
    modulo5.loc[modulo5.index == '2017-04-27 11:00:00', 'temperature'] = -127

    # Andrei transformou essa linha em nula (?)
    modulo5.loc[modulo5.index == '2017-04-26 14:00:00', 'module'] = 5
    modulo5.loc[modulo5.index == '2017-04-26 14:00:00', 'battery'] = np.NaN
    modulo5.loc[modulo5.index == '2017-04-26 14:00:00', 'wetness'] = np.NaN
    modulo5.loc[modulo5.index == '2017-04-26 14:00:00', 'rain'] = np.NaN
    modulo5.loc[modulo5.index == '2017-04-26 14:00:00', 'temperature'] = np.NaN
    
    modulo5 = modulo5.sort_index()    # Ordem ASC
    modulo5 = modulo5[1:]            # Andrei removeu a primeira linha (?)

    # Tratamento dos dados do modulo 5_2
    modulo52 = retime(modulo52)                    # Resample dos dados do modulo5_2
    modulo5 = pd.concat([modulo5, modulo52])    # Mescla os dados do modulo5_1 com o modulo5_2

    # Tratamento dos dados do modulo 2
    modulo2 = table2timetable(modulo2)
    modulo2 = modulo2[~modulo2.index.duplicated(keep='first')]    # Deleta todos os dados duplicados permanecendo somente o primeiro

    # Converter dados em timetable
    modulo1 = table2timetable(modulo1)
    # modulo2 já é timetable
    modulo3 = table2timetable(modulo3)
    modulo4 = table2timetable(modulo4)
    # modulo5 já é timetable

    # Tratamento dos dados do modulo 1 (thingspeak)
    modulo1_ts = modulo1_ts[:161]    # Remove modulos travados (? -- procurar na dissertação)

    # Ordenando todos os dados de forma crescente
    # Já estão ordenados

    # Remoção de dados redundantes (?)
    modulo1_ts = modulo1_ts[25:]
    modulo2_ts = modulo2_ts[26:]
    modulo3_ts = modulo3_ts[19:]
    modulo4_ts = modulo4_ts[14:]
    modulo5_ts = modulo5_ts[12:]

    # Removendo colunas desnecessárias
    del modulo1['module']
    del modulo1['battery']
    del modulo1['d15cm_bias']
    del modulo1['d45cm_bias']
    del modulo1['d75cm_bias']

    del modulo2['module']
    del modulo2['battery']
    del modulo2['d15cm_bias']
    del modulo2['d45cm_bias']
    del modulo2['d75cm_bias']

    del modulo3['module']
    del modulo3['battery']
    del modulo3['d15cm_bias']
    del modulo3['d45cm_bias']
    del modulo3['d75cm_bias']

    del modulo4['module']
    del modulo4['battery']
    del modulo4['d15cm_bias']
    del modulo4['d45cm_bias']
    del modulo4['d75cm_bias']

    del modulo5['module']
    del modulo5['battery']
    del modulo5['rain']

    del modulo1_ts['battery']
    del modulo1_ts['d15cm_bias']
    del modulo1_ts['d45cm_bias']
    del modulo1_ts['d75cm_bias']

    del modulo2_ts['battery']
    del modulo2_ts['d15cm_bias']
    del modulo2_ts['d45cm_bias']
    del modulo2_ts['d75cm_bias']

    del modulo3_ts['battery']
    del modulo3_ts['d15cm_bias']
    del modulo3_ts['d45cm_bias']
    del modulo3_ts['d75cm_bias']

    del modulo4_ts['battery']
    del modulo4_ts['d15cm_bias']
    del modulo4_ts['d45cm_bias']
    del modulo4_ts['d75cm_bias']

    del modulo5_ts['battery']
    del modulo5_ts['rain']

    # Dividir módulos thingspeak (?) -- dados descontinuos para resample
                                        # Módulo Um - Dados Contínuos

    modulo2_ts_1 = modulo2_ts[:256]        # Módulo Dois
    modulo2_ts_2 = modulo2_ts[256:]        # Módulo Dois

    modulo3_ts_1 = modulo3_ts[:73]        # Módulo Três
    modulo3_ts_2 = modulo3_ts[73:]        # Módulo Três

                                        # Módulo Quatro - Dados Contínuos

    modulo5_ts_1 = modulo5_ts[3:149]    # Módulo Cinco
    modulo5_ts_2 = modulo5_ts[151:]        # Módulo Cinco

    # Resample para horas homogêneas
    modulo1_ts = retime(modulo1_ts)            # Perdeu um dado 'arredondado' pra cima ['11-May-2017 06:00:00']
    
    modulo2_ts_1 = retime(modulo2_ts_1)        # Perdeu um dado 'arredondado' pra cima ['15-May-2017 22:00:00']
    modulo2_ts_2 = retime(modulo2_ts_2)        # Perdeu um dado 'arredondado' pra cima ['29-May-2017 23:00:00']
    
    modulo3_ts_1 = retime(modulo3_ts_1)        # Perdeu um dado 'arredondado' pra cima ['10-May-2017 20:00:00']
    modulo3_ts_2 = retime(modulo3_ts_2)        # Perdeu um dado 'arredondado' pra cima ['29-May-2017 23:00:00']
    
    modulo4_ts = retime(modulo4_ts)            # Perdeu um dado 'arredondado' pra cima ['29-May-2017 20:00:00']
    
    modulo5_ts_1 = retime(modulo5_ts_1)        # Perdeu um dado 'arredondado' pra cima ['13-May-2017 16:00:00']
    modulo5_ts_2 = retime(modulo5_ts_2)        # Perdeu um dado 'arredondado' pra cima ['23-May-2017 10:00:00']
                                            # Perdeu um total de 9 dados

    modulo5_ts_1.loc[modulo5_ts_1['temperature'] == -127, 'temperature'] = np.NaN    # Pq só a partir do 63? E 61-62? -- -127 = NaN (?)
    modulo5_ts_1.loc[modulo5_ts_1.index == '12-May-2017 02:00:00', 'temperature'] = -127
    modulo5_ts_1.loc[modulo5_ts_1.index == '12-May-2017 03:00:00', 'temperature'] = -127

    # Unir dados do thingspeak
    modulo2_ts = pd.concat([modulo2_ts_1, modulo2_ts_2])
    modulo3_ts = pd.concat([modulo3_ts_1, modulo3_ts_2])
    modulo5_ts = pd.concat([modulo5_ts_1, modulo5_ts_2])

    # Unir tabelas dos watermarks
    modulo1 = pd.concat([modulo1, modulo1_ts])
    modulo2 = pd.concat([modulo2, modulo2_ts])
    modulo3 = pd.concat([modulo3, modulo3_ts])
    modulo4 = pd.concat([modulo4, modulo4_ts])
    modulo5 = pd.concat([modulo5, modulo5_ts])

    # Unir todos os dados em uma unica tabela
    coleta03_total_12 = pd.DataFrame.join(modulo1, modulo2, how='outer', lsuffix="_modulo1", rsuffix="_modulo2")
    coleta03_total_34 = pd.DataFrame.join(modulo3, modulo4, how='outer', lsuffix="_modulo3", rsuffix="_modulo4")
    coleta03_total_1234 = pd.DataFrame.join(coleta03_total_12, coleta03_total_34, how='outer')
    coleta = pd.DataFrame.join(coleta03_total_1234, modulo5)

    # DAI-FEO - Conversão dados de chuva
    converterChuva(coleta)
    coleta.loc[coleta['wetness'] > 1023, 'wetness'] = np.NaN

    # DAI-FEO - Conversão temperatura do solo (modulo5)
    # Feita no arduino
    
    # DAI-FEO - Conversão umidade do solo - Fórmula 4.1 (página 31)
    filtragemForaEscopoTemperatura(coleta)
    converterUmidadeSolo(coleta)

    # Filtragem de dados fora do escopo
    filtragemForaEscopoUmidade(coleta)

    coleta = coleta[1:]    # removendo duas primeiras horas para começar com todos os modulos funcionando [Andrei]    
    coleta = coleta.dropna(how='all')
#    coleta.plot(y='d15cm_modulo1')

    # Preparação para a fusão dos dados
    # Agrupando dados por profundidade no solo
    sensor15cm = coleta[['d15cm_modulo1', 'd15cm_modulo2', 'd15cm_modulo3', 'd15cm_modulo4']]
    sensor45cm = coleta[['d45cm_modulo1', 'd45cm_modulo2', 'd45cm_modulo3', 'd45cm_modulo4']]
    sensor75cm = coleta[['d75cm_modulo1', 'd75cm_modulo2', 'd75cm_modulo3', 'd75cm_modulo4']]
    
    # Substituindo NaN pelo último valor
    sensor15cm = sensor15cm.fillna(method='ffill')
    sensor45cm = sensor45cm.fillna(method='ffill')
    sensor75cm = sensor75cm.fillna(method='ffill')
    
    # Media
    sensor15cmFusedMean = basicFusion(sensor15cm, 'mean')
    sensor45cmFusedMean = basicFusion(sensor45cm, 'mean')
    sensor75cmFusedMean = basicFusion(sensor75cm, 'mean')
    
    # Mediana
    sensor15cmFusedMedian = basicFusion(sensor15cm, 'median')
    sensor45cmFusedMedian = basicFusion(sensor45cm, 'median')
    sensor75cmFusedMedian = basicFusion(sensor75cm, 'median')
    
    # Peirce
    sensor15cmFusedPeirce = applyPierce(sensor15cm)
    sensor45cmFusedPeirce = applyPierce(sensor45cm)
    sensor75cmFusedPeirce = applyPierce(sensor75cm)
    
    # Chauvenet
    sensor15cmFusedChauvenet = chauvenetFusion(sensor15cm)
    sensor45cmFusedChauvenet = chauvenetFusion(sensor45cm)
    sensor75cmFusedChauvenet = chauvenetFusion(sensor75cm)
    
    # zScore
    sensor15cmFusedZScore = zscoreFusion(sensor15cm)
    sensor45cmFusedZScore = zscoreFusion(sensor45cm)
    sensor75cmFusedZScore = zscoreFusion(sensor75cm)
    
    # G-ESD
    sensor15cmFusedGESD = gesdFusion(sensor15cm)
    sensor45cmFusedGESD = gesdFusion(sensor45cm)
    sensor75cmFusedGESD = gesdFusion(sensor75cm)
    
    # Modified zScore
    sensor15cmFusedMZScore = mzscoreFusion(sensor15cm)
    sensor45cmFusedMZScore = mzscoreFusion(sensor45cm)
    sensor75cmFusedMZScore = mzscoreFusion(sensor75cm)
    
if __name__ == '__main__':
    main()