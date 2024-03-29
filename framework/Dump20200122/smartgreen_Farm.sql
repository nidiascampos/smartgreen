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
-- Table structure for table `Farm`
--

DROP TABLE IF EXISTS `Farm`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Farm` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `latitude` int(11) DEFAULT NULL,
  `longitude` int(11) DEFAULT NULL,
  `altitude` int(11) DEFAULT NULL,
  `User_ID` int(11) DEFAULT NULL,
  `Meteorological_Station_ID` int(11) DEFAULT NULL,
  `rua` varchar(45) DEFAULT 'none',
  `numero` int(11) DEFAULT '0',
  `bairro` varchar(45) DEFAULT NULL,
  `cidade` varchar(45) DEFAULT 'none',
  `estado` varchar(45) DEFAULT 'none',
  `cep` varchar(45) DEFAULT 'none',
  `pais` varchar(45) DEFAULT 'none',
  `nome` varchar(45) DEFAULT 'none',
  PRIMARY KEY (`ID`),
  KEY `FK` (`User_ID`,`Meteorological_Station_ID`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Farm`
--

LOCK TABLES `Farm` WRITE;
/*!40000 ALTER TABLE `Farm` DISABLE KEYS */;
INSERT INTO `Farm` VALUES (1,4,39,20,1,1,'none',0,'none','Paraipaba','Ceará','0','Brasil','Curu');
/*!40000 ALTER TABLE `Farm` ENABLE KEYS */;
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
