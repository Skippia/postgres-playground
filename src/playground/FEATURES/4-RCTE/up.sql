BEGIN;

CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL
);

CREATE TABLE followers (
    leader_id INTEGER NOT NULL,
    follower_id INTEGER NOT NULL,
    PRIMARY KEY (leader_id, follower_id),
    CONSTRAINT fk_leader FOREIGN KEY (leader_id) REFERENCES users (id) ON DELETE CASCADE,
    CONSTRAINT fk_follower FOREIGN KEY (follower_id) REFERENCES users (id) ON DELETE CASCADE
);

INSERT INTO users (username) VALUES
  ('Alice'),    -- id 1
  ('Bob'),      -- id 2
  ('Charlie'),  -- id 3
  ('David'),    -- id 4
  ('Eve'),      -- id 5
  ('Frank'),    -- id 6
  ('Grace'),    -- id 7
  ('Heidi'),    -- id 8
  ('Ivan'),     -- id 9
  ('Judy'),     -- id 10
  ('Kevin'),    -- id 11
  ('Laura'),    -- id 12
  ('Mallory'),  -- id 13
  ('Nathan'),   -- id 14
  ('Olivia');   -- id 15

-- Chain 1: 10 <- 5, 5 <- 3, 3 <- 2 (depths: 1, 2, 3)
INSERT INTO followers (leader_id, follower_id) VALUES
  (5, 10),
  (3, 5),
  (2, 3);

-- Chain 2: 10 <- 7, 7 <- 8, 8 <- 6 (depths: 1, 2, 3)
INSERT INTO followers (leader_id, follower_id) VALUES
  (7, 10),
  (8, 7),
  (6, 8);

COMMIT;
