--drop table HOTEL;
--drop table PARTICIPATE;
--drop table STAY;
--drop table ACTIVITY;
--drop table TOURIST;

--DDL--

create table hotel
(
hcode varchar2(2) not null,
name varchar2(50),
city varchar2(50),
country varchar(50),
constraint hcode_pk primary key(hcode),
constraint ck_city check (city in ('Athens','Paris','London','New York'))
);

create table tourist
(
tcode varchar2(2) not null,
name varchar2(50),
country varchar(50),
age number,
gender varchar2(6),
constraint tcode_pk primary key(tcode),
constraint ck_gender check (gender in ('male','female','trans'))
);

create table activity
(
acode varchar2(2) not null,
aname varchar2(50),
duration_in_minutes number,
constraint acode_pk primary key(acode)
);

create table stay
(
hcode varchar2(2) not null,
tcode varchar2(2) not null,
year number not null,
days number,
cost number,
constraint stay_pk primary key(hcode, tcode, year) ENABLE,
constraint hcode_fk1 foreign key (hcode) references hotel (hcode)on delete cascade,
constraint tcode_fk2 foreign key (tcode) references tourist (tcode)on delete cascade,
constraint ck_year check (year > 2000 and year < 2010)
);

create table participate
(
tcode varchar2(2) not null,
acode varchar2(2) not null,
year number not null,
cost number,
constraint participate_pk PRIMARY KEY(tcode, acode, year),
constraint tcode_fk1 foreign key (tcode) references tourist (tcode)on delete cascade,
constraint acode_fk2 foreign key (acode) references activity (acode)on delete cascade
);


---DML---
insert into michail.hotel (hcode,name,city,country)
    values ('h1', 'Hilton', 'Athens', 'Greece');
insert into michail.hotel (hcode,name,city,country)
    values ('h2', 'Continental', 'Paris', 'France');
insert into michail.hotel (hcode,name,city,country)
    values ('h3', 'Regent', 'London', 'England');
insert into michail.hotel (hcode,name,city,country)
    values ('h4', 'Plaza', 'New York', 'USA');
    
insert into michail.tourist (tcode,name,country,age,gender)
    values ('t1', 'John', 'England', 50, 'male');
insert into michail.tourist (tcode,name,country,age,gender)
    values ('t2', 'Maria', 'France', 30, 'female');
insert into michail.tourist (tcode,name,country,age,gender)
    values ('t3', 'Kostas', 'Greece', 25, 'male');
insert into michail.tourist (tcode,name,country,age,gender)
    values ('t4', 'Joanna', 'USA', 45, 'female');
insert into michail.tourist (tcode,name,country,age,gender)
    values ('t5', 'Elli', 'Cyprus', 20, 'female');

insert into michail.stay (hcode,tcode,year,days,cost)
    values ('h1', 't1', 2001, 3, 300);
insert into michail.stay (hcode,tcode,year,days,cost)
    values ('h1', 't1', 2002, 4, 500);
insert into michail.stay (hcode,tcode,year,days,cost)
    values ('h1', 't2', 2001, 3, 300);
insert into michail.stay (hcode,tcode,year,days,cost)
    values ('h1', 't3', 2004, 5, 600);
insert into michail.stay (hcode,tcode,year,days,cost)
    values ('h1', 't4', 2005, 4, 600);
insert into michail.stay (hcode,tcode,year,days,cost)
    values ('h2', 't1', 2003, 5, 500);
insert into michail.stay (hcode,tcode,year,days,cost)
    values ('h2', 't2', 2005, 4, 400);
insert into michail.stay (hcode,tcode,year,days,cost)
    values ('h3', 't4', 2002, 3, 300);
insert into michail.stay (hcode,tcode,year,days,cost)
    values ('h4', 't4', 2003, 4, 400);
    
insert into michail.activity (acode,aname,duration_in_minutes)
    values ('a1', 'walking tour', 120);
insert into michail.activity (acode,aname,duration_in_minutes)
    values ('a2', 'museum', 150);
insert into michail.activity (acode,aname,duration_in_minutes)
    values ('a3', 'trip', 240);
    
