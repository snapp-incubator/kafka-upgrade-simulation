create materialized view IF NOT EXISTS kafka_test.mat_view to kafka_test.base (
    `id` UInt32,
    `mat_id` Float32,
    `name` String,
    `mat_name` String,
    `created_at` DateTime,
    `created_date` Date
) as select 
    `id` as `id`,
    `id` / 100000 as `mat_id`,
    `name` as `name`,
    cityHash64(`name`) as `mat_name`,
    toDateTimeOrZero(`created_at`) as `created_at`,
    toDate(`created_at`) as `created_date`
from kafka_test.kafka
