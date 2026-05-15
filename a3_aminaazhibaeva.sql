BEGIN;

-- Task 1

WITH new_movies AS (
    SELECT
        'Edward Scissorhands' AS title,
        'The solitary life of an artificial man with scissors for hands is upended when he is taken in by a suburban family.' AS description,
        1990 AS release_year,
        (
        SELECT
            l.language_id
        FROM
            public."language" l
        WHERE
            lower( l."name") = 'english') AS language_id,
        9 AS rental_duration,
        8.99 AS rental_rate,
        105 AS length,
        'PG-13'::mpaa_rating AS rating
    UNION ALL
    SELECT
        'Sleepy Hollow' AS title,
        'Ichabod Crane is sent to Sleepy Hollow to investigate the decapitations of three people;' ||
        'the culprit is legendary apparition The Headless Horseman.' AS description,
        1999 AS release_year,
        (
        SELECT
            l.language_id
        FROM
            public."language" l
        WHERE
            lower( l."name") = 'english') AS language_id,
        22 AS rental_duration,
        7.59 AS rental_rate,
        105 AS length,
        'R'::mpaa_rating AS rating
    UNION ALL
    SELECT
        'Busanhaeng' AS title,
        'While a zombie virus breaks out in South Korea, passengers struggle to survive on the train from Seoul to Busan.' AS description,
        2016 AS release_year,
        (
        SELECT
            l.language_id
        FROM
            public."language" l
        WHERE
            lower( l."name") = 'korean') AS language_id,
        21 AS rental_duration,
        19.99 AS rental_rate,
        118 AS length,
        'PG-13'::mpaa_rating AS rating
), --CTE FOR inserting movies that defined in previous CTE with checking on existing in database
inserted_movies AS (
    INSERT INTO public.film
        (title,
        description,
        release_year,
        language_id,
        rental_duration,
        rental_rate,
        "length",
        rating,
        last_update)
    SELECT
        nm.title,
        nm.description,
        nm.release_year,
        nm.language_id,
        nm.rental_duration,
        nm.rental_rate,
        nm."length",
        nm.rating,
        current_date AS last_update
    FROM
        new_movies nm
    WHERE
        NOT EXISTS (SELECT
                        *
                    FROM
                        public.film f
                    WHERE
                        f.title = nm.title AND
                        f.release_year = nm.release_year)
    RETURNING film_id, title, release_year, rental_duration, rental_rate, last_update
)
SELECT film_id, title, release_year, rental_duration, rental_rate, last_update FROM inserted_movies
;

select *
from film
where title = 'Sleepy Hollow' or title = 'Edward Scissorhands' or title = 'Busanhaeng';



-- Task 2a — Insert actors

INSERT INTO actor (first_name, last_name, last_update)
SELECT 'Johnny', 'Depp', CURRENT_DATE
WHERE NOT EXISTS (
    SELECT 1
    FROM actor
    WHERE first_name = 'Johnny'
      AND last_name = 'Depp'
);

INSERT INTO actor (first_name, last_name, last_update)
SELECT 'Winona', 'Ryder', CURRENT_DATE
WHERE NOT EXISTS (
    SELECT 1
    FROM actor
    WHERE first_name = 'Winona'
      AND last_name = 'Ryder'
);

INSERT INTO actor (first_name, last_name, last_update)
SELECT 'Christina', 'Ricci', CURRENT_DATE
WHERE NOT EXISTS (
    SELECT 1
    FROM actor
    WHERE first_name = 'Christina'
      AND last_name = 'Ricci'
);

INSERT INTO actor (first_name, last_name, last_update)
SELECT 'Christopher', 'Walken', CURRENT_DATE
WHERE NOT EXISTS (
    SELECT 1
    FROM actor
    WHERE first_name = 'Christopher'
      AND last_name = 'Walken'
);

INSERT INTO actor (first_name, last_name, last_update)
SELECT 'Gong', 'Yoo', CURRENT_DATE
WHERE NOT EXISTS (
    SELECT 1
    FROM actor
    WHERE first_name = 'Gong'
      AND last_name = 'Yoo'
);

INSERT INTO actor (first_name, last_name, last_update)
SELECT 'Ma', 'Dong-seok', CURRENT_DATE
WHERE NOT EXISTS (
    SELECT 1
    FROM actor
    WHERE first_name = 'Ma'
      AND last_name = 'Dong-seok'
);



