from service import Storage as stor
from service import Fusion as fusion

class MatricPotential:
    def __init__(self,Pirri,):
        self.Pirri=Pirri
        self.NHB=0
        self.t_irri=0

    def set_NHB(self,value):
        self.NHB=value

    def vanGenuchten(self,thetaR, thetaS, alpha, n, psiM):
        num = thetaS - thetaR

        den = (alpha * psiM) ** n

        den = (den + 1) ** (1 - 1 / n)

        theta = thetaR + (num / den)
        return theta


    def compute_irrigation_time(self):
        self.t_irri=self.NHB/self.Pirri
        return self.t_irri


if __name__ == '__main__':
    database = stor.Storage('localhost', 'root', '12345678')

    # field information
    field_id = 1
    field_info = database.get_field_information(field_id)
    farm_id = field_info[0]
    crop_id = field_info[1]
    irrigation_system_id = field_info[4]

    # crop information
    crop_info = database.get_crop_info(crop_id)
    critical_condition_moisture = crop_info[7]

    # irrigation system info
    irrigation_info = database.get_irrigation_system_info(irrigation_system_id)
    irrigation_type = irrigation_info[0]
    irrigation_ef = irrigation_info[1]
    irrigation_pe = irrigation_info[2]

    #soil layer info
    monitoring_points_ids = database.get_monitoring_points(field_id)
    print("monitoring point ids {}".format(monitoring_points_ids))

    #calcular NHB e Tempo de ir para irrigação para cada ponto de monitoramento
    NHB_MP=[]
    NHB=0
    soil_layers=[]
    manejo = MatricPotential(irrigation_pe)
    date = "2016-02-01"
    soil_layer_id=0
    layer_depth=0
    field_condition_moisture=0
    residual_water_content=0
    saturation_water_content=0
    alpha_air_entry_suction=0
    n_pore_size_distribution=0
    current_humidity=0
    u=0
    date = "2016-02-01"
    ms=[]


    f = fusion.Fusion()

    for mp_id in monitoring_points_ids:
        soil_layers = database.get_soil_layer_info(field_id,mp_id)
        NHB=[]
        m=[]

        for layer in soil_layers:
            soil_layer_id=layer[0]
            layer_depth=layer[1]
            field_condition_moisture=layer[2]
            residual_water_content=layer[5]
            saturation_water_content=layer[6]
            alpha_air_entry_suction=layer[7]
            n_pore_size_distribution = layer[8]
            moisture_sensor_type_id = layer[9]

            #buscar umidade do solo atual
            u=database.get_moisture_data(date,field_id,mp_id, soil_layer_id)

            criterias = database.get_moisture_remotion_criteria(moisture_sensor_type_id)
            f.set_soil_moisture_remotion_criteria(criterias["min"], criterias["max"])
            u=f.check_soil_moisture_remotion_criteria(u)
            m.append(u)

            #manejo para cada ponto de monitoramento
            # current_humidity = manejo.vanGenuchten(residual_water_content,saturation_water_content,alpha_air_entry_suction,n_pore_size_distribution,u)
            # fc_moisture = manejo.vanGenuchten(residual_water_content,saturation_water_content,alpha_air_entry_suction,n_pore_size_distribution,field_condition_moisture)
            # critical_moisture = manejo.vanGenuchten(residual_water_content,saturation_water_content,alpha_air_entry_suction,n_pore_size_distribution,critical_condition_moisture)
            #
            # if current_humidity <= critical_moisture:
            #     NHB.append((fc_moisture-current_humidity)*layer_depth)
            # else:
            #     continue

        #NHB_MP.append(NHB)
        ms.append(m)

    #print("NHB {}".format(NHB))

    print("moistures {}".format(ms))

    f_data = f.cooperative_fusion(ms)
    print("f_moistures {}".format(f_data))

    #f_data_ch = f.chauvenetFusion(ms)
    #print("f_chau {}".format(f_data_ch))

    #f_data_z = f.zscoreFusion(ms)
    #print("f_z {}".format(f_data_z))

    print("ms {}".format(ms))

    #f_data_gesd = f.gesdFusion(ms,maxOLs=len(monitoring_points_ids))
    #print("f_gesd {}".format(f_data_gesd))

    f_data_mz=f.mzscoreFusion(ms)
    print("f_mz {}".format(f_data_mz))




