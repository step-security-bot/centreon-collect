*** Settings ***
Resource	../resources/resources.robot
Suite Setup	Clean Before Suite
Suite Teardown	Clean After Suite
Test Setup	Stop Processes

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
BEEXTCMD1
	[Documentation]	external command CHANGE_NORMAL_SVC_CHECK_INTERVAL on bbdo3.0
	[Tags]	Broker	Engine	services	extcmd
	Config Engine	${1}	${50}	${20}
	Config Broker	rrd
	Config Broker	central
	Config Broker	module	${1}
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
			${content}=	Create List	INITIAL SERVICE STATE: host_1;service_1;
			${result}=	Find In Log with Timeout	${logEngine0}	${start}	${content}	60
			Should Be True	${result}	msg=An Initial host state on host_1 should be raised before we can start our external commands.
		Change Normal Svc Check Interval  ${use_grpc}  host_1	service_1	10

		Connect To Database	pymysql	${DBName}	${DBUser}	${DBPass}	${DBHost}	${DBPort}

		FOR	${index}	IN RANGE	300
			Log To Console	select s.check_interval from services s,hosts h where s.description='service_1' and h.name='host_1' 
			${output}=	Query	select s.check_interval from services s,hosts h where s.description='service_1' and h.name='host_1'
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((10.0,),)"
		END
		Should Be Equal As Strings	${output}	((10.0,),)
		Stop Engine
		Kindly Stop Broker
	END
BEEXTCMD2
	[Documentation]	external command CHANGE_NORMAL_SVC_CHECK_INTERVAL on bbdo2.0
	[Tags]	Broker	Engine	services	extcmd
	Config Engine	${1}	${50}	${20}
	Config Broker	rrd
	Config Broker	central
	Config Broker	module	${1}
	Broker Config Log	central	sql	debug
	FOR  ${use_grpc}  IN RANGE  0  2
		Log To Console	external command CHANGE_NORMAL_SVC_CHECK_INTERVAL on bbdo2.0 use_grpc=${use_grpc}
		Clear Retention
		${start}=	Get Current Date
		Start Broker
		Start Engine
			${content}=	Create List	INITIAL SERVICE STATE: host_1;service_1;
			${result}=	Find In Log with Timeout	${logEngine0}	${start}	${content}	60
			Should Be True	${result}	msg=An Initial host state on host_1 should be raised before we can start our external commands.
		Change Normal Svc Check Interval  ${use_grpc}	host_1	service_1	15

		Connect To Database	pymysql	${DBName}	${DBUser}	${DBPass}	${DBHost}	${DBPort}

		FOR	${index}	IN RANGE	30
			Log To Console	select s.check_interval from services s,hosts h where s.description='service_1' and h.name='host_1' 
			${output}=	Query	select s.check_interval from services s,hosts h where s.description='service_1' and h.name='host_1'
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((15.0,),)"
		END
		Should Be Equal As Strings	${output}	((15.0,),)
		Stop Engine
		Kindly Stop Broker
	END

BEEXTCMD3
	[Documentation]	external command CHANGE_NORMAL_HOST_CHECK_INTERVAL on bbdo3.0
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
	FOR  ${use_grpc}  IN RANGE  0  2
		Log To Console	external command CHANGE_NORMAL_HOST_CHECK_INTERVAL on bbdo3.0 use_grpc=${use_grpc}
		Clear Retention
		${start}=	Get Current Date
		Start Broker
		Start Engine
			${content}=	Create List	INITIAL SERVICE STATE: host_1;service_1;
			${result}=	Find In Log with Timeout	${logEngine0}	${start}	${content}	60
			Should Be True	${result}	msg=An Initial host state on host_1 should be raised before we can start our external commands.
		Change Normal Host Check Interval  ${use_grpc}  host_1	10

		Connect To Database	pymysql	${DBName}	${DBUser}	${DBPass}	${DBHost}	${DBPort}

		FOR	${index}	IN RANGE	30
			Log To Console	select check_interval from hosts where name='host_1' 
			${output}=	Query	select check_interval from hosts where name='host_1' 
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((10.0,),)"
		END
		Should Be Equal As Strings	${output}	((10.0,),)
		Stop Engine
		Kindly Stop Broker
	END

BEEXTCMD4
	[Documentation]	external command CHANGE_NORMAL_HOST_CHECK_INTERVAL on bbdo2.0
	[Tags]	Broker	Engine	host	extcmd
	Config Engine	${1}	${50}	${20}
	Config Broker	rrd
	Config Broker	central
	Config Broker	module	${1}
	Broker Config Log	central	core	error
	Broker Config Log	central	sql	debug
	FOR  ${use_grpc}  IN RANGE  0  2
		Log To Console	external command CHANGE_NORMAL_HOST_CHECK_INTERVAL on bbdo2.0 use_grpc=${use_grpc}
		Clear Retention
		${start}=	Get Current Date
		Start Broker
		Start Engine
			${content}=	Create List	INITIAL SERVICE STATE: host_1;service_1;
			${result}=	Find In Log with Timeout	${logEngine0}	${start}	${content}	60
			Should Be True	${result}	msg=An Initial host state on host_1 should be raised before we can start our external commands.
		Change Normal Host Check Interval  ${use_grpc}  host_1	15

		Connect To Database	pymysql	${DBName}	${DBUser}	${DBPass}	${DBHost}	${DBPort}

		FOR	${index}	IN RANGE	30
			Log To Console	select check_interval from hosts where name='host_1' 
			${output}=	Query	select check_interval from hosts where name='host_1' 
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((15.0,),)"
		END
		Should Be Equal As Strings	${output}	((15.0,),)
		Stop Engine
		Kindly Stop Broker
	END



BEEXTCMD5
	[Documentation]	external command CHANGE_RETRY_SVC_CHECK_INTERVAL on bbdo3.0
	[Tags]	Broker	Engine	services	extcmd
	Config Engine	${1}	${50}	${20}
	Config Broker	rrd
	Config Broker	central
	Config Broker	module	${1}
	Broker Config Add Item	module0	bbdo_version	3.0.0
	Broker Config Add Item	central	bbdo_version	3.0.0
	Broker Config Add Item	rrd	bbdo_version	3.0.0
	Broker Config Log	central	sql	debug
	Config Broker Sql Output	central	unified_sql
	FOR  ${use_grpc}  IN RANGE  0  2
		Log To Console	external command CHANGE_RETRY_SVC_CHECK_INTERVAL on bbdo3.0 use_grpc=${use_grpc}
		Clear Retention
		${start}=	Get Current Date
		Start Broker
		Start Engine
			${content}=	Create List	INITIAL SERVICE STATE: host_1;service_1;
			${result}=	Find In Log with Timeout	${logEngine0}	${start}	${content}	60
			Should Be True	${result}	msg=An Initial host state on host_1 should be raised before we can start our external commands.
		Change Retry Svc Check Interval  ${use_grpc}  host_1	service_1	15

		Connect To Database	pymysql	${DBName}	${DBUser}	${DBPass}	${DBHost}	${DBPort}

		FOR	${index}	IN RANGE	30
			Log To Console	select s.retry_interval from services s,hosts h where s.description='service_1' and h.name='host_1' 
			${output}=	Query	select s.retry_interval from services s,hosts h where s.description='service_1' and h.name='host_1'
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((15.0,),)"
		END
		Should Be Equal As Strings	${output}	((15.0,),)
		Stop Engine
		Kindly Stop Broker
	END

BEEXTCMD6
	[Documentation]	external command CHANGE_RETRY_SVC_CHECK_INTERVAL on bbdo2.0
	[Tags]	Broker	Engine	services	extcmd
	Config Engine	${1}	${50}	${20}
	Config Broker	rrd
	Config Broker	central
	Config Broker	module	${1}
	Broker Config Log	central	sql	debug
	FOR  ${use_grpc}  IN RANGE  0  2
		Log To Console	external command CHANGE_RETRY_SVC_CHECK_INTERVAL on bbdo2.0 use_grpc=${use_grpc}
		Clear Retention
		${start}=	Get Current Date
		Start Broker
		Start Engine
        ${content}=	Create List	INITIAL SERVICE STATE: host_1;service_1;
        ${result}=	Find In Log with Timeout	${logEngine0}	${start}	${content}	60
        Should Be True	${result}	msg=An Initial host state on host_1 should be raised before we can start our external commands.
		Change Retry Svc Check Interval  ${use_grpc}  host_1	service_1	10

		Connect To Database	pymysql	${DBName}	${DBUser}	${DBPass}	${DBHost}	${DBPort}

		FOR	${index}	IN RANGE	30
			Log To Console	select s.retry_interval from services s,hosts h where s.description='service_1' and h.name='host_1' 
			${output}=	Query	select s.retry_interval from services s,hosts h where s.description='service_1' and h.name='host_1'
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((10.0,),)"
		END
		Should Be Equal As Strings	${output}	((10.0,),)
		Stop Engine
		Kindly Stop Broker
	END

