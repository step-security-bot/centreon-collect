*** Settings ***
Resource	../resources/resources.robot
Suite Setup	Clean Before Suite
Suite Teardown	Clean After Suite
Test Setup	Stop Processes
Test Teardown	Save logs If Failed

Documentation	Centreon Broker and Engine progressively add services
Library	DatabaseLibrary
Library	Process
Library	OperatingSystem
Library	DateTime
Library	Collections
Library	../resources/Engine.py
Library	../resources/Broker.py
Library	../resources/Common.py

*** Test Cases ***
BEEXTCMD30
	[Documentation]	external command DISABLE_HOST_NOTIFICATIONS and ENABLE_HOST_NOTIFICATIONS on bbdo2.0
	[Tags]	Broker	Engine	host	extcmd
	Config Engine	${1}	${50}	${20}
	Config Broker	rrd
	Config Broker	central
	Config Broker	module	${1}
	Broker Config Log	central	core	error
	Broker Config Log	central	sql	debug
	FOR	${use_grpc}	IN RANGE	0  2
		Log To Console	external command DISABLE_HOST_NOTIFICATIONS and ENABLE_HOST_NOTIFICATIONS on bbdo2.0 use_grpc=${use_grpc}
		Clear Retention
		${start}=	Get Current Date
		Start Broker
		Start Engine
		${content}=	Create List	INITIAL SERVICE STATE: host_50;service_1000;	check_for_external_commands()
		${result}=	Find In Log with Timeout	${engineLog0}	${start}	${content}	60
		Should Be True	${result}	msg=An Initial host state on host_1 should be raised before we can start our external commands.
		Disable Host Notifications	${use_grpc}	host_1

		Connect To Database	pymysql	${DBName}	${DBUser}	${DBPass}	${DBHost}	${DBPort}

		FOR	${index}	IN RANGE	30
			Log To Console	SELECT notify FROM hosts WHERE name='host_1'
			${output}=	Query	SELECT notify FROM hosts WHERE name='host_1'
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((0,),)"
		END
		Should Be Equal As Strings	${output}	((0,),)

		Enable Host Notifications	${use_grpc}	host_1

		FOR	${index}	IN RANGE	30
			Log To Console	SELECT notify FROM hosts WHERE name='host_1'
			${output}=	Query	SELECT notify FROM hosts WHERE name='host_1'
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((1,),)"
		END
		Should Be Equal As Strings	${output}	((1,),)

		Stop Engine
		Kindly Stop Broker
	END

BEEXTCMD31
	[Documentation]	external command DISABLE_HOST_SVC_CHECKS and ENABLE_HOST_SVC_CHECKS on bbdo3.0
	[Tags]	Broker	Engine	host	extcmd
	Config Engine	${1}	${50}	${20}
	Config Broker	rrd
	Config Broker	central
	Config Broker	module	${1}
	Broker Config Add Item	module0	bbdo_version	3.0.0
	Broker Config Add Item	central	bbdo_version	3.0.0
	Broker Config Add Item	rrd	bbdo_version	3.0.0
	Broker Config Log	central	core	error
	Broker Config Log	central	sql	debug
	Broker Config Log	module0	neb	trace
	Config Broker Sql Output	central	unified_sql
	Clear Retention
	FOR	${use_grpc}	IN RANGE	0  1
		${start}=	Get Current Date
		Start Broker
		Start Engine
		${content}=	Create List	INITIAL SERVICE STATE: host_50;service_1000;	check_for_external_commands()
		${result}=	Find In Log with Timeout	${engineLog0}	${start}	${content}	60
		Should Be True	${result}	msg=An Initial host state on host_1 should be raised before we can start our external commands.
		Disable Host Svc Checks	${use_grpc}	host_1

		Connect To Database	pymysql	${DBName}	${DBUser}	${DBPass}	${DBHost}	${DBPort}

		FOR	${index}	IN RANGE	30
			Log To Console	SELECT s.active_checks FROM services s LEFT JOIN hosts h ON s.host_id=h.host_id WHERE s.description='service_1' AND h.name='host_1'
			${output}=	Query	SELECT s.active_checks FROM services s LEFT JOIN hosts h ON s.host_id=h.host_id WHERE s.description='service_1' AND h.name='host_1'
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((0,),)"
		END
		Should Be Equal As Strings	${output}	((0,),)

		FOR	${index}	IN RANGE	30
			Log To Console	SELECT active_checks_enabled FROM resources WHERE name='service_1'
			${output}=	Query	SELECT active_checks_enabled FROM resources WHERE name='service_1'
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((0,),)"
		END
		Should Be Equal As Strings	${output}	((0,),)

		FOR	${index}	IN RANGE	30
			Log To Console	SELECT s.should_be_scheduled FROM services s LEFT JOIN hosts h ON s.host_id=h.host_id WHERE s.description='service_1' AND h.name='host_1'
			${output}=	Query	SELECT s.should_be_scheduled FROM services s LEFT JOIN hosts h ON s.host_id=h.host_id WHERE s.description='service_1' AND h.name='host_1'
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((0,),)"
		END
		Should Be Equal As Strings	${output}	((0,),)

		Enable Host Svc Checks	${use_grpc}	host_1

		FOR	${index}	IN RANGE	30
			Log To Console	SELECT s.active_checks FROM services s LEFT JOIN hosts h ON s.host_id=h.host_id WHERE s.description='service_1' AND h.name='host_1'
			${output}=	Query	SELECT s.active_checks FROM services s LEFT JOIN hosts h ON s.host_id=h.host_id WHERE s.description='service_1' AND h.name='host_1'
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((1,),)"
		END
		Should Be Equal As Strings	${output}	((1,),)

		FOR	${index}	IN RANGE	30
			Log To Console	SELECT active_checks_enabled FROM resources WHERE name='service_1'
			${output}=	Query	SELECT active_checks_enabled FROM resources WHERE name='service_1'
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((1,),)"
		END
		Should Be Equal As Strings	${output}	((1,),)

		FOR	${index}	IN RANGE	30
			Log To Console	SELECT s.should_be_scheduled FROM services s LEFT JOIN hosts h ON s.host_id=h.host_id WHERE s.description='service_1' AND h.name='host_1'
			${output}=	Query	SELECT s.should_be_scheduled FROM services s LEFT JOIN hosts h ON s.host_id=h.host_id WHERE s.description='service_1' AND h.name='host_1'
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((1,),)"
		END
		Should Be Equal As Strings	${output}	((1,),)
		Stop Engine
		Kindly Stop Broker
	END

