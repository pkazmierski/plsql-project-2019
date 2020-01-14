INSERT INTO HOTEL.DOCUMENT_TYPE (ID, NAME) VALUES (1, 'ID card');
INSERT INTO HOTEL.DOCUMENT_TYPE (ID, NAME) VALUES (2, 'Passport');
INSERT INTO HOTEL.DOCUMENT_TYPE (ID, NAME) VALUES (3, 'Student ID');
INSERT INTO HOTEL.DOCUMENT_TYPE (ID, NAME) VALUES (4, 'Driving licence');


INSERT INTO HOTEL.GUEST (ID, FIRST_NAME, LAST_NAME, PHONE, EMAIL, NATIONALITY, DOCUMENT_ID, BIRTH_DATE, DOCUMENT_TYPE_ID, STATUS_ID) VALUES (1, 'John', 'Doe', 111222333, 'johndoe@mail.com', 'English', 'JFV5R3', TO_DATE('1990-05-03 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 1, 5);
INSERT INTO HOTEL.GUEST (ID, FIRST_NAME, LAST_NAME, PHONE, EMAIL, NATIONALITY, DOCUMENT_ID, BIRTH_DATE, DOCUMENT_TYPE_ID, STATUS_ID) VALUES (2, 'Jane', 'Done', 111222335, 'janed@mail.com', 'English', 'GFV433', TO_DATE('1982-11-08 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 1, 1);
INSERT INTO HOTEL.GUEST (ID, FIRST_NAME, LAST_NAME, PHONE, EMAIL, NATIONALITY, DOCUMENT_ID, BIRTH_DATE, DOCUMENT_TYPE_ID, STATUS_ID) VALUES (3, 'Hannah', 'Drewton', 551222333, 'hannah@mail.com', 'English', 'GETER3', TO_DATE('1991-06-12 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 2, 3);
INSERT INTO HOTEL.GUEST (ID, FIRST_NAME, LAST_NAME, PHONE, EMAIL, NATIONALITY, DOCUMENT_ID, BIRTH_DATE, DOCUMENT_TYPE_ID, STATUS_ID) VALUES (4, 'David', 'Drewton', 751226343, 'dvddrw@mail.com', 'English', '94TER3', TO_DATE('1975-02-21 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 1, 2);
INSERT INTO HOTEL.GUEST (ID, FIRST_NAME, LAST_NAME, PHONE, EMAIL, NATIONALITY, DOCUMENT_ID, BIRTH_DATE, DOCUMENT_TYPE_ID, STATUS_ID) VALUES (5, 'Staycey', 'McKenzie', 123456789, 'stackie@mymail.com', 'American', '00TETDSFD', TO_DATE('1990-03-14 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 2, 3);
INSERT INTO HOTEL.GUEST (ID, FIRST_NAME, LAST_NAME, PHONE, EMAIL, NATIONALITY, DOCUMENT_ID, BIRTH_DATE, DOCUMENT_TYPE_ID, STATUS_ID) VALUES (6, 'Brian', 'Goldwood', 486205369, 'bgoldwood@mail.co.uk', 'English', 'G64FETB3', TO_DATE('1978-05-23 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 2, 2);
INSERT INTO HOTEL.GUEST (ID, FIRST_NAME, LAST_NAME, PHONE, EMAIL, NATIONALITY, DOCUMENT_ID, BIRTH_DATE, DOCUMENT_TYPE_ID, STATUS_ID) VALUES (7, 'Patrycja', 'Kowalska', 548413645, 'patikovaa@mojapoczta.pl', 'Polish', 'YYHH654', TO_DATE('1989-08-18 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 1, 3);
INSERT INTO HOTEL.GUEST (ID, FIRST_NAME, LAST_NAME, PHONE, EMAIL, NATIONALITY, DOCUMENT_ID, BIRTH_DATE, DOCUMENT_TYPE_ID, STATUS_ID) VALUES (8, 'Mariusz', 'Tracz', 825390716, 'kolejarz87@mail.com', 'Polish', '647HHRRK5', TO_DATE('1985-10-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 1, 3);
INSERT INTO HOTEL.GUEST (ID, FIRST_NAME, LAST_NAME, PHONE, EMAIL, NATIONALITY, DOCUMENT_ID, BIRTH_DATE, DOCUMENT_TYPE_ID, STATUS_ID) VALUES (9, 'Anna', 'Graczyk', 563093673, 'anka777@poczta.pl', 'Polish', 'T3RETR435', TO_DATE('1998-09-28 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 1, 5);
INSERT INTO HOTEL.GUEST (ID, FIRST_NAME, LAST_NAME, PHONE, EMAIL, NATIONALITY, DOCUMENT_ID, BIRTH_DATE, DOCUMENT_TYPE_ID, STATUS_ID) VALUES (10, 'Karol', 'Nowak', 762111335, 'k.nowak@poczta.pl', 'Polish', 'H3V421', TO_DATE('1992-07-10 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 2, 1);
INSERT INTO HOTEL.GUEST (ID, FIRST_NAME, LAST_NAME, PHONE, EMAIL, NATIONALITY, DOCUMENT_ID, BIRTH_DATE, DOCUMENT_TYPE_ID, STATUS_ID) VALUES (11, 'Abraham', 'Sparrow', 645738269, 'asp@mail.com', 'American', 'FG345JS45', TO_DATE('1990-01-11 20:12:23', 'YYYY-MM-DD HH24:MI:SS'), 2, 1);


INSERT INTO HOTEL.GUESTS_IN_RESERVATION (GUEST_ID, RESERVATION_ID) VALUES (1, 1);
INSERT INTO HOTEL.GUESTS_IN_RESERVATION (GUEST_ID, RESERVATION_ID) VALUES (1, 11);
INSERT INTO HOTEL.GUESTS_IN_RESERVATION (GUEST_ID, RESERVATION_ID) VALUES (2, 2);
INSERT INTO HOTEL.GUESTS_IN_RESERVATION (GUEST_ID, RESERVATION_ID) VALUES (3, 3);
INSERT INTO HOTEL.GUESTS_IN_RESERVATION (GUEST_ID, RESERVATION_ID) VALUES (4, 4);
INSERT INTO HOTEL.GUESTS_IN_RESERVATION (GUEST_ID, RESERVATION_ID) VALUES (5, 5);
INSERT INTO HOTEL.GUESTS_IN_RESERVATION (GUEST_ID, RESERVATION_ID) VALUES (5, 10);
INSERT INTO HOTEL.GUESTS_IN_RESERVATION (GUEST_ID, RESERVATION_ID) VALUES (6, 6);
INSERT INTO HOTEL.GUESTS_IN_RESERVATION (GUEST_ID, RESERVATION_ID) VALUES (6, 8);
INSERT INTO HOTEL.GUESTS_IN_RESERVATION (GUEST_ID, RESERVATION_ID) VALUES (6, 9);
INSERT INTO HOTEL.GUESTS_IN_RESERVATION (GUEST_ID, RESERVATION_ID) VALUES (7, 7);
INSERT INTO HOTEL.GUESTS_IN_RESERVATION (GUEST_ID, RESERVATION_ID) VALUES (8, 6);
INSERT INTO HOTEL.GUESTS_IN_RESERVATION (GUEST_ID, RESERVATION_ID) VALUES (9, 8);
INSERT INTO HOTEL.GUESTS_IN_RESERVATION (GUEST_ID, RESERVATION_ID) VALUES (9, 9);
INSERT INTO HOTEL.GUESTS_IN_RESERVATION (GUEST_ID, RESERVATION_ID) VALUES (10, 7);
INSERT INTO HOTEL.GUESTS_IN_RESERVATION (GUEST_ID, RESERVATION_ID) VALUES (10, 8);
INSERT INTO HOTEL.GUESTS_IN_RESERVATION (GUEST_ID, RESERVATION_ID) VALUES (10, 9);
INSERT INTO HOTEL.GUESTS_IN_RESERVATION (GUEST_ID, RESERVATION_ID) VALUES (11, 9);
INSERT INTO HOTEL.GUESTS_IN_RESERVATION (GUEST_ID, RESERVATION_ID) VALUES (11, 10);


INSERT INTO HOTEL.GUEST_STATUS (ID, STATUS_NAME, MULTIPLIER) VALUES (1, 'bronze', 1);
INSERT INTO HOTEL.GUEST_STATUS (ID, STATUS_NAME, MULTIPLIER) VALUES (2, 'silver', 0.95);
INSERT INTO HOTEL.GUEST_STATUS (ID, STATUS_NAME, MULTIPLIER) VALUES (3, 'gold', 0.9);
INSERT INTO HOTEL.GUEST_STATUS (ID, STATUS_NAME, MULTIPLIER) VALUES (4, 'diamond', 0.85);
INSERT INTO HOTEL.GUEST_STATUS (ID, STATUS_NAME, MULTIPLIER) VALUES (5, 'platinum', 0.8);


INSERT INTO HOTEL.PAYMENT (ID, AMOUNT, PAYMENT_TYPE_ID, RESERVATION_ID) VALUES (1, 70, 2, 2);
INSERT INTO HOTEL.PAYMENT (ID, AMOUNT, PAYMENT_TYPE_ID, RESERVATION_ID) VALUES (2, 40, 1, 3);
INSERT INTO HOTEL.PAYMENT (ID, AMOUNT, PAYMENT_TYPE_ID, RESERVATION_ID) VALUES (3, 70, 3, 4);
INSERT INTO HOTEL.PAYMENT (ID, AMOUNT, PAYMENT_TYPE_ID, RESERVATION_ID) VALUES (4, 70, 6, 5);
INSERT INTO HOTEL.PAYMENT (ID, AMOUNT, PAYMENT_TYPE_ID, RESERVATION_ID) VALUES (5, 75, 1, 6);
INSERT INTO HOTEL.PAYMENT (ID, AMOUNT, PAYMENT_TYPE_ID, RESERVATION_ID) VALUES (6, 150, 4, 7);
INSERT INTO HOTEL.PAYMENT (ID, AMOUNT, PAYMENT_TYPE_ID, RESERVATION_ID) VALUES (7, 100, 5, 8);
INSERT INTO HOTEL.PAYMENT (ID, AMOUNT, PAYMENT_TYPE_ID, RESERVATION_ID) VALUES (8, 230, 5, 9);
INSERT INTO HOTEL.PAYMENT (ID, AMOUNT, PAYMENT_TYPE_ID, RESERVATION_ID) VALUES (9, 100, 1, 10);
INSERT INTO HOTEL.PAYMENT (ID, AMOUNT, PAYMENT_TYPE_ID, RESERVATION_ID) VALUES (10, 50, 5, 9);
INSERT INTO HOTEL.PAYMENT (ID, AMOUNT, PAYMENT_TYPE_ID, RESERVATION_ID) VALUES (11, 40, 5, 9);
INSERT INTO HOTEL.PAYMENT (ID, AMOUNT, PAYMENT_TYPE_ID, RESERVATION_ID) VALUES (12, 30, 5, 8);
INSERT INTO HOTEL.PAYMENT (ID, AMOUNT, PAYMENT_TYPE_ID, RESERVATION_ID) VALUES (13, 100, 1, 10);


INSERT INTO HOTEL.PAYMENT_TYPE (ID, NAME) VALUES (1, 'Cash');
INSERT INTO HOTEL.PAYMENT_TYPE (ID, NAME) VALUES (2, 'Bank transfer');
INSERT INTO HOTEL.PAYMENT_TYPE (ID, NAME) VALUES (3, 'Cheque');
INSERT INTO HOTEL.PAYMENT_TYPE (ID, NAME) VALUES (4, 'Card');
INSERT INTO HOTEL.PAYMENT_TYPE (ID, NAME) VALUES (5, 'PayPal');
INSERT INTO HOTEL.PAYMENT_TYPE (ID, NAME) VALUES (6, 'Mobile payment');


INSERT INTO HOTEL.RESERVATION (ID, CREATION_DATE, CHECKIN_DATE, CHECKOUT_DATE, ROOM_ID, RESERVATION_STATUS_ID, PRICE, PAYER_ID) VALUES (1, TO_DATE('2020-01-09 12:05:39', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2020-05-21 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2020-05-30 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 101, 1, 70.00, 1);
INSERT INTO HOTEL.RESERVATION (ID, CREATION_DATE, CHECKIN_DATE, CHECKOUT_DATE, ROOM_ID, RESERVATION_STATUS_ID, PRICE, PAYER_ID) VALUES (2, TO_DATE('2020-01-05 12:05:39', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2020-09-10 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2020-09-20 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 102, 3, 70.00, 2);
INSERT INTO HOTEL.RESERVATION (ID, CREATION_DATE, CHECKIN_DATE, CHECKOUT_DATE, ROOM_ID, RESERVATION_STATUS_ID, PRICE, PAYER_ID) VALUES (3, TO_DATE('2020-01-03 12:05:39', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2020-08-10 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2020-08-20 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 103, 2, 70.00, 3);
INSERT INTO HOTEL.RESERVATION (ID, CREATION_DATE, CHECKIN_DATE, CHECKOUT_DATE, ROOM_ID, RESERVATION_STATUS_ID, PRICE, PAYER_ID) VALUES (4, TO_DATE('2020-01-06 12:05:39', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2020-01-08 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2020-01-15 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 201, 3, 70.00, 4);
INSERT INTO HOTEL.RESERVATION (ID, CREATION_DATE, CHECKIN_DATE, CHECKOUT_DATE, ROOM_ID, RESERVATION_STATUS_ID, PRICE, PAYER_ID) VALUES (5, TO_DATE('2020-01-10 12:05:39', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2020-03-15 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2020-03-20 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 202, 3, 70.00, 5);
INSERT INTO HOTEL.RESERVATION (ID, CREATION_DATE, CHECKIN_DATE, CHECKOUT_DATE, ROOM_ID, RESERVATION_STATUS_ID, PRICE, PAYER_ID) VALUES (6, TO_DATE('2020-01-08 12:05:39', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2020-02-07 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2020-02-11 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 104, 2, 150.00, 8);
INSERT INTO HOTEL.RESERVATION (ID, CREATION_DATE, CHECKIN_DATE, CHECKOUT_DATE, ROOM_ID, RESERVATION_STATUS_ID, PRICE, PAYER_ID) VALUES (7, TO_DATE('2020-01-05 12:05:39', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2020-04-10 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2020-04-16 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 204, 3, 150.00, 7);
INSERT INTO HOTEL.RESERVATION (ID, CREATION_DATE, CHECKIN_DATE, CHECKOUT_DATE, ROOM_ID, RESERVATION_STATUS_ID, PRICE, PAYER_ID) VALUES (8, TO_DATE('2020-01-05 12:05:39', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2020-06-22 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2020-06-30 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 109, 2, 300.00, 9);
INSERT INTO HOTEL.RESERVATION (ID, CREATION_DATE, CHECKIN_DATE, CHECKOUT_DATE, ROOM_ID, RESERVATION_STATUS_ID, PRICE, PAYER_ID) VALUES (9, TO_DATE('2020-01-03 12:05:39', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2020-07-12 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2020-07-18 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 211, 2, 350.00, 9);
INSERT INTO HOTEL.RESERVATION (ID, CREATION_DATE, CHECKIN_DATE, CHECKOUT_DATE, ROOM_ID, RESERVATION_STATUS_ID, PRICE, PAYER_ID) VALUES (10, TO_DATE('2020-01-05 12:05:39', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2020-10-05 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2020-10-06 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 207, 3, 200.00, 5);
INSERT INTO HOTEL.RESERVATION (ID, CREATION_DATE, CHECKIN_DATE, CHECKOUT_DATE, ROOM_ID, RESERVATION_STATUS_ID, PRICE, PAYER_ID) VALUES (11, TO_DATE('2020-01-02 12:05:39', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2020-11-12 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2020-11-19 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 208, 1, 150.00, 1);
INSERT INTO HOTEL.RESERVATION (ID, CREATION_DATE, CHECKIN_DATE, CHECKOUT_DATE, ROOM_ID, RESERVATION_STATUS_ID, PRICE, PAYER_ID) VALUES (12, TO_DATE('2020-01-03 22:58:09', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2020-11-20 22:58:15', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2020-11-27 22:58:33', 'YYYY-MM-DD HH24:MI:SS'), 101, 1, 70.00, 1);


INSERT INTO HOTEL.RESERVATION_STATUS (ID, NAME) VALUES (1, 'unpaid');
INSERT INTO HOTEL.RESERVATION_STATUS (ID, NAME) VALUES (2, 'partially_paid');
INSERT INTO HOTEL.RESERVATION_STATUS (ID, NAME) VALUES (3, 'confirmed');
INSERT INTO HOTEL.RESERVATION_STATUS (ID, NAME) VALUES (4, 'active');
INSERT INTO HOTEL.RESERVATION_STATUS (ID, NAME) VALUES (5, 'completed');
INSERT INTO HOTEL.RESERVATION_STATUS (ID, NAME) VALUES (6, 'cancelled');


INSERT INTO HOTEL.ROOM (ID, MAX_TENANTS, ROOM_TYPE_ID) VALUES (101, 1, 1);
INSERT INTO HOTEL.ROOM (ID, MAX_TENANTS, ROOM_TYPE_ID) VALUES (102, 1, 1);
INSERT INTO HOTEL.ROOM (ID, MAX_TENANTS, ROOM_TYPE_ID) VALUES (103, 1, 1);
INSERT INTO HOTEL.ROOM (ID, MAX_TENANTS, ROOM_TYPE_ID) VALUES (104, 2, 2);
INSERT INTO HOTEL.ROOM (ID, MAX_TENANTS, ROOM_TYPE_ID) VALUES (105, 2, 2);
INSERT INTO HOTEL.ROOM (ID, MAX_TENANTS, ROOM_TYPE_ID) VALUES (106, 2, 3);
INSERT INTO HOTEL.ROOM (ID, MAX_TENANTS, ROOM_TYPE_ID) VALUES (107, 2, 3);
INSERT INTO HOTEL.ROOM (ID, MAX_TENANTS, ROOM_TYPE_ID) VALUES (108, 2, 3);
INSERT INTO HOTEL.ROOM (ID, MAX_TENANTS, ROOM_TYPE_ID) VALUES (109, 3, 4);
INSERT INTO HOTEL.ROOM (ID, MAX_TENANTS, ROOM_TYPE_ID) VALUES (110, 3, 4);
INSERT INTO HOTEL.ROOM (ID, MAX_TENANTS, ROOM_TYPE_ID) VALUES (111, 4, 5);
INSERT INTO HOTEL.ROOM (ID, MAX_TENANTS, ROOM_TYPE_ID) VALUES (201, 1, 1);
INSERT INTO HOTEL.ROOM (ID, MAX_TENANTS, ROOM_TYPE_ID) VALUES (202, 1, 1);
INSERT INTO HOTEL.ROOM (ID, MAX_TENANTS, ROOM_TYPE_ID) VALUES (203, 1, 1);
INSERT INTO HOTEL.ROOM (ID, MAX_TENANTS, ROOM_TYPE_ID) VALUES (204, 2, 2);
INSERT INTO HOTEL.ROOM (ID, MAX_TENANTS, ROOM_TYPE_ID) VALUES (205, 2, 2);
INSERT INTO HOTEL.ROOM (ID, MAX_TENANTS, ROOM_TYPE_ID) VALUES (206, 2, 3);
INSERT INTO HOTEL.ROOM (ID, MAX_TENANTS, ROOM_TYPE_ID) VALUES (207, 2, 3);
INSERT INTO HOTEL.ROOM (ID, MAX_TENANTS, ROOM_TYPE_ID) VALUES (208, 2, 3);
INSERT INTO HOTEL.ROOM (ID, MAX_TENANTS, ROOM_TYPE_ID) VALUES (209, 3, 4);
INSERT INTO HOTEL.ROOM (ID, MAX_TENANTS, ROOM_TYPE_ID) VALUES (210, 3, 4);
INSERT INTO HOTEL.ROOM (ID, MAX_TENANTS, ROOM_TYPE_ID) VALUES (211, 4, 6);


INSERT INTO HOTEL.ROOM_TYPE (ID, NAME, BASE_PRICE) VALUES (1, 'Single', 70);
INSERT INTO HOTEL.ROOM_TYPE (ID, NAME, BASE_PRICE) VALUES (2, 'King', 150);
INSERT INTO HOTEL.ROOM_TYPE (ID, NAME, BASE_PRICE) VALUES (3, 'Twin', 200);
INSERT INTO HOTEL.ROOM_TYPE (ID, NAME, BASE_PRICE) VALUES (4, 'Triple', 250);
INSERT INTO HOTEL.ROOM_TYPE (ID, NAME, BASE_PRICE) VALUES (5, 'Quad', 350);
INSERT INTO HOTEL.ROOM_TYPE (ID, NAME, BASE_PRICE) VALUES (6, 'Double king', 300);


INSERT INTO HOTEL.SEASON_PRICING (ID, START_DATE, END_DATE, MULTIPLIER, NAME) VALUES (1, TO_DATE('2020-12-20 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2020-01-03 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 1.8, 'Christmas and New Year');
INSERT INTO HOTEL.SEASON_PRICING (ID, START_DATE, END_DATE, MULTIPLIER, NAME) VALUES (2, TO_DATE('2020-06-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2020-09-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 1.5, 'Summer');
INSERT INTO HOTEL.SEASON_PRICING (ID, START_DATE, END_DATE, MULTIPLIER, NAME) VALUES (3, TO_DATE('2020-05-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2020-05-04 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 1.2, 'Easter');