BEEXTCMD7
	[Documentation]	external command CHANGE_RETRY_HOST_CHECK_INTERVAL on bbdo3.0
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
	FOR  ${use_grpc}  IN RANGE  0  2
		Log To Console	external command CHANGE_RETRY_HOST_CHECK_INTERVAL on bbdo3.0 use_grpc=${use_grpc}
		Clear Retention
		${start}=	Get Current Date
		Start Broker
		Start Engine
			${content}=	Create List	INITIAL SERVICE STATE: host_1;service_1;
			${result}=	Find In Log with Timeout	${logEngine0}	${start}	${content}	60
			Should Be True	${result}	msg=An Initial host state on host_1 should be raised before we can start our external commands.
		Change Retry Host Check Interval  ${use_grpc}  host_1	15

		Connect To Database	pymysql	${DBName}	${DBUser}	${DBPass}	${DBHost}	${DBPort}

		FOR	${index}	IN RANGE	30
			Log To Console	select retry_interval from hosts where name='host_1' 
			${output}=	Query	select retry_interval from hosts where name='host_1' 
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((15.0,),)"
		END
		Should Be Equal As Strings	${output}	((15.0,),)
		Stop Engine
		Kindly Stop Broker
	END

BEEXTCMD8
	[Documentation]	external command CHANGE_RETRY_HOST_CHECK_INTERVAL on bbdo2.0
	[Tags]	Broker	Engine	host	extcmd
	Config Engine	${1}	${50}	${20}
	Config Broker	rrd
	Config Broker	central
	Config Broker	module	${1}
	Broker Config Log	central	core	error
	Broker Config Log	central	sql	debug
	FOR  ${use_grpc}  IN RANGE  0  2
		Log To Console	external command CHANGE_RETRY_HOST_CHECK_INTERVAL on bbdo2.0 use_grpc=${use_grpc}
		Clear Retention
		${start}=	Get Current Date
		Start Broker
		Start Engine
			${content}=	Create List	INITIAL SERVICE STATE: host_1;service_1;
			${result}=	Find In Log with Timeout	${logEngine0}	${start}	${content}	60
			Should Be True	${result}	msg=An Initial host state on host_1 should be raised before we can start our external commands.
		Change Retry Host Check Interval  ${use_grpc}  host_1	10

		Connect To Database	pymysql	${DBName}	${DBUser}	${DBPass}	${DBHost}	${DBPort}

		FOR	${index}	IN RANGE	30
			Log To Console	select retry_interval from hosts where name='host_1' 
			${output}=	Query	select retry_interval from hosts where name='host_1' 
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((10.0,),)"
		END
		Should Be Equal As Strings	${output}	((10.0,),)
		Stop Engine
		Kindly Stop Broker
	END

BEEXTCMD9
	[Documentation]	external command CHANGE_MAX_SVC_CHECK_ATTEMPTS on bbdo3.0
	[Tags]	Broker	Engine	services	extcmd
	Config Engine	${1}	${50}	${20}
	Config Broker	rrd
	Config Broker	central
	Config Broker	module	${1}
	Broker Config Add Item	module0	bbdo_version	3.0.0
	Broker Config Add Item	central	bbdo_version	3.0.0
	Broker Config Add Item	rrd	bbdo_version	3.0.0
	Broker Config Log	central	sql	debug
	Config Broker Sql Output	central	unified_sql
	FOR  ${use_grpc}  IN RANGE  0  2
		Log To Console	external command CHANGE_MAX_SVC_CHECK_ATTEMPTS on bbdo3.0 use_grpc=${use_grpc}
		Clear Retention
		${start}=	Get Current Date
		Start Broker
		Start Engine
			${content}=	Create List	INITIAL SERVICE STATE: host_1;service_1;
			${result}=	Find In Log with Timeout	${logEngine0}	${start}	${content}	60
			Should Be True	${result}	msg=An Initial host state on host_1 should be raised before we can start our external commands.
		Change Max Svc Check Attempts  ${use_grpc}  host_1	service_1	15

		Connect To Database	pymysql	${DBName}	${DBUser}	${DBPass}	${DBHost}	${DBPort}

		FOR	${index}	IN RANGE	30
			Log To Console	select s.max_check_attempts from services s,hosts h where s.description='service_1' and h.name='host_1' 
			${output}=	Query	select s.max_check_attempts from services s,hosts h where s.description='service_1' and h.name='host_1'
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((15,),)"
		END
		Should Be Equal As Strings	${output}	((15,),)

		FOR	${index}	IN RANGE	30
			Log To Console	select max_check_attempts from resources where name='service_1' and parent_name='host_1' 
			${output}=	Query	select max_check_attempts from resources where name='service_1' and parent_name='host_1'
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((15,),)"
		END
		Should Be Equal As Strings	${output}	((15,),)
		Stop Engine
		Kindly Stop Broker
	END

BEEXTCMD10
	[Documentation]	external command CHANGE_MAX_SVC_CHECK_ATTEMPTS on bbdo2.0
	[Tags]	Broker	Engine	services	extcmd
	Config Engine	${1}	${50}	${20}
	Config Broker	rrd
	Config Broker	central
	Config Broker	module	${1}
	Broker Config Log	central	sql	debug
	FOR  ${use_grpc}  IN RANGE  0  2
		Log To Console	external command CHANGE_MAX_SVC_CHECK_ATTEMPTS on bbdo2.0 use_grpc=${use_grpc}
		Clear Retention
		${start}=	Get Current Date
		Start Broker
		Start Engine
			${content}=	Create List	INITIAL SERVICE STATE: host_1;service_1;
			${result}=	Find In Log with Timeout	${logEngine0}	${start}	${content}	60
			Should Be True	${result}	msg=An Initial host state on host_1 should be raised before we can start our external commands.
		Change Max Svc Check Attempts  ${use_grpc}  host_1	service_1	10

		Connect To Database	pymysql	${DBName}	${DBUser}	${DBPass}	${DBHost}	${DBPort}

		FOR	${index}	IN RANGE	30
			Log To Console	select s.max_check_attempts from services s,hosts h where s.description='service_1' and h.name='host_1' 
			${output}=	Query	select s.max_check_attempts from services s,hosts h where s.description='service_1' and h.name='host_1'
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((10,),)"
		END
		Should Be Equal As Strings	${output}	((10,),)
		Stop Engine
		Kindly Stop Broker
	END

BEEXTCMD11
	[Documentation]	external command CHANGE_MAX_HOST_CHECK_ATTEMPTS on bbdo3.0
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
	FOR  ${use_grpc}  IN RANGE  0  2
		Log To Console	external command CHANGE_MAX_HOST_CHECK_ATTEMPTS on bbdo3.0 use_grpc=${use_grpc}
		Clear Retention
		${start}=	Get Current Date
		Start Broker
		Start Engine
			${content}=	Create List	INITIAL SERVICE STATE: host_1;service_1;
			${result}=	Find In Log with Timeout	${logEngine0}	${start}	${content}	60
			Should Be True	${result}	msg=An Initial host state on host_1 should be raised before we can start our external commands.
		Change Max Host Check Attempts  ${use_grpc}  host_1	15

		Connect To Database	pymysql	${DBName}	${DBUser}	${DBPass}	${DBHost}	${DBPort}

		FOR	${index}	IN RANGE	30
			Log To Console	select max_check_attempts from hosts where name='host_1' 
			${output}=	Query	select max_check_attempts from hosts where name='host_1' 
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((15,),)"
		END
		Should Be Equal As Strings	${output}	((15,),)

		FOR	${index}	IN RANGE	30
			Log To Console	select max_check_attempts from resources where name='host_1' 
			${output}=	Query	select max_check_attempts from resources where name='host_1' 
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((15,),)"
		END
		Should Be Equal As Strings	${output}	((15,),)
		Stop Engine
		Kindly Stop Broker
	END

