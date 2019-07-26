from sklearn import preprocessing
from xgboost import XGBRegressor
from sklearn.externals import joblib
import numpy as np

from service import Storage as stor

class MoisturePredicition():
    def __init__(self):
        self.global_model = joblib.load("prediction_models/global.joblib.dat")
        self.local_P1 = joblib.load("prediction_models/local-P1.joblib.dat")
        self.local_P2 = joblib.load("prediction_models/local-P2.joblib.dat")
        self.local_P3 = joblib.load("prediction_models/local-P3.joblib.dat")
        self.local_P4 = joblib.load("prediction_models/local-P4.joblib.dat")
        self.local_P5 = joblib.load("prediction_models/local-P5.joblib.dat")
        self.local_P6 = joblib.load("prediction_models/local-P6.joblib.dat")
        self.local_P7 = joblib.load("prediction_models/local-P7.joblib.dat")
        self.local_P8 = joblib.load("prediction_models/local-P8.joblib.dat")
        self.local_P9 = joblib.load("prediction_models/local-P9.joblib.dat")
        self.new_data = ['Kc', 'T_max', 'RH_min', 'RH_max', 'Ri_f', 'W', 'Rn', 'U2', 'T_min', 'P']
        self.normalized_input_data = []


    def set_input_data(self, Kc, T_max, RH_min, RH_max, Ri_f, W, Rn, U2, T_min, P):
        X = [[Kc, T_max, RH_min, RH_max, Ri_f, W, Rn, U2, T_min, P]]
        self.normalized_input_data = preprocessing.normalize(X)

    def undo_normalization(self, Kc, T_max, RH_min, RH_max, Ri_f, W, Rn, U2, T_min, P, y):
        X = [Kc, T_max, RH_min, RH_max, Ri_f, W, Rn, U2, T_min, P]
        w = np.sqrt(np.sum(np.power(X, 2)))

        return y * w


    def global_prediction(self, Kc, T_max, RH_min, RH_max, Ri_f, W, Rn, U2, T_min, P):
        self.set_input_data(Kc, T_max, RH_min, RH_max, Ri_f, W, Rn, U2, T_min, P)
        y = self.global_model.predict(self.normalized_input_data)
        y_unnorm=self.undo_normalization(Kc, T_max, RH_min, RH_max, Ri_f, W, Rn, U2, T_min, P,y)

        return y_unnorm

    def local_prediction(self, monitoring_point, Kc, T_max, RH_min, RH_max, Ri_f, W, Rn, U2, T_min, P):
        self.set_input_data(Kc, T_max, RH_min, RH_max, Ri_f, W, Rn, U2, T_min, P)

        y=0
        if monitoring_point==1:
            y = self.local_P1.predict(self.normalized_input_data)
        elif monitoring_point==2:
            y = self.local_P2.predict(self.normalized_input_data)
        elif monitoring_point==3:
            y = self.local_P3.predict(self.normalized_input_data)
        elif monitoring_point==4:
            y = self.local_P4.predict(self.normalized_input_data)
        elif monitoring_point==5:
            y = self.local_P5.predict(self.normalized_input_data)
        elif monitoring_point==6:
            y = self.local_P6.predict(self.normalized_input_data)
        elif monitoring_point==7:
            y = self.local_P7.predict(self.normalized_input_data)
        elif monitoring_point==8:
            y = self.local_P8.predict(self.normalized_input_data)
        elif monitoring_point==9:
            y = self.local_P9.predict(self.normalized_input_data)

        y_unnorm = self.undo_normalization(Kc, T_max, RH_min, RH_max, Ri_f, W, Rn, U2, T_min, P, y)

        return y_unnorm


if __name__ == '__main__':
    database = stor.Storage('localhost', 'root', '12345678')
    start_date = start_date = "2016-02-01"
    station_id = 1
    data = database.get_meteorological_data(station_id, start_date)

    Kc = 0.5
    W = 5

    soil_prediction = MoisturePredicition()
    predicted_moisture = soil_prediction.global_prediction(Kc,data["T_max"],data["RH_min"],data["RH_max"],
                                    data["Ri"],W,data["Rn"],data["U"],data["T_min"],data["P"])

    p1 = soil_prediction.local_prediction(1,Kc,data["T_max"],data["RH_min"],data["RH_max"],
                                    data["Ri"],W,data["Rn"],data["U"],data["T_min"],data["P"])
    p2 = soil_prediction.local_prediction(2,Kc,data["T_max"],data["RH_min"],data["RH_max"],
                                    data["Ri"],W,data["Rn"],data["U"],data["T_min"],data["P"])
    p3 = soil_prediction.local_prediction(3,Kc,data["T_max"],data["RH_min"],data["RH_max"],
                                    data["Ri"],W,data["Rn"],data["U"],data["T_min"],data["P"])
    p4 = soil_prediction.local_prediction(4,Kc,data["T_max"],data["RH_min"],data["RH_max"],
                                  data["Ri"],W,data["Rn"],data["U"],data["T_min"],data["P"])
    p5 = soil_prediction.local_prediction(5,Kc,data["T_max"],data["RH_min"],data["RH_max"],
                                    data["Ri"],W,data["Rn"],data["U"],data["T_min"],data["P"])
    p6 = soil_prediction.local_prediction(6,Kc,data["T_max"],data["RH_min"],data["RH_max"],
                                    data["Ri"],W,data["Rn"],data["U"],data["T_min"],data["P"])
    p7 = soil_prediction.local_prediction(7,Kc,data["T_max"],data["RH_min"],data["RH_max"],
                                    data["Ri"],W,data["Rn"],data["U"],data["T_min"],data["P"])
    p8 = soil_prediction.local_prediction(8,Kc,data["T_max"],data["RH_min"],data["RH_max"],
                                    data["Ri"],W,data["Rn"],data["U"],data["T_min"],data["P"])
    p9 = soil_prediction.local_prediction(9,Kc,data["T_max"],data["RH_min"],data["RH_max"],
                                    data["Ri"],W,data["Rn"],data["U"],data["T_min"],data["P"])


    print("global {}".format(predicted_moisture))

    print("p1 {}".format(p1))
    print("p2 {}".format(p2))
    print("p3 {}".format(p3))
    print("p4 {}".format(p4))
    print("p5 {}".format(p5))
    print("p6 {}".format(p6))
    print("p7 {}".format(p7))
    print("p8 {}".format(p8))
    print("p9 {}".format(p9))