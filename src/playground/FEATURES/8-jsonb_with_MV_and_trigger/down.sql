BEGIN;

DROP TRIGGER IF EXISTS refresh_product_specs_trigger ON products;
DROP FUNCTION IF EXISTS refresh_product_specs();
DROP MATERIALIZED VIEW IF EXISTS product_specs;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP FUNCTION IF EXISTS total_category_sales;

COMMIT;
