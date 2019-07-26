from service import Storage as stor
from application.pyeto import fao
from application.pyeto import convert as conv

class TurnoRega:
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

        self.kc = 0
        self.Eto=0
        self.Etc=0
        self.TR_dias=0
        self.NHB=0
        self.t_irri=0


    def set_crop_current_stage(self, value):
        self.crop_current_stage-value

    def compute_current_kc(self)  :
        if self.crop_current_stage >= self.final_stage:
            self.kc = self.final_kc
        elif self.crop_current_stage <= self.init_stage:
            self.kc = self.init_kc

        else:
            a = (self.inter_kc - self.init_kc)
            b = (self.inter_stage -self.init_stage)
            c = (self.init_stage*self.inter_kc - self.inter_stage - self.init_kc)

            print("a {} b{} c{}".format(a,b,c))
            self.kc=(-a*self.crop_current_stage)-c
            self.kc=self.kc/b


    def set_weather_data(self,data):
        self.weather_data=data

    def compute_ETo_FAO(self,T_max, T_min, RH_max, RH_min, Rn, U, P):
        net_rad= Rn
        t=(conv.celsius2kelvin(T_min)+conv.celsius2kelvin(T_max))/2
        ws=U
        svp= (fao.svp_from_t(T_max)+fao.svp_from_t(T_min))/2
        avp=fao.avp_from_rhmin_rhmax(fao.svp_from_t(T_min),
                                     fao.svp_from_t(T_max),
                                     RH_min,
                                     RH_max)
        delta_svp=fao.delta_svp(conv.kelvin2celsius(t))
        psy=fao.psy_const(P)
        shf = 0.0

        self.Eto=fao.fao56_penman_monteith(net_rad,t,ws,svp,avp,delta_svp,psy,shf)

        return self.Eto


    def execute_TR(self):
        self.compute_ETo_FAO(self.weather_data["T_max"],
                             self.weather_data["T_min"],
                             self.weather_data["RH_max"],
                             self.weather_data["RH_min"],
                             self.weather_data["Rn"],
                             self.weather_data["U"],
                             self.weather_data["P"])
        self.compute_current_kc()
        self.ETc=self.kc*self.Eto
        self.NHB = self.ETc - self.weather_data["Ri"]
        self.t_irri=self.NHB/self.Pirri


if __name__ == '__main__':
    database=stor.Storage('localhost', 'root', '12345678')
    start_date="2016-02-01"
    stop_date="2016-03-01"
    station_id=1
    data=database.get_meteorological_data_mean(station_id,start_date,stop_date)

#field information
    field_id=1
    field_info=database.get_field_information(field_id)
    farm_id=field_info[0]
    crop_id=field_info[1]
    crop_init_stage=field_info[2]
    crop_current_stage=field_info[3]
    irrigation_system_id=field_info[4]

#crop information
    crop_info=database.get_crop_info(crop_id)

    crop_description=crop_info[0]
    initial_stage=crop_info[1]
    intermediate_stage=crop_info[2]
    final_stage=crop_info[3]
    initial_stage_kc=crop_info[4]
    intermediate_stage_kc=crop_info[5]
    final_stage_kc=crop_info[6]
    critical_condition_moisture=crop_info[7]

#irrigation system info
    irrigation_info = database.get_irrigation_system_info(irrigation_system_id)
    irrigation_type=irrigation_info[0]
    irrigation_ef=irrigation_info[1]
    irrigation_pe=irrigation_info[2]

    manejo = TurnoRega(irrigation_pe,station_id, initial_stage,initial_stage_kc,
                 intermediate_stage,intermediate_stage_kc,
                 final_stage, final_stage_kc, crop_current_stage)
    manejo.set_weather_data(data)
    manejo.execute_TR()

    print("NHB = {}".format(manejo.NHB))