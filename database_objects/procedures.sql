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