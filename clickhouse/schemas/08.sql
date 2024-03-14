CREATE TABLE IF NOT EXISTS kafka_test.kafka__orders
(
    `id` Int64,
    `order_date` Date,
    `purchaser` Int64,
    `quantity` Int64,
    `product_id` Int64
)
ENGINE = Kafka()
SETTINGS 
kafka_topic_list = 'debezium_cdc.inventory.orders',
kafka_group_name = 'clickhouse_cdc_kafka_on_premise_kafka_kafka_test_orders',
kafka_format = 'AvroConfluent',
kafka_broker_list = 'kafka1:9092,kafka2:9092,kafka3:9092',
format_avro_schema_registry_url = 'http://schema-registry:8081'