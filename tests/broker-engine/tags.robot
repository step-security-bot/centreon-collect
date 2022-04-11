*** Settings ***
Resource	../resources/resources.robot
Suite Setup	Clean Before Suite
Suite Teardown	Clean After Suite
Test Setup	Stop Processes

Documentation	Engine/Broker tests on tags.
Library	Process
Library	DateTime
Library	OperatingSystem
Library	../resources/Engine.py
Library	../resources/Broker.py
Library	../resources/Common.py
Library	../resources/specific-duplication.py

*** Test Cases ***
BETAG1
	[Documentation]	Engine is configured with some tags. When broker receives them, it stores them in the centreon_storage.tags table. Broker is started before.
	[Tags]	Broker	Engine	protobuf	bbdo	tags
	Config Engine	${1}
	Create Tags File	${0}	${20}
	Config Engine Add Cfg File	${0}	tags.cfg
	Config Broker	central
	Config Broker	rrd
	Config Broker	module
	Broker Config Log	module	neb	debug
	Broker Config Log	central	sql	debug
	Clear Retention
	${start}=	Get Current Date
	Start Broker
	Start Engine
	${result}=	check tag With Timeout	tag20	3	30
	Should Be True	${result}	msg=tag20 should be of type 3
	${result}=	check tag With Timeout	tag1	0	30
	Should Be True	${result}	msg=tag1 should be of type 0
	Stop Engine
	Stop Broker

BETAG2
	[Documentation]	Engine is configured with some tags. When broker receives them, it stores them in the centreon_storage.tags table. Engine is started before.
	[Tags]	Broker	Engine	protobuf	bbdo	tags
	Config Engine	${1}
	Create Tags File	${0}	${20}
	Config Engine Add Cfg File	${0}	tags.cfg
	Config Broker	central
	Config Broker	rrd
	Config Broker	module
	Broker Config Log	module	neb	debug
	Broker Config Log	central	sql	debug
	Clear Retention
	${start}=	Get Current Date
	Start Engine
	Sleep	1s
	Start Broker
	${result}=	check tag With Timeout	tag20	3	30
	Should Be True	${result}	msg=tag20 should be of type 3
	${result}=	check tag With Timeout	tag1	0	30
	Should Be True	${result}	msg=tag1 should be of type 0
	Stop Engine
	Stop Broker

BEUTAG1
	[Documentation]	Engine is configured with some tags. When broker receives them, it stores them in the centreon_storage.tags table. Broker is started before.
	[Tags]	Broker	Engine	protobuf	bbdo	tags
	Config Engine	${1}
	Create Tags File	${0}	${20}
	Config Engine Add Cfg File	${0}	tags.cfg
	Config Broker	central
	Config Broker	rrd
	Config Broker	module
	Config Broker Sql Output	central	unified_sql
        Broker Config Add Item	module	bbdo_version	3.0.0
        Broker Config Add Item	central	bbdo_version	3.0.0
        Broker Config Add Item	rrd	bbdo_version	3.0.0
	Broker Config Log	module	neb	debug
	Broker Config Log	central	sql	debug
	Clear Retention
	${start}=	Get Current Date
	Start Broker
	Start Engine
	${result}=	check tag With Timeout	tag20	3	30
	Should Be True	${result}	msg=tag20 should be of type 3
	${result}=	check tag With Timeout	tag1	0	30
	Should Be True	${result}	msg=tag1 should be of type 0
	Stop Engine
	Stop Broker

BEUTAG2
	[Documentation]	Engine is configured with some tags. When broker receives them, it stores them in the centreon_storage.tags table. Engine is started before.
	[Tags]	Broker	Engine	protobuf	bbdo	tags
	Config Engine	${1}
	Create Tags File	${0}	${20}
	Config Engine Add Cfg File	${0}	tags.cfg
	Config Broker	central
	Config Broker	rrd
	Config Broker	module
	Config Broker Sql Output	central	unified_sql
	Broker Config Add Item	module	bbdo_version	3.0.0
	Broker Config Add Item	central	bbdo_version	3.0.0
	Broker Config Add Item	rrd	bbdo_version	3.0.0
	Broker Config Log	module	neb	debug
	Broker Config Log	central	sql	debug
	Clear Retention
	${start}=	Get Current Date
	Start Engine
	Sleep	1s
	Start Broker
	${result}=	check tag With Timeout	tag20	3	30
	Should Be True	${result}	msg=tag20 should be of type 3
	${result}=	check tag With Timeout	tag1	0	30
	Should Be True	${result}	msg=tag1 should be of type 0
	Stop Engine
	Stop Broker

