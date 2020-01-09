-- QUERIES

-- 1. Kto ma najwięcej oplacaonych rezerwacji
SELECT
    COUNT(g.id),
    g.first_name,
    g.last_name
FROM
    guest g
    LEFT JOIN guests_in_reservation pfr
    ON g.id = pfr.guest_id
    LEFT JOIN reservation r
    ON r.id = pfr.reservation_id
GROUP BY
    g.id,
    g.first_name,
    g.last_name;

-- 2. Jaki klient zaplacil w najwiekszej liczbie rat platności

SELECT
    g.first_name,
    g.last_name
FROM
    guest g
    LEFT JOIN guests_in_reservation gir
    ON g.id = gir.reservation_id
    LEFT JOIN reservation res
    ON res.id = gir.reservation_id
    LEFT JOIN payments_for_reservation pfr
    ON pfr.reservation_id = res.id
GROUP BY
    g.first_name,
    g.last_name;

-- 3. Największa suma rezerwacji/najdroższa rezerwacja

SELECT
    res.id,
    SUM(rt.base_price)
FROM
    room rom
    LEFT JOIN room_type rt
    ON rom.room_type_id = rt.id
    INNER JOIN reservation res
    ON rom.id = res.room_id
GROUP BY
    res.id
ORDER BY
    SUM(rt.base_price) DESC
OFFSET 0 ROWS FETCH NEXT 1 ROWS ONLY;

-- 4. Klienci którzy dokonali jednej rezerwacji

SELECT
    g.first_name,
    g.last_name
FROM
    guest g
    LEFT JOIN guests_in_reservation gir
    ON g.id = gir.guest_id
    LEFT JOIN reservation res
    ON res.id = gir.reservation_id
    LEFT JOIN reservation_status rs
    ON rs.id = res.reservation_status_id
WHERE
    rs.name = 'completed';

-- 5. Liczba pokoi ze względu na piętro
SELECT
    "Floor", COUNT("Floor") "Number of rooms"
FROM
    (SELECT SUBSTR(id,0,1) "Floor"
    FROM room)
GROUP BY "Floor";

-- 6. Ile jednej nocy można maksymalnie przenocować gości
SELECT
    SUM(max_tenants)
FROM
    room;

-- 7. Ile jest rezerwacji dzisiejszego dnia
SELECT
    COUNT(*)
FROM
    reservation r
WHERE
    to_char(sysdate, 'yyyy/mm/dd') BETWEEN r.checkin_date AND r.checkout_date;

-- 8. Najpopularnieszy typ platnosci
SELECT
    pt.name,
    COUNT(p.payment_type_id)
FROM
    payment p
    LEFT JOIN payment_type pt
    ON p.payment_type_id = pt.id
GROUP BY
    pt.name
ORDER BY
    COUNT(p.payment_type_id) DESC
FETCH FIRST 1 ROWS ONLY;

-- 9. Najczęściej rezerwowany pokój
SELECT
    r.id,
    COUNT(gir.reservation_id)
FROM
    guests_in_reservation gir
    LEFT JOIN reservation res
    ON gir.reservation_id = res.id
    LEFT JOIN room r
    ON r.id = res.room_id
GROUP BY
    r.id
ORDER BY
    COUNT(gir.reservation_id)
FETCH FIRST 1 ROWS ONLY;


-- 10. Pokoje zarezerwowane przez zlotych klientow
SELECT
    g.first_name,
    g.last_name,
    res.room_id
FROM
    guest g
    LEFT JOIN guests_in_reservation gir
    ON g.id = gir.guest_id
    LEFT JOIN reservation res
    ON res.id = gir.reservation_id
    LEFT JOIN guest_status gs
    ON gs.id = g.status_id
WHERE
    gs.status_name = 'gold' AND res.room_id IS NOT NULL;

-- 11. Najwyższa i najniższa cena zapłacona dotychczas za każdy pokój
SELECT
    room_id,
    MIN(price),
    MAX(price)
FROM
    reservation
GROUP BY
    room_id;
	

-- PROCEDURES

-- dodaj klienta
CREATE OR REPLACE PROCEDURE add_client(p_first_name guest.first_name%TYPE,
p_last_name guest.last_name%TYPE,
p_phone guest.phone%TYPE,
p_email guest.email%TYPE,
p_nationality guest.nationality%TYPE,
p_document_id guest.document_id%TYPE,
p_birth_date guest.birth_date%TYPE,
p_reservation_id guest.reservation_id%TYPE,
p_document_type_id guest.document_type_id%TYPE,
p_status_id guest.status_id%TYPE)
AS
BEGIN
INSERT INTO TABLE guest(first_name, last_name, phone, email, nationality, document_id, birth_date, reservation_id,
document_type_id, status_id)
VALUES (p_first_name, p_last_name, p_phone, p_email, p_nationality, p_document_id, p_birth_date,
p_reservation_id, p_document_type_id, p_status_id);
END;




