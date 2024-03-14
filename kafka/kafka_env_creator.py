import os 

script_path = os.path.dirname(os.path.abspath(__file__))
env_prefix = "KAFKA_CFG"
properties_file_name = "server"
number_of_brokers=3
configs_override = {
    "broker.id" : "{broker_id}",
    "listeners" : "SASL://kafka{broker_id}:9092",
    "advertised.listeners" : "SASL://kafka{broker_id}:9092",
}
configs_extra = [
    "ALLOW_PLAINTEXT_LISTENER=yes",
    "KAFKA_INTER_BROKER_USER=admin",
    "KAFKA_INTER_BROKER_PASSWORD=12345",
    "KAFKA_BROKER_USER=admin",
    "KAFKA_BROKER_PASSWORD=12345"
]
configs_to_ignore:list[str] = ['log.dirs']

with open(
    os.path.join(script_path,properties_file_name + '.properties')
) as fp:
    configs_raw = fp.readlines()

for broker_id in range(1,number_of_brokers+1):
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
                val = configs_override[conf].format(broker_id=broker_id)
            else:
                val = '='.join(conf_val_raw[1:])
            configs += f"{env_prefix}_{conf.replace('.','_').upper()}={val}\n"

    for c in configs_extra:
        configs += c+'\n'

    configs = configs.strip('\n')

    with open(
        os.path.join(script_path,f"{properties_file_name}{broker_id}.env"),
        "w"
    ) as fp:
        fp.write(configs)
