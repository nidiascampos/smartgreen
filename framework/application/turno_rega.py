from service import Storage as stor
from application.pyeto import fao
from application.pyeto import convert as conv

class TurnoRega:
    def __init__(self,db_host,db_user,db_pass):
        self.database = stor.Storage(db_host, db_user, db_pass)

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

        self.Pirri=0
        self.weather_station=0
        self.weather_data = {"T_max": 0, "T_min": 0, "RH_max": 0, "RH_min": 0, "Rn": 0, "U": 0, "P": 0, "Ri": 0}

        self.kc = 0
        self.Eto=0
        self.Etc=0
        self.TR_dias=0
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

    def set_crop_current_stage(self, value):
        self.crop_current_stage=value

    def compute_current_kc(self):
        if self.crop_current_stage >= self.final_stage:
            self.kc = self.final_kc
        elif self.crop_current_stage <= self.init_stage:
            self.kc = self.init_kc
        else:
            a = (self.inter_kc - self.init_kc)
            b = (self.inter_stage - self.init_stage)
            c = (self.inter_stage * self.init_kc - self.init_stage - self.inter_kc)
            self.kc = (-a) * self.crop_current_stage - c
            self.kc = abs(self.kc / b)

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

    def execute_TR(self,start_date,stop_date, field_id, station_id):
        self.set_field_info(field_id)
        self.set_crop_info()
        self.set_irrigation_system_info()
        self.weather_station=station_id

        self.weather_data = self.database.get_meteorological_data_mean(station_id,
                                                                  start_date, stop_date)

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
        self.ITN=self.NHB/self.irrigation_ef

        return self.ITN

    def compute_irrigation_time(self):
        self.t_irri=self.ITN/self.irrigation_pe
        return self.t_irri

if __name__ == '__main__':
    irrigation_management=TurnoRega('localhost', 'root', '12345678')
    station_id = 1
    field_id = 1
    farm_id=1
    start_date = "2016-02-01"
    stop_date = "2016-03-01"

    water_needed=irrigation_management.execute_TR(start_date,stop_date,field_id,station_id)

    print("water_needed {}".format(water_needed))
    irrigation_management.compute_irrigation_time()

    # database = stor.Storage('localhost', 'root', '12345678')
    # monitoring_point_id=0#if the field does not have monitoring points
    # management_type=1#1 turno de rega; 2 hydro balance 3; matric potential 4 salvation
    # database.insert_irrigation_management(farm_id, field_id, monitoring_point_id,
    #                                       management_type,water_needed,stop_date)
    # water_need = database.get_irrigation_water(farm_id,field_id,monitoring_point_id,
    #                                            management_type,stop_date)