insert into michail.participate (tcode,acode,year,cost)
    values ('t1', 'a1', 2001, 10);
insert into michail.participate (tcode,acode,year,cost)
    values ('t1', 'a2', 2001, 20);
insert into michail.participate (tcode,acode,year,cost)
    values ('t2', 'a3', 2001, 15);
insert into michail.participate (tcode,acode,year,cost)
    values ('t3', 'a1', 2004, 20);
insert into michail.participate (tcode,acode,year,cost)
    values ('t1', 'a3', 2003, 50);
insert into michail.participate (tcode,acode,year,cost)
    values ('t2', 'a2', 2005, 30);
    
    
    
----SQL QUERIES 1-7 BELOW----    
-----------1----------------    
select t.tcode, sum(s.cost) as total_cost, t.name
from tourist t join stay s
on t.tcode = s.tcode
group by t.name, t.tcode;

--------------2-------------
select tourist.name, participate.acode from tourist 
left outer join participate 
ON (tourist.tcode=participate.tcode)
WHERE participate.acode is NULL;
--------------3---------------
select a.acode, a.part_cost, a.aname
FROM (Select a.acode, SUM(p.cost) part_cost, a.aname
FROM activity a join participate p ON a.acode=p.acode group by a.acode, a.aname) a
where a.part_cost = (Select MAX(part_cost) part_cost from 
(Select a.acode, SUM(p.cost) part_cost
FROM activity a join participate p ON a.acode=p.acode group by a.acode) a);
-------------4--------------------
select a1.hotel_name, a1.person_name, a.aname, a1.year
from (select distinct h.name as hotel_name, t.name as person_name, p.acode, p.year
from hotel h join stay s
on h.hcode=s.hcode
join tourist t on t.tcode=s.tcode
join participate p on s.year=p.year and s.tcode=p.tcode) a1
join activity a on a.acode=a1.acode
where a1.hotel_name='Hilton' OR a.aname = 'trip' order by a1.person_name asc, a.aname desc;
-------------5---------------
SELECT DISTINCT h.country, COUNT(s.tcode) AS onDemand
FROM hotel h join stay s
on h.hcode=s.hcode
JOIN tourist t on t.tcode=s.tcode
GROUP BY h.country
ORDER BY count(s.tcode) DESC
fetch first 1 rows only;
------------6------------------
        -----1-----nulled value can handle easily on backend
select MAX(stay_cost)as dianomi, null "drastiriotita", name as stay from(select DISTINCT sum(s.cost) as stay_cost, t.name, p.cost
from stay s
JOIN tourist t
on t.tcode=s.tcode
JOIN participate p
on p.tcode=t.tcode
group by t.name, p.cost
HAVING
    SUM(s.cost) > 1000
    fetch first 1 rows only) group by name, 'drastiriotita'
UNION
select null "dianomi", MAX(cost) as drastiriotita, name from(select DISTINCT s.cost as stay_cost, t.name, sum(p.cost) as COST
from stay s
JOIN tourist t
on t.tcode=s.tcode
JOIN participate p
on p.tcode=t.tcode
group by t.name, s.cost
HAVING
    SUM(p.cost) <= 100
    fetch first 1 rows only) group by name, 'dianomi'; 
       ------2------- PREFERED WAY
select a1.tcode, a1.name,a1.total_sum, sum(p.cost) as total_cost
FROM (select t.tcode, t.name, sum(s.cost) as total_sum
from tourist t join stay s
on t.tcode=s.tcode
group by t.tcode, t.name) a1
JOIN participate p
on p.tcode=a1.tcode
group by a1.tcode, a1.name, a1.total_sum
having a1.total_sum >1000 and sum(p.cost) <= 100;
-------------7------------- 
select DISTINCT h.name, t.name
from hotel h join stay s
on h.hcode =s.hcode
join tourist t
on t.tcode=s.tcode
where t.name NOT IN (select DISTINCT t.name
from hotel h join stay s
on h.hcode =s.hcode
join tourist t
on t.tcode=s.tcode where h.name='Continental')AND h.name='Hilton' and NOT h.name='Continental';
