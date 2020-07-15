user_constraints  user_cons_columns  user_tab_columns
table_name      -    table_name        table_name  
constraint_name -  constraint_name     column_name
                     column_name
;

-- 테이블명, 컬럼명, 제약조건 이름, 종류,
-- 부모테이블명, reference_key 조회
select c1.TABLE_NAME AS "테이블명(자식테이블)",
       c3.column_name AS 컬럼명,
       c1.constraint_name AS 제약조건이름,
       c1.constraint_type AS 제약조건종류,
       c2.table_name AS 부모테이블명,
       c4.column_name AS "reference_key"
  from user_constraints c1, user_constraints c2,
       user_cons_columns c3, user_cons_columns c4
 where c1.r_constraint_name = c2.constraint_name(+)
   and c1.constraint_name = c3.constraint_name
   and c2.constraint_name = c4.constraint_name(+);

--c3 - c1 - c2(+) - c4(+);

select * from user_constraints;

---------- 여기까지는 복습입니다. ----------

-- foreign key 생성 옵션
--자식테이블    - 부모 테이블
--foreign key     reference key
--
--1. on delete cascade : 부모 데이터 삭제 시 자식 데이터
--                       함께 삭제
--2. on delete set null : 부모 데이터 삭제 시 자식 데이터
--                        null로 업데이트;

create table emp_t2 as select * from emp;
create table dept_t2 as select * from dept;

alter table dept_t2 add constraint deptt2_deptno_pk
                    primary key(deptno);
               
--case1) foreign key 옵션 없이 생성 시 delete
alter table emp_t2 add constraint empt2_deptno_fk
      foreign key(deptno) references dept_t2(deptno);

delete from dept_t2 where deptno = 10; -- 불가

--case2) on delete cascade 옵션으로 생성 시 delete
alter table emp_t2 drop constraint empt2_deptno_fk;

alter table emp_t2 add constraint empt2_deptno_fk
      foreign key(deptno) references dept_t2(deptno)
      on delete cascade;

delete from dept_t2 where deptno = 10;  -- 가능
select * from emp_t2; -- 10번 부서 데이터 함께 삭제
rollback;

--case3) on delete set null 옵션으로 생성 시 delete
alter table emp_t2 drop constraint empt2_deptno_fk;

alter table emp_t2 add constraint empt2_deptno_fk
      foreign key(deptno) references dept_t2(deptno)
      on delete set null;

delete from dept_t2 where deptno = 10;  -- 가능
select * from emp_t2; -- 10번 부서 데이터 null로 수정


--[ 참고 : 테이블 및 컬럼 comment 조회 및 부여하기 ]
--1) 조회
select * 
  from all_tab_comments;  -- 테이블 설명
  
select * 
  from all_col_comments;  -- 컬럼 설명

--2) comment 부여
comment on table 테이블명 is 설명;
comment on column 테이블명.컬럼1 is 설명;

comment on table emp_t2 is 'emp test table';
comment on column emp_t2.empno is '사원번호';


-- [ DDL 연습문제 : pdf 파일 ]
drop table board purge;
drop table member2 purge;

create table member2(
userid varchar2(10) ,
username varchar2(10) ,
passwd varchar2(10) ,
idnum varchar2(13) ,
phone number(13) ,
address varchar2(20) ,
regdate date ,
interest varchar2(15) 
);

alter table member2 add primary key(userid);
alter table member2 add unique(idnum);
alter table member2 modify username not null;
alter table member2 modify passwd not null;

comment on column member2.userid is '사용자아이디';
comment on column member2.username  is '회원이름';
comment on column member2.passwd  is '비밀번호';
comment on column member2.phone   is '전화번호';
comment on column member2.address  is '주소';
comment on column member2.regdate  is '가입일';
comment on column member2.interest   is '관심분야';

create table board(
NO NUMBER(4),
SUBJECT VARCHAR2(50) ,
CONTENT VARCHAR2(100) ,
RDATE DATE ,
USERID VARCHAR2(10));

alter table board add primary key(no);
alter table board add foreign key (userid) references member2(userid);
alter table board modify subject not null;

comment on column board.NO  is '게시물 번호';
comment on column board.SUBJECT   is '제목';
comment on column board.CONTENT   is '내용';
comment on column board.RDATE    is '작성일자';
comment on column board.USERID   is '글쓴이';


-- 기타 오브젝트
--1. 뷰
-- 실제 저장공간을 갖지 않고 특정 쿼리의 결과를 출력
-- 뷰를 테이블처럼 조회 가능
-- 단순뷰(테이블 한개)/복합뷰(여러 테이블)