--Procedura dodaj płatność
CREATE OR REPLACE PROCEDURE add_payment(p_amount payment.amount%TYPE, p_payment_type_id payment.payment_type_id%TYPE)
AS
BEGIN
    INSERT INTO PAYMENT(amount, payment_type_id) VALUES(p_amount, p_payment_type_id);
END;

-- check-in - zmiana rezerwacji na active
CREATE OR REPLACE PROCEDURE check_in(p_reservation_id reservation.id%TYPE)
AS
BEGIN
    UPDATE reservation SET reservation_status_id = 4
    WHERE id = p_reservation_id;
END;

-- Funkcje
-- czy rezerwacja zostala oplacona
CREATE OR REPLACE FUNCTION is_paid(p_reservation_id reservation.id%TYPE)
RETURN boolean
AS
 v_reservation_status_name reservation_status.NAME%TYPE;
BEGIN
    SELECT rs.name INTO v_reservation_status_name
    FROM reservation r
    JOIN reservation_status rs ON r.reservation_status_id = rs.id
    WHERE r.id = p_reservation_id;
    
	IF v_reservation_status_name = 'confirmed' THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END;

CREATE OR REPLACE FUNCTION room_price(p_guest_id guest.id%TYPE, p_room_id room.id%TYPE)
RETURN NUMBER
AS
    v_calculated_price room_type.base_price%TYPE;
    v_base_price room_type.base_price%TYPE;
    v_season_multiplier season_pricing.multiplier%TYPE;
    v_guest_status_multiplier guest_status.multiplier%TYPE;
BEGIN
    SELECT rt.base_price INTO v_base_price
    FROM room r JOIN room_type rt ON r.room_type_id = rt.id
    WHERE r.id = p_room_id;
    
    SELECT gs.multiplier INTO v_guest_status_multiplier
    FROM guest g LEFT JOIN guest_status gs ON g.status_id = gs.id
    WHERE g.id = p_guest_id;
    
    SELECT multiplier into v_season_multiplier
    from season_pricing
    where SYSDATE >= start_date AND SYSDATE <= end_date;
    IF SQL%NOTFOUND THEN
        v_season_multiplier := 1.0;
    END IF;
    
    RETURN TRUNC(v_base_price * v_guest_status_multiplier * v_season_multiplier, 2);
END;

-- W jakim sezonie była dana rezerwacja
CREATE OR REPLACE FUNCTION check_season_for_reservation(p_reservation_id reservation.id%TYPE)
RETURN season_pricing.id%TYPE
AS
v_reservation_date reservation.checkin_date%TYPE;
CURSOR season_cursor IS SELECT * FROM season_pricing;
BEGIN
    SELECT r.checkin_date INTO v_reservation_date
    FROM reservation r WHERE r.id = p_reservation_id;
    FOR season IN season_cursor 
    LOOP
        IF v_reservation_date BETWEEN season.start_date AND season.end_date THEN
        RETURN season.id;
        ELSE RETURN NULL;
        END IF;
    END LOOP;
    
END;

-- Triggery
-- Czy guest ma przynajmniej 1 formę kontaktu - create/update
CREATE OR REPLACE TRIGGER check_contact_data
BEFORE INSERT ON guest
FOR EACH ROW
DECLARE
e_no_contact_provided EXCEPTION;
BEGIN
    IF :NEW.email = NULL AND :NEW.phone = NULL THEN
    RAISE e_no_contact_provided;
    END IF;
    EXCEPTION WHEN e_no_contact_provided THEN
    dbms_output.put_line('At least one method of contact per guest must be provided');
END;


-- Brak możliwości modyfikacji płatności (możliwe, że jest też inny sposób rozwiązania tego niż trigger)
CREATE OR REPLACE TRIGGER block_payment_update
BEFORE UPDATE ON payment  
DECLARE 
e_no_update_allowed EXCEPTION;
BEGIN
    RAISE e_no_update_allowed;
    EXCEPTION WHEN e_no_update_allowed THEN
    dbms_output.put_line('Updating PAYMENT table is not allowed');
END;
--Testy
SET SERVEROUTPUT ON;
BEGIN
    dbms_output.put_line(room_price(1, 101));
END;