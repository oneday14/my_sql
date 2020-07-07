--1. EMP2 테이블에서 출생년도(1960,1970,1980,1990)별로 
--평균연봉을 구하라.
select trunc(to_char(BIRTHDAY,'YYYY'), -1), 
       round(avg(PAY))
  from emp2
 group by trunc(to_char(BIRTHDAY,'YYYY'), -1);
 
--2. emp2 테이블과 p_grade 테이블을 조회하여 사원들의 
--이름과 나이, 현재직급, 예상직급을 출력하세요. 
--예상직급은 나이로 계산하며 소수점이하는 생략하세요.
select e.name, 
       e.position as 현재직급, 
       p.position as 예상직급,
       trunc((sysdate - e.birthday)/365) as 나이1,
       2020 - to_char(e.birthday,'yyyy') as 나이2
  from emp2 e, p_grade p
 where trunc((sysdate - e.birthday)/365) 
       between p.s_age and p.e_age;
  
--3. STUDENT 테이블과 PROFESSOR 테이블을 사용하여
--3,4학년 학생의 지도교수 정보를 함께 출력하여
--각 지도교수별 지도학생이 몇명인지에 대한 정보를
--교수이름, 직급과 함께 출력하여라.
select p.NAME AS 교수이름, p.POSITION, p.PAY, p.HIREDATE,
       count(s.name) AS 학생수
  from STUDENT s, PROFESSOR p
 where s.PROFNO = p.PROFNO
   and s.GRADE in (3,4)
 group by p.PROFNO, p.NAME, p.POSITION, p.PAY, p.HIREDATE;

--4. 레포트를 작성하고자 한다.
--emp 테이블을 이용하여 각 부서별 직원수를 출력하되 다음과 같은 형식으로 작성하여라.
--
--레포트명	       10_직원수	 20_직원수	  30_직원수
----------------------------------------------------------
--본인이름 레포트	        3	         5           6

select deptno, count(empno)
  from emp
 group by deptno;
 
select '김현지 레포트' AS 레포트명, 
       sum(decode(deptno,10,1)) AS "10_직원수",
       count(decode(deptno,20,'있다')) AS "20_직원수",
       count(decode(deptno,30,1)) AS "30_직원수"
  from emp;

---------- 여기까지는 복습입니다. ----------

-- 3개 이상 테이블 조인 예제
--예제) STUDENT과 PROFESSOR, DEPARTMENT 테이블을 조인하여
--3,4학년 학생에 대해 각 학생의 이름, 제1전공명,
--지도교수 이름을 함께 출력
-- d - s - p 
select s.NAME, s.GRADE, d.DNAME, p.NAME
  from STUDENT s, PROFESSOR p, DEPARTMENT d
 where s.DEPTNO1 = d.DEPTNO
   and s.PROFNO = p.PROFNO
   and s.GRADE in (3,4);
   

--연습문제) STUDENT, EXAM_01, HAKJUM 테이블을 사용하여
--각 학생의 이름, 시험점수, 학점을 출력하여라
s(studno) - e(studno, total) - h(min_point,max_point);

select s.NAME, e.TOTAL, h.GRADE 
  from STUDENT s, EXAM_01 e, HAKJUM h
 where s.STUDNO = e.STUDNO
   and e.TOTAL between h.MIN_POINT and h.MAX_POINT;

--연습문제) 위 데이터를 활용하여 각 학점별 학생수 출력
--단, 학점은 A,B,C,D로 묶어서 출력
select substr(h.GRADE,1,1) AS 학점,
       count(s.STUDNO) AS 학생수, 
       avg(e.TOTAL) AS 평균점수
  from STUDENT s, EXAM_01 e, HAKJUM h
 where s.STUDNO = e.STUDNO
   and e.TOTAL between h.MIN_POINT and h.MAX_POINT
 group by substr(h.GRADE,1,1);


-- 똑같은 테이블의 중복 조인 예제
d(deptno) - s(deptno1, profno) - p(profno, deptno) - d(deptno)
;
select s.name, s.grade, s.DEPTNO1, d1.DNAME,
       p.name, p.DEPTNO, d2.DNAME
  from STUDENT s, PROFESSOR p, 
       DEPARTMENT d1, DEPARTMENT d2
 where s.PROFNO = p.PROFNO
   and s.DEPTNO1 = d1.DEPTNO
   and p.DEPTNO = d2.DEPTNO
   and s.GRADE in (3,4);


-- outer join
--- inner join의 반대
--- 조인 조건에 맞지 않는 데이터도 출력 가능
--- 기준이 되는 테이블 방향에 따라
--  1) left outer join : 왼쪽 테이블 기준
--  2) right outer join : 오른쪽 테이블 기준
--  3) full outer join : 양쪽 테이블 기준

--예제) 각 학생의 이름, 지도교수 이름을 출력하되,
--지도교수가 없는 학생까지 전부 출력
select s.name AS 학생이름,
       p.name AS 교수이름
  from STUDENT s, PROFESSOR p
 where s.PROFNO = p.PROFNO(+);
  
select s.name AS 학생이름,
       p.name AS 교수이름
  from STUDENT s left outer join PROFESSOR p
    on s.PROFNO = p.PROFNO;

