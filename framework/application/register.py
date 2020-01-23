from service import Storage as stor
import json

class Register:

    def __init__(self, db_host,db_user,db_pass,user_id):
        self.database = stor.Storage(db_host, db_user, db_pass)
        self.user_id=user_id
        self.farm_id=0
        self.crop_id=0
        self.weather_station_id=0
        self.soil_sensor_id=0
        self.field_id=0
        self.monitoring_ponts_number=0
        self.soil_layer_ids=[]
        self.moisture_gathering=0

    # return user id or 0 if user is already registered
    def register_user(self,username, usertype, password):

        id=self.database.get_user(username)

        if id is None:
            res = self.database.insert_user(username,usertype,password)
            id=res[0]

        else:
            id= 0

        return id

    # return user_info: id, username and user_type(specialist or regular)
    def get_user_info(self,username):
        user_info=self.database.get_user(username)

        res=None
        if user_info is not None:
            user_type = self.database.get_user_type(user_info[2])
            res=(user_info[0],user_info[1],user_type)

        return res


    #return farm id or 0 if farm is already registered
    def register_farm(self,  latitude, longitude, altitude, user_id, meteorological_station_id, rua,
                        numero, bairro, cidade, estado, cep, pais,nome):
        id=self.database.get_farm_info(rua, numero, bairro, cidade, estado, cep, pais,nome)

        if id is None:
            res=self.database.insert_farm(latitude, longitude, altitude, user_id, meteorological_station_id, rua,
                                  numero, bairro,cidade, estado, cep, pais)
            id=res[0]
        else:
            id=0

        return id

    def get_farm_info(self,rua, numero, bairro, cidade, estado, cep, pais,nome):
        res = self.database.get_farm_info(rua, numero, bairro, cidade, estado, cep, pais,nome)

        return res

    # return crop id or 0 if crop is already registered
    def register_crop(self,description, initial_stage, intermediate_stage, final_stage, initial_stage_kc,
                         intermediate_stage_kc, final_stage_kc, critical_condition_moisture):
        id = self.database.get_crop_info_by_description(description)

        if id is None:
            res=self.database.insert_crop_type(description, initial_stage, intermediate_stage, final_stage, initial_stage_kc,
                         intermediate_stage_kc, final_stage_kc, critical_condition_moisture)
            id=res[0]
        else:
            id=0

        return id

    def get_crop_info(self,description):
        res=self.database.get_crop_info_by_description(description)

        return res

    # return irrigation system type id or 0 if irrigation system type is already registered
    def register_irrigation_system_type(self,name, description):
        id = self.database.get_irrigation_system_type(name)
        if id is None:
            res=self.database.insert_irrigation_system_type(name,description)
            id=res[0]
        else:
            id=0

        return id

    def get_irrigation_system_type_info(self,name):
        res=self.database.get_irrigation_system_type(name)
        return res

    # return irrigation system id or 0 if irrigation system is already registered
    def register_irrigation_system(self, type_id,Ef, PE):
        id=self.database.get_irrigation_system(type_id,Ef,PE)

        if id is None:
            res = self.database.insert_irrigation_system(type_id,Ef, PE)
            id=res[0]
        else:
            id=0

        return id

    def get_irrigation_system(self,type_id,Ef, PE):
        res=self.database.get_irrigation_system(type_id,Ef,PE)
        return res

    # return moisture sensor id or 0 if moisture sensor type is already registered
    def register_moisture_sensor_type(self,name, description):
        id=self.database.get_moisture_sensor_type(name)
        if id is None:
            res=self.database.insert_moisture_sensor_type(name,description)
            id=res[0]
        else:
            id=0

        return id

    def get_moisture_sensor_type(self, name):
        res=self.database.get_moisture_sensor_type(name)
        return res

    # return field id or  0 if field is already registered
    def register_field(self,farm_id, crop_id, crop_current_stage, irrigation_system_id, description,
                       register_date, monitoring_point_number):

        id=self.database.get_field_info_by_description(farm_id,crop_id,irrigation_system_id,description)
        if id is None:
            res=self.database.insert_field(self, farm_id, crop_id, crop_current_stage,
                     irrigation_system_id, description, register_date, monitoring_point_number)
            id=res
        else:
            id=0

        return id


    def get_field(self,farm_id, crop_id, irrigation_system_id, description):
        res=self.database.get_field_info_by_description(farm_id,crop_id,irrigation_system_id,description)
        return res

    # return monitoring point id or 0 if monitoring point is already registered
    def register_monitoring_point(self,id, field_id, description, soil_layer_number,moisture_gathering_type):
        res = self.database.get_monitoring_point(id,field_id)
        if res is None:
            self.database.insert_monitoring_point(self, id, field_id, description, soil_layer_number,
                                                    moisture_gathering_type)
            res=id
        else:
            res=0

        return res

    def get_monitoring_point(self,id, field_id):
        res = self.database.get_monitoring_point(id, field_id)
        return res

    # return soil depth type id or 0 if soil depth is already registered
    def register_soil_depth_type(self,value,description, fusion_id,
                               field_capacity,residual_water_content,
                               saturation_water_content, alpha_air_entry_suction,
                               n_pore_size_distribution):
        id=self.database.get_soil_depth_ID(value,field_capacity,residual_water_content,
                               saturation_water_content, alpha_air_entry_suction,
                               n_pore_size_distribution)

        if id is None:
            res = self.database.insert_soil_depth_type(value,field_capacity,residual_water_content,
                               saturation_water_content, alpha_air_entry_suction,
                               n_pore_size_distribution)
            id=res[0]
        else:
            id=0

        return id


    def get_soil_depth_id(self,value, field_capacity, residual_water_content,
                                             saturation_water_content, alpha_air_entry_suction,
                                             n_pore_size_distribution):
        res = self.database.get_soil_depth_ID(value, field_capacity, residual_water_content,
                                             saturation_water_content, alpha_air_entry_suction,
                                             n_pore_size_distribution)
        return res

    # return soil layer id id or 0 if soil layer is already registered
    def register_soil_layer(self, field_id, mp_id, depth_type, moisture_sensor_type):
        id=self.database.get_soil_layer_id(field_id, mp_id, depth_type)

        if id is None:
            res=self.database.insert_soil_layer(depth_type,moisture_sensor_type,field_id,field_id)
            id=res[0]
        else:
            id=0

        return id

    def get_soil_layer_id(self, field_id, monitoring_point_id,depth_type):
        res=self.database.get_soil_layer_id(field_id,monitoring_point_id,depth_type)
        return res[0]

    # return server address id id or 0 if server address is already registered
    def register_field_communication(self, farm_id, field_id, coap_server_address, mqtt_server_address,
                                http_server_address,mqtt_topic):
        id = self.database.get_field_communication(farm_id, field_id)

        if id is None:
            res = self.database.insert_field_communication(farm_id, field_id, coap_server_address, mqtt_server_address,
                                                     http_server_address,mqtt_topic)
            id = res[0]
        else:
            id=0

        return id

    # return coap, mqtt, and http servers address
    def get_server_address(self,farm_id,field_id):
        res = self.database.get_field_servers(farm_id, field_id)
        return res

    def create_client_configuration_file(self, farm_id, field_id, monitoring_point_number, mp_info,
                                  coap_server_address, mqtt_server_address, http_server_address, mqtt_topic):
        config_info={
            "farm_id":farm_id,
            "field_id":field_id,
            "monitoring_point_number":monitoring_point_number,
            "mp_info":mp_info,
            "coap_server_address":coap_server_address,
            "mqtt_server_address":mqtt_server_address,
            "http_server_address":http_server_address,
            "mqtt_topic":mqtt_topic
        }

        file_name="client-configuration-farm_id="+str(farm_id)+"-field_id="+str(field_id)+".json"

        with open(file_name, 'w') as json_file:
            json.dump(config_info, json_file, indent=4)