-- Task 2b — Link actors to films

-- Edward Scissorhands

INSERT INTO film_actor (actor_id, film_id, last_update)
SELECT
    (
        SELECT actor_id
        FROM actor
        WHERE first_name = 'Johnny'
          AND last_name = 'Depp'
    ),
    (
        SELECT film_id
        FROM film
        WHERE title = 'Edward Scissorhands'
    ),
    CURRENT_DATE
ON CONFLICT DO NOTHING;

INSERT INTO film_actor (actor_id, film_id, last_update)
SELECT
    (
        SELECT actor_id
        FROM actor
        WHERE first_name = 'Winona'
          AND last_name = 'Ryder'
    ),
    (
        SELECT film_id
        FROM film
        WHERE title = 'Edward Scissorhands'
    ),
    CURRENT_DATE
ON CONFLICT DO NOTHING;

-- Sleepy Hollow

INSERT INTO film_actor (actor_id, film_id, last_update)
SELECT
    (
        SELECT actor_id
        FROM actor
        WHERE first_name = 'Johnny'
          AND last_name = 'Depp'
    ),
    (
        SELECT film_id
        FROM film
        WHERE title = 'Sleepy Hollow'
    ),
    CURRENT_DATE
ON CONFLICT DO NOTHING;

INSERT INTO film_actor (actor_id, film_id, last_update)
SELECT
    (
        SELECT actor_id
        FROM actor
        WHERE first_name = 'Christina'
          AND last_name = 'Ricci'
    ),
    (
        SELECT film_id
        FROM film
        WHERE title = 'Sleepy Hollow'
    ),
    CURRENT_DATE
ON CONFLICT DO NOTHING;

INSERT INTO film_actor (actor_id, film_id, last_update)
SELECT
    (
        SELECT actor_id
        FROM actor
        WHERE first_name = 'Christopher'
          AND last_name = 'Walken'
    ),
    (
        SELECT film_id
        FROM film
        WHERE title = 'Sleepy Hollow'
    ),
    CURRENT_DATE
ON CONFLICT DO NOTHING;

-- Busanhaeng

INSERT INTO film_actor (actor_id, film_id, last_update)
SELECT
    (
        SELECT actor_id
        FROM actor
        WHERE first_name = 'Gong'
          AND last_name = 'Yoo'
    ),
    (
        SELECT film_id
        FROM film
        WHERE title = 'Busanhaeng'
    ),
    CURRENT_DATE
ON CONFLICT DO NOTHING;

INSERT INTO film_actor (actor_id, film_id, last_update)
SELECT
    (
        SELECT actor_id
        FROM actor
        WHERE first_name = 'Ma'
          AND last_name = 'Dong-seok'
    ),
    (
        SELECT film_id
        FROM film
        WHERE title = 'Busanhaeng'
    ),
    CURRENT_DATE
ON CONFLICT DO NOTHING;


-- Verification
SELECT f.title,
       COUNT(*) AS actor_count,
       string_agg(a.first_name || ' ' || a.last_name, ', ') AS actors
FROM film f
JOIN film_actor fa USING (film_id)
JOIN actor a       USING (actor_id)
WHERE f.title IN ('Edward Scissorhands', 'Sleepy Hollow', 'Busanhaeng')
GROUP BY f.title;

SELECT 'film' AS tbl, COUNT(*) FROM film WHERE title IN ('Edward Scissorhands', 'Sleepy Hollow', 'Busanhaeng')
UNION ALL
SELECT 'actor', COUNT(*) FROM actor WHERE last_update = CURRENT_DATE
UNION ALL
SELECT 'film_actor', COUNT(*) FROM film_actor WHERE last_update = CURRENT_DATE;



-- Task 3 — Add films to inventory

-- Edward Scissorhands

INSERT INTO inventory (film_id, store_id, last_update)
SELECT
    (SELECT film_id FROM film WHERE title = 'Edward Scissorhands'),
    (SELECT store_id FROM store WHERE store_id = 1),
    CURRENT_DATE
