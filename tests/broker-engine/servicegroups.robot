*** Settings ***
Resource	../resources/resources.robot
Suite Setup	Clean Before Suite
Suite Teardown	Clean After Suite
Test Setup	Stop Processes

Documentation	Centreon Broker and Engine add servicegroup
Library	Process
Library	OperatingSystem
Library	DateTime
Library	Collections
Library	../resources/Engine.py
Library	../resources/Broker.py
Library	../resources/Common.py

*** Test Cases ***
EBNHG1
	[Documentation]	New service group with several pollers and connections to DB
	[Tags]	Broker	Engine	New service group
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
	Add service Group	${0}	${1}	["host_1","service_1", "host_1","service_2","host_1", "service_3"]
	Config Engine Add Cfg File	${0}	servicegroups.cfg

	Reload Broker
	Reload Engine

	${result}=	Check Connections
	Should Be True	${result}	msg=Engine and Broker not connected

	${content}=	Create List	enabling membership of service (1, 3) to service group 1 on instance 1	enabling membership of service (1, 2) to service group 1 on instance 1	enabling membership of service (1, 1) to service group 1 on instance 1

	${log}=	Catenate	SEPARATOR=	${BROKER_LOG}	/central-broker-master.log
	${result}=	Find In Log With Timeout	${log}	${start}	${content}	45
	Should Be True	${result}	msg=One of the new service groups not found in logs.
	Stop Engine
	Stop Broker

EBNHGU1
	[Documentation]	New service group with several pollers and connections to DB with broker configured with unified_sql
	[Tags]	Broker	Engine	New service group	unified_sql
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
	Add service Group	${0}	${1}	["host_1","service_1", "host_1","service_2","host_1", "service_3"]
	Config Engine Add Cfg File	${0}	servicegroups.cfg

	Reload Broker
	Reload Engine

	${result}=	Check Connections
	Should Be True	${result}	msg=Engine and Broker not connected

	${content}=	Create List	enabling membership of service (1, 3) to service group 1 on instance 1	enabling membership of service (1, 2) to service group 1 on instance 1	enabling membership of service (1, 1) to service group 1 on instance 1

	${log}=	Catenate	SEPARATOR=	${BROKER_LOG}	/central-broker-master.log
	${result}=	Find In Log With Timeout	${log}	${start}	${content}	45
	Should Be True	${result}	msg=One of the new service groups not found in logs.
	Stop Engine
	Stop Broker

EBNHGU2
	[Documentation]	New service group with several pollers and connections to DB with broker configured with unified_sql
	[Tags]	Broker	Engine	New service group	unified_sql
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



	${start}=	Get Current Date
	Start Broker
	Start Engine
	${result}=	Check Connections
	Should Be True	${result}	msg=Engine and Broker not connected
	Config Engine Add Cfg File	${1}	servicegroups.cfg
	Add service Group	${0}	${1}	["host_1","service_1", "host_1","service_2","host_1", "service_3"]
	Add service Group	${1}	${1}	["host_1","service_1", "host_1","service_2","host_1", "service_3"]
	Add service Group	${2}	${1}	["host_1","service_1", "host_1","service_2","host_1", "service_3"]
	Add service Group	${3}	${1}	["host_1","service_1", "host_1","service_2","host_1", "service_3"]
	Config Engine Add Cfg File	${0}	servicegroups.cfg
	Config Engine Add Cfg File	${1}	servicegroups.cfg
	Config Engine Add Cfg File	${2}	servicegroups.cfg
	Config Engine Add Cfg File	${3}	servicegroups.cfg
	# Reload Broker
	Reload Engine

	Config Engine Remove Cfg File	${0}	servicegroups.cfg

	Reload Engine

	${result}=	Check Connections
	Should Be True	${result}	msg=Engine and Broker not connected

	${content}=	Create List	enabling membership of service (1, 3) to service group 1 on instance 1	enabling membership of service (1, 2) to service group 1 on instance 1	enabling membership of service (1, 1) to service group 1 on instance 1

	${log}=	Catenate	SEPARATOR=	${BROKER_LOG}	/central-broker-master.log
	${result}=	Find In Log With Timeout	${log}	${start}	${content}	45
	Should Be True	${result}	msg=One of the new service groups not found in logs.
	Stop Engine
	Stop Broker