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
	Broker Config Log	module0	neb	debug
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
	Kindly Stop Broker

BETAG2
	[Documentation]	Engine is configured with some tags. When broker receives them, it stores them in the centreon_storage.tags table. Engine is started before.
	[Tags]	Broker	Engine	protobuf	bbdo	tags
	Config Engine	${1}
	Create Tags File	${0}	${20}
	Config Engine Add Cfg File	${0}	tags.cfg
	Config Broker	central
	Config Broker	rrd
	Config Broker	module
	Broker Config Log	module0	neb	debug
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
	Kindly Stop Broker

BEUTAG1
	[Documentation]	Engine is configured with some tags. When broker receives them, it stores them in the centreon_storage.tags table. Broker is started before.
	[Tags]	Broker	Engine	protobuf	bbdo	tags	unified_sql
	Config Engine	${1}
	Create Tags File	${0}	${20}
	Config Engine Add Cfg File	${0}	tags.cfg
	Config Broker	central
	Config Broker	rrd
	Config Broker	module
	Config Broker Sql Output	central	unified_sql
        Broker Config Add Item	module0	bbdo_version	3.0.0
        Broker Config Add Item	central	bbdo_version	3.0.0
        Broker Config Add Item	rrd	bbdo_version	3.0.0
	Broker Config Log	module0	neb	debug
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
	Kindly Stop Broker

BEUTAG2
	[Documentation]	Engine is configured with some tags. A new service is added with a tag. Broker should make the relations.
	[Tags]	Broker	Engine	protobuf	bbdo	tags	unified_sql
        Clear Db	resources
	Config Engine	${1}
	Create Tags File	${0}	${20}
	Config Engine Add Cfg File	${0}	tags.cfg
	Config Broker	central
	Config Broker	rrd
	Config Broker	module
	Config Broker Sql Output	central	unified_sql
        Broker Config Add Item	module0	bbdo_version	3.0.0
        Broker Config Add Item	central	bbdo_version	3.0.0
        Broker Config Add Item	rrd	bbdo_version	3.0.0
        Broker Config Output Set	central	central-broker-unified-sql	connections_count	1
        Broker Config Output Set	central	central-broker-unified-sql	queries_per_transaction	1
        Broker Config Output Set	central	central-broker-unified-sql	read_timeout	1
        Broker Config Output Set	central	central-broker-unified-sql	retry_interval	5
	Broker Config Log	module0	neb	debug
	Broker Config Log	central	sql	error
	Clear Retention
	${start}=	Get Current Date
	Start Broker
	Start Engine
        Sleep	2s

        ${svc}=	Create Service	${0}	1     1
	Add Tags To Services	${0}	group_tags	4	[${svc}]

	Stop Engine
	Start Engine
	Reload Broker
        Sleep	2s
	${result}=	check resources tags With Timeout	1	${svc}	servicegroup	[4]	60
	Should Be True	${result}	msg=New service should have a service group tag of id 4.
	Stop Engine
	Kindly Stop Broker

BEUTAG3
	[Documentation]	Engine is configured with some tags. When broker receives them, it stores them in the centreon_storage.tags table. Engine is started before.
	[Tags]	Broker	Engine	protobuf	bbdo	tags	unified_sql
	Config Engine	${1}
	Create Tags File	${0}	${20}
	Config Engine Add Cfg File	${0}	tags.cfg
	Config Broker	central
	Config Broker	rrd
	Config Broker	module
	Config Broker Sql Output	central	unified_sql
	Broker Config Add Item	module0	bbdo_version	3.0.0
	Broker Config Add Item	central	bbdo_version	3.0.0
	Broker Config Add Item	rrd	bbdo_version	3.0.0
	Broker Config Log	module0	neb	debug
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
	Kindly Stop Broker

