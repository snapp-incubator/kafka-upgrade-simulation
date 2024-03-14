#! /bin/python3.8

import os 

script_path = os.path.dirname(os.path.abspath(__file__))
env_prefix = "CONNECT"
properties_file_name = "kafka-connect"
configs_override = {
    "client.id" : "kafka_upgrade_simulation",
    "producer.client.id" : "kafka_upgrade_simulation",
    "consumer.client.id" : "kafka_upgrade_simulation",
    "key.converter.schema.registry.url" : "'http://schema-registry:8081'",
    "value.converter.schema.registry.url" : "'http://schema-registry:8081'",
    "rest.advertised.host.name" : "\"debezium\"",
    "security.protocol" : "SASL_PLAINTEXT",
    "sasl.jaas.config" : "org.apache.kafka.common.security.scram.ScramLoginModule required username=\"debezium\" password=\"12345\";",
    "sasl.mechanism" : "SCRAM-SHA-512",
    "producer.security.protocol" : "SASL_PLAINTEXT",
    "producer.sasl.jaas.config" : "org.apache.kafka.common.security.scram.ScramLoginModule required username=\"debezium\" password=\"12345\";",
    "producer.sasl.mechanism" : "SCRAM-SHA-512",
    "consumer.security.protocol" : "SASL_PLAINTEXT",
    "consumer.sasl.jaas.config" : "org.apache.kafka.common.security.scram.ScramLoginModule required username=\"debezium\" password=\"12345\";",
    "consumer.sasl.mechanism" : "SCRAM-SHA-512"
}
configs_extra = [
    "BOOTSTRAP_SERVERS=kafka1:9092,kafka2:9092,kafka3:9092",
    "GROUP_ID=1",
    "CONFIG_STORAGE_TOPIC=my_connect_configs",
    "OFFSET_STORAGE_TOPIC=my_connect_offsets",
    "STATUS_STORAGE_TOPIC=my_connect_statuses",
    "INTERNAL_KEY_CONVERTER=org.apache.kafka.connect.json.JsonConverter",
    "INTERNAL_VALUE_CONVERTER=org.apache.kafka.connect.json.JsonConverter"
]
configs_to_ignore:list[str] = []

with open(
    os.path.join(script_path,properties_file_name+'.properties')
) as fp:
    configs_raw = fp.readlines()

configs = ""
for line in configs_raw:
    if line.strip() == '' or line.startswith("#"):
        continue
    else:
        conf_val_raw = line.strip().split('=')
        conf = conf_val_raw[0]
        if conf in configs_to_ignore:
            continue
        elif conf in configs_override:
            val = configs_override[conf]
        else:
            val = '='.join(conf_val_raw[1:])
        configs += f"{env_prefix}_{conf.replace('.','_').upper()}={val}\n"

for c in configs_extra:
    configs += c+'\n'

configs = configs.strip('\n')

with open(
    os.path.join(script_path,f"{properties_file_name}.env"),
    "w"
) as fp:
    fp.write(configs)
