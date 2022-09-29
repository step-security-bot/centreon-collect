*** Settings ***
Resource	./db_variables.robot
Library	Process
Library	OperatingSystem
Library	Common.py

*** Keywords ***
Clean Before Suite
	Stop Processes
	Clear Engine Logs
	Clear Broker Logs

Clean Before Suite With rrdcached
	Clean Before Suite
	log to console	Starting RRDCached
	Run Process	/usr/bin/rrdcached	-l	unix:${BROKER_LIB}/rrdcached.sock	-V	LOG_DEBUG	-F

Clean Grpc Before Suite
	set grpc port  0
	Clean Before Suite

Clean After Suite
	# Remove Files	${ENGINE_LOG}${/}centengine.log ${ENGINE_LOG}${/}centengine.debug
	# Remove Files	${BROKER_LOG}${/}central-broker-master.log	${BROKER_LOG}${/}central-rrd-master.log	${BROKER_LOG}${/}central-module-master.log
	Terminate All Processes	kill=True

Clean After Suite With rrdcached
	Clean after Suite
	log to console	Stopping RRDCached
	Stop rrdcached

Clear Engine Logs
	Remove Directory	${ENGINE_LOG}	Recursive=True
	Create Directory	${ENGINE_LOG}

Clear Broker Logs
	Remove Directory	${BROKER_LOG}	Recursive=True
	Create Directory	${BROKER_LOG}

Start Broker
	Start Process	/usr/sbin/cbd	${EtcRoot}/centreon-broker/central-broker.json	alias=b1
	Start Process	/usr/sbin/cbd	${EtcRoot}/centreon-broker/central-rrd.json	alias=b2

Reload Broker
	Send Signal To Process	SIGHUP	b1
	Send Signal To Process	SIGHUP	b2

Kindly Stop Broker
	Send Signal To Process	SIGTERM	b1
	Send Signal To Process	SIGTERM	b2
	${result}=	Wait For Process	b1	timeout=60s
	# In case of process not stopping
	IF	"${result}" == "${None}"
	  Dump Process	b1	broker-central
	  Send Signal To Process	SIGKILL	b1
	  Fail	Central Broker not correctly stopped (coredump generated)
	ELSE
	  Should Be Equal As Integers	${result.rc}	0	msg=Central Broker not correctly stopped
	END

	${result}=	Wait For Process	b2	timeout=60s	on_timeout=kill
	# In case of process not stopping
	IF	"${result}" == "${None}"
	  Dump Process	b2	broker-rrd
	  Send Signal To Process	SIGKILL	b2
	  Fail	RRD Broker not correctly stopped (coredump generated)
  	ELSE
	  Should Be Equal As Integers	${result.rc}	0	msg=RRD Broker not correctly stopped
	END

Stop Broker
	${result}=	Terminate Process	b1	kill=False
	Should Be Equal As Integers	${result.rc}	0
	${result}=	Terminate Process	b2	kill=False
	Should Be Equal As Integers	${result.rc}	0

Stop Processes
	Terminate All Processes	kill=True
	Kill Broker
	Kill Engine

Start Engine
	${count}=	Get Engines Count
	FOR	${idx}	IN RANGE	0	${count}
	 ${alias}=	Catenate	SEPARATOR=	e	${idx}
	 ${conf}=	Catenate	SEPARATOR=	${EtcRoot}  /centreon-engine/config	${idx}	/centengine.cfg
	 ${log}=	Catenate	SEPARATOR=	${VarRoot}  /log/centreon-engine/config	${idx}
	 ${lib}=	Catenate	SEPARATOR=	${VarRoot}  /lib/centreon-engine/config	${idx}
	 Create Directory	${log}
	 Create Directory	${lib}
	 Start Process	/usr/sbin/centengine	${conf}	alias=${alias}
	END

Start Custom Engine
	[Arguments]	 ${conf_path}  ${process_alias}
	Start Process  /usr/sbin/centengine  ${conf_path}  alias=${process_alias}

Stop Custom Engine
	[Arguments]  ${process_alias}
	${result}=	Terminate Process	${process_alias}
	Should Be True	${result.rc} == -15 or ${result.rc} == 0	msg=Engine badly stopped alias = ${process_alias} - code returned ${result.rc}.

