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