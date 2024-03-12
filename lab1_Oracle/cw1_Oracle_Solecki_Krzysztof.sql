create TYPE TRIP_OBJ AS OBJECT
(
    TRIP_ID       NUMBER,
    TRIP_NAME     VARCHAR(100),
    COUNTRY_ID    NUMBER,
    "TRIP_DATE"   DATE,
    MAX_NO_PLACES NUMBER
)
/

create TYPE TRIPS_TABLE IS TABLE OF TRIP_OBJ
/

create TYPE PERSON_TRIP_OBJ AS OBJECT
(
    TRIP_NAME   NVARCHAR2(100),
    COUNTRY_ID  NUMBER,
    "TRIP_DATE" DATE,
    FIRSTNAME   NVARCHAR2(50),
    LASTNAME    NVARCHAR2(50),
    STATUS      CHAR(1)
)
/

create type TRIPS_TABLE as table of TRIP_OBJ
/

create type PERSON_TRIP_TABLE as table of PERSON_TRIP_OBJ
/

create table PERSON
(
    PERSON_ID NUMBER generated as identity
        constraint PERSON_PK
            primary key,
    FIRSTNAME VARCHAR2(50),
    LASTNAME  VARCHAR2(50)
)
/

create table COUNTRY
(
    COUNTRY_ID   NUMBER generated as identity
        constraint COUNTRY_PK
            primary key,
    COUNTRY_NAME VARCHAR2(50)
)
/

create table TRIP
(
    TRIP_ID             NUMBER generated as identity
        constraint TRIP_PK
            primary key,
    TRIP_NAME           VARCHAR2(100),
    COUNTRY_ID          NUMBER
        constraint TRIP_FK1
            references COUNTRY,
    TRIP_DATE           DATE,
    MAX_NO_PLACES       NUMBER,
    NO_AVAILABLE_PLACES NUMBER
)
/

create trigger MODIFY_NO_PLACES_TRIGGER
    after update of MAX_NO_PLACES
    on TRIP
    for each row
BEGIN
    UPDATE TRIP
    SET NO_AVAILABLE_PLACES = NO_AVAILABLE_PLACES + (:NEW.MAX_NO_PLACES - TRIP.MAX_NO_PLACES);
end;
/

create table RESERVATION
(
    RESERVATION_ID NUMBER generated as identity
        constraint RESERVATION_PK
            primary key,
    TRIP_ID        NUMBER
        constraint RESERVATION_FK2
            references TRIP,
    PERSON_ID      NUMBER
        constraint RESERVATION_FK1
            references PERSON,
    STATUS         CHAR
        constraint RESERVATION_CHK1
            check (status in ('N', 'P', 'C'))
)
/

create trigger PREVENT_DELETE_RESERVATION_TRIGGER
    before delete
    on RESERVATION
    for each row
BEGIN
    RAISE_APPLICATION_ERROR(-20008, 'Removing reservation forbidden');
end;
/

create trigger MODIFY_RESERVATION_STATUS_TRIGGER
    after update
    on RESERVATION
    for each row
DECLARE
    new_places INT;
BEGIN
    INSERT INTO LOG (RESERVATION_ID, LOG_DATE, STATUS)
    VALUES (:NEW.RESERVATION_ID, CURRENT_DATE, :NEW.STATUS);

    IF :NEW.STATUS = 'C' THEN
        new_places := 1;
    ELSE
        new_places := 0;
    end if;

    UPDATE TRIP t
    SET NO_AVAILABLE_PLACES = NO_AVAILABLE_PLACES + new_places
    WHERE t.TRIP_ID = :NEW.trip_id;

end MODIFY_RESERVATION_STATUS_TRIGGER;
/

create trigger ADD_RESERVATION_TRIGGER
    after insert or update
    on RESERVATION
    for each row
BEGIN
    INSERT INTO LOG (RESERVATION_ID, LOG_DATE, STATUS)
    VALUES (:NEW.RESERVATION_ID, CURRENT_DATE, :NEW.STATUS);

    UPDATE TRIP t
    SET NO_AVAILABLE_PLACES = NO_AVAILABLE_PLACES - 1
    WHERE t.TRIP_ID = :NEW.TRIP_ID;
end;
/

create trigger ADD_RESERVATION_TRIGGER_2
    before insert
    on RESERVATION
    for each row
DECLARE
    trip_available INT;
BEGIN

    -- check if trip exists and is available (is in future and has free places), should return count > 0
    SELECT COUNT(*)
    INTO trip_available
    FROM AVAILABLE_TRIPS_VIEW
    WHERE AVAILABLE_TRIPS_VIEW.TRIP_ID = :NEW.trip_id;

    IF trip_available = 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'Trip with chosen ID not available.');
    END IF;
end;
/

create trigger MODIFY_RESERVATION_STATUS_TRIGGER_2
    before update
    on RESERVATION
    for each row
DECLARE
    PRAGMA AUTONOMOUS_TRANSACTION;
    t_noa_places INT;