BEEXTCMD12
	[Documentation]	external command CHANGE_MAX_HOST_CHECK_ATTEMPTS on bbdo2.0
	[Tags]	Broker	Engine	host	extcmd
	Config Engine	${1}	${50}	${20}
	Config Broker	rrd
	Config Broker	central
	Config Broker	module	${1}
	Broker Config Log	central	core	error
	Broker Config Log	central	sql	debug
	FOR  ${use_grpc}  IN RANGE  0  2
		Log To Console	external command CHANGE_MAX_HOST_CHECK_ATTEMPTS on bbdo2.0 use_grpc=${use_grpc}
		Clear Retention
		${start}=	Get Current Date
		Start Broker
		Start Engine
			${content}=	Create List	INITIAL SERVICE STATE: host_1;service_1;
			${result}=	Find In Log with Timeout	${logEngine0}	${start}	${content}	60
			Should Be True	${result}	msg=An Initial host state on host_1 should be raised before we can start our external commands.
		Change Max Host Check Attempts  ${use_grpc}  host_1  10

		Connect To Database	pymysql	${DBName}	${DBUser}	${DBPass}	${DBHost}	${DBPort}

		FOR	${index}	IN RANGE	30
			Log To Console	select max_check_attempts from hosts where name='host_1' 
			${output}=	Query	select max_check_attempts from hosts where name='host_1' 
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((10,),)"
		END
		Should Be Equal As Strings	${output}	((10,),)

		Stop Engine
		Kindly Stop Broker
	END

BEEXTCMD13
	[Documentation]	external command CHANGE_HOST_CHECK_TIMEPERIOD on bbdo3.0
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
	FOR  ${use_grpc}  IN RANGE  0  2
		Log To Console	external command CHANGE_HOST_CHECK_TIMEPERIOD on bbdo3.0 use_grpc=${use_grpc}
		Clear Retention
		${start}=	Get Current Date
		Start Broker
		Start Engine
			${content}=	Create List	INITIAL SERVICE STATE: host_1;service_1;
			${result}=	Find In Log with Timeout	${logEngine0}	${start}	${content}	60
			Should Be True	${result}	msg=An Initial host state on host_1 should be raised before we can start our external commands.
		Change Host Check Timeperiod  ${use_grpc}  host_1	24x6

		Connect To Database	pymysql	${DBName}	${DBUser}	${DBPass}	${DBHost}	${DBPort}

		FOR	${index}	IN RANGE	30
			Log To Console	select check_period from hosts where name='host_1' 
			${output}=	Query	select check_period from hosts where name='host_1' 
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "(('24x6',),)"
		END
		Should Be Equal As Strings	${output}	(('24x6',),)

		Stop Engine
		Kindly Stop Broker
	END

BEEXTCMD14
	[Documentation]	external command CHANGE_HOST_CHECK_TIMEPERIOD on bbdo2.0
	[Tags]	Broker	Engine	host	extcmd
	Config Engine	${1}	${50}	${20}
	Config Broker	rrd
	Config Broker	central
	Config Broker	module	${1}
	Broker Config Log	central	core	error
	Broker Config Log	central	sql	debug
	FOR  ${use_grpc}  IN RANGE  0  2
		Log To Console	external command CHANGE_HOST_CHECK_TIMEPERIOD on bbdo2.0 use_grpc=${use_grpc}
		Clear Retention
		${start}=	Get Current Date
		Start Broker
		Start Engine
			${content}=	Create List	INITIAL SERVICE STATE: host_1;service_1;
			${result}=	Find In Log with Timeout	${logEngine0}	${start}	${content}	60
			Should Be True	${result}	msg=An Initial host state on host_1 should be raised before we can start our external commands.
		Change Host Check Timeperiod  ${use_grpc}  host_1	24x6

		Connect To Database	pymysql	${DBName}	${DBUser}	${DBPass}	${DBHost}	${DBPort}

		FOR	${index}	IN RANGE	30
			Log To Console	select check_period from hosts where name='host_1' 
			${output}=	Query	select check_period from hosts where name='host_1' 
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "(('24x6',),)"
		END
		Should Be Equal As Strings	${output}	(('24x6',),)

		Stop Engine
		Kindly Stop Broker
	END

BEEXTCMD15
	[Documentation]	external command CHANGE_HOST_NOTIFICATION_TIMEPERIOD on bbdo3.0
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
	FOR  ${use_grpc}  IN RANGE  0  2
		Log To Console	external command CHANGE_HOST_NOTIFICATION_TIMEPERIOD on bbdo3.0 use_grpc=${use_grpc}
		Clear Retention
		${start}=	Get Current Date
		Start Broker
		Start Engine
			${content}=	Create List	INITIAL SERVICE STATE: host_1;service_1;
			${result}=	Find In Log with Timeout	${logEngine0}	${start}	${content}	60
			Should Be True	${result}	msg=An Initial host state on host_1 should be raised before we can start our external commands.
		Change Host Notification Timeperiod  ${use_grpc}  host_1	24x7

		Connect To Database	pymysql	${DBName}	${DBUser}	${DBPass}	${DBHost}	${DBPort}

		FOR	${index}	IN RANGE	30
			Log To Console	select notification_period from hosts where name='host_1' 
			${output}=	Query	select notification_period from hosts where name='host_1' 
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "(('24x7',),)"
		END
		Should Be Equal As Strings	${output}	(('24x7',),)

		Stop Engine
		Kindly Stop Broker
	END

BEEXTCMD16
	[Documentation]	external command CHANGE_HOST_NOTIFICATION_TIMEPERIOD on bbdo2.0
	[Tags]	Broker	Engine	host	extcmd
	Config Engine	${1}	${50}	${20}
	Config Broker	rrd
	Config Broker	central
	Config Broker	module	${1}
	Broker Config Log	central	core	error
	Broker Config Log	central	sql	debug
	FOR  ${use_grpc}  IN RANGE  0  2
		Log To Console	external command CHANGE_HOST_NOTIFICATION_TIMEPERIOD on bbdo2.0 use_grpc=${use_grpc}
		Clear Retention
		${start}=	Get Current Date
		Start Broker
		Start Engine
		${content}=	Create List	INITIAL SERVICE STATE: host_1;service_1;
		${result}=	Find In Log with Timeout	${logEngine0}	${start}	${content}	60
		Should Be True	${result}	msg=An Initial host state on host_1 should be raised before we can start our external commands.
		Change Host Notification Timeperiod  ${use_grpc}  host_1	24x6

		Connect To Database	pymysql	${DBName}	${DBUser}	${DBPass}	${DBHost}	${DBPort}

		FOR	${index}	IN RANGE	30
			Log To Console	select notification_period from hosts where name='host_1' 
			${output}=	Query	select notification_period from hosts where name='host_1' 
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "(('24x6',),)"
		END
		Should Be Equal As Strings	${output}	(('24x6',),)

		Stop Engine
		Kindly Stop Broker
	END

BEEXTCMD17
	[Documentation]	external command CHANGE_SVC_CHECK_TIMEPERIOD on bbdo3.0
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
	FOR  ${use_grpc}  IN RANGE  0  2
		Log To Console	external command CHANGE_SVC_CHECK_TIMEPERIOD on bbdo3.0 use_grpc=${use_grpc}
		Clear Retention
		${start}=	Get Current Date
		Start Broker
		Start Engine
		${content}=	Create List	INITIAL SERVICE STATE: host_1;service_1;
		${result}=	Find In Log with Timeout	${logEngine0}	${start}	${content}	60
		Should Be True	${result}	msg=An Initial host state on host_1 should be raised before we can start our external commands.
		Change Svc Check Timeperiod  ${use_grpc}  host_1	service_1	24x6

		Connect To Database	pymysql	${DBName}	${DBUser}	${DBPass}	${DBHost}	${DBPort}

		FOR	${index}	IN RANGE	30
			Log To Console	select s.check_period from services s,hosts h where s.description='service_1' and h.name='host_1'
			${output}=	Query	select s.check_period from services s,hosts h where s.description='service_1' and h.name='host_1' 
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "(('24x6',),)"
		END
		Should Be Equal As Strings	${output}	(('24x6',),)

		Stop Engine
		Kindly Stop Broker
	END

