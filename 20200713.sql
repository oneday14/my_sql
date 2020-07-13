--2. DML(Data Manipulation Langauge) : 
-- 데이터의 수정(구조 변경 X)
--  commit or rollback으로 저장 여부 결정
--1) insert
insert into 테이블명 values(값1,값2,....);
insert into 테이블명(col1, col2, ...)
       values(값1,값2,....);

insert into EMP_BAK3 values('hong',10,1500,'a','b');
insert into EMP_BAK3(emp_name, deptno)
            values('kim',20);
insert into EMP_BAK3 values('park',20,1500,null,null);

insert into EMP_BAK
select * from emp where deptno=10;

commit;

--[ 참고 : 백업 테이블 생성 ]
create table emp_backup as select * from emp;

select 'create table '||TNAME||
       '_backup as select * from '||TNAME||';'
  from tab
 where TNAME not like '%BAK%';

select *
  from tab
 where tname like '%BACKUP';

--2) delete : 행 단위 삭제
delete from 테이블명
 where 조건 ; --서브쿼리 가능

select * from EMP_BAK;

delete from EMP_BAK3;
delete from EMP_BAK where EMPNO = 7369;
commit;

--예제) student_bakup 테이블에서 서진수와 학년이 같은
--학생 데이터 모두 삭제(서진수 포함)

select * 
  from student_bakup;

delete from student_backup
 where grade = (select grade
                  from student_backup
                 where NAME = '서진수');

rollback;

--연습문제) STUDENT_backup 테이블에서 각 학년별
--키가 가장 큰 학생 데이터를 삭제 후 저장
delete from student_backup
 where (grade, height) in (select grade, max(height)
                             from student_backup
                            group by grade);
commit;

--연습문제) emp_backup 테이블에서 각 부서별 평균연봉보다
--작은 연봉을 받는 직원 데이터를 삭제 후 저장
select *
  from emp_backup e1
 where sal < (select avg(sal)
                from emp_backup e2
               where e1.deptno = e2.deptno
               group by deptno);

delete from emp_backup e1
 where sal < (select avg(sal)
                from emp_backup e2
               where e1.deptno = e2.deptno
               group by deptno);

commit;

-- dml 복구 방법
--위의 emp_backup 테이블에서 삭제된 데이터 확인,
--다시 원래대로 복구
--sol1) 지워진 데이터만 찾아서 입력
insert into emp_backup
select *
  from emp_backup as of timestamp 
       to_date('2020/07/13 11:00','YYYY/MM/DD HH24:MI')
 minus
select *
  from emp_backup; 
  
commit; 

--sol2) 지우고 전체 다시 입력
delete from emp_backup;
insert into emp_backup 
select *
  from emp_backup as of timestamp 
       to_date('2020/07/13 11:00',
               'YYYY/MM/DD HH24:MI');

--3) update : 수정, 특정 컬럼의 값
update 테이블명
   set 컬럼명 = 수정값(서브쿼리가능)
 where 조건(서브쿼리가능);
 
--예제) STUDENT_backup 테이블에서 이미경 학생의 키를
--160으로 수정;
select * from student_backup;

update student_backup
   set height = 160
 where name = '이미경';
 
select *
  from student_backup;

--예제) student_backup의 아이디를 앞의 4자로 모두 수정
update student_backup
   set ID = substr(ID,1,4);
   
--연습문제) student_backup테이블에서 avg_height컬럼추가
--각 학년의 키의 평균값으로 수정
alter table student_backup add avg_height number(8);
select * from student_backup;

update student_backup s1
   set AVG_HEIGHT = (select avg(HEIGHT)
                       from student_backup s2
                      where s1.GRADE = s2.GRADE
                      group by GRADE);
                      
commit;

--연습문제) student_backup 테이블에 성별 컬럼을 추가,
--각 학생의 성별을 남,여로 update
alter table student_backup add gender varchar2(4);

update student_backup
   set gender = decode(substr(jumin,7,1),
                       '1','남','여');
rollback;   

update student_backup s1
   set gender = (select decode(substr(jumin,7,1),
                               '1','남','여')
                   from student_backup s1
                  where s1.STUDNO = s2.STUDNO);

select *
  from student_backup;
  
--연습문제) professor_backup 테이블에서 각 학과별 
--평균연봉보다 낮은 연봉을 받는 교수의 연봉을 
--각 학과의 평균연봉으로 수정
select *
  from professor_backup;

update professor_backup p1
   set pay = (select avg(pay)
                from professor_backup p2
               where p1.DEPTNO = p2.DEPTNO)
 where pay < (select avg(pay)
                from professor_backup p3
               where p1.DEPTNO = p3.DEPTNO);
commit;

