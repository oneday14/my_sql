-- 1) student2 테이블을 만들고 
-- 제1의 전공번호가 301인 학생들의 출생년도와 동일한 
-- 학생들을 삭제하여라.
create table student2 as select * from STUDENT;

select to_char(BIRTHDAY, 'YYYY'),
       to_char(BIRTHDAY, 'RRRR')
  from student2
 where deptno1 = 301;
 
select to_date('90/01/01','YY/MM/DD'),
       to_date('90/01/01','RR/MM/DD')
  from dual;
  
delete from STUDENT2
 where to_char(BIRTHDAY, 
               'YYYY') in (select to_char(BIRTHDAY,
                                         'YYYY')
                             from student2
                            where deptno1 = 301);
commit;    

-- 2) student3 테이블을 만들고 비만여부를 나타내는 컬럼을
-- 새로 추가하고, 각 학생들의 비만정보를 update 하여라.
-- 비만여부는 체중이 표준체중보다 크면 과체중, 
-- 작으면 저체중, 같으면 표준으로 분류하여라.
-- *표준체중 = (키-100)*0.9
create table student3 as select * from STUDENT;
alter table student3 add biman varchar2(10);

select WEIGHT, (HEIGHT-100)*0.9 AS 표준체중,
       case when WEIGHT > (HEIGHT-100)*0.9 then '과체중'
            when WEIGHT < (HEIGHT-100)*0.9 then '저체중'
                                           else '표준'
        end AS "비만여부"                                   
  from STUDENT3;

update STUDENT3 s1
   set biman = (select case when WEIGHT > (HEIGHT-100)*0.9 
                            then '과체중'
                            when WEIGHT < (HEIGHT-100)*0.9 
                            then '저체중'
                            else '표준'
                        end AS "비만여부"                                   
                  from STUDENT3 s2
                 where s1.STUDNO = s2.STUDNO);
rollback;

update STUDENT3 s1
   set biman = case when WEIGHT > (HEIGHT-100)*0.9 
                    then '과체중'
                    when WEIGHT < (HEIGHT-100)*0.9 
                    then '저체중'
                    else '표준'
                end;

commit;

-- 3) student3 테이블의 주민번호를 아래와 같이 변경.
-- (에러 발생 시 적절한 조치를 취한 후 수정)
-- 751023-1111111
select JUMIN, 
       substr(JUMIN,1,6)||'-'||substr(JUMIN,7),
       substr(JUMIN,1,6)||'-'||substr(JUMIN,7,7),
       length(substr(JUMIN,7))
  from STUDENT3;

alter table STUDENT3 modify jumin char(14);

update STUDENT3
   set jumin = substr(JUMIN,1,6)||'-'
               ||substr(JUMIN,7,7) ;

desc STUDENT3;  --JUMIN  CHAR(13)

commit;

-- 4) emp_back2 테이블을 만들고 각 직원의 연봉을 
-- 직원과 각 직원의 상위관리자의 연봉의 평균으로 수정.
-- 단, 상위관리자가 없는 경우는 본인의 연봉의 
-- 10% 상승된 값을 상위관리자 연봉으로 취급
create table emp_back2 as select * from emp;

select e1.ename, e1.sal, e2.sal,
       (e1.sal + e2.sal)/2,
       (e1.sal + nvl(e2.sal,e1.sal*1.1))/2
  from emp_back2 e1, emp_back2 e2
 where e1.mgr = e2.EMPNO(+);

select e1.ename, e1.sal, 
       nvl((select (e1.sal + e2.sal)/2
              from emp_back2 e2
              where e1.mgr = e2.EMPNO),
           (e1.sal + e1.sal*1.1)/2)
  from emp_back2 e1;

select e1.ename, e1.sal, 
       nvl((select e2.SAL
         from emp e2 
        where e1.mgr = e2.empno),5000)
  from emp e1;


update emp_back2 e1
   set sal = (select (e1.sal + 
                     nvl(e2.sal,e1.sal*1.1))/2
                from emp_back2 e2
               where e1.mgr = e2.EMPNO(+));

update emp_back2 e1
   set sal = nvl((select (e1.sal + e2.sal)/2
                    from emp_back2 e2
                   where e1.mgr = e2.EMPNO),
                 (e1.sal + e1.sal*1.1)/2);