if __name__ == '__main__':
#Register Class demonstration
    user_id=1#rubens_sonsol,specialist_user
    register = Register('localhost', 'root', '12345678',user_id)


#register user
    new_user="nidia"
    password="1234"
    user_type=1#specialist -> User_Type Table
    user_id=register.register_user(new_user,user_type,password)
    if user_id==0:#user already registered
        user_info=register.get_user_info(new_user)
        user_id=user_info[0]

#register farm
    rua = "none"
    numero = 0
    bairro = "none"
    cidade = "Paraipaba"
    estado = "Ceará"
    cep = "0"
    pais = "Brasil"
    nome = "Curu"
    latitude=4
    longitude=39
    altitude=20
    meteorological_station_id=1

    farm_id=register.register_farm( latitude, longitude, altitude, user_id, meteorological_station_id, rua,
                        numero, bairro, cidade, estado, cep, pais,nome)


    if farm_id==0:
        res=register.get_farm_info(rua,numero,bairro,cidade,estado,cep,pais,nome)
        farm_id=res[0]
#crop
    description="caju_anao"
    initial_stage=300
    intermediate_stage=700
    final_stage=1300
    initial_stage_kc=0.6
    intermediate_stage_kc=1
    final_stage_kc=1
    critical_condition_moisture=60

    crop_id=register.register_crop(description, initial_stage, intermediate_stage, final_stage, initial_stage_kc,
                         intermediate_stage_kc, final_stage_kc, critical_condition_moisture)

    if crop_id==0:
        res=register.get_crop_info(description)
        crop_id=res[0]

