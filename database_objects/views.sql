-- Widoki
-- DO SPRAWDZENIA widok Wolne pokoje (aktualnie)
CREATE OR REPLACE VIEW free_rooms AS
SELECT
    r.id,
    rt.name,
    rt.base_price,
    rt.name
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
SELECT
    res.id,
    g.first_name,
    g.last_name,
    yet_to_pay(res.id) AS "Left to pay"
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
        rs.name IN (
                    'unpaid', 'partially_paid'
        );