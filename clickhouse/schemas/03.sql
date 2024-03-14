create table IF NOT EXISTS kafka_test.kafka (
    `id` UInt32,
    `name` String,
    `created_at` String
)
ENGINE = Kafka()
SETTINGS
    kafka_broker_list = 'kafka1:9092,kafka2:9092,kafka3:9092',
    kafka_topic_list = 'test-topic',
    kafka_group_name = 'clickhouse_kafka_consumer',
    kafka_format = 'AvroConfluent',
    format_avro_schema_registry_url = 'http://schema-registry:8081'