BEEXTCMD32
	[Documentation]	external command DISABLE_HOST_SVC_CHECKS and ENABLE_HOST_SVC_CHECKS on bbdo2.0
	[Tags]	Broker	Engine	host	extcmd
	Config Engine	${1}	${50}	${20}
	Config Broker	rrd
	Config Broker	central
	Config Broker	module	${1}
	Broker Config Log	central	core	error
	Broker Config Log	central	sql	debug
	Clear Retention
	FOR	${use_grpc}	IN RANGE	0  1
		${start}=	Get Current Date
		Start Broker
		Start Engine
		${content}=	Create List	INITIAL SERVICE STATE: host_50;service_1000;	check_for_external_commands()
		${result}=	Find In Log with Timeout	${engineLog0}	${start}	${content}	60
		Should Be True	${result}	msg=An Initial host state on host_1 should be raised before we can start our external commands.
		Disable Host Svc Checks	${use_grpc}	host_1

		Connect To Database	pymysql	${DBName}	${DBUser}	${DBPass}	${DBHost}	${DBPort}

		FOR	${index}	IN RANGE	30
			Log To Console	SELECT s.s.active_checks FROM services s LEFT JOIN hosts h ON s.host_id=h.host_id WHERE s.description='service_1' AND h.name='host_1'
			${output}=	Query	SELECT s.active_checks FROM services s LEFT JOIN hosts h ON s.host_id=h.host_id WHERE s.description='service_1' AND h.name='host_1'
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((0,),)"
		END
		Should Be Equal As Strings	${output}	((0,),)

		FOR	${index}	IN RANGE	30
			Log To Console	SELECT s.should_be_scheduled FROM services s LEFT JOIN hosts h ON s.host_id=h.host_id WHERE s.description='service_1' AND h.name='host_1'
			${output}=	Query	SELECT s.should_be_scheduled FROM services s LEFT JOIN hosts h ON s.host_id=h.host_id WHERE s.description='service_1' AND h.name='host_1'
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((0,),)"
		END
		Should Be Equal As Strings	${output}	((0,),)

		Enable Host Svc Checks	${use_grpc}	host_1

		FOR	${index}	IN RANGE	30
			Log To Console	SELECT s.active_checks FROM services s LEFT JOIN hosts h ON s.host_id=h.host_id WHERE s.description='service_1' AND h.name='host_1'
			${output}=	Query	SELECT s.active_checks FROM services s LEFT JOIN hosts h ON s.host_id=h.host_id WHERE s.description='service_1' AND h.name='host_1'
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((1,),)"
		END
		Should Be Equal As Strings	${output}	((1,),)

		FOR	${index}	IN RANGE	30
			Log To Console	SELECT s.should_be_scheduled FROM services s LEFT JOIN hosts h ON s.host_id=h.host_id WHERE s.description='service_1' AND h.name='host_1'
			${output}=	Query	SELECT s.should_be_scheduled FROM services s LEFT JOIN hosts h ON s.host_id=h.host_id WHERE s.description='service_1' AND h.name='host_1'
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((1,),)"
		END
		Should Be Equal As Strings	${output}	((1,),)

		Stop Engine
		Kindly Stop Broker
	END

BEEXTCMD33
	[Documentation]	external command DISABLE_HOST_SVC_NOTIFICATIONS and ENABLE_HOST_SVC_NOTIFICATIONS on bbdo3.0
	[Tags]	Broker	Engine	host	extcmd
	Config Engine	${1}	${50}	${20}
	Config Broker	rrd
	Config Broker	central
	Config Broker	module	${1}
	Broker Config Add Item	module0	bbdo_version	3.0.0
	Broker Config Add Item	central	bbdo_version	3.0.0
	Broker Config Add Item	rrd	bbdo_version	3.0.0
	Broker Config Log	central	core	error
	Broker Config Log	central	sql	debug
	Broker Config Log	module0	neb	trace
	Config Broker Sql Output	central	unified_sql
	Clear Retention
	FOR	${use_grpc}	IN RANGE	0  1
		${start}=	Get Current Date
		Start Broker
		Start Engine
		${content}=	Create List	INITIAL SERVICE STATE: host_50;service_1000;	check_for_external_commands()
		${result}=	Find In Log with Timeout	${engineLog0}	${start}	${content}	60
		Should Be True	${result}	msg=An Initial host state on host_1 should be raised before we can start our external commands.
		Disable Host Svc Notifications	${use_grpc}	host_1

		Connect To Database	pymysql	${DBName}	${DBUser}	${DBPass}	${DBHost}	${DBPort}

		FOR	${index}	IN RANGE	30
			Log To Console	SELECT s.notify FROM services s LEFT JOIN hosts h ON s.host_id=h.host_id WHERE s.description='service_1' AND h.name='host_1'
			${output}=	Query	SELECT s.notify FROM services s LEFT JOIN hosts h ON s.host_id=h.host_id WHERE s.description='service_1' AND h.name='host_1'
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((0,),)"
		END
		Should Be Equal As Strings	${output}	((0,),)

		Enable Host Svc Notifications	${use_grpc}	host_1

		FOR	${index}	IN RANGE	30
			Log To Console	SELECT s.notify FROM services s LEFT JOIN hosts h ON s.host_id=h.host_id WHERE s.description='service_1' AND h.name='host_1'
			${output}=	Query	SELECT s.notify FROM services s LEFT JOIN hosts h ON s.host_id=h.host_id WHERE s.description='service_1' AND h.name='host_1'
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((1,),)"
		END
		Should Be Equal As Strings	${output}	((1,),)

		Stop Engine
		Kindly Stop Broker
	END

BEEXTCMD34
	[Documentation]	external command DISABLE_HOST_SVC_NOTIFICATIONS and ENABLE_HOST_SVC_NOTIFICATIONS on bbdo2.0
	[Tags]	Broker	Engine	host	extcmd
	Config Engine	${1}	${50}	${20}
	Config Broker	rrd
	Config Broker	central
	Config Broker	module	${1}
	Broker Config Log	central	core	error
	Broker Config Log	central	sql	debug
	Clear Retention
	FOR	${use_grpc}	IN RANGE	0  1
		${start}=	Get Current Date
		Start Broker
		Start Engine
		${content}=	Create List	INITIAL SERVICE STATE: host_50;service_1000;	check_for_external_commands()
		${result}=	Find In Log with Timeout	${engineLog0}	${start}	${content}	60
		Should Be True	${result}	msg=An Initial host state on host_1 should be raised before we can start our external commands.
		Disable Host Svc Notifications	${use_grpc}	host_1

		Connect To Database	pymysql	${DBName}	${DBUser}	${DBPass}	${DBHost}	${DBPort}

		FOR	${index}	IN RANGE	30
			Log To Console	SELECT s.notify FROM services s LEFT JOIN hosts h ON s.host_id=h.host_id WHERE s.description='service_1' AND h.name='host_1'
			${output}=	Query	SELECT s.notify FROM services s LEFT JOIN hosts h ON s.host_id=h.host_id WHERE s.description='service_1' AND h.name='host_1'
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((0,),)"
		END
		Should Be Equal As Strings	${output}	((0,),)

		Enable Host Svc Notifications	${use_grpc}	host_1

		FOR	${index}	IN RANGE	30
			Log To Console	SELECT s.notify FROM services s LEFT JOIN hosts h ON s.host_id=h.host_id WHERE s.description='service_1' AND h.name='host_1'
			${output}=	Query	SELECT s.notify FROM services s LEFT JOIN hosts h ON s.host_id=h.host_id WHERE s.description='service_1' AND h.name='host_1'
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((1,),)"
		END
		Should Be Equal As Strings	${output}	((1,),)

		Stop Engine
		Kindly Stop Broker
	END

BEEXTCMD35
	[Documentation]	external command DISABLE_PASSIVE_HOST_CHECKS and ENABLE_PASSIVE_HOST_CHECKS on bbdo3.0
	[Tags]	Broker	Engine	host	extcmd
	Config Engine	${1}	${50}	${20}
	Config Broker	rrd
	Config Broker	central
	Config Broker	module	${1}
	Broker Config Add Item	module0	bbdo_version	3.0.0
	Broker Config Add Item	central	bbdo_version	3.0.0
	Broker Config Add Item	rrd	bbdo_version	3.0.0
	Broker Config Log	central	core	error
	Broker Config Log	central	sql	debug
	Broker Config Log	module0	neb	trace
	Config Broker Sql Output	central	unified_sql
	Clear Retention
	FOR	${use_grpc}	IN RANGE	0  1
		${start}=	Get Current Date
		Start Broker
		Start Engine
		${content}=	Create List	INITIAL SERVICE STATE: host_50;service_1000;	check_for_external_commands()
		${result}=	Find In Log with Timeout	${engineLog0}	${start}	${content}	60
		Should Be True	${result}	msg=An Initial host state on host_1 should be raised before we can start our external commands.
		Disable Passive Host Checks	${use_grpc}	host_1

		Connect To Database	pymysql	${DBName}	${DBUser}	${DBPass}	${DBHost}	${DBPort}

		FOR	${index}	IN RANGE	30
			Log To Console	SELECT passive_checks FROM hosts WHERE name='host_1'
			${output}=	Query	SELECT passive_checks FROM hosts WHERE name='host_1'
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((0,),)"
		END
		Should Be Equal As Strings	${output}	((0,),)

		FOR	${index}	IN RANGE	30
			Log To Console	SELECT passive_checks_enabled FROM resources WHERE name='host_1'
			${output}=	Query	SELECT passive_checks_enabled FROM resources WHERE name='host_1'
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((0,),)"
		END
		Should Be Equal As Strings	${output}	((0,),)

		Enable Passive Host Checks	${use_grpc}	host_1

		FOR	${index}	IN RANGE	30
			Log To Console	SELECT passive_checks FROM hosts WHERE name='host_1'
			${output}=	Query	SELECT passive_checks FROM hosts WHERE name='host_1'
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((1,),)"
		END
		Should Be Equal As Strings	${output}	((1,),)

		FOR	${index}	IN RANGE	30
			Log To Console	SELECT passive_checks_enabled FROM resources WHERE name='host_1'
			${output}=	Query	SELECT passive_checks_enabled FROM resources WHERE name='host_1'
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((1,),)"
		END
		Should Be Equal As Strings	${output}	((1,),)

		Stop Engine
		Kindly Stop Broker
	END

