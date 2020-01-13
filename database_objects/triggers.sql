-- DO POPRAWY (NIE BLOKUJE NIC, EXCEPTION PRAWD. DO ZMIANY) Czy guest ma przynajmniej 1 formę kontaktu - create/update
CREATE OR REPLACE TRIGGER check_contact_data
    BEFORE
        INSERT OR UPDATE OF phone, email
    ON guest
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
CREATE OR REPLACE TRIGGER block_payment_update
    BEFORE
        UPDATE
    ON payment
DECLARE
    e_no_update_allowed EXCEPTION;
BEGIN
    RAISE e_no_update_allowed;
EXCEPTION
    WHEN e_no_update_allowed THEN
        dbms_output.put_line('Updating PAYMENT table is not allowed');
END;

-- DO POPRAWY, MÓWIEM O MUTOWANIU TABELI sprawdzanie nowego sezonu (czy się nie nakada z innymi)
CREATE OR REPLACE TRIGGER check_new_season
    BEFORE
        INSERT
    ON season_pricing
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
          :new.start_date >= sp.start_date
      AND :new.end_date <= sp.end_date;

    IF v_counter >= 1 THEN
        RAISE e_no_season_found;
    END IF;
EXCEPTION
    WHEN e_no_season_found THEN
        dbms_output.put_line('Cannot add a season that interferes with any other');
END;