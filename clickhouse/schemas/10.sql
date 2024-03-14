CREATE MATERIALIZED VIEW IF NOT EXISTS kafka_test.consumer__orders TO kafka_test.stream_orders
(
    `id` Int64,
    `order_date` Date,
    `purchaser` Int64,
    `quantity` Int64,
    `product_id` Int64,
    `pipeline_type` LowCardinality(String),
    `kafka_time` DateTime,
    `kafka_offset` UInt64,
    `clickhouse_time` DateTime
) AS
SELECT
    coalesce(id, 0) AS id,
    order_date AS order_date,
    coalesce(purchaser, 0) AS purchaser,
    coalesce(quantity, 0) AS quantity,
    coalesce(product_id, 0) AS product_id,
    'stream' AS pipeline_type,
    _timestamp AS kafka_time,
    _offset AS kafka_offset,
    now() AS clickhouse_time
FROM kafka_test.kafka__orders