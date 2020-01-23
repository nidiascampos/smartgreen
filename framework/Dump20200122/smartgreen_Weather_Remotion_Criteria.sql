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
-- Table structure for table `Weather_Remotion_Criteria`
--

DROP TABLE IF EXISTS `Weather_Remotion_Criteria`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Weather_Remotion_Criteria` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `station_id` int(11) DEFAULT NULL,
  `Tmax_less` float DEFAULT NULL,
  `Tmin_less` float DEFAULT NULL,
  `RHmax_less` float DEFAULT NULL,
  `RHmin_less` float DEFAULT NULL,
  `Rn_less` float DEFAULT NULL,
  `U_less` float DEFAULT NULL,
  `P_less` float DEFAULT NULL,
  `Ri_less` float DEFAULT NULL,
  `Tmax_greater` float DEFAULT NULL,
  `Tmin_greater` float DEFAULT NULL,
  `RHmax_greater` float DEFAULT NULL,
  `RHmin_greater` float DEFAULT NULL,
  `Rn_greater` float DEFAULT NULL,
  `U_greater` float DEFAULT NULL,
  `P_greater` float DEFAULT NULL,
  `Ri_greater` float DEFAULT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Weather_Remotion_Criteria`
--

LOCK TABLES `Weather_Remotion_Criteria` WRITE;
/*!40000 ALTER TABLE `Weather_Remotion_Criteria` DISABLE KEYS */;
INSERT INTO `Weather_Remotion_Criteria` VALUES (1,1,20,20,20,20,NULL,NULL,NULL,NULL,39,39,NULL,NULL,NULL,NULL,NULL,250);
/*!40000 ALTER TABLE `Weather_Remotion_Criteria` ENABLE KEYS */;
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