BEEXTCMD36
	[Documentation]	external command DISABLE_PASSIVE_HOST_CHECKS and ENABLE_PASSIVE_HOST_CHECKS on bbdo2.0
	[Tags]	Broker	Engine	host	extcmd
	Config Engine	${1}	${50}	${20}
	Config Broker	rrd
	Config Broker	central
	Config Broker	module	${1}
	Broker Config Log	central	core	error
	Broker Config Log	central	sql	debug
	Clear Retention
	FOR	${use_grpc}	IN RANGE	0  1
		${start}=	Get Current Date
		Start Broker
		Start Engine
		${content}=	Create List	INITIAL SERVICE STATE: host_50;service_1000;	check_for_external_commands()
		${result}=	Find In Log with Timeout	${engineLog0}	${start}	${content}	60
		Should Be True	${result}	msg=An Initial host state on host_1 should be raised before we can start our external commands.
		Disable Passive Host Checks	${use_grpc}	host_1

		Connect To Database	pymysql	${DBName}	${DBUser}	${DBPass}	${DBHost}	${DBPort}

		FOR	${index}	IN RANGE	30
			Log To Console	SELECT passive_checks FROM hosts WHERE name='host_1'
			${output}=	Query	SELECT passive_checks FROM hosts WHERE name='host_1'
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((0,),)"
		END
		Should Be Equal As Strings	${output}	((0,),)

		Enable Passive Host Checks	${use_grpc}	host_1

		FOR	${index}	IN RANGE	30
			Log To Console	SELECT passive_checks FROM hosts WHERE name='host_1'
			${output}=	Query	SELECT passive_checks FROM hosts WHERE name='host_1'
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((1,),)"
		END
		Should Be Equal As Strings	${output}	((1,),)

		Stop Engine
		Kindly Stop Broker
	END

BEEXTCMD37
	[Documentation]	external command DISABLE_PASSIVE_SVC_CHECKS and ENABLE_PASSIVE_SVC_CHECKS on bbdo3.0
	[Tags]	Broker	Engine	host	extcmd
	Config Engine	${1}	${50}	${20}
	Config Broker	rrd
	Config Broker	central
	Config Broker	module	${1}
	Broker Config Add Item	module0	bbdo_version	3.0.0
	Broker Config Add Item	central	bbdo_version	3.0.0
	Broker Config Add Item	rrd	bbdo_version	3.0.0
	Broker Config Log	central	core	error
	Broker Config Log	central	sql	debug
	Broker Config Log	module0	neb	trace
	Config Broker Sql Output	central	unified_sql
	Clear Retention
	FOR	${use_grpc}	IN RANGE	0  1
		${start}=	Get Current Date
		Start Broker
		Start Engine
		${content}=	Create List	INITIAL SERVICE STATE: host_50;service_1000;	check_for_external_commands()
		${result}=	Find In Log with Timeout	${engineLog0}	${start}	${content}	60
		Should Be True	${result}	msg=An Initial host state on host_1 should be raised before we can start our external commands.
		Disable Passive Svc Checks	${use_grpc}	host_1	service_1

		Connect To Database	pymysql	${DBName}	${DBUser}	${DBPass}	${DBHost}	${DBPort}

		FOR	${index}	IN RANGE	30
			Log To Console	SELECT s.passive_checks FROM services s LEFT JOIN hosts h ON s.host_id=h.host_id WHERE s.description='service_1' AND h.name='host_1'
			${output}=	Query	SELECT s.passive_checks FROM services s LEFT JOIN hosts h ON s.host_id=h.host_id WHERE s.description='service_1' AND h.name='host_1'
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((0,),)"
		END
		Should Be Equal As Strings	${output}	((0,),)

		FOR	${index}	IN RANGE	30
			Log To Console	SELECT passive_checks_enabled FROM resources WHERE name='service_1'
			${output}=	Query	SELECT passive_checks_enabled FROM resources WHERE name='service_1'
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((0,),)"
		END
		Should Be Equal As Strings	${output}	((0,),)

		Enable Passive Svc Checks	${use_grpc}	host_1	service_1

		FOR	${index}	IN RANGE	30
			Log To Console	SELECT s.passive_checks FROM services s LEFT JOIN hosts h ON s.host_id=h.host_id WHERE s.description='service_1' AND h.name='host_1'
			${output}=	Query	SELECT s.passive_checks FROM services s LEFT JOIN hosts h ON s.host_id=h.host_id WHERE s.description='service_1' AND h.name='host_1'
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((1,),)"
		END
		Should Be Equal As Strings	${output}	((1,),)

		FOR	${index}	IN RANGE	30
			Log To Console	SELECT passive_checks_enabled FROM resources WHERE name='service_1'
			${output}=	Query	SELECT passive_checks_enabled FROM resources WHERE name='service_1'
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((1,),)"
		END
		Should Be Equal As Strings	${output}	((1,),)

		Stop Engine
		Kindly Stop Broker
	END

BEEXTCMD38
	[Documentation]	external command DISABLE_PASSIVE_SVC_CHECKS and ENABLE_PASSIVE_SVC_CHECKS on bbdo2.0
	[Tags]	Broker	Engine	host	extcmd
	Config Engine	${1}	${50}	${20}
	Config Broker	rrd
	Config Broker	central
	Config Broker	module	${1}
	Broker Config Log	central	core	error
	Broker Config Log	central	sql	debug
	Clear Retention
	FOR	${use_grpc}	IN RANGE	0  1
		${start}=	Get Current Date
		Start Broker
		Start Engine
		${content}=	Create List	INITIAL SERVICE STATE: host_50;service_1000;	check_for_external_commands()
		${result}=	Find In Log with Timeout	${engineLog0}	${start}	${content}	60
		Should Be True	${result}	msg=An Initial host state on host_1 should be raised before we can start our external commands.
		Disable Passive Svc Checks	${use_grpc}	host_1	service_1

		Connect To Database	pymysql	${DBName}	${DBUser}	${DBPass}	${DBHost}	${DBPort}

		FOR	${index}	IN RANGE	30
			Log To Console	SELECT s.passive_checks FROM services s LEFT JOIN hosts h ON s.host_id=h.host_id WHERE s.description='service_1' AND h.name='host_1'
			${output}=	Query	SELECT s.passive_checks FROM services s LEFT JOIN hosts h ON s.host_id=h.host_id WHERE s.description='service_1' AND h.name='host_1'
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((0,),)"
		END
		Should Be Equal As Strings	${output}	((0,),)

		Enable Passive Svc Checks	${use_grpc}	host_1	service_1

		FOR	${index}	IN RANGE	30
			Log To Console	SELECT s.passive_checks FROM services s LEFT JOIN hosts h ON s.host_id=h.host_id WHERE s.description='service_1' AND h.name='host_1'
			${output}=	Query	SELECT s.passive_checks FROM services s LEFT JOIN hosts h ON s.host_id=h.host_id WHERE s.description='service_1' AND h.name='host_1'
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((1,),)"
		END
		Should Be Equal As Strings	${output}	((1,),)

		Stop Engine
		Kindly Stop Broker
	END

