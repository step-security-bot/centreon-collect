--
-- Centreon Engine logs.
--
CREATE TABLE log_logs (
  log_id int NOT NULL auto_increment,

  ctime int default NULL,
  host_id int default NULL,
  host_name varchar(255) default NULL,
  instance_name varchar(255) NOT NULL,
  issue_id int default NULL,
  msg_type tinyint default NULL,
  notification_cmd varchar(255) default NULL,
  notification_contact varchar(255) default NULL,
  output text default NULL,
  retry int default NULL,
  service_description varchar(255) default NULL,
  service_id int default NULL,
  status tinyint default NULL,
  type smallint default NULL,

  PRIMARY KEY (log_id),
  FOREIGN KEY (host_id) REFERENCES rt_hosts (host_id)
    ON DELETE SET NULL
) ENGINE=InnoDB;
