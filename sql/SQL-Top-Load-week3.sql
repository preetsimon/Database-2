/* 
Version Jan 25, 2023

The course materials are only for the use of students enrolled in the course CSIS 3300 at Douglas College. 
Sharing this material to a third-party website can lead to a violation of Copyright law.
*/

use master;

drop database if exists TestDB;
go

create database TestDB;
go

use TestDB;

create table employee (
	name varchar(20) not null,
	department varchar(20),
	salary numeric(8,2),
	primary key (name)
);

insert into employee values ('Srinivasan', 'admin', 90000);
insert into employee values ('Wu', 'admin', 90000);
insert into employee values ('Mozart', 'sales', 90000);
insert into employee values ('Einstein', 'engineering', 80000);
insert into employee values ('El Said', 'engineering', 80000);
insert into employee values ('Gold', 'sales', 80000);
insert into employee values ('Katz', 'admin', 70000);
insert into employee values ('Califieri', 'sales', 70000);
insert into employee values ('Singh', 'sales', 70000);
insert into employee values ('Crick', 'engineering', 60000);
insert into employee values ('Brandt', 'admin', 60000);
insert into employee values ('Kim', 'sales', 60000);