BEEXTCMD39
	[Documentation]	external command START_OBSESSING_OVER_HOST and STOP_OBSESSING_OVER_HOST on bbdo3.0
	[Tags]	Broker	Engine	host	extcmd
	Config Engine	${1}	${50}	${20}
	Config Broker	rrd
	Config Broker	central
	Config Broker	module	${1}
	Broker Config Add Item	module0	bbdo_version	3.0.0
	Broker Config Add Item	central	bbdo_version	3.0.0
	Broker Config Add Item	rrd	bbdo_version	3.0.0
	Broker Config Log	central	core	error
	Broker Config Log	central	sql	debug
	Broker Config Log	module0	neb	trace
	Config Broker Sql Output	central	unified_sql
	Clear Retention
	FOR	${use_grpc}	IN RANGE	0  1
		${start}=	Get Current Date
		Start Broker
		Start Engine
		${content}=	Create List	INITIAL SERVICE STATE: host_50;service_1000;	check_for_external_commands()
		${result}=	Find In Log with Timeout	${engineLog0}	${start}	${content}	60
		Should Be True	${result}	msg=An Initial host state on host_1 should be raised before we can start our external commands.
		Stop Obsessing Over Host	${use_grpc}	host_1

		Connect To Database	pymysql	${DBName}	${DBUser}	${DBPass}	${DBHost}	${DBPort}

		FOR	${index}	IN RANGE	30
			Log To Console	SELECT obsess_over_host FROM hosts WHERE name='host_1'
			${output}=	Query	SELECT obsess_over_host FROM hosts WHERE name='host_1'
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((0,),)"
		END
		Should Be Equal As Strings	${output}	((0,),)

		Start Obsessing Over Host	${use_grpc}	host_1

		FOR	${index}	IN RANGE	30
			Log To Console	SELECT obsess_over_host FROM hosts WHERE name='host_1'
			${output}=	Query	SELECT obsess_over_host FROM hosts WHERE name='host_1'
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((1,),)"
		END
		Should Be Equal As Strings	${output}	((1,),)

		Stop Engine
		Kindly Stop Broker
	END

BEEXTCMD40
	[Documentation]	external command START_OBSESSING_OVER_HOST and STOP_OBSESSING_OVER_HOST on bbdo2.0
	[Tags]	Broker	Engine	host	extcmd
	Config Engine	${1}	${50}	${20}
	Config Broker	rrd
	Config Broker	central
	Config Broker	module	${1}
	Broker Config Log	central	core	error
	Broker Config Log	central	sql	debug
	Clear Retention
	FOR	${use_grpc}	IN RANGE	0  1
		${start}=	Get Current Date
		Start Broker
		Start Engine
		${content}=	Create List	INITIAL SERVICE STATE: host_50;service_1000;	check_for_external_commands()
		${result}=	Find In Log with Timeout	${engineLog0}	${start}	${content}	60
		Should Be True	${result}	msg=An Initial host state on host_1 should be raised before we can start our external commands.
		Stop Obsessing Over Host	${use_grpc}	host_1

		Connect To Database	pymysql	${DBName}	${DBUser}	${DBPass}	${DBHost}	${DBPort}

		FOR	${index}	IN RANGE	30
			Log To Console	SELECT obsess_over_host FROM hosts WHERE name='host_1'
			${output}=	Query	SELECT obsess_over_host FROM hosts WHERE name='host_1'
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((0,),)"
		END
		Should Be Equal As Strings	${output}	((0,),)

		Start Obsessing Over Host	${use_grpc}	host_1

		FOR	${index}	IN RANGE	30
			Log To Console	SELECT obsess_over_host FROM hosts WHERE name='host_1'
			${output}=	Query	SELECT obsess_over_host FROM hosts WHERE name='host_1'
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((1,),)"
		END
		Should Be Equal As Strings	${output}	((1,),)

		Stop Engine
		Kindly Stop Broker
	END

BEEXTCMD41
	[Documentation]	external command START_OBSESSING_OVER_SVC and STOP_OBSESSING_OVER_SVC on bbdo3.0
	[Tags]	Broker	Engine	host	extcmd
	Config Engine	${1}	${50}	${20}
	Config Broker	rrd
	Config Broker	central
	Config Broker	module	${1}
	Broker Config Add Item	module0	bbdo_version	3.0.0
	Broker Config Add Item	central	bbdo_version	3.0.0
	Broker Config Add Item	rrd	bbdo_version	3.0.0
	Broker Config Log	central	core	error
	Broker Config Log	central	sql	debug
	Broker Config Log	module0	neb	trace
	Config Broker Sql Output	central	unified_sql
	Clear Retention
	FOR	${use_grpc}	IN RANGE	0  1
		${start}=	Get Current Date
		Start Broker
		Start Engine
		${content}=	Create List	INITIAL SERVICE STATE: host_50;service_1000;	check_for_external_commands()
		${result}=	Find In Log with Timeout	${engineLog0}	${start}	${content}	60
		Should Be True	${result}	msg=An Initial host state on host_1 should be raised before we can start our external commands.
		Stop Obsessing Over Svc	${use_grpc}	host_1	service_1

		Connect To Database	pymysql	${DBName}	${DBUser}	${DBPass}	${DBHost}	${DBPort}

		FOR	${index}	IN RANGE	30
			Log To Console	SELECT s.obsess_over_service FROM services s LEFT JOIN hosts h ON s.host_id=h.host_id WHERE s.description='service_1' AND h.name='host_1'
			${output}=	Query	SELECT s.obsess_over_service FROM services s LEFT JOIN hosts h ON s.host_id=h.host_id WHERE s.description='service_1' AND h.name='host_1'
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((0,),)"
		END
		Should Be Equal As Strings	${output}	((0,),)

		Start Obsessing Over Svc	${use_grpc}	host_1	service_1

		FOR	${index}	IN RANGE	30
			Log To Console	SELECT s.obsess_over_service FROM services s LEFT JOIN hosts h ON s.host_id=h.host_id WHERE s.description='service_1' AND h.name='host_1'
			${output}=	Query	SELECT s.obsess_over_service FROM services s LEFT JOIN hosts h ON s.host_id=h.host_id WHERE s.description='service_1' AND h.name='host_1'
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((1,),)"
		END
		Should Be Equal As Strings	${output}	((1,),)

		Stop Engine
		Kindly Stop Broker
	END

BEEXTCMD42
	[Documentation]	external command START_OBSESSING_OVER_SVC and STOP_OBSESSING_OVER_SVC on bbdo2.0
	[Tags]	Broker	Engine	host	extcmd
	Config Engine	${1}	${50}	${20}
	Config Broker	rrd
	Config Broker	central
	Config Broker	module	${1}
	Broker Config Log	central	core	error
	Broker Config Log	central	sql	debug
	Clear Retention
	FOR	${use_grpc}	IN RANGE	0  1
		${start}=	Get Current Date
		Start Broker
		Start Engine
		${content}=	Create List	INITIAL SERVICE STATE: host_50;service_1000;	check_for_external_commands()
		${result}=	Find In Log with Timeout	${engineLog0}	${start}	${content}	60
		Should Be True	${result}	msg=An Initial host state on host_1 should be raised before we can start our external commands.
		Stop Obsessing Over Svc	${use_grpc}	host_1	service_1

		Connect To Database	pymysql	${DBName}	${DBUser}	${DBPass}	${DBHost}	${DBPort}

		FOR	${index}	IN RANGE	30
			Log To Console	SELECT s.obsess_over_service FROM services s LEFT JOIN hosts h ON s.host_id=h.host_id WHERE s.description='service_1' AND h.name='host_1'
			${output}=	Query	SELECT s.obsess_over_service FROM services s LEFT JOIN hosts h ON s.host_id=h.host_id WHERE s.description='service_1' AND h.name='host_1'
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((0,),)"
		END
		Should Be Equal As Strings	${output}	((0,),)

		Start Obsessing Over Svc	${use_grpc}	host_1	service_1

		FOR	${index}	IN RANGE	30
			Log To Console	SELECT s.obsess_over_service FROM services s LEFT JOIN hosts h ON s.host_id=h.host_id WHERE s.description='service_1' AND h.name='host_1'
			${output}=	Query	SELECT s.obsess_over_service FROM services s LEFT JOIN hosts h ON s.host_id=h.host_id WHERE s.description='service_1' AND h.name='host_1'
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((1,),)"
		END
		Should Be Equal As Strings	${output}	((1,),)

		Stop Engine
		Kindly Stop Broker
	END