WHERE NOT EXISTS (
    SELECT 1 FROM inventory
    WHERE film_id = (SELECT film_id FROM film WHERE title = 'Edward Scissorhands')
      AND store_id = (SELECT store_id FROM store WHERE store_id = 1)
);

-- Sleepy Hollow

INSERT INTO inventory (film_id, store_id, last_update)
SELECT
    (SELECT film_id FROM film WHERE title = 'Sleepy Hollow'),
    (SELECT store_id FROM store WHERE store_id = 1),
    CURRENT_DATE
WHERE NOT EXISTS (
    SELECT 1 FROM inventory
    WHERE film_id = (SELECT film_id FROM film WHERE title = 'Sleepy Hollow')
      AND store_id = (SELECT store_id FROM store WHERE store_id = 1)
);

-- Busanhaeng

INSERT INTO inventory (film_id, store_id, last_update)
SELECT
    (SELECT film_id FROM film WHERE title = 'Busanhaeng'),
    (SELECT store_id FROM store WHERE store_id = 1),
    CURRENT_DATE
WHERE NOT EXISTS (
    SELECT 1 FROM inventory
    WHERE film_id = (SELECT film_id FROM film WHERE title = 'Busanhaeng')
      AND store_id = (SELECT store_id FROM store WHERE store_id = 1)
);


-- Verification
SELECT
    f.title,
    i.inventory_id,
    i.store_id
FROM inventory i
JOIN film f USING (film_id)
WHERE f.title IN (
    'Edward Scissorhands',
    'Sleepy Hollow',
    'Busanhaeng'
)
ORDER BY f.title;



-- Task 4 — Update an existing customer with your personal data

UPDATE customer
SET first_name  = 'Amina',
    last_name   = 'Azhibaeva',
    email       = 'aminaazhibaeva@email.com',
    address_id  = (SELECT address_id FROM address ORDER BY address_id LIMIT 1),
    last_update = CURRENT_DATE
WHERE (first_name = 'Practitioner' AND last_name  = 'Test')
OR (first_name = 'Amina' AND last_name  = 'Azhibaeva');

-- Verification
SELECT customer_id, first_name, last_name, email, address_id, last_update
FROM customer
WHERE first_name = 'Amina' AND last_name = 'Azhibaeva';



-- Task 5 — Clean up prior records

SELECT COUNT(*) AS payments_to_delete
FROM payment
WHERE customer_id = (
    SELECT customer_id
    FROM customer WHERE first_name = 'Amina' AND last_name  = 'Azhibaeva'
);


SELECT COUNT(*) AS rentals_to_delete
FROM rental
WHERE customer_id = (
    SELECT customer_id
    FROM customer WHERE first_name = 'Amina' AND last_name  = 'Azhibaeva'
);


-- Delete prior records

DELETE FROM payment
WHERE customer_id = (
    SELECT customer_id
    FROM customer WHERE first_name = 'Amina' AND last_name  = 'Azhibaeva'
);

DELETE FROM rental
WHERE customer_id = (
    SELECT customer_id
    FROM customer WHERE first_name = 'Amina' AND last_name  = 'Azhibaeva'
);

-- Verification after DELETE

SELECT COUNT(*) AS remaining_payments
FROM payment
WHERE customer_id = (
    SELECT customer_id
    FROM customer WHERE first_name = 'Amina' AND last_name  = 'Azhibaeva'
);

SELECT COUNT(*) AS remaining_rentals
FROM rental
WHERE customer_id = (
    SELECT customer_id
    FROM customer WHERE first_name = 'Amina' AND last_name  = 'Azhibaeva'
);



-- Task 6
-- Edward Scissorhands (WITH RETURNING)

INSERT INTO rental (rental_date, inventory_id, customer_id, return_date, staff_id, last_update)

SELECT
    '2017-01-15'::timestamp,
    (SELECT i.inventory_id
        FROM inventory i
        JOIN film f USING (film_id)
        WHERE f.title = 'Edward Scissorhands' AND i.store_id = 1
        LIMIT 1),
    (SELECT customer_id FROM customer
        WHERE first_name = 'Amina' AND last_name = 'Azhibaeva'),
    '2017-01-15'::timestamp + (SELECT rental_duration FROM film WHERE title = 'Edward Scissorhands') * INTERVAL '1 day',
    (SELECT staff_id FROM staff ORDER BY staff_id LIMIT 1),
    CURRENT_DATE
