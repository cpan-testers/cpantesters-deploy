-- MySQL dump 10.13  Distrib 5.5.44, for debian-linux-gnu (x86_64)
--
-- Host: 216.246.80.45    Database: cpanstats
-- ------------------------------------------------------
-- Server version	5.7.15-9-log

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
-- Table structure for table `cpanstats`
--

DROP TABLE IF EXISTS `cpanstats`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cpanstats` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `guid` char(36) NOT NULL DEFAULT '',
  `state` varchar(32) DEFAULT NULL,
  `postdate` varchar(8) DEFAULT NULL,
  `tester` varchar(255) DEFAULT NULL,
  `dist` varchar(255) DEFAULT NULL,
  `version` varchar(255) DEFAULT NULL,
  `platform` varchar(255) DEFAULT NULL,
  `perl` varchar(255) DEFAULT NULL,
  `osname` varchar(255) DEFAULT NULL,
  `osvers` varchar(255) DEFAULT NULL,
  `fulldate` varchar(32) DEFAULT NULL,
  `type` int(2) DEFAULT '0',
  `uploadid` int(10) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `guid` (`guid`),
  KEY `distvers` (`dist`,`version`),
  KEY `tester` (`tester`),
  KEY `state` (`state`),
  KEY `postdate` (`postdate`),
  KEY `IXUPID` (`uploadid`),
  KEY `cpanstats_dist_state` (`dist`,`state`),
  KEY `ix_fulldate` (`guid`,`fulldate`)
) ENGINE=InnoDB AUTO_INCREMENT=81091198 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `interesting`
--

DROP TABLE IF EXISTS `interesting`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `interesting` (
  `type` varchar(32) NOT NULL DEFAULT '',
  `count` int(10) NOT NULL DEFAULT '0',
  `id` int(10) unsigned NOT NULL,
  PRIMARY KEY (`type`,`count`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ixlatest`
--

DROP TABLE IF EXISTS `ixlatest`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ixlatest` (
  `dist` varchar(255) NOT NULL,
  `version` varchar(255) NOT NULL,
  `released` int(16) NOT NULL,
  `author` varchar(32) NOT NULL,
  `oncpan` tinyint(4) DEFAULT '0',
  `uploadid` int(10) DEFAULT '0',
  PRIMARY KEY (`dist`,`author`),
  KEY `IXDISTX` (`dist`),
  KEY `IXAUTHX` (`author`),
  KEY `IXUPID` (`uploadid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `leaderboard`
--

