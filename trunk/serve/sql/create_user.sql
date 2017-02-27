CREATE TABLE USER(id int(6) not null primary key auto_increment,
uid int(6),
name char(20) not null,
sex int(4) not null default '0',
card int(4) not null default '3',
status int(4));


SHOW TABLES

-- select * from USER where 1-- 
show processlist; 