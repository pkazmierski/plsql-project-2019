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

CREATE OR REPLACE TYPE T_ROOM_ID_RECORD AS OBJECT
(
    room_id INTEGER
);

CREATE OR REPLACE TYPE T_ROOM_ID_TABLE AS TABLE OF T_ROOM_ID_RECORD;

-- mozliwe ze da sie zoptymalizowac, zeby ta tabela byla od razu z ustalonym rozmiarem (np. wziac count z kursora)
CREATE OR REPLACE FUNCTION room_filter_id(
    p_date_from reservation.checkin_date%TYPE DEFAULT sysdate,
    p_date_to reservation.checkout_date%TYPE DEFAULT sysdate + 7,
    p_min_price room_type.base_price%TYPE DEFAULT 0.00,
    p_max_price room_type.base_price%TYPE DEFAULT 9999.00,
    p_room_type room_type.name%TYPE DEFAULT '%') RETURN T_ROOM_ID_TABLE AS
    v_ret         T_ROOM_ID_TABLE;
    v_room_id     room.id%TYPE;
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