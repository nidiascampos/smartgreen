"""This is a usage example of Smart&Green MQTT Client which works as publisher (default) and
subscriber. The main function demonstrates how to configure class as an subscriber.
 ''"""

import paho.mqtt.client as mqtt #import the client1
import time
from service import Storage as stor
from datetime import datetime
import json


class MQTTClient(mqtt.Client):
    def __init__(self, cname, **kwargs):
        super(MQTTClient, self).__init__(cname, **kwargs)
        self.database=0
        self.isSubscriber=False
        self.msg_data={}
        self.rc=-1
        self.ret_pub=[]
        self.topic=''
        self.farm_id=0
        self.field_id=0

        self.last_pub_time = time.time()
        self.topic_ack = []
        self.run_flag = True
        self.subscribe_flag = False
        self.bad_connection_flag = False
        self.connected_flag = False
        self.disconnect_flag = False
        self.disconnect_time = 0.0
        self.pub_msg_count = 0
        self.devices = []

    def set_as_subscriber(self, db_host,db_user,db_pass ):
        self.database = stor.Storage(db_host, db_user, db_pass)
        self.isSubscriber=True

    def set_msg_data(self, payload):
        self.msg_data=payload

    def set_topic(self,topic_name):
        self.topic=topic_name


#Connection Return Codes
#0: Connection successful
#1: Connection refused – incorrect protocol version
#2: Connection refused – invalid client identifier
#3: Connection refused – server unavailable
#4: Connection refused – bad username or password
#5: Connection refused – not authorised
    def on_connect(self, userdata, flags, rc):
        self.rc=rc
        if rc == 0:
            print("connected ok")
            if self.isSubscriber:
                print("Subscribing to topic", self.topic)
                t=self.topic+"/#"
                self.subscribe(t, 2)
            else:
                print("publishing mp_data")
                self.ret_pub=self.publish(topic=self.topic, payload=self.msg_data, qos=2)

            self.connected_flag = True  # set flag
        else:
            print("Bad connection Returned code=", rc)
            client.bad_connection_flag = True


    def on_message(self, userdata, message):
        content = str(message.payload.decode("utf-8"))
        print("message received " ,content)
        print("message topic=",message.topic)
        print("message qos=",message.qos)
        print("message retain flag=",message.retain)

        date = datetime.now().strftime('%Y/%m/%d %H:%M:%S')

        data = json.loads(content)

        moisture_data = data['matric_potential']

        for soil_layer_id in moisture_data.keys():
            print("md-> field_id:{}, soil_layer_id:{}, mp_id:{}, value:{}".format(data['field_id'], int(soil_layer_id),
                                                                                  data['mp_id'], moisture_data[soil_layer_id]))
            #self.database.insert_moisture_data(date, data['field_id'], int(soil_layer_id),
                   #                            data['mp_id'], moisture_data[soil_layer_id])

        #self.database.insert_monitoring_point_power_data(date, data['field_id'], data['mp_id'], data['power_level'])
        print("pd-> field_id:{}, mp_id:{}, value:{}".format(data['field_id'],data['mp_id'],data['power_level']))


    def on_publish(self, userdata, mid):
        if self.ret_pub[0]==0 and self.ret_pub[1]==mid :
            self.pub_msg_count += 1
            print("publish ok")
            self.disconnect()

        else:
            print("publishing mp_data")
            topic = "mp_data"
            self.ret_pub = self.publish(topic=topic, payload=self.msg_data, qos=2)



if __name__ == "__main__":
    field_id=1
    farm_id=1
    broker_address = "localhost"
    framework_address = "localhost"
    topic="mp_data/soil_data_for_Smart&Green_at_"+framework_address
    client_name = "Smart&GreenAt" + framework_address
    print("creating new instance")
    client = MQTTClient(client_name)  # create new instance

    #publish must set the following configuration
    client.topic=topic
    client.set_as_subscriber('localhost', 'root', '12345678')
    client.on_message = MQTTClient.on_message  # as publisher, it receive topic messages

    client.on_connect = MQTTClient.on_connect
    print("connecting to broker")
    client.connect(broker_address)  # connect to broker

    # The loop_forever call must be placed at the very end of the main script code
    # as it doesn’t progress beyond it.
    client.loop_forever()

    #Loop_start starts a loop in another thread and lets the main thread continue
    # if you need to do other things in the main thread then it is important that
    # it doesn’t end. To #accomplish this you need to use your own wait loop.
    #client.loop_start(

