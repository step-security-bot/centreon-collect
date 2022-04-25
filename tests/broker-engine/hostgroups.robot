*** Settings ***
Resource	../resources/resources.robot
Suite Setup	Clean Before Suite
Suite Teardown	Clean After Suite
Test Setup	Stop Processes

Documentation	Centreon Broker and Engine add Hostgroup
Library	Process
Library	OperatingSystem
Library	DateTime
Library	Collections
Library	../resources/Engine.py
Library	../resources/Broker.py
Library	../resources/Common.py

*** Test Cases ***
EBNHG1
	[Documentation]	New host group with several pollers and connections to DB
	[Tags]	Broker	Engine	New host group
	Config Engine	${3}
	Config Broker	rrd
	Config Broker	central
	Config Broker	module

	Broker Config Log	central	sql	info
	Broker Config Output Set	central	central-broker-master-sql	connections_count	5
	Broker Config Output Set	central	central-broker-master-perfdata	connections_count	5
	${start}=	Get Current Date
	Start Broker
	Start Engine
	${result}=	Check Connections
	Should Be True	${result}	msg=Engine and Broker not connected
	Add Host Group	${0}	${1}	["host_1", "host_2", "host_3"]

	Reload Broker
	Reload Engine

	${result}=	Check Connections
	Should Be True	${result}	msg=Engine and Broker not connected

	${content}=	Create List	enabling membership of host 3 to host group 1 on instance 1	enabling membership of host 2 to host group 1 on instance 1	enabling membership of host 1 to host group 1 on instance 1

	${log}=	Catenate	SEPARATOR=	${BROKER_LOG}	/central-broker-master.log
	${result}=	Find In Log With Timeout	${log}	${start}	${content}	45
	Should Be True	${result}	msg=One of the new host groups not found in logs.
	Stop Engine
	Stop Broker

EBNHGU1
	[Documentation]	New host group with several pollers and connections to DB with broker configured with unified_sql
	[Tags]	Broker	Engine	New host group	unified_sql
	Config Engine	${3}
	Config Broker	rrd
	Config Broker	central
	Config Broker	module

	Broker Config Log	central	sql	info
	Config Broker Sql Output	central	unified_sql
	Broker Config Output Set	central	central-broker-unified-sql	connections_count	5
	${start}=	Get Current Date
	Start Broker
	Start Engine
	${result}=	Check Connections
	Should Be True	${result}	msg=Engine and Broker not connected
	Add Host Group	${0}	${1}	["host_1", "host_2", "host_3"]

	Reload Broker
	Reload Engine

	${result}=	Check Connections
	Should Be True	${result}	msg=Engine and Broker not connected

	${content}=	Create List	enabling membership of host 3 to host group 1 on instance 1	enabling membership of host 2 to host group 1 on instance 1	enabling membership of host 1 to host group 1 on instance 1

	${log}=	Catenate	SEPARATOR=	${BROKER_LOG}	/central-broker-master.log
	${result}=	Find In Log With Timeout	${log}	${start}	${content}	45
	Should Be True	${result}	msg=One of the new host groups not found in logs.
	Stop Engine
	Stop Broker

EBNHGU2
	[Documentation]	New host group with several pollers and connections to DB with broker configured with unified_sql
	[Tags]	Broker	Engine	New host group	unified_sql
	Config Engine	${3}
	Config Broker	rrd
	Config Broker	central
	Config Broker	module

	Broker Config Log	central	sql	info
	Config Broker Sql Output	central	unified_sql
	Broker Config Output Set	central	central-broker-unified-sql	connections_count	5
	Broker Config Add Item	module	bbdo_version	3.0.0
	Broker Config Add Item	central	bbdo_version	3.0.0
	Broker Config Add Item	rrd	bbdo_version	3.0.0
	${start}=	Get Current Date
	Start Broker
	Start Engine
	${result}=	Check Connections
	Should Be True	${result}	msg=Engine and Broker not connected
	Add Host Group	${0}	${1}	["host_1", "host_2", "host_3"]

	Reload Broker
	Reload Engine

	${result}=	Check Connections
	Should Be True	${result}	msg=Engine and Broker not connected

	${content}=	Create List	enabling membership of host 3 to host group 1 on instance 1	enabling membership of host 2 to host group 1 on instance 1	enabling membership of host 1 to host group 1 on instance 1

	${log}=	Catenate	SEPARATOR=	${BROKER_LOG}	/central-broker-master.log
	${result}=	Find In Log With Timeout	${log}	${start}	${content}	45
	Should Be True	${result}	msg=One of the new host groups not found in logs.
	Stop Engine
	Stop Broker

EBNHGU3
	[Documentation]	New host group with several pollers and connections to DB with broker configured with unified_sql
	[Tags]	Broker	Engine	New host group	unified_sql
	Config Engine	${4}
	Config Broker	rrd
	Config Broker	central
	Config Broker	module

	Broker Config Log	central	sql	info
	Config Broker Sql Output	central	unified_sql
	Broker Config Output Set	central	central-broker-unified-sql	connections_count	5
	Broker Config Add Item	module	bbdo_version	3.0.0
	Broker Config Add Item	central	bbdo_version	3.0.0
	Broker Config Add Item	rrd	bbdo_version	3.0.0
	Broker Config Log	central	sql	debug


	Log To Console	avant start
	${start}=	Get Current Date
	Start Broker
	Start Engine
	${result}=	Check Connections
	Should Be True	${result}	msg=Engine and Broker not connected
	Add Host Group	${0}	${1}	["host_1", "host_2", "host_3"]
	Add Host Group	${1}	${1}	["host_21", "host_22", "host_23"]
	Add Host Group	${2}	${1}	["host_31", "host_32", "host_33"]
	Add Host Group	${3}	${1}	["host_41", "host_42", "host_43"]
	Log To Console	avant premier reload
	Sleep	10s
	Reload Broker
	Reload Engine
	Log To Console	after premier reload

	

	${result}=	Check Connections
	Should Be True	${result}	msg=Engine and Broker not connected

	${content}=	Create List	enabling membership of host 3 to host group 1 on instance 1	enabling membership of host 2 to host group 1 on instance 1	enabling membership of host 1 to host group 1 on instance 1

	${log}=	Catenate	SEPARATOR=	${BROKER_LOG}	/central-broker-master.log
	${result}=	Find In Log With Timeout	${log}	${start}	${content}	50
	Should Be True	${result}	msg=One of the new host groups not found in logs.

	Config Engine Remove Cfg File	${0}	hostgroups.cfg

	Log To Console	avant deuxieme reload
	Sleep	10s
	Reload Broker
	Reload Engine
	Log To Console	after deuxieme reload
	${start}=	Get Current Date
	${result}=	Check Connections
	Should Be True	${result}	msg=Engine and Broker not connected

	${content}=	Create List	enabling membership of host 32 to host group 1 on instance 1	enabling membership of host 31 to host group 1 on instance 1	enabling membership of host 30 to host group 1 on instance 1

	${log}=	Catenate	SEPARATOR=	${BROKER_LOG}	/central-broker-master.log
	${result}=	Find In Log With Timeout	${log}	${start}	${content}	60
	Should Be True	${result}	msg=One of the new host groups not found in logs.

	Stop Engine
	Stop Broker
