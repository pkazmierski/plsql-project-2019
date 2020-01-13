-- dodaj gościa
CREATE OR REPLACE PROCEDURE add_guest(
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
    (p_first_name, p_last_name, p_phone, p_email, p_nationality, p_document_id, p_birth_date, p_document_type_id,
     p_status_id);
END add_guest;


-- dodaj płatność
CREATE OR REPLACE PROCEDURE add_payment(
    p_amount payment.amount%TYPE,
    p_payment_type_id payment.payment_type_id%TYPE,
    p_reservation_id payment.id%TYPE) AS
BEGIN
    INSERT INTO payment (amount, payment_type_id, reservation_id)
    VALUES (p_amount, p_payment_type_id, p_reservation_id);
END add_payment;

-- check-in - zmiana rezerwacji na active
CREATE OR REPLACE PROCEDURE check_in(
    p_reservation_id reservation.id%TYPE
) AS
BEGIN
    UPDATE reservation
    SET
        reservation_status_id = 4
    WHERE
        id = p_reservation_id;
END check_in;