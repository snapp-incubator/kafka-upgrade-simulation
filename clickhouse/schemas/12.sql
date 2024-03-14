CREATE TABLE  IF NOT EXISTS kafka_test.stream_products (
    `id` Int64,
    `name` String,
    `description` Nullable(String),
    `weight` Nullable(Float64),
    `pipeline_type` LowCardinality(String),
    `kafka_time` DateTime,
    `kafka_offset` UInt64,
    `clickhouse_time` DateTime
)
ENGINE = MergeTree()
ORDER BY tuple()
SETTINGS index_granularity = 8192