BEUTAG3
	[Documentation]	Engine is configured with some tags. When broker receives them, it stores them in the centreon_storage.resources_tags table. Engine is started before.
	[Tags]	Broker	Engine	protobuf	bbdo	tags
	#Clear DB	tags
	Config Engine	${1}
	Create Tags File	${0}	${20}
	Config Engine Add Cfg File	${0}	tags.cfg
	Add Tags To Services	${0}	group_tags	9,13	[1, 3, 5, 6]
	Add Tags To Services	${0}	category_tags	3,11	[1, 3, 5, 6]
	Config Broker	central
	Config Broker	rrd
	Config Broker	module
	Config Broker Sql Output	central	unified_sql
	Broker Config Add Item	module	bbdo_version	3.0.0
	Broker Config Add Item	central	bbdo_version	3.0.0
	Broker Config Add Item	rrd	bbdo_version	3.0.0
	Broker Config Log	module	neb	debug
	Broker Config Log	central	sql	debug
	Clear Retention
	${start}=	Get Current Date
	Start Engine
	Sleep	1s
	Start Broker
	${result}=	check service tags With Timeout	1	1	9	60
	Should Be True	${result}	msg=Service (1, 1) should have tag_id=9
	Stop Engine
	Stop Broker

BEUTAG4
	[Documentation]	Engine is configured with some tags. When broker receives them, it stores them in the centreon_storage.resources_tags table. Engine is started before.
	[Tags]	Broker	Engine	protobuf	bbdo	tags
	#Clear DB	tags
	Config Engine	${1}
	Create Tags File	${0}	${20}
	Config Engine Add Cfg File	${0}	tags.cfg
	Add Tags To Hosts	${0}	group_tags	2,6	[1, 2, 3, 4]
	Add Tags To Hosts	${0}	category_tags	4,8	[1, 2, 3, 4]
	Config Broker	central
	Config Broker	rrd
	Config Broker	module
	Config Broker Sql Output	central	unified_sql
	Broker Config Add Item	module	bbdo_version	3.0.0
	Broker Config Add Item	central	bbdo_version	3.0.0
	Broker Config Add Item	rrd	bbdo_version	3.0.0
	Broker Config Log	module	neb	debug
	Broker Config Log	central	sql	debug
	Clear Retention
	${start}=	Get Current Date
	Start Engine
	Sleep	1s
	Start Broker
	${result}=	check host tags With Timeout	1	6	60
	Should Be True	${result}	msg=Host (1) should have tag_id=6
	Stop Engine
	Stop Broker

BEUTAG5
	[Documentation]	Engine is configured with some tags. When broker receives them, it stores them in the centreon_storage.resources_tags table. Engine is started before.
	[Tags]	Broker	Engine	protobuf	bbdo	tags
	#Clear DB	tags
	Config Engine	${1}
	Create Tags File	${0}	${20}
	Config Engine Add Cfg File	${0}	tags.cfg
	Add Tags To Hosts	${0}	group_tags	2,6	[1, 2, 3, 4]
	Add Tags To Hosts	${0}	category_tags	4,8	[1, 2, 3, 4]
	Add Tags To Services	${0}	group_tags	9,13	[1, 2, 3, 4]
	Add Tags To Services	${0}	category_tags	3,11	[1, 2, 3, 4]
	Config Broker	central
	Config Broker	rrd
	Config Broker	module
	Config Broker Sql Output	central	unified_sql
	Broker Config Add Item	module	bbdo_version	3.0.0
	Broker Config Add Item	central	bbdo_version	3.0.0
	Broker Config Add Item	rrd	bbdo_version	3.0.0
	Broker Config Log	module	neb	debug
	Broker Config Log	central	sql	debug
	Clear Retention
	${start}=	Get Current Date
	Start Engine
	Sleep	1s
	Start Broker
	${result}=	check host tags With Timeout	1	6	60
	Should Be True	${result}	msg=Host (1) should have tag_id=6
	${result}=	check service tags With Timeout	1	1	9	60
	Should Be True	${result}	msg=Service (1, 1) should have tag_id=9
	Stop Engine
	Stop Broker

