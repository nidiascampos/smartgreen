var mqtt = require('mqtt'); //includes mqtt server 
var mongodb = require('mongodb'); // includes mongoDB 
var mongodbClient = mongodb.MongoClient; //initialises the mongoDB client
var mongodbURI = 'mongodb://localhost:27017/TempMonitor'; //activating the MongoDB port 27017, here TempMontor is the name of the database
var deviceRoot = "demo/device/"; //deviceroot is topic name given in arduino code 
var collection,client; //initialise collection and client

mongodbClient.connect(mongodbURI, setupCollection); //connect the database with collecion
     
function setupCollection(err, db) {
   if(err) throw err;
   collection=db.collection("test_mqtt"); //name of the collection in the database
   client=mqtt.connect({ host: 'localhost', port: 1883 }); //connecting the mqtt server with the MongoDB database
   client.subscribe(deviceRoot+"+"); //subscribing to the topic name 
   client.on('message', insertEvent); //inserting the event
}

//function that displays the data in the MongoDataBase
function insertEvent(topic,message) {
   var key=topic.replace(deviceRoot,'');

   collection.update(
   { _id:key }, 
   { $push: { events: { event: {  value:message, when:new Date() } } } }, 
   { upsert:true },

   function(err,docs) {  
   if(err) {
      console.log("Insert fail")// Improve error handling		
	 }
 }

 );

}