BEEXTCMD18
	[Documentation]	external command CHANGE_SVC_CHECK_TIMEPERIOD on bbdo2.0
	[Tags]	Broker	Engine	host	extcmd
	Config Engine	${1}	${50}	${20}
	Config Broker	rrd
	Config Broker	central
	Config Broker	module	${1}
	Broker Config Log	central	core	error
	Broker Config Log	central	sql	debug
	FOR  ${use_grpc}  IN RANGE  0  2
		Log To Console	external command CHANGE_SVC_CHECK_TIMEPERIOD on bbdo2.0 use_grpc=${use_grpc}
		Clear Retention
		${start}=	Get Current Date
		Start Broker
		Start Engine
		${content}=	Create List	INITIAL SERVICE STATE: host_1;service_1;
		${result}=	Find In Log with Timeout	${logEngine0}	${start}	${content}	60
		Should Be True	${result}	msg=An Initial host state on host_1 should be raised before we can start our external commands.
		Change Svc Check Timeperiod  ${use_grpc}  host_1	service_1	24x7

		Connect To Database	pymysql	${DBName}	${DBUser}	${DBPass}	${DBHost}	${DBPort}

		FOR	${index}	IN RANGE	30
			Log To Console	select s.check_period from services s,hosts h where s.description='service_1' and h.name='host_1'
			${output}=	Query	select s.check_period from services s,hosts h where s.description='service_1' and h.name='host_1' 
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "(('24x7',),)"
		END
		Should Be Equal As Strings	${output}	(('24x7',),)

		Stop Engine
		Kindly Stop Broker
	END

BEEXTCMD19
	[Documentation]	external command CHANGE_SVC_NOTIFICATION_TIMEPERIOD on bbdo3.0
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
	FOR  ${use_grpc}  IN RANGE  0  2
		Log To Console	external command CHANGE_SVC_NOTIFICATION_TIMEPERIOD on bbdo3.0 use_grpc=${use_grpc}
		Clear Retention
		${start}=	Get Current Date
		Start Broker
		Start Engine
		${content}=	Create List	INITIAL SERVICE STATE: host_1;service_1;
		${result}=	Find In Log with Timeout	${logEngine0}	${start}	${content}	60
		Should Be True	${result}	msg=An Initial host state on host_1 should be raised before we can start our external commands.
		Change Svc Notification Timeperiod  ${use_grpc}  host_1	service_1	24x7

		Connect To Database	pymysql	${DBName}	${DBUser}	${DBPass}	${DBHost}	${DBPort}

		FOR	${index}	IN RANGE	30
			Log To Console	select s.notification_period from services s,hosts h where s.description='service_1' and h.name='host_1'
			${output}=	Query	select s.notification_period from services s,hosts h where s.description='service_1' and h.name='host_1'
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "(('24x7',),)"
		END
		Should Be Equal As Strings	${output}	(('24x7',),)

		Stop Engine
		Kindly Stop Broker
	END

BEEXTCMD20
	[Documentation]	external command CHANGE_SVC_NOTIFICATION_TIMEPERIOD on bbdo2.0
	[Tags]	Broker	Engine	host	extcmd
	Config Engine	${1}	${50}	${20}
	Config Broker	rrd
	Config Broker	central
	Config Broker	module	${1}
	Broker Config Log	central	core	error
	Broker Config Log	central	sql	debug
	FOR  ${use_grpc}  IN RANGE  0  2
		Log To Console	external command CHANGE_SVC_NOTIFICATION_TIMEPERIOD on bbdo2.0 use_grpc=${use_grpc}
		Clear Retention
		${start}=	Get Current Date
		Start Broker
		Start Engine
		${content}=	Create List	INITIAL SERVICE STATE: host_1;service_1;
		${result}=	Find In Log with Timeout	${logEngine0}	${start}	${content}	60
		Should Be True	${result}	msg=An Initial host state on host_1 should be raised before we can start our external commands.
		Change Svc Notification Timeperiod  ${use_grpc}  host_1	service_1	24x6

		Connect To Database	pymysql	${DBName}	${DBUser}	${DBPass}	${DBHost}	${DBPort}

		FOR	${index}	IN RANGE	30
			Log To Console	select s.notification_period from services s,hosts h where s.description='service_1' and h.name='host_1' 
			${output}=	Query	select s.notification_period from services s,hosts h where s.description='service_1' and h.name='host_1' 
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "(('24x6',),)"
		END
		Should Be Equal As Strings	${output}	(('24x6',),)

		Stop Engine
		Kindly Stop Broker
	END

BEEXTCMD21
	[Documentation]	external command DISABLE_HOST_AND_CHILD_NOTIFICATIONS and ENABLE_HOST_AND_CHILD_NOTIFICATIONS on bbdo3.0
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
	FOR	${use_grpc}	IN RANGE	0  2
		Log To Console	external command DISABLE_HOST_AND_CHILD_NOTIFICATIONS and ENABLE_HOST_AND_CHILD_NOTIFICATIONS on bbdo3.0 use_grpc=${use_grpc}
		${start}=	Get Current Date
		Start Broker
		Start Engine
		${content}=	Create List	INITIAL SERVICE STATE: host_1;service_1;
		${result}=	Find In Log with Timeout	${logEngine0}	${start}	${content}	60
		Should Be True	${result}	msg=An Initial host state on host_1 should be raised before we can start our external commands.
		Disable Host And child Notifications	${use_grpc}	host_1

		Connect To Database	pymysql	${DBName}	${DBUser}	${DBPass}	${DBHost}	${DBPort}

		FOR	${index}	IN RANGE	30
			Log To Console	select notify from hosts where name='host_1' 
			${output}=	Query	select notify from hosts where name='host_1'  
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((0,),)"
		END
		Should Be Equal As Strings	${output}	((0,),)

		FOR	${index}	IN RANGE	30
			Log To Console	select notifications_enabled from resources where name='host_1' 
			${output}=	Query	select notifications_enabled from resources where name='host_1' 
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((0,),)"
		END
		Should Be Equal As Strings	${output}	((0,),)

		Enable Host And child Notifications	${use_grpc}	host_1

		FOR	${index}	IN RANGE	30
			Log To Console	select notify from hosts where name='host_1' 
			${output}=	Query	select notify from hosts where name='host_1'  
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((1,),)"
		END
		Should Be Equal As Strings	${output}	((1,),)

		FOR	${index}	IN RANGE	30
			Log To Console	select notifications_enabled from resources where name='host_1' 
			${output}=	Query	select notifications_enabled from resources where name='host_1' 
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((1,),)"
		END
		Should Be Equal As Strings	${output}	((1,),)

		Stop Engine
		Kindly Stop Broker
	END

BEEXTCMD22
	[Documentation]	external command DISABLE_HOST_AND_CHILD_NOTIFICATIONS and ENABLE_HOST_AND_CHILD_NOTIFICATIONS on bbdo2.0
	[Tags]	Broker	Engine	host	extcmd
	Config Engine	${1}	${50}	${20}
	Config Broker	rrd
	Config Broker	central
	Config Broker	module	${1}
	Broker Config Log	central	core	error
	Broker Config Log	central	sql	debug
	Clear Retention
	FOR	${use_grpc}	IN RANGE	0  2
		Log To Console	external command DISABLE_HOST_AND_CHILD_NOTIFICATIONS and ENABLE_HOST_AND_CHILD_NOTIFICATIONS on bbdo2.0 use_grpc=${use_grpc}
		${start}=	Get Current Date
		Start Broker
		Start Engine
		${content}=	Create List	INITIAL SERVICE STATE: host_1;service_1;
		${result}=	Find In Log with Timeout	${logEngine0}	${start}	${content}	60
		Should Be True	${result}	msg=An Initial host state on host_1 should be raised before we can start our external commands.
		Disable Host And child Notifications	${use_grpc}	host_1

		Connect To Database	pymysql	${DBName}	${DBUser}	${DBPass}	${DBHost}	${DBPort}

		FOR	${index}	IN RANGE	30
			Log To Console	select notify from hosts where name='host_1' 
			${output}=	Query	select notify from hosts where name='host_1'  
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((0,),)"
		END
		Should Be Equal As Strings	${output}	((0,),)

		Enable Host And child Notifications	${use_grpc}	host_1

		FOR	${index}	IN RANGE	30
			Log To Console	select notify from hosts where name='host_1' 
			${output}=	Query	select notify from hosts where name='host_1'  
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((1,),)"
		END
		Should Be Equal As Strings	${output}	((1,),)

		Stop Engine
		Kindly Stop Broker
	END

