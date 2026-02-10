BEGIN;

CREATE EXTENSION IF NOT EXISTS pg_cron;

CREATE TABLE staging_data (
    id SERIAL PRIMARY KEY,
    data TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT now()
);

CREATE TABLE production_data (
    id SERIAL PRIMARY KEY,
    data TEXT NOT NULL,
    transformed_data TEXT NOT NULL,
    processed_at TIMESTAMP
);

INSERT INTO staging_data (data) VALUES
  ('first sample'),
  ('second sample'),
  ('third sample');

CREATE OR REPLACE PROCEDURE etl_job()
LANGUAGE plpgsql
AS $$
DECLARE
    record RECORD;
BEGIN
    SELECT id, data
    INTO record
    FROM staging_data
    ORDER BY id
    LIMIT 1;
    
    IF record IS NOT NULL THEN
        INSERT INTO production_data (data, transformed_data, processed_at)
        VALUES (record.data, UPPER(record.data), now());
        
        DELETE FROM staging_data WHERE id = record.id;
    END IF;
END;
$$;

SELECT cron.schedule('etl_job_schedule', '5 seconds', 'CALL etl_job()');

COMMIT;
