def get_db():
  from pymongo import MongoClient
  client = MongoClient('localhost:27017')
  db = client.TempMonitor
  return db

def add_country(db):
  db.countries.insert({"name": "Canada"})

def get_country(db):
  return db.test_mqtt.find_one()

if __name__ == "__main__":
  db = get_db()
  #add_country(db)
  print get_country(db)