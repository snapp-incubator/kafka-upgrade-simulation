CREATE TABLE IF NOT EXISTS kafka_test.kafka__customer
(
    `id` Int64,
    `first_name` String,
    `last_name` String,
    `email` String
)
ENGINE = Kafka()
SETTINGS 
kafka_topic_list = 'debezium_cdc.inventory.customers',
kafka_group_name = 'clickhouse_cdc_kafka_on_premise_kafka_kafka_test_customer',
kafka_broker_list = 'kafka1:9092,kafka2:9092,kafka3:9092',
kafka_format = 'AvroConfluent',
format_avro_schema_registry_url = 'http://schema-registry:8081'