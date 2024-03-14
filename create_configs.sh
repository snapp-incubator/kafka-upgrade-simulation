#! /bin/bash

# python version should be 3.6 or higher
# Create configs for zookeeper
python3 zookeeper/zookeeper_conf_creator.py
# Create configs for kafka connect
python3 debezium/kafka_connect_config_generator.py
# Create configs for schema resigstry
python3 schema-registry/schema_registry_config_creator.py 
# Create configs for kafka
python3 kafka/kafka_env_creator.py  