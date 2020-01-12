-- 1. Liczba rezerwacji, w ktorych poszczegolne osoby sa platnikami
SELECT COUNT(g.id), g.first_name, g.last_name
FROM guest g
         LEFT JOIN reservation r
                   ON r.payer_id = g.id
GROUP BY g.id, g.first_name, g.last_name;

-- 2. Ktory klient zaplaccil w najwiekszej ilosci rat
SELECT g.first_name, g.last_name, COUNT(p.id) "Installments"
FROM guest g
         JOIN reservation res
              ON res.payer_id = g.id
         JOIN payment p
              ON res.id = p.reservation_id
GROUP BY g.first_name, g.last_name
ORDER BY "Installments" DESC
FETCH FIRST 1 ROWS ONLY;

-- 3. Osoba, ktora zostawila w hotelu najwiecej pieniedzy
SELECT *
FROM (SELECT g.first_name, g.last_name, SUM(p.amount) AS "Payment sum"
      FROM guest g
               JOIN reservation res
                    ON res.payer_id = g.id
               JOIN payment p
                    ON res.id = p.reservation_id
      GROUP BY g.first_name, g.last_name
      ORDER BY "Payment sum" DESC)
WHERE "Payment sum" IS NOT NULL
FETCH FIRST 1 ROWS ONLY;

-- 4. Klienci którzy mają potwierdzoną chociaż jedną rezerwację
SELECT UNIQUE g.first_name, g.last_name
FROM guest g
         JOIN reservation res
              ON res.payer_id = g.id
         JOIN reservation_status rs
              ON rs.id = res.reservation_status_id
WHERE rs.name = 'confirmed';

-- 5. Liczba pokoi ze względu na piętro
SELECT "floor", COUNT("floor") "number of rooms"
FROM (
         SELECT substr(id, 0, 1) "floor"
         FROM room
     )
GROUP BY "floor";

-- 6. Ile jednej nocy można maksymalnie przenocować gości

SELECT SUM(max_tenants)
FROM room;

-- 7. Ile jest aktywnych dzisiejszego dnia
SELECT COUNT(*) AS "Active reservations today"
FROM reservation r
         JOIN reservation_status rs ON r.reservation_status_id = rs.id
WHERE sysdate BETWEEN r.checkin_date AND r.checkout_date
  AND rs.name = 'active';

-- 8. Najpopularnieszy typ platnosci
SELECT pt.name, COUNT(p.payment_type_id) AS "Count"
FROM payment p
         JOIN payment_type pt
              ON p.payment_type_id = pt.id
GROUP BY pt.name
ORDER BY "Count" DESC
FETCH FIRST 1 ROWS ONLY;

-- 9. Najczęściej rezerwowany pokój
SELECT rm.id AS "Room ID", COUNT(*) AS "Reservation count"
FROM reservation res
         JOIN room rm
              ON rm.id = res.room_id
GROUP BY rm.id
ORDER BY "Reservation count" DESC
FETCH FIRST 1 ROWS ONLY;


-- 10. Pokoje zarezerwowane przez zlotych klientow
SELECT g.first_name, g.last_name, res.room_id
FROM reservation res
         JOIN guest g
              ON res.payer_id = g.id
         JOIN guest_status gs
              ON gs.id = g.status_id
WHERE gs.status_name = 'gold';

-- 11. Najwyższa i najniższa cena zapłacona dotychczas za każdy pokój
SELECT room_id, MIN(price), MAX(price)
FROM reservation
GROUP BY room_id;