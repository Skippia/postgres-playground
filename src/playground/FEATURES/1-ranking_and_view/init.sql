BEGIN;

CREATE TABLE sales_data (
    region VARCHAR(50),
    salesperson_id INT,
    total_sales NUMERIC(12, 2),
    sales_date DATE
);

INSERT INTO
    sales_data (
        region,
        salesperson_id,
        total_sales,
        sales_date
    )
VALUES (
        'North',
        1,
        1000.00,
        '2025-03-01'
    ),
    (
        'North',
        1,
        1500.00,
        '2025-03-05'
    ),
    (
        'North',
        1,
        2000.00,
        '2025-03-10'
    ),
    (
        'North',
        2,
        3000.00,
        '2025-03-02'
    ),
    (
        'North',
        2,
        2500.00,
        '2025-03-12'
    ),
    (
        'North',
        3,
        4000.00,
        '2025-03-03'
    ),
    (
        'North',
        3,
        1000.00,
        '2025-03-15'
    );

INSERT INTO
    sales_data (
        region,
        salesperson_id,
        total_sales,
        sales_date
    )
VALUES (
        'South',
        4,
        5000.00,
        '2025-03-04'
    ),
    (
        'South',
        4,
        3000.00,
        '2025-03-08'
    ),
    (
        'South',
        5,
        2000.00,
        '2025-03-06'
    ),
    (
        'South',
        5,
        4000.00,
        '2025-03-20'
    );

CREATE VIEW monthly_sales AS 
SELECT
    region,
    salesperson_id,
    SUM(total_sales) AS monthly_total
FROM sales_data
WHERE
    sales_date >= '2025-03-01'
    AND sales_date < '2025-04-01'
GROUP BY
    region,
    salesperson_id;

CREATE VIEW ranked_sales AS 
SELECT
    region,
    salesperson_id,
    monthly_total,
    RANK() OVER (
        PARTITION BY region
        ORDER BY monthly_total DESC
    ) AS sales_rank
FROM monthly_sales;

COMMIT;
