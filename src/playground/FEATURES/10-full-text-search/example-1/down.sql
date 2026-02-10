BEGIN;
DROP VIEW IF EXISTS search_phrase_matching;
DROP VIEW IF EXISTS search_results;
DROP VIEW IF EXISTS search_phrase_exact_order;
DROP INDEX IF EXISTS products_search_idx;
DROP TABLE IF EXISTS products CASCADE;
COMMIT;
