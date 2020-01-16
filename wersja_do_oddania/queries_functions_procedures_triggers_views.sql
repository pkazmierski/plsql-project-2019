-----------
--Queries--
-----------

-- 1. Liczba rezerwacji, w ktorych poszczegolne osoby sa platnikami
SELECT COUNT(g.id), g.first_name, g.last_name
FROM guest g
         LEFT JOIN reservation r
                   ON r.payer_id = g.id
GROUP BY g.id, g.first_name, g.last_name;

-- 2. Ktory klient zaplacil w najwiekszej ilosci rat
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



-------------
--Functions--
-------------

-- OK Ile z wymaganej kwoty rezerwacji zostało już wpłacone/ile do zapłacenia
CREATE OR REPLACE FUNCTION left_to_pay(
    p_reservation_id reservation.id%TYPE
) RETURN NUMBER AS
    v_res_price    reservation.price%TYPE;
    v_payments_sum payment.amount%TYPE := 0;
BEGIN
    BEGIN
        SELECT
            SUM(amount)
        INTO v_payments_sum
        FROM
            payment
        WHERE
            reservation_id = p_reservation_id;

        IF v_payments_sum IS NULL THEN
            v_payments_sum := 0;
        END IF;
    EXCEPTION
        WHEN no_data_found THEN
            v_payments_sum := 0;
    END;

    SELECT
        price
    INTO v_res_price
    FROM
        reservation res
    WHERE
        id = p_reservation_id;

    RETURN trunc(v_res_price - v_payments_sum, 2);
END left_to_pay;

-- OK weryfikuje, czy dany sezon nie nakłada się z innymi
CREATE OR REPLACE FUNCTION verify_season_dates(p_season_id season_pricing.id%TYPE) RETURN BOOLEAN AS
    v_current_season season_pricing%ROWTYPE;
BEGIN
    SELECT *
    INTO v_current_season
    FROM
        season_pricing
    WHERE
        id = p_season_id;


    FOR r_pricing IN (SELECT * FROM season_pricing)
        LOOP
            IF (v_current_season.end_date BETWEEN r_pricing.start_date AND r_pricing.end_date)
                OR (v_current_season.start_date BETWEEN r_pricing.start_date AND r_pricing.end_date) THEN
                RETURN FALSE;
            END IF;
        END LOOP;
    RETURN TRUE;
END verify_season_dates;

-- OK Zwracanie kursora do pokoi, które są wolne w danym terminie i spełniają dane wymagania
CREATE OR REPLACE FUNCTION room_filter(
    p_date_from reservation.checkin_date%TYPE DEFAULT sysdate,
    p_date_to reservation.checkout_date%TYPE DEFAULT sysdate + 7,
    p_min_price room_type.base_price%TYPE DEFAULT 0.00,
    p_max_price room_type.base_price%TYPE DEFAULT 9999.00,
    p_room_type room_type.name%TYPE DEFAULT '%') RETURN SYS_REFCURSOR AS
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
                             (p_date_from NOT BETWEEN res.checkin_date AND res.checkout_date)
                         AND (p_date_to NOT BETWEEN res.checkin_date AND res.checkout_date)
                         AND rt.name LIKE p_room_type
                         AND rt.base_price >= p_min_price
                         AND rt.base_price <= p_max_price;
    RETURN my_cursor;
END;

--typ potrzebny do T_ROOM_ID_TABLE
CREATE OR REPLACE TYPE T_ROOM_ID_RECORD AS OBJECT
(
    room_id INTEGER
);

-- typ potrzebny do room_filter_id
CREATE OR REPLACE TYPE T_ROOM_ID_TABLE AS TABLE OF T_ROOM_ID_RECORD;

-- OK Zwracanie tabeli z id pokoi, które spełniają wymagania
CREATE OR REPLACE FUNCTION room_filter_id(
    p_date_from reservation.checkin_date%TYPE DEFAULT sysdate,
    p_date_to reservation.checkout_date%TYPE DEFAULT sysdate + 7,
    p_min_price room_type.base_price%TYPE DEFAULT 0.00,
    p_max_price room_type.base_price%TYPE DEFAULT 9999.00,
    p_room_type room_type.name%TYPE DEFAULT '%') RETURN T_ROOM_ID_TABLE AS
    v_ret         T_ROOM_ID_TABLE;
    c_rooms       SYS_REFCURSOR;
    TYPE T_ROOM_RECORD_TYPE IS RECORD (id room.id%TYPE, name room_type.name%TYPE, base_price room_type.base_price%TYPE);
    v_room_record T_ROOM_RECORD_TYPE;
