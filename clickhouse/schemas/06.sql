CREATE TABLE IF NOT EXISTS kafka_test.stream_customer
(
    `id` Int64,
    `first_name` String,
    `last_name` String,
    `email` String,
    `pipeline_type` LowCardinality(String),
    `kafka_time` DateTime,
    `kafka_offset` UInt64,
    `clickhouse_time` DateTime
)
ENGINE = MergeTree()
ORDER BY tuple()
SETTINGS index_granularity = 8192;