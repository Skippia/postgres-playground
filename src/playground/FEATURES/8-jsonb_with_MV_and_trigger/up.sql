BEGIN;

CREATE TABLE products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    sku TEXT NOT NULL UNIQUE,
    price NUMERIC(10,2) NOT NULL,
    attributes JSONB NOT NULL DEFAULT '{}'::JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);


CREATE TABLE orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    status TEXT NOT NULL CHECK (status IN ('pending', 'completed', 'canceled')),
    line_items JSONB NOT NULL,
    shipping_address JSONB,
    metadata JSONB NOT NULL DEFAULT '{}'::JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON COLUMN products.attributes IS 'Dynamic product attributes (e.g., size, color, specs)';
COMMENT ON COLUMN orders.line_items IS 'Array of order items with product details';
COMMENT ON COLUMN orders.shipping_address IS 'Structured address information';
COMMENT ON COLUMN orders.metadata IS 'Additional order processing metadata';

CREATE INDEX idx_products_attributes ON products USING GIN (attributes);
CREATE INDEX idx_orders_line_items ON orders USING GIN (line_items);
CREATE INDEX idx_orders_metadata ON orders USING GIN (metadata);

-- Materialized view for product attributes aggregation
CREATE MATERIALIZED VIEW product_specs AS
SELECT
    id,
    name,
    attributes->>'brand' AS brand,
    jsonb_path_query_array(attributes, '$.sizes[*].value') AS available_sizes,
    (attributes#>>'{weight,value}')::NUMERIC AS weight,
    attributes->'dimensions' AS dimensions
FROM products
WHERE attributes ? 'brand';

CREATE OR REPLACE FUNCTION refresh_product_specs()
RETURNS TRIGGER AS $$
BEGIN
    REFRESH MATERIALIZED VIEW product_specs;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Trigger for automatic refresh (might want to schedule instead?)
CREATE TRIGGER refresh_product_specs_trigger
AFTER INSERT OR UPDATE OR DELETE ON products
FOR EACH STATEMENT
EXECUTE FUNCTION refresh_product_specs();

-- Function to calculate total sales by category
CREATE OR REPLACE FUNCTION total_category_sales(category_name TEXT)
RETURNS NUMERIC AS $$
DECLARE
    total NUMERIC;
BEGIN
    SELECT SUM((item->>'quantity')::NUMERIC * (item->>'price')::NUMERIC)
    INTO total
    FROM orders,
    jsonb_array_elements(orders.line_items) item
    WHERE item->>'category' = category_name AND orders.status = 'completed';

    RETURN total;
END;
$$ LANGUAGE plpgsql STABLE;

COMMIT;

BEGIN;

-- Insert products with JSONB attributes
INSERT INTO products (name, sku, price, attributes) VALUES
('Premium Laptop', 'LT-1001', 1499.99,
 '{
   "brand": "TechMaster",
   "specs": {
     "processor": "Intel i7",
     "ram": "32GB",
     "storage": "1TB SSD"
   },
   "sizes": [
     {"value": "15-inch", "stock": 50},
     {"value": "17-inch", "stock": 25}
   ],
   "weight": {"value": 1.5, "unit": "kg"},
   "dimensions": {"width": 35, "height": 24, "depth": 2}
 }'),
('Wireless Headphones', 'HP-2002', 299.99,
 '{
   "brand": "AudioPro",
   "color_options": ["black", "silver"],
   "wireless": true,
   "battery_life": {"value": 30, "unit": "hours"}
 }');

-- Insert orders with JSONB line items
INSERT INTO orders (user_id, status, line_items, shipping_address) VALUES
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'completed',
 '[{
    "product_id": "LT-1001",
    "name": "Premium Laptop",
    "quantity": 2,
    "price": 1499.99,
    "category": "electronics",
    "options": {"size": "15-inch", "color": "silver"}
  }]',
 '{
   "street": "123 Main St",
   "city": "Techville",
   "state": "CA",
   "zip": "90210",
   "country": "USA"
 }'),
('b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22', 'pending',
 '[{
    "product_id": "HP-2002",
    "name": "Wireless Headphones",
    "quantity": 1,
    "price": 299.99,
    "category": "audio",
    "options": {"color": "black"}
  }]',
 '{
   "street": "456 Oak Rd",
   "city": "Sound City",
   "state": "NY",
   "zip": "10001",
   "country": "USA"
 }');

COMMIT;
