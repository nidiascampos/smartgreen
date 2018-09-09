import pandas as pd

def normalizarDados(data):
    for index, row in data.iterrows():
        data.at[index, 'when'] = pd.Timestamp(row['when']).replace(minute=0, second=0, microsecond=0)

def table2timetable(data):
    data = data.set_index(['when'])
    data.index = pd.to_datetime(data.index)
    data = data.sort_index()
    return data

def retime(data, frequency='H', method='linear'):
    data = table2timetable(data)            # Transforma em Timetable
    data = data.resample(frequency).bfill()    # Resample (Hora)
    data = data.interpolate(method=method)    # Interpolar (linear)

    return data

