-- [ orange 단축키 ]
-- sql 실행 : ctrl + enter
-- 주석처리 : ctrl + -
-- 주석처리 해제 : ctrl + shift + -
-- sql문 재배치 : ctrl + shift + f
-- 저장 : ctrl + s
  
-- 테이블 : 행과 열의 구조를 갖는 데이터의 저장 단위

-- 1. 테이블 레이아웃 확인
desc emp;

--[ 확인 가능 정보 ]
--1) 컬럼명/컬럼순서
--2) null(아직 정의되지 않은 상태) 여부
--3) 데이터 타입/크기
--  - NUMBER(4) : 4자리 숫자
--  - VARCHAR2(9) : 9 바이트 가변형 문자
--    'abcde'
--  - CHAR(9) : 9 바이트 고정형 문자
--    'abcde    '
--  - DATE : 날짜

-- 문자 > 숫자
-- 문자 컬럼에 숫자 삽입 가능
-- 숫자 컬럼에 문자 삽입 불가

-- [ 조회 언어 : select문 ] 
select           -- 테이블 내 출력을 원하는 컬럼/표현식
  from 테이블명  -- 조회할 데이터가 포함된 테이블명 
 where
 group by
having
 order by
;

select *
  from emp; -- query
  
select empno, ename
  from emp;
  
select empno, ename, sal, sal + 1000, 10000
  from emp;  


-- distinct : 행 중복 제거
select distinct DEPTNO 
  from emp;

select distinct JOB, DEPTNO
  from emp;

select *
  from employees;   -- hr 계정에서 조회가능
  

select empno, 1000, 'a'
  from emp;
  
-- 컬럼 별칭
select empno AS "사원 번호",  -- 
       ename "사원명!",       --
       sal "Salary"           --
  from emp;
  
--Alias 연습문제 1 : 
--DEPT 테이블을 사용하여 deptno 를 부서#, dname 부서명, 
--loc 를 위치로 별명을 설정하여 출력하세요. 
select DEPTNO "부서#",
       dname 부서명,
       loc 위치
  from dept;
  
--Distinct 연습문제 1 : 
--EMP 테이블에서 부서별(deptno)로 담당하는 업무(job)가 
--하나씩 출력되도록 하여라.
select distinct deptno, job
  from emp;


-- 연결연산자(||) : 서로 분리되어진 컬럼을 하나로 합침
select empno||'-'||ename
  from emp;
  
select concat(concat(empno,'-'), ename)
  from emp;

--예제) 다음과 같은 형식으로 출력
--SMITH의 연봉은 800입니다.

select ENAME||'의 연봉은 '||SAL||'입니다. '
  from emp;

-- 조건절(WHERE) : 조건에 맞는 행을 선택(필터)
-- * 조건의 형태 : 대상(컬럼) 연산자 상수

--예제) emp 테이블에서 10번 부서직원의 정보만 출력
select *
  from EMP
 where DEPTNO = 10;

--예제) emp 테이블에서 ALLEN의 이름, 부서번호, 연봉을
--      출력
select ENAME, DEPTNO, SAL 
  from emp
 where lower(ENAME) = 'allen';

select lower(ENAME), DEPTNO, SAL 
  from emp
 where upper(ENAME) = 'ALLEN';

--예제) emp 테이블에서 sal이 2000이상인 직원의
--      이름, 부서번호, sal, comm 출력
select ENAME, DEPTNO, SAL, COMM
  from emp
 where SAL >= 2000;

--예제) emp 테이블에서 10번 부서원 중
--      sal이 2000이상인 직원의
--      이름, 부서번호, sal, comm 출력
select ENAME, DEPTNO, SAL, COMM
  from emp
 where SAL >= 2000
   and DEPTNO = 10;
   
   
   
   
 