commit;
select * from emp_back2;

---------- 여기까지는 복습입니다. ----------

-- 제약조건
-- foreign key(외래키) : 

자식테이블(emp)        부모테이블(dept) 
         deptno    ->  deptno 
     (foreign key)   (reference key)
insert, update 제약    delete 제약       
                       PK 또는 UK 제약 필요
;

1. 생성
1) 테이블 생성 시
create table 테이블명(
컬럼1  데이터타입 primary key,
컬럼2  데이터타입 references 부모테이블(컬럼3));

2) 이미 생성된 테이블에 추가
alter table 테이블명 add foreign key(컬럼1) 
                     references 부모테이블(컬럼2)); 

--예제) jumun테이블과 cafe_prod 테이블을 만들고 
--jumun 테이블의 product_no 컬럼이 cafe_prod 테이블의
--상품번호(no)를 참조하도록 테이블을 설계하여라
--cafe_prod : no, name, price
--jumun : jumun_no, qty, product_no
drop table cafe_prod;

create table cafe_prod(
no      number primary key,  -- reference key 전제조건
name    varchar2(10),
price   number);

create table jumun(
jumun_no    number,
qty         number,
product_no  number references cafe_prod(no));

--연습문제) emp로부터 emp_t1, dept로부터 dept_t1 생성,
--emp_t1(deptno)  ->  dept_t1(deptno) 의 관계가 되도록
--적절한 제약조건을 생성하세요
create table emp_t1 as select * from emp;
create table dept_t1 as select * from dept;

alter table dept_t1 add constraint deptt1_deptno_pk
      primary key(deptno);
      
alter table emp_t1 add constraint empt1_deptno_fk
      foreign key(deptno) references dept_t1(deptno);
      
-- foreign key <-> reference key 의 컬럼 삭제
-- reference key를 삭제하려면(컬럼삭제)
-- 1) foreign key 컬럼을 먼저 삭제 후 삭제
-- 2) cascade constraints 옵션을 사용한 삭제
alter table dept_t1 drop column deptno; -- 불가
alter table dept_t1 
      drop column deptno cascade constraints; -- 가능


-- 제약조건 조회 뷰
-- 1) user_constraints(제약조건 컬럼 정보 없음)
select constraint_name,  -- 제약조건 이름
       constraint_type,  -- c:(check/nn), p:pk, u:uk, r:fk
       search_condition, -- check or nn 여부
       table_name,       -- 테이블명
       r_constraint_name -- 참조 제약조건 이름
  from user_constraints
 where constraint_name = 'SYS_C0011049';

insert into dept2 values(1001,'abc',1000,'ab');
무결성 제약조건 SYS_C0011049에 위배됩니다
=> PK가 있다는 정보 확인, 어떤 컬럼인지는 알 수 없음
;

-- 2) user_cons_columns(제약조건 컬럼 정보 있음)
select *
  from user_cons_columns
 where CONSTRAINT_NAME = 'SYS_C0011049' ;

=> PK가 dcode 컬럼에 걸려있는지 알 수 있음
;

insert into dept2 values(2001,'abc',1000,'ab');
rollback;

--연습문제) user_constraints, user_cons_columns 뷰를
--조인하여 테이블명, 컬럼이름, 제약조건이름, 
--제약조건 종류를 출력하되 제약조건 종류는 다음과 같이
--표현(PK, UK, CHECK, NN, FK)
select c1.table_name,
       c2.column_name,
       c1.constraint_name,
       c1.constraint_type,
       decode(c1.constraint_type,
              'P','PK',
              'U','UK',
              'R','FK',
              'C',decode(nullable,'N','NN','CHECK'))
       AS 제약조건종류,
       .... AS reference_table,
       .... AS reference_key
  from user_constraints c1, 
       user_cons_columns c2,
       user_tab_columns c3
 where c1.constraint_name = c2.constraint_name
   and c2.column_name = c3.column_name
   and c2.table_name = c3.table_name;

user_constraints  user_cons_columns  user_tab_columns
table_name      -    table_name        table_name  
constraint_name -  constraint_name     column_name
                     column_name
