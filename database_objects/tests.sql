--Testy
SET SERVEROUTPUT ON;

BEGIN
    dbms_output.put_line(room_price(1, 101, sysdate, sysdate+7));
END;


DECLARE
    c_rooms SYS_REFCURSOR;
    TYPE t_room_record_type IS RECORD (id room.id%type, name room_type.name%type, base_price room_type.base_price%type);
    v_room_record t_room_record_type;
BEGIN
    c_rooms := room_filter(TO_DATE('2020-04-16 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2020-04-17 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 0, 999, '%');
    LOOP
        FETCH c_rooms INTO v_room_record;
        EXIT WHEN c_rooms%NOTFOUND;
        dbms_output.PUT_LINE(v_room_record.id || ' | ' || v_room_record.name || ' | ' || v_room_record.base_price);
    END LOOP;
    CLOSE c_rooms;
END;

SELECT room_id, max_tenants, name, base_price
    FROM table(room_filter_id(TO_DATE('2020-04-16 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2020-04-17 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 0, 999, '%')) frm
        JOIN room rm ON frm.room_id = rm.id
        JOIN room_type rt ON rm.room_type_id = rt.id;

CALL generate_year_by_year_report(1990, 2020);

BEGIN
    SELECT
        id,
        is_paid(id),
        LEFT_TO_PAY(id)
    FROM
        reservation;
END;

SELECT
    id,
    season_for_reservation(id)
FROM
    reservation;