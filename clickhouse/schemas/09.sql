CREATE TABLE IF NOT EXISTS kafka_test.stream_orders
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
)
ENGINE = MergeTree()
ORDER BY (toYYYYMM(order_date))
SETTINGS index_granularity = 8192;