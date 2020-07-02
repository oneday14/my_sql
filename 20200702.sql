--1. student 테이블에서 10월에 태어난 학생의
--이름, 학년, 생년월일을 출력하되
--태어난 일이 작은순서대로 정렬하여라.
select *
  from student
 where JUMIN like '__10%';
 
select *
  from student
 where substr(JUMIN,3,2) = '10'; 
 
-- 1975/10/23 00:00:00  => substr(BIRTHDAY,6,2)
-- 75/10/23             => substr(BIRTHDAY,4,2)
select name, birthday, substr(BIRTHDAY,4,2)
  from STUDENT 
 where substr(BIRTHDAY,4,2) = '10';
 
alter session set nls_date_format='YYYY/MM/DD';
select name, birthday, substr(BIRTHDAY,6,2) AS 월
  from STUDENT 
 where substr(BIRTHDAY,6,2) = '10'
 order by substr(BIRTHDAY,-2);
 
--2. student 테이블에서 각 학생의 국번 추출
--051)426-1700  => 426
--02)6255-9875  => 6255
select NAME, 
       TEL,
       instr(TEL,')') AS ")의 위치",
       instr(TEL,'-') AS "-의 위치",
       substr(tel,
              instr(tel,')') + 1,
              instr(TEL,'-') - instr(TEL,')') - 1)
  from STUDENT;

--3. student 테이블에서 성이 'ㅅ'인 학생의 
--학번, 이름, 학년을 출력하여라
select *
  from student
 where NAME > '사'
   and name < '아';

--4. EMPLOYEES 테이블에서 대소를 구분하지 않고 
--email에 last_name이 포함되어 있지 않은 
--사람의 EMPLOYEE_ID, FIRST_NAME, EMAIL을 출력하여라.
--(EMPLOYEES 테이블은 hr 계정에서 조회 가능)
select * 
  from employees
 where instr(EMAIL,upper(LAST_NAME)) = 0;

select *
  from EMPLOYEES
 where EMAIL not like '%'||upper(LAST_NAME)||'%';
 
--OConnell DOCONNEL (X)
--Grant DGRANT (O)
--Whalen JWHALEN (O)
--De Haan LDEHAAN (X)

---------- 여기까지는 복습입니다. ----------

-- length : 문자열의 길이 출력
select ename, length(ename)
  from emp;

select name, 
       length(name) AS "글자수",
       lengthb(name) AS "Byte size"
  from STUDENT;

-- lpad, rpad : 문자열의 삽입
-- lpad(대상,총길이[,삽입문자])
select 'abcd',
       lpad('abcd',5,'!'),
       rpad('abcd',5,'!'),
       length(rpad('abcd',5))
  from dual;
  
-- ltrim, rtrim, trim : 문자열의 제거
-- ltrim(대상[,제거할문자])
-- trim(대상)
select 'ababa',
       ltrim('ababa','a'),
       rtrim('ababa','a'),
       length(rtrim('ababa ')),
       length(trim('   ababa '))
  from dual;

-- [ 테스트 - 문자열에 불필요한 공백 삽입시 조회되지 X ]
create table test1(col1 varchar2(5),
                   col2 char(5));

insert into test1 values('ab','ab');
commit;

select *
  from test1
 where COL1 = COL2;   -- 각각 'ab' 'ab   '로 저장되어
                      -- 일치하지 않아 조회되지 않음

select *
  from test1
 where COL1 = trim(COL2);
 
select length(col1), length(col2)
  from test1;

-- replace : 치환함수
-- replace(대상,찾을문자열,바꿀문자열)
select 'abcba',
       replace('abcba','ab','AB'),
       replace('abcba','c',''),
       replace('ab c ba',' ','')
  from dual;

-- translate : 치환함수(번역)
-- translate(대상,찾을문자열,바꿀문자열)
select 'abcba',
       replace('abcba','ab','AB'),
       translate('abcba','abc','ABC'),
       translate('abcba','!ab','!'),
       translate('abcba','ab','ABC')       
  from dual;

--연습문제) PROFESSOR테이블에서 교수 아이디에서 
--          특수문자 모두 제거 후 출력
select id, 
       replace(replace(id,'-',''),'_',''),
       translate(id,'a-_','a')
  from PROFESSOR;

--연습문제) emp 테이블에서 급여를 모두 동일한 자리수로
--출력
select sal, lpad(sal,4,0) 
  from emp;

--연습문제) STUDENT 테이블에서 이름의 두번째 글자를
--#처리
select name, replace(NAME,
                     substr(NAME,2,1),
                     '#')
  from STUDENT;


-- 숫자함수
-- round : 반올림
-- trunc : 내림
select 1234.56,
       round(1234.56,1),  -- 소수점 두번째에서 반올림
       round(1234.56),    -- 소수점 첫번째에서 반올림
       trunc(1234.56,1),  -- 소수점 두번째에서 내림
       round(1234.56,-3)  -- 백의 자리에서 반올림
  from dual;
  
select ename, sal, trunc(sal * 1.15) AS "15%인상된 SAL"
  from emp;
  
-- mod : 나머지
select 7/3,
       trunc(7/3) AS 몫,
       mod(7,3) AS 나머지
  from dual;
  
