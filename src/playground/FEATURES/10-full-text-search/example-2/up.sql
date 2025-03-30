BEGIN;

CREATE SCHEMA search;

CREATE TABLE search.documents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    language_code VARCHAR(3) NOT NULL DEFAULT 'eng',
    search_vector TSVECTOR GENERATED ALWAYS AS (
        setweight(to_tsvector('english', coalesce(title, '')), 'A') ||
        setweight(to_tsvector('english', coalesce(content, '')), 'B'
    ) STORED,
    metadata JSONB NOT NULL DEFAULT '{}',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
) WITH (fillfactor = 90);

COMMENT ON COLUMN search.documents.search_vector IS 'TSVECTOR for weighted title/content search';

-- Index for fast update
CREATE INDEX idx_documents_search_vector ON search.documents USING GIN (search_vector) WITH (fastupdate = on);

-- Index for language-specific searching
CREATE INDEX idx_documents_language ON search.documents (language_code);

CREATE TABLE search.statistics (
    document_id UUID REFERENCES search.documents(id) ON DELETE CASCADE,
    search_count INT NOT NULL DEFAULT 0,
    last_searched TIMESTAMPTZ,
    PRIMARY KEY (document_id)
) WITH (fillfactor = 100);

CREATE TABLE search.configurations (
    id SMALLINT PRIMARY KEY,
    config_name TEXT NOT NULL UNIQUE,
    stop_words TEXT[],
    dictionary JSONB NOT NULL DEFAULT '{}',
    boost_weights JSONB NOT NULL DEFAULT '{"title": 1.0, "content": 0.5}'
);

CREATE OR REPLACE FUNCTION search.to_tsvector_custom(lang TEXT, text TEXT)
RETURNS TSVECTOR AS $$
BEGIN
    RETURN to_tsvector(
        lang::regconfig
        -- Custom text normalization:, 
        unaccent(lower(regexp_replace(text, '<[^>]+>', '', 'g')))
    );
END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION search.search_documents(
    search_query TEXT,
    lang TEXT = 'english',
    limit_rows INT = 100
) RETURNS TABLE (
    id UUID,
    title TEXT,
    snippet TEXT,
    similarity REAL,
    ranking FLOAT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        d.id,
        d.title,
        -- Highlighting with safety:
        ts_headline(
            lang::regconfig,
            d.content,
            websearch_to_tsquery(lang::regconfig, search_query),
            'MaxWords=35, MinWords=15, StartSel=<mark>, StopSel=</mark>'
        ) AS snippet,
        -- Multiple ranking algorithms:
        ts_rank_cd(d.search_vector, query) AS similarity,
        ts_rank_cd(d.search_vector, query, 32) AS ranking
    FROM
        search.documents d,
        websearch_to_tsquery(lang::regconfig, search_query) query
    WHERE
        d.search_vector @@ query
        AND d.language_code = left(lang, 3)
    ORDER BY
        ranking DESC,
        similarity DESC
    LIMIT limit_rows;
END;
$$ LANGUAGE plpgsql STABLE;

CREATE OR REPLACE FUNCTION search.update_search_stats()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO search.statistics (document_id, search_count, last_searched)
    VALUES (NEW.id, 1, NOW())
    ON CONFLICT (document_id) DO UPDATE
    SET
        search_count = search.statistics.search_count + 1,
        last_searched = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_search_stats
AFTER SELECT ON search.documents
FOR EACH ROW EXECUTE FUNCTION search.update_search_stats();


-- Weekly index optimization
SELECT cron.schedule('optimize-search-index', '0 4 * * 6', $$
    REINDEX INDEX CONCURRENTLY idx_documents_search_vector;
    ANALYZE search.documents;
$$);
COMMIT;