WHERE NOT EXISTS (
    SELECT 1
    FROM rental
    WHERE inventory_id = (SELECT i.inventory_id FROM inventory i JOIN film f USING (film_id)
    					  WHERE f.title = 'Edward Scissorhands' AND i.store_id = 1 LIMIT 1)
      AND customer_id = (SELECT customer_id FROM customer
      					 WHERE first_name = 'Amina'
          				 AND last_name = 'Azhibaeva')
      AND rental_date = '2017-01-15'::timestamp)
RETURNING rental_id, rental_date, return_date;


-- Sleepy Hollow

INSERT INTO rental (rental_date, inventory_id, customer_id, return_date, staff_id, last_update)

SELECT
    '2017-02-10'::timestamp,
    (SELECT i.inventory_id
        FROM inventory i
        JOIN film f USING (film_id)
        WHERE f.title = 'Sleepy Hollow' AND i.store_id = 1
        LIMIT 1),
    (SELECT customer_id FROM customer
        WHERE first_name = 'Amina' AND last_name = 'Azhibaeva'),
    '2017-02-10'::timestamp + (SELECT rental_duration FROM film WHERE title = 'Sleepy Hollow') * INTERVAL '1 day',
    (SELECT staff_id FROM staff ORDER BY staff_id LIMIT 1),
    CURRENT_DATE
WHERE NOT EXISTS (
    SELECT 1
    FROM rental
    WHERE inventory_id = (SELECT i.inventory_id FROM inventory i JOIN film f USING (film_id)
       					  WHERE f.title = 'Sleepy Hollow' AND i.store_id = 1 LIMIT 1)
      AND customer_id = (SELECT customer_id FROM customer
        				 WHERE first_name = 'Amina' AND last_name = 'Azhibaeva')
      AND rental_date = '2017-02-10'::timestamp);


-- Busanhaeng

INSERT INTO rental (rental_date, inventory_id, customer_id, return_date, staff_id, last_update)

SELECT
    '2017-03-05'::timestamp,
    (SELECT i.inventory_id
        FROM inventory i
        JOIN film f USING (film_id)
        WHERE f.title = 'Busanhaeng' AND i.store_id = 1
        LIMIT 1),
    (SELECT customer_id FROM customer
        WHERE first_name = 'Amina' AND last_name = 'Azhibaeva'),
    '2017-03-05'::timestamp + (SELECT rental_duration FROM film WHERE title = 'Busanhaeng') * INTERVAL '1 day',
    (SELECT staff_id FROM staff ORDER BY staff_id LIMIT 1),
    CURRENT_DATE
WHERE NOT EXISTS (
    SELECT 1
    FROM rental
    WHERE inventory_id = (SELECT i.inventory_id FROM inventory i JOIN film f USING (film_id)
        				  WHERE f.title = 'Busanhaeng' AND i.store_id = 1 LIMIT 1)
      AND customer_id = (SELECT customer_id FROM customer
        				 WHERE first_name = 'Amina' AND last_name = 'Azhibaeva')
      AND rental_date = '2017-03-05'::timestamp);



-- Task 6b

INSERT INTO payment (customer_id, staff_id, rental_id, amount, payment_date)
SELECT
    (SELECT customer_id FROM customer
       WHERE first_name = 'Amina' AND last_name = 'Azhibaeva'),
    (SELECT staff_id FROM staff ORDER BY staff_id LIMIT 1),
    r.rental_id,
    (SELECT rental_rate FROM film WHERE title = 'Edward Scissorhands'),
    '2017-01-15'::timestamp
FROM rental r
WHERE r.inventory_id = (SELECT i.inventory_id FROM inventory i JOIN film f USING (film_id)
                        WHERE f.title = 'Edward Scissorhands' AND i.store_id = 1 LIMIT 1)
  AND r.customer_id  = (SELECT customer_id FROM customer
                        WHERE first_name = 'Amina' AND last_name = 'Azhibaeva')
  AND NOT EXISTS (
      SELECT 1 FROM payment p
      WHERE p.rental_id = r.rental_id
        AND p.customer_id = r.customer_id
        AND p.amount = (SELECT rental_rate FROM film WHERE title = 'Edward Scissorhands')
  );