BEGIN
    IF :NEW.STATUS != :OLD.STATUS THEN
        IF :NEW.STATUS = 'C' THEN
            COMMIT;
        ELSE
            IF :OLD.STATUS = 'C' THEN
                SELECT NO_AVAILABLE_PLACES
                INTO t_noa_places
                FROM TRIP
                WHERE TRIP.TRIP_ID = :NEW.TRIP_ID;
                IF t_noa_places >= 1 THEN
                    COMMIT;
                ELSE
                    RAISE_APPLICATION_ERROR(-20001, 'Not enought places');
                end if;
            end if;
        end if;
    end if;
end;
/

create table LOG
(
    LOG_ID         NUMBER generated as identity
        constraint LOG_PK
            primary key,
    RESERVATION_ID NUMBER not null
        constraint LOG_FK1
            references RESERVATION,
    LOG_DATE       DATE   not null,
    STATUS         CHAR
        constraint LOG_CHK1
            check (status in ('N', 'P', 'C'))
)
/

create view RESERVATIONS_VIEW as
SELECT COUNTRY_NAME,
       TRIP_DATE,
       TRIP_NAME,
       FIRSTNAME,
       LASTNAME,
       RESERVATION_ID,
       STATUS
FROM COUNTRY
         JOIN TRIP T on COUNTRY.COUNTRY_ID = T.COUNTRY_ID
         JOIN RESERVATION R on T.TRIP_ID = R.TRIP_ID
         JOIN PERSON P on P.PERSON_ID = R.PERSON_ID
/

create view TRIPS_VIEW as
SELECT COUNTRY_NAME,
       TRIP_DATE,
       TRIP_NAME,
       MAX_NO_PLACES,
       (MAX_NO_PLACES - COUNT(DISTINCT PERSON_ID)) AS NO_AVAILABLE_PLACES
FROM COUNTRY
         JOIN TRIP ON COUNTRY.COUNTRY_ID = TRIP.COUNTRY_ID
         LEFT JOIN (SELECT * FROM RESERVATION WHERE STATUS <> 'C') RESERVATION
                   ON RESERVATION.TRIP_ID = TRIP.TRIP_ID
GROUP BY COUNTRY.COUNTRY_NAME, TRIP.TRIP_ID, TRIP.TRIP_NAME, TRIP.TRIP_DATE, TRIP.MAX_NO_PLACES
/

create view AVAILABLE_TRIPS_VIEW as
SELECT COUNTRY_NAME,
       trip.TRIP_ID,
       TRIP_NAME,
       TRIP_DATE,
       MAX_NO_PLACES,
       (MAX_NO_PLACES - COUNT(DISTINCT PERSON_ID)) NO_AVAILABLE_PLACES
FROM COUNTRY
         JOIN TRIP on COUNTRY.COUNTRY_ID = trip.COUNTRY_ID
         LEFT JOIN (SELECT * FROM RESERVATION WHERE STATUS <> 'C') RESERVATION
                   ON RESERVATION.TRIP_ID = TRIP.TRIP_ID
GROUP BY COUNTRY.COUNTRY_NAME, TRIP.TRIP_ID, TRIP.TRIP_NAME, TRIP.TRIP_DATE, TRIP.MAX_NO_PLACES
HAVING TRIP_DATE > current_date
   AND MAX_NO_PLACES - COUNT(DISTINCT PERSON_ID) > 0
/

create view FUTURE_TRIPS_VIEW as
SELECT TRIP.TRIP_ID,
       TRIP_NAME,
       COUNTRY_NAME,
       TRIP_DATE,
       FIRSTNAME,
       LASTNAME,
       STATUS
FROM TRIP
         JOIN RESERVATION ON TRIP.TRIP_ID = RESERVATION.TRIP_ID
         JOIN COUNTRY ON TRIP.COUNTRY_ID = COUNTRY.COUNTRY_ID
         JOIN PERSON ON RESERVATION.PERSON_ID = PERSON.PERSON_ID
WHERE TRIP_DATE > CURRENT_DATE
/

create view TRIPS_NO_PLACES_VIEW as
SELECT TRIP.TRIP_ID,
       TRIP_NAME,
       COUNTRY_NAME,
       TRIP_DATE,
       MAX_NO_PLACES,
       (MAX_NO_PLACES - COUNT(DISTINCT r.PERSON_ID)) NO_AVAILABLE_PLACES
FROM TRIP
         JOIN COUNTRY C on TRIP.COUNTRY_ID = C.COUNTRY_ID
         LEFT JOIN (SELECT * FROM RESERVATION r WHERE r.STATUS <> 'C') r
                   ON r.TRIP_ID = TRIP.TRIP_ID
GROUP BY TRIP.TRIP_ID, TRIP_NAME, COUNTRY_NAME, TRIP_DATE, MAX_NO_PLACES
/

create view TRIPS_NO_PLACES_VIEW_4 as
SELECT TRIP.TRIP_ID,
       TRIP_NAME,
       COUNTRY_NAME,
       TRIP_DATE,
       MAX_NO_PLACES,
       NO_AVAILABLE_PLACES