BEEXTCMD_GRPC1
	[Documentation]	external command CHANGE_NORMAL_SVC_CHECK_INTERVAL on bbdo3.0 and grpc
	[Tags]	Broker	Engine	services	extcmd
	Config Engine	${1}	${50}	${20}
	Config Broker	rrd
	Config Broker	central
	Config Broker	module	${1}
	Change Broker tcp output to grpc	module0
	Change Broker tcp input to grpc     central
	Broker Config Add Item	module0	bbdo_version	3.0.0
	Broker Config Add Item	central	bbdo_version	3.0.0
	Broker Config Add Item	rrd	bbdo_version	3.0.0
	Broker Config Log	central	sql	debug
	Config Broker Sql Output	central	unified_sql
	FOR  ${use_grpc}  IN RANGE  0  2
		Log To Console	external command CHANGE_NORMAL_SVC_CHECK_INTERVAL on bbdo3.0 use_grpc=${use_grpc}
		Clear Retention
		${start}=	Get Current Date
		Start Broker
		Start Engine
			${content}=	Create List	INITIAL SERVICE STATE: host_50;service_1000;	check_for_external_commands()
			${result}=	Find In Log with Timeout	${engineLog0}	${start}	${content}	60
			Should Be True	${result}	msg=An Initial host state on host_1 should be raised before we can start our external commands.
		Change Normal Svc Check Interval  ${use_grpc}  host_1	service_1	10

		Connect To Database	pymysql	${DBName}	${DBUser}	${DBPass}	${DBHost}	${DBPort}

		FOR	${index}	IN RANGE	300
			Log To Console	SELECT s.check_interval FROM services s LEFT JOIN hosts h ON s.host_id=h.host_id WHERE s.description='service_1' AND h.name='host_1'
			${output}=	Query	SELECT s.check_interval FROM services s LEFT JOIN hosts h ON s.host_id=h.host_id WHERE s.description='service_1' AND h.name='host_1'
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((10.0,),)"
		END
		Should Be Equal As Strings	${output}	((10.0,),)
		Stop Engine
		Kindly Stop Broker
	END

BEEXTCMD_GRPC2
	[Documentation]	external command CHANGE_NORMAL_SVC_CHECK_INTERVAL on bbdo2.0 and grpc
	[Tags]	Broker	Engine	services	extcmd
	Config Engine	${1}	${50}	${20}
	Config Broker	rrd
	Config Broker	central
	Config Broker	module	${1}
	Change Broker tcp output to grpc	module0
	Change Broker tcp input to grpc     central
	Broker Config Log	central	sql	debug
	FOR  ${use_grpc}  IN RANGE  0  2
		Log To Console	external command CHANGE_NORMAL_SVC_CHECK_INTERVAL on bbdo2.0 use_grpc=${use_grpc}
		Clear Retention
		${start}=	Get Current Date
		Start Broker
		Start Engine
			${content}=	Create List	INITIAL SERVICE STATE: host_50;service_1000;
			${result}=	Find In Log with Timeout	${engineLog0}	${start}	${content}	60
			Should Be True	${result}	msg=An Initial host state on host_1 should be raised before we can start our external commands.
		Change Normal Svc Check Interval  ${use_grpc}	host_1	service_1	15

		Connect To Database	pymysql	${DBName}	${DBUser}	${DBPass}	${DBHost}	${DBPort}

		FOR	${index}	IN RANGE	30
			Log To Console	SELECT s.check_interval FROM services s LEFT JOIN hosts h ON s.host_id=h.host_id WHERE s.description='service_1' AND h.name='host_1'
			${output}=	Query	SELECT s.check_interval FROM services s LEFT JOIN hosts h ON s.host_id=h.host_id WHERE s.description='service_1' AND h.name='host_1'
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((15.0,),)"
		END
		Should Be Equal As Strings	${output}	((15.0,),)
		Stop Engine
		Kindly Stop Broker
	END

BEEXTCMD_GRPC3
	[Documentation]	external command CHANGE_NORMAL_HOST_CHECK_INTERVAL on bbdo3.0 and grpc
	[Tags]	Broker	Engine	host	extcmd
	Config Engine	${1}	${50}	${20}
	Config Broker	rrd
	Config Broker	central
	Config Broker	module	${1}
	Change Broker tcp output to grpc	module0
	Change Broker tcp input to grpc     central
	Broker Config Add Item	module0	bbdo_version	3.0.0
	Broker Config Add Item	central	bbdo_version	3.0.0
	Broker Config Add Item	rrd	bbdo_version	3.0.0
	Broker Config Log	central	core	error
	Broker Config Log	central	sql	debug
	Broker Config Log	module0	neb	trace
	Config Broker Sql Output	central	unified_sql
	FOR  ${use_grpc}  IN RANGE  0  2
		Log To Console	external command CHANGE_NORMAL_HOST_CHECK_INTERVAL on bbdo3.0 use_grpc=${use_grpc}
		Clear Retention
		${start}=	Get Current Date
		Start Broker
		Start Engine
			${content}=	Create List	INITIAL SERVICE STATE: host_50;service_1000;
			${result}=	Find In Log with Timeout	${engineLog0}	${start}	${content}	60
			Should Be True	${result}	msg=An Initial host state on host_1 should be raised before we can start our external commands.
		Change Normal Host Check Interval  ${use_grpc}  host_1	10

		Connect To Database	pymysql	${DBName}	${DBUser}	${DBPass}	${DBHost}	${DBPort}

		FOR	${index}	IN RANGE	30
			Log To Console	SELECT check_interval FROM hosts WHERE name='host_1'
			${output}=	Query	SELECT check_interval FROM hosts WHERE name='host_1'
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((10.0,),)"
		END
		Should Be Equal As Strings	${output}	((10.0,),)
		Stop Engine
		Kindly Stop Broker
	END

BEEXTCMD_GRPC4
	[Documentation]	external command CHANGE_NORMAL_HOST_CHECK_INTERVAL on bbdo2.0 and grpc
	[Tags]	Broker	Engine	host	extcmd
	Config Engine	${1}	${50}	${20}
	Config Broker	rrd
	Config Broker	central
	Config Broker	module	${1}
	Change Broker tcp output to grpc	module0
	Change Broker tcp input to grpc     central
	Broker Config Log	central	core	error
	Broker Config Log	central	sql	debug
	FOR  ${use_grpc}  IN RANGE  0  2
		Log To Console	external command CHANGE_NORMAL_HOST_CHECK_INTERVAL on bbdo2.0 use_grpc=${use_grpc}
		Clear Retention
		${start}=	Get Current Date
		Start Broker
		Start Engine
			${content}=	Create List	INITIAL SERVICE STATE: host_50;service_1000;
			${result}=	Find In Log with Timeout	${engineLog0}	${start}	${content}	60
			Should Be True	${result}	msg=An Initial host state on host_1 should be raised before we can start our external commands.
		Change Normal Host Check Interval  ${use_grpc}  host_1	15

		Connect To Database	pymysql	${DBName}	${DBUser}	${DBPass}	${DBHost}	${DBPort}

		FOR	${index}	IN RANGE	30
			Log To Console	SELECT check_interval FROM hosts WHERE name='host_1'
			${output}=	Query	SELECT check_interval FROM hosts WHERE name='host_1'
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((15.0,),)"
		END
		Should Be Equal As Strings	${output}	((15.0,),)
		Stop Engine
		Kindly Stop Broker
	END

