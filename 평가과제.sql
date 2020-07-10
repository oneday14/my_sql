-- 데이터베이스 구현 문제
-- 1. DESC EMP의결과를그대로출력할수있도록쿼리문을작성하세요.
--    단, 정보는 USER_TAB_COLUMNS 테이블사용

 select COLUMN_NAME as "Column",
        decode(NULLABLE,'N','NOT NULL','') as "Nullable",
        DATA_TYPE ||
        case when COLUMN_NAME in ('SAL', 'COMM')  then '(' || DATA_PRECISION || ',' || DATA_SCALE || ')'
             when DATA_TYPE = 'VARCHAR2' then '(' || DATA_LENGTH || ')'
             when DATA_TYPE = 'NUMBER' then '(' || DATA_PRECISION || ')'
         end as "Type"
   from USER_TAB_COLUMNS
  where table_name = 'EMP';          -- 결과 옳바름
  
-- SQL 활용 문제 
-- 1. student.csv, exam_01.csv 파일을 각각 클립보드로 읽어들여 다음수행
--  1) 두 데이터를 조인하여 학생의 이름, 시험성적 출력

 select s.name, e.TOTAL
   from STUDENT s, EXAM_01 e
  where s.STUDNO = e.STUDNO;          -- 결과 옳바름
  
--  2) 서울에 거주하는 여학생의 정보만 출력

 select s.*, substr(tel, 1, instr(tel, ')') -1) as 지역번호
   from STUDENT s
  where substr(tel, 1, instr(tel, ')') -1) = '02'
    and substr(jumin, 7,1) = '2';          -- 결과 옳바름
    
--  3) ID컬럼에 숫자를 포함하는 학생의 정보 출력

 select *
   from STUDENT
  where translate(ID,'1abcdefghijklmnopqrstuvwxyz','1') is not null;          -- 결과 옳바름

--  4) 학년별 성별 시험성적의 평균을 다음과 같은 형태로 출력
--          1  2  3  4
--       남
--       여

select decode(substr(jumin, 7,1),1,'남','여') as 성별,
       avg(decode(s.grade, 1, e.total, '')) as "1",
       nvl(to_char(avg(decode(s.grade, 2, e.total, ''))),'NA') as "2",
       nvl(to_char(avg(decode(s.grade, 3, e.total, ''))),'NA') as "3",
       avg(decode(s.grade, 4, e.total, '')) as "4"
  from STUDENT s, EXAM_01 e
 where s.STUDNO = e.STUDNO
 group by substr(jumin, 7,1),1,'남','여';          -- 결과 옳바름