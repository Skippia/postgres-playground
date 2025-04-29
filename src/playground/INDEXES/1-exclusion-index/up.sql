BEGIN;
CREATE EXTENSION IF NOT EXISTS btree_gist;

CREATE TABLE reservations
(
 id serial PRIMARY KEY,
 room_id INTEGER,
 booking_status TEXT,
 start_date TIMESTAMP,
 end_date TIMESTAMP,
--  EXCLUDE USING GIST (TSRANGE(start_date, end_date) WITH &&)
  --  no conflicting bookings for the same date range (applied for the whole table)
--  EXCLUDE USING GIST (room_id WITH =, TSRANGE(start_date, end_date) WITH &&)
  -- contraint applied only to the same room
EXCLUDE USING GIST (room_id WITH =,TSRANGE(start_date, end_date) WITH &&) WHERE (booking_status != 'CANCELED')
-- partial exclusion contraint (applied only to the same room where booking status is not CANCELED)
);

COMMIT;
