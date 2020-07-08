--1) student테이블에서 각 학생의 이름, 제1전공학과명을 
--출력하고 담당지도교수 이름과 지도교수의 소속 학과명도 
--함께 출력하여라. 단, 지도교수가 없는 학생도 모두 출력.
d(+) - p(+) - s - d;

select s.name as 학생이름, d1.dname as 제1전공명,
       p.name as 지도교수이름, d2.dname as 교수학과
  from student s, department d1,
       professor p, department d2
  where s.deptno1 = d1.deptno
    and s.profno = p.profno(+)
    and p.deptno = d2.deptno(+);
    
select s.name as 학생이름, d1.dname as 제1전공명,
       p.name as 지도교수이름, d2.dname as 교수학과
  from department d1 join student s
    on s.deptno1 = d1.deptno
       left outer join professor p
    on s.profno = p.profno
       left outer join department d2
    on p.deptno = d2.deptno;


--2) student 테이블과 exam_01, department 테이블을 
--이용하여 각 학과별 평균 점수와 최고 점수, 최저 점수를 
--나타내되 학과이름(제1전공), 학과번호와 함께 출력.
d - s - e ;
select d.dname, d.deptno, 
       avg(e.total), min(e.total), max(e.total)
  from student s, exam_01 e, department d
 where s.studno = e.studno
   and s.deptno1 = d.deptno
 group by d.dname, d.deptno;
 
select d.dname, d.deptno, 
       avg(e.total), min(e.total), max(e.total)
  from student s join exam_01 e
    on s.studno = e.studno
       join department d
    on s.deptno1 = d.deptno
 group by d.dname, d.deptno; 

--3) emp2 테이블에서 각 직원과 나이가 같으면서 
--취미가 같은 직원의 수를 직원의 이름, 부서이름, 취미, 
--pay와 함께 출력하여라.
d - e1 - e2(+);
select e1.name as 직원이름, e1.birthday, 
       e1.hobby, e1.pay, d.dname,
       count(e2.name) as 친구수
  from emp2 e1, emp2 e2, dept2 d
 where e1.hobby = e2.hobby(+)
   and to_char(e1.birthday, 'yyyy') = 
       to_char(e2.birthday(+), 'yyyy')
   and e1.empno != e2.empno(+)
   and e1.deptno = d.dcode
 group by e1.empno, e1.name, e1.birthday, 
          e1.hobby, e1.pay, d.dname
 order by e1.empno;

select e1.name as 직원이름, e1.birthday, 
       e1.hobby, e1.pay, d.dname,
       count(e2.name) as 친구수
  from emp2 e1 left outer join emp2 e2
    on (e1.hobby = e2.hobby
   and to_char(e1.birthday, 'yyyy') = 
       to_char(e2.birthday, 'yyyy')
   and e1.empno != e2.empno)
       join dept2 d
   on  e1.deptno = d.dcode
 group by e1.empno, e1.name, e1.birthday, 
          e1.hobby, e1.pay, d.dname
 order by e1.empno;         
          
--4) emp 테이블을 이용하여 본인과 상위관리자의 
--평균연봉보다 많은 연봉을 받는 직원의
--이름, 부서명, 연봉, 상위관리자명을 출력하여라.
select e1.ename as 직원이름, e1.sal, d.dname,
       e2.ename as 매니저이름, e2.sal,
       (e1.sal + nvl(e2.sal, e1.sal))/2 as 평균연봉
  from emp e1, emp e2, dept d
 where e1.mgr = e2.empno(+)                         -- e1과 e2의 관계중 이 조건만 아우터조인 필요
   and e1.sal >= (e1.sal + nvl(e2.sal, e1.sal))/2   -- 이 조건은 아우터 조인 필요 없음
   and e1.deptno = d.deptno;

select e1.ename as 직원이름, e1.sal, d.dname,
       e2.ename as 매니저이름, e2.sal,
       (e1.sal + nvl(e2.sal, e1.sal))/2 as 평균연봉
  from emp e1 join emp e2                            -- e1과 e2를 left outer join을 걸면 각 직원의 연봉이 상위관리자와의 평균 연봉보다 높은 조건에 만족하지 않아도 모두 출력됌
    on (e1.mgr = e2.empno
   and e1.sal >= (e1.sal + nvl(e2.sal, e1.sal))/2)
       join dept d
    on e1.deptno = d.deptno;

---------- 여기까지는 복습입니다. ----------

-- 서브쿼리
--1. where절에 사용되는 서브쿼리
--1) 단일행 서브쿼리 : 서브쿼리의 결과가 단일행(한 컬럼)
select *
  from emp
 where sal > (select sal
                from emp
               where ename = 'ALLEN');