-- floor : 값보다 작은 최대정수
-- ceil : 값보다 큰 최소정수
select 2.33,
       floor(2.33) AS "값보다 작은 최대정수",
       ceil(2.33) AS "값보다 큰 최소정수"
  from dual;

-- abs : 절대값
select -2.3,
       abs(-2.3)
  from dual;
  
-- sign : 부호판별
select sign(1.1),
       sign(-1.1),
       sign(0)
  from dual;
  
-- 날짜 함수
-- sysdate : 현재날짜 및 시간
select sysdate
  from dual;

select sysdate + 100
  from dual;

select ename, 
       trunc(sysdate - hiredate) as 근무일수
  from emp;
  
--연습문제) emp 테이블에서 각 사원의 현재 날짜 기준
--퇴직금을 계산하여라
--퇴직금 = 기본급(sal) / 12 * 근속년수
select ename, sal, hiredate,
       trunc(sysdate - hiredate) AS 근무일수,
       trunc(trunc(sysdate - hiredate)/365) AS 근속년수,
       trunc((sysdate - hiredate)/365) AS 근속년수,
       trunc(sal / 12 * trunc((sysdate - hiredate)/365))
       AS 퇴직금
  from emp;

-- months_between : 두 날짜 사이 개월수 리턴
select ename, hiredate,
       sysdate - hiredate AS 근무일수,
       months_between(sysdate,hiredate),
       trunc((sysdate - hiredate)/365) AS 근속년수,
       trunc(months_between(sysdate,hiredate) / 12)
       AS 근속년수2
  from emp;

select sysdate, 
       sysdate + 3*31,       -- 부정확한 3개월 뒤 날짜
       add_months(sysdate,3) -- 정확한 3개월 뒤 날짜
  from dual;

--next_day : 바로 뒤에 오는 특정 요일의 날짜 리턴
-- 1 : 일요일, 2 : 월요일, .....
select sysdate,
       next_day(sysdate,1),
       next_day(sysdate,'월')
  from dual;

alter session set nls_date_language='american';
select sysdate,
       next_day(sysdate,1),
       next_day(sysdate,'mon')
  from dual;
  
alter session set nls_date_format='MM/DD/YYYY';
select sysdate from dual;  --2020/07/02 14:21:38
  
-- last_day : 해당 날짜가 속한 달의 마지막 날짜 리턴
select sysdate,
       last_day(sysdate)
  from dual;
  
--문제1) EMP 테이블에서 현재까지 근무일수가 
--몇 주, 몇 일인가를 출력하여라.
--단, 근무일수가 많은 사람 순으로 출력하여라.   
select ename, 
       trunc(sysdate - hiredate) AS 근무일수,
       trunc((sysdate - hiredate)/7) AS 근무주수,
       mod(trunc(sysdate - hiredate),7) AS 나머지일수 
  from emp;

--문제4) EMP 테이블에서 10번 부서원의 입사일자로부터 
--돌아오는 금요일을 계산하여 출력하여라. 
select ename, hiredate, next_day(hiredate,'fri')
  from emp
 where deptno = 10;
 
-- 변환함수 : 데이터의 타입을 변환
--1. to_char : 문자가 아닌 값을 문자로 변환
-- 1) 숫자 -> 문자
--     - 1000 -> 1,000
--     - 1000 -> $1000
-- 2) 날짜 -> 문자
--     - 1981/06/09 -> 06
--     - 1981/06/09 -> 81-06-09
select 1000,
       to_char(1000,'9,999'),
       to_char(1000,'999.99'),  -- #######
       to_char(1000,'9999.99'),
       to_char(1000,'99999'),   -- ' 1000'
       to_char(1000,'09999'),   -- '01000'
       to_char(1000,'$9,999'),
       to_char(1000,'9,999')||'\'
  from dual;
  
-- 2020/07/02 15:19:13  => 07/02/2020
select sysdate, 
       to_char(sysdate,'MM/DD/YYYY') 
  from dual;
  
select sysdate, 
       to_char(sysdate,'MM/DD/YYYY') + 1 -- 연산불가
  from dual;

--예제) emp 테이블에서 1981년 2월 22일에 입사한 
--사람 출력
select * 
  from emp
 where to_char(HIREDATE,'MM/DD/YYYY') = '02/22/1981';

select * 
  from emp
 where HIREDATE = to_char('1981/02/22', 'RR/MM/DD');
--     => 에러발생, to_char의 첫번째 인수는 문자 불가
 
--2. to_number : 숫자가 아닌(숫자로 변경 가능한)값을
--               숫자로 변경
               
--3. to_date : 날짜가 아닌 값을 날짜로 변환(파싱) 
select to_date('2020/06/30','YYYY/MM/DD') + 100
  from dual;

select to_date('09/07/2020','MM/DD/YYYY'),
       to_date('09/07/2020','DD/MM/YYYY')
  from dual;
 
select * 
  from emp
 where HIREDATE = to_date('1981/02/22','YYYY/MM/DD'); 
 
select *
  from student
 where to_char(BIRTHDAY,'MM') = '06';
  
 