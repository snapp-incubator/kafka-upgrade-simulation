CREATE MATERIALIZED VIEW IF NOT EXISTS kafka_test.consumer__products_on_hand TO kafka_test.stream_products_on_hand
(
    `product_id` Int64,
    `quantity` Int64,
    `pipeline_type` LowCardinality(String),
    `kafka_time` DateTime,
    `kafka_offset` UInt64,
    `clickhouse_time` DateTime
) AS
SELECT
    coalesce(product_id, 0) AS product_id,
    coalesce(quantity, 0) AS quantity,
    'stream' AS pipeline_type,
    _timestamp AS kafka_time,
    _offset AS kafka_offset,
    now() AS clickhouse_time
FROM kafka_test.kafka__products_on_hand