BEGIN
    v_ret := t_room_id_table();

    c_rooms := room_filter(p_date_from, p_date_to, p_min_price, p_max_price, p_room_type);

    LOOP
        FETCH c_rooms INTO v_room_record;
        EXIT WHEN c_rooms%NOTFOUND;
        v_ret.extend;
        v_ret(v_ret.count) := T_ROOM_ID_RECORD(v_room_record.id);
    END LOOP;
    CLOSE c_rooms;

    RETURN v_ret;
END room_filter_id;

-- OK cena za pokoj
CREATE OR REPLACE FUNCTION room_price(
    p_guest_id guest.id%TYPE,
    p_room_id room.id%TYPE,
    p_start_date reservation.checkin_date%TYPE,
    p_end_date reservation.checkout_date%TYPE) RETURN NUMBER AS

    v_base_price              room_type.base_price%TYPE;
    v_season_multiplier       season_pricing.multiplier%TYPE;
    v_guest_status_multiplier guest_status.multiplier%TYPE;
    v_duration                INTEGER;
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
              sysdate >= start_date
          AND sysdate <= end_date;

    EXCEPTION
        WHEN no_data_found THEN
            v_season_multiplier := 1.0;
    END;

    v_duration := trunc(p_end_date - p_start_date + 1);

    dbms_output.PUT_LINE('v_base_price: ' || v_base_price);
    dbms_output.PUT_LINE('v_guest_status_multiplier: ' || v_guest_status_multiplier);
    dbms_output.PUT_LINE('v_season_multiplier: ' || v_season_multiplier);
    dbms_output.PUT_LINE('v_duration: ' || v_duration);

    RETURN trunc(v_base_price * v_guest_status_multiplier * v_season_multiplier * v_duration, 2);
END;

-- OK W jakim sezonie była dana rezerwacja
CREATE OR REPLACE FUNCTION season_for_reservation(
    p_reservation_id reservation.id%TYPE
) RETURN season_pricing.id%TYPE AS
    v_reservation_date reservation.checkin_date%TYPE;
    CURSOR season_cursor IS
        SELECT *
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

    FOR season IN season_cursor
        LOOP
            IF v_reservation_date BETWEEN season.start_date AND season.end_date THEN
                RETURN season.id;
            END IF;
        END LOOP;

    RETURN NULL;
END;



--------------
--Procedures--
--------------

CREATE OR REPLACE PROCEDURE generate_year_by_year_report(
    p_start_year NUMBER, p_end_year NUMBER) AS
    v_report_table_name CHAR(16 CHAR);
    v_current_income    NUMBER(18, 2);
    v_current_guests    INTEGER;
    table_does_not_exist EXCEPTION;
    PRAGMA EXCEPTION_INIT (table_does_not_exist, -942);
BEGIN
    IF p_end_year > EXTRACT(YEAR FROM sysdate) THEN
        RAISE_APPLICATION_ERROR(-20006, 'End year cannot be later than the current year');
    END IF;

    v_report_table_name := 'report_' || to_char(p_start_year) || '_' || to_char(p_end_year);

    --drop the existing report table and ignore the exception if it does not exist
    BEGIN
        EXECUTE IMMEDIATE 'DROP TABLE ' || v_report_table_name;
    EXCEPTION
        WHEN table_does_not_exist THEN
            NULL;
    END;

    --create a new table for the report
    EXECUTE IMMEDIATE 'create table ' || v_report_table_name ||
                      ' (year INTEGER, income NUMBER(18, 2), clientsCount INTEGER)';

    FOR current_year IN p_start_year..p_end_year
        LOOP
            SELECT
                SUM(price)
            INTO v_current_income
            FROM
                reservation
            WHERE
                  EXTRACT(YEAR FROM checkin_date) = current_year
              AND reservation_status_id IN (3, 4, 5);

            IF v_current_income IS NULL THEN
                v_current_income := 0;
            END IF;

            SELECT
                COUNT(*)
            INTO v_current_guests
            FROM
                guests_in_reservation gir
                    LEFT JOIN reservation res ON gir.reservation_id = res.id
            WHERE
                  EXTRACT(YEAR FROM checkin_date) = current_year
              AND reservation_status_id IN (3, 4, 5);

            IF v_current_guests IS NULL THEN
                v_current_guests := 0;
            END IF;

            EXECUTE IMMEDIATE 'INSERT INTO ' || v_report_table_name || ' VALUES(' || to_char(current_year) || ', ' ||
                              to_char(v_current_income) || ', ' || to_char(v_current_guests) || ')';
        END LOOP;
END generate_year_by_year_report;

CREATE OR REPLACE PROCEDURE verify_reservation_status_checkin_job(
    p_reservation_id reservation.id%TYPE) AS
    v_reservation reservation%ROWTYPE;
BEGIN
    SELECT *
    INTO v_reservation
    FROM
        reservation
    WHERE
        id = p_reservation_id;

    IF v_reservation.reservation_status_id = 3 THEN
        UPDATE reservation
        SET
            reservation_status_id = 4
        WHERE
            id = p_reservation_id;
    ELSE
        UPDATE reservation
        SET
            reservation_status_id = 6
        WHERE
            id = p_reservation_id;
    END IF;