--예제) ALLEN의 부서와 같은 부서에 속한 직원 정보 출력
select deptno
  from emp
 where ename = 'ALLEN';

select *
  from emp
 where deptno = 30;

select *
  from emp
 where deptno = (select deptno
                   from emp
                  where ename = 'ALLEN');
                  
--2) 다중행 서브쿼리 : 서브쿼리의 결과가 여러행(한 컬럼)
-- where절에 사용되는 연산자에 =, 대소비교 사용 불가

--연습문제) 이름이 M으로 시작하는 직원과 같은 부서에
--있는 직원을 모두 출력(이름이 M으로 시작하는 직원포함)
select deptno 
  from emp
 where ENAME like 'M%';

select *
  from emp
 where deptno in (select deptno 
                    from emp
                   where ENAME like 'M%');
                   
--예제) 이름이 M으로 시작하는 직원의 연봉보다 높은 
--직원 출력
select *
  from emp
 where sal > (select avg(sal)          -- min, max 
                from emp
               where ENAME like 'M%'); --1250,1300

-- 단일행 연산자(>)에 맞게 서브쿼리 수정(1개 행 리턴)
select *
  from emp
 where sal > (select max(sal)          --1300    
                from emp
               where ENAME like 'M%');

-- 다중행 서브쿼리에 맞게 연산자 수정(ALL)
select *
  from emp
 where sal > all(select sal             --1300    
                   from emp
                  where ENAME like 'M%');
  
 > all(1250,1300)  <=>   > 1300  : 최대값 리턴
 < all(1250,1300)  <=>   < 1250  : 최소값 리턴
 
 > any(1250,1300)  <=>   > 1250  : 최소값 리턴
 < any(1250,1300)  <=>   < 1300  : 최대값 리턴 
;

--연습문제) 학생테이블에서 4학년 학생 중 키가 가장 작은
--학생보다 작은 학생을 출력하세요
select HEIGHT
  from STUDENT
 where grade = 4;
 
select *
  from STUDENT
 where height < (select min(HEIGHT)
                   from STUDENT
                  where grade = 4);

select *
  from STUDENT
 where height < all(select HEIGHT
                      from STUDENT
                     where grade = 4);
                     
--3) 다중컬럼 서브쿼리 : 서브쿼리 출력 결과가 여러 컬럼
-- 그룹내 대소 비교 불가 => 상호연관, 인라인뷰 대체

--예제) emp 테이블에서 각 부서별 최대 연봉과 함께
--      각 부서별 최대 연봉을 갖는 직원 이름 출력
select deptno, max(sal)
  from emp
 group by deptno;

select *
  from emp
 where (deptno, sal) in (select deptno, max(sal)
                           from emp
                          group by deptno);

--연습문제) PROFESSOR 테이블에서 각 position별
--가장 먼저 입사한 사람의 이름, 입사일, position,
--pay 출력
select POSITION, min(HIREDATE)
  from PROFESSOR
 group by POSITION;
 
 select NAME, HIREDATE, POSITION, PAY 
   from PROFESSOR
  where (POSITION, HIREDATE) in (select POSITION, 
                                        min(HIREDATE)
                                   from PROFESSOR
                                   group by POSITION);
 
--예제) emp 테이블에서 각 부서별 평균연봉보다 높은
--연봉을 받는 직원의 정보 출력
select *
  from EMP
 where (deptno, sal) > (select deptno, avg(sal)
                          from emp
                         group by deptno); 
                     -- 에러, 다중컬럼 대소비교 불가

select *
  from EMP
 where deptno in (select deptno
                   from emp
                  group by deptno)
   and sal > (select avg(sal)
                from emp
               group by deptno);

--4) 상호연관 서브쿼리 : 메인쿼리와 서브쿼리의 조건 결합

--2. from절에 사용되는 서브쿼리(인라인뷰)
select * 
  from emp e, (select deptno, avg(sal) AS avg_sal
                 from emp
                group by deptno) i
 where e.DEPTNO = i.DEPTNO
   and e.SAL > i.avg_sal;

--연습문제) STUDENT 테이블에서 같은 성별내에
--평균몸무게보다 작은 학생의 이름, 성별, 학년, 몸무게
--출력
select NAME, 
       decode(substr(s.JUMIN,7,1),'1','남','여') AS 성별,
       GRADE, WEIGHT
  from STUDENT s, (select substr(JUMIN,7,1) AS gender, 
                          avg(weight) AS avg_weight
                     from STUDENT
                    group by substr(JUMIN,7,1)) i
 where substr(s.JUMIN,7,1) = i.gender
   and s.WEIGHT < i.avg_weight;

