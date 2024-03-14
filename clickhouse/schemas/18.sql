CREATE TABLE IF NOT EXISTS kafka_test.stream_spatial_ref_sys
(
    `srid` Int64,
    `auth_name` Nullable(String),
    `auth_srid` Nullable(Int64),
    `srtext` Nullable(String),
    `proj4text` Nullable(String),
    `pipeline_type` LowCardinality(String),
    `kafka_time` DateTime,
    `kafka_offset` UInt64,
    `clickhouse_time` DateTime
)
ENGINE = MergeTree()
ORDER BY tuple()
SETTINGS index_granularity = 8192;