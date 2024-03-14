CREATE TABLE IF NOT EXISTS kafka_test.kafka__spatial_ref_sys 
(
    `srid` Int64,
    `auth_name` Nullable(String),
    `auth_srid` Nullable(Int64),
    `srtext` Nullable(String),
    `proj4text` Nullable(String)
)
ENGINE = Kafka()
SETTINGS kafka_topic_list = 'debezium_cdc.inventory.spatial_ref_sys',
kafka_group_name = 'clickhouse_cdc_kafka_on_premise_kafka_kafka_test_spatial_ref_sys',
kafka_broker_list = 'kafka1:9092,kafka2:9092,kafka3:9092',
kafka_format = 'AvroConfluent',
format_avro_schema_registry_url = 'http://schema-registry:8081'