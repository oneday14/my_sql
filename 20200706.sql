--1. EMP 테이블의 사원이름, 매니저번호(MGR)를 출력하고, 
--매니저번호가 null이면 '상위관리자'로 표시, 
--매니저번호가 있으면 매니저번호담당으로 표시하여라
-- ex) mgr이 7869이면 7869담당
select empno, ename, mgr,
       nvl2(MGR, to_char(mgr)||'담당','상위관리자')
  from emp;
  
--2. Student 테이블의 jumin 컬럼을 참조하여 학생들의 
--이름과 태어난 달, 그리고 분기를 출력하라.
--태어난 달이 01-03월 은 1/4분기, 04-06월은 2/4 분기, 
--07-09 월은 3/4 분기, 10-12월은 4/4 분기로 출력하라.
select name, jumin,
       substr(JUMIN,3,2),
case when to_number(substr(JUMIN,3,2)) between 1 and 3 
     then '1/4분기'
     when to_number(substr(JUMIN,3,2)) between 4 and 6
     then '2/4분기'
     when to_number(substr(JUMIN,3,2)) between 7 and 9
     then '3/4분기'
     else '4/4분기'
 end 분기1
  from STUDENT;

select name, jumin,
       to_char(to_date(substr(jumin,1,6),'RRMMDD'),
               'Q')||'/4분기' AS 분기2
  from STUDENT;
  
--3. emp 테이블에서 인상된 연봉을 기준으로 2000 미만은
--'C', 2000이상 4000미만은 'B', 4000이상은 'A' 등급을 
--부여하여 각 직원의 현재 연봉과 함께 출력
--**인상된 연봉 = 기존 연봉 15% 인상 + 보너스(comm)
select ENAME, SAL, comm, SAL*1.15, 
       SAL*1.15 + nvl(comm,0) AS new_sal,
       case when SAL*1.15 + nvl(comm,0) < 2000 then 'C'
            when SAL*1.15 + nvl(comm,0) < 4000 then 'B'
                                               else 'A'
        end AS 등급
  from emp;

--4. EMP 테이블을 이용하여 사원이름, 입사일 및 
--급여검토일을 표시합니다. 
--급여검토일은 여섯달 근무후 해당되는 첫번째 월요일 
--날짜는 "Sunday the Seventh of September, 1981" 
--형식으로 표시. 열 이름은 check로 한다.
alter session set nls_date_language='american';

select ENAME, HIREDATE, 
       to_char(next_day(add_months(HIREDATE, 6),'mon'),
               'Day "of" ddspth "the" month, YYYY'),
       trim(to_char(next_day(add_months(HIREDATE, 6),'mon'),
               'Day'))||' the '||
       trim(to_char(next_day(add_months(HIREDATE, 6),'mon'),
               'ddspth'))||' of '||
       trim(to_char(next_day(add_months(HIREDATE, 6),'mon'),
               'month'))||
       to_char(next_day(add_months(HIREDATE, 6),'mon'),
               ',YYYY')        
  from emp;


--5. emp 테이블을 사용하여 연봉기준 등급을 아래의 
--기준에 맞게 표현하세요.
--2000미만 'C', 2000이상 3000이하 'B', 3000초과 'A'
--decode문 작성
select ename, sal, 
       sign(sal-2000), -- sal < 2000 => -1 
       sign(sal-3000),  -- sal > 3000 => 1
       decode(sign(sal-2000),-1,
              'C',decode(sign(sal-3000),1,'A','B')),
       decode(sign(sal-2000)+sign(sal-3000),-2,'C',
                                             2,'A','B')       
  from emp
 order by sal;

---------- 여기까지는 복습입니다. ----------

-- group by절 : 그룹별 그룹함수의 적용
-- "분리 - 적용 - 결합"의 연산 수행
-- 그룹당 한 개의 행 리턴
-- group by에 명시되지 않은 컬럼 select절에 
-- 단독 사용불가, 그룹함수와 함께 사용 필요
select deptno, max(sal)
  from emp
 group by deptno;

