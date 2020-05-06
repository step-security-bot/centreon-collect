--
-- Historization of flapping statuses.
--
CREATE TABLE rt_flappingstatuses (
  flappingstatus_id int NOT NULL,
  host_id int default NULL,
  service_id int default NULL,
  event_time int default NULL,

  comment_time int default NULL,
  event_type smallint default NULL,
  high_threshold double precision default NULL,
  instance_id int default NULL,
  internal_comment_id int default NULL,
  low_threshold double precision default NULL,
  percent_state_change double precision default NULL,
  reason_type smallint default NULL,
  type smallint default NULL,

  PRIMARY KEY (flappingstatus_id),
  UNIQUE (host_id, service_id, event_time),
  FOREIGN KEY (host_id) REFERENCES rt_hosts (host_id)
    ON DELETE CASCADE
);
CREATE SEQUENCE flappingstatuses_seq
START WITH 1
INCREMENT BY 1;
CREATE TRIGGER flappingstatuses_trigger
BEFORE INSERT ON flappingstatuses
FOR EACH ROW
BEGIN
  SELECT flappingstatuses_seq.nextval INTO :NEW.flappingstatus_id FROM dual;
END;
/