BEUTAG4
	[Documentation]	Engine is configured with some tags. Group tags tag9, tag13 are set to services 1 and 3. Category tags tag3 and tag11 are added to services 1, 3, 5 and 6. The centreon_storage.resources and resources_tags tables are well filled.
	[Tags]	Broker	Engine	protobuf	bbdo	tags	unified_sql
	#Clear DB	tags
	Config Engine	${1}
	Create Tags File	${0}	${20}
	Config Engine Add Cfg File	${0}	tags.cfg
	Add Tags To Services	${0}	group_tags	4,5	[1, 3]
	Add Tags To Services	${0}	category_tags	2,4	[3, 5, 6]
	Config Broker	central
	Config Broker	rrd
	Config Broker	module
	Config Broker Sql Output	central	unified_sql
	Broker Config Add Item	module0	bbdo_version	3.0.0
	Broker Config Add Item	central	bbdo_version	3.0.0
	Broker Config Add Item	rrd	bbdo_version	3.0.0
	Broker Config Log	module0	neb	debug
	Broker Config Log	central	sql	debug
	Clear Retention
	${start}=	Get Current Date
	Start Engine
	Sleep	1s
	Start Broker
	${result}=	check resources tags With Timeout	1	1	servicegroup	[4, 5]	60
	Should Be True	${result}	msg=Service (1, 1) should have servicegroup tag ids 4 and 5
	${result}=	check resources tags With Timeout	1	3	servicegroup	[4, 5]	60
	Should Be True	${result}	msg=Service (1, 3) should have servicegroup tag ids 4, 5
	${result}=	check resources tags With Timeout	1	3	servicecategory	[2, 4]	60
	Should Be True	${result}	msg=Service (1, 3) should have servicecategory tag ids 2, 4
	${result}=	check resources tags With Timeout	1	5	servicecategory	[2, 4]	60
	Should Be True	${result}	msg=Service (1, 5) should have servicecategory tag ids 2, 4
	Stop Engine
	Kindly Stop Broker

BEUTAG5
	[Documentation]	Engine is configured with some tags. Group tags tag2, tag6 are set to hosts 1 and 2. Category tags tag4 and tag8 are added to hosts 2, 3, 4. The resources and resources_tags tables are well filled.
	[Tags]	Broker	Engine	protobuf	bbdo	tags
	#Clear DB	tags
	Config Engine	${1}
	Create Tags File	${0}	${20}
	Config Engine Add Cfg File	${0}	tags.cfg
	Add Tags To Hosts	${0}	group_tags	2,3	[1, 2]
	Add Tags To Hosts	${0}	category_tags	2,3	[2, 3, 4]
	Config Broker	central
	Config Broker	rrd
	Config Broker	module
	Config Broker Sql Output	central	unified_sql
	Broker Config Add Item	module0	bbdo_version	3.0.0
	Broker Config Add Item	central	bbdo_version	3.0.0
	Broker Config Add Item	rrd	bbdo_version	3.0.0
	Broker Config Log	module0	neb	debug
	Broker Config Log	central	sql	debug
	Clear Retention
	${start}=	Get Current Date
	Start Engine
	Sleep	1s
	Start Broker
	${result}=	check resources tags With Timeout	0	1	hostgroup	[2,3]	60
	Should Be True	${result}	msg=Host 1 should have hostgroup tags 2 and 3
	${result}=	check resources tags With Timeout	0	2	hostgroup	[2,3]	60
	Should Be True	${result}	msg=Host 2 should have hostgroup tags 2 and 3
	${result}=	check resources tags With Timeout	0	2	hostcategory	[2, 3]	60
	Should Be True	${result}	msg=Host 2 should have hostcategory tags 2 and 3
	${result}=	check resources tags With Timeout	0	3	hostcategory	[2, 3]	60
	Should Be True	${result}	msg=Host 3 should have hostcategory tags 2 and 3
	Stop Engine
	Kindly Stop Broker

