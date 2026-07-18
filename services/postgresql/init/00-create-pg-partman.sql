-- pg_partman: 分区管理扩展。
-- 注意：pg_partman 5.x 只能装在 pg_catalog 之外的 schema，默认用 partman。
CREATE SCHEMA IF NOT EXISTS partman;
CREATE EXTENSION IF NOT EXISTS pg_partman SCHEMA partman;
