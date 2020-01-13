-- DO SPRAWDZENIA czy rezerwacja zostala oplacona
CREATE OR REPLACE FUNCTION is_paid(
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
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END;

-- DO POPRAWY cena za pokoj
CREATE OR REPLACE FUNCTION room_price(
    p_guest_id guest.id%TYPE,
    p_room_id room.id%TYPE) RETURN NUMBER AS

    v_calculated_price        room_type.base_price%TYPE;
    v_base_price              room_type.base_price%TYPE;
    v_season_multiplier       season_pricing.multiplier%TYPE;
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
              sysdate >= start_date
          AND sysdate <= end_date;

    EXCEPTION
        WHEN no_data_found THEN
            v_season_multiplier := 1.0;
    END;

    RETURN trunc(v_base_price * v_guest_status_multiplier * v_season_multiplier, 2);
END;

-- DO SPRAWDZENIA W jakim sezonie była dana rezerwacja
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

-- DO SPRAWDZENIA Zwracanie całych rzędów pokoi, które są wolne i mają podane parametry (filtrowanie, niech będą defaulty albo jakieś inne ogarnięcie przypadków, gdy nie ma podanego danego parametru)
CREATE OR REPLACE FUNCTION available_rooms(
    p_date_from reservation.checkin_date%TYPE DEFAULT to_char(sysdate),
    p_date_to reservation.checkout_date%TYPE DEFAULT to_char(
            sysdate + 7),
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
                         AND (p_date_to NOT BETWEEN res.checkin_date
                           AND res.checkout_date)
                         AND rt.name LIKE p_room_type;
    s
    RETURN my_cursor;
END;



-- OK Ile z wymaganej kwoty rezerwacji zostało już wpłacone/ile do zapłacenia
CREATE OR REPLACE FUNCTION yet_to_pay(
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

    dbms_output.put_line('res id: ' || p_reservation_id || ', v_payments_sum: ' || v_payments_sum);
    SELECT
        price
    INTO v_res_price
    FROM
        reservation res
    WHERE
        id = p_reservation_id;

    RETURN trunc(v_res_price - v_payments_sum, 2);
END;