BEUTAG6
	[Documentation]	Engine is configured with some tags. When broker receives them, it stores them in the centreon_storage.resources_tags table. Engine is started before.
	[Tags]	Broker	Engine	protobuf	bbdo	tags
	#Clear DB	tags
	Config Engine	${1}
	Create Tags File	${0}	${20}
	Config Engine Add Cfg File	${0}	tags.cfg
	Add Tags To Hosts	${0}	group_tags	2,4	[1, 2, 3, 4]
	Add Tags To Hosts	${0}	category_tags	1,5	[1, 2, 3, 4]
	Add Tags To Services	${0}	group_tags	2,4	[1, 2, 3, 4]
	Add Tags To Services	${0}	category_tags	3,5	[1, 2, 3, 4]
	Config Broker	central
	Config Broker	rrd
	Config Broker	module	${1}
	Config Broker Sql Output	central	unified_sql
	Broker Config Add Item	module0	bbdo_version	3.0.0
	Broker Config Add Item	central	bbdo_version	3.0.0
	Broker Config Add Item	rrd	bbdo_version	3.0.0
	Broker Config Log	module0	neb	debug
	Broker Config Log	central	sql	debug
	Clear Retention
	${start}=	Get Current Date
	Start Engine
	Sleep	1s
	Start Broker
	${result}=	check resources tags With Timeout	0	1	hostgroup	[2,4]	60
	Should Be True	${result}	msg=Host 1 should have hostgroup tag_id 2 and 4
	${result}=	check resources tags With Timeout	0	1	hostcategory	[1,5]	60
	Should Be True	${result}	msg=Host 1 should have hostcategory tag_id 1 and 5
	${result}=	check resources tags With Timeout	1	1	servicegroup	[2,4]	60
	Should Be True	${result}	msg=Service (1, 1) should have servicegroup tag_id 2 and 4.
	${result}=	check resources tags With Timeout	1	1	servicecategory	[3,5]	60
	Should Be True	${result}	msg=Service (1, 1) should have servicecategory tag_id 3 and 5.
	Stop Engine
	Kindly Stop Broker

BEUTAG7
	[Documentation]	some services are configured and deleted with tags on two pollers.
	[Tags]	Broker	Engine	protobuf	bbdo	tags
	Config Engine	${2}
	Create Tags File	${0}	${20}
	Create Tags File	${1}	${20}
	Config Engine Add Cfg File	${0}	tags.cfg
	Config Engine Add Cfg File	${1}	tags.cfg
	Engine Config Set Value	${0}	log_level_config	debug
	Engine Config Set Value	${1}	log_level_config	debug
	Add Tags To Services	${0}	group_tags	2,4	[1, 2, 3, 4]
	Add Tags To Services	${0}	category_tags	3,5	[1, 2, 3, 4]
	Add Tags To Services	${1}	group_tags	3,5	[501, 502, 503, 504]
	Add Tags To Services	${1}	category_tags	2,4	[501, 502, 503, 504]
	Config Broker	central
	Config Broker	rrd
	Config Broker	module	${2}
	Config Broker Sql Output	central	unified_sql
	Broker Config Add Item	module0	bbdo_version	3.0.0
	Broker Config Add Item	module1	bbdo_version	3.0.0
	Broker Config Add Item	central	bbdo_version	3.0.0
	Broker Config Add Item	rrd	bbdo_version	3.0.0
	Broker Config Log	module0	neb	debug
	Broker Config Log	module1	neb	debug
	Broker Config Log	central	sql	trace
	Clear Retention
	${start}=	Get Current Date
	Start Engine
	Start Broker
	Sleep	5s
	# We need to wait a little before reloading Engine
	${result}=	check resources tags With Timeout	1	1	servicegroup	[2,4]	60
	Should Be True	${result}	msg=First step: Service (1, 1) should have servicegroup tags 2 and 4

	${result}=	check resources tags With Timeout	26	502	servicecategory	[2,4]	60
	Should Be True	${result}	msg=First step: Service (26, 502) should have servicecategory tags 13, 9, 3 and 11.
	${result}=	check resources tags With Timeout	26	502	servicegroup	[3,5]	60
	Should Be True	${result}	msg=First step: Service (26, 502) should have servicegroup tags 3 and 5.

	Remove Tags From Services	${0}	group_tags
	Remove Tags From Services	${0}	category_tags
	Remove Tags From Services	${1}	group_tags
	Remove Tags From Services	${1}	category_tags
	Create Tags File	${0}	${18}
	Create Tags File	${1}	${18}
	Add Tags To Services	${1}	group_tags	3,5	[505, 506, 507, 508]
	Reload Engine
	Reload Broker
	Sleep	3s
	${result}=	check resources tags With Timeout	26	507	servicegroup	[3,5]	60
	Should Be True	${result}	msg=Second step: Service (26, 507) should have servicegroup tags 3 and 5

	${result}=	check resources tags With Timeout	26	508	servicegroup	[3,5]	60
	Should Be True	${result}	msg=Second step: Service (26, 508) should have servicegroup tags 3 and 5

	Stop Engine
	Kindly Stop Broker

