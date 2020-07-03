-- [ 날짜 기본 문제 ]
-- 1. 2020/01/01로부터 90일 뒤의 날짜의 다음 월요일 리턴
alter session set nls_date_format='MM/DD/YYYY';

select to_date('2020/01/01','YYYY/MM/DD') + 90,
       next_day(to_date('2020/01/01','YYYY/MM/DD')+90,
                '월')
  from dual;

select sysdate - HIREDATE,
       to_date('2019/01/01','YYYY/MM/DD') - HIREDATE
  from emp;

-- to_char(날짜,포맷) : 날짜 포맷 변경
-- to_date(문자/숫자,포맷) : 날짜로 해석(파싱)

-- 예제) 2020/06/30 로부터 150일 뒤의 요일 출력
select to_date('2020/06/30','YYYY/MM/DD') + 150,
       to_char(to_date('2020/06/30','YYYY/MM/DD')+150,
               'Day')
  from dual;

-- 날짜 언어가 영문일 경우 날짜포맷의 대소 구분
alter session set nls_date_language='american';
select to_char(sysdate,'Day'),
       to_char(sysdate,'DAY'),
       to_char(sysdate,'day')
  from dual;

-- 2. student테이블에서 24일에 태어난 학생 출력
select *
  from student
 where to_char(BIRTHDAY,'DD') = '24';

select *
  from student
 where substr(JUMIN,5,2) = '24';

-- 3. professor 테이블에서 2001년 이후에 입사한 교수 출력
select *
  from PROFESSOR
 where to_char(HIREDATE,'YYYY') > '2001';

-- [ 응용 문제 ]
--1. professor 테이블에서 각 교수의 이메일 아이디를 
--출력하되, 특수기호를 제거한 형태로 출력하여라.
select EMAIL,
       substr(email,
              1,
              instr(email,'@')-1) AS email_id,
       translate(substr(email,1,instr(email,'@')-1),
                 '1_-!@#$%^&*','1') AS 삭제된ID
  from PROFESSOR;
  
--2. student 테이블에서의 tel을 다음의 형태로 변경
-- 055)381-2158 => 055 381 2158
select name, tel,
       translate(tel,')-','  ')
  from student;
  
--3. emp 테이블을 이용하여 현재까지 근무일수를 
--XX년 XX개월 XX일 형태로 출력하세요.
-- 32일 => 0년, 1개월, 1일
select trunc(months_between(sysdate,hiredate)) AS 근무개월수,
       trunc(trunc(months_between(sysdate,hiredate))/12) AS 근속년수,
       mod(trunc(months_between(sysdate,hiredate)),
           12) AS "나머지 월수",
       trunc(sysdate - 
       add_months(hiredate,
                  trunc(months_between(sysdate,hiredate))))
  from emp;
-- 나머지일수 : sysdate - add_months(입사일, 근무개월수)
 
---------- 여기까지는 복습입니다. ----------

-- 변환함수
--1. to_char 
-- 1) to_char(숫자,숫자포맷)
-- 2) to_char(날짜,날짜포맷)
select sysdate,
       to_char(sysdate,'Day'),    -- 요일
       to_char(sysdate,'month'),  -- 월
       to_char(sysdate,'year'),   -- 년도
       to_char(sysdate,'ddth'),   -- 일의 서수표현
       to_char(sysdate,'ddspth'), -- 일의 영문 서수표현
       to_char(sysdate,'q')       -- 분기
  from dual;

select '91/12/24',
       to_date('91/12/24','YY/MM/DD'), -- 2000년대
       to_date('91/12/24','RR/MM/DD')  -- 1900년대
  from dual;
  
--연습문제) student 테이블에서 jumin컬럼을 사용,
--각 학생의 태어난 날의 요일 출력
select JUMIN,
       substr(JUMIN,1,6) AS 생년월일,
       to_date(substr(JUMIN,1,6),'RRMMDD') AS 생일,
       to_char(to_date(substr(JUMIN,1,6),'RRMMDD'),
               'DAY') AS 요일
  from STUDENT;
  
--2. to_date
-- 1) to_date(문자,날짜포맷)
select '12/05/20',
       to_date('12/05/20','MM/DD/YY')
  from dual;
  
-- 2) to_date(숫자,날짜포맷)
select 120520,
       to_date(120520,'MMDDYY')
  from dual;
  
--3. to_number(문자)
select '1' + 1,
       to_number('1') + 1   --묵시적 형 변환
  from dual;

-- ** 묵시적 형 변환이 발생하는 경우(성능저하)
select *
  from student
 where to_number(to_char(birthday,'MM')) = 12;

-- 형 변환이 필요한 경우 예제
select to_char(3) || '일'  -- 문자열을 필요로 하는 경우
  from dual;               -- 표현식에 to_char 사용


-- 일반함수
--1. decode : if문(조건문)의 축약형태

--[ 보통의 조건문 ]
--if 조건 then 치환
--        else 치환
--if deptno = 10 then '총무부'
--               else '재무부'
--
--=> decode(deptno,10,'총무부','재무부')

--예제) emp 테이블에서 10번 부서는 총무부, 20번 재무부,
--      30번은 인사부로 리턴
select deptno, decode(deptno,10,'총무부',
                             20,'재무부',
                             30,'인사부',
                                '기타부서') AS 부서명
  from emp;
      
-- 연습문제) student 테이블을 사용하여
-- 4학년 학생의 이름, 제1전공명을 출력하라
-- 단, 101번은 경영, 102번은 경제, 103번은 수학,
-- 나머지는 기타로 출력
select name, deptno1,
       decode(deptno1,101,'경영',102,'경제',
                      103,'수학','기타') AS 전공명
  from STUDENT
 where grade = 4;
     
