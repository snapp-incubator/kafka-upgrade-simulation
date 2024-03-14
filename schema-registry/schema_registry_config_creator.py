#! /bin/python3.8

import os 

script_path = os.path.dirname(os.path.abspath(__file__))
env_prefix = "SCHEMA_REGISTRY"
properties_file_name = "schema-registry"
configs_override = {
    "host.name" : "schema-registry",
    "kafkastore.bootstrap.servers" : "kafka1:9092,kafka2:9092,kafka3:9092",
    "listeners" : "http://schema-registry:8081",
    "kafkastore.security.protocol" : "SASL_PLAINTEXT",
    "kafkastore.sasl.mechanism" : "SCRAM-SHA-512",
    "kafkastore.client.id" : "kafka_upgrade_simulation"
}
configs_extra = [
    "JAVA_TOOL_OPTIONS=-Djava.security.auth.login.config=/app/kafka_client_jaas.conf",
    "SCHEMA_REGISTRY_HOST_NAME=schema-registry"
]
configs_to_ignore:list[str] = []

with open(
    os.path.join(script_path,properties_file_name + '.properties')
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