BEEXTCMD23
	[Documentation]	external command DISABLE_HOST_CHECK and ENABLE_HOST_CHECK on bbdo3.0
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
		${content}=	Create List	INITIAL SERVICE STATE: host_1;service_1;
		${result}=	Find In Log with Timeout	${logEngine0}	${start}	${content}	60
		Should Be True	${result}	msg=An Initial host state on host_1 should be raised before we can start our external commands.
		Disable Host Check	${use_grpc}	host_1

		Connect To Database	pymysql	${DBName}	${DBUser}	${DBPass}	${DBHost}	${DBPort}

		FOR	${index}	IN RANGE	30
			Log To Console	select active_checks from hosts where name='host_1' 
			${output}=	Query	select active_checks from hosts where name='host_1'  
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((0,),)"
		END
		Should Be Equal As Strings	${output}	((0,),)

		FOR	${index}	IN RANGE	30
			Log To Console	select active_checks_enabled from resources where name='host_1' 
			${output}=	Query	select active_checks_enabled from resources where name='host_1' 
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((0,),)"
		END
		Should Be Equal As Strings	${output}	((0,),)

		FOR	${index}	IN RANGE	30
			Log To Console	select should_be_scheduled from hosts where name='host_1' 
			${output}=	Query	select should_be_scheduled from hosts where name='host_1'  
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((0,),)"
		END
		Should Be Equal As Strings	${output}	((0,),)

		Enable Host Check	${use_grpc}	host_1

		FOR	${index}	IN RANGE	30
			Log To Console	select active_checks from hosts where name='host_1' 
			${output}=	Query	select active_checks from hosts where name='host_1'  
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((1,),)"
		END
		Should Be Equal As Strings	${output}	((1,),)

		FOR	${index}	IN RANGE	30
			Log To Console	select active_checks_enabled from resources where name='host_1' 
			${output}=	Query	select active_checks_enabled from resources where name='host_1' 
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((1,),)"
		END
		Should Be Equal As Strings	${output}	((1,),)

		FOR	${index}	IN RANGE	30
			Log To Console	select should_be_scheduled from hosts where name='host_1' 
			${output}=	Query	select should_be_scheduled from hosts where name='host_1'  
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((1,),)"
		END
		Should Be Equal As Strings	${output}	((1,),)
		Stop Engine
		Kindly Stop Broker
	END

BEEXTCMD24
	[Documentation]	external command DISABLE_HOST_CHECK and ENABLE_HOST_CHECK on bbdo2.0
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
		${content}=	Create List	INITIAL SERVICE STATE: host_1;service_1;
		${result}=	Find In Log with Timeout	${logEngine0}	${start}	${content}	60
		Should Be True	${result}	msg=An Initial host state on host_1 should be raised before we can start our external commands.
		Disable Host Check	${use_grpc}	host_1

		Connect To Database	pymysql	${DBName}	${DBUser}	${DBPass}	${DBHost}	${DBPort}

		FOR	${index}	IN RANGE	30
			Log To Console	select active_checks from hosts where name='host_1' 
			${output}=	Query	select active_checks from hosts where name='host_1'  
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((0,),)"
		END
		Should Be Equal As Strings	${output}	((0,),)

		FOR	${index}	IN RANGE	30
			Log To Console	select should_be_scheduled from hosts where name='host_1' 
			${output}=	Query	select should_be_scheduled from hosts where name='host_1'  
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((0,),)"
		END
		Should Be Equal As Strings	${output}	((0,),)

		Enable Host Check	${use_grpc}	host_1

		FOR	${index}	IN RANGE	30
			Log To Console	select active_checks from hosts where name='host_1' 
			${output}=	Query	select active_checks from hosts where name='host_1'  
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((1,),)"
		END
		Should Be Equal As Strings	${output}	((1,),)

		FOR	${index}	IN RANGE	30
			Log To Console	select should_be_scheduled from hosts where name='host_1' 
			${output}=	Query	select should_be_scheduled from hosts where name='host_1'  
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((1,),)"
		END
		Should Be Equal As Strings	${output}	((1,),)

		Stop Engine
		Kindly Stop Broker
	END

BEEXTCMD25
	[Documentation]	external command DISABLE_HOST_EVENT_HANDLER and ENABLE_HOST_EVENT_HANDLER on bbdo3.0
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
	FOR	${use_grpc}	IN RANGE	0  1
		Clear Retention
		${start}=	Get Current Date
		Start Broker
		Start Engine
		${content}=	Create List	INITIAL SERVICE STATE: host_1;service_1;
		${result}=	Find In Log with Timeout	${logEngine0}	${start}	${content}	60
		Should Be True	${result}	msg=An Initial host state on host_1 should be raised before we can start our external commands.
		Disable Host Event Handler	${use_grpc}	host_1

		Connect To Database	pymysql	${DBName}	${DBUser}	${DBPass}	${DBHost}	${DBPort}

		FOR	${index}	IN RANGE	30
			Log To Console	select event_handler_enabled from hosts where name='host_1' 
			${output}=	Query	select event_handler_enabled from hosts where name='host_1'  
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((0,),)"
		END
		Should Be Equal As Strings	${output}	((0,),)

		Enable Host Event Handler	${use_grpc}	host_1
		
		FOR	${index}	IN RANGE	30
			Log To Console	select event_handler_enabled from hosts where name='host_1' 
			${output}=	Query	select event_handler_enabled from hosts where name='host_1'  
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((1,),)"
		END
		Should Be Equal As Strings	${output}	((1,),)

		Stop Engine
		Kindly Stop Broker
	END

BEEXTCMD26
	[Documentation]	external command DISABLE_HOST_EVENT_HANDLER and ENABLE_HOST_EVENT_HANDLER on bbdo2.0
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
		${content}=	Create List	INITIAL SERVICE STATE: host_1;service_1;
		${result}=	Find In Log with Timeout	${logEngine0}	${start}	${content}	60
		Should Be True	${result}	msg=An Initial host state on host_1 should be raised before we can start our external commands.
		Disable Host Event Handler	${use_grpc}	host_1

		Connect To Database	pymysql	${DBName}	${DBUser}	${DBPass}	${DBHost}	${DBPort}

		FOR	${index}	IN RANGE	30
			Log To Console	select event_handler_enabled from hosts where name='host_1' 
			${output}=	Query	select event_handler_enabled from hosts where name='host_1'  
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((0,),)"
		END
		Should Be Equal As Strings	${output}	((0,),)
		
		Enable Host Event Handler	${use_grpc}	host_1
		
		FOR	${index}	IN RANGE	30
			Log To Console	select event_handler_enabled from hosts where name='host_1' 
			${output}=	Query	select event_handler_enabled from hosts where name='host_1'  
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((1,),)"
		END
		Should Be Equal As Strings	${output}	((1,),)

		Stop Engine
		Kindly Stop Broker
	END

BEEXTCMD27
	[Documentation]	external command DISABLE_HOST_FLAP_DETECTION and ENABLE_HOST_FLAP_DETECTION on bbdo3.0
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
		${content}=	Create List	INITIAL SERVICE STATE: host_1;service_1;
		${result}=	Find In Log with Timeout	${logEngine0}	${start}	${content}	60
		Should Be True	${result}	msg=An Initial host state on host_1 should be raised before we can start our external commands.
		Disable Host Flap Detection	${use_grpc}	host_1

		Connect To Database	pymysql	${DBName}	${DBUser}	${DBPass}	${DBHost}	${DBPort}

		FOR	${index}	IN RANGE	30
			Log To Console	select flap_detection from hosts where name='host_1' 
			${output}=	Query	select flap_detection from hosts where name='host_1'  
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((0,),)"
		END
		Should Be Equal As Strings	${output}	((0,),)

		Enable Host Flap Detection	${use_grpc}	host_1

		FOR	${index}	IN RANGE	30
			Log To Console	select flap_detection from hosts where name='host_1' 
			${output}=	Query	select flap_detection from hosts where name='host_1'  
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((1,),)"
		END
		Should Be Equal As Strings	${output}	((1,),)

		Stop Engine
		Kindly Stop Broker
	END

BEEXTCMD28
	[Documentation]	external command DISABLE_HOST_FLAP_DETECTION and ENABLE_HOST_FLAP_DETECTION on bbdo2.0
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
		${content}=	Create List	INITIAL SERVICE STATE: host_1;service_1;
		${result}=	Find In Log with Timeout	${logEngine0}	${start}	${content}	60
		Should Be True	${result}	msg=An Initial host state on host_1 should be raised before we can start our external commands.
		Disable Host Flap detection	${use_grpc}	host_1

		Connect To Database	pymysql	${DBName}	${DBUser}	${DBPass}	${DBHost}	${DBPort}

		FOR	${index}	IN RANGE	30
			Log To Console	select flap_detection from hosts where name='host_1' 
			${output}=	Query	select flap_detection from hosts where name='host_1'  
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((0,),)"
		END
		Should Be Equal As Strings	${output}	((0,),)

		Enable Host Flap Detection	${use_grpc}	host_1

		FOR	${index}	IN RANGE	30
			Log To Console	select flap_detection from hosts where name='host_1' 
			${output}=	Query	select flap_detection from hosts where name='host_1'  
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((1,),)"
		END
		Should Be Equal As Strings	${output}	((1,),)

		Stop Engine
		Kindly Stop Broker
	END

