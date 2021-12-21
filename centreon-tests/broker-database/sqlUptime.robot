*** Settings ***
Resource            ../resources/resources.robot
Suite Setup         Clean Before Suite
Suite Teardown      Clean After Suite
Test Setup          Stop Processes

Documentation       Centreon Broker database connections status and timestamp through grpc
Library             Process
Library             DateTime
Library             OperatingSystem
Library				../resources/Common.py
Library				../resources/Broker.py
Library				../resources/Engine.py
Library             ../resources/Grpc.py

*** Test Cases ***
StatsDBConnectionsStatusTimestamp1
    [Documentation]
    [Tags]      Broker      Database    Grpc    Stats
    Database Status Timestamp Stats Test        conn=1

StatsDBConnectionsStatusTimestamp2
    [Documentation]
    [Tags]      Broker      Database    Grpc    Stats
    Database Status Timestamp Stats Test        conn=2

StatsDBConnectionsStatusTimestamp3
    [Documentation]
    [Tags]      Broker      Database    Grpc    Stats
    Database Status Timestamp Stats Test        conn=3

StatsDBConnectionsStatusTimestamp4
    [Documentation]
    [Tags]      Broker      Database    Grpc    Stats
    Database Status Timestamp Stats Test        conn=4

StatsDBConnectionsStatusTimestamp5
    [Documentation]
    [Tags]      Broker      Database    Grpc    Stats
    Database Status Timestamp Stats Test        conn=5

StatsDBConnectionsStatusTimestamp6
    [Documentation]
    [Tags]      Broker      Database    Grpc    Stats
    Database Status Timestamp Stats Test        conn=6

*** Keywords ***
Mysql Connection Size Json Request
    ${location}=        Set Variable            /var/lib/centreon-broker/central-broker-master-stats.json
    ${key1}=            Set Variable            mysql manager
    ${key2}=            Set Variable            size
    ${res}=             Json Stats Request      location=${location}        key1=${key1}        key2=${key2}
    [return]            ${res}
Mysql Connection Size Grpc Request
    ${component}=       Set Variable            broker
    ${exe}=             Set Variable            GetSqlConnectionSize
    ${key1}=            Set Variable            size
    ${res}=             Grpc Stats Request      component=${component}      exe=${exe}          key1=${key1}
    [return]            ${res}
Mysql Connection Stats Json Request
    [arguments]         ${idx}
    ${location}=        Set Variable            /var/lib/centreon-broker/central-broker-master-stats.json
    ${key1}=            Set Variable            mysql manager
    ${key2}=            Set Variable            connection_${idx}
    ${res}              Json Stats Request      location=${location}        key1=${key1}        key2=${key2}
    [return]            ${res}
Mysql Connection Stats Connected Grpc Request
    [arguments]         ${idx}
    ${component}=       Set Variable            broker
    ${exe}=             Set Variable            GetSqlConnectionStats
    ${arg}=             Set Variable            {\"value\": ${idx}}
    ${key1}=            Set Variable            is_connected
    ${res}=             Grpc Stats Request Args                             component=${component}      exe=${exe}              key1=${key1}            arg=${arg}
    [return]            ${res}
Mysql Connection Stats Since Grpc Request
    [arguments]         ${idx}                  ${connected}
    ${component}=       Set Variable            broker
    ${exe}=             Set Variable            GetSqlConnectionStats
    ${arg}=             Set Variable            {\"value\": ${idx}}
    ${key1}=            Set Variable If         ${connected} == True        up_since
    ${key1}=            Set Variable If         ${connected} == False       down_since
    ${res}=             Grpc Stats Request Args                             component=${component}      exe=${exe}              key1=${key1}            arg=${arg}
    [return]            ${res}
Database Status Timestamp Stats Test
    [Arguments]     ${conn}
    Config Engine   ${1}
    Config Broker   module
    Config Broker   rrd
    Config Broker   central
    Broker Config Output Set        central     central-broker-master-sql       db_host                 127.0.0.1
    Broker Config Output Set        central     central-broker-master-perfdata  db_host                 127.0.0.1
    Broker Config Output Set        central     central-broker-master-sql       connections_count       ${conn}
    Broker Config Output Set        central     central-broker-master-perfdata  connections_count       ${conn}
    Broker Config Log               central     sql                             trace
    Start Broker
    Start Engine
    ${sizeJson}                     ${sizeJsonValue}=                           Mysql Connection Size Json Request
    ${sizeGrpc}                     ${sizeGrpcValue}=                           Mysql Connection Size Grpc Request
    Should Be True                  ${sizeJson}
    Should Be True                  ${sizeGrpc}
    Should Be Equal As Integers     ${sizeJsonValue}                            ${conn}
    Should Be Equal As Integers     ${sizeGrpcValue}                            ${conn}
    FOR                             ${idx}              IN RANGE                ${conn}
        ${connectionJson}           ${connectionJsonValue}=                     Mysql Connection Stats Json Request             idx=${idx}
        Should Be True              ${connectionJson}
        ${connectionJsonMatch}      ${connectionJsonValueConnected}             ${connectionJsonValueSince}=                    Should Match regexp     ${connectionJsonValue}                          ^connected: (true|false), since: (\\d+)

        ${connectionGrpc}           ${connectionGrpcConnectedValue}=            Mysql Connection Stats Connected Grpc Request   idx=${idx}
        Should Be True              ${connectionGrpc}

        ${connectionGrpc}           ${connectionGrpcSinceValue}=                Mysql Connection Stats Since Grpc Request       idx=${idx}              connected=${connectionGrpcConnectedValue}
        Should Be True              ${connectionGrpc}

        Should Be Equal                                                         ${connectionJsonValueConnected}                 ${connectionGrpcConnectedValue}
        Should Be Equal As Integers                                             ${connectionJsonValueSince}                     ${connectionGrpcSinceValue}
    END
    Stop Broker
    Stop Engine

*** Variables ***

#broker is connected to the database
#broker lost the connection to the database
#broker restored its connection to the database

#not reported as disconnected when restart after iptables drop
#or when droping iptables while running
#both in sql manager output and grpc stats
#should come from non corrrectly setted variables inside sql connection

#seems to have some issues with multithreading
#values seems to be not set

#RUN	iptables -A INPUT -p tcp --dport ${port} -j DROP
#RUN	iptables -A OUTPUT -p tcp --dport ${port} -j DROP
#RUN	iptables -A FORWARD -p tcp --dport ${port} -j DROP

#RUN	iptables -F
#RUN	iptables -X

#{
#  "connections": [
#    {
#      "waiting_tasks": 0,
#      "is_connected": false
#    }
#  ]
#}
#{
#  "size": 1
#}

#{
#  "waiting_tasks": 1,
#  "is_connected": true,
#  "up_since": "1640101108"
#}