BEGIN;
DROP VIEW search_phrase_matching;
DROP VIEW search_results;
DROP INDEX products_search_idx;
DROP TABLE products;
COMMIT;
