--연습문제) PROFESSOR 테이블에서 입사년도별
--평균 연봉보다 높은 교수의 이름, 소속학과명, PAY,
--지도학생 수를 함께 출력
select p.NAME, d.dname, p.PAY, 
       count(s.NAME) AS 지도학생수
  from PROFESSOR p, DEPARTMENT d, STUDENT s,
       (select to_char(HIREDATE,'YYYY') AS hyear,
               avg(pay) AS avg_pay
          from PROFESSOR
         group by to_char(HIREDATE,'YYYY')) i
 where to_char(p.HIREDATE,'YYYY') = hyear
   and p.PAY > avg_pay
   and p.DEPTNO = d.DEPTNO
   and p.PROFNO = s.PROFNO(+)
 group by p.PROFNO, p.NAME, d.dname, p.PAY;

---------- 여기까지는 복습입니다. ----------   

d - p - i
    |
    s(+);

-- 서브쿼리
--1. where절 서브쿼리
-- 1)단일행 서브쿼리 : =, 대소비교 가능
-- 2)다중행 서브쿼리 : =, 대소비교 불가 => in, any, all
-- 3)다중컬럼 서브쿼리 : 그룹내 동등비교 가능,
--                       그룹내 대소비교 불가 => 인라인뷰
-- 4)상호연관 서브쿼리 : 그룹내 대소비교 가능

--예제) emp 테이블에서 각 job별 최소연봉을 받는 직원의
--이름, job, sal 출력
select *
  from emp
 where job in (select job
                from emp
               group by job)   -- 그룹비교로 좋지 X
   and sal in (select min(sal) --    (무조건 참)
                from emp
               group by job);  -- 에러 발생 X,
                               -- 그룹내 비교 발생 X

select *
  from emp e1
 where e1.job = e2.job         -- 에러 발생
   and sal in (select min(sal)
                from emp e2
               group by job);

select *
  from emp e1
 where sal in (select min(sal)
                 from emp e2
                where e1.job = e2.job -- 서브쿼리로 이동
                group by job);
               
select *
  from emp 
 where (job,sal) in (select job, min(sal)
                       from emp
                      group by job);

empno job sal
1     a   3000   ***
2     a   4000
3     b   3000
4     b   2000   ***
;

-- 상호연관 서브쿼리의 실행순서
select *
  from emp e1
 where sal in (select min(sal)
                 from emp e2
                where e1.job = e2.job 
                group by job);

1) 첫번째 행의 SAL 확인 : 800
2) 서브쿼리 실행 시 e1.job 요구 : CLERK
3) 서브쿼리의 where절이 'CLERK' = e2.job 수행
4) 서브쿼리에서 job이 'CLERK'인 행의 min(sal) 연산 : 800
5) 메인쿼리의 조건절은 800 = 800 이므로 첫 번째 행 선택
6) 나머지 행 모두 반복
;

--연습문제) PROFESSOR 테이블에서 소속학과별 PAY가 
--가장 큰 교수의 정보 출력
--1) 다중컬럼
select *
  from PROFESSOR
 where (deptno, pay) in (select deptno, 
                                max(pay) AS max_pay
                           from PROFESSOR
                          group by deptno);
--2) 인라인뷰
select *
  from PROFESSOR p, (select deptno, 
                            max(pay) AS max_pay
                       from PROFESSOR
                      group by deptno) i
 where p.deptno = i.deptno
   and p.PAY = i.max_pay;
   
--3) 상호연관
select *
  from PROFESSOR p1
 where pay = (select max(pay) AS max_pay
                from PROFESSOR p2
               where p1.DEPTNO = p2.DEPTNO);

--2. from절 서브쿼리(인라인뷰)

--연습문제) emp2 테이블에서 고용타입(EMP_TYPE)별
--평균 PAY보다 적게 받는 직원을 출력;
--1) 인라인뷰
select *
  from emp2 e, (select emp_type, 
                       avg(pay) AS avg_pay
                  from emp2
                 group by emp_type) i 
 where e.EMP_TYPE = i.emp_type
   and e.PAY > i.avg_pay;
   
--2) 상호연관
select *
  from emp2 e
 where 1=1
   and e.PAY > (select avg(pay) AS avg_pay
                  from emp2 i
                 where e.EMP_TYPE = i.emp_type);
   
--3. select절 서브쿼리(스칼라 서브쿼리)
-- select절에 사용되는 서브쿼리

-- 1) 하나의 상수를 대체하기 위한 용도
--예제) ALLEN의 이름, JOB, SAL, DEPTNO를 출력하되
--ALLEN의 부서는 SMITH의 부서와 동일하게 출력
select ENAME, JOB, SAL, 20 AS deptno
  from emp
 where ENAME='ALLEN';

select ENAME, JOB, SAL, 
       (select deptno 
          from emp
         where ename = 'SMITH') AS deptno
  from emp
 where ENAME='ALLEN';

--예제) ALLEN의 이름, JOB, SAL, DEPTNO를 출력하되
--ALLEN의 부서는 M으로 시작하는 직원의 부서정보로 출력
select ENAME, JOB, SAL, 
       (select deptno 
          from emp
         where ename like 'M%') AS deptno -- 에러발생
  from emp
 where ENAME='ALLEN';

-- 2) 조인의 대체 연산(특정 컬럼의 표현)
-- 조인조건에 맞지 않는 데이터도 출력(아우터조인 대체)

--연습문제) emp, dept 테이블에서 각 직원의 이름, 
--sal, 부서명을 함께 출력(스칼라 서브쿼리)
select e.ENAME, d.DNAME
  from emp e, dept d
 where e.DEPTNO = d.DEPTNO;

select e.ENAME, (select d.DNAME
                   from dept d
                  where e.DEPTNO = d.DEPTNO)
  from emp e;

--연습문제) emp 테이블을 사용하여 각 직원의 이름,
--상위관리자 이름을 동시 출력(스칼라 서브쿼리)
select e1.ename AS 직원명, 
       e2.ENAME AS 관리자명
  from emp e1, emp e2
 where e1.MGR = e2.EMPNO(+);
 
select e1.ename AS 직원명, 
       (select e2.ENAME 
          from emp e2
         where e1.MGR = e2.EMPNO) 
  from emp e1;
 
--연습문제) STUDENT, PROFESSOR 테이블을 사용,
--학생이름, 지도교수이름 출력
--단, 지도교수 이름이 없는 경우 '홍길동' 출력
select s.name AS 학생이름,
       nvl(p.name,'홍길동') AS 교수이름
  from STUDENT s, PROFESSOR p
 where s.PROFNO = p.PROFNO(+);

select s.name AS 학생이름,
       nvl((select p.name
              from PROFESSOR p
             where s.PROFNO = p.PROFNO), 
           '홍길동') AS 교수이름
  from STUDENT s;

--연습문제) STUDENT, EXAM_01, HAKJUM 테이블을 사용하여
--각 학생의 이름, 시험성적, 학점을 출력하되
--스칼라 서브쿼리를 2개 사용
select s.NAME,
       e.TOTAL,
       h.GRADE
  from STUDENT s, EXAM_01 e, HAKJUM h
 where s.STUDNO = e.STUDNO
   and e.TOTAL between h.MIN_POINT and h.MAX_POINT;

select (select s.NAME 
          from STUDENT s 
         where s.STUDNO = e.STUDNO) AS 학생이름,
       e.TOTAL,
       (select h.GRADE
          f
          rom HAKJUM h
         where e.TOTAL between h.MIN_POINT and 
                               h.MAX_POINT) AS 학점
  from EXAM_01 e;
 

select s.NAME, e.TOTAL,
       (select h.GRADE
          from HAKJUM h
         where e.TOTAL between h.MIN_POINT 
                           and h.MAX_POINT) AS 학점
  from STUDENT s, EXAM_01 e
 where s.STUDNO = e.STUDNO;

-- 참고 : 순환 구조를 갖는 경우의 아우터 조인 연산
--        => 서브쿼리 사용
a - b(+)
|   |
d - c

a(+) - b(+)
|       |      : 순환구조 에러 발생
d(+) - c(+)

(a - d) - (b - c)(+)   ;


-- 변경 언어 분류 
--1. DDL : 객체의 정의 언어
--         객체 생성(create), 변경(alter), 삭제(drop),
--         객체 비우기(truncate)
--         
--2. DML : 데이터 수정 언어
--         데이터 입력(insert), 
--         수정(update), 
--         삭제(delete)
--         
--3. DCL : 트랜잭션 컨트롤 언어
--         저장(commit), 취소(rollback)


-- 1. DDL(Data Definition Language)
-- 1) create : 테이블 및 객체 생성
create table test2(
col1    varchar2(10) not null,
col2    number(10)
);

--** 테이블명은 다른 객체 이름과 중복될 수 없지만
--유저가 다르면 중복된 테이블명을 사용할 수 있음
scott.emp
hr.emp
;

-- 테이블 복사하기
-- (CTAS : Create Table As Select)
create table emp_bak
as
select *
  from emp;

select * from emp_bak;

create table emp_bak2
as
select *
  from emp
 where DEPTNO = 10;

create table emp_bak3
as
select ename AS emp_name, deptno, sal
  from emp;

select * from emp_bak3;

create table emp_bak4
as
select to_char(empno) AS empno, ename AS emp_name, 
       deptno, sal
  from emp;
  
desc emp_bak4;

-- 빈 테이블 생성하기(구조만 복사)
create table emp_bak5
as
select * 
  from emp
 where 1=2;  -- 항상 거짓조건 전달, no date selected

select * from emp_bak5;

desc emp_bak5;

create table STUDENT_bak
as
select * from STUDENT;
desc STUDENT;

다음 중 CTAS로 복제되지 않는 대상은? 5
1. 컬럼이름
2. 컬럼순서
3. 컬럼타입
4. 널여부
5. 제약조건
;