BEUTAG6
	[Documentation]	some services are configured and deleted with tags on two pollers. 
	[Tags]	Broker	Engine	protobuf	bbdo	tags
	Config Engine	${2}
	Create Tags File	${0}	${20}
	Create Tags File	${1}	${20}
	Config Engine Add Cfg File	${0}	tags.cfg
	Config Engine Add Cfg File	${1}	tags.cfg
	Engine Config Set Value	${0}	log_level_config	debug
	Engine Config Set Value	${1}	log_level_config	debug
	Add Tags To Services	${0}	group_tags	9,13	[1, 2, 3, 4]
	Add Tags To Services	${0}	category_tags	3,11	[1, 2, 3, 4]
	Add Tags To Services	${1}	group_tags	9,13	[501, 502, 503, 504]
	Add Tags To Services	${1}	category_tags	3,11	[501, 502, 503, 504]
	Config Broker	central
	Config Broker	rrd
	Config Broker	module
	Config Broker Sql Output	central	unified_sql
	Broker Config Add Item	module	bbdo_version	3.0.0
	Broker Config Add Item	central	bbdo_version	3.0.0
	Broker Config Add Item	rrd	bbdo_version	3.0.0
	Broker Config Log	module	neb	debug
	Broker Config Log	central	sql	trace
	Clear Retention
	${start}=	Get Current Date
	Start Engine
	Start Broker
	Sleep	5s
	# We need to wait a little before reloading Engine
	${result}=	check service tags With Timeout	1	1	9	60
	Should Be True	${result}	msg=First step: Service (1, 1) should have tag_id=9

	${result}=	check service tags With Timeout	1	1	13	60
	Should Be True	${result}	msg=First step: Service (1, 1) should have tag_id=13

	${result}=	check service tags With Timeout	1	2	13	60
	Should Be True	${result}	msg=First step: Service (1, 2) should have tag_id=13

	${result}=	check service tags With Timeout	26	502	13	60
	Should Be True	${result}	msg=First step: Service (26, 502) should have tag_id=13

	Remove Tags From Services	${0}	group_tags
	Remove Tags From Services	${0}	category_tags
	Remove Tags From Services	${1}	group_tags
	Remove Tags From Services	${1}	category_tags
	Create Tags File	${0}	${18}
	Create Tags File	${1}	${18}
	Add Tags To Services	${1}	group_tags	9,13	[505, 506, 507, 508]
	Reload Engine
	Reload Broker
	Sleep	3s
	${result}=	check service tags With Timeout	26	507	9	60
	Should Be True	${result}	msg=Second step: Service (26, 502) should have tags_id=9

	${result}=	check service tags With Timeout	26	508	13	60
	Should Be True	${result}	msg=Second step: Service (1, 4) should have tags_id=13

	Stop Engine
	Kindly Stop Broker