FROM TRIP
         JOIN COUNTRY C on TRIP.COUNTRY_ID = C.COUNTRY_ID
         LEFT JOIN (SELECT * FROM RESERVATION r WHERE r.STATUS <> 'C') r
                   ON r.TRIP_ID = TRIP.TRIP_ID
GROUP BY TRIP.TRIP_ID, TRIP_NAME, COUNTRY_NAME, TRIP_DATE, MAX_NO_PLACES, NO_AVAILABLE_PLACES
/

create view AVAILABLE_TRIPS_VIEW_4 as
SELECT COUNTRY_NAME,
       trip.TRIP_ID,
       TRIP_NAME,
       TRIP_DATE,
       MAX_NO_PLACES,
       NO_AVAILABLE_PLACES
FROM COUNTRY
         JOIN TRIP on COUNTRY.COUNTRY_ID = trip.COUNTRY_ID
         LEFT JOIN (SELECT * FROM RESERVATION WHERE STATUS <> 'C') RESERVATION
                   ON RESERVATION.TRIP_ID = TRIP.TRIP_ID
GROUP BY COUNTRY.COUNTRY_NAME, TRIP.TRIP_ID, TRIP.TRIP_NAME, TRIP.TRIP_DATE, TRIP.MAX_NO_PLACES,
         TRIP.NO_AVAILABLE_PLACES
HAVING TRIP_DATE > current_date
   AND MAX_NO_PLACES - COUNT(DISTINCT PERSON_ID) > 0
/

create FUNCTION AVAILABLE_TRIPS(country TRIP.COUNTRY_ID%TYPE,
                                date_from DATE, date_to DATE)
    RETURN TRIPS_TABLE
AS
    result TRIPS_TABLE;
BEGIN
    IF date_from > date_to THEN
        RAISE_APPLICATION_ERROR(-20001, 'Date_from must by <= date_to');
    end if;

    SELECT TRIP_OBJ(TRIP_ID, TRIP_NAME, COUNTRY_ID, TRIP_DATE, MAX_NO_PLACES) BULK COLLECT
    INTO result
    FROM TRIP
    WHERE TRIP.COUNTRY_ID = AVAILABLE_TRIPS.country
      AND TRIP.TRIP_DATE >= AVAILABLE_TRIPS.date_from
      AND TRIP.TRIP_DATE <= AVAILABLE_TRIPS.date_to
      AND TRIP.MAX_NO_PLACES >
          (SELECT COUNT(*)
           FROM RESERVATION r
           WHERE r.STATUS <> 'C'
             AND r.TRIP_ID = TRIP.TRIP_ID);
    RETURN result;
END;
/

create FUNCTION TRIP_PARTICIPANTS(id TRIP.TRIP_ID%TYPE)
    RETURN PERSON_TRIP_TABLE
AS
    result      PERSON_TRIP_TABLE;
    -- 1 - exists, 0 - not exists
    trip_exists INT;
BEGIN
    SELECT COUNT(*) INTO trip_exists FROM TRIP WHERE TRIP.TRIP_ID = TRIP_PARTICIPANTS.id;
    IF trip_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20000, 'Trip with chosen ID not found');
    END IF;

    SELECT PERSON_TRIP_OBJ(TRIP_NAME, COUNTRY_ID, TRIP_DATE, FIRSTNAME, LASTNAME, STATUS) BULK COLLECT
    INTO result
    FROM TRIP
             JOIN RESERVATION ON TRIP.TRIP_ID = RESERVATION.TRIP_ID
             JOIN PERSON ON RESERVATION.PERSON_ID = PERSON.PERSON_ID
    WHERE TRIP.TRIP_ID = id
      AND RESERVATION.STATUS <> 'C';

    RETURN result;
END;
/

create FUNCTION PERSON_RESERVATIONS(id PERSON.PERSON_ID%TYPE)
    RETURN PERSON_TRIP_TABLE
AS
    result      PERSON_TRIP_TABLE;
    -- 1-exists, 0-not exists
    trip_exists INT;
BEGIN
    SELECT COUNT(*) INTO trip_exists FROM PERSON WHERE PERSON.PERSON_ID = PERSON_RESERVATIONS.id;
    IF trip_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20000, 'Person with chosen ID not found');
    END IF;

    SELECT PERSON_TRIP_OBJ(TRIP_NAME, COUNTRY_ID, TRIP_DATE, FIRSTNAME, LASTNAME, STATUS) BULK COLLECT
    INTO result
    FROM TRIP
             JOIN RESERVATION ON TRIP.TRIP_ID = RESERVATION.TRIP_ID
             JOIN PERSON ON RESERVATION.PERSON_ID = PERSON.PERSON_ID
    WHERE PERSON.PERSON_ID = id
      AND RESERVATION.STATUS <> 'C';

    RETURN result;
END;
/

create PROCEDURE
    ADD_RESERVATION(trip_id TRIP.TRIP_ID%TYPE, person_id PERSON.PERSON_ID%TYPE)
