def converterChuva(data):
    for index, row in data.iterrows():
        # Sem chuva
        if row['wetness'] > 900 and row['wetness'] <= 1023:
            data.loc[index, 'wetness'] = 0
            
        # Chuva fraca
        elif row['wetness'] > 600 and row['wetness'] <= 900:
            data.loc[index, 'wetness'] = 1
            
        # Chuva moderada
        elif row['wetness'] > 400 and row['wetness'] <= 600:
            data.loc[index, 'wetness'] = 2
            
        # Chuva intensa
        elif row['wetness'] > 0 and row['wetness'] <= 400:
            data.loc[index, 'wetness'] = 3

        # Fora do Escopo
        else:
            data.loc[index, 'wetness'] = None
    # END for

def converterUmidadeSolo(data):
    for index, row in data.iterrows():
        data.loc[index, 'd15cm_modulo1'] = ((3.213*(row['d15cm_modulo1']/1000))+4.093)/(1-(0.009733*(row['d15cm_modulo1']/1000))-(0.01205*row['temperature']))
        data.loc[index, 'd15cm_modulo2'] = ((3.213*(row['d15cm_modulo2']/1000))+4.093)/(1-(0.009733*(row['d15cm_modulo2']/1000))-(0.01205*row['temperature']))
        data.loc[index, 'd15cm_modulo3'] = ((3.213*(row['d15cm_modulo3']/1000))+4.093)/(1-(0.009733*(row['d15cm_modulo3']/1000))-(0.01205*row['temperature']))
        data.loc[index, 'd15cm_modulo4'] = ((3.213*(row['d15cm_modulo4']/1000))+4.093)/(1-(0.009733*(row['d15cm_modulo4']/1000))-(0.01205*row['temperature']))
        
        data.loc[index, 'd45cm_modulo1'] = ((3.213*(row['d45cm_modulo1']/1000))+4.093)/(1-(0.009733*(row['d45cm_modulo1']/1000))-(0.01205*row['temperature']))
        data.loc[index, 'd45cm_modulo2'] = ((3.213*(row['d45cm_modulo2']/1000))+4.093)/(1-(0.009733*(row['d45cm_modulo2']/1000))-(0.01205*row['temperature']))
        data.loc[index, 'd45cm_modulo3'] = ((3.213*(row['d45cm_modulo3']/1000))+4.093)/(1-(0.009733*(row['d45cm_modulo3']/1000))-(0.01205*row['temperature']))
        data.loc[index, 'd45cm_modulo4'] = ((3.213*(row['d45cm_modulo4']/1000))+4.093)/(1-(0.009733*(row['d45cm_modulo4']/1000))-(0.01205*row['temperature']))
        
        data.loc[index, 'd75cm_modulo1'] = ((3.213*(row['d75cm_modulo1']/1000))+4.093)/(1-(0.009733*(row['d75cm_modulo1']/1000))-(0.01205*row['temperature']))
        data.loc[index, 'd75cm_modulo2'] = ((3.213*(row['d75cm_modulo2']/1000))+4.093)/(1-(0.009733*(row['d75cm_modulo2']/1000))-(0.01205*row['temperature']))
        data.loc[index, 'd75cm_modulo3'] = ((3.213*(row['d75cm_modulo3']/1000))+4.093)/(1-(0.009733*(row['d75cm_modulo3']/1000))-(0.01205*row['temperature']))
        data.loc[index, 'd75cm_modulo4'] = ((3.213*(row['d75cm_modulo4']/1000))+4.093)/(1-(0.009733*(row['d75cm_modulo4']/1000))-(0.01205*row['temperature']))