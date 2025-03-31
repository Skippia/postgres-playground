CREATE EXTENSION IF NOT EXISTS pg_ivm;

CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date TIMESTAMPTZ NOT NULL DEFAULT now(),
    total_amount NUMERIC(10, 2) NOT NULL,
    status TEXT NOT NULL DEFAULT 'pending'
);

SELECT pgivm.create_immv (
  'mv_orders_summary', 
  'SELECT 
     (order_date AT TIME ZONE ''UTC'')::date AS order_day,
     status,
     COUNT(*) AS order_count,
     SUM(total_amount) AS total_revenue
   FROM orders
   GROUP BY (order_date AT TIME ZONE ''UTC'')::date, status;'
);