END verify_reservation_status_checkin_job;

CREATE OR REPLACE PROCEDURE verify_reservation_status_checkout_job(
    p_reservation_id reservation.id%TYPE) AS
    v_reservation reservation%ROWTYPE;
BEGIN
    SELECT *
    INTO v_reservation
    FROM
        reservation
    WHERE
        id = p_reservation_id;

    IF v_reservation.reservation_status_id = 4 THEN
        UPDATE reservation
        SET
            reservation_status_id = 5
        WHERE
            id = p_reservation_id;
    END IF;
END verify_reservation_status_checkout_job;

-- OK uzywane w triggerze check_payments
CREATE OR REPLACE PROCEDURE verify_reservation_status_changed(
    p_reservation_id reservation.id%TYPE,
    p_amount payment.amount%TYPE) AS
    v_left_to_pay reservation.price%TYPE;
    v_reservation reservation%ROWTYPE;
BEGIN
    v_left_to_pay := LEFT_TO_PAY(p_reservation_id);
    SELECT *
    INTO v_reservation
    FROM
        reservation
    WHERE
        id = p_reservation_id;

    IF v_reservation.reservation_status_id NOT BETWEEN 1 AND 2 THEN
        RAISE_APPLICATION_ERROR(-20000,
                                'Cannot add payments to a reservation with status different than unpaid or partially_paid. Reservation ID: ' ||
                                p_reservation_id);
    ELSIF v_left_to_pay - p_amount < 0 THEN
        RAISE_APPLICATION_ERROR(-20001,
                                'Overpay on reservation no. ' || p_reservation_id || '. Overpay: ' ||
                                TO_CHAR(p_amount - v_left_to_pay));
    ELSIF v_left_to_pay - p_amount = 0 THEN
        UPDATE reservation
        SET
            reservation_status_id = 3
        WHERE
            id = p_reservation_id;
    ELSIF v_left_to_pay - p_amount > 0 THEN
        UPDATE reservation
        SET
            reservation_status_id = 2
        WHERE
            id = p_reservation_id;
    ELSE
        RAISE_APPLICATION_ERROR(-20002,
                                'Unknown problem on reservation no. ' || p_reservation_id);
    END IF;


END verify_reservation_status_changed;

-- dodaj gościa
CREATE
    OR
    REPLACE PROCEDURE add_guest(
    p_first_name guest.first_name%TYPE,
    p_last_name guest.last_name%TYPE,
    p_phone guest.phone%TYPE,
    p_email guest.email%TYPE,
    p_nationality guest.nationality%TYPE,
    p_document_id guest.document_id%TYPE,
    p_birth_date guest.birth_date%TYPE,
    p_document_type_id guest.document_type_id %TYPE,
    p_status_id guest.status_id%TYPE) AS
BEGIN
    INSERT INTO
        guest (first_name, last_name, phone, email, nationality, document_id, birth_date, document_type_id,
               status_id)
    VALUES
    (p_first_name, p_last_name, p_phone, p_email, p_nationality, p_document_id, p_birth_date,
     p_document_type_id,
     p_status_id);
END add_guest;

-- dodaj płatność
CREATE
    OR
    REPLACE PROCEDURE add_payment(
    p_amount payment.amount%TYPE,
    p_payment_type_id payment.payment_type_id%TYPE,
    p_reservation_id payment.id%TYPE) AS
BEGIN
    INSERT INTO payment (amount, payment_type_id, reservation_id)
    VALUES (p_amount, p_payment_type_id, p_reservation_id);
END add_payment;

-- check-in - zmiana rezerwacji na active
CREATE
    OR
    REPLACE PROCEDURE check_in(
    p_reservation_id reservation.id%TYPE
) AS
BEGIN
    UPDATE reservation
    SET
        reservation_status_id = 4
    WHERE
        id = p_reservation_id;
END check_in;



------------
--Triggers--
------------

-- OK Sprawdza platnosci
CREATE OR REPLACE TRIGGER check_payments
    BEFORE INSERT
    ON payment
    FOR EACH ROW
BEGIN
    verify_reservation_status_changed(:new.reservation_id, :new.amount);
END check_payments;

-- OK Czy guest ma przynajmniej 1 formę kontaktu - create/update
CREATE OR REPLACE TRIGGER check_contact_data
    BEFORE
        INSERT OR UPDATE OF phone, email
    ON guest
    FOR EACH ROW
BEGIN
    IF :new.email IS NULL AND :new.phone IS NULL THEN
        RAISE_APPLICATION_ERROR(-20003,
                                'At least one contact method must be provided for the guest with ID ' || :new.id);
    END IF;
END check_contact_data;

