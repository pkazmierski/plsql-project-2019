-- QUERIES

-- 1. Kto ma najwięcej oplaconych rezerwacji
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
    "Floor",
    COUNT("Floor") "Number of rooms"
FROM
    (
        SELECT
            substr(id, 0, 1) "Floor"
        FROM
            room
    )
GROUP BY
    "Floor";

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

-- dodaj gościa

CREATE OR REPLACE PROCEDURE add_guest (
    p_first_name guest.first_name%TYPE,
    p_last_name guest.last_name%TYPE,
    p_phone guest.phone%TYPE,
    p_email guest.email%TYPE,
    p_nationality guest.nationality%TYPE,
    p_document_id guest.document_id%TYPE,
    p_birth_date guest.birth_date%TYPE,
    p_document_type_id guest.document_type_id%TYPE,
    p_status_id guest.status_id%TYPE
) AS
BEGIN
    INSERT INTO guest (
        first_name,
        last_name,
        phone,
        email,
        nationality,
        document_id,
        birth_date,
        document_type_id,
        status_id
    ) VALUES (
        p_first_name,
        p_last_name,
        p_phone,
        p_email,
        p_nationality,
        p_document_id,
        p_birth_date,
        p_document_type_id,
        p_status_id
    );

END add_guest;


-- dodaj płatność

CREATE OR REPLACE PROCEDURE add_payment (
    p_amount payment.amount%TYPE,
    p_payment_type_id payment.payment_type_id%TYPE
) AS
BEGIN
    INSERT INTO payment (
        amount,
        payment_type_id
    ) VALUES (
        p_amount,
        p_payment_type_id
    );

END;

-- check-in - zmiana rezerwacji na active

CREATE OR REPLACE PROCEDURE check_in (
    p_reservation_id reservation.id%TYPE
) AS
BEGIN
    UPDATE reservation
    SET
        reservation_status_id = 4
    WHERE
        id = p_reservation_id;

END;




-- Funkcje

-- DO SPRAWDZENIA czy rezerwacja zostala oplacona

CREATE OR REPLACE FUNCTION is_paid (
    p_reservation_id reservation.id%TYPE
) RETURN BOOLEAN AS
    v_reservation_status_name reservation_status.name%TYPE;
BEGIN
    SELECT
        rs.name
    INTO v_reservation_status_name
    FROM
        reservation r
        JOIN reservation_status rs
        ON r.reservation_status_id = rs.id
    WHERE
        r.id = p_reservation_id;

    IF v_reservation_status_name = 'confirmed' THEN
        RETURN true;
    ELSE
        RETURN false;
    END IF;
END;

-- DO POPRAWY cena za pokoj

CREATE OR REPLACE FUNCTION room_price (
    p_guest_id guest.id%TYPE,
    p_room_id room.id%TYPE
) RETURN NUMBER AS

    v_calculated_price room_type.base_price%TYPE;
    v_base_price room_type.base_price%TYPE;
    v_season_multiplier season_pricing.multiplier%TYPE;
    v_guest_status_multiplier guest_status.multiplier%TYPE;
BEGIN
    SELECT
        rt.base_price
    INTO v_base_price
    FROM
        room r
        LEFT JOIN room_type rt
        ON r.room_type_id = rt.id
    WHERE
        r.id = p_room_id;

    SELECT
        gs.multiplier
    INTO v_guest_status_multiplier
    FROM
        guest g
        LEFT JOIN guest_status gs
        ON g.status_id = gs.id
    WHERE
        g.id = p_guest_id;

    BEGIN
        SELECT
            multiplier
        INTO v_season_multiplier
        FROM
            season_pricing
        WHERE
            sysdate >= start_date AND sysdate <= end_date;

    EXCEPTION
        WHEN no_data_found THEN
            v_season_multiplier := 1.0;
    END;

    RETURN trunc(v_base_price * v_guest_status_multiplier * v_season_multiplier, 2);
END;

-- DO SPRAWDZENIA W jakim sezonie była dana rezerwacja

CREATE OR REPLACE FUNCTION season_for_reservation (
    p_reservation_id reservation.id%TYPE
) RETURN season_pricing.id%TYPE AS
    v_reservation_date reservation.checkin_date%TYPE;
    CURSOR season_cursor IS
    SELECT
        *
    FROM
        season_pricing;

BEGIN
    SELECT
        r.checkin_date
    INTO v_reservation_date
    FROM
        reservation r
    WHERE
        r.id = p_reservation_id;

    FOR season IN season_cursor LOOP IF v_reservation_date BETWEEN season.start_date AND season.end_date THEN
        RETURN season.id;
    END IF;
    END LOOP;

    RETURN NULL;
END;

-- DO SPRAWDZENIA Zwracanie całych rzędów pokoi, które są wolne i mają podane parametry (filtrowanie, niech będą defaulty albo jakieś inne ogarnięcie przypadków, gdy nie ma podanego danego parametru)

