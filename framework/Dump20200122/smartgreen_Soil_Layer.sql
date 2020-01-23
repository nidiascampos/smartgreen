-- MySQL dump 10.13  Distrib 5.7.28, for Linux (x86_64)
--
-- Host: localhost    Database: smartgreen
-- ------------------------------------------------------
-- Server version	5.7.28-0ubuntu0.16.04.2

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `Soil_Layer`
--

DROP TABLE IF EXISTS `Soil_Layer`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Soil_Layer` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `depth_type` int(11) NOT NULL DEFAULT '1',
  `monitoring_point_id` int(11) NOT NULL,
  `field_id` int(11) NOT NULL,
  `moisture_sensor_type_id` int(11) NOT NULL,
  PRIMARY KEY (`ID`),
  KEY `FK` (`field_id`)
) ENGINE=InnoDB AUTO_INCREMENT=28 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Soil_Layer`
--

LOCK TABLES `Soil_Layer` WRITE;
/*!40000 ALTER TABLE `Soil_Layer` DISABLE KEYS */;
INSERT INTO `Soil_Layer` VALUES (1,1,1,1,2),(2,2,1,1,2),(3,3,1,1,2),(4,1,2,1,2),(5,2,2,1,2),(6,3,2,1,2),(7,1,3,1,2),(8,2,3,1,2),(9,3,3,1,2),(10,1,4,1,2),(11,2,4,1,2),(12,3,4,1,2),(13,1,5,1,2),(14,2,5,1,2),(15,3,5,1,2),(16,1,6,1,2),(17,2,6,1,2),(18,3,6,1,2),(19,1,7,1,2),(20,2,7,1,2),(21,3,7,1,2),(22,1,8,1,2),(23,2,8,1,2),(24,3,8,1,2),(25,1,9,1,2),(26,2,9,1,2),(27,3,9,1,2);
/*!40000 ALTER TABLE `Soil_Layer` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2020-01-22 21:56:17