BEUTAG7
	[Documentation]	Services have tags provided by templates.
	[Tags]	Broker	Engine	protobuf	bbdo	tags
	Config Engine	${2}
	Create Tags File	${0}	${20}
	Create Tags File	${1}	${20}
	Create Template File	${0}	service	group_tags	[1, 9]
	Create Template File	${1}	service	group_tags	[5, 13]

	Config Engine Add Cfg File	${0}	tags.cfg
	Config Engine Add Cfg File	${1}	tags.cfg
	Config Engine Add Cfg File	${0}	serviceTemplates.cfg
	Config Engine Add Cfg File	${1}	serviceTemplates.cfg
	Engine Config Set Value	${0}	log_level_config	debug
	Engine Config Set Value	${1}	log_level_config	debug
	Add Template To Services	0	service_template_1	[2, 4]
	Add Template To Services	0	service_template_2	[5, 7]
	Add Template To Services	1	service_template_1	[501, 502]
	Add Template To Services	1	service_template_2	[503, 504]
	Config Broker	central
	Config Broker	rrd
	Config Broker	module
	Config Broker Sql Output	central	unified_sql
	Broker Config Add Item	module	bbdo_version	3.0.0
	Broker Config Add Item	central	bbdo_version	3.0.0
	Broker Config Add Item	rrd	bbdo_version	3.0.0
	Broker Config Log	module	neb	debug
	Broker Config Log	central	sql	trace
	Clear Retention
	${start}=	Get Current Date
	Start Engine
	Start Broker
	Sleep	5s
	# We need to wait a little before reloading Engine
	${result}=	check service tags With Timeout	1	2	1	60
	Should Be True	${result}	msg=First step: Service (1, 2) should have tags_id=1

	${result}=	check service tags With Timeout	1	4	1	60
	Should Be True	${result}	msg=First step: Service (1, 4) should have tags_id=1

	${result}=	check service tags With Timeout	1	5	9	60
	Should Be True	${result}	msg=First step: Service (1, 5) should have tags_id=9

	${result}=	check service tags With Timeout	1	7	9	60
	Should Be True	${result}	msg=First step: Service (1, 7) should have tags_id=9

	${result}=	check service tags With Timeout	26	502	5	60
	Should Be True	${result}	msg=First step: Service (26, 502) should have tags_id=5

	${result}=	check service tags With Timeout	26	503	13	60
	Should Be True	${result}	msg=First step: Service (26, 503) should have tags_id=13

	Stop Engine
	Kindly Stop Broker

BEUTAG8
	[Documentation]	hosts have tags provided by templates.
	[Tags]	Broker	Engine	protobuf	bbdo	tags
	Config Engine	${2}
	Create Tags File	${0}	${20}
	Create Tags File	${1}	${20}
	Create Template File	${0}	host	group_tags	[2, 6]
	Create Template File	${1}	host	group_tags	[10, 14]

	Config Engine Add Cfg File	${0}	tags.cfg
	Config Engine Add Cfg File	${1}	tags.cfg
	Config Engine Add Cfg File	${0}	hostTemplates.cfg
	Config Engine Add Cfg File	${1}	hostTemplates.cfg
	Engine Config Set Value	${0}	log_level_config	debug
	Engine Config Set Value	${1}	log_level_config	debug
	Add Template To Hosts	0	host_template_1	[9, 10]
	Add Template To Hosts	0	host_template_2	[11, 12]
	Add Template To Hosts	1	host_template_1	[30, 31]
	Add Template To Hosts	1	host_template_2	[32, 33]
	Config Broker	central
	Config Broker	rrd
	Config Broker	module
	Config Broker Sql Output	central	unified_sql
	Broker Config Add Item	module	bbdo_version	3.0.0
	Broker Config Add Item	central	bbdo_version	3.0.0
	Broker Config Add Item	rrd	bbdo_version	3.0.0
	Broker Config Log	module	neb	debug
	Broker Config Log	central	sql	trace
	Clear Retention
	${start}=	Get Current Date
	Start Engine
	Sleep	5s
	Start Broker

	# We need to wait a little before reloading Engine
	${result}=	check host tags With Timeout	9	2	60
	Should Be True	${result}	msg=First step: host (9) should have tags_id=2

	${result}=	check host tags With Timeout	10	2	60
	Should Be True	${result}	msg=First step: host (10) should have tags_id=2

	${result}=	check host tags With Timeout	11	6	60
	Should Be True	${result}	msg=First step: host (11) should have tags_id=6

	${result}=	check host tags With Timeout	12	6	60
	Should Be True	${result}	msg=First step: host (12) should have tags_id=6

	${result}=	check host tags With Timeout	30	10	60
	Should Be True	${result}	msg=First step: host (30) should have tags_id=10

	${result}=	check host tags With Timeout	31	10	60
	Should Be True	${result}	msg=First step: host (31) should have tags_id=10

	${result}=	check host tags With Timeout	32	14	60
	Should Be True	${result}	msg=First step: host (32) should have tags_id=14

	${result}=	check host tags With Timeout	33	14	60
	Should Be True	${result}	msg=First step: host (33) should have tags_id=14

	Stop Engine
	Kindly Stop Broker