BEUTAG8
	[Documentation]	Services have tags provided by templates.
	[Tags]	Broker	Engine	protobuf	bbdo	tags
	Config Engine	${2}
	Create Tags File	${0}	${40}
	Create Tags File	${1}	${40}
	Create Template File	${0}	service	group_tags	[1, 9]
	Create Template File	${1}	service	group_tags	[5, 7]

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

	Add Tags To Services	${0}	category_tags	3,5	[1, 2]
	Add Tags To Services	${1}	group_tags	1,4	[501, 502]

	Config Broker	central
	Config Broker	rrd
	Config Broker	module	${2}
	Config Broker Sql Output	central	unified_sql
	Broker Config Add Item	module0	bbdo_version	3.0.0
	Broker Config Add Item	module1	bbdo_version	3.0.0
	Broker Config Add Item	central	bbdo_version	3.0.0
	Broker Config Add Item	rrd	bbdo_version	3.0.0
	Broker Config Log	module0	neb	debug
	Broker Config Log	module1	neb	debug
	Broker Config Log	central	sql	trace
	Clear Retention
	${start}=	Get Current Date
	Start Engine
	Start Broker
	Sleep	5s
	# We need to wait a little before reloading Engine
	${result}=	check resources tags With Timeout	1	2	servicecategory	[3,5]	60
	Should Be True	${result}	msg=First step: Service (1, 2) should have servicecategory tags 3 and 5.
	${result}=	check resources tags With Timeout	1	2	servicegroup	[1]	60
	Should Be True	${result}	msg=First step: Service (1, 2) should have servicegroup tag 1.

	${result}=	check resources tags With Timeout	1	5	servicegroup	[9]	60
	Should Be True	${result}	msg=First step: Service (1, 5) should have servicegroup tag 9

	${result}=	check resources tags With Timeout	26	502	servicegroup	[1,4,5]	60
	Should Be True	${result}	msg=First step: Service (26, 502) should have tags 1, 4 and 5

	${result}=	check resources tags With Timeout	26	503	servicegroup	[7]	60
	Should Be True	${result}	msg=First step: Service (26, 503) should have servicegroup tag 7

	Stop Engine
	Kindly Stop Broker

BEUTAG9
	[Documentation]	hosts have tags provided by templates.
	[Tags]	Broker	Engine	protobuf	bbdo	tags
	Config Engine	${2}
	Create Tags File	${0}	${40}
	Create Tags File	${1}	${40}
	Create Template File	${0}	host	group_tags	[2, 6]
	Create Template File	${1}	host	group_tags	[8, 9]

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
	Config Broker	module	${2}
	Config Broker Sql Output	central	unified_sql
	Broker Config Add Item	module0	bbdo_version	3.0.0
	Broker Config Add Item	module1	bbdo_version	3.0.0
	Broker Config Add Item	central	bbdo_version	3.0.0
	Broker Config Add Item	rrd	bbdo_version	3.0.0
	Broker Config Log	module0	neb	debug
	Broker Config Log	module1	neb	debug
	Broker Config Log	central	sql	trace
	Clear Retention
	${start}=	Get Current Date
	Start Engine
	Sleep	2s
	Start Broker

	# We need to wait a little before reloading Engine
	${result}=	check resources tags With Timeout	0	9	hostgroup	[2]	60
	Should Be True	${result}	msg=First step: resource 9 should have hostgroup tag with id=2

	${result}=	check resources tags With Timeout	0	10	hostgroup	[2]	60
	Should Be True	${result}	msg=First step: resource 10 should have hostgroup tag with id=2

	${result}=	check resources tags With Timeout	0	11	hostgroup	[6]	60
	Should Be True	${result}	msg=First step: resource 11 should have hostgroup tag with id=6

	${result}=	check resources tags With Timeout	0	12	hostgroup	[6]	60
	Should Be True	${result}	msg=First step: resource 12 should have hostgroup tag with id=6

	${result}=	check resources tags With Timeout	0	30	hostgroup	[8]	60
	Should Be True	${result}	msg=First step: resource 30 should have hostgroup tag with id=10

	${result}=	check resources tags With Timeout	0	31	hostgroup	[8]	60
	Should Be True	${result}	msg=First step: resource 31 should have hostgroup tag with id=10

	${result}=	check resources tags With Timeout	0	32	hostgroup	[9]	60
	Should Be True	${result}	msg=First step: resource 32 should have hostgroup tag with id=14

	${result}=	check resources tags With Timeout	0	33	hostgroup	[9]	60
	Should Be True	${result}	msg=First step: host 33 should have hostgroup tag with id=14

	Stop Engine
	Kindly Stop Broker