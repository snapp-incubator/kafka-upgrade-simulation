#!/bin/bash

set -e

# Create a Kafka topics

# For producer
kafka-topics.sh --create --topic test-topic --zookeeper zookeeper1:2181,zookeeper2:2181,zookeeper3:2181 --partitions 2 --replication-factor 3 --if-not-exists 

# For debezium (internal)
kafka-topics.sh --create --topic my_connect_configs --zookeeper zookeeper1:2181,zookeeper2:2181,zookeeper3:2181 --partitions 1 --replication-factor 3 --config cleanup.policy=compact --if-not-exists
kafka-topics.sh --create --topic my_connect_offsets --zookeeper zookeeper1:2181,zookeeper2:2181,zookeeper3:2181 --partitions 1 --replication-factor 3 --config cleanup.policy=compact --if-not-exists
kafka-topics.sh --create --topic my_connect_statuses --zookeeper zookeeper1:2181,zookeeper2:2181,zookeeper3:2181 --partitions 1 --replication-factor 3 --config cleanup.policy=compact --if-not-exists

# For Debezium (tables)
kafka-topics.sh --create --topic debezium_cdc.inventory.customers --zookeeper zookeeper1:2181,zookeeper2:2181,zookeeper3:2181 --partitions 2 --replication-factor 3 --if-not-exists
kafka-topics.sh --create --topic debezium_cdc.inventory.geom --zookeeper zookeeper1:2181,zookeeper2:2181,zookeeper3:2181 --partitions 2 --replication-factor 3 --if-not-exists
kafka-topics.sh --create --topic debezium_cdc.inventory.orders --zookeeper zookeeper1:2181,zookeeper2:2181,zookeeper3:2181 --partitions 2 --replication-factor 3 --if-not-exists
kafka-topics.sh --create --topic debezium_cdc.inventory.products --zookeeper zookeeper1:2181,zookeeper2:2181,zookeeper3:2181 --partitions 2 --replication-factor 3 --if-not-exists
kafka-topics.sh --create --topic debezium_cdc.inventory.products_on_hand --zookeeper zookeeper1:2181,zookeeper2:2181,zookeeper3:2181 --partitions 2 --replication-factor 3 --if-not-exists
kafka-topics.sh --create --topic debezium_cdc.inventory.spatial_ref_sys --zookeeper zookeeper1:2181,zookeeper2:2181,zookeeper3:2181 --partitions 2 --replication-factor 3 --if-not-exists

# If all commands succeed, print success message
echo "topic created sucessfully"

# In order to exit with status=0
touch /tmp/kafka-setup-success