--1) 생성
create [or replace] view 뷰이름
as
subquery;

-- system 계정에서 아래 수행
grant dba to scott;

-- scott 계정에서 뷰 생성(재접속 필요)
create view emp_view1
as
select empno, ename 
  from emp;

create or replace view emp_view1
as
select empno, ename, sal 
  from emp;

select *
  from emp_view1;

create view student_hakjum  
as
select s.studno, s.name, e.total, h.grade
  from student s, exam_01 e, hakjum h
 where s.studno = e.studno
   and e.total between h.min_point and h.max_point;

--2) 뷰 조회
select * from user_views;

--3) 뷰를 통한 원본 테이블 수정
update emp_view1
   set ename = 'smith'
 where ename = 'SMITH';

select * from emp;

--4) 삭제
drop view emp_view1;

--2. 시퀀스 : 연속적인 번호의 자동 부여

--1) 생성
create sequence 시퀀스 이름
increment by n   -- 증가값
start with n     -- 시작값
maxvalue n       -- 최대값, 재시작 시점
minvalue n       -- 최소값, 재시작 시점
cycle            -- 순환여부(번호 재사용 여부)
cache n          -- 캐싱사이즈
;

--[ sequence를 사용한 자동 번호 부여 test ]
--1. sequence 생성
--drop sequence test_seq1;
create sequence test_seq1
increment by 1
start with 100
maxvalue 110
;

create sequence test_seq2
increment by 1
start with 100
maxvalue 110
minvalue 100
cycle
cache 2
;

create sequence test_seq3
increment by 1
start with 100
maxvalue 110
minvalue 100
cycle
cache 2
;


--2. test table 생성
create table jumun1(
no   number,
name varchar2(10),
qty  number);

create table jumun2(
no   number,
name varchar2(10),
qty  number);

--3. sequence를 사용한 데이터 입력
--1) nocycle로 생성시 insert 여러번 반복
-- maxvalue를 초과하는 순간 에러 발생
-- 해당 sequence 사용 불가
insert into jumun1 values(test_seq1.nextval, 'latte',2);
select * from jumun1;

--2) cycle로 생성시 insert 여러번 반복
-- maxvalue를 초과하는 순간 minvalue값 사용
-- 해당 sequence 계속 사용 가능
insert into jumun2 values(test_seq2.nextval, 'latte',2);
select * from jumun2;
rollback;

insert into jumun2 values(test_seq3.nextval, 'latte',2);
select * from jumun2;

--4. sequence 현재 번호 확인
select test_seq2.currval
  from dual;

select * 
  from user_sequences;


--3. 시노님 : 광범위하게 사용 가능한 테이블 별칭
--1) 생성
create [or replace] [public] synonym 별칭명
        for 테이블명;

create synonym emp_test for emp;
select * from emp_test;

--scott 계정에서 수행)
select * from employees;

--system 계정에서 수행) 
--scott에게 hr의 employees 테이블 조회 권한 부여
grant select on hr.EMPLOYEES to scott;

--scott 계정에서 수행)
select * from hr.employees;

--system 계정에서 수행) 
create synonym employees1 for hr.employees;
create public synonym employees for hr.employees;

--scott 계정에서 수행)
select * from employees1;
select * from employees;

--2) 조회
select *
  from all_synonyms
 where 1=1
   and table_owner in ('SCOTT','HR')
--   and table_name = 'EMPLOYEES'
 ;

--3) 삭제(system 계정에서 수행)
drop synonym employees1;
drop public synonym employees;

--[ 연습 문제 ]
--hr계정에서 scott 전 테이블 조회 가능하도록 시노님생성 
--scott계정에서 hr 전 테이블 조회 가능하도록 시노님생성
--
--system 계정에서 수행)
select 'create or replace public synonym '||
       table_name||' for '||owner||'.'||table_name||';'
  from dba_tables
 where owner in ('SCOTT','HR');

select * from hr.REGIONS;
select * from REGIONS;