AS
    person_exists      INT;
    trip_available     INT;
    reservation_exists INT;
    new_reservation_id INT;
BEGIN
    -- check if person exists; if it does, should return count > 0
    SELECT COUNT(*) INTO person_exists FROM PERSON WHERE PERSON.PERSON_ID = ADD_RESERVATION.person_id;

    IF person_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Person with chosen ID not found.');
    END IF;

    -- check if trip exists and is available (is in future and has free places), should return count > 0
    SELECT COUNT(*)
    INTO trip_available
    FROM AVAILABLE_TRIPS_VIEW
    WHERE AVAILABLE_TRIPS_VIEW.TRIP_ID = ADD_RESERVATION.trip_id;

    IF trip_available = 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'Trip with chosen ID not available.');
    END IF;

    -- checks if reservation exists; should return count = 0
    SELECT COUNT(*)
    INTO reservation_exists
    FROM RESERVATION
    WHERE RESERVATION.TRIP_ID = ADD_RESERVATION.trip_id
      AND RESERVATION.PERSON_ID = ADD_RESERVATION.person_id;

    IF reservation_exists > 0 THEN
        RAISE_APPLICATION_ERROR(-20004, 'Reservation for chosen trip ID and person ID already exists.');
    END IF;

    -- save new automatically generated NR_REZERWACJI (it's generated as indentity) in
    -- new_reservation_ID for logging
    INSERT INTO RESERVATION (TRIP_ID, PERSON_ID, STATUS)
    VALUES (ADD_RESERVATION.trip_id, ADD_RESERVATION.person_id, 'N')
    RETURNING RESERVATION_ID INTO new_reservation_ID;

    INSERT INTO LOG (RESERVATION_ID, LOG_DATE, STATUS)
    VALUES (new_reservation_id, CURRENT_DATE, 'N');

    -- INSERT is DML and does not automatically commit, and procedures don't automatically commit either
    COMMIT;
END;
/

create PROCEDURE
    MODIFY_RESERVATION_STATUS(id_reservation RESERVATION.RESERVATION_ID%TYPE,
                              status RESERVATION.STATUS%TYPE)
AS
    old_status  RESERVATION.STATUS%TYPE;
    trip_exists INT;
BEGIN
    SELECT COUNT(*)
    INTO trip_exists
    FROM FUTURE_TRIPS_VIEW ft
             JOIN RESERVATION r ON ft.TRIP_ID = r.TRIP_ID
    WHERE r.RESERVATION_ID = MODIFY_RESERVATION_STATUS.id_reservation;

    IF trip_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20005, 'Trip with chosen  ID not found');
    end if;

    SELECT STATUS
    INTO old_status
    FROM RESERVATION r
    WHERE r.RESERVATION_ID = MODIFY_RESERVATION_STATUS.id_reservation;

    CASE
        WHEN old_status IS NULL
            THEN RAISE_APPLICATION_ERROR(-20005, 'Reservation with chosen ID not found');
        WHEN old_status = 'C'
            THEN RAISE_APPLICATION_ERROR(-20006, 'Status of cancelled reservation cannot be changed');
        WHEN old_status = 'P'
            THEN IF (MODIFY_RESERVATION_STATUS.status <> 'C')
            THEN
                RAISE_APPLICATION_ERROR(-20006, 'Status of confirmed reservation can be changed only to cancelled');
            END IF;
        ELSE
            RAISE_APPLICATION_ERROR(-20999, 'Internal application error');
        END CASE;

    UPDATE RESERVATION
    SET STATUS = MODIFY_RESERVATION_STATUS.status
    WHERE RESERVATION_ID = MODIFY_RESERVATION_STATUS.id_reservation;

    INSERT INTO LOG (RESERVATION_ID, LOG_DATE, STATUS)
    VALUES (MODIFY_RESERVATION_STATUS.id_reservation,
            CURRENT_DATE,
            MODIFY_RESERVATION_STATUS.status);
    COMMIT;
end;
/

create PROCEDURE
    MODIFY_NO_PLACES(trip_id TRIP.TRIP_ID%TYPE,
                     new_no_places TRIP.MAX_NO_PLACES%TYPE)
AS
    trip_exists     INT;
    reserved_places INT;
BEGIN
    SELECT COUNT(*)
    INTO trip_exists
    FROM TRIP t
    WHERE t.TRIP_ID = MODIFY_NO_PLACES.trip_id;

    IF trip_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20005, 'Trip with chosen  ID not found');
    end if;

    SELECT tnp.MAX_NO_PLACES - tnp.NO_AVAILABLE_PLACES
    INTO reserved_places
    FROM TRIPS_NO_PLACES_VIEW tnp
    WHERE tnp.TRIP_ID = MODIFY_NO_PLACES.trip_id;

    IF new_no_places < 0 OR reserved_places > new_no_places
    THEN
        RAISE_APPLICATION_ERROR(-20007, 'Too low number of free places');
    end if;

    UPDATE TRIP
    SET MAX_NO_PLACES = MODIFY_NO_PLACES.new_no_places
    WHERE TRIP_ID = MODIFY_NO_PLACES.trip_id;

    COMMIT;
