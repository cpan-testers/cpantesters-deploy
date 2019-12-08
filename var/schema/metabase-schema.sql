-- Generated with
--      mysqldump --defaults-file=~/.cpanstats.cnf --no-data --databases metabase
-- And then edited to add "IF NOT EXISTS" to the create table statements

CREATE DATABASE IF NOT EXISTS `metabase`;
USE `metabase`;

CREATE TABLE IF NOT EXISTS `metabase` (
  `guid` char(36) NOT NULL,
  `id` int(10) unsigned NOT NULL,
  `updated` varchar(32) DEFAULT NULL,
  `report` longblob NOT NULL,
  `fact` longblob,
  PRIMARY KEY (`guid`),
  KEY `id` (`id`),
  KEY `updated` (`updated`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `testers_email` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `resource` varchar(64) NOT NULL,
  `fullname` varchar(255) NOT NULL,
  `email` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `resource` (`resource`)
) ENGINE=MyISAM AUTO_INCREMENT=10311 DEFAULT CHARSET=latin1;