create or replace public synonym DEPT for SCOTT.DEPT;
create or replace public synonym EMP for SCOTT.EMP;
create or replace public synonym BONUS for SCOTT.BONUS;
create or replace public synonym SALGRADE for SCOTT.SALGRADE;
create or replace public synonym REGIONS for HR.REGIONS;
create or replace public synonym LOCATIONS for HR.LOCATIONS;
create or replace public synonym DEPARTMENTS for HR.DEPARTMENTS;
create or replace public synonym PROFESSOR for SCOTT.PROFESSOR;
create or replace public synonym DEPARTMENT for SCOTT.DEPARTMENT;
create or replace public synonym STUDENT for SCOTT.STUDENT;
create or replace public synonym EMP2 for SCOTT.EMP2;
create or replace public synonym DEPT2 for SCOTT.DEPT2;
create or replace public synonym CAL for SCOTT.CAL;
create or replace public synonym GIFT for SCOTT.GIFT;
create or replace public synonym GOGAK for SCOTT.GOGAK;
create or replace public synonym HAKJUM for SCOTT.HAKJUM;
create or replace public synonym EXAM_01 for SCOTT.EXAM_01;
create or replace public synonym P_GRADE for SCOTT.P_GRADE;
create or replace public synonym REG_TEST for SCOTT.REG_TEST;
create or replace public synonym P_01 for SCOTT.P_01;
create or replace public synonym P_02 for SCOTT.P_02;
create or replace public synonym PT_01 for SCOTT.PT_01;
create or replace public synonym PT_02 for SCOTT.PT_02;
create or replace public synonym P_TOTAL for SCOTT.P_TOTAL;
create or replace public synonym DML_ERR_TEST for SCOTT.DML_ERR_TEST;
create or replace public synonym TEST_NOVALIDATE for SCOTT.TEST_NOVALIDATE;
create or replace public synonym TEST_VALIDATE for SCOTT.TEST_VALIDATE;
create or replace public synonym TEST_ENABLE for SCOTT.TEST_ENABLE;
create or replace public synonym PRODUCT for SCOTT.PRODUCT;
create or replace public synonym PANMAE for SCOTT.PANMAE;
create or replace public synonym MEMBER for SCOTT.MEMBER;
create or replace public synonym REG_TEST2 for SCOTT.REG_TEST2;
create or replace public synonym TEST1 for SCOTT.TEST1;
create or replace public synonym PLAN_TABLE for SCOTT.PLAN_TABLE;
create or replace public synonym TEST2 for SCOTT.TEST2;
create or replace public synonym TEST2 for HR.TEST2;
create or replace public synonym EMP_BAK for SCOTT.EMP_BAK;
create or replace public synonym EMP_BAKUP2 for SCOTT.EMP_BAKUP2;
create or replace public synonym EMP_BAK5 for SCOTT.EMP_BAK5;
create or replace public synonym STUDENT_BAK for SCOTT.STUDENT_BAK;
create or replace public synonym BONUS_BACKUP for SCOTT.BONUS_BACKUP;
create or replace public synonym CAL_BACKUP for SCOTT.CAL_BACKUP;
create or replace public synonym DEPARTMENT_BACKUP for SCOTT.DEPARTMENT_BACKUP;
create or replace public synonym DEPT_BACKUP for SCOTT.DEPT_BACKUP;
create or replace public synonym DEPT2_BACKUP for SCOTT.DEPT2_BACKUP;
create or replace public synonym DML_ERR_TEST_BACKUP for SCOTT.DML_ERR_TEST_BACKUP;
create or replace public synonym EMP_BACKUP for SCOTT.EMP_BACKUP;
create or replace public synonym EMP2_BACKUP for SCOTT.EMP2_BACKUP;
create or replace public synonym EXAM_01_BACKUP for SCOTT.EXAM_01_BACKUP;
create or replace public synonym GIFT_BACKUP for SCOTT.GIFT_BACKUP;
create or replace public synonym GOGAK_BACKUP for SCOTT.GOGAK_BACKUP;
create or replace public synonym HAKJUM_BACKUP for SCOTT.HAKJUM_BACKUP;
create or replace public synonym MEMBER_BACKUP for SCOTT.MEMBER_BACKUP;
create or replace public synonym PANMAE_BACKUP for SCOTT.PANMAE_BACKUP;
create or replace public synonym PRODUCT_BACKUP for SCOTT.PRODUCT_BACKUP;
create or replace public synonym PROFESSOR_BACKUP for SCOTT.PROFESSOR_BACKUP;
create or replace public synonym PT_01_BACKUP for SCOTT.PT_01_BACKUP;
create or replace public synonym PT_02_BACKUP for SCOTT.PT_02_BACKUP;
create or replace public synonym P_01_BACKUP for SCOTT.P_01_BACKUP;
create or replace public synonym P_02_BACKUP for SCOTT.P_02_BACKUP;
create or replace public synonym P_GRADE_BACKUP for SCOTT.P_GRADE_BACKUP;
create or replace public synonym P_TOTAL_BACKUP for SCOTT.P_TOTAL_BACKUP;
create or replace public synonym REG_TEST_BACKUP for SCOTT.REG_TEST_BACKUP;
create or replace public synonym REG_TEST2_BACKUP for SCOTT.REG_TEST2_BACKUP;
create or replace public synonym SALGRADE_BACKUP for SCOTT.SALGRADE_BACKUP;
create or replace public synonym STUDENT_BACKUP for SCOTT.STUDENT_BACKUP;
create or replace public synonym TEST1_BACKUP for SCOTT.TEST1_BACKUP;
create or replace public synonym TEST2_BACKUP for SCOTT.TEST2_BACKUP;
create or replace public synonym TEST_ENABLE_BACKUP for SCOTT.TEST_ENABLE_BACKUP;
create or replace public synonym TEST_NOVALIDATE_BACKUP for SCOTT.TEST_NOVALIDATE_BACKUP;
create or replace public synonym TEST_VALIDATE_BACKUP for SCOTT.TEST_VALIDATE_BACKUP;
create or replace public synonym STUDENT2 for SCOTT.STUDENT2;
create or replace public synonym STUDENT3 for SCOTT.STUDENT3;
create or replace public synonym EMP_BACK2 for SCOTT.EMP_BACK2;
create or replace public synonym CAFE_PROD for SCOTT.CAFE_PROD;
create or replace public synonym JUMUN for SCOTT.JUMUN;
create or replace public synonym EMP_T1 for SCOTT.EMP_T1;
create or replace public synonym DEPT_T1 for SCOTT.DEPT_T1;
create or replace public synonym EMP_T2 for SCOTT.EMP_T2;
create or replace public synonym DEPT_T2 for SCOTT.DEPT_T2;
create or replace public synonym MEMBER2 for SCOTT.MEMBER2;
create or replace public synonym BOARD for SCOTT.BOARD;
create or replace public synonym COUNTRIES for HR.COUNTRIES;
create or replace public synonym EMPLOYEES for HR.EMPLOYEES;
create or replace public synonym EMP_BAK4 for SCOTT.EMP_BAK4;
create or replace public synonym EMP_BAK3 for SCOTT.EMP_BAK3;
create or replace public synonym JOB_HISTORY for HR.JOB_HISTORY;
create or replace public synonym JOBS for HR.JOBS;