end;
/

create PROCEDURE
    ADD_RESERVATION_2(trip_id TRIP.TRIP_ID%TYPE, person_id PERSON.PERSON_ID%TYPE)
AS
    person_exists      INT;
    trip_available     INT;
    reservation_exists INT;
    new_reservation_id INT;
BEGIN
    -- check if person exists; if it does, should return count > 0
    SELECT COUNT(*) INTO person_exists FROM PERSON WHERE PERSON.PERSON_ID = ADD_RESERVATION_2.person_id;

    IF person_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Person with chosen ID not found.');
    END IF;

    -- check if trip exists and is available (is in future and has free places), should return count > 0
    SELECT COUNT(*)
    INTO trip_available
    FROM AVAILABLE_TRIPS_VIEW
    WHERE AVAILABLE_TRIPS_VIEW.TRIP_ID = ADD_RESERVATION_2.trip_id;

    IF trip_available = 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'Trip with chosen ID not available.');
    END IF;

    -- checks if reservation exists; should return count = 0
    SELECT COUNT(*)
    INTO reservation_exists
    FROM RESERVATION
    WHERE RESERVATION.TRIP_ID = ADD_RESERVATION_2.trip_id
      AND RESERVATION.PERSON_ID = ADD_RESERVATION_2.person_id;

    IF reservation_exists > 0 THEN
        RAISE_APPLICATION_ERROR(-20004, 'Reservation for chosen trip ID and person ID already exists.');
    END IF;

    -- save new automatically generated NR_REZERWACJI (it's generated as indentity) in
    -- new_reservation_ID for logging
    INSERT INTO RESERVATION (TRIP_ID, PERSON_ID, STATUS)
    VALUES (ADD_RESERVATION_2.trip_id, ADD_RESERVATION_2.person_id, 'N')
    RETURNING RESERVATION_ID INTO new_reservation_ID;

    -- INSERT is DML and does not automatically commit, and procedures don't automatically commit either
    COMMIT;
END;
/

create PROCEDURE
    MODIFY_RESERVATION_STATUS_2(id_reservation RESERVATION.RESERVATION_ID%TYPE,
                                status RESERVATION.STATUS%TYPE)
AS
    old_status   RESERVATION.STATUS%TYPE;
    trip_exists  INT;
    t_noa_places INT;
    trip_id      INT;
BEGIN
    SELECT COUNT(*)
    INTO trip_exists
    FROM FUTURE_TRIPS_VIEW ft
             JOIN RESERVATION r ON ft.TRIP_ID = r.TRIP_ID
    WHERE r.RESERVATION_ID = MODIFY_RESERVATION_STATUS_2.id_reservation;

    IF trip_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20005, 'Trip with chosen  ID not found');
    end if;

    SELECT STATUS
    INTO old_status
    FROM RESERVATION r
    WHERE r.RESERVATION_ID = MODIFY_RESERVATION_STATUS_2.id_reservation;

    CASE
        WHEN old_status IS NULL
            THEN RAISE_APPLICATION_ERROR(-20005, 'Reservation with chosen ID not found');
        WHEN old_status = 'C'
            THEN RAISE_APPLICATION_ERROR(-20006, 'Status of cancelled reservation cannot be changed');
        WHEN old_status = 'P'
            THEN IF (MODIFY_RESERVATION_STATUS_2.status <> 'C')
            THEN
                RAISE_APPLICATION_ERROR(-20006, 'Status of confirmed reservation can be changed only to cancelled');
            END IF;
        ELSE
            RAISE_APPLICATION_ERROR(-20999, 'Internal application error');
        END CASE;

    SELECT TRIP_ID
    INTO trip_id
    FROM RESERVATION
    WHERE RESERVATION_ID = MODIFY_RESERVATION_STATUS_2.id_reservation;

    SELECT NO_AVAILABLE_PLACES
    INTO t_noa_places
    FROM TRIP
    WHERE TRIP.TRIP_ID = trip_id;
    IF t_noa_places < 1 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Not enought places');
    end if;

    UPDATE RESERVATION
    SET STATUS = MODIFY_RESERVATION_STATUS_2.status
    WHERE RESERVATION_ID = MODIFY_RESERVATION_STATUS_2.id_reservation;

    COMMIT;
end;
/

create PROCEDURE RECALCULATE
AS
BEGIN
    UPDATE TRIP t
    SET NO_AVAILABLE_PLACES =
                MAX_NO_PLACES - (SELECT COUNT(*)
                                 FROM RESERVATION r
                                 WHERE r.TRIP_ID = t.TRIP_ID
                                   AND r.STATUS <> 'C');
end;
/

create PROCEDURE
    ADD_RESERVATION_4(trip_id TRIP.TRIP_ID%TYPE, person_id PERSON.PERSON_ID%TYPE)
