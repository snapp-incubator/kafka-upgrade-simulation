create table IF NOT EXISTS kafka_test.base (
    `id` UInt32,
    `mat_id` Float32,
    `name` String,
    `mat_name` String,
    `created_at` DateTime,
    `created_date` Date
)
ENGINE = ReplacingMergeTree(created_at)
ORDER BY (created_date,id)
SETTINGS index_granularity = 8192