select s.name AS 학생이름,
       p.name AS 교수이름
  from PROFESSOR p right outer join STUDENT s
    on s.PROFNO = p.PROFNO;

--예제) STUDENT과 PROFESSOR의 full outer join 수행
select s.name AS 학생이름, p.name AS 교수이름
  from STUDENT s full outer join PROFESSOR p
    on s.PROFNO = p.PROFNO;

select s.name AS 학생이름, p.name AS 교수이름
  from STUDENT s, PROFESSOR p
 where s.PROFNO(+) = p.PROFNO(+); -- 에러발생
 
select s.name AS 학생이름, p.name AS 교수이름
  from STUDENT s, PROFESSOR p
 where s.PROFNO(+) = p.PROFNO
 union 
select s.name AS 학생이름, p.name AS 교수이름
  from STUDENT s, PROFESSOR p
 where s.PROFNO = p.PROFNO(+); 

--연습문제) STUDENT, DEPARTMENT테이블을 사용하여
--각 학생의 이름, 제2전공명, 학년을 함께 출력
select s.NAME, s.GRADE, d.DNAME
  from STUDENT s, DEPARTMENT d
 where s.DEPTNO2 = d.DEPTNO(+);
 
select s.NAME, s.GRADE, d.DNAME
  from STUDENT s left outer join DEPARTMENT d
    on s.DEPTNO2 = d.DEPTNO;

-- 순환 구조를 갖는 경우의 outer join
-- 예제) 각 학생의 이름, 학년, 지도교수이름과
--       지도교수의 소속 학과명을 함께 출력하세요
s - p(+) - d(+) - p2(+);

s - p(+) - d(+)
|
d;

select s.NAME AS 학생이름, s.grade, 
       p.name AS 교수이름, d.DNAME
  from STUDENT s, PROFESSOR p, DEPARTMENT d
 where s.PROFNO = p.PROFNO(+)
   and p.DEPTNO = d.DEPTNO(+);
  
-- self join : 하나의 테이블을 여러번 조인하는 경우
-- 한번의 스캔으로 동시 출력 불가능한 정보를 
-- 동일 테이블을 중복 스캔했을 경우 출력 가능한 경우

-- 예제) emp 테이블을 사용하여 각 직원의 이름, sal,
-- 상위관리자의 이름, sal을 동시 출력
select e1.ENAME AS 본인이름,
       e2.ENAME AS 상위관리자이름
  from emp e1, emp e2
 where e1.MGR = e2.EMPNO(+);

--연습문제) DEPARTMENT 테이블을 사용하여
--각 학과명과 상위학과명을 동시 출력,
--단 상위학과가 없는 경우도 출력
select d1.DNAME AS 학과명, 
       d2.DNAME AS 상위학과명
  from DEPARTMENT d1, DEPARTMENT d2
 where d1.PART = d2.DEPTNO(+);
 
--예제) 위 결과에서 상위학과가 없는 경우
--상위학과 이름은 원래 학과 이름을 출력
select d1.DNAME AS 학과명, 
       nvl(d2.DNAME, d1.DNAME) AS 상위학과명
  from DEPARTMENT d1, DEPARTMENT d2
 where d1.PART = d2.DEPTNO(+);
 
--연습문제) professor 테이블에서 교수의 번호, 교수이름, 
--입사일, 자신보다 입사일 빠른 사람 인원수를 출력     
--단, 자신보다 입사일이 빠른 사람수를 오름차순으로 출력
select p1.PROFNO, p1.NAME, p1.HIREDATE,
       count(p2.PROFNO) AS 선배수 
  from PROFESSOR p1, PROFESSOR p2
 where p1.HIREDATE > p2.HIREDATE(+)
 group by p1.PROFNO, p1.NAME, p1.HIREDATE
 order by p1.NAME;
 
--연습문제) STUDENT 테이블에서 각 학생의 이름,학년,
--키를 출력, 같은 학년내에 각 학생보다 키가 큰 학생 수
--함께 출력
select s1.NAME, s1.GRADE, s1.HEIGHT,
       count(s2.STUDNO) AS "키가 큰 학생수"
  from STUDENT s1, STUDENT s2
 where s1.GRADE = s2.GRADE(+)
   and s1.HEIGHT < s2.HEIGHT(+)
 group by s1.STUDNO, s1.NAME, s1.GRADE, s1.HEIGHT
 order by s1.NAME;

-- 서브쿼리(sub-query) : 쿼리 안의 쿼리
--  ** 뷰 : 테이블처럼 저장공간을 갖진 않지만 
--          테이블처럼 조회가 가능한(미리보기) 객체
--          
select col1, (select ...)        -- 스칼라 서브쿼리
  from tab1, tab2, (select ...)  -- 인라인 뷰**
 where col1 = (select ...)       -- 서브쿼리
;

--예제) emp 테이블에서 ALLEN보다 SAL이 낮은 사람 출력
select *
  from emp
 where SAL < 1600;
 
select *
  from emp
 where SAL < (select SAL
                from emp
               where ENAME = 'ALLEN');  -- CTRL + l
