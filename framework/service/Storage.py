import MySQLdb
import numpy as np


class Storage():
    def __init__(self, host, user, password):
        self.con = MySQLdb.connect(host, user, password)

    # field_storage_commands
    def insert_field(self,farm_id, crop_id, crop_current_stage,irrigation_system_id, description,
                     register_date, monitoring_point_number):
        cursor = self.con.cursor()
        query = "INSERT INTO smartgreen.Field " \
                "(farm_id, crop_id, crop_init_stage,crop_current_stage, irrigation_system_id," \
                "description,register_date, monitoring_point_number)"\
                "VALUES(%s,%s,%s,%s,%s,%s,%s)"
        args = (farm_id, crop_id, crop_current_stage,
                irrigation_system_id,description,register_date, monitoring_point_number)
        cursor.execute(query, args)
        self.con.commit()

        query = "SELECT LAST_INSERT_ID()"
        cursor.execute(query)
        return cursor.fetchone()

    def get_field_info_by_description(self,farm_id,crop_id,irrigation_system_id,description):
        cursor = self.con.cursor()
        query="select * from smartgreen.Field where farm_id=%s and crop_id=%s and irrigation_system_id=%s " \
              "and description=%s"
        args=(farm_id,crop_id,irrigation_system_id,description)
        cursor.execute(query,args)
        return cursor.fetchone()

    def get_fields(self,farm_id):
        cursor = self.con.cursor()
        query="select * from smartgreen.Field where farm_id=%s"
        cursor.execute(query)
        return cursor.fetchall()

    def get_field_information(self, field_id):
        cursor = self.con.cursor()
        query ="SELECT farm_id, crop_id, crop_current_stage, irrigation_system_id, " \
               "monitoring_point_number "\
                "FROM smartgreen.Field WHERE id="+str(field_id)

        cursor.execute(query)
        return cursor.fetchone()

    def update_crop_current_stage(self, value, crop_id):
        cursor = self.con.cursor()
        query = "UPDATE smartgreen.Field SET crop_current_stage =%s WHERE crop_id = %s"
        args = (value,crop_id)
        cursor.execute(query,args)
        cursor.commit()


    # metereological_station_storage_commands
    def insert_metereological_station(self, latitude, longitude, altitude, state, city):
        cursor = self.con.cursor()
        query = "INSERT INTO smartgreen.Meteorological_Station " \
                "(latitude, longitude, altitude, state, city) " \
                "VALUES(%s,%s,%s,%s,%s)"
        args = (latitude, longitude, altitude, state, city)
        cursor.execute(query, args)
        self.con.commit()

        query = "SELECT LAST_INSERT_ID()"
        cursor.execute(query)
        return cursor.fetchone()

    def insert_meteorological_data(self,station_id, date, T_max, T_min, RH_max, RH_min, Rn, U, P, Ri):
        cursor = self.con.cursor()
        query = "INSERT INTO smartgreen.Meteorological_Data " \
                "(Meteorological_Station_ID, Date,T_max, T_min, RH_max, RH_min, Rn, U, P, Ri) " \
                "VALUES(%s,%s,%s,%s,%s, %s,%s,%s,%s,%s)"
        args = (station_id, date, T_max, T_min, RH_max, RH_min, Rn, U, P, Ri)
        cursor.execute(query, args)
        self.con.commit()

        query = "SELECT LAST_INSERT_ID()"
        cursor.execute(query),Ri
        return cursor.fetchone()

    def get_meteorological_data_mean(self,station_id, start_date, stop_date):
        cursor = self.con.cursor()
        query = "SELECT T_max, T_min, RH_max, RH_min, Rn, U, P, Ri " \
             "FROM smartgreen.Meteorological_Data " \
                "WHERE meteorological_station_id = %s AND date >= %s AND date <%s"
        args = (station_id,start_date,stop_date)
        cursor.execute(query,args)
        result=cursor.fetchall()
        data={"T_max":0, "T_min":0, "RH_max":0, "RH_min":0, "Rn":0, "U":0, "P":0,"Ri":0}


        cT_max=len(result)
        cT_min=len(result)
        cRH_max=len(result)
        cRH_min=len(result)
        cRn=len(result)
        cU=len(result)
        cP=len(result)
        cRi=len(result)

        for x in result:
            try:
                data["T_max"]+=x[0]
            except ValueError as e:
                cT_max=cT_max-1

            try:
                data["T_min"]+=x[1]
            except ValueError as e:
                cT_min=cT_min-1

            try:
                data["RH_max"]+=x[2]
            except ValueError as e:
                cRH_max=cRH_max-1

            try:
                data["RH_min"]+=x[3]
            except ValueError as e:
                cRH_min=cRH_min-1

            try:
                data["Rn"]+=x[4]
            except ValueError as e:
                cRn=cRn-1

            try:
                data["U"]+=x[5]
            except ValueError as e:
                cU=cU-1

            try:
                data["P"]+=x[6]
            except ValueError as e:
                cP=cP-1

            try:
                data["Ri"]+=x[7]
            except ValueError as e:
                cRi=cRi-1

        data["T_max"]=data["T_max"]/cT_max
        data["T_min"] = data["T_min"] / cT_min
        data["RH_max"]=data["RH_max"]/cRH_max
        data["RH_min"] = data["RH_min"] / cRH_min
        data["Rn"] = data["Rn"] / cRn
        data["U"] = data["U"] / cU
        data["P"] = data["P"] / cP
        data["Ri"] = data["Ri"] / cRi

        return data

    def get_meteorological_data(self,station_id, date):
        cursor = self.con.cursor()
        query = "SELECT T_max, T_min, RH_max, RH_min, Rn, U, P, Ri " \
             "FROM smartgreen.Meteorological_Data " \
                "WHERE meteorological_station_id = %s AND date = %s"
        args = (station_id,date)
        cursor.execute(query,args)
        result=cursor.fetchone()

        if result is not None:
            try:

                if len(result)>0:
                    r=[]
                    for val in result:
                        if val==np.nan or val==None:
                            r.append(0)
                        else:
                            r.append(val)

                    result=r
                    data={"T_max":result[0], "T_min":result[1], "RH_max":result[2], "RH_min":result[3], "Rn":result[4], "U":result[5],
                      "P":result[6],"Ri":result[7]}
                    return data
                else: return None
            except TypeError:
                return None
        else:
            return None




    # user_storage_commands
    def insert_user(self, username, type_ID, password):
        cursor = self.con.cursor()
        query = "INSERT INTO smartgreen.User " \
                "(username,type_ID, password) " \
                "VALUES(%s,%s,%s)"
        args = (username, type_ID,password)
        cursor.execute(query, args)
        self.con.commit()

        query = "SELECT LAST_INSERT_ID()"
        cursor.execute(query)
        return cursor.fetchone()


    def insert_user_type(self, name, description):
        cursor = self.con.cursor()
        query = "INSERT INTO smartgreen.User_Type " \
                "(name, description) " \
                "VALUES(%s,%s)"
        args = (name, description)
        cursor.execute(query, args)
        self.con.commit()

    def get_user(self,username):
        cursor = self.con.cursor()
        query="SELECT * FROM smartgreen.User where username=%s"

        cursor.execute(query,(username,))
        return cursor.fetchone()

    def get_user_type(self,type_id):
        cursor = self.con.cursor()
        query = "select name from smartgreen.User_Type where ID=%s"
        cursor.execute(query,(type_id,))
        res  = cursor.fetchone()
        if res is not None:
            res=res[0]

        return res


    # farm_storage_commands
    def insert_farm(self, latitude, longitude, altitude, user_id, meteorological_station_id, rua, numero, bairro,
                    cidade, estado, cep, pais,nome):
        cursor = self.con.cursor()
        query = "INSERT INTO smartgreen.Farm " \
                "(latitude, longitude, altitude, User_ID, Meteorological_Station_ID, " \
                "rua, numero, bairro, cidade, estado, cep, pais,nome) " \
                "VALUES(%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)"
        args = (latitude, longitude, altitude, user_id, meteorological_station_id,rua, numero, bairro,
                    cidade, estado, cep, pais,nome)
        cursor.execute(query, args)
        self.con.commit()

        query = "SELECT LAST_INSERT_ID()"
        cursor.execute(query)
        return cursor.fetchone()


    def get_farm_info(self, rua, numero, bairro, cidade, estado, cep, pais,nome):
        cursor = self.con.cursor()
        query="select * from smartgreen.Farm where rua=%s and numero=%s and bairro=%s and cidade=%s and estado=%s " \
              "and cep=%s and pais=%s and nome=%s"
        args=(rua, numero, bairro, cidade, estado, cep, pais,nome)
        cursor.execute(query,args)

        return cursor.fetchone()

    def get_farms(self):
        cursor = self.con.cursor()
        query = "select * from smartgreen.Farm"
        cursor.execute(query)
        return cursor.fetchall()

    # crop_storage_commands
    def insert_crop_type(self, description, initial_stage, intermediate_stage, final_stage, initial_stage_kc,
                         intermediate_stage_kc, final_stage_kc, critical_condition_moisture):
        cursor = self.con.cursor()
        query = "INSERT INTO smartgreen.Crop " \
                "(description, initial_stage,intermediate_stage, final_stage, initial_stage_kc, intermediate_stage_kc, final_stage_kc, critical_condition_moisture) " \
                "VALUES(%s,%s,%s,%s,%s,%s,%s,%s)"
        args = (description, initial_stage, intermediate_stage, final_stage, initial_stage_kc, intermediate_stage_kc,
                final_stage_kc, critical_condition_moisture)
        cursor.execute(query, args)
        self.con.commit()

        query = "SELECT LAST_INSERT_ID()"
        cursor.execute(query)
        return cursor.fetchone()

    def get_crop_types(self):
        cursor = self.con.cursor()
        query = "select * from smartgreen.Crop"
        cursor.execute(query)
        return cursor.fetchall()

    def get_crop_info(self,crop_id):
        cursor = self.con.cursor()
        query = "SELECT description, initial_stage,intermediate_stage, final_stage, initial_stage_kc, " \
                "intermediate_stage_kc, final_stage_kc, critical_condition_moisture " \
                "FROM smartgreen.Crop WHERE id="+str(crop_id)

        cursor.execute(query)
        return cursor.fetchone()

    def get_crop_info_by_description(self,description):
        cursor = self.con.cursor()
        query = "select * from smartgreen.Crop where description=%s"
        cursor.execute(query, (description,))
        return cursor.fetchone()


    # irrigation_storage_commands
    def insert_irrigation_system_type(self, name, description):
        cursor = self.con.cursor()
        query = "INSERT INTO smartgreen.Irrigation_System_Type " \
                "(name, description) " \
                "VALUES(%s,%s)"
        args = (name, description)
        cursor.execute(query, args)
        self.con.commit()

        query = "SELECT LAST_INSERT_ID()"
        cursor.execute(query)
        return cursor.fetchone()

    def get_irrigation_system_types(self):
        cursor = self.con.cursor()
        query = "select * from smartgreen.Irrigation_System_Type"
        cursor.execute(query)
        return cursor.fetchall()

    def get_irrigation_system_type(self, name):
        cursor = self.con.cursor()
        query = "select * from smartgreen.Irrigation_System_Type where name=%s"
        cursor.execute(query,(name,))
        return cursor.fetchone()

    def insert_irrigation_system(self, type, ef, pe):
        cursor = self.con.cursor()
        query = "INSERT INTO smartgreen.Irrigation_System " \
                "(type_ID, Ef, PE) " \
                "VALUES(%s,%s,%s)"
        args = (type, ef, pe)
        cursor.execute(query, args)
        self.con.commit()

        query = "SELECT LAST_INSERT_ID()"
        cursor.execute(query)
        return cursor.fetchone()

    def get_irrigation_system(self,type, ef, pe):
        cursor = self.con.cursor()
        query = "SELECT * FROM smartgreen.Irrigation_System " \
                "WHERE type_ID=%s AND ABS(Ef - %s) < 0.00005 AND PE=%s"
        args=(type, ef, pe)
        cursor.execute(query,args)
        return cursor.fetchone()

    def get_irrigation_systems(self):
        cursor = self.con.cursor()
        query = "select * from smartgreen.Irrigation_System"
        cursor.execute(query)
        return cursor.fetchall()

    def get_irrigation_system_info(self,id):
        cursor = self.con.cursor()
        query = "SELECT type_ID, Ef, PE FROM smartgreen.Irrigation_System " \
                "WHERE ID ="+str(id)

        cursor.execute(query)
        return cursor.fetchone()

    def insert_irrigation_management_type(self,name,description):
        cursor = self.con.cursor()
        query = "INSERT INTO smartgreen.Irrigation_Management_Type " \
                "(name,description) " \
                "VALUES (%s,%s)"
        args = (name,description)

        cursor.execute(query,args)
        self.con.commit()

        query = "SELECT LAST_INSERT_ID()"
        cursor.execute(query)
        return cursor.fetchone()

    def insert_irrigation_management(self,farm_id, field_id, monitoring_point_id, management_type, water_needed, date):
        cursor = self.con.cursor()
        query = "INSERT INTO smartgreen.Irrigation_Management" \
                "(Farm_ID, Field_ID, Monitoring_Point_ID, management_type_id, water_needed,date) " \
                "VALUES(%s,%s,%s,%s,%s)"
        args = (farm_id, field_id,monitoring_point_id,management_type,water_needed,date)
        cursor.execute(query, args)
        self.con.commit()

        query = "SELECT LAST_INSERT_ID()"
        cursor.execute(query)
        return cursor.fetchone()

    def get_irrigation_water(self, farm_id, field_id, monitoring_point_id, management_type, date):
        cursor = self.con.cursor()
        query = "SELECT water_needed FROM smartgreen.Irrigation_Management " \
                "WHERE Farm_ID=%s AND Field_ID=%s AND monitoring_point_id=%s " \
                "AND management_type_id=%s AND date=%s"
        args = (farm_id, field_id, monitoring_point_id, management_type, date)
        cursor.execute(query,args)
        r = cursor.fetchone()

        result=None
        if r!=None:
            result=r[0]

        return result

    # soil_storage_commands
    def insert_moisture_sensor_type(self,name,description):
        cursor = self.con.cursor()
        query = "INSERT INTO smartgreen.Moisture_Sensor_Type " \
                "(name, description) " \
                "VALUES(%s,%s)"
        args = (name, description)
        cursor.execute(query, args)
        self.con.commit()

        query = "SELECT LAST_INSERT_ID()"
        cursor.execute(query)
        return cursor.fetchone()

    def get_moisture_sensor_type(self,name):
        cursor = self.con.cursor()
        query = "select * from smartgreen.Moisture_Sensor_Type " \
                "where name=%s"

        cursor.execute(query,(name,))
        return cursor.fetchone()

    def get_moisture_sensors(self):
        cursor = self.con.cursor()
        query = "select * from smartgreen.Moisture_Sensor_Type"
        cursor.execute(query)
        return cursor.fetchall()

    def insert_monitoring_point(self, id, field_id,description, soil_layer_number, moisture_gathering_type):
        cursor = self.con.cursor()
        query = "INSERT INTO smartgreen.Monitoring_Point " \
                "(id,field_id,description, soil_layer_number, moisture_gathering_type) " \
                "VALUES(%s,%s,%s,%s,%s)"
        args = (id, field_id,description,soil_layer_number,moisture_gathering_type)
        cursor.execute(query, args)
        self.con.commit()

    def get_monitoring_point(self,id,field_id):
        cursor = self.con.cursor()
        query = "select * from smartgreen.Monitoring_Point where id=%s and field_id=%s"
        args=(id,field_id)
        cursor.execute(query,args)
        result = cursor.fetchone()
        return result

    def get_monitoring_points(self,field_id):
        cursor = self.con.cursor()
        query = "SELECT id from smartgreen.Monitoring_Point WHERE field_id="+str(field_id)
        cursor.execute(query)
        result= cursor.fetchall()
        r = []

        if len(result)>0:
            for x in result:
                r.append(x[0])

        return r


    def insert_soil_depth_type(self,value,description, fusion_id,
                               field_capacity,residual_water_content,
                               saturation_water_content, alpha_air_entry_suction,
                               n_pore_size_distribution):
        cursor = self.con.cursor()
        query = "INSERT INTO smartgreen.Depth_Type " \
                "(value, description,fusion_id, field_capacity,"\
                "residual_water_content, saturation_water_content,"\
                "alpha_air_entry_suction, n_pore_size_distribution) " \
                "VALUES(%s,%s,%s,%s,%s,%s,%s.%s)"
        args = (value, description,fusion_id,field_capacity,residual_water_content,
                saturation_water_content, alpha_air_entry_suction, n_pore_size_distribution,)
        cursor.execute(query, args)
        self.con.commit()

        query = "SELECT LAST_INSERT_ID()"
        cursor.execute(query)
        return cursor.fetchone()

    def get_soil_depth(self, id):
        cursor = self.con.cursor()
        query = "SELECT * from smartgreen.Depth_Type WHERE id=" + str(id)
        cursor.execute(query)
        result = cursor.fetchone()

        return result

    def get_soil_depth_ID(self,value,field_capacity,residual_water_content,
                               saturation_water_content, alpha_air_entry_suction,
                               n_pore_size_distribution):
        cursor = self.con.cursor()
        query = "select id from smartgreen.Depth_Type where value=%s " \
                "and field_capacity=%s " \
                "and ABS(residual_water_content - %s) < 0.5 " \
                "and ABS(saturation_water_content - %s) < 0.000005 " \
               "and ABS(alpha_air_entry_suction - %s) < 0.0000005 " \
                "and ABS(n_pore_size_distribution - %s) < 0.5"
        args=(value, field_capacity, residual_water_content,saturation_water_content, alpha_air_entry_suction,
                              n_pore_size_distribution
              )

        cursor.execute(query,args)
        result = cursor.fetchone()

        return result[0]


    def insert_soil_layer(self, depth_type, monitoring_point_id, moisture_sensor_type_id, field_id):
        cursor = self.con.cursor()
        query = "INSERT INTO smartgreen.Soil_Layer " \
                "(depth_type, monitoring_point_id,field_id, moisture_sensor_type_id) " \
                "VALUES(%s,%s,%s,%s)"
        args = (depth_type, monitoring_point_id,moisture_sensor_type_id, field_id)
        cursor.execute(query, args)
        self.con.commit()

        query = "SELECT LAST_INSERT_ID()"
        cursor.execute(query)
        return cursor.fetchone()


    def insert_moisture_data(self, field_id, layer_id, monitoring_point_id, value):
        cursor = self.con.cursor()
        query = "INSERT INTO smartgreen.Soil_Moisture_Data " \
                "(matric_potential,soil_layer_id,field_id,monitoring_point_id) " \
                "VALUES(%s,%s,%s,%s)"
        args = (value, layer_id, field_id, monitoring_point_id)
        cursor.execute(query, args)
        self.con.commit()

    def get_soil_layer_info(self,field_id,mp_id):
        cursor = self.con.cursor()
        query = "SELECT * FROM smartgreen.Soil_Layer "\
                "WHERE field_id=%s AND monitoring_point_id=%s"
        args=(field_id,mp_id)
        cursor.execute(query,args)
        result=cursor.fetchall()
        return result

    def get_soil_layer_id(self, field_id, mp_id, depth_type):
        cursor = self.con.cursor()
        query ="select id from smartgreen.Soil_Layer " \
               "where depth_type=%s and monitoring_point_id=%s and field_id=%s"
        args=(depth_type,mp_id,field_id)
        cursor.execute(query, args)
        result = cursor.fetchone()
        return result


    def insert_moisture_data(self, date, field_id, layer_id, monitoring_point_id, value):
        cursor = self.con.cursor()
        query = "INSERT INTO smartgreen.Soil_Moisture_Data " \
                "(date,matric_potential,soil_layer_id,field_id,monitoring_point_id) " \
                "VALUES(%s,%s,%s,%s,%s)"
        args = (date,value, layer_id, field_id, monitoring_point_id)
        cursor.execute(query, args)
        self.con.commit()
        query = "SELECT LAST_INSERT_ID()"
        cursor.execute(query)
        return cursor.fetchone()

    def get_moisture_data(self,date,field_id, mp_id, layer_id):
        cursor = self.con.cursor()
        query = "SELECT matric_potential FROM smartgreen.Soil_Moisture_Data " \
                "WHERE date = %s AND field_id=%s AND monitoring_point_id=%s AND soil_layer_id=%s"
        args = (date,field_id,mp_id,layer_id)
        cursor.execute(query,args)
        result=cursor.fetchall()

        #print("result {}".format(result))

        value=0
        c=0
        if len(result)>0:
            for r in result:
                if r[0]!=None:
                    value+=r[0]
                    c+=1

            if c!=0:
                result=value/c
            else:
                result=None
        else:
            result=None

        return result

    def insert_monitoring_point_power_data(self, field_id, monitoring_point_id, value):
        cursor = self.con.cursor()
        query = "INSERT INTO smartgreen.Monitoring_Point_Power_Data " \
                "(monitoring_point_id, field_id, power_level) " \
                "VALUES(%s,%s,%s)"
        args = (monitoring_point_id, field_id, value)
        cursor.execute(query, args)
        self.con.commit()

    #remotion criterias commands
    def insert_weather_remotion_criteria(self,station_id, Tmax_less, Tmin_less, RHmax_less, RHmin_less, Rn_less,
                                         U_less, P_less, Ri_less, Tmax_greater, Tmin_greater, RHmax_greater,
                                         RHmin_greater, Rn_greater, U_greater, P_greater, Ri_greater):

        cursor = self.con.cursor()
        query = "INSERT INTO smartgreen.Weather_Remotion_Criteria " \
                "(station_id, Tmax_less, Tmin_less, RHmax_less, RHmin_less, Rn_less," \
                "U_less, P_less, Ri_less, Tmax_greater, Tmin_greater, RHmax_greater, RHmin_greater, " \
                "Rn_greater, U_greater, P_greater, Ri_greater) " \
                "VALUES(%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)"
        args = (station_id, Tmax_less, Tmin_less, RHmax_less, RHmin_less, Rn_less,
                U_less, P_less, Ri_less, Tmax_greater, Tmin_greater, RHmax_greater,
                RHmin_greater, Rn_greater, U_greater, P_greater, Ri_greater)
        cursor.execute(query, args)
        self.con.commit()
        query = "SELECT LAST_INSERT_ID()"
        cursor.execute(query)
        return cursor.fetchone()

    def get_weather_remotion_criteria(self,station_id):
        cursor = self.con.cursor()
        query = "SELECT * FROM smartgreen.Weather_Remotion_Criteria "\
                "WHERE station_id="+str(station_id)

        cursor.execute(query)
        r=cursor.fetchall()

        x = {"Tmax_less": None, "Tmin_less": None, "RHmax_less": None, "RHmin_less": None,
             "Rn_less": None, "U_less": None, "P_less": None, "Ri_less": None,
             "Tmax_greater": None, "Tmin_greater": None, "RHmax_greater": None,
             "RHmin_greater": None, "Rn_greater": None, "U_greater": None, "P_greater": None, "Ri_greater": None}

        if len(r)>0:
            result=r[0]

            x = {"Tmax_less":result[2], "Tmin_less":result[3], "RHmax_less":result[4], "RHmin_less":result[5],
             "Rn_less":result[6], "U_less":result[7], "P_less":result[8], "Ri_less":result[9], "Tmax_greater":result[10],
             "Tmin_greater":result[11], "RHmax_greater":result[12], "RHmin_greater":result[13], "Rn_greater":result[14],
             "U_greater":result[15], "P_greater":result[16], "Ri_greater":result[17]}

        return x


    def insert_moisture_remotion_criteria(self,moisture_sensor_id,value_min,value_max):
        cursor = self.con.cursor()
        query = "INSERT INTO smartgreen.Moisture_Remotion_Criteria " \
                "(moisture_sensor_id,value_less,value_greater) " \
                "VALUES(%s,%s,%s)"
        args = (moisture_sensor_id,value_min,value_max)
        cursor.execute(query, args)
        self.con.commit()
        query = "SELECT LAST_INSERT_ID()"
        cursor.execute(query)
        return cursor.fetchone()

    def get_moisture_remotion_criteria(self, sensor_id):
        cursor = self.con.cursor()
        query = "SELECT value_less,value_greater FROM smartgreen.Moisture_Remotion_Criteria " \
                "WHERE moisture_sensor_id=" + str(sensor_id)

        cursor.execute(query)
        r = cursor.fetchall()

        x = {"min": None, "max": None}
        if len(r) > 0:
            result = r[0]
            x = {"min": result[0], "max": result[1]}

        return x

    #fusion commands
    def get_fusion_method(self,fusion_id):
        cursor = self.con.cursor()
        query = "SELECT * FROM smartgreen.Fusion_Type "\
                "WHERE id="+str(fusion_id)

        cursor.execute(query)
        r=cursor.fetchall()

        x = {"id":None,"name":None,"description":None}
        if len(r)>0:
            result=r[0]
            x = {"id":result[0],"name":result[1],"description":result[2]}


        return x

    def insert_fusion_method(self,name,description):
        cursor = self.con.cursor()
        query = "INSERT INTO smartgreen.Fusion_Type " \
                "(name, description) " \
                "VALUES(%s,%s)"
        args = (name,description)
        cursor.execute(query, args)
        self.con.commit()
        query = "SELECT LAST_INSERT_ID()"
        cursor.execute(query)
        return cursor.fetchone()


    #server address commands
    def insert_field_communication(self,farm_id, field_id, coap_server_address, mqtt_server_address, http_server_address,mqtt_topic):
        cursor = self.con.cursor()
        query = "INSERT INTO smartgreen.Field_Communication " \
                "(farm_id, field_id, coap_server_address, mqtt_server_address, http_server_address,mqtt_topic) " \
                "VALUES(%s,%s,%s,%s,%s,%s)"
        args = (farm_id, field_id, coap_server_address, mqtt_server_address, http_server_address,mqtt_topic)
        cursor.execute(query, args)
        self.con.commit()
        query = "SELECT LAST_INSERT_ID()"
        cursor.execute(query)
        return cursor.fetchone()


    def get_field_communication(self,farm_id, field_id):
        cursor = self.con.cursor()
        query = "select id, coap_server_address, mqtt_server_address, http_server_address,mqtt_topic from smartgreen.Field_Communication " \
                "where farm_id=%s and field_id=%s"
        args = (farm_id, field_id)
        cursor.execute(query, args)
        result = cursor.fetchone()
        return result