-- 공유폴더 접속
--\\192.168.0.115
--ID : kitcoop
--PW : 없음(그냥 엔터)

-- 샘플 스키마(아래 테이블들이 생성됌)
--scott : emp, dept
--hr : employees

-- [ 단축키 ] 
-- 파일열기 : ctrl + o
-- 대문자 변경 : ctrl + shift + u
-- 소문자 변경 : ctrl + u

-- between A and B : A와 B사이 반환
-- A와 B는 포함, A가 더 작은 값이어야 함

select *
  from emp
 where sal between 1000 and 2000;

-- in : 포함연산자, 여러값과 일치하는 행을 리턴
select * 
  from student
 where GRADE in (1,2);

select * 
  from student
 where NAME in ('이윤나','김진욱');

-- null 조건
select *
  from emp
 where COMM is null;

select *
  from emp
 where COMM is not null;
 
-- like : 패턴 연산자 
-- % : 자리수 제한 없는 모든
-- _ : 한 자리수 모든

--예제) emp테이블에서 이름이 S로 시작하는 직원 출력
select *
  from emp
 where ename like 'S%';
 
--예제) student 테이블에서 이름의 두번째 글자가 '진'인
--      학생 정보 출력
select *
  from student
 where name like '%진%';

select *
  from student
 where name like '_진%';

-- 부정 연산자
select *
  from student
 where grade != 4;
 
-- 예제) student 테이블에서 3,4학년이 아닌 학생
select *
  from student
 where grade != 3
   and grade != 4;
 
select *
  from student
 where grade not in (3,4);
 
--예제) student에서 몸무게가 50 ~ 60이 아닌 학생 출력
select *
  from student
 where weight not between 50 and 60;

select ename, sal, sal * 1.1 AS "10% 인상된 연봉"
  from emp;
  
--예제) emp에서 10% 인상된 연봉이 3000이하인 직원 선택  
select ename, sal, sal * 1.1 AS "10% 인상된 연봉"
  from emp
 where sal * 1.1 <= 3000; 
 
--연습문제1) EMP 테이블에서 급여가 1100 이상이거나, 
--이름이 M으로 시작하지 않는 사원 출력 
select *
  from emp
 where sal >= 1100
    or ename not like 'M%';
  
--연습문제2) EMP 테이블에서 JOB이 Manager, Clerk, 
--Analyst가 아닌 사원 출력
select *
  from emp
 where initcap(JOB) not in ('Manager', 
                            'Clerk', 
                            'Analyst');
 
--연습문제3) EMP 테이블에서 JOB이 PRESIDENT이고 
--급여가 1500 이상이거나 업무가 SALESMAN인 사원 출력
select *
  from emp
 where (job = 'PRESIDENT'
   and sal >= 1500)
    or job = 'SALESMAN';
 
select *
  from emp
 where job = 'PRESIDENT'
   and (sal >= 1500
    or job = 'SALESMAN');

select *
  from emp
 where job in ('PRESIDENT', 'SALESMAN')
   and sal >= 1500;
    
-- A and (B or C)
-- (A and B) or (A and C)

-- order by절 : 정렬
select *
  from emp
 order by DEPTNO asc;

select *
  from emp
 order by DEPTNO desc;

select *
  from emp
 order by DEPTNO, SAL desc;

-- select절에서 정의된 컬럼 별칭의 재사용
select ename, deptno AS 부서번호, sal * 1.1
  from emp
 where 부서번호 = 10;  -- 불가

select ename, deptno AS 부서번호, sal
  from emp
 order by 부서번호;    -- 가능
  
select ename, deptno AS 부서번호, sal
  from emp
 order by 1,2;  -- select절에 나열된 컬럼 순서로 정렬


-- 날짜 상수의 전달
alter session set nls_date_format='RR/MM/DD';

-- 저장된 날짜 포맷 : 'YYYY/MM/DD'
-- 출력 날짜 포맷   : 'YYYY/MM/DD HH24:MI:SS'

select *
  from emp
 where HIREDATE = '1980/12/17';
 
-- 1980/12/17일 이전에 입사한 사원 출력
select *
  from emp
 where HIREDATE < '1980/12/17';

select *
  from emp
 where to_char(HIREDATE, 'YYYY/MM/DD HH24:MI:SS')
       = '1981/02/20 00:00:00';

-- 함수
--함수란 : input value에 따라 output value가 달라지는
--         input과 output의 관계를 정의한 객체
       

--단일행 함수 : 1개의 input이 1개의 output return

--복수행 함수(그룹함수) : 여러개의 input이 
--                        1개의 output return
select ename, lower(ename)
  from emp;
  
select sum(sal)
  from emp;

-- 대소치환함수 : initcap, upper, lower
select 'abc def', 
       initcap('abc def')
  from dual;

select 'abc def', 
       initcap('abc def', 'aaa')
  from dual;

-- substr : 문자열 추출 함수
-- substr(대상,추출위치[,추출개수])
select 'abcde', 
       substr('abcde',1,2),
       substr('abcde',3,1),
       substr('abcde',3),
       substr('abcde',-2)
  from dual;

--예제) emp테이블에서 두번째 이름이 M인 직원 추출
select *
  from emp
 where ENAME like '_M%';

select *
  from emp
 where substr(ename,2,1) ='M';
 
-- 연습문제) student 테이블에서 여학생이면서
-- 생년월일이 1975년 7월 1일 이후에 태어난 학생 추출

select * 
  from student
 where BIRTHDAY > '1975/07/01'
   and JUMIN like '______2%';
   
select * 
  from student
 where BIRTHDAY > '1975/07/01'
   and substr(JUMIN,7,1) = '2';  
   
--연습문제) student 테이블에서 78년에 태어난 학생 추출
select *
  from student
 where substr(jumin,1,2) = '78' ;

alter session set nls_date_format='YY/MM/DD';

select name, BIRTHDAY, substr(BIRTHDAY,1,2)
  from student
 where substr(BIRTHDAY,1,2) = '78'; 

select name, BIRTHDAY, substr(BIRTHDAY,1,2)
  from student
 where BIRTHDAY like '78%';  
 
alter session set nls_date_format='YYYY/MM/DD'; 

select name, BIRTHDAY, substr(BIRTHDAY,1,2)
  from student
 where BIRTHDAY like '1978%';  
  
select name, BIRTHDAY
  from student
 where BIRTHDAY between '1978/01/01' and '1978/12/31';  

alter session set nls_date_format='RR/MM/DD';
-- '78/01/01' => '1978/01/01'

alter session set nls_date_format='YY/MM/DD';
-- '78/01/01' => '2078/01/01'

select name, BIRTHDAY
  from student
 where BIRTHDAY between '1978/01/01' and '1978/12/31';  

select name, BIRTHDAY
  from student
 where BIRTHDAY between '78/01/01' and '78/12/31';  


-- instr : 원본문자열에서 특정문자열의 위치값 리턴
-- instr(원본문자열,특정문자열[,위치][,발견횟수])
select 'ababba',
       instr('ababba','a',1,3),
       instr('ababba','a',1),
       instr('ababba','a'),
       instr('ababba','A'),
       instr('ababba','a',-4,2)
  from dual;

select tel, substr(tel,1,3)
  from student;

-- 연습문제) student 테이블에서 지역번호만 추출
-- 055)381-2158  => 055
-- 02)6255-9875  => 02

select tel,
       instr(tel,')'),
       substr(tel,
              1,
              instr(tel,')')-1)
  from student;


 
 
 
 
 