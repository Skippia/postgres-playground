BEGIN;
-- Create a product catalog with search capabilities
 
-- This SQL query creates a product catalog table with intelligent search capabilities. 
-- The table includes basic fields like id, name, description, and an array of categories, 
-- but its key feature is the search_vector column, which automatically generates and stores a weighted search index. 

-- The search index combines three levels of search priority: 
--   - product names (weight 'A' for highest importance), 
--   - descriptions (weight 'B' for medium importance), 
--   - and categories (weight 'C' for lowest importance). 

-- The COALESCE functions prevent NULL values from breaking the index generation, while `array_to_string` converts 
-- the category array into searchable text. 

-- This structure allows for highly relevant search results where matches in the product name will rank higher
--  than matches in the description or categories.

CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    categories TEXT[],
    search_vector tsvector GENERATED ALWAYS AS (
        setweight(to_tsvector('english', coalesce(name, '')), 'A') ||
        setweight(to_tsvector('english', coalesce(description, '')), 'B') ||
        setweight(to_tsvector('english', coalesce(array_to_string(categories, ' '), '')), 'C')
    ) STORED
);

-- Create an index for efficient searching
CREATE INDEX products_search_idx ON products USING GIN (search_vector);

-- Insert sample data
INSERT INTO products (name, description, categories) VALUES
    ('PostgreSQL Database Server', 
     'High-performance open-source relational database',
     ARRAY['software', 'database', 'open-source']),
    ('MySQL Database', 
     'Popular open-source database management system',
     ARRAY['software', 'database', 'open-source']);

-- Perform a complex search
CREATE VIEW search_results AS
SELECT 
    name,
    ts_rank(search_vector, query) as rank
FROM 
    products,
    to_tsquery('english', 'database & (postgresql | mysql) & !oracle') query
WHERE search_vector @@ query
ORDER BY rank DESC;

-- Search with phrase matching
CREATE VIEW search_phrase_matching AS
SELECT 
    name,
    ts_rank(search_vector, query) as rank
FROM 
    products,
    phraseto_tsquery('english', 'open source database') query
WHERE search_vector @@ query
ORDER BY rank DESC;

COMMIT;
