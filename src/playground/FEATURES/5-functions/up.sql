BEGIN;

CREATE TABLE "mangas"(
    "id" SERIAL PRIMARY KEY NOT NULL,
    "title" VARCHAR NOT NULL
);

CREATE TABLE "volumes"(
    "id" SERIAL PRIMARY KEY NOT NULL,
    "volume" INTEGER NOT NULL,
    "price" DOUBLE PRECISION NOT NULL,
    "manga_id" INTEGER NOT NULL
);

ALTER TABLE "volumes" ADD FOREIGN KEY ("manga_id") REFERENCES "mangas" ("id") ON DELETE CASCADE;

INSERT INTO "mangas"(
    "id",
    "title"
)
VALUES
(1, 'one piece'),
(2, 'death note'),
(3, 'chainsawman'),
(4, 'slave'),
(5, 'eighty six');

INSERT INTO "volumes"(
    "manga_id",
    "price",
    "volume"
)
VALUES
(1, 45, 1),
(1, 45, 2),
(1, 50, 3),
(1, 50, 4),
(1, 45, 5),
(2, 120, 1),
(2, 120, 2),
(2, 120, 3),
(2, 120, 4),
(2, 120, 5),
(3, 60, 1),
(3, 60, 2),
(3, 60, 3),
(3, 60, 4),
(3, 60, 5),
(4, 130, 1),
(4, 135, 2),
(4, 160, 3),
(4, 160, 4),
(4, 160, 5),
(5, 130, 1),
(5, 130, 2),
(5, 130, 3),
(5, 130, 4),
(5, 130, 5);

CREATE OR REPLACE FUNCTION get_all_volumes(manga_id INT)
    RETURNS TABLE (
    "id" INT,
    "title" VARCHAR,
    "vol" INT
    )
    AS $$
BEGIN
    RETURN QUERY SELECT
    "m"."id",
    "m"."title",
    "v"."volume" AS "vol"
    FROM "mangas" "m"
    LEFT JOIN "volumes" "v" ON "v"."manga_id" = "m"."id"
    WHERE "v"."manga_id" = $1;
END;
$$ LANGUAGE plpgsql;


-- SELECT INTO "manga"
--  retrieves only first value if there are multiple (which corresponds the condition)
CREATE OR REPLACE FUNCTION get_manga_from_price(price FLOAT)
RETURNS VARCHAR
AS $$
DECLARE
    "manga" VARCHAR;
BEGIN
    SELECT INTO "manga"
    "m"."title"
    FROM "mangas" "m"
    INNER JOIN "volumes" "v" ON "v"."manga_id" = "m"."id"
    WHERE "v"."price" >= $1;
RETURN
    "manga";
END;
$$ LANGUAGE plpgsql;

COMMIT;
