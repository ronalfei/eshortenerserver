DROP TABLE IF EXISTS `ld_ess`.`url_map`;
CREATE TABLE  `ld_ess`.`url_map` (
  `hash_id` char(32) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
  `url` varchar(255) DEFAULT NULL,
  `host` varchar(255) DEFAULT NULL,
  `expire` datetime DEFAULT NULL,
  `memo` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`hash_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