--4. index
-- index : 데이터의 위치값을 기록해놓은 오브젝트

select * 
  from emp
 where empno = 7369;

select rowid, empno
  from emp;

select hiredate, rowid
  from emp
 order by 1;

--1) 생성
create index 인덱스명 on 테이블명(컬럼명);

create index emp_hd_idx on emp(hiredate);
drop index emp_hd_idx;

-- FBI(Function Based Index)
--예제) 1980년에 입사한 사람을 출력하는 쿼리 작성 후
--인덱스 스캔이 가능하게 하여라
-- index supressing
select *
  from EMP
 where to_char(hiredate,'YYYY') = 1980;

create index emp_hd_fbi 
       on emp(to_char(hiredate,'YYYY'));

select *
  from EMP
 where to_char(hiredate,'YYYY') = '1980';

       
--2) 인덱스의 이점
select *
  from emp
 where hiredate = '1981/06/09';  --ctrl + e

--연습문제) 1981년 6월 9일에 입사한 사람 출력 후
--각 쿼리의 실행계획 확인(ctrl + e)
--단, 입사일은 06/09/1981 형태로 전달

select *
  from emp
 where hiredate = '06/09/1981'; 

--1) hiredate 컬럼 수정
select *
  from emp
 where to_char(hiredate, 'MM/DD/YYYY') = '06/09/1981'; 
 
--2) '06/09/1981' 수정
select *
  from emp
 where hiredate = to_date('06/09/1981', 'MM/DD/YYYY'); 
 

[목차1]
substr    10
decode    11

[목차2]
select    1
where     10
groupby   20
;


-- 권한(대체적으로 관리자 계정으로 수행)
--1. 부여
--1) 오브젝트 권한
grant 권한 to 유저명;
grant select on scott.emp to hr;
grant select on scott.dept to hr;

--2) 시스템 권한
grant create view to hr;
grant create table to hr;
grant alter table to hr;
grant create index to hr;

--3) role(권한의 묶음)을 통한 권한 부여
create role test_role;
grant select on hr.EMPLOYEES to test_role;
grant test_role to scott;
grant dba to hr;

--2. 회수
revoke 권한명 from 유저명;