--예제) emp 테이블에서 10번 부서이면서 job이 'PRESIDENT'
--      이면 사장, 그외 job은 staff, 그외부서는 기타로
--      출력
--      
select deptno, job,
       decode(deptno,
              10, decode(job,'PRESIDENT','사장','staff'),
              '기타')
  from emp;

-- deptno = 10 and job = 'PRESIDENT'  => '사장'
-- deptno = 10 and job != 'PRESIDENT' => 'staff'
-- deptno != 10                       => '기타'


--2. case : 조건문
--[ case 기본 문법 ]
--case when 조건1 then 리턴1
--     when 조건2 then 리턴2
--                else 리턴3  -- else 생략시 NULL 리턴
-- end

--예제) 위 deptno를 활용한 부서명 출력
select deptno,
       case when deptno = 10 then '총무부'
            when deptno = 20 then '재무부'
                             else '인사부' 
        end AS 부서명
  from emp;
 
--[ case 축약 문법 - equal 비교일때만 ]
--case 대상 when 상수1 then 리턴1
--          when 상수2 then 리턴2
--                     else 리턴3 
-- end

select deptno,
       case deptno when 10 then '총무부'
                   when 20 then '재무부'
                           else '인사부' 
        end AS 부서명
  from emp;

--연습문제) STUDENT테이블에서 3,4학년 학생에 대해
--이름, 학년, 제1전공번호, 성별을 함께 출력
--단, 성별은 남자, 여자로 표현
select NAME, GRADE, DEPTNO1,
       substr(JUMIN,7,1) AS 성별숫자,
       case when substr(JUMIN,7,1) = '1' then '남자'
                                         else '여자'
        end AS 성별1,
       case substr(JUMIN,7,1) when '1' then '남자'
                                     else '여자'
        end AS 성별2,
       decode(substr(JUMIN,7,1),'1','남자',
                                    '여자') AS 성별3  
  from STUDENT
 where GRADE in (3,4);

-- 3. null 치환 : nvl, nvl2
--nvl(대상,치환값)
--nvl2(대상, null이 아닐때 치환값, null일때 치환값)

--예제) emp 테이블에서 사원이름, sal, comm값 출력
--단, 현재 comm이 정해지지 않은 사원은 기본으로 100부여
select ename, sal, comm,
       nvl(comm,100) AS new_comm
  from emp;

--예제) emp 테이블에서 사원이름, sal, comm값 출력
--단, 현재 comm이 정해지지 않은 사원은 기본으로 500부여
--comm이 있는 직원은 10% 인상
select ename, sal, comm,
       nvl2(comm,comm*1.1,500) AS new_comm
  from emp;


-- nvl 사용시 주의사항
-- nvl(대상,치환값) : 대상과 치환값이 하나의 컬럼으로
-- 표현되므로 서로 같은 데이터 타입 요구

select ename, sal, comm,
       nvl(comm,'보너스없음')
  from emp;

select ename, sal, comm,
       nvl(comm,0)
  from emp;

select ename, sal, comm,
       nvl(to_char(comm),'보너스없음')
  from emp;
  
select nvl('abc',1)  -- 리턴 데이터타입은 문자
  from dual;         -- 문자안에 숫자 삽입 가능, 정상

select nvl(1,'abc')  -- 리턴 데이터타입은 숫자
  from dual;         -- 숫자 안에 문자 삽입 불가, 에러
  
-- nvl2 사용시 주의사항
-- nvl2(대상,치환1,치환2) : 치환1, 치환2가 같은 컬럼에
--표현되므로 치환1, 치환2의 데이터 타입 일치 필요
select comm,
       nvl2(comm,'보너스있음','보너스없음')
  from emp;

select comm,
       nvl2(comm,'보너스있음',0) -- 문자로 리턴
  from emp; 

select comm,
       nvl2(comm,0,'보너스없음') -- 숫자로 리턴
  from emp;
 
-- 연습문제) PROFESSOR 테이블에서 홈페이지 주소가 없는
-- 교수는 http://www.kic.com/email_id로 출력
-- lamb1@hamail.net  => http://www.kic.com/lamb1
select NAME, HPAGE,
       substr(email,1,instr(email,'@')-1) AS ID,
       nvl(HPAGE,'http://www.kic.com/'||
                  substr(email,1,instr(email,'@')-1))
  from PROFESSOR;

 select name,
        email, 
        nvl(hpage,
            lpad(substr(email, 
                        1,
                        instr(email, 
                              '@')-1),
                 length('http://www.kic.com/')+length(substr(email,
                                                             1,
                                                             instr(email, 
                                                                   '@')-1)),
                 'http://www.kic.com/')) 
   from PROFESSOR;

--연습문제) EMP 테이블에서 JOB이 ANALYST이면 
--급여 증가는 10%이고, CLERK이면 15%, MANAGER이면 20%,
--다른 업무에 대해서는 급여 증가가 없다. 
--사원번호, 이름, 업무, 급여, 증가된 급여를 출력하여라. 
select empno, ename, job, sal,
       decode(job, 'ANALYST', sal*1.1,
                   'CLERK', sal*1.15,
                   'MANAGER', sal*1.2,
                   sal) as new_sal
  from emp;

-- 그룹함수(복수행함수) : 여러개 행이 input,
-- 하나 또는 그룹별 하나 output
-- sum, count, avg, min, max
select sal
  from emp;

select sum(sal)
  from emp;

select DEPTNO, sum(sal)
  from emp
 group by DEPTNO;

select DEPTNO, max(sal), max(hiredate)
  from emp
 group by DEPTNO;

--group by절에 명시되지 않은 컬럼은
--select절에 단독으로 사용할 수 없다
--(그룹정보와 개별정보는 함께 표현 불가능)