AS
    person_exists      INT;
    trip_available     INT;
    reservation_exists INT;
    new_reservation_id INT;
BEGIN
    -- check if person exists; if it does, should return count > 0
    SELECT COUNT(*) INTO person_exists FROM PERSON WHERE PERSON.PERSON_ID = ADD_RESERVATION_4.person_id;

    IF person_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Person with chosen ID not found.');
    END IF;

    -- check if trip exists and is available (is in future and has free places), should return count > 0
    SELECT COUNT(*)
    INTO trip_available
    FROM AVAILABLE_TRIPS_VIEW
    WHERE AVAILABLE_TRIPS_VIEW.TRIP_ID = ADD_RESERVATION_4.trip_id;

    IF trip_available = 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'Trip with chosen ID not available.');
    END IF;

    -- checks if reservation exists; should return count = 0
    SELECT COUNT(*)
    INTO reservation_exists
    FROM RESERVATION
    WHERE RESERVATION.TRIP_ID = ADD_RESERVATION_4.trip_id
      AND RESERVATION.PERSON_ID = ADD_RESERVATION_4.person_id;

    IF reservation_exists > 0 THEN
        RAISE_APPLICATION_ERROR(-20004, 'Reservation for chosen trip ID and person ID already exists.');
    END IF;

    -- save new automatically generated NR_REZERWACJI (it's generated as indentity) in
    -- new_reservation_ID for logging
    INSERT INTO RESERVATION (TRIP_ID, PERSON_ID, STATUS)
    VALUES (ADD_RESERVATION_4.trip_id, ADD_RESERVATION_4.person_id, 'N')
    RETURNING RESERVATION_ID INTO new_reservation_ID;

    UPDATE TRIP
    SET NO_AVAILABLE_PLACES = NO_AVAILABLE_PLACES - 1
    WHERE TRIP_ID = ADD_RESERVATION_4.trip_id;

    -- INSERT is DML and does not automatically commit, and procedures don't automatically commit either
    COMMIT;
END;
/

create FUNCTION AVAILABLE_TRIPS_4(country TRIP.COUNTRY_ID%TYPE,
                                  date_from DATE, date_to DATE)
    RETURN TRIPS_TABLE
AS
    result TRIPS_TABLE;
BEGIN
    IF date_from > date_to THEN
        RAISE_APPLICATION_ERROR(-20001, 'Date_from must by <= date_to');
    end if;

    SELECT TRIP_OBJ(TRIP_ID, TRIP_NAME, COUNTRY_ID, TRIP_DATE, MAX_NO_PLACES) BULK COLLECT
    INTO result
    FROM TRIP
    WHERE TRIP.COUNTRY_ID = AVAILABLE_TRIPS_4.country
      AND TRIP.TRIP_DATE >= AVAILABLE_TRIPS_4.date_from
      AND TRIP.TRIP_DATE <= AVAILABLE_TRIPS_4.date_to
      AND TRIP.NO_AVAILABLE_PLACES > 0;
    RETURN result;
END;
/

create PROCEDURE
    MODIFY_RESERVATION_STATUS_4(id_reservation RESERVATION.RESERVATION_ID%TYPE,
                                status RESERVATION.STATUS%TYPE)
AS
    old_status  RESERVATION.STATUS%TYPE;
    trip_exists INT;
    new_places  INT;
BEGIN
    SELECT COUNT(*)
    INTO trip_exists
    FROM FUTURE_TRIPS_VIEW ft
             JOIN RESERVATION r ON ft.TRIP_ID = r.TRIP_ID
    WHERE r.RESERVATION_ID = MODIFY_RESERVATION_STATUS_4.id_reservation;

    IF trip_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20005, 'Trip with chosen  ID not found');
    end if;

    SELECT STATUS
    INTO old_status
    FROM RESERVATION r
    WHERE r.RESERVATION_ID = MODIFY_RESERVATION_STATUS_4.id_reservation;

    CASE
        WHEN old_status IS NULL
            THEN RAISE_APPLICATION_ERROR(-20005, 'Reservation with chosen ID not found');
        WHEN old_status = 'C'
            THEN RAISE_APPLICATION_ERROR(-20006, 'Status of cancelled reservation cannot be changed');
        WHEN old_status = 'P'
            THEN IF (MODIFY_RESERVATION_STATUS_4.status <> 'C')
            THEN
                RAISE_APPLICATION_ERROR(-20006, 'Status of confirmed reservation can be changed only to cancelled');
            END IF;
        ELSE
            RAISE_APPLICATION_ERROR(-20999, 'Internal application error');
        END CASE;

    UPDATE RESERVATION
    SET STATUS = MODIFY_RESERVATION_STATUS_4.status
    WHERE RESERVATION_ID = MODIFY_RESERVATION_STATUS_4.id_reservation;

    IF status = 'C' THEN
        new_places := 1;
    ELSE
        new_places := 0;
    end if;

    UPDATE TRIP t
    SET NO_AVAILABLE_PLACES = NO_AVAILABLE_PLACES + new_places
    WHERE t.TRIP_ID = (SELECT TRIP_ID
                       FROM RESERVATION r
                       WHERE r.RESERVATION_ID = MODIFY_RESERVATION_STATUS_4.id_reservation);

    COMMIT;