Stop Engine
	${count}=	Get Engines Count
	FOR	${idx}	IN RANGE	0	${count}
	 ${alias}=	Catenate	SEPARATOR=	e	${idx}
	 Send Signal To Process	SIGTERM	${alias}
	END
	FOR	${idx}	IN RANGE	0	${count}
	 ${alias}=	Catenate	SEPARATOR=	e	${idx}
	 ${result}=	Wait For Process	${alias}	timeout=60s
	 IF	"${result}" == "${None}"
	   ${name}=	Catenate	SEPARATOR=	centengine	${idx}
	   Dump Process	${alias}	${name}
	   Send Signal To Process	SIGKILL	${alias}
	   Fail	${name} not correctly stopped (coredump generated)
  	 ELSE
	  Should Be True	${result.rc} == -15 or ${result.rc} == 0	msg=Engine badly stopped with ${count} instances - code returned ${result.rc}.
	 END
	END

Reload Engine
	${count}=	Get Engines Count
	FOR	${idx}	IN RANGE	0	${count}
	 ${alias}=	Catenate	SEPARATOR=	e	${idx}
	 Send Signal To Process	SIGHUP	${alias}
	END

Check Connections
	${count}=	Get Engines Count
	${pid1}=	Get Process Id	b1
	FOR	${idx}	IN RANGE	0	${count}
	 ${alias}=	Catenate	SEPARATOR=	e	${idx}
	 ${pid2}=	Get Process Id	${alias}
	 ${retval}=	Check Connection	5669	${pid1}	${pid2}
	 Return from Keyword If	${retval} == ${False}	${False}
	END
	${pid2}=	Get Process Id	b2
	${retval}=	Check Connection	5670	${pid1}	${pid2}
	[Return]	${retval}

Disable Eth Connection On Port
	[Arguments]	${port}
	RUN	iptables -A INPUT -p tcp --dport ${port} -j DROP
	RUN	iptables -A OUTPUT -p tcp --dport ${port} -j DROP
	RUN	iptables -A FORWARD -p tcp --dport ${port} -j DROP

Reset Eth Connection
	Run	iptables -F
	Run	iptables -X

Save Logs If failed
	Run Keyword If Test Failed	Save Logs

Save Logs
	Create Directory	failed
	${failDir}=	Catenate	SEPARATOR=	failed/	${Test Name}
	Create Directory	${failDir}
	Copy files	${centralLog}	${failDir}
	Copy files	${moduleLog0}	${failDir}
	Copy files	${engineLog0}	${failDir}
	Copy files	${ENGINE_LOG}/config0/gcore_*	${failDir}
	Copy Files	${EtcRoot}/centreon-engine/config0/*.cfg	${failDir}/etc/centreon-engine/config0
	Copy Files	${EtcRoot}/centreon-broker/*.json	${failDir}/etc/centreon-broker


Dump Process
	[Arguments]	${process_name}	${name}
	${pid}=	Get Process Id	${process_name}
	${failDir}=	Catenate	SEPARATOR=	failed/	${Test Name}
	Create Directory	${failDir}
	${output}=	Catenate	SEPARATOR=	${failDir}	/core-	${name}
	Log To Console	Creation of core ${output}.${pid} to debug
	Run Process	gcore	-o	${output}	${pid}
	Log To Console	Done...


Wait Or Dump And Kill Process
	[Arguments]  ${process_name}  ${timeout}
	${result}=      Wait For Process	${process_name}	timeout=${timeout}      on_timeout=continu
	${test_none}=  Set Variable If  $result is None  "not killed"  "killed"
	IF  ${test_none} == "not killed"
		${pid}=  Get Process Id  ${process_name}
		Run Process  gcore  -o  ${ENGINE_LOG}/config0/gcore_${process_name}  ${pid}
		${result}=      Wait For Process	${process_name}	timeout=1s      on_timeout=kill
	END
	[Return]	${result}

*** Variables ***
${BROKER_LOG}	${VarRoot}/log/centreon-broker
${BROKER_LIB}	${VarRoot}/lib/centreon-broker
${ENGINE_LOG}	${VarRoot}/log/centreon-engine
${SCRIPTS}	${CURDIR}${/}scripts${/}
${centralLog}	${BROKER_LOG}/central-broker-master.log
${moduleLog0}	${BROKER_LOG}/central-module-master0.log
${moduleLog1}	${BROKER_LOG}/central-module-master1.log
${moduleLog2}	${BROKER_LOG}/central-module-master2.log
${moduleLog3}	${BROKER_LOG}/central-module-master3.log
${rrdLog}	${BROKER_LOG}/central-rrd-master.log

${engineLog0}	${ENGINE_LOG}/config0/centengine.log
${engineLog1}	${ENGINE_LOG}/config1/centengine.log
${engineLog2}	${ENGINE_LOG}/config2/centengine.log
${engineLog3}	${ENGINE_LOG}/config3/centengine.log