-- OK Brak możliwości modyfikacji płatności
CREATE OR REPLACE TRIGGER block_payment_update
    BEFORE
        UPDATE
    ON payment
BEGIN
    RAISE_APPLICATION_ERROR(-20004, 'Payment data cannot be updated');
END block_payment_update;

-- OK Sprawdzanie nowego sezonu (czy się nie nakada z innymi)
CREATE OR REPLACE TRIGGER check_season
    FOR INSERT OR UPDATE OF start_date, end_date
    ON season_pricing
    COMPOUND TRIGGER
    TYPE T_SEASON_IDS IS TABLE OF season_pricing.id%TYPE INDEX BY BINARY_INTEGER;
    v_season_ids T_SEASON_IDS;
    v_counter BINARY_INTEGER := 1;

BEFORE STATEMENT IS
BEGIN
    NULL;
END BEFORE STATEMENT;

    BEFORE EACH ROW IS
    BEGIN
        NULL;
    END BEFORE EACH ROW;

    AFTER EACH ROW IS
    BEGIN
        v_season_ids(v_counter) := :new.id;
        v_counter := v_counter + 1;
    END AFTER EACH ROW;

    AFTER STATEMENT IS
    BEGIN
        FOR i IN 1..v_season_ids.count
            LOOP
                IF verify_season_dates(v_season_ids(i)) = FALSE THEN
                    RAISE_APPLICATION_ERROR(-20005, 'Duration of the season cannot collide with other seasons''');
                END IF;
            END LOOP;
    END AFTER STATEMENT;
    END check_season;

CREATE OR REPLACE TRIGGER checkin_out_date_job_trigger
    AFTER INSERT OR UPDATE OF checkin_date, checkout_date
    ON reservation
    FOR EACH ROW
DECLARE
    v_job_id          BINARY_INTEGER;
    v_checkin_job_id  BINARY_INTEGER;
    v_checkout_job_id BINARY_INTEGER;
BEGIN
    IF UPDATING ('checkin_date') OR INSERTING THEN
        BEGIN
            SELECT
                to_number(substr(job_name, 11))
            INTO v_checkin_job_id
            FROM
                user_scheduler_jobs
            WHERE
                    job_action = 'HOTEL.verify_reservation_status_checkin_job(' || to_char(:new.id) || ');';
        EXCEPTION
            WHEN no_data_found THEN
                v_checkin_job_id := 0;
        END;

        IF v_checkin_job_id != 0 THEN
            DBMS_JOB.REMOVE(v_checkin_job_id);
        END IF;

        dbms_job.submit(
                job => v_job_id,
                what => 'HOTEL.verify_reservation_status_checkin_job(' || to_char(:new.id) || ');',
                next_date => :new.checkin_date);
    END IF;

    IF UPDATING ('checkout_date') OR INSERTING THEN
        BEGIN
            SELECT
                to_number(substr(job_name, 11))
            INTO v_checkout_job_id
            FROM
                user_scheduler_jobs
            WHERE
                    job_action = 'HOTEL.verify_reservation_status_checkout_job(' || to_char(:new.id) || ');';
        EXCEPTION
            WHEN no_data_found THEN
                v_checkout_job_id := 0;
        END;

        IF v_checkout_job_id != 0 THEN
            DBMS_JOB.REMOVE(v_checkout_job_id);
        END IF;

        dbms_job.submit(
                job => v_job_id,
                what => 'HOTEL.verify_reservation_status_checkout_job(' || to_char(:new.id) || ');',
                next_date => :new.checkout_date);
    END IF;
END checkin_out_date_job_trigger;




---------
--Views--
---------

-- OK widok Wolne pokoje (aktualnie)
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
    sysdate NOT BETWEEN res.checkin_date AND res.checkout_date;


-- OK kto w danym dniu nie ma zapłaty za hotel
CREATE OR REPLACE VIEW not_paid_today AS
WITH
    payment_count AS (SELECT
                          reservation_id,
                          COUNT(*) as "Installments paid"
                      FROM
                          payment
                      GROUP BY reservation_id)
SELECT
    res.id              AS "Reservation ID",
    g.first_name,
    g.last_name,
    LEFT_TO_PAY(res.id) AS "Left to pay",
    "Installments paid"
FROM
    reservation res
        JOIN reservation_status rs
             ON res.reservation_status_id = rs.id
        JOIN guest g
             ON res.payer_id = g.id
        JOIN payment_count ON payment_count.reservation_id = res.id
WHERE
        rs.name IN (
                    'unpaid', 'partially_paid'
        );

CREATE OR REPLACE VIEW free_rooms_one_week AS
SELECT room_id, max_tenants, name, base_price
    FROM table(room_filter_id) frm
        JOIN room rm ON frm.room_id = rm.id
        JOIN room_type rt ON rm.room_type_id = rt.id;