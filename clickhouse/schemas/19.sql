CREATE MATERIALIZED VIEW IF NOT EXISTS kafka_test.consumer__spatial_ref_sys TO kafka_test.stream_spatial_ref_sys
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
) AS
SELECT
    coalesce(srid, 0) AS srid,
    auth_name AS auth_name,
    auth_srid AS auth_srid,
    srtext AS srtext,
    proj4text AS proj4text,
    'stream' AS pipeline_type,
    _timestamp AS kafka_time,
    _offset AS kafka_offset,
    now() AS clickhouse_time
FROM kafka_test.kafka__spatial_ref_sys