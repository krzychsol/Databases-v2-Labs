-- drop table log;
-- drop table reservation;
-- drop table person;
-- drop table trip;

-- trip

insert into trip(trip_name, COUNTRY_ID, trip_date, max_no_places)
values ('Wycieczka do Paryza', 2, to_date('2022-09-12','YYYY-MM-DD'), 3);

insert into trip(trip_name, COUNTRY_ID, trip_date,  max_no_places)
values ('Piękny Kraków', 1, to_date('2023-07-03','YYYY-MM-DD'), 2);

insert into trip(trip_name, country_id, trip_date,  max_no_places)
values ('Znów do Francji', 2, to_date('2023-05-01','YYYY-MM-DD'), 2);

insert into trip(trip_name, country_id, trip_date,  max_no_places)
values ('Hel', 1, to_date('2023-05-01','YYYY-MM-DD'), 2);

-- person

insert into person(firstname, lastname)
values ('Jan', 'Nowak');

insert into person(firstname, lastname)
values ('Jan', 'Kowalski');

insert into person(firstname, lastname)
values ('Jan', 'Nowakowski');

insert into person(firstname, lastname)
values ('Adam', 'Kowalski');

insert into person(firstname, lastname)
values  ('Novak', 'Nowak');

insert into person(firstname, lastname)
values ('Maciej', 'Wysoki');

insert into person(firstname, lastname)
values ('Wojciech', 'Niski');

insert into person(firstname, lastname)
values ('Sebastian', 'Chudy');

insert into person(firstname, lastname)
values ('Albert', 'Gruby');

insert into person(firstname, lastname)
values ('Czesław', 'Wielki');

-- reservation
-- trip 1
insert into reservation(trip_id, person_id, status)
values (6, 1, 'P');

-- trip 2
insert into reservation(trip_id, person_id, status)
values (7, 1, 'P');

-- trip 3
insert into reservation(trip_id, person_id, status)
values (8, 5, 'P');

-- trip 4
insert into reservation(trip_id, person_id, status)
values (8, 1, 'N');

-- trip 5
insert into reservation(trip_id, person_id, status)
values (6, 7, 'N');

-- trip 6
insert into reservation(trip_id, person_id, status)
values (7, 8, 'P');

-- trip 7
insert into reservation(trip_id, person_id, status)
values (8, 9, 'P');

-- trip 8
insert into reservation(trip_id, person_id, status)
values (9, 4, 'P');

-- trip 9
insert into reservation(trip_id, person_id, status)
values (6, 2, 'N');

-- trip 10
insert into reservation(trip_id, person_id, status)
values (7, 4, 'C');

-- country
INSERT INTO COUNTRY(COUNTRY_NAME)
values ('Polska');

INSERT INTO COUNTRY(COUNTRY_NAME)
values ('Francja');

INSERT INTO COUNTRY(COUNTRY_NAME)
values ('Hiszpania');

INSERT INTO COUNTRY(COUNTRY_NAME)
values ('Niemcy');

INSERT INTO COUNTRY(COUNTRY_NAME)
values ('Portugalia');

INSERT INTO COUNTRY(COUNTRY_NAME)
values ('Szwecja');

SELECT * FROM RESERVATION

--country,trip_date,trip_name, firstname, lastname,reservation_id,status
SELECT COUNTRY_NAME,TRIP_DATE,FIRSTNAME, LASTNAME, RESERVATION_ID, STATUS
FROM RESERVATION
JOIN PERSON P on RESERVATION.PERSON_ID = P.PERSON_ID
join TRIP T on T.TRIP_ID = RESERVATION.TRIP_ID
join COUNTRY C2 on T.COUNTRY_ID = C2.COUNTRY_ID


create table person
(
  person_id int generated always as identity not null,
  firstname varchar(50),
  lastname varchar(50),
  constraint person_pk primary key ( person_id ) enable
);

create table trip
(
  trip_id int generated always as identity not null,
  trip_name varchar(100),
  country varchar(50),
  trip_date date,
  max_no_places int,
  constraint trip_pk primary key ( trip_id ) enable
);

create table reservation
(
  reservation_id int generated always as identity not null,
  trip_id int,
  person_id int,
  status char(1),
  constraint reservation_pk primary key ( reservation_id ) enable
);


alter table reservation
add constraint reservation_fk1 foreign key
( person_id ) references person ( person_id ) enable;

alter table reservation
add constraint reservation_fk2 foreign key
( trip_id ) references trip ( trip_id ) enable;

alter table reservation
add constraint reservation_chk1 check
(status in ('N','P','C')) enable;


create table log
(
	log_id int  generated always as identity not null,
	reservation_id int not null,
	log_date date  not null,
	status char(1),
	constraint log_pk primary key ( log_id ) enable
);

alter table log
add constraint log_chk1 check
(status in ('N','P','C')) enable;

alter table log
add constraint log_fk1 foreign key
( reservation_id ) references reservation ( reservation_id ) enable;