BEEXTCMD_REVERSE_GRPC1
	[Documentation]	external command CHANGE_NORMAL_SVC_CHECK_INTERVAL on bbdo3.0 and reversed gRPC
	[Tags]	Broker	Engine	services	extcmd	bbdo3
	Config Engine	${1}	${50}	${20}
	Config Broker	rrd
	Config Broker	central
	Config Broker	module	${1}
	Change Broker tcp output to grpc	module0
	Change Broker tcp input to grpc     central
	Broker Config Output Remove  module0  central-module-master-output  host
	Broker Config Output Remove  central  centreon-broker-master-rrd  host
	Broker Config Input Set  central  central-broker-master-input  host  127.0.0.1
	Broker Config Input Set  rrd  central-rrd-master-input  host  127.0.0.1
	Broker Config Add Item	module0	bbdo_version	3.0.0
	Broker Config Add Item	central	bbdo_version	3.0.0
	Broker Config Add Item	rrd	bbdo_version	3.0.0
	Broker Config Log	central	sql	debug
	Config Broker Sql Output	central	unified_sql
	FOR  ${use_grpc}  IN RANGE  0  2
		Log To Console	external command CHANGE_NORMAL_SVC_CHECK_INTERVAL on bbdo3.0 use_grpc=${use_grpc}
		Clear Retention
		${start}=	Get Current Date
                Sleep	1s
		Start Broker
		Start Engine
		${content}=	Create List	INITIAL SERVICE STATE: host_50;service_1000;	check_for_external_commands()
		${result}=	Find In Log with Timeout	${engineLog0}	${start}	${content}	60
		Should Be True	${result}	msg=An Initial host state on host_1 should be raised before we can start our external commands.
		Change Normal Svc Check Interval  ${use_grpc}  host_1	service_1	10

		Connect To Database	pymysql	${DBName}	${DBUser}	${DBPass}	${DBHost}	${DBPort}

		FOR	${index}	IN RANGE	300
			Log To Console	SELECT s.check_interval FROM services s LEFT JOIN hosts h ON s.host_id=h.host_id WHERE h.name='host_1' AND s.description='service_1'
			${output}=	Query	SELECT s.check_interval FROM services s LEFT JOIN hosts h ON s.host_id=h.host_id WHERE h.name='host_1' AND s.description='service_1'
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((10.0,),)"
		END
		Should Be Equal As Strings	${output}	((10.0,),)
		Stop Engine
		Kindly Stop Broker
	END

BEEXTCMD_REVERSE_GRPC2
	[Documentation]	external command CHANGE_NORMAL_SVC_CHECK_INTERVAL on bbdo2.0 and grpc reversed
	[Tags]	Broker	Engine	services	extcmd
	Config Engine	${1}	${50}	${20}
	Config Broker	rrd
	Config Broker	central
	Config Broker	module	${1}
	Change Broker tcp output to grpc	module0
	Change Broker tcp input to grpc     central
	Broker Config Output Remove  module0  central-module-master-output  host
	Broker Config Output Remove  central  centreon-broker-master-rrd  host
	Broker Config Input Set  central  central-broker-master-input  host  127.0.0.1
	Broker Config Input Set  rrd  central-rrd-master-input  host  127.0.0.1
	Broker Config Log	central	sql	debug
	FOR  ${use_grpc}  IN RANGE  0  2
		Log To Console	external command CHANGE_NORMAL_SVC_CHECK_INTERVAL on bbdo2.0 use_grpc=${use_grpc} reversed
		Clear Retention
		${start}=	Get Current Date
		Start Broker
		Start Engine
		${content}=	Create List	INITIAL SERVICE STATE: host_50;service_1000;	check_for_external_commands()
		${result}=	Find In Log with Timeout	${engineLog0}	${start}	${content}	60
		Should Be True	${result}	msg=An Initial host state on host_1 should be raised before we can start our external commands.
		Change Normal Svc Check Interval  ${use_grpc}	host_1	service_1	15

		Connect To Database	pymysql	${DBName}	${DBUser}	${DBPass}	${DBHost}	${DBPort}

		FOR	${index}	IN RANGE	30
			Log To Console	SELECT s.check_interval FROM services s LEFT JOIN hosts h ON s.host_id=h.host_id WHERE h.name='host_1' AND s.description='service_1'
			${output}=	Query	SELECT s.check_interval FROM services s LEFT JOIN hosts h ON s.host_id=h.host_id WHERE h.name='host_1' AND s.description='service_1'
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((15.0,),)"
		END
		Should Be Equal As Strings	${output}	((15.0,),)
		Stop Engine
		Kindly Stop Broker
	END

BEEXTCMD_REVERSE_GRPC3
	[Documentation]	external command CHANGE_NORMAL_HOST_CHECK_INTERVAL on bbdo3.0 and grpc reversed
	[Tags]	Broker	Engine	host	extcmd
	Config Engine	${1}	${50}	${20}
	Config Broker	rrd
	Config Broker	central
	Config Broker	module	${1}
	Change Broker tcp output to grpc	module0
	Change Broker tcp input to grpc     central
	Broker Config Add Item	module0	bbdo_version	3.0.0
	Broker Config Add Item	central	bbdo_version	3.0.0
	Broker Config Add Item	rrd	bbdo_version	3.0.0
	Broker Config Output Remove  module0  central-module-master-output  host
	Broker Config Output Remove  central  centreon-broker-master-rrd  host
	Broker Config Input Set  central  central-broker-master-input  host  127.0.0.1
	Broker Config Input Set  rrd  central-rrd-master-input  host  127.0.0.1
	Broker Config Log	central	core	error
	Broker Config Log	central	sql	debug
	Broker Config Log	module0	neb	trace
	Config Broker Sql Output	central	unified_sql
	FOR  ${use_grpc}  IN RANGE  0  2
		Log To Console	external command CHANGE_NORMAL_HOST_CHECK_INTERVAL on bbdo3.0 use_grpc=${use_grpc} reversed
		Clear Retention
		${start}=	Get Current Date
		Start Broker
		Start Engine
		${content}=	Create List	INITIAL SERVICE STATE: host_50;service_1000;	check_for_external_commands()
		${result}=	Find In Log with Timeout	${engineLog0}	${start}	${content}	60
		Should Be True	${result}	msg=An Initial host state on host_1 should be raised before we can start our external commands.
		Change Normal Host Check Interval  ${use_grpc}  host_1	10

		Connect To Database	pymysql	${DBName}	${DBUser}	${DBPass}	${DBHost}	${DBPort}

		FOR	${index}	IN RANGE	30
			Log To Console	SELECT check_interval FROM hosts WHERE name='host_1'
			${output}=	Query	SELECT check_interval FROM hosts WHERE name='host_1'
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((10.0,),)"
		END
		Should Be Equal As Strings	${output}	((10.0,),)
		Stop Engine
		Kindly Stop Broker
	END

BEEXTCMD_REVERSE_GRPC4
	[Documentation]	external command CHANGE_NORMAL_HOST_CHECK_INTERVAL on bbdo2.0 and grpc reversed
	[Tags]	Broker	Engine	host	extcmd
	Config Engine	${1}	${50}	${20}
	Config Broker	rrd
	Config Broker	central
	Config Broker	module	${1}
	Change Broker tcp output to grpc	module0
	Change Broker tcp input to grpc     central
	Broker Config Output Remove  module0  central-module-master-output  host
	Broker Config Output Remove  central  centreon-broker-master-rrd  host
	Broker Config Input Set  central  central-broker-master-input  host  127.0.0.1
	Broker Config Input Set  rrd  central-rrd-master-input  host  127.0.0.1
	Broker Config Log	central	core	error
	Broker Config Log	central	sql	debug
	FOR  ${use_grpc}  IN RANGE  0  2
		Log To Console	external command CHANGE_NORMAL_HOST_CHECK_INTERVAL on bbdo2.0 use_grpc=${use_grpc} reversed
		Clear Retention
		${start}=	Get Current Date
		Start Broker
		Start Engine
		${content}=	Create List	INITIAL SERVICE STATE: host_50;service_1000;	check_for_external_commands()
		${result}=	Find In Log with Timeout	${engineLog0}	${start}	${content}	60
		Should Be True	${result}	msg=An Initial host state on host_1 should be raised before we can start our external commands.
                Sleep	1s
		Change Normal Host Check Interval  ${use_grpc}  host_1	15

		Connect To Database	pymysql	${DBName}	${DBUser}	${DBPass}	${DBHost}	${DBPort}

		FOR	${index}	IN RANGE	30
			Log To Console	SELECT check_interval FROM hosts WHERE name='host_1'
			${output}=	Query	SELECT check_interval FROM hosts WHERE name='host_1'
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((15.0,),)"
		END
		Should Be Equal As Strings	${output}	((15.0,),)
		Stop Engine
		Kindly Stop Broker
	END


