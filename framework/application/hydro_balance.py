from datetime import date
from datetime import datetime
from datetime import timedelta

from application.pyeto import convert as conv
from service import Fusion as fus
from service import Storage as stor

from application.pyeto import fao

from application.soil_moisture_prediction import MoisturePrediction

class HydroBalance:
    def __init__(self,db_host,db_user,db_pass):
        self.database = stor.Storage(db_host, db_user, db_pass)
        self.fusion = fus.Fusion()
        self.moist_pred=MoisturePrediction()
        self.moist_pred_type=0

        self.field_id=0
        self.farm_id=0
        self.irrigation_system_id=0

        #crop info
        self.crop_id = 0
        self.init_stage=0
        self.init_kc=0
        self.inter_stage=0
        self.inter_kc=0
        self.final_stage=0
        self.final_kc=0
        self.crop_current_stage=0
        self.critical_condition_moisture=0

        #irrigation system info
        self.irrigation_type = 0
        self.irrigation_ef = 0
        self.irrigation_pe = 0

        #soil info
        self.monitoring_points_ids=[]
        self.soil_layer_data={}
        self.soil_moisture = 0
        self.soil_mois_pred=0
        self.fusion_data={}
        self.soil_moisture_data={}

        #weather station info
        self.weather_station_id=0
        self.weather_data = {"T_max": 0, "T_min": 0, "RH_max": 0, "RH_min": 0, "Rn": 0, "U": 0, "P": 0, "Ri": 0}

        self.kc = 0
        self.ETo=0
        self.ETc=0
        self.NHB=0
        self.ITN=0
        self.t_irri=0

    def set_field_info(self, field_id):
        self.field_id = field_id
        field_info = self.database.get_field_information(field_id)
        self.farm_id = field_info[0]
        self.crop_id = field_info[1]
        self.crop_init_stage = field_info[2]
        self.crop_current_stage = field_info[3]
        self.irrigation_system_id = field_info[4]
        self.monitoring_points_ids = self.database.get_monitoring_points(self.field_id)

    def set_crop_info(self):
        crop_info = self.database.get_crop_info(self.crop_id)

        self.init_stage = crop_info[1]
        self.inter_stage = crop_info[2]
        self.final_stage = crop_info[3]
        self.init_kc = crop_info[4]
        self.inter_kc = crop_info[5]
        self.final_kc = crop_info[6]
        self.critical_condition_moisture = crop_info[7]

    def set_irrigation_system_info(self):
        irrigation_info = self.database.get_irrigation_system_info(self.irrigation_system_id)
        self.irrigation_type = irrigation_info[0]
        self.irrigation_ef = irrigation_info[1]
        self.irrigation_pe = irrigation_info[2]

    def get_farm_id(self):
        return self.farm_id

    def compute_current_kc(self,stage):
        if stage >= self.final_stage:
            self.kc = self.final_kc
        elif stage <= self.init_stage:
            self.kc = self.init_kc
        else:
            a = (self.inter_kc - self.init_kc)
            b = (self.inter_stage - self.init_stage)
            c = (self.inter_stage * self.init_kc - self.init_stage - self.inter_kc)
            self.kc = (-a )* stage - c
            self.kc = abs(self.kc / b)

    # apply outlier remotion criteria on data
    def data_preprocessing(self,date):
        soil_layers = []
        self.soil_layer_data = {}
        self.date = date


        for mp_id in self.monitoring_points_ids:
            soil_layers = self.database.get_soil_layer_info(self.field_id, mp_id)

            for layer in soil_layers:
                soil_layer_id = layer[0]
                layer_depth_type = layer[1]
                moisture_sensor_type_id = layer[4]

                u = self.database.get_moisture_data(self.date, self.field_id, mp_id,soil_layer_id)
                criterias = self.database.get_moisture_remotion_criteria(moisture_sensor_type_id)
                self.fusion.set_soil_moisture_remotion_criteria(criterias["min"],
                                                                criterias["max"])
                u = self.fusion.check_soil_moisture_remotion_criteria(u)

                data = []
                if layer_depth_type in self.soil_layer_data:
                    data = self.soil_layer_data[layer_depth_type]

                data.append(u)
                self.soil_layer_data.update({layer_depth_type:data})

    def compute_soil_moisture(self,date):
        self.data_preprocessing(date)
        fusioned_data=0
        depth_info=[]
        self.soil_moisture=0
        layer_depth = 0
        field_condition_moisture = 0
        residual_water_content = 0
        saturation_water_content = 0
        alpha_air_entry_suction = 0
        n_pore_size_distribution = 0
        fusion_id=0
        self.soil_moisture_data={}

        for key in self.soil_layer_data.keys():
            layer=self.database.get_soil_depth(key)
            layer_depth=layer[1]
            fusion_id=layer[3]
            residual_water_content=layer[5]
            saturation_water_content=layer[6]
            alpha_air_entry_suction=layer[7]
            n_pore_size_distribution = layer[8]

            fusion_type = self.database.get_fusion_method(fusion_id)
            fusioned_data = self.fusion.apply_method(fusion_type["name"],
                                                     self.soil_layer_data[key])

            current_humidity = self.vanGenuchten(residual_water_content,
                                                 saturation_water_content,
                                                 alpha_air_entry_suction,
                                                 n_pore_size_distribution,
                                                 fusioned_data)

            # a=current_humidity*layer_depth
            # print("layer_depth {}".format(a))
            u=current_humidity*layer_depth
            self.fusion_data.update({layer_depth:fusioned_data})
            self.soil_moisture_data.update({layer_depth:u})

        z=min(self.soil_moisture_data.keys())
        self.soil_moisture=self.soil_moisture_data[z]

    def run_local_prediction(self,date,fusion_type="zscore"):
        monitoring_points_ids = [1, 2, 3, 4, 5, 6, 7, 8, 9]
        predict_data=[]
        p = 9
        management_type = 4
        W = 0
        res = 0
        soil_layers = []
        self.soil_layer_data = {}
        data=0

        #get W
        for mp_id in monitoring_points_ids:
            res = self.database.get_irrigation_water(self.farm_id, self.field_id, mp_id, management_type, date)
            if res != None:
                W += res
            else:
                p = p - 1

        if p > 0:
            W = W / p

        #forecast soil moisture
        for mp_id in monitoring_points_ids:
            data = self.moist_pred.local_prediction(mp_id, self.kc,
                                                    self.weather_data["T_max"],
                                                    self.weather_data["RH_min"],
                                                    self.weather_data["RH_max"],
                                                    self.weather_data["Ri"],
                                                    W, self.weather_data["Rn"],
                                                    self.weather_data["U"],
                                                    self.weather_data["T_min"],
                                                    self.weather_data["P"])
            predict_data.append(data)

        #fusion data
        fusioned_data = self.fusion.apply_method(fusion_type,predict_data)

        self.soil_mois_pred = self.vanGenuchten(0.14010, 0.38839, 0.022504, 20.524, fusioned_data)
        self.soil_mois_pred = self.soil_mois_pred * 150
        # print("date {} W {} pm {} moist {}".format(date, W, pm, self.soil_mois_pred))
        return self.soil_mois_pred

    def run_global_prediction(self,date):
        monitoring_points_ids=[1,2,3,4,5,6,7,8,9]
        p=9
        management_type=4
        W=0
        res=0
        for id in monitoring_points_ids:
            res=self.database.get_irrigation_water(self.farm_id,self.field_id,id,management_type,date)
            if res!=None:
                W+=res
            else:
                p=p-1

        if p>0:
            W=W/p

        pm=self.moist_pred.global_prediction(self.kc,
                                          self.weather_data["T_max"],
                                          self.weather_data["RH_min"],
                                          self.weather_data["RH_max"],
                                          self.weather_data["Ri"],
                                          W,self.weather_data["Rn"],
                                          self.weather_data["U"],
                                          self.weather_data["T_min"],
                                          self.weather_data["P"])

        self.soil_mois_pred=self.vanGenuchten(0.14010,0.38839,0.022504,20.524,pm)
        self.soil_mois_pred=self.soil_mois_pred*150
        #print("date {} W {} pm {} moist {}".format(date, W, pm, self.soil_mois_pred))
        return self.soil_mois_pred

    #return water need in mm; prediction= 0 (without),1(local approach), 2 (global)
    def compute_RNI(self,start_date,stop_date,field_id,station_id,with_soil_data, prediction_type):
        self.set_field_info(field_id)
        self.set_crop_info()
        self.set_irrigation_system_info()
        self.moist_pred_type=prediction_type


        d1 = start_date.split("-")
        d2 = stop_date.split("-")
        day1 = date(int(d1[0]), int(d1[1]), int(d1[2]))
        day2 = date(int(d2[0]), int(d2[1]), int(d2[2]))
        num_days = (day2 - day1).days

        #synchronizing days to start crop development stage
        hoje = datetime.now()
        now = date(hoje.year,hoje.month,hoje.day)
        start_stage=self.crop_current_stage - (now-day2).days - num_days
        stage = start_stage

        self.NHB=0
        num_days+=1
        for day in range(0, num_days):
            self.weather_data= self.database.get_meteorological_data(station_id, start_date)
            nhb=self.execute_hydro_balance(stage)

            self.NHB+=nhb
            #print("date {} stage {} nhb_day {} NHB {}".format(start_date, stage, nhb,self.NHB))
            day1 = day1 + timedelta(days=1)
            start_date = day1.strftime("%Y-%m-%d")
            stage += 1


        if with_soil_data==True and len(self.monitoring_points_ids) > 0:
            self.compute_soil_moisture(stop_date)
            self.NHB-=self.soil_moisture

        if self.moist_pred_type == 1 and nhb != 0:
            day1 = day1 - timedelta(days=1)
            start_date = day1.strftime("%Y-%m-%d")
            stage -= 1
            self.run_global_prediction(start_date)
            self.NHB -= self.soil_mois_pred

        elif self.moist_pred_type == 2 and nhb != 0:
            day1 = day1 - timedelta(days=1)
            start_date = day1.strftime("%Y-%m-%d")
            stage -= 1
            self.run_local_prediction(start_date)

            self.NHB -= self.soil_mois_pred

        self.ITN=self.NHB/self.irrigation_ef

        return self.ITN

    def vanGenuchten(self,thetaR, thetaS, alpha, n, psiM):
        num = thetaS - thetaR

        den = (alpha * psiM) ** n

        den = (den + 1) ** (1 - 1 / n)

        theta = thetaR + (num / den)
        return theta

    def set_soil_moisture(self, thetaR, thetaS, alpha, n, psiM):
        self.soil_moisture= self.vanGenuchten(thetaR, thetaS, alpha, n, psiM)

    def compute_ETo_FAO(self, T_max, T_min, RH_max, RH_min, Rn, U, P):
        net_rad = Rn
        t = (conv.celsius2kelvin(T_min) + conv.celsius2kelvin(T_max)) / 2
        ws = U
        svp = (fao.svp_from_t(T_max) + fao.svp_from_t(T_min)) / 2
        avp = fao.avp_from_rhmin_rhmax(fao.svp_from_t(T_min),
                                       fao.svp_from_t(T_max),
                                       RH_min,
                                       RH_max)
        delta_svp = fao.delta_svp(conv.kelvin2celsius(t))
        psy = fao.psy_const(P)
        shf = 0.0

        self.ETo = fao.fao56_penman_monteith(net_rad, t, ws, svp, avp, delta_svp, psy, shf)

        return self.ETo

    def execute_hydro_balance(self, stage):
        nhb=0
        if self.weather_data!=None:
            self.compute_ETo_FAO(self.weather_data["T_max"],
                             self.weather_data["T_min"],
                             self.weather_data["RH_max"],
                             self.weather_data["RH_min"],
                             self.weather_data["Rn"],
                             self.weather_data["U"],
                             self.weather_data["P"])

            self.compute_current_kc(stage)
            self.ETc = self.kc * self.ETo
            nhb=self.ETc - self.weather_data["Ri"]


        return nhb

    def compute_irrigation_time(self):
        self.t_irri=self.ITN/self.irrigation_pe
        return self.t_irri