BEEXTCMD29
	[Documentation]	external command DISABLE_HOST_NOTIFICATIONS and ENABLE_HOST_NOTIFICATIONS on bbdo3.0
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
	FOR	${use_grpc}	IN RANGE	0  2
		Log To Console	external command DISABLE_HOST_NOTIFICATIONS and ENABLE_HOST_NOTIFICATIONS on bbdo3.0 use_grpc=${use_grpc}
		Clear Retention
		${start}=	Get Current Date
		Start Broker
		Start Engine
		${content}=	Create List	INITIAL SERVICE STATE: host_1;service_1;
		${result}=	Find In Log with Timeout	${logEngine0}	${start}	${content}	60
		Should Be True	${result}	msg=An Initial host state on host_1 should be raised before we can start our external commands.
		Disable Host Notifications	${use_grpc}	host_1

		Connect To Database	pymysql	${DBName}	${DBUser}	${DBPass}	${DBHost}	${DBPort}

		FOR	${index}	IN RANGE	30
			Log To Console	select notify from hosts where name='host_1' 
			${output}=	Query	select notify from hosts where name='host_1'  
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((0,),)"
		END
		Should Be Equal As Strings	${output}	((0,),)

		FOR	${index}	IN RANGE	30
			Log To Console	select notifications_enabled from resources where name='host_1' 
			${output}=	Query	select notifications_enabled from resources where name='host_1' 
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((0,),)"
		END
		Should Be Equal As Strings	${output}	((0,),)

		Enable Host Notifications	${use_grpc}	host_1

		FOR	${index}	IN RANGE	30
			Log To Console	select notify from hosts where name='host_1' 
			${output}=	Query	select notify from hosts where name='host_1'  
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((1,),)"
		END
		Should Be Equal As Strings	${output}	((1,),)

		FOR	${index}	IN RANGE	30
			Log To Console	select notifications_enabled from resources where name='host_1' 
			${output}=	Query	select notifications_enabled from resources where name='host_1' 
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((1,),)"
		END
		Should Be Equal As Strings	${output}	((1,),)

		Stop Engine
		Kindly Stop Broker
	END

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
		${content}=	Create List	INITIAL SERVICE STATE: host_1;service_1;
		${result}=	Find In Log with Timeout	${logEngine0}	${start}	${content}	60
		Should Be True	${result}	msg=An Initial host state on host_1 should be raised before we can start our external commands.
		Disable Host Notifications	${use_grpc}	host_1

		Connect To Database	pymysql	${DBName}	${DBUser}	${DBPass}	${DBHost}	${DBPort}

		FOR	${index}	IN RANGE	30
			Log To Console	select notify from hosts where name='host_1' 
			${output}=	Query	select notify from hosts where name='host_1'  
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((0,),)"
		END
		Should Be Equal As Strings	${output}	((0,),)

		Enable Host Notifications	${use_grpc}	host_1

		FOR	${index}	IN RANGE	30
			Log To Console	select notify from hosts where name='host_1' 
			${output}=	Query	select notify from hosts where name='host_1'  
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
		${content}=	Create List	INITIAL SERVICE STATE: host_1;service_1;
		${result}=	Find In Log with Timeout	${logEngine0}	${start}	${content}	60
		Should Be True	${result}	msg=An Initial host state on host_1 should be raised before we can start our external commands.
		Disable Host Svc Checks	${use_grpc}	host_1

		Connect To Database	pymysql	${DBName}	${DBUser}	${DBPass}	${DBHost}	${DBPort}

		FOR	${index}	IN RANGE	30
			Log To Console	select s.active_checks from services s,hosts h where s.description='service_1' and h.name='host_1' 
			${output}=	Query	select s.active_checks from services s,hosts h where s.description='service_1' and h.name='host_1'  
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((0,),)"
		END
		Should Be Equal As Strings	${output}	((0,),)

		FOR	${index}	IN RANGE	30
			Log To Console	select active_checks_enabled from resources where name='service_1' 
			${output}=	Query	select active_checks_enabled from resources where name='service_1' 
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((0,),)"
		END
		Should Be Equal As Strings	${output}	((0,),)

		FOR	${index}	IN RANGE	30
			Log To Console	select s.should_be_scheduled from services s,hosts h where s.description='service_1' and h.name='host_1' 
			${output}=	Query	select s.should_be_scheduled from services s,hosts h where s.description='service_1' and h.name='host_1'  
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((0,),)"
		END
		Should Be Equal As Strings	${output}	((0,),)

		Enable Host Svc Checks	${use_grpc}	host_1

		FOR	${index}	IN RANGE	30
			Log To Console	select s.active_checks from services s,hosts h where s.description='service_1' and h.name='host_1' 
			${output}=	Query	select s.active_checks from services s,hosts h where s.description='service_1' and h.name='host_1'  
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((1,),)"
		END
		Should Be Equal As Strings	${output}	((1,),)

		FOR	${index}	IN RANGE	30
			Log To Console	select active_checks_enabled from resources where name='service_1' 
			${output}=	Query	select active_checks_enabled from resources where name='service_1' 
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((1,),)"
		END
		Should Be Equal As Strings	${output}	((1,),)

		FOR	${index}	IN RANGE	30
			Log To Console	select s.should_be_scheduled from services s,hosts h where s.description='service_1' and h.name='host_1' 
			${output}=	Query	select s.should_be_scheduled from services s,hosts h where s.description='service_1' and h.name='host_1'  
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
		${content}=	Create List	INITIAL SERVICE STATE: host_1;service_1;
		${result}=	Find In Log with Timeout	${logEngine0}	${start}	${content}	60
		Should Be True	${result}	msg=An Initial host state on host_1 should be raised before we can start our external commands.
		Disable Host Svc Checks	${use_grpc}	host_1

		Connect To Database	pymysql	${DBName}	${DBUser}	${DBPass}	${DBHost}	${DBPort}

		FOR	${index}	IN RANGE	30
			Log To Console	select s.s.active_checks from services s,hosts h where s.description='service_1' and h.name='host_1' 
			${output}=	Query	select s.active_checks from services s,hosts h where s.description='service_1' and h.name='host_1'  
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((0,),)"
		END
		Should Be Equal As Strings	${output}	((0,),)

		FOR	${index}	IN RANGE	30
			Log To Console	select s.should_be_scheduled from services s,hosts h where s.description='service_1' and h.name='host_1' 
			${output}=	Query	select s.should_be_scheduled from services s,hosts h where s.description='service_1' and h.name='host_1'  
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((0,),)"
		END
		Should Be Equal As Strings	${output}	((0,),)

		Enable Host Svc Checks	${use_grpc}	host_1

		FOR	${index}	IN RANGE	30
			Log To Console	select s.active_checks from services s,hosts h where s.description='service_1' and h.name='host_1' 
			${output}=	Query	select s.active_checks from services s,hosts h where s.description='service_1' and h.name='host_1'  
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((1,),)"
		END
		Should Be Equal As Strings	${output}	((1,),)

		FOR	${index}	IN RANGE	30
			Log To Console	select s.should_be_scheduled from services s,hosts h where s.description='service_1' and h.name='host_1' 
			${output}=	Query	select s.should_be_scheduled from services s,hosts h where s.description='service_1' and h.name='host_1'  
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
		${content}=	Create List	INITIAL SERVICE STATE: host_1;service_1;
		${result}=	Find In Log with Timeout	${logEngine0}	${start}	${content}	60
		Should Be True	${result}	msg=An Initial host state on host_1 should be raised before we can start our external commands.
		Disable Host Svc Notifications	${use_grpc}	host_1

		Connect To Database	pymysql	${DBName}	${DBUser}	${DBPass}	${DBHost}	${DBPort}

		FOR	${index}	IN RANGE	30
			Log To Console	select s.notify from services s,hosts h where s.description='service_1' and h.name='host_1' 
			${output}=	Query	select s.notify from services s,hosts h where s.description='service_1' and h.name='host_1'  
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((0,),)"
		END
		Should Be Equal As Strings	${output}	((0,),)

		Enable Host Svc Notifications	${use_grpc}	host_1
		
		FOR	${index}	IN RANGE	30
			Log To Console	select s.notify from services s,hosts h where s.description='service_1' and h.name='host_1' 
			${output}=	Query	select s.notify from services s,hosts h where s.description='service_1' and h.name='host_1'  
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
		${content}=	Create List	INITIAL SERVICE STATE: host_1;service_1;
		${result}=	Find In Log with Timeout	${logEngine0}	${start}	${content}	60
		Should Be True	${result}	msg=An Initial host state on host_1 should be raised before we can start our external commands.
		Disable Host Svc Notifications	${use_grpc}	host_1

		Connect To Database	pymysql	${DBName}	${DBUser}	${DBPass}	${DBHost}	${DBPort}

		FOR	${index}	IN RANGE	30
			Log To Console	select s.notify from services s,hosts h where s.description='service_1' and h.name='host_1' 
			${output}=	Query	select s.notify from services s,hosts h where s.description='service_1' and h.name='host_1'  
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((0,),)"
		END
		Should Be Equal As Strings	${output}	((0,),)
		
		Enable Host Svc Notifications	${use_grpc}	host_1
		
		FOR	${index}	IN RANGE	30
			Log To Console	select s.notify from services s,hosts h where s.description='service_1' and h.name='host_1' 
			${output}=	Query	select s.notify from services s,hosts h where s.description='service_1' and h.name='host_1'  
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
		${content}=	Create List	INITIAL SERVICE STATE: host_1;service_1;
		${result}=	Find In Log with Timeout	${logEngine0}	${start}	${content}	60
		Should Be True	${result}	msg=An Initial host state on host_1 should be raised before we can start our external commands.
		Disable Passive Host Checks	${use_grpc}	host_1

		Connect To Database	pymysql	${DBName}	${DBUser}	${DBPass}	${DBHost}	${DBPort}

		FOR	${index}	IN RANGE	30
			Log To Console	select passive_checks from hosts where name='host_1' 
			${output}=	Query	select passive_checks from hosts where name='host_1'  
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((0,),)"
		END
		Should Be Equal As Strings	${output}	((0,),)

		FOR	${index}	IN RANGE	30
			Log To Console	select passive_checks_enabled from resources where name='host_1' 
			${output}=	Query	select passive_checks_enabled from resources where name='host_1' 
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((0,),)"
		END
		Should Be Equal As Strings	${output}	((0,),)

		Enable Passive Host Checks	${use_grpc}	host_1

		FOR	${index}	IN RANGE	30
			Log To Console	select passive_checks from hosts where name='host_1' 
			${output}=	Query	select passive_checks from hosts where name='host_1'  
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((1,),)"
		END
		Should Be Equal As Strings	${output}	((1,),)

		FOR	${index}	IN RANGE	30
			Log To Console	select passive_checks_enabled from resources where name='host_1' 
			${output}=	Query	select passive_checks_enabled from resources where name='host_1' 
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
		${content}=	Create List	INITIAL SERVICE STATE: host_1;service_1;
		${result}=	Find In Log with Timeout	${logEngine0}	${start}	${content}	60
		Should Be True	${result}	msg=An Initial host state on host_1 should be raised before we can start our external commands.
		Disable Passive Host Checks	${use_grpc}	host_1

		Connect To Database	pymysql	${DBName}	${DBUser}	${DBPass}	${DBHost}	${DBPort}

		FOR	${index}	IN RANGE	30
			Log To Console	select passive_checks from hosts where name='host_1' 
			${output}=	Query	select passive_checks from hosts where name='host_1'  
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((0,),)"
		END
		Should Be Equal As Strings	${output}	((0,),)

		Enable Passive Host Checks	${use_grpc}	host_1

		FOR	${index}	IN RANGE	30
			Log To Console	select passive_checks from hosts where name='host_1' 
			${output}=	Query	select passive_checks from hosts where name='host_1'  
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
		${content}=	Create List	INITIAL SERVICE STATE: host_1;service_1;
		${result}=	Find In Log with Timeout	${logEngine0}	${start}	${content}	60
		Should Be True	${result}	msg=An Initial host state on host_1 should be raised before we can start our external commands.
		Disable Passive Svc Checks	${use_grpc}	host_1	service_1

		Connect To Database	pymysql	${DBName}	${DBUser}	${DBPass}	${DBHost}	${DBPort}

		FOR	${index}	IN RANGE	30
			Log To Console	select s.passive_checks from services s,hosts h where s.description='service_1' and h.name='host_1' 
			${output}=	Query	select s.passive_checks from services s,hosts h where s.description='service_1' and h.name='host_1'  
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((0,),)"
		END
		Should Be Equal As Strings	${output}	((0,),)

		FOR	${index}	IN RANGE	30
			Log To Console	select passive_checks_enabled from resources where name='service_1' 
			${output}=	Query	select passive_checks_enabled from resources where name='service_1' 
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((0,),)"
		END
		Should Be Equal As Strings	${output}	((0,),)

		Enable Passive Svc Checks	${use_grpc}	host_1	service_1

		FOR	${index}	IN RANGE	30
			Log To Console	select s.passive_checks from services s,hosts h where s.description='service_1' and h.name='host_1' 
			${output}=	Query	select s.passive_checks from services s,hosts h where s.description='service_1' and h.name='host_1'  
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((1,),)"
		END
		Should Be Equal As Strings	${output}	((1,),)

		FOR	${index}	IN RANGE	30
			Log To Console	select passive_checks_enabled from resources where name='service_1' 
			${output}=	Query	select passive_checks_enabled from resources where name='service_1' 
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
		${content}=	Create List	INITIAL SERVICE STATE: host_1;service_1;
		${result}=	Find In Log with Timeout	${logEngine0}	${start}	${content}	60
		Should Be True	${result}	msg=An Initial host state on host_1 should be raised before we can start our external commands.
		Disable Passive Svc Checks	${use_grpc}	host_1	service_1

		Connect To Database	pymysql	${DBName}	${DBUser}	${DBPass}	${DBHost}	${DBPort}

		FOR	${index}	IN RANGE	30
			Log To Console	select s.passive_checks from services s,hosts h where s.description='service_1' and h.name='host_1' 
			${output}=	Query	select s.passive_checks from services s,hosts h where s.description='service_1' and h.name='host_1'  
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((0,),)"
		END
		Should Be Equal As Strings	${output}	((0,),)

		Enable Passive Svc Checks	${use_grpc}	host_1	service_1

		FOR	${index}	IN RANGE	30
			Log To Console	select s.passive_checks from services s,hosts h where s.description='service_1' and h.name='host_1' 
			${output}=	Query	select s.passive_checks from services s,hosts h where s.description='service_1' and h.name='host_1'  
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
		${content}=	Create List	INITIAL SERVICE STATE: host_1;service_1;
		${result}=	Find In Log with Timeout	${logEngine0}	${start}	${content}	60
		Should Be True	${result}	msg=An Initial host state on host_1 should be raised before we can start our external commands.
		Stop Obsessing Over Host	${use_grpc}	host_1

		Connect To Database	pymysql	${DBName}	${DBUser}	${DBPass}	${DBHost}	${DBPort}

		FOR	${index}	IN RANGE	30
			Log To Console	select obsess_over_host from hosts where name='host_1' 
			${output}=	Query	select obsess_over_host from hosts where name='host_1'  
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((0,),)"
		END
		Should Be Equal As Strings	${output}	((0,),)

		Start Obsessing Over Host	${use_grpc}	host_1

		FOR	${index}	IN RANGE	30
			Log To Console	select obsess_over_host from hosts where name='host_1' 
			${output}=	Query	select obsess_over_host from hosts where name='host_1'  
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
		${content}=	Create List	INITIAL SERVICE STATE: host_1;service_1;
		${result}=	Find In Log with Timeout	${logEngine0}	${start}	${content}	60
		Should Be True	${result}	msg=An Initial host state on host_1 should be raised before we can start our external commands.
		Stop Obsessing Over Host	${use_grpc}	host_1

		Connect To Database	pymysql	${DBName}	${DBUser}	${DBPass}	${DBHost}	${DBPort}

		FOR	${index}	IN RANGE	30
			Log To Console	select obsess_over_host from hosts where name='host_1' 
			${output}=	Query	select obsess_over_host from hosts where name='host_1'  
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((0,),)"
		END
		Should Be Equal As Strings	${output}	((0,),)

		Start Obsessing Over Host	${use_grpc}	host_1

		FOR	${index}	IN RANGE	30
			Log To Console	select obsess_over_host from hosts where name='host_1' 
			${output}=	Query	select obsess_over_host from hosts where name='host_1'  
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
		${content}=	Create List	INITIAL SERVICE STATE: host_1;service_1;
		${result}=	Find In Log with Timeout	${logEngine0}	${start}	${content}	60
		Should Be True	${result}	msg=An Initial host state on host_1 should be raised before we can start our external commands.
		Stop Obsessing Over Svc	${use_grpc}	host_1	service_1

		Connect To Database	pymysql	${DBName}	${DBUser}	${DBPass}	${DBHost}	${DBPort}

		FOR	${index}	IN RANGE	30
			Log To Console	select s.obsess_over_service from services s,hosts h where s.description='service_1' and h.name='host_1' 
			${output}=	Query	select s.obsess_over_service from services s,hosts h where s.description='service_1' and h.name='host_1'  
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((0,),)"
		END
		Should Be Equal As Strings	${output}	((0,),)

		Start Obsessing Over Svc	${use_grpc}	host_1	service_1

		FOR	${index}	IN RANGE	30
			Log To Console	select s.obsess_over_service from services s,hosts h where s.description='service_1' and h.name='host_1' 
			${output}=	Query	select s.obsess_over_service from services s,hosts h where s.description='service_1' and h.name='host_1'  
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
		${content}=	Create List	INITIAL SERVICE STATE: host_1;service_1;
		${result}=	Find In Log with Timeout	${logEngine0}	${start}	${content}	60
		Should Be True	${result}	msg=An Initial host state on host_1 should be raised before we can start our external commands.
		Stop Obsessing Over Svc	${use_grpc}	host_1	service_1

		Connect To Database	pymysql	${DBName}	${DBUser}	${DBPass}	${DBHost}	${DBPort}

		FOR	${index}	IN RANGE	30
			Log To Console	select s.obsess_over_service from services s,hosts h where s.description='service_1' and h.name='host_1' 
			${output}=	Query	select s.obsess_over_service from services s,hosts h where s.description='service_1' and h.name='host_1'  
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((0,),)"
		END
		Should Be Equal As Strings	${output}	((0,),)

		Start Obsessing Over Svc	${use_grpc}	host_1	service_1

		FOR	${index}	IN RANGE	30
			Log To Console	select s.obsess_over_service from services s,hosts h where s.description='service_1' and h.name='host_1' 
			${output}=	Query	select s.obsess_over_service from services s,hosts h where s.description='service_1' and h.name='host_1'  
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
			${content}=	Create List	INITIAL SERVICE STATE: host_1;service_1;
			${result}=	Find In Log with Timeout	${logEngine0}	${start}	${content}	60
			Should Be True	${result}	msg=An Initial host state on host_1 should be raised before we can start our external commands.
		Change Normal Svc Check Interval  ${use_grpc}  host_1	service_1	10

		Connect To Database	pymysql	${DBName}	${DBUser}	${DBPass}	${DBHost}	${DBPort}

		FOR	${index}	IN RANGE	300
			Log To Console	select s.check_interval from services s,hosts h where s.description='service_1' and h.name='host_1' 
			${output}=	Query	select s.check_interval from services s,hosts h where s.description='service_1' and h.name='host_1'
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
			${content}=	Create List	INITIAL SERVICE STATE: host_1;service_1;
			${result}=	Find In Log with Timeout	${logEngine0}	${start}	${content}	60
			Should Be True	${result}	msg=An Initial host state on host_1 should be raised before we can start our external commands.
		Change Normal Svc Check Interval  ${use_grpc}	host_1	service_1	15

		Connect To Database	pymysql	${DBName}	${DBUser}	${DBPass}	${DBHost}	${DBPort}

		FOR	${index}	IN RANGE	30
			Log To Console	select s.check_interval from services s,hosts h where s.description='service_1' and h.name='host_1' 
			${output}=	Query	select s.check_interval from services s,hosts h where s.description='service_1' and h.name='host_1'
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
			${content}=	Create List	INITIAL SERVICE STATE: host_1;service_1;
			${result}=	Find In Log with Timeout	${logEngine0}	${start}	${content}	60
			Should Be True	${result}	msg=An Initial host state on host_1 should be raised before we can start our external commands.
		Change Normal Host Check Interval  ${use_grpc}  host_1	10

		Connect To Database	pymysql	${DBName}	${DBUser}	${DBPass}	${DBHost}	${DBPort}

		FOR	${index}	IN RANGE	30
			Log To Console	select check_interval from hosts where name='host_1' 
			${output}=	Query	select check_interval from hosts where name='host_1' 
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
			${content}=	Create List	INITIAL SERVICE STATE: host_1;service_1;
			${result}=	Find In Log with Timeout	${logEngine0}	${start}	${content}	60
			Should Be True	${result}	msg=An Initial host state on host_1 should be raised before we can start our external commands.
		Change Normal Host Check Interval  ${use_grpc}  host_1	15

		Connect To Database	pymysql	${DBName}	${DBUser}	${DBPass}	${DBHost}	${DBPort}

		FOR	${index}	IN RANGE	30
			Log To Console	select check_interval from hosts where name='host_1' 
			${output}=	Query	select check_interval from hosts where name='host_1' 
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((15.0,),)"
		END
		Should Be Equal As Strings	${output}	((15.0,),)
		Stop Engine
		Kindly Stop Broker
	END

