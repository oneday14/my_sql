--[ 아래 수행 후 실습 - system 계정에서 수행 ]
create user kic identified by oracle;
grant create session to kic;

select *
  from dba_users
 where username='KIC';
 
--1. 다음을 차례대로 수행
--1) menu_t1 테이블 생성(no, name, price)
create table menu_t1(
no    number(4),
name  varchar2(20),
price number);

--2) jumun_t1 테이블 생성(no, product_no, qty, jdate)
create table jumun_t1(
no          number(4),
product_no  number(4),
qty         number,
jdate       date);

--3) jumun_t1 테이블의 product_no가 menu_t1 테이블의
--   no를 참조하도록 설정
alter table menu_t1 add constraint menu_no_pk
      primary key(no);
      
alter table jumun_t1 add constraint jumun_pno_fk
      foreign key(product_no) references menu_t1(no);
      
--4) kic 유저에게 두 테이블을 조회할 권한 부여
grant select on scott.menu_t1 to kic;
grant insert on scott.menu_t1 to kic;
grant select on scott.jumun_t1 to kic;
grant select, insert, delete, update 
      on scott.jumun_t1 to kic;

--5) kic 유저가 테이블명만으로 조회하도록 시노님 생성
create public synonym jumun_t1 for scott.jumun_t1;
create public synonym menu_t1 for scott.menu_t1;

--6) 1000번부터 시작해서 9999의 값을 갖는 시퀀스를 생성,
--   menu_t1에 데이터 입력
create sequence seq_menu
start with 1000
increment by 1
maxvalue 9999;

insert into menu_t1 values(seq_menu.nextval, 'tv',150);
select * from menu_t1;
commit;

--7) 1번 부터 시작해서 100의 값을 갖는 시퀀스 생성,
--   jumun_t1에 데이터 입력
create sequence seq_jumun
start with 100
increment by 1
;

insert into jumun_t1 values(seq_jumun.nextval, 
                            1001,
                            2,
                            '2020/06/06');

alter session set nls_date_format='MM/DD/YYYY';
insert into jumun_t1 values(seq_jumun.nextval, 
                            1001,
                            3,
                            to_date('2020/06/07',
                                    'YYYY/MM/DD'));
commit;                                    
select * from jumun_t1;                                    
--8) 두 테이블 조인하여 주문일자, 상품명, 주문수량, 
--   상품가격을 동시 출력하는 뷰 생성

create view jumun_menu
as
select j.JDATE, m.NAME, j.QTY, m.PRICE
  from menu_t1 m, jumun_t1 j
 where m.NO = j.PRODUCT_NO;
 
--2. 다음을 수행하여라.
drop table emp_test1;
create table emp_test1 as select * from emp;
insert into emp_test1 
select * from emp where deptno = 10;
commit;

--emp_test1 테이블의 empno에 pk를 생성,
--중복된 행을 찾아 제거 후 생성
alter table emp_test1 add constraint emp_test_empno_pk
      primary key(empno);
      
select empno, count(empno), max(ROWID)
  from emp_test1
 group by empno
having count(empno) >= 2;      

select rowid, e.* 
  from emp_test1 e
 order by deptno, empno;

delete from emp_test1
 where ROWID in (select max(ROWID)
                   from emp_test1
                  group by empno
                 having count(empno) >= 2);  
commit;

select * from emp_test1;