if __name__ == '__main__':
    irrigation_management=HydroBalance('localhost', 'root', '12345678')
    station_id = 1
    field_id = 1
    farm_id=1
    start_date = "2016-5-23"
    stop_date = "2016-5-27"
    moist_pred_type=2# 0 para não usadar dados da predição 1 para predição global e 2 para predição local de dados do
    water_needed = []
    moist_pred = []
    NHB=[]
    w = 0
    fusion_type="zscore"

    soil_moist_data=False # usar dados do solo no balanço

    #Balanço Hidrico para um periodo
    w = irrigation_management.compute_RNI(start_date, stop_date, field_id, station_id,
                                          soil_moist_data, moist_pred_type)
    if w != 0:
        water_needed.append(w)
        moist_pred.append(irrigation_management.soil_mois_pred)
        NHB.append(irrigation_management.NHB)

    print("soil_moisture {}".format(moist_pred))
    print("NHB {}".format(NHB))
    print("water_needed {}".format(water_needed))

    # #Balanço Hidrico Diário dado um periodo
    # d1 = start_date.split("-")
    # d2 = stop_date.split("-")
    # day1 = date(int(d1[0]), int(d1[1]), int(d1[2]))
    # day2 = date(int(d2[0]), int(d2[1]), int(d2[2]))
    # num_days = (day2 - day1).days
    #
    # for day in range(0, num_days):
    #     w = irrigation_management.compute_RNI(start_date, start_date, field_id, station_id, False,moist_pred_type)
    #     if w != 0:
    #         water_needed.append(w)
    #         moist_pred.append(irrigation_management.soil_mois_pred)
    #         NHB.append(irrigation_management.NHB)
    #     day1 = day1 + timedelta(days=1)
    #     start_date = day1.strftime("%Y-%m-%d")
    #
    # print("soil_moisture {}".format(moist_pred))
    # print("NHB {}".format(NHB))
    # print("water_needed {}".format(water_needed))

    # database = stor.Storage('localhost', 'root', '12345678')
    # monitoring_point_id=0#if the field does not have monitoring points
    # management_type=2#1 turno de rega; 2 hydro balance 3; matric potential 4 salvation
    # database.insert_irrigation_management(farm_id, field_id, monitoring_point_id,
    #                                       management_type,water_needed,stop_date)
    # water_need = database.get_irrigation_water(farm_id,field_id,monitoring_point_id,
    #                                            management_type,stop_date)