CREATE OR REPLACE FUNCTION available_rooms (
    p_date_from reservation.checkin_date%TYPE DEFAULT to_char(sysdate),
    p_date_to reservation.checkout_date%TYPE DEFAULT to_char(sysdate + 7),
    p_room_type room_type.name%TYPE DEFAULT '%'
) RETURN SYS_REFCURSOR AS
    my_cursor SYS_REFCURSOR;
BEGIN
    OPEN my_cursor FOR SELECT
                           r.id,
                           rt.name,
                           rt.base_price
                       FROM
                           reservation res
                           LEFT JOIN room r
                           ON res.room_id = r.id
                           LEFT JOIN room_type rt
                           ON rt.id = r.room_type_id
                       WHERE
                           ( p_date_from NOT BETWEEN res.checkin_date AND res.checkout_date ) AND ( p_date_to NOT BETWEEN res.checkin_date
                           AND res.checkout_date ) AND rt.name LIKE p_room_type;

    RETURN my_cursor;
END;



-- DO SPRAWDZENIA Ile z wymaganej kwoty rezerwacji zostało już wpłacone/ile do zapłacenia

CREATE OR REPLACE FUNCTION yet_to_pay (
    p_reservation_id reservation.id%TYPE
) RETURN NUMBER AS
    v_res_price reservation.price%TYPE;
    v_payments_sum payment.amount%TYPE;
BEGIN
    SELECT
        p.amount
    INTO v_payments_sum
    FROM
        payment
    WHERE
        id = p_reservation_id;

    SELECT
        price
    INTO v_res_price
    FROM
        reservation res
    WHERE
        id = p_reservation_id;

    RETURN trunc(v_res_price - v_payments_sum, 2);
END;




-- Triggery

-- DO POPRAWY (NIE BLOKUJE NIC, EXCEPTION PRAWD. DO ZMIANY) Czy guest ma przynajmniej 1 formę kontaktu - create/update

CREATE OR REPLACE TRIGGER check_contact_data BEFORE
    INSERT OR UPDATE OF phone, email ON guest
    FOR EACH ROW
DECLARE
    e_no_contact_provided EXCEPTION;
BEGIN
    IF :new.email = NULL AND :new.phone = NULL THEN
        RAISE e_no_contact_provided;
    END IF;
EXCEPTION
    WHEN e_no_contact_provided THEN
        dbms_output.put_line('At least one method of contact per guest must be provided');
END;


-- DO POPRAWY (NIC NIE BLOKUJE, EXCPETION PRAWD. DO ZMIANY) Brak możliwości modyfikacji płatności (możliwe, że jest też inny sposób rozwiązania tego niż trigger)

CREATE OR REPLACE TRIGGER block_payment_update BEFORE
    UPDATE ON payment
DECLARE
    e_no_update_allowed EXCEPTION;
BEGIN
    RAISE e_no_update_allowed;
EXCEPTION
    WHEN e_no_update_allowed THEN
        dbms_output.put_line('Updating PAYMENT table is not allowed');
END;

-- DO POPRAWY, MÓWIEM O MUTOWANIU TABELI sprawdzanie nowego sezonu (czy się nie nakada z innymi)

CREATE OR REPLACE TRIGGER check_new_season BEFORE
    INSERT ON season_pricing
    FOR EACH ROW
DECLARE
    v_counter NUMBER;
    e_no_season_found EXCEPTION;
BEGIN
    SELECT
        COUNT(*)
    INTO v_counter
    FROM
        season_pricing sp
    WHERE
        :new.start_date >= sp.start_date AND :new.end_date <= sp.end_date;

    IF v_counter >= 1 THEN
        RAISE e_no_season_found;
    END IF;
EXCEPTION
    WHEN e_no_season_found THEN
        dbms_output.put_line('Cannot add a season that interferes with any other');
END;

-- Widoki
-- DO SPRAWDZENIA widok Wolne pokoje (aktualnie)

CREATE OR REPLACE VIEW free_rooms AS
    SELECT
        r.id,
        rt.name,
        rt.base_price
    FROM
        reservation res
        LEFT JOIN room r
        ON res.room_id = r.id
        LEFT JOIN room_type rt
        ON rt.id = r.room_type_id
    WHERE
        SYSDATE NOT BETWEEN res.checkin_date AND res.checkout_date;



-- DO POPRAWY, ten sam problem co poprzedni, czyli p.amount zwróci dla POJEDYNCZEJ platnosci | kto w danym dniu nie ma zapłaty za hotel

CREATE OR REPLACE VIEW not_paid_today AS
    SELECT
        g.first_name,
        g.last_name,
        res.price - p.amount AS "Left to pay"
    FROM
        reservation res
        LEFT JOIN reservation_status rs
        ON res.reservation_status_id = rs.id
        LEFT JOIN guests_in_reservation gir
        ON gir.reservation_id = res.id
        LEFT JOIN guest g
        ON g.id = gir.guest_id
        LEFT JOIN payment p
        ON res.id = p.reservation_id
    WHERE
        res.checkin_date >= to_char(sysdate) AND res.checkout_date <= to_char(sysdate) AND rs.name = 'unpaid';


--Testy

SET SERVEROUTPUT ON;

BEGIN
    dbms_output.put_line(room_price(1, 101));
END;