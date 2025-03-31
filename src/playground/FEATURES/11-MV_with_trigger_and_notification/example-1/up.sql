CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date TIMESTAMPTZ NOT NULL DEFAULT now(),
    total_amount NUMERIC(10, 2) NOT NULL,
    status TEXT NOT NULL DEFAULT 'pending'
);

CREATE MATERIALIZED VIEW mv_orders_summary
AS
  SELECT
    order_date::date AS order_day,
    status,
    COUNT(*) AS order_count,
    SUM(total_amount) AS total_revenue
  FROM orders
  GROUP BY order_date::date, status
WITH DATA;

-- To allow concurrent refresh, create a unique index on the materialized view.
CREATE UNIQUE INDEX mv_orders_summary_idx ON mv_orders_summary (order_day, status);

CREATE OR REPLACE FUNCTION fn_refresh_orders_summary_and_notify()
RETURNS TRIGGER AS $$
BEGIN
    -- Refresh the materialized view concurrently.
    -- Note: Refreshing concurrently requires that the materialized view has a unique index.
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_orders_summary;

    PERFORM pg_notify('orders_changes', 'Orders table updated');

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_orders_change
AFTER INSERT OR UPDATE OR DELETE ON orders
FOR EACH STATEMENT
EXECUTE FUNCTION fn_refresh_orders_summary_and_notify();
