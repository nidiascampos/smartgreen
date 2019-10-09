from service import Storage as stor
from service import Fusion as fus

class MatricPotential:
    def __init__(self,db_host,db_user,db_pass):
        self.RNI={}
        self.ITN=0
        self.water_needed=0
        self.t_irri=0
        self.database = stor.Storage(db_host, db_user, db_pass)
        self.fusion = fus.Fusion()

        #field_information
        self.field_id = 0
        self.farm_id = 0
        self.crop_id = 0
        self.irrigation_system_id =0

        # crop information
        self.critical_condition_moisture = 0

        # irrigation system info
        self.irrigation_type = 0
        self.irrigation_ef = 0
        self.irrigation_p = 0

        # soil layer info
        self.monitoring_points_ids=[]

        self.date = ''

    def set_field_info(self,field_id):
        self.field_id = field_id
        field_info = self.database.get_field_information(field_id)
        self.farm_id = field_info[0]
        self.crop_id = field_info[1]
        self.irrigation_system_id = field_info[4]

        # crop information
        crop_info = self.database.get_crop_info(self.crop_id)
        self.critical_condition_moisture = crop_info[7]

        # irrigation system info
        irrigation_info = self.database.get_irrigation_system_info(self.irrigation_system_id)
        self.irrigation_type = irrigation_info[0]
        self.irrigation_ef = irrigation_info[1]
        self.irrigation_p = irrigation_info[2]

        # soil layer info
        self.monitoring_points_ids = self.database.get_monitoring_points(field_id)
        #print("monitoring point ids {}".format(monitoring_points_ids))

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

                u = self.database.get_moisture_data(self.date, field_id, mp_id, soil_layer_id)
                criterias = self.database.get_moisture_remotion_criteria(moisture_sensor_type_id)
                self.fusion.set_soil_moisture_remotion_criteria(criterias["min"], criterias["max"])
                u = self.fusion.check_soil_moisture_remotion_criteria(u)

                data = []
                if layer_depth_type in self.soil_layer_data:
                    data = self.soil_layer_data[layer_depth_type]

                data.append(u)
                self.soil_layer_data.update({layer_depth_type:data})

    def compute_RNI(self,field_id,date):
        self.set_field_info(field_id)
        self.data_preprocessing(date)

        fusioned_data=0
        depth_info=[]
        self.RNI={}
        afd=0#available ready water
        rni=0
        layer_depth = 0
        field_condition_moisture = 0
        residual_water_content = 0
        saturation_water_content = 0
        alpha_air_entry_suction = 0
        n_pore_size_distribution = 0
        current_humidity=0
        critical_moisture=0
        fusion_id=0


        for key in self.soil_layer_data.keys():
            layer=self.database.get_soil_depth(key)
            layer_depth=layer[1]
            fusion_id=layer[3]
            field_capacity=layer[4]
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
            fc_moisture = self.vanGenuchten(residual_water_content,saturation_water_content,
                                            alpha_air_entry_suction,n_pore_size_distribution,
                                            field_capacity)
            critical_moisture = self.vanGenuchten(residual_water_content,
                                                  saturation_water_content,
                                                  alpha_air_entry_suction,
                                                  n_pore_size_distribution,
                                                  self.critical_condition_moisture)

            afd=(fc_moisture-critical_moisture)*layer_depth
            rni=(fc_moisture-current_humidity)*layer_depth
            self.RNI.update({layer_depth:[current_humidity,critical_moisture,afd,rni]})

        depths=self.RNI.keys()
        min_depth = min(depths)
        moisture = self.RNI[min_depth]
        current_humidity=moisture[0]
        critical_moisture=moisture[1]
        self.water_needed=0


        if current_humidity <= critical_moisture:
            for key in self.RNI.keys():
                moisture=self.RNI[key]

                if key==min_depth:
                    self.water_needed+= moisture[2]
                else:
                    self.water_needed += moisture[3]

        self.ITN=self.water_need/self.irrigation_ef


        return self.ITN

    #model to compute soil moisture
    def vanGenuchten(self,thetaR, thetaS, alpha, n, psiM):
        num = thetaS - thetaR

        den = (alpha * psiM) ** n

        den = (den + 1) ** (1 - 1 / n)

        theta = thetaR + (num / den)
        return theta

    def compute_irrigation_time(self):
        self.t_irri=self.ITN/self.irrigation_p
        return self.t_irri

if __name__ == '__main__':

    irrigation_management = MatricPotential('localhost', 'root', '12345678')
    date = "2016-02-01"
    field_id = 1
    water_needed=irrigation_management.compute_RNI(field_id,date)

    print('water needed={}'.format(water_needed))






