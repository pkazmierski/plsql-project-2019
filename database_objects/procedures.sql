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
                EXTRACT(YEAR FROM checkin_date) = current_year AND reservation_status_id IN (3,4,5);

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
                EXTRACT(YEAR FROM checkin_date) = current_year AND reservation_status_id IN (3,4,5);

            IF v_current_guests IS NULL THEN
                v_current_guests := 0;
            END IF;

            EXECUTE IMMEDIATE 'INSERT INTO ' || v_report_table_name || ' VALUES(' || to_char(current_year) || ', ' ||
                              to_char(v_current_income) || ', ' || to_char(v_current_guests) || ')';
        END LOOP;
END generate_year_by_year_report;


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