DROP TABLE IF EXISTS `leaderboard`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `leaderboard` (
  `postdate` varchar(8) NOT NULL,
  `osname` varchar(255) NOT NULL,
  `tester` varchar(255) NOT NULL,
  `score` int(10) DEFAULT '0',
  `testerid` int(10) unsigned NOT NULL DEFAULT '0',
  `addressid` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`postdate`,`osname`,`tester`),
  KEY `IXOS` (`osname`),
  KEY `IXTEST` (`tester`),
  KEY `IXPROFILE` (`testerid`),
  KEY `IXADDRESS` (`addressid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `monitor`
--

DROP TABLE IF EXISTS `monitor`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `monitor` (
  `now` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `day` int(2) NOT NULL DEFAULT '0',
  `month` int(2) NOT NULL DEFAULT '0',
  `year` int(4) NOT NULL DEFAULT '0',
  `name_count` int(10) NOT NULL DEFAULT '0',
  `page_count` int(10) NOT NULL DEFAULT '0',
  `page_weight` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`now`,`day`,`month`,`year`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `noreports`
--

DROP TABLE IF EXISTS `noreports`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `noreports` (
  `dist` varchar(255) DEFAULT NULL,
  `version` varchar(255) DEFAULT NULL,
  `osname` varchar(255) DEFAULT NULL,
  KEY `NRIX` (`dist`,`version`,`osname`),
  KEY `OSIX` (`osname`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `osname`
--

DROP TABLE IF EXISTS `osname`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `osname` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `osname` varchar(255) DEFAULT NULL,
  `ostitle` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `IXOS` (`osname`)
) ENGINE=InnoDB AUTO_INCREMENT=52700 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `page_requests`
--

DROP TABLE IF EXISTS `page_requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `page_requests` (
  `type` varchar(8) NOT NULL,
  `name` varchar(255) NOT NULL,
  `weight` int(2) unsigned NOT NULL,
  `created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `id` int(10) unsigned DEFAULT '0',
  KEY `IXNAME` (`name`),
  KEY `IXTYPE` (`type`),
  KEY `IXID` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `passreports`
--

DROP TABLE IF EXISTS `passreports`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `passreports` (
  `platform` varchar(255) DEFAULT NULL,
  `osname` varchar(255) DEFAULT NULL,
  `perl` varchar(255) DEFAULT NULL,
  `postdate` varchar(8) DEFAULT NULL,
  `dist` varchar(255) DEFAULT NULL,
  KEY `PLATFORMIX` (`platform`),
  KEY `OSNAMEIX` (`osname`),
  KEY `PERLIX` (`perl`),
  KEY `DATEIX` (`postdate`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `perl_version`
--

DROP TABLE IF EXISTS `perl_version`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `perl_version` (
  `version` varchar(255) NOT NULL DEFAULT '',
  `perl` varchar(32) DEFAULT NULL,
  `patch` tinyint(1) DEFAULT '0',
  `devel` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `release_data`
--

DROP TABLE IF EXISTS `release_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `release_data` (
  `dist` varchar(255) NOT NULL,
  `version` varchar(255) NOT NULL,
  `id` int(10) unsigned NOT NULL,
  `guid` char(36) NOT NULL,
  `oncpan` tinyint(4) DEFAULT '0',
  `distmat` tinyint(4) DEFAULT '0',
  `perlmat` tinyint(4) DEFAULT '0',
  `patched` tinyint(4) DEFAULT '0',
  `pass` int(10) DEFAULT '0',
  `fail` int(10) DEFAULT '0',
  `na` int(10) DEFAULT '0',
  `unknown` int(10) DEFAULT '0',
  `uploadid` int(10) DEFAULT '0',
  PRIMARY KEY (`id`,`guid`),
  KEY `dist` (`dist`,`version`),
  KEY `guid` (`guid`),
  KEY `IXUPID` (`uploadid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `release_summary`
--

DROP TABLE IF EXISTS `release_summary`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `release_summary` (
  `dist` varchar(255) NOT NULL,
  `version` varchar(255) NOT NULL,
  `id` int(10) unsigned NOT NULL,
  `guid` char(36) NOT NULL,
  `oncpan` tinyint(4) DEFAULT '0',
  `distmat` tinyint(4) DEFAULT '0',
  `perlmat` tinyint(4) DEFAULT '0',
  `patched` tinyint(4) DEFAULT '0',
  `pass` int(10) DEFAULT '0',
  `fail` int(10) DEFAULT '0',
  `na` int(10) DEFAULT '0',
  `unknown` int(10) DEFAULT '0',
  `uploadid` int(10) DEFAULT '0',
  KEY `dist` (`dist`,`version`),
  KEY `ident` (`id`,`guid`),
  KEY `summary` (`dist`,`version`,`oncpan`,`distmat`,`perlmat`,`patched`),
  KEY `maturity` (`perlmat`),
  KEY `IXUPID` (`uploadid`),
  KEY `maturity_patched` (`perlmat`,`patched`),
  KEY `ix_join_report` (`guid`,`perlmat`,`patched`),
  KEY `ix_release_guid` (`guid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `reports_history`
--

DROP TABLE IF EXISTS `reports_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `reports_history` (
  `historyid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `savedate` datetime DEFAULT NULL,
  `statsid` int(10) unsigned NOT NULL,
  `state` varchar(32) DEFAULT NULL,
  `postdate` varchar(8) DEFAULT NULL,
  `dist` varchar(255) DEFAULT NULL,
  `version` varchar(255) DEFAULT NULL,
  `oldtype` int(2) NOT NULL,
  `newtype` int(2) NOT NULL,
  PRIMARY KEY (`historyid`),
  KEY `IXSTATS` (`statsid`)
) ENGINE=InnoDB AUTO_INCREMENT=333 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `summary`
--

DROP TABLE IF EXISTS `summary`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `summary` (
  `type` varchar(8) NOT NULL,
  `name` varchar(255) NOT NULL,
  `lastid` int(10) unsigned NOT NULL,
  `dataset` blob,
  PRIMARY KEY (`type`,`name`),
  KEY `IXNAME` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `uploads`
--

DROP TABLE IF EXISTS `uploads`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `uploads` (
  `uploadid` int(10) NOT NULL AUTO_INCREMENT,
  `type` varchar(10) NOT NULL,
  `author` varchar(32) NOT NULL,
  `dist` varchar(255) NOT NULL,
  `version` varchar(255) NOT NULL,
  `filename` varchar(255) NOT NULL,
  `released` int(16) NOT NULL,
  PRIMARY KEY (`uploadid`),
  KEY `IXDIST` (`dist`),
  KEY `IXAUTH` (`author`),
  KEY `IXDATE` (`released`),
  KEY `IXVERS` (`dist`,`version`)
) ENGINE=InnoDB AUTO_INCREMENT=293414 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `uploads_failed`
--

DROP TABLE IF EXISTS `uploads_failed`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `uploads_failed` (
  `source` varchar(255) NOT NULL,
  `type` varchar(255) DEFAULT NULL,
  `dist` varchar(255) DEFAULT NULL,
  `version` varchar(255) DEFAULT NULL,
  `file` varchar(255) DEFAULT NULL,
  `pause` varchar(255) DEFAULT NULL,
  `created` int(11) unsigned DEFAULT NULL,
  PRIMARY KEY (`source`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2017-04-18 13:03:28