--4) merge 
-- 두 테이블의 병합
-- insert, update, delete가 동시 수행
merge into 변경테이블명
using 참조테이블명
   on 조건
 when matched then
 update
 when not matched then
 insert/delete;
 
--예제) PT_01 테이블을 PT_02을 참조하여 변경,
--PT_02에만 있는 데이터는 입력,
--양쪽에 있는 데이터는 PT_02 기준으로 수정
insert into PT_02 values(12010103,1003,1,400);

merge into PT_01 p1
using PT_02 p2
   on (p1.판매번호 = p2.판매번호)
 when matched then
update 
   set p1.금액 = p2.금액
 when not matched then
 insert values(p2.판매번호, p2.제품번호, 
               p2.수량, p2.금액);

select * from PT_01;
commit;

--[ commit / rollback 시점 ]
update 1
delete 2
commit 3
insert 4
savepoint A
update 5
savepoint B
delete 6
1. rollback --3번 이후 시점으로 
2. rollback to savepoint B --B 이후로, delete 만 취소
;


-- 데이터 딕셔너리
-- DBMS가 자동으로 관리하는 테이블 및 뷰
-- 주로 객체에 대한 변경 내용 및 
-- 성능, 보안과 관련된 정보를 기록

--1. static dictionary view : 객체 관련
--1) dba_XXX
--   DBA 권한을 갖는 유저 조회 가능, 모든 객체정보 출력
--2) all_XXX
--   조회 유저 소유 혹은 권한이 있는 객체 정보 출력
--3) user_XXX
--   조회 유저 소유의 객체 정보만 출력

select * from user_tables;  -- scott 소유
select * from all_tables;   -- scott 소유 
                            -- scott에 권한이 부여된
select * from dba_tables;   -- system 계정에서 조회가능

-- [ 유용한 딕셔너리 뷰 ]
select * from user_indexes;      -- 인덱스 정보
select * from user_ind_columns;  -- 인덱스 컬럼정보
select * from user_constraints;  -- 제약조건 정보
select * from user_cons_columns; -- 제약조건 컬럼정보
select * from user_tab_columns;  -- 테이블의 컬럼정보
select * from user_views;        -- 뷰 정보
select * from user_users;        -- user 정보

--2. dynamic performance view : 성능 관련
-- v$XXX
-- dba권한 혹은 각 뷰의 조회 권한이 있어야 함
select * from v$session;
select * from v$sql;

-- 제약조건(constraint) 
-- 데이터의 무결성을 위해 생성하는 오브젝트
-- 각 컬럼마다 제약조건을 생성할 수 있음
--1. unique : 중복값 허용 X, NULL 입력 가능
--2. not null : null값 허용 X
--3. primary key(기본키) : 각 행의 유일한 식별자
--   unique + not null 제약조건의 형태
--4. check : 정해진 특정 값으로 입력 제한
--5. foreign key : 특정 테이블의 컬럼을 참조

-- 제약조건 생성
--1) 테이블 생성시
create table cons_test1(
    no   number primary key,
    name varchar2(10) not null
);

insert into cons_test1 values(1,'김길동');
insert into cons_test1 values(1,'홍길동');

create table cons_test2(
    no   number constraint test2_no_pk primary key,
    name varchar2(10) not null
);

insert into cons_test2 values(1,'김길동');
insert into cons_test2 values(1,'홍길동');

--2) 이미 만들어진 테이블에 제약조건 추가
alter table emp_backup 
      add constraint emp_empno_pk primary key(empno);

alter table emp_backup 
      add unique(ename);
      
alter table emp_backup 
      add constraint emp_job_nn not null(job);  --불가
      
alter table emp_backup 
      modify job not null;
      
insert into emp_backup(empno, ename, job)
       values(7000, null, 'CLERK');

-- 하나의 테이블에는 하나의 PK만 생성 가능
alter table emp_backup 
      add constraint emp_empno_pk primary key(ename);

alter table emp_backup 
      add constraint emp_empno_pk 
          primary key(empno,ename);

--[ 참고 : 여러 컬럼을 조합하여 하나의 PK를 만드는 경우]
일자      창고
20200710   a
20200710   b
20200711   a;


-- foreign key 
-- 부모, 자식과의 관계를 갖는 자식 테이블에 설정
-- 참조대상(부모)의 컬럼을 reference key라고 함

--예제) emp테이블에 50번 부서에 속하는 홍길동 행 추가
insert into emp(empno,ename,deptno)
       values(1000,'홍길동',50); -- 에러(부모키가 없음)

--예제) emp테이블에 SMITH 부서번호를 50으로 수정
update emp
   set deptno = 50
 where ename='SMITH'; --에러(부모키가 없음)

--예제) dept 테이블에 10번 부서정보 삭제
delete from dept
 where deptno = 10;  --에러(자식레코드 발견)

rollback;       