BEEXTCMD_COMPRESS_GRPC1
	[Documentation]	external command CHANGE_NORMAL_SVC_CHECK_INTERVAL on bbdo3.0 and compressed grpc
	[Tags]	Broker	Engine	services	extcmd
	Config Engine	${1}	${50}	${20}
	Config Broker	rrd
	Config Broker	central
	Config Broker	module	${1}
	Change Broker tcp output to grpc	module0
	Change Broker tcp input to grpc     central
	Change Broker Compression Output  module0  central-module-master-output  yes
	Change Broker Compression Input  central  centreon-broker-master-input  yes
	Broker Config Add Item	module0	bbdo_version	3.0.0
	Broker Config Add Item	central	bbdo_version	3.0.0
	Broker Config Add Item	rrd	bbdo_version	3.0.0
	Broker Config Log	central	sql	debug
	Config Broker Sql Output	central	unified_sql
	FOR  ${use_grpc}  IN RANGE  0  2
		Log To Console	external command CHANGE_NORMAL_SVC_CHECK_INTERVAL on bbdo3.0 use_grpc=${use_grpc}
		Clear Retention
		${start}=	Get Current Date
		Start Broker
		Start Engine
			${content}=	Create List	INITIAL SERVICE STATE: host_50;service_1000;	check_for_external_commands()
			${result}=	Find In Log with Timeout	${engineLog0}	${start}	${content}	60
			Should Be True	${result}	msg=An Initial host state on host_1 should be raised before we can start our external commands.
		Change Normal Svc Check Interval  ${use_grpc}  host_1	service_1	10

		Connect To Database	pymysql	${DBName}	${DBUser}	${DBPass}	${DBHost}	${DBPort}

		FOR	${index}	IN RANGE	300
			Log To Console	SELECT s.check_interval FROM services s LEFT JOIN hosts h ON s.host_id=h.host_id WHERE s.description='service_1' AND h.name='host_1'
			${output}=	Query	SELECT s.check_interval FROM services s LEFT JOIN hosts h ON s.host_id=h.host_id WHERE s.description='service_1' AND h.name='host_1'
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((10.0,),)"
		END
		Should Be Equal As Strings	${output}	((10.0,),)
		Stop Engine
		Kindly Stop Broker
	END

BEATOI11
	[Documentation]	external command SEND_CUSTOM_HOST_NOTIFICATION with option_number=1 should work
	[Tags]	Broker	Engine	host	extcmd	Notification	atoi
	Config Engine	${1}	${50}	${20}
	Config Broker	rrd
	Config Broker	central
	Config Broker	module	${1}
	Broker Config Log	central	core	error
	Broker Config Log	central	sql	debug
	${start}=	Get Current Date
	Start Broker
	Start Engine
	${content}=	Create List	check_for_external_commands
	${result}=	Find In Log with Timeout	${engineLog0}	${start}	${content}	60
	Should Be True	${result}	msg=No check for external commands executed for 1mn.
	SEND CUSTOM HOST NOTIFICATION	host_1	1	admin	foobar
	${content}=	Create List	EXTERNAL COMMAND: SEND_CUSTOM_HOST_NOTIFICATION;host_1;1;admin;foobar
	${result}=	Find In Log With Timeout	${engineLog0}	${start}	${content}	60
	Should Be True	${result}	msg=command argument notification_option must be an integer between 0 and 7.
	Stop Engine
	Kindly Stop Broker

BEATOI12
	[Documentation]	external command SEND_CUSTOM_HOST_NOTIFICATION with option_number>7 should fail
	[Tags]	Broker	Engine	host	extcmd	Notification	atoi
	Config Engine	${1}	${50}	${20}
	Config Broker	rrd
	Config Broker	central
	Config Broker	module	${1}
	Broker Config Log	central	core	error
	Broker Config Log	central	sql	debug
	${start}=	Get Current Date
	Start Broker
	Start Engine
	${content}=	Create List	check_for_external_commands
	${result}=	Find In Log with Timeout	${engineLog0}	${start}	${content}	60
	Should Be True	${result}	msg=No check for external commands executed for 1mn.
	SEND CUSTOM HOST NOTIFICATION	host_1	8	admin	foobar
	${content}=	Create List	Error: could not send custom host notification: '8' must be an integer between 0 and 7
	${result}=	Find In Log with Timeout	${engineLog0}	${start}	${content}	60
	Should Be True	${result}	msg=command argument notification_option must be an integer between 0 and 7.
	Stop Engine
	Kindly Stop Broker


BEATOI13
	[Documentation]	external command SCHEDULE SERVICE DOWNTIME with duration<0 should fail
	[Tags]	Broker	Engine	host	extcmd	atoi
	Config Engine	${1}	${50}	${20}
	Config Broker	rrd
	Config Broker	central
	Config Broker	module	${1}
	Broker Config Log	central	core	error
	Broker Config Log	central	sql	debug
	${start}=	Get Current Date
	Start Broker
	Start Engine
	${content}=	Create List	check_for_external_commands
	${result}=	Find In Log with Timeout	${engineLog0}	${start}	${content}	60
	Should Be True	${result}	msg=No check for external commands executed for 1mn.
	${date}=	Get Current Date	result_format=epoch
	SCHEDULE SERVICE DOWNTIME	host_1	service_1	-1
	${content}=	Create List	Error: could not schedule downtime : duration
	${result}=	Find In Log with Timeout	${engineLog0}	${start}	${content}	60
	Should Be True	${result}	msg=command argument duration must be an integer >= 0.
	Stop Engine
	Kindly Stop Broker


BEATOI21
	[Documentation]	external command ADD_HOST_COMMENT and DEL_HOST_COMMENT should work
	[Tags]	Broker	Engine	host	extcmd	atoi
	Config Engine	${1}	${50}	${20}
	Config Broker	rrd
	Config Broker	central
	Config Broker	module	${1}
	Broker Config Log	central	core	error
	Broker Config Log	central	sql	debug
	${start}=	Get Current Date	exclude_millis=True
	Start Broker
	Start Engine
	${content}=	Create List	check_for_external_commands
	${result}=	Find In Log with Timeout	${engineLog0}	${start}	${content}	60
	Should Be True	${result}	msg=No check for external commands executed for 1mn.
	ADD HOST COMMENT	host_1	1	user	comment
	${content}=	Create List	ADD_HOST_COMMENT
	${result}=	Find In Log with Timeout	${engineLog0}	${start}	${content}	60
	Should Be True	${result}	msg=the comment with id:1 was not added.
	${com_id}=	Find Internal Id	${start}	True	30
	Should Be True	${com_id}>0	msg=Comment id should be a positive integer.
	DEL HOST COMMENT	${com_id}
	${result}=	Find Internal Id	${start}	False	30
	Should Be True	${result}	msg=the comment with id:${com_id} was not deleted.
	Stop Engine
	Kindly Stop Broker


