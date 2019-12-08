-- Generated with
--      mysqldump --defaults-file=~/.cpanstats.cnf --no-data --databases cpanstats --tables page_requests
-- And then edited to add "IF NOT EXISTS" to the create table statements
CREATE TABLE IF NOT EXISTS `page_requests` (
      `type` varchar(8) NOT NULL,
      `name` varchar(255) NOT NULL,
      `weight` int(2) unsigned NOT NULL,
      `created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
      `id` int(10) unsigned DEFAULT '0',
      KEY `IXNAME` (`name`),
      KEY `IXTYPE` (`type`),
      KEY `IXID` (`id`)
);
