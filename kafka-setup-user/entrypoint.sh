#!/bin/bash

set -e


# Run the Kafka commands

# Admin user
kafka-configs.sh --zookeeper zookeeper1:2181,zookeeper2:2181,zookeeper3:2181 --alter --add-config 'SCRAM-SHA-512=[password='12345']' --entity-type users --entity-name admin
kafka-acls.sh --authorizer-properties zookeeper.connect=zookeeper1:2181,zookeeper2:2181,zookeeper3:2181 --add --allow-principal User:admin --allow-host '*' --operation All --cluster --group '*' 

# Clickhouse user
kafka-configs.sh --zookeeper zookeeper1:2181,zookeeper2:2181,zookeeper3:2181 --alter --add-config 'SCRAM-SHA-512=[password='12345']' --entity-type users --entity-name clickhouse
kafka-acls.sh --authorizer-properties zookeeper.connect=zookeeper1:2181,zookeeper2:2181,zookeeper3:2181 --add --allow-principal User:clickhouse --allow-host '*' --operation Read --topic '*' --group '*' 

# Producer user
kafka-configs.sh --zookeeper zookeeper1:2181,zookeeper2:2181,zookeeper3:2181 --alter --add-config 'SCRAM-SHA-512=[password='12345']' --entity-type users --entity-name producer
kafka-acls.sh --authorizer-properties zookeeper.connect=zookeeper1:2181,zookeeper2:2181,zookeeper3:2181 --add --allow-principal User:producer --allow-host '*' --operation Write --topic test-topic

# Consumer user 
kafka-configs.sh --zookeeper zookeeper1:2181,zookeeper2:2181,zookeeper3:2181 --alter --add-config 'SCRAM-SHA-512=[password='12345']' --entity-type users --entity-name consumer
kafka-acls.sh --authorizer-properties zookeeper.connect=zookeeper1:2181,zookeeper2:2181,zookeeper3:2181 --add --allow-principal User:consumer --allow-host '*' --operation Read --topic test-topic --group '*' 

# debezium user 
kafka-configs.sh --zookeeper zookeeper1:2181,zookeeper2:2181,zookeeper3:2181 --alter --add-config 'SCRAM-SHA-512=[password='12345']' --entity-type users --entity-name debezium
kafka-acls.sh --authorizer-properties zookeeper.connect=zookeeper1:2181,zookeeper2:2181,zookeeper3:2181 --add --allow-principal User:debezium --allow-host '*' --operation Read  --operation Describe --topic '*' --group '*' 
kafka-acls.sh --authorizer-properties zookeeper.connect=zookeeper1:2181,zookeeper2:2181,zookeeper3:2181 --add --allow-principal User:debezium --allow-host '*' --operation Write --topic '*'



# Client ID
kafka-configs.sh --zookeeper zookeeper1:2181,zookeeper2:2181,zookeeper3:2181 --alter --add-config "producer_byte_rate=10485760,consumer_byte_rate=10485760,request_percentage=100" --entity-type clients --entity-name kafka_upgrade_simulation

# If all commands succeed, print success message
echo "Users and client_id added to zookeeper sucessfully"

# In order to exit with status=0
touch /tmp/kafka-setup-success