-- 그룹함수 
-- 1. sum
select sum(sal), sum(comm)
  from emp;

-- 2. count
select count(*),     -- 전체컬럼이 null일 수 없음, 가장 정확한 행의 수 리턴
       count(empno), -- not null컬럼이 null일 수 없음, 가장 빠르고 정확한 결과
       count(comm)   -- count는 null을 세지 않음
  from emp;

-- 3. avg
select avg(comm),   -- null 제외 후 평균(4명의 평균)
       sum(comm)/count(comm), -- avg 수행결과와 동일
       sum(comm)/14,  -- 14명(전체)의 평균
       avg(nvl(comm,0)) -- 14명(전체)의 평균
  from emp;
  
-- 4. min/max
select min(comm), max(comm)
  from emp;
  
-- 연습문제) 학생테이블에서 각 학년별, 성별
-- 학생수와 키와 몸무게의 평균을 출력하세요
select grade, 
       decode(substr(jumin,7,1),'1','남','여') AS 성별,
       count(STUDNO) AS 학생수,
       round(avg(height),1) AS 평균키, 
       avg(weight) AS 평균몸무게
  from STUDENT
 group by grade, substr(jumin,7,1);

-- having절 : 행의 조건 전달, 그룹 연산 결과의 조건 사용
--예제) 학생테이블에서 학 학년별 평균키를 구하고
--      평균키가 170 이상인 학년만 출력
select grade, avg(height)
  from STUDENT
 where avg(height) >= 170 -- 그룹함수는 where절 사용불가
 group by grade;
 
select grade, avg(height)
  from STUDENT 
 group by grade
having avg(height) >= 170; 

-- [ select문의 6가지 절 수행 순서 ]
-- select     -- 5
--   from     -- 1
--  where     -- 2
--  group by  -- 3
-- having     -- 4
--  order by  -- 6
; 
--연습문제) emp테이블에서 10번 부서를 제외하고 
--나머지에 대해 부서별 평균 연봉을 구하여라
select deptno, avg(sal)
  from emp
 where deptno != 10
 group by deptno;

select deptno, avg(sal)
  from emp
 group by deptno
having deptno != 10;

--=> 일반조건은 where, having절 모두 사용 가능하나
--where절에 사용하는 것이 성능상 유리

-- 연습문제) EMP 테이블에서 부서 인원이 4명보다 많은 
-- 부서의 부서번호, 인원수, 급여의 합을 출력하여라. 
select DEPTNO, count(EMPNO) AS 인원수,
       sum(sal) AS 급여합
  from emp
 group by DEPTNO
having count(EMPNO) > 4;
  
-- 연습문제) EMP 테이블에서 업무별 급여의 평균이 
-- 3000 이상인 업무에 대해서 업무명, 평균 급여, 
-- 급여의 합을 구하여라.  
select job, avg(sal), sum(sal)
  from emp
 group by job, deptno
having avg(sal) >= 3000;

--다음과 같은 데이터에서 job별 sal의 총 합과 함께
--부서번호를 함께 출력하여라
job   deptno sal
A     10     1000
A     10     2000 
B     20     3000

select job, sum(sal), deptno
  from a
 group by job, deptno;

A  10   3000
B  20   3000
;

-- 집합 연산자 : select 결과에 대한 집합을 구하는 연산
--1. union/union all : 합집합
--2. intersect : 교집합
--3. minus : 차집합

-- 사용시 주의
-- select절에 표현되는 컬럼의 개수, 순서, 
-- 데이터 타입 일치
select ename, deptno, sal*1.1, '500'
  from emp
 where deptno = 10
 union 
select ename, deptno, sal*1.2, to_char(comm)
  from emp
 where deptno = 20;
   
-- union / union all의 차이
-- union : 중복된 행을 제거하기 위해 내부 정렬 수행
-- union all : 중복 행 제거 없이 모두 출력, 정렬 수행X
-- => union / union all의 결과가 같다면 union all 수행

