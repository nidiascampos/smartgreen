#include <cstdlib>
#include <iostream>
#include "mongo/client/dbclient.h"
#include <bsonobj.h>
#include <bsonobjbuilder.h>

void run() {
  mongo::DBClientConnection c;
  c.connect("localhost");
}

int main() {

  try {
    run();
    std::cout << "connected ok" << std::endl;

  BSONObjBuilder b;
  b.append("name", "Joe");
  b.append("age", "33");
  BSONObj p = b.obj();

  c.insert("tutorial.persons", p);

  } catch( const mongo::DBException &e ) {
    std::cout << "caught " << e.what() << std::endl;
  }
  return EXIT_SUCCESS;
}