end;
/

create PROCEDURE
    MODIFY_NO_PLACES_4(trip_id TRIP.TRIP_ID%TYPE,
                       new_no_places TRIP.MAX_NO_PLACES%TYPE)
AS
    trip_exists     INT;
    reserved_places INT;
BEGIN
    SELECT COUNT(*)
    INTO trip_exists
    FROM TRIP t
    WHERE t.TRIP_ID = MODIFY_NO_PLACES_4.trip_id;

    IF trip_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20005, 'Trip with chosen  ID not found');
    end if;

    SELECT MAX_NO_PLACES - NO_AVAILABLE_PLACES
    INTO reserved_places
    FROM TRIP
    WHERE TRIP.TRIP_ID = MODIFY_NO_PLACES_4.trip_id;

    IF new_no_places < 0 OR reserved_places > new_no_places
    THEN
        RAISE_APPLICATION_ERROR(-20007, 'Too low number of free places');
    end if;

    UPDATE TRIP
    SET MAX_NO_PLACES       = MODIFY_NO_PLACES_4.new_no_places,
        NO_AVAILABLE_PLACES = NO_AVAILABLE_PLACES + (new_no_places - TRIP.MAX_NO_PLACES)
    WHERE TRIP_ID = MODIFY_NO_PLACES_4.trip_id;

    COMMIT;
end;
/

create PROCEDURE
    ADD_RESERVATION_5(trip_id TRIP.TRIP_ID%TYPE, person_id PERSON.PERSON_ID%TYPE)
AS
    person_exists      INT;
    trip_available     INT;
    reservation_exists INT;
    new_reservation_id INT;
BEGIN
    -- check if person exists; if it does, should return count > 0
    SELECT COUNT(*) INTO person_exists FROM PERSON WHERE PERSON.PERSON_ID = ADD_RESERVATION_5.person_id;

    IF person_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Person with chosen ID not found.');
    END IF;

    -- check if trip exists and is available (is in future and has free places), should return count > 0
    SELECT COUNT(*)
    INTO trip_available
    FROM AVAILABLE_TRIPS_VIEW
    WHERE AVAILABLE_TRIPS_VIEW.TRIP_ID = ADD_RESERVATION_5.trip_id;

    IF trip_available = 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'Trip with chosen ID not available.');
    END IF;

    -- checks if reservation exists; should return count = 0
    SELECT COUNT(*)
    INTO reservation_exists
    FROM RESERVATION
    WHERE RESERVATION.TRIP_ID = ADD_RESERVATION_5.trip_id
      AND RESERVATION.PERSON_ID = ADD_RESERVATION_5.person_id;

    IF reservation_exists > 0 THEN
        RAISE_APPLICATION_ERROR(-20004, 'Reservation for chosen trip ID and person ID already exists.');
    END IF;

    -- save new automatically generated NR_REZERWACJI (it's generated as indentity) in
    -- new_reservation_ID for logging
    INSERT INTO RESERVATION (TRIP_ID, PERSON_ID, STATUS)
    VALUES (ADD_RESERVATION_5.trip_id, ADD_RESERVATION_5.person_id, 'N')
    RETURNING RESERVATION_ID INTO new_reservation_ID;

    -- INSERT is DML and does not automatically commit, and procedures don't automatically commit either
    COMMIT;
END;
/

create PROCEDURE
    MODIFY_RESERVATION_STATUS_5(id_reservation RESERVATION.RESERVATION_ID%TYPE,
                                status RESERVATION.STATUS%TYPE)
AS
    old_status  RESERVATION.STATUS%TYPE;
    trip_exists INT;
    new_places  INT;
BEGIN
    SELECT COUNT(*)
    INTO trip_exists
    FROM FUTURE_TRIPS_VIEW ft
             JOIN RESERVATION r ON ft.TRIP_ID = r.TRIP_ID
    WHERE r.RESERVATION_ID = MODIFY_RESERVATION_STATUS_5.id_reservation;

    IF trip_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20005, 'Trip with chosen  ID not found');
    end if;

    SELECT STATUS
    INTO old_status
    FROM RESERVATION r
    WHERE r.RESERVATION_ID = MODIFY_RESERVATION_STATUS_5.id_reservation;

    CASE
        WHEN old_status IS NULL
            THEN RAISE_APPLICATION_ERROR(-20005, 'Reservation with chosen ID not found');
        WHEN old_status = 'C'
            THEN RAISE_APPLICATION_ERROR(-20006, 'Status of cancelled reservation cannot be changed');
        WHEN old_status = 'P'
            THEN IF (MODIFY_RESERVATION_STATUS_5.status <> 'C')
            THEN
                RAISE_APPLICATION_ERROR(-20006, 'Status of confirmed reservation can be changed only to cancelled');
            END IF;
        ELSE
            RAISE_APPLICATION_ERROR(-20999, 'Internal application error');
        END CASE;

    UPDATE RESERVATION
    SET STATUS = MODIFY_RESERVATION_STATUS_5.status
    WHERE RESERVATION_ID = MODIFY_RESERVATION_STATUS_5.id_reservation;

    COMMIT;
