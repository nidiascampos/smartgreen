from service import Storage as stor
from application.pyeto import fao
from application.pyeto import convert as conv
from datetime import date
from datetime import timedelta
from datetime import datetime

class HydroBalance:
    def __init__(self,Pirri,station_id, initial_stage,initial_stage_kc,
                 intermediate_stage,intermediate_stage_kc,
                 final_stage, final_stage_kc, crop_current_stage):

        self.init_stage=initial_stage
        self.init_kc=initial_stage_kc
        self.inter_stage=intermediate_stage
        self.inter_kc=intermediate_stage_kc
        self.final_stage=final_stage
        self.final_kc=final_stage_kc
        self.crop_current_stage=crop_current_stage

        self.Pirri=Pirri
        self.weather_station=station_id
        self.weather_data = {"T_max": 0, "T_min": 0, "RH_max": 0, "RH_min": 0, "Rn": 0, "U": 0, "P": 0, "Ri": 0}
        self.soil_moisture = 0


        self.kc = 0
        self.ETo=0
        self.ETc=0
        self.NHB=0
        self.t_irri=0

    def set_crop_current_stage(self, value):
        self.crop_current_stage= value

    def compute_current_kc(self):
        if self.crop_current_stage >= self.final_stage:
            self.kc = self.final_kc
        elif self.crop_current_stage <= self.init_stage:
            self.kc = self.init_kc

        else:
            a = (self.inter_kc - self.init_kc)
            b = (self.inter_stage - self.init_stage)
            c = (self.init_stage * self.inter_kc - self.inter_stage - self.init_kc)

            print("a {} b{} c{}".format(a, b, c))
            self.kc = (-a * self.crop_current_stage) - c
            self.kc = self.kc / b

    def set_weather_data(self, data):
        self.weather_data = data


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

    def execute_hydro_balance(self):
        self.compute_ETo_FAO(self.weather_data["T_max"],
                             self.weather_data["T_min"],
                             self.weather_data["RH_max"],
                             self.weather_data["RH_min"],
                             self.weather_data["Rn"],
                             self.weather_data["U"],
                             self.weather_data["P"])
        self.compute_current_kc()
        self.ETc = self.kc * self.ETo
        self.NHB += self.ETc - self.weather_data["Ri"] -self.soil_moisture

    def compute_irrigation_time(self):
        self.t_irri=self.NHB/self.Pirri
        return self.t_irri


if __name__ == '__main__':
    database = stor.Storage('localhost', 'root', '12345678')
    station_id = 1

    # field information
    field_id = 1
    field_info = database.get_field_information(field_id)
    farm_id = field_info[0]
    crop_id = field_info[1]
    crop_init_stage = field_info[2]
    crop_current_stage = 328#field_info[3]
    irrigation_system_id = field_info[4]

    # crop information
    crop_info = database.get_crop_info(crop_id)

    crop_description = crop_info[0]
    initial_stage = crop_info[1]
    intermediate_stage = crop_info[2]
    final_stage = crop_info[3]
    initial_stage_kc = crop_info[4]
    intermediate_stage_kc = crop_info[5]
    final_stage_kc = crop_info[6]
    critical_condition_moisture = crop_info[7]

    # irrigation system info
    irrigation_info = database.get_irrigation_system_info(irrigation_system_id)
    irrigation_type = irrigation_info[0]
    irrigation_ef = irrigation_info[1]
    irrigation_pe = irrigation_info[2]

    manejo = HydroBalance(irrigation_pe, station_id, initial_stage, initial_stage_kc,
                          intermediate_stage, intermediate_stage_kc,
                          final_stage, final_stage_kc, crop_current_stage)

    start_date = "2016-02-01"
    stop_date = "2016-03-01"
    d1 = start_date.split("-")
    d2 = stop_date.split("-")
    day1 = date(int(d1[0]), int(d1[1]), int(d1[2]))
    day2 = date(int(d2[0]), int(d2[1]), int(d2[2]))
    num_days = (day2 - day1).days

    crop_stage = crop_current_stage - num_days
    stage = crop_stage

    for day in range(crop_stage, crop_current_stage):
        if day > 1:
            day1 = day1+timedelta(days=1)
            start_date = day1.strftime("%Y-%m-%d")
            stage += 1

        else:
            day1 = datetime(int(d1[0]), int(d1[1]), int(d1[2]))


        data = database.get_meteorological_data(station_id, start_date)
        manejo.set_weather_data(data)

        manejo.set_crop_current_stage(stage)
        manejo.execute_hydro_balance()
        print ("data {}".format(data))
        print("start_date {}, crop_stage {}, kc {}, ETc {}, NHB {}".format(start_date, stage, manejo.kc, manejo.ETc,manejo.NHB))

    manejo.compute_irrigation_time()

    print("NHB = {}".format(manejo.NHB))

    #database.insert_irrigation_management(farm_id,0,2,manejo.NHB, stop_date)

    NHB = database.get_irrigation_water(farm_id,0,2,stop_date )

    print("stored NHB {}".format(NHB))