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