BEEXTCMD_REVERSE_GRPC1
	[Documentation]	external command CHANGE_NORMAL_SVC_CHECK_INTERVAL on bbdo3.0 and grpc reversed
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
		${content}=	Create List	INITIAL SERVICE STATE: host_1;service_1;
		${result}=	Find In Log with Timeout	${logEngine0}	${start}	${content}	60
		Should Be True	${result}	msg=An Initial host state on host_1 should be raised before we can start our external commands.
		Change Normal Svc Check Interval  ${use_grpc}  host_1	service_1	10

		Connect To Database	pymysql	${DBName}	${DBUser}	${DBPass}	${DBHost}	${DBPort}

		FOR	${index}	IN RANGE	300
			Log To Console	select s.check_interval from services s,hosts h where s.description='service_1' and h.name='host_1' 
			${output}=	Query	select s.check_interval from services s,hosts h where s.description='service_1' and h.name='host_1'
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
		${content}=	Create List	INITIAL SERVICE STATE: host_1;service_1;
		${result}=	Find In Log with Timeout	${logEngine0}	${start}	${content}	60
		Should Be True	${result}	msg=An Initial host state on host_1 should be raised before we can start our external commands.
		Change Normal Svc Check Interval  ${use_grpc}	host_1	service_1	15

		Connect To Database	pymysql	${DBName}	${DBUser}	${DBPass}	${DBHost}	${DBPort}

		FOR	${index}	IN RANGE	30
			Log To Console	select s.check_interval from services s,hosts h where s.description='service_1' and h.name='host_1' 
			${output}=	Query	select s.check_interval from services s,hosts h where s.description='service_1' and h.name='host_1'
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
		${content}=	Create List	INITIAL SERVICE STATE: host_1;service_1;
		${result}=	Find In Log with Timeout	${logEngine0}	${start}	${content}	60
		Should Be True	${result}	msg=An Initial host state on host_1 should be raised before we can start our external commands.
		Change Normal Host Check Interval  ${use_grpc}  host_1	10

		Connect To Database	pymysql	${DBName}	${DBUser}	${DBPass}	${DBHost}	${DBPort}

		FOR	${index}	IN RANGE	30
			Log To Console	select check_interval from hosts where name='host_1' 
			${output}=	Query	select check_interval from hosts where name='host_1' 
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
		${content}=	Create List	INITIAL SERVICE STATE: host_1;service_1;
		${result}=	Find In Log with Timeout	${logEngine0}	${start}	${content}	60
		Should Be True	${result}	msg=An Initial host state on host_1 should be raised before we can start our external commands.
		Change Normal Host Check Interval  ${use_grpc}  host_1	15

		Connect To Database	pymysql	${DBName}	${DBUser}	${DBPass}	${DBHost}	${DBPort}

		FOR	${index}	IN RANGE	30
			Log To Console	select check_interval from hosts where name='host_1' 
			${output}=	Query	select check_interval from hosts where name='host_1' 
			Log To Console	${output}
			Sleep	1s
			EXIT FOR LOOP IF	"${output}" == "((15.0,),)"
		END
		Should Be Equal As Strings	${output}	((15.0,),)
		Stop Engine
		Kindly Stop Broker
	END