end;
/

create PROCEDURE
    MODIFY_NO_PLACES_5(trip_id TRIP.TRIP_ID%TYPE,
                       new_no_places TRIP.MAX_NO_PLACES%TYPE)
AS
    trip_exists     INT;
    reserved_places INT;
BEGIN
    SELECT COUNT(*)
    INTO trip_exists
    FROM TRIP t
    WHERE t.TRIP_ID = MODIFY_NO_PLACES_5.trip_id;

    IF trip_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20005, 'Trip with chosen  ID not found');
    end if;

    SELECT MAX_NO_PLACES - NO_AVAILABLE_PLACES
    INTO reserved_places
    FROM TRIP
    WHERE TRIP.TRIP_ID = MODIFY_NO_PLACES_5.trip_id;

    IF new_no_places < 0 OR reserved_places > new_no_places
    THEN
        RAISE_APPLICATION_ERROR(-20007, 'Too low number of free places');
    end if;

    UPDATE TRIP
    SET MAX_NO_PLACES = MODIFY_NO_PLACES_5.new_no_places
    WHERE TRIP_ID = MODIFY_NO_PLACES_5.trip_id;

    COMMIT;
end;
/

create PROCEDURE
    ADD_RESERVATION_3(trip_id TRIP.TRIP_ID%TYPE, person_id PERSON.PERSON_ID%TYPE)
AS
    person_exists      INT;
    reservation_exists INT;
    new_reservation_id INT;
BEGIN
    -- check if person exists; if it does, should return count > 0
    SELECT COUNT(*) INTO person_exists FROM PERSON WHERE PERSON.PERSON_ID = ADD_RESERVATION_3.person_id;

    IF person_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Person with chosen ID not found.');
    END IF;

    -- checks if reservation exists; should return count = 0
    SELECT COUNT(*)
    INTO reservation_exists
    FROM RESERVATION
    WHERE RESERVATION.TRIP_ID = ADD_RESERVATION_3.trip_id
      AND RESERVATION.PERSON_ID = ADD_RESERVATION_3.person_id;

    IF reservation_exists > 0 THEN
        RAISE_APPLICATION_ERROR(-20004, 'Reservation for chosen trip ID and person ID already exists.');
    END IF;

    -- save new automatically generated NR_REZERWACJI (it's generated as indentity) in
    -- new_reservation_ID for logging
    INSERT INTO RESERVATION (TRIP_ID, PERSON_ID, STATUS)
    VALUES (ADD_RESERVATION_3.trip_id, ADD_RESERVATION_3.person_id, 'N')
    RETURNING RESERVATION_ID INTO new_reservation_ID;

    INSERT INTO LOG (RESERVATION_ID, LOG_DATE, STATUS)
    VALUES (new_reservation_id, CURRENT_DATE, 'N');

    -- INSERT is DML and does not automatically commit, and procedures don't automatically commit either
    COMMIT;
END;
/

create PROCEDURE
    MODIFY_RESERVATION_STATUS_3(id_reservation RESERVATION.RESERVATION_ID%TYPE,
                                status RESERVATION.STATUS%TYPE)
AS
    old_status  RESERVATION.STATUS%TYPE;
    trip_exists INT;
BEGIN
    SELECT COUNT(*)
    INTO trip_exists
    FROM FUTURE_TRIPS_VIEW ft
             JOIN RESERVATION r ON ft.TRIP_ID = r.TRIP_ID
    WHERE r.RESERVATION_ID = MODIFY_RESERVATION_STATUS_3.id_reservation;

    IF trip_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20005, 'Trip with chosen  ID not found');
    end if;

    SELECT STATUS
    INTO old_status
    FROM RESERVATION r
    WHERE r.RESERVATION_ID = MODIFY_RESERVATION_STATUS_3.id_reservation;

    CASE
        WHEN old_status IS NULL
            THEN RAISE_APPLICATION_ERROR(-20005, 'Reservation with chosen ID not found');
        WHEN old_status = 'C'
            THEN RAISE_APPLICATION_ERROR(-20006, 'Status of cancelled reservation cannot be changed');
        WHEN old_status = 'P'
            THEN IF (MODIFY_RESERVATION_STATUS_3.status <> 'C')
            THEN
                RAISE_APPLICATION_ERROR(-20006, 'Status of confirmed reservation can be changed only to cancelled');
            END IF;
        ELSE
            RAISE_APPLICATION_ERROR(-20999, 'Internal application error');
        END CASE;

    UPDATE RESERVATION
    SET STATUS = MODIFY_RESERVATION_STATUS_3.status
    WHERE RESERVATION_ID = MODIFY_RESERVATION_STATUS_3.id_reservation;

    COMMIT;
end;
/