#irrigation system type
    irrigation_system_type_name="microsprinkler"
    irrigation_system_type_descr="microsprinkler system"
    irrigation_system_type_id=register.register_irrigation_system_type(irrigation_system_type_name,
                                                                       irrigation_system_type_descr)
    if irrigation_system_type_id==0:
        res = register.get_irrigation_system_type_info(irrigation_system_type_name)
        irrigation_system_type_id=res[0]

#irrigation system
    ef=0.8185
    pe=12.5
    irrigation_system_id=register.register_irrigation_system(irrigation_system_type_id,ef,pe)

    if irrigation_system_id==0:
        res = register.get_irrigation_system(irrigation_system_type_id,ef,pe)
        irrigation_system_id=res[0]


#Field
    crop_current_stage=1656
    field_description="asdf"
    register_date="2016-01-29 00:00:00"
    monitoring_ṕoint_number=9

    field_id=register.register_field(farm_id,crop_id,crop_current_stage,irrigation_system_id,
                                     field_description,register_date,monitoring_ṕoint_number)

    if field_id==0:
        res=register.get_field(farm_id, crop_id, irrigation_system_id, field_description)
        field_id=res[0]


#moisture sensor type
    moisture_sensor_type_name="soilcontrol"
    moisture_sensor_type_descr="analog tensiometer"
    moisture_sensor_type_id=register.register_moisture_sensor_type(moisture_sensor_type_name,
                                                                   moisture_sensor_type_descr)
    if moisture_sensor_type_id==0:
        res = register.get_moisture_sensor_type(moisture_sensor_type_name)
        moisture_sensor_type_id=res[0]

#depth_type
    mp_soil_layer_number = 3
    values=[150,450,750]
    fusion_ids=[1,1,1]
    field_capacities=[20,20,20]
    residual_water_contents=[0.1441,0.1441,0.1441]
    saturation_water_contents=[0.38839,0.38839,0.38839]
    alpha_air_entry_suctions=[0.022504,0.022504,0.022504]
    n_pore_size_distributions=[20.254,20.254,20.254]
    depth_description=["","",""]

    depth_ids=[]
    for n in range(0,mp_soil_layer_number):
        depth_id=register.register_soil_depth_type(values[n],depth_description[n], fusion_ids[n],
                               field_capacities[n],residual_water_contents[n],
                               saturation_water_contents[n], alpha_air_entry_suctions[n],
                               n_pore_size_distributions[n])
        if depth_id==0:
            depth_id=register.get_soil_depth_id(values[n],field_capacities[n],residual_water_contents[n],
                                           saturation_water_contents[n],alpha_air_entry_suctions[n],
                                           n_pore_size_distributions[n])

        depth_ids.append(depth_id)



#monitoring point
    stop=monitoring_ṕoint_number+1
    mp_ids=[]
    mp_description=""
    moisture_gathering='1'#none

    mp_info=[]
    for mp_id in range(1,stop):
        mp_ids.append(mp_id)
        register.register_monitoring_point(mp_id,field_id,mp_description,mp_soil_layer_number,moisture_gathering)

#soil layers
        soil_layer_ids={}
        for z in range(0, mp_soil_layer_number):
            soil_layer_id = register.register_soil_layer(field_id, mp_id, depth_ids[z], moisture_sensor_type_id)
            if soil_layer_id == 0:
                soil_layer_id = register.get_soil_layer_id(field_id, mp_id, depth_ids[z])

            soil_layer_ids[values[z]]=soil_layer_id
        mp_info.append({"id":mp_id,"soil_layer_ids":soil_layer_ids})


#Field Server Address
    coap_server="localhost"
    mqtt_server="localhost"
    http_server="localhost"
    mqtt_topic = "mp_data/soil_data_for_Smart&Green_at_" + http_server
    server_info_id=register.register_server_address(farm_id, field_id, coap_server,mqtt_server,http_server,mqtt_topic)
    if server_info_id==0:
        res = register.get_server_address(farm_id,field_id)
        server_info_id=res[0]


#create client configuration file

    register.create_client_configuration_file(farm_id,field_id,monitoring_ṕoint_number,mp_info,
                                              coap_server,mqtt_server,http_server,mqtt_topic)


#weather station
#moisture remotion criteria