INSERT INTO payment (customer_id, staff_id, rental_id, amount, payment_date)
SELECT
    (SELECT customer_id FROM customer
       WHERE first_name = 'Amina' AND last_name = 'Azhibaeva'),
    (SELECT staff_id FROM staff ORDER BY staff_id LIMIT 1),
    r.rental_id,
    (SELECT rental_rate FROM film WHERE title = 'Sleepy Hollow'),
    '2017-02-10'::timestamp
FROM rental r
WHERE r.inventory_id = (SELECT i.inventory_id FROM inventory i JOIN film f USING (film_id)
                        WHERE f.title = 'Sleepy Hollow' AND i.store_id = 1 LIMIT 1)
  AND r.customer_id  = (SELECT customer_id FROM customer
                        WHERE first_name = 'Amina' AND last_name = 'Azhibaeva')
  AND NOT EXISTS (
      SELECT 1 FROM payment p
      WHERE p.rental_id = r.rental_id
        AND p.customer_id = r.customer_id
        AND p.amount = (SELECT rental_rate FROM film WHERE title = 'Sleepy Hollow')
  );


INSERT INTO payment (customer_id, staff_id, rental_id, amount, payment_date)
SELECT
    (SELECT customer_id FROM customer
       WHERE first_name = 'Amina' AND last_name = 'Azhibaeva'),
    (SELECT staff_id FROM staff ORDER BY staff_id LIMIT 1),
    r.rental_id,
    (SELECT rental_rate FROM film WHERE title = 'Busanhaeng'),
    '2017-03-05'::timestamp
FROM rental r
WHERE r.inventory_id = (SELECT i.inventory_id FROM inventory i JOIN film f USING (film_id)
                        WHERE f.title = 'Busanhaeng' AND i.store_id = 1 LIMIT 1)
  AND r.customer_id  = (SELECT customer_id FROM customer
                        WHERE first_name = 'Amina' AND last_name = 'Azhibaeva')
  AND NOT EXISTS (
      SELECT 1 FROM payment p
      WHERE p.rental_id = r.rental_id
        AND p.customer_id = r.customer_id
        AND p.amount = (SELECT rental_rate FROM film WHERE title = 'Busanhaeng')
  );

-- Verification
-- All rentals for you
SELECT r.rental_id, f.title, r.rental_date, r.return_date
FROM rental r
JOIN inventory i USING (inventory_id)
JOIN film f      USING (film_id)
JOIN customer c  ON r.customer_id = c.customer_id
WHERE c.first_name = 'Amina' AND c.last_name = 'Azhibaeva'
ORDER BY r.rental_date;

-- All payments for you
SELECT p.payment_id, p.amount, p.payment_date, f.title
FROM payment p
JOIN rental r    ON p.rental_id = r.rental_id
JOIN inventory i USING (inventory_id)
JOIN film f      USING (film_id)
JOIN customer c  ON p.customer_id = c.customer_id
WHERE c.first_name = 'Amina' AND c.last_name = 'Azhibaeva'
ORDER BY p.payment_date;


-- Full Script Idempotency Test
SELECT 'film'             AS tbl, COUNT(*) FROM film  WHERE title IN ('Edward Scissorhands','Sleepy Hollow','Busanhaeng')
UNION ALL SELECT 'actor',          COUNT(*) FROM actor WHERE last_update = CURRENT_DATE
UNION ALL SELECT 'film_actor',     COUNT(*) FROM film_actor WHERE last_update = CURRENT_DATE
UNION ALL SELECT 'inventory',      COUNT(*) FROM inventory i JOIN film f USING (film_id)
                                   WHERE f.title IN ('Edward Scissorhands','Sleepy Hollow','Busanhaeng')
UNION ALL SELECT 'customer_you',   COUNT(*) FROM customer WHERE first_name='Amina' AND last_name='Azhibaeva'
UNION ALL SELECT 'rental_yours',   COUNT(*) FROM rental r JOIN customer c USING (customer_id)
                                   WHERE c.first_name='Amina' AND c.last_name='Azhibaeva'
UNION ALL SELECT 'payment_yours',  COUNT(*) FROM payment p JOIN customer c USING (customer_id)
                                   WHERE c.first_name='Amina' AND c.last_name='Azhibaeva';

COMMIT;