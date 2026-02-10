BEGIN;
-- Create a product catalog with search capabilities
/** 
This SQL query creates a product catalog table with intelligent search capabilities. 
The table includes basic fields like id, name, description, and an array of categories, 
but its key feature is the search_vector column, which automatically generates and stores a weighted search index. 

The search index combines three levels of search priority: 
  - product names (weight 'A' for highest importance), 
  - descriptions (weight 'B' for medium importance), 
  - and categories (weight 'C' for lowest importance). 

The COALESCE functions prevent NULL values from breaking the index generation, while `array_to_string` converts 
the category array into searchable text. 

This structure allows for highly relevant search results where matches in the product name will rank higher
 than matches in the description or categories.
**/

CREATE OR REPLACE FUNCTION immutable_array_to_string(text[], text) 
RETURNS text as $$ 
BEGIN
 RETURN array_to_string($1, $2);
END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    categories TEXT[],
    search_vector tsvector GENERATED ALWAYS AS (
        setweight(to_tsvector('english', coalesce(name, '')), 'A') ||
        setweight(to_tsvector('english', coalesce(description, '')), 'B') ||
        setweight(to_tsvector('english', coalesce(immutable_array_to_string(categories, ' '), '')), 'C')
    ) STORED
);

CREATE INDEX products_search_idx ON products USING GIN (search_vector);

INSERT INTO products (name, description, categories) VALUES
    ('PostgreSQL Database Server', 
     'High-performance relational open-source database',
     ARRAY['software', 'database', 'open-source']),
    ('MySQL Database', 
     'Popular (RDBMS) open-source database management system',
     ARRAY['software', 'database', 'open-source']),
    ('Random Database', 
     '(RDBMS) Popular open source database',
     ARRAY['software', 'database', 'open-source', 'oracle']);

-- Search with keywords (1)
CREATE VIEW search_results AS
SELECT 
    name,
    ts_rank(search_vector, query) as rank
FROM 
    products,
    to_tsquery('english', 'database & (postgresql | mysql) & !oracle') query
WHERE search_vector @@ query
ORDER BY rank DESC;

-- Search with phrase matching (2)
CREATE VIEW search_phrase_matching AS
SELECT 
    name,
    ts_rank(search_vector, query) as rank
FROM 
    products,
    phraseto_tsquery('english', 'open source database') query
WHERE search_vector @@ query
ORDER BY rank DESC;

-- Search with phrase matching regardless of the distance between words (3)
CREATE VIEW search_phrase_matching2 AS
SELECT 
    name,
    ts_rank(search_vector, query) as rank
FROM 
    products,
    phraseto_tsquery('english', 'high-performance & of & open-source') query
WHERE search_vector @@ query
ORDER BY rank DESC;

-- Search with phrase exact order (4)
CREATE VIEW search_phrase_exact_order AS
SELECT 
    name,
    ts_rank(search_vector, query) as rank
FROM 
    products,
    to_tsquery('english', 'RDBMS <-> popular') query
WHERE search_vector @@ query
ORDER BY rank DESC;

CREATE VIEW search_phrase_headline AS
SELECT 
    name,
    ts_headline('english', description, query) as context
FROM 
    products,
    to_tsquery('RDBMS <-> popular') query
WHERE search_vector @@ query;

COMMIT;
