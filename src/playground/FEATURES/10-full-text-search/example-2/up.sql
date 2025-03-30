BEGIN;

CREATE EXTENSION IF NOT EXISTS pg_cron;

-- Create the search schema if it does not already exist
CREATE SCHEMA IF NOT EXISTS search;

-- Create the documents table with a generated full-text search vector column.
-- Note the explicit cast to regconfig, which makes to_tsvector immutable.
CREATE TABLE search.documents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    search_vector TSVECTOR GENERATED ALWAYS AS (
        setweight(to_tsvector('english'::regconfig, coalesce(title, '')), 'A') ||
        setweight(to_tsvector('english'::regconfig, coalesce(content, '')), 'B')
    ) STORED,
    metadata JSONB NOT NULL DEFAULT '{}',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON COLUMN search.documents.search_vector IS 'TSVECTOR for weighted title/content search';

CREATE INDEX idx_documents_search_vector ON search.documents USING GIN (search_vector) WITH (fastupdate = on);

-- Create a statistics table to keep track of how many times documents have been returned in search queries.
CREATE TABLE search.statistics (
    document_id UUID PRIMARY KEY,
    search_count INT NOT NULL DEFAULT 0,
    last_searched TIMESTAMPTZ
);

-- Create a search function that performs a full-text search and updates search statistics.
-- This function:
--  1. Converts the user query to a tsquery using websearch_to_tsquery with an explicit regconfig cast.
--  2. Retrieves matching documents, highlighting matching content via ts_headline.
--  3. Updates the search statistics (search_count and last_searched) for all returned documents.
CREATE OR REPLACE FUNCTION search.search_documents(
    search_query TEXT,
    limit_rows INT DEFAULT 100
)
RETURNS TABLE (
    id UUID,
    title TEXT,
    snippet TEXT,
    similarity double precision
)
AS $$
DECLARE
    tsq tsquery;
BEGIN
    -- Convert the search query to a tsquery using the specified language.
    tsq := websearch_to_tsquery('english'::regconfig, search_query);

    RETURN QUERY
    WITH results AS (
        SELECT 
            d.id,
            d.title,
            ts_headline(
                'english'::regconfig,
                d.content,
                tsq,
                'MaxWords=35, MinWords=15, StartSel=<mark>, StopSel=</mark>'
            ) AS snippet,
            ts_rank_cd(d.search_vector, tsq)::double precision AS similarity
        FROM search.documents d
        WHERE d.search_vector @@ tsq
        ORDER BY similarity DESC
        LIMIT limit_rows
    ),
    stats AS (
        INSERT INTO search.statistics (document_id, search_count, last_searched)
        SELECT r.id, 1, NOW()
        FROM results r
        ON CONFLICT (document_id)
        DO UPDATE SET 
            search_count = search.statistics.search_count + 1,
            last_searched = NOW()
        RETURNING document_id
    )
    -- Return the final search results.
    SELECT r.id, r.title, r.snippet, r.similarity
    FROM results r;
END;
$$ LANGUAGE plpgsql VOLATILE;

INSERT INTO search.documents (title, content, metadata)
VALUES
  (
    'PostgreSQL Database Server',
    'PostgreSQL is a powerful, open source object-relational database system with more than 30 years of development, offering advanced features and reliability.',
    '{"source": "community", "version": "16"}'
  ),
  (
    'MySQL Database',
    'MySQL is one of the world’s most popular open source relational database management systems, widely used in web applications.',
    '{"source": "community", "version": "8.0"}'
  ),
  (
    'MongoDB NoSQL Database',
    'MongoDB is a document-oriented NoSQL database used for high volume data storage, offering flexibility and scalability for modern applications.',
    '{"source": "official"}'
  );


-- Schedule a weekly maintenance job using pg_cron to optimize the search index.
SELECT cron.schedule('optimize-search-index', '0 4 * * 6', $$
    REINDEX INDEX CONCURRENTLY idx_documents_search_vector;
    ANALYZE search.documents;
$$);

COMMIT;
