BEGIN;

CREATE TABLE IF NOT EXISTS orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    order_date DATE NOT NULL,
    order_amount NUMERIC(10, 2) NOT NULL
);

CREATE TABLE IF NOT EXISTS orders_archive (
    order_id INTEGER PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    order_date DATE NOT NULL,
    order_amount NUMERIC(10, 2) NOT NULL,
    archived_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO orders (customer_id, order_date, order_amount) VALUES
    (1, '2019-06-15', 150.00),
    (2, '2020-02-20', 200.00),
    (3, '2018-11-11', 300.00),
    (4, '2019-12-05', 450.00),
    (5, '2021-01-15', 500.00);

CREATE OR REPLACE PROCEDURE archive_old_orders()
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO orders_archive (order_id, customer_id, order_date, order_amount)
    SELECT order_id, customer_id, order_date, order_amount
    FROM orders
    WHERE order_date < '2020-01-01';

    DELETE FROM orders
    WHERE order_date < '2020-01-01';
END;
$$;

COMMIT;
