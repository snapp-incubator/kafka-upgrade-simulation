CREATE MATERIALIZED VIEW IF NOT EXISTS kafka_test.consumer__products TO kafka_test.stream_products
(
    `id` Int64,
    `name` String,
    `description` Nullable(String),
    `weight` Nullable(Float64),
    `pipeline_type` LowCardinality(String),
    `kafka_time` DateTime,
    `kafka_offset` UInt64,
    `clickhouse_time` DateTime
) AS
SELECT
    coalesce(id, 0) AS id,
    coalesce(name, '') AS name,
    description AS description,
    weight AS weight,
    'stream' AS pipeline_type,
    _timestamp AS kafka_time,
    _offset AS kafka_offset,
    now() AS clickhouse_time
FROM kafka_test.kafka__products