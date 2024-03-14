CREATE MATERIALIZED VIEW IF NOT EXISTS kafka_test.consumer__customer
TO kafka_test.stream_customer
(
    `id` Int64,
    `first_name` String,
    `last_name` String,
    `email` String,
    `pipeline_type` LowCardinality(String),
    `kafka_time` DateTime,
    `kafka_offset` UInt64,
    `clickhouse_time` DateTime
) AS
SELECT
    coalesce(id, 0) AS id,
    coalesce(first_name, '') AS first_name,
    coalesce(last_name, '') AS last_name,
    coalesce(email, '') AS email,
    'stream' AS pipeline_type,
    _timestamp AS kafka_time,
    _offset AS kafka_offset,
    now() AS clickhouse_time
FROM kafka_test.kafka__customer