select ename, deptno
  from emp
 where deptno in (10,20)
 union
select ename, deptno
  from emp
 where deptno = 10;   
   
select ename, deptno
  from emp
 where deptno in (10,20)
 union all
select ename, deptno
  from emp
 where deptno = 10;

-- intersect
select ename, deptno
  from emp
 where deptno in (10,20)
 intersect
select ename, deptno
  from emp
 where deptno = 10;

-- minus
select ename, deptno
  from emp
 where deptno in (10,20)
 minus
select ename, deptno
  from emp
 where deptno = 10;

-- 조인  

--1. cross join : 카티시안 곱 발생
--  (발생가능한 모든 경우의 수)
--   주로 조인조건 생략 혹은 부적절한 조인조건 전달시
--1) 오라클 표준
select * 
  from emp, dept
 order by 1;

--2) ANSI 표준
select * 
  from emp cross join dept
 order by 1;
 
-- 2. inner join : 조인조건에 맞는 행만 연결해서 출력
-- 2-1) equi join(등가 조인) : 조인 조건이 '='
--1) 오라클 표준
select emp.*, DNAME 
  from emp, dept
 where emp.DEPTNO = dept.DEPTNO
 order by 1;

--2) ANSI 표준
select e.*, DNAME 
  from emp e join dept d
    on e.DEPTNO = d.DEPTNO
 order by 1;
 
--[ 참고 : 테이블 별칭 사용 ]
--테이블 별칭을 사용하는 경우 반드시 
--컬럼명의 출처 전달시 테이블 이름이 아닌 별칭 사용
select e.*, DNAME 
  from emp e, dept d
 where e.DEPTNO = d.DEPTNO
 order by 1;

SQL : 국제적 표준 => ANSI 표준
      ORACLE 표준
;

--연습문제) student 테이블과 EXAM_01 테이블을 사용하여
--각 학생의 학번, 이름, 학년, 시험성적을 함께 출력
select s.STUDNO, s.NAME, s.GRADE, e.TOTAL
  from STUDENT s, EXAM_01 e
 where s.STUDNO = e.STUDNO;

select s.STUDNO, s.NAME, s.GRADE, e.TOTAL
  from STUDENT s join EXAM_01 e
    on s.STUDNO = e.STUDNO;

--연습문제) 위 결과를 사용하여 학년별 시험성적의
--평균을 출력하세요
select s.GRADE, avg(e.TOTAL)
  from STUDENT s, EXAM_01 e
 where s.STUDNO = e.STUDNO
 group by s.GRADE;

select s.GRADE, avg(e.TOTAL)
  from STUDENT s join EXAM_01 e
    on s.STUDNO = e.STUDNO
 group by s.GRADE;

-- 2-2) non equi join(비등가 조인) 
--    : 조인 조건이 '='이 아닌 경우
select g1.GNAME AS 고객이름,
       g2.GNAME AS 상품명
  from GOGAK g1, GIFT g2
 where g1.POINT between g2.G_START and g2.G_END; 
  
--연습문제) 위 테이블을 사용하여 각 고객이 가져갈 수 
--있는 모든 상품 목록을 출력
select g1.GNAME AS 고객이름, 
       g2.GNAME AS 상품명
  from GOGAK g1, GIFT g2
 where g1.POINT >= g2.G_START
 order by 1;
 
--연습문제) 위 문제에서 준비할 상품의 최대 개수를
--상품이름과 함께 출력하되,
--각 상품별 최소 포인트 조건과 최대 포인트 조건을
--함께 출력하세요.
select g2.GNAME AS 상품명,
       count(g1.gno) AS 개수,
       g2.G_START,
       g2.G_END
  from GOGAK g1, GIFT g2
 where g1.POINT >= g2.G_START
 group by g2.GNAME, g2.G_START, g2.G_END;

  
  
  
  