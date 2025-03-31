BEGIN;
DROP MATERIALIZED VIEW IF EXISTS mv_orders_summary;
DROP TABLE IF EXISTS orders CASCADE;
DROP FUNCTION IF EXISTS fn_refresh_orders_summary_and_notify;
COMMIT;
