BEGIN;

DROP TABLE IF EXISTS employees;

COMMIT;

BEGIN;

-- Drop products table first due to dependency
DROP TABLE IF EXISTS products;

-- Drop product_groups table
DROP TABLE IF EXISTS product_groups;

COMMIT;
