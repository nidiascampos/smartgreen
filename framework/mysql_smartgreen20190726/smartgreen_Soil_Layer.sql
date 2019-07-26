-- MySQL dump 10.13  Distrib 5.7.26, for Linux (x86_64)
--
-- Host: localhost    Database: smartgreen
-- ------------------------------------------------------
-- Server version	5.7.26-0ubuntu0.16.04.1

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
  `Depth` float DEFAULT NULL,
  `Field_Condition_Moisture` float DEFAULT NULL,
  `monitoring_point_id` int(11) DEFAULT NULL,
  `field_id` int(11) DEFAULT NULL,
  `residual_soil_content` float DEFAULT NULL,
  `saturation_water_content` float DEFAULT NULL,
  `alpha_air_entry_suction` float unsigned DEFAULT NULL,
  `n_pore_size_distribution` float DEFAULT NULL,
  `moisture_sensor_type_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`ID`),
  KEY `FK` (`field_id`)
) ENGINE=InnoDB AUTO_INCREMENT=28 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Soil_Layer`
--

LOCK TABLES `Soil_Layer` WRITE;
/*!40000 ALTER TABLE `Soil_Layer` DISABLE KEYS */;
INSERT INTO `Soil_Layer` VALUES (1,150,20,1,1,0.1401,0.38839,0.022504,20.524,2),(2,450,20,1,1,0.1401,0.38839,0.022504,20.524,2),(3,750,20,1,1,0.1401,0.38839,0.022504,20.524,2),(4,150,20,2,1,0.1401,0.38839,0.022504,20.524,2),(5,450,20,2,1,0.1401,0.38839,0.022504,20.524,2),(6,750,20,2,1,0.1401,0.38839,0.022504,20.524,2),(7,150,20,3,1,0.1401,0.38839,0.022504,20.524,2),(8,450,20,3,1,0.1401,0.38839,0.022504,20.524,2),(9,750,20,3,1,0.1401,0.38839,0.022504,20.524,2),(10,150,20,4,1,0.1401,0.38839,0.022504,20.524,2),(11,450,20,4,1,0.1401,0.38839,0.022504,20.524,2),(12,750,20,4,1,0.1401,0.38839,0.022504,20.524,2),(13,150,20,5,1,0.1401,0.38839,0.022504,20.524,2),(14,450,20,5,1,0.1401,0.38839,0.022504,20.524,2),(15,750,20,5,1,0.1401,0.38839,0.022504,20.524,2),(16,150,20,6,1,0.1401,0.38839,0.022504,20.524,2),(17,450,20,6,1,0.1401,0.38839,0.022504,20.524,2),(18,750,20,6,1,0.1401,0.38839,0.022504,20.524,2),(19,150,20,7,1,0.1401,0.38839,0.022504,20.524,2),(20,450,20,7,1,0.1401,0.38839,0.022504,20.524,2),(21,750,20,7,1,0.1401,0.38839,0.022504,20.524,2),(22,150,20,8,1,0.1401,0.38839,0.022504,20.524,2),(23,450,20,8,1,0.1401,0.38839,0.022504,20.524,2),(24,750,20,8,1,0.1401,0.38839,0.022504,20.524,2),(25,150,20,9,1,0.1401,0.38839,0.022504,20.524,2),(26,450,20,9,1,0.1401,0.38839,0.022504,20.524,2),(27,750,20,9,1,0.1401,0.38839,0.022504,20.524,2);
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

-- Dump completed on 2019-07-26 10:57:35