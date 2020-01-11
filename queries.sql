-- 1. Kto ma najwięcej oplaconych rezerwacji
SELECT COUNT(g.id), g.first_name, g.last_name
FROM guest g
LEFT JOIN guests_in_reservation pfr
ON g.id = pfr.guest_id
LEFT JOIN reservation r
ON r.id = pfr.reservation_id
GROUP BY g.id, g.first_name, g.last_name;

-- 2. Jaki klient zaplacil w najwiekszej liczbie rat platności

SELECT g.first_name, g.last_name
FROM guest g
LEFT JOIN guests_in_reservation gir
ON g.id = gir.reservation_id
LEFT JOIN reservation res
ON res.id = gir.reservation_id
LEFT JOIN payments_for_reservation pfr
ON pfr.reservation_id = res.id
GROUP BY g.first_name, g.last_name;

-- 3. Największa suma rezerwacji/najdroższa rezerwacja

SELECT res.id, SUM(rt.base_price)
FROM room rom
LEFT JOIN room_type rt
ON rom.room_type_id = rt.id
INNER JOIN reservation res
ON rom.id = res.room_id
GROUP BY res.id
ORDER BY SUM(rt.base_price) DESC
OFFSET 0 ROWS FETCH NEXT 1 ROWS ONLY;

-- 4. Klienci którzy dokonali jednej rezerwacji

SELECT g.first_name, g.last_name
FROM guest g
LEFT JOIN guests_in_reservation gir
ON g.id = gir.guest_id
LEFT JOIN reservation res
ON res.id = gir.reservation_id
LEFT JOIN reservation_status rs
ON rs.id = res.reservation_status_id
WHERE rs.name = 'completed';

-- 5. Liczba pokoi ze względu na piętro

SELECT "Floor", COUNT("Floor") "Number of rooms"
FROM (
    SELECT substr(id, 0, 1) "Floor"
    FROM room
)
GROUP BY "Floor";

-- 6. Ile jednej nocy można maksymalnie przenocować gości

SELECT SUM(max_tenants)
FROM room;

-- 7. Ile jest rezerwacji dzisiejszego dnia

SELECT COUNT(*)
FROM reservation r
WHERE to_char(sysdate, 'yyyy/mm/dd') BETWEEN r.checkin_date AND r.checkout_date;

-- 8. Najpopularnieszy typ platnosci

SELECT pt.name, COUNT(p.payment_type_id)
FROM payment p
LEFT JOIN payment_type pt
ON p.payment_type_id = pt.id
GROUP BY pt.name
ORDER BY COUNT(p.payment_type_id) DESC
FETCH FIRST 1 ROWS ONLY;

-- 9. Najczęściej rezerwowany pokój

SELECT r.id, COUNT(gir.reservation_id)
FROM guests_in_reservation gir
LEFT JOIN reservation res
ON gir.reservation_id = res.id
LEFT JOIN room r
ON r.id = res.room_id
GROUP BY r.id
ORDER BY COUNT(gir.reservation_id)
FETCH FIRST 1 ROWS ONLY;


-- 10. Pokoje zarezerwowane przez zlotych klientow

SELECT g.first_name, g.last_name, res.room_id
FROM guest g
LEFT JOIN guests_in_reservation gir
ON g.id = gir.guest_id
LEFT JOIN reservation res
ON res.id = gir.reservation_id
LEFT JOIN guest_status gs
ON gs.id = g.status_id
WHERE gs.status_name = 'gold' AND res.room_id IS NOT NULL;

-- 11. Najwyższa i najniższa cena zapłacona dotychczas za każdy pokój

SELECT room_id, MIN(price), MAX(price)
FROM reservation
GROUP BY room_id;