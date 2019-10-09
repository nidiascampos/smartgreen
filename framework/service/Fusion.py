from service import Storage as stor
import numpy as np
from scipy.special import erfc
from PyAstronomy import pyasl
import	pandas	as	pd


class Fusion():
    def __init__(self):
        #definicao de limites de variáveis meteorologicas
        self.Tmax_less=0
        self.Tmin_less=0
        self.RHmax_less=0
        self.RHmin_less=0
        self.Rn_less=0
        self.U_less=0
        self.P_less=0
        self.Ri_less=0
        self.Tmax_greater=0
        self.Tmin_greater=0
        self.RHmax_greater=0
        self.RHmin_greater=0
        self.Rn_greater=0
        self.U_greater=0
        self.P_greater=0
        self.Ri_greater=0

        #definicao de limite de umidade do solo
        self.soil_moisture_less=0
        self.soil_moisture_greater=0

        self.valid_criterias = {"Tmax_less": True, "Tmin_less": True, "RHmax_less": True, "RHmin_less": True,
                           "Rn_less": True, "U_less": True, "P_less": True, "Ri_less": True, "Tmax_greater": True,
                           "Tmin_greater": True, "RHmax_greater": True, "RHmin_greater": True, "Rn_greater": True,
                           "U_greater": True, "P_greater": True, "Ri_greater": True}

        self.soil_valid_criterias = {"min":True,"max":True}


    def set_weather_remotion_criterias(self,Tmax_less, Tmin_less, RHmax_less, RHmin_less, Rn_less,
                                         U_less, P_less, Ri_less, Tmax_greater, Tmin_greater, RHmax_greater,
                                         RHmin_greater, Rn_greater, U_greater, P_greater, Ri_greater):
        self.Tmax_less = Tmax_less
        self.Tmin_less = Tmin_less
        self.RHmax_less = RHmax_less
        self.RHmin_less= RHmin_less
        self.Rn_less = Rn_less
        self.U_less = U_less
        self.P_less = P_less
        self.Ri_less = Ri_less
        self.Tmax_greater = Tmax_greater
        self.Tmin_greater = Tmin_greater
        self.RHmax_greater = RHmax_greater
        self.RHmin_greater = RHmin_greater
        self.Rn_greater = Rn_greater
        self.U_greater = U_greater
        self.P_greater = P_greater
        self.Ri_greater = Ri_greater

        self.valid_criterias = {"Tmax_less": True, "Tmin_less": True, "RHmax_less": True, "RHmin_less": True,
             "Rn_less": True, "U_less": True,"P_less": True, "Ri_less": True, "Tmax_greater": True,
             "Tmin_greater": True, "RHmax_greater": True, "RHmin_greater": True, "Rn_greater": True,
                "U_greater": True, "P_greater": True, "Ri_greater": True}

        if Tmax_less == None: self.valid_criterias["Tmax_less"]=False
        if Tmin_less == None: self.valid_criterias["Tmin_less"] = False
        if RHmax_less == None: self.valid_criterias["RHmax_less"]=False
        if RHmin_less == None: self.valid_criterias["RHmin_less"] = False
        if Rn_less == None: self.valid_criterias["Rn_less"] = False
        if U_less == None: self.valid_criterias["U_less"] = False
        if P_less == None: self.valid_criterias["P_less"] = False
        if Ri_less == None: self.valid_criterias["Ri_less"] = False

        if Tmax_greater == None: self.valid_criterias["Tmax_greater"]=False
        if Tmin_greater == None: self.valid_criterias["Tmin_greater"] = False
        if RHmax_greater == None: self.valid_criterias["RHmax_greater"]=False
        if RHmin_greater == None: self.valid_criterias["RHmin_greater"] = False
        if Rn_greater == None: self.valid_criterias["Rn_greater"] = False
        if U_greater == None: self.valid_criterias["U_greater"] = False
        if P_greater == None: self.valid_criterias["P_greater"] = False
        if Ri_greater == None: self.valid_criterias["Ri_greater"] = False



    def set_soil_moisture_remotion_criteria(self,min, max):
        self.soil_moisture_less = min
        self.soil_moisture_greater = max

        self.soil_valid_criterias = {"min":True,"max":True}

        if min==None: self.soil_valid_criterias["min"]=False
        if max == None: self.soil_valid_criterias["max"]=False


    def check_weather_remotion_criterias(self,T_max, T_min, RH_max, RH_min, Rn, U, P, Ri):

        if T_max!=None:
            if self.valid_criterias["Tmax_less"]==True and T_max<self.Tmax_less: T_max=None
            if self.valid_criterias["Tmax_greater"] == True and T_max> self.Tmax_greater: T_max=None

        if T_min!=None:
            if self.valid_criterias["Tmin_less"]==True and T_min<self.Tmin_less: T_min=None
            if self.valid_criterias["Tmin_greater"] == True and T_min> self.Tmin_greater: T_min=None

        if RH_max != None:
            if self.valid_criterias["RHmax_less"] == True and RH_max < self.RHmax_less: RH_max = None
            if self.valid_criterias["RHmax_greater"] == True and RH_max > self.RHmax_greater: RH_max = None

        if RH_min != None:
            if self.valid_criterias["RHmin_less"] == True and RH_min < self.RHmin_less: RH_min = None
            if self.valid_criterias["RHmin_greater"] == True and RH_min > self.RHmin_greater: RH_min = None

        if Rn != None:
            if self.valid_criterias["Rn_less"] == True and Rn < self.Rn_less: Rn = None
            if self.valid_criterias["Rn_greater"] == True and Rn > self.Rn_greater: Rn = None

        if U != None:
            if self.valid_criterias["U_less"] == True and U < self.U_less: U = None
            if self.valid_criterias["U_greater"] == True and U > self.U_greater: U = None

        if P != None:
            if self.valid_criterias["P_less"] == True and P < self.P_less: P = None
            if self.valid_criterias["P_greater"] == True and P > self.P_greater: P = None

        if Ri != None:
            if self.valid_criterias["Ri_less"] == True and Ri < self.Ri_less: Ri = None
            if self.valid_criterias["Ri_greater"] == True and Ri > self.Ri_greater: Ri = None


        return {"T_max":T_max,"T_min":T_min, "RH_max":RH_max, "RH_min":RH_min, "Rn":Rn, "U":U, "P":P,"Ri": Ri}

    def check_soil_moisture_remotion_criteria(self,soil_moisture):
        if soil_moisture!=None:
            if self.soil_valid_criterias["min"] == True and soil_moisture < self.soil_moisture_less: soil_moisture=None
            if self.soil_valid_criterias["max"] == True and soil_moisture> self.soil_moisture_greater: soil_moisture =None

        return soil_moisture

    def cooperative_fusion(self, data):
        return np.nanmean(data,axis=0)

    def set_outlier_as_nan(self,data,filter):
        i=0
        for f in filter:
            if f == False:
                data[i] = np.nan
            # for d in range(0, len(f)):
            #     if f[d]==False:
            #         data[i][d]=np.nan
            i+=1

        return data



    ######################################################
    # Fusão de dados dos sensores utilizando Chauvenet
    # http://www.statisticshowto.com/chauvenets-criterion/
    ######################################################
    def chauvenetFusion(self,sensor):
        mean = np.mean(sensor, axis=0)  # Mean of incoming array y
        stdv =np.std(sensor,axis=0)  # Its standard deviation
        N = len(sensor)  # Lenght of incoming arrays

        criterion = 1.0 / (2 * N)  # Chauvenet's criterion
        d = abs(sensor - mean) / stdv  # Distance of a value to mean in stdv's
        d /= 2.0 ** 0.5  # The left and right tail threshold values
        prob = erfc(d)  # Area normal dist
        filter = prob >= criterion  # The 'accept' filter array with booleans

        sensor_filtered=self.set_outlier_as_nan(sensor,filter)

        #    return sensor[filter], sensor[~filter], filter  # Return the cleared version, the rejected version and the filter
        return self.cooperative_fusion(sensor_filtered)

    ####################################################################
    # Fusão de dados dos sensores utilizando zscore
    # http://www.statisticshowto.com/probability-and-statistics/z-score/
    ####################################################################
    def zscoreFusion(self,sensor):

        mean = np.mean(sensor, axis=0)  # Mean of incoming array y
        stdv = np.std(sensor, axis=0)  # Its standard deviation

        zscore = (sensor - mean) / stdv  # Distance of a value to mean in stdv's
        prob = erfc(zscore)  # Area normal dist
        filter = prob >= zscore  # The 'accept' filter array with booleans


        sensor_filtered=self.set_outlier_as_nan(sensor,filter)

        #    return sensor[filter], sensor[~filter], filter  # Return the cleared version, the rejected version and the filter

        return np.nanmean(sensor_filtered)

    ######################################################################################
    # Fusão de dados dos sensores utilizando Generalized ESD
    # https://www.itl.nist.gov/div898/handbook/eda/section3/eda35h3.htm
    # https://www.hs.uni-hamburg.de/DE/Ins/Per/Czesla/PyA/PyA/pyaslDoc/aslDoc/outlier.html
    ######################################################################################
    def gesdFusion(self,sensor, maxOLs=6):
        data = pd.DataFrame(np.array(sensor))

        for column in data.columns:
            gesd = pyasl.generalizedESD(data[column],maxOLs)

            for outlier in gesd[1]:
                data.ix[column][outlier]=np.NaN


        return np.nanmean(np.array(data.values))

    ##################################################################
    # Fusão de dados dos sensores utilizando Modified zScore
    # https://www.itl.nist.gov/div898/handbook/eda/section3/eda35h.htm
    ##################################################################
    def mzscoreFusion(self, sensor):
        median = np.median(sensor)  # Mediana do sensor
        MAD = np.abs(sensor - median)
        MAD = np.median(MAD)  # Median Absolute Deviation

        mzscore = (0.6745 * (sensor - median)) / MAD  # Cálculo do Modified ZScore
        prob = erfc(mzscore)  # Area normal dist
        filter = prob >= mzscore  # The 'accept' filter array with booleans


        sensor_filtered = self.set_outlier_as_nan(sensor, filter)

        #    return sensor[filter], sensor[~filter], filter  # Return the cleared version, the rejected version and the filter
        return np.nanmean(sensor_filtered)


    def apply_method(self,method,data):
        res=[]
        if method=="zscore":
            res =self.zscoreFusion(data)
        elif method=="gesd":
            res =self.gesdFusion(data)
        elif method=="mzscore":
            res =self.mzscoreFusion(data)
        elif method=="chauvenet":
            res =self.chauvenetFusion(data)
        else:
            res=self.cooperative_fusion(data)

        return res

if __name__ == '__main__':
    database = stor.Storage('localhost', 'root', '12345678')
    station_id = 1
    Tmax_less=20
    Tmin_less=20
    RHmax_less=20
    RHmin_less=20
    Rn_less=None
    U_less=None
    P_less=None
    Ri_less=None
    Tmax_greater=39
    Tmin_greater=39
    RHmax_greater=None
    RHmin_greater=None
    Rn_greater=None
    U_greater=None
    P_greater=None
    Ri_greater=250


    #database.insert_weather_remotion_criteria(station_id,Tmax_less, Tmin_less, RHmax_less, RHmin_less, Rn_less,
    #                                     U_less, P_less, Ri_less, Tmax_greater, Tmin_greater, RHmax_greater,
    #                                     RHmin_greater, Rn_greater, U_greater, P_greater, Ri_greater)

    criterias = database.get_weather_remotion_criteria(station_id)
    fusion = Fusion()
    fusion.set_weather_remotion_criterias(criterias["Tmax_less"],criterias["Tmin_less"], criterias["RHmax_less"],
                                          criterias["RHmin_less"], criterias["Rn_less"],criterias["U_less"],
                                          criterias["P_less"], criterias["Ri_less"],criterias["Tmax_greater"],
                                          criterias["Tmin_greater"], criterias["RHmax_greater"],
                                          criterias["RHmin_greater"], criterias["Rn_greater"],criterias["U_greater"],
                                          criterias["P_greater"], criterias["Ri_greater"])

    start_date = start_date = "2016-02-01"
    data = database.get_meteorological_data(station_id, start_date)



    data_s_out=fusion.check_weather_remotion_criterias(data["T_max"],data["T_min"],data["RH_max"],data["RH_min"],data["Rn"],data["U"],
                                            data["P"],data["Ri"])

    digital_t_id = 1# database.insert_moisture_sensor_type("watermaker","digital tensiomenter")
    analog_t_id= 2 #database.insert_moisture_sensor_type("soilcontrol", "analog tensiomenter")
    #database.insert_moisture_remotion_criteria(digital_t_id,0,200)
    #database.insert_moisture_remotion_criteria(analog_t_id,0,100)

    criterias = database.get_moisture_remotion_criteria(analog_t_id)
    fusion.set_soil_moisture_remotion_criteria(criterias["min"],criterias["max"])
    field_id = 1
    mp_ids = monitoring_points_ids = database.get_monitoring_points(field_id)

    mp_data=[]
    for mp_id in monitoring_points_ids:
        soil_layers = database.get_soil_layer_info(field_id, mp_id)
        data = []
        for layer in soil_layers:
            soil_layer_id = layer[0]
            # buscar umidade do solo atual
            u = database.get_moisture_data(start_date, field_id, mp_id, soil_layer_id)
            data_s_out  = fusion.check_soil_moisture_remotion_criteria(u)
            data.append(data_s_out)

        mp_data.append(data)


    print("mp_data {}".format(mp_data))