BEATOI22
	[Documentation]	external command DEL_HOST_COMMENT with comment_id<0 should fail
	[Tags]	Broker	Engine	host	extcmd	atoi
	Config Engine	${1}	${50}	${20}
	Config Broker	rrd
	Config Broker	central
	Config Broker	module	${1}
	Broker Config Log	central	core	error
	Broker Config Log	central	sql	debug
	${start}=	Get Current Date
	Sleep	1s
	Start Broker
	Start Engine
	${content}=	Create List	check_for_external_commands
	${result}=	Find In Log with Timeout	${engineLog0}	${start}	${content}	60
	Should Be True	${result}	msg=No check for external commands executed for 1mn.
	ADD HOST COMMENT	host_1	1	user	comment
	${content}=	Create List	ADD_HOST_COMMENT
	${result}=	Find In Log with Timeout	${engineLog0}	${start}	${content}	60
	Should Be True	${result}	msg=the comment with id:1 was not added.
	${com_id}=	Find Internal Id		${start}	True	30
	DEL HOST COMMENT	-1
	${content}=	Create List	Error: could not delete comment : comment_id
	${result}=	Find In Log with Timeout	${engineLog0}	${start}	${content}	60
	Should Be True	${result}	msg=comment_id must be an unsigned integer.
	${result}=	Find Internal Id	${start}	True	30
	Should Be True	${result}	msg=comment with id:-1 was deleted.
	Stop Engine
	Kindly Stop Broker


BEATOI23
	[Documentation]	external command ADD_SVC_COMMENT with persistent=0 should work
	[Tags]	Broker	Engine	host	extcmd	atoi
	Config Engine	${1}	${50}	${20}
	Config Broker	rrd
	Config Broker	central
	Config Broker	module	${1}
	Broker Config Log	central	core	error
	Broker Config Log	central	sql	error
	${start}=	Get Current Date
	Start Broker
	Start Engine
	${content}=	Create List	check_for_external_commands
	${result}=	Find In Log with Timeout	${engineLog0}	${start}	${content}	60
	Should Be True	${result}	msg=No check for external commands executed for 1mn.
	${date}=	Get Current Date	result_format=epoch
	ADD SVC COMMENT	host_1	service_1	0	user	comment
	${content}=	Create List	ADD_SVC_COMMENT
	${result}=	Find In Log with Timeout	${engineLog0}	${start}	${content}	60
	Should Be True	${result}	msg=command argument persistent_flag must be 0 or 1.
	Stop Engine
	Kindly Stop Broker

BECUSTOMHOSTVAR
	[Documentation]	external command CHANGE_CUSTOM_HOST_VAR on SNMPVERSION
	[Tags]	Broker	Engine	host	extcmd	atoi
	Config Engine	${1}	${50}	${20}
	Config Broker	central
	Config Broker	module	${1}
	Broker Config Log	central	sql	trace
	Broker Config Add Item	module0	bbdo_version	3.0.0
	Broker Config Add Item	central	bbdo_version	3.0.0
	Config Broker Sql Output	central	unified_sql
	${start}=	Get Current Date
	Start Broker
	Start Engine
	${content}=	Create List	check_for_external_commands
	${result}=	Find In Log with Timeout	${engineLog0}	${start}	${content}	60
	Should Be True	${result}	msg=No check for external commands executed for 1mn.
	${date}=	Get Current Date	result_format=epoch
	CHANGE CUSTOM HOST VAR COMMAND  host_1  SNMPVERSION  789456

	Connect To Database	pymysql	${DBName}	${DBUser}	${DBPass}	${DBHost}	${DBPort}

	FOR	${index}	IN RANGE	300
		Log To Console	SELECT c.value FROM customvariables c LEFT JOIN hosts h ON c.host_id=h.host_id WHERE h.name='host_1' && c.name='SNMPVERSION'
		${output}=	Query	SELECT c.value FROM customvariables c LEFT JOIN hosts h ON c.host_id=h.host_id WHERE h.name='host_1' && c.name='SNMPVERSION'
		Log To Console	${output}
		Sleep	1s
		EXIT FOR LOOP IF	"${output}" == "(('789456',),)"
	END
	Should Be Equal As Strings	${output}	(('789456',),)

	Stop Engine
	Kindly Stop Broker

BECUSTOMSVCVAR
	[Documentation]	external command CHANGE_CUSTOM_SVC_VAR on CRITICAL
	[Tags]	Broker	Engine	host	extcmd	atoi
	Config Engine	${1}	${50}	${20}
	Config Broker	central
	Config Broker	module	${1}
	Broker Config Log	central	sql	trace
	Broker Config Add Item	module0	bbdo_version	3.0.0
	Broker Config Add Item	central	bbdo_version	3.0.0
	Config Broker Sql Output	central	unified_sql
	${start}=	Get Current Date
	Start Broker
	Start Engine
	${content}=	Create List	check_for_external_commands
	${result}=	Find In Log with Timeout	${engineLog0}	${start}	${content}	60
	Should Be True	${result}	msg=No check for external commands executed for 1mn.
	${date}=	Get Current Date	result_format=epoch
	CHANGE CUSTOM SVC VAR COMMAND  host_1  service_1  CRITICAL  456123

	Connect To Database	pymysql	${DBName}	${DBUser}	${DBPass}	${DBHost}	${DBPort}

	FOR	${index}	IN RANGE	300
		Log To Console	SELECT c.value FROM customvariables c JOIN hosts h ON c.host_id=h.host_id JOIN services s ON c.service_id = s.service_id and h.host_id = s.service_id WHERE h.name='host_1' && s.description = 'service_1' && c.name='CRITICAL'
		${output}=	Query	SELECT c.value FROM customvariables c JOIN hosts h ON c.host_id=h.host_id JOIN services s ON c.service_id = s.service_id and h.host_id = s.service_id WHERE h.name='host_1' && s.description = 'service_1' && c.name='CRITICAL'
		Log To Console	${output}
		Sleep	1s
		EXIT FOR LOOP IF	"${output}" == "(('456123',),)"
	END
	Should Be Equal As Strings	${output}	(('456123',),)

	Stop Engine
	Kindly Stop Broker

BESERVCHECK
	[Documentation]	external command CHECK_SERVICE_RESULT 
	[Tags]	Broker	Engine	host	extcmd	atoi
	Config Engine	${1}	${50}	${20}
	Config Broker	central
	Config Broker	module	${1}
	Broker Config Log	central	sql	trace
	Broker Config Add Item	module0	bbdo_version	3.0.0
	Broker Config Add Item	central	bbdo_version	3.0.0
	Config Broker Sql Output	central	unified_sql
	${start}=	Get Current Date
	Start Broker
	Start Engine
	${content}=	Create List	check_for_external_commands
	${result}=	Find In Log with Timeout	${engineLog0}	${start}	${content}	60
	Should Be True	${result}	msg=No check for external commands executed for 1mn.
	Connect To Database	pymysql	${DBName}	${DBUser}	${DBPass}	${DBHost}	${DBPort}
	Execute SQL String	UPDATE services set command_line='toto', next_check=0 where service_id=1 and host_id=1
	schedule_forced_svc_check  host_1  service_1
	${command_param}=  get_command_service_param  1
	${result}=  check_service_check_with_timeout  host_1  service_1  30  ${VarRoot}/lib/centreon-engine/check.pl ${command_param}  
	Should Be True	${result}	msg=service table not updated

BEHOSTCHECK
	[Documentation]	external command CHECK_SERVICE_RESULT 
	[Tags]	Broker	Engine	host	extcmd	atoi
	Config Engine	${1}	${50}	${20}
	Config Broker	central
	Config Broker	module	${1}
	Broker Config Log	central	sql	trace
	Broker Config Add Item	module0	bbdo_version	3.0.0
	Broker Config Add Item	central	bbdo_version	3.0.0
	Config Broker Sql Output	central	unified_sql
	${start}=	Get Current Date
	Start Broker
	Start Engine
	${content}=	Create List	check_for_external_commands
	${result}=	Find In Log with Timeout	${engineLog0}	${start}	${content}	60
	Should Be True	${result}	msg=No check for external commands executed for 1mn.
	Connect To Database	pymysql	${DBName}	${DBUser}	${DBPass}	${DBHost}	${DBPort}
	Execute SQL String	UPDATE hosts set command_line='toto' where name='host_1'
	schedule_forced_host_check  host_1
	${result}=  check_host_check_with_timeout  host_1  30  ${VarRoot}/lib/centreon-engine/check.pl 0 1  
	Should Be True	${result}	msg=hosts table not updated
