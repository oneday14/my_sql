--1. STUDENT테이블에서 성별로 평균몸무게보다 
--높은 학생의 이름, 학년, 몸무게, 평균몸무게 출력
--1) 인라인 뷰
select s.NAME, s.GRADE, s.WEIGHT, i.avg_weight
  from STUDENT s, (select substr(JUMIN,7,1) as gender, 
                          avg(WEIGHT) as avg_weight
                     from STUDENT
                    group by substr(JUMIN,7,1)) i
 where substr(s.JUMIN,7,1) = i.gender
   and s.WEIGHT > i.avg_weight;

--2) 상호연관(평균 몸무게는 함께 출력 불가, 추가 스캔)
select s.NAME, s.GRADE, s.WEIGHT
  from STUDENT s 
 where 1=1
   and s.WEIGHT > (select avg(WEIGHT)
                     from STUDENT s2
                    where substr(s.JUMIN,7,1) = 
                          substr(s2.JUMIN,7,1));
  
--2. emp2 테이블에서 각 직원과 나이가 같으면서 취미가 
--같은 직원의 수를 직원의 이름, 부서이름, 취미, 
--pay와 함께 출력하여라.
select e1.NAME, e1.HOBBY, e1.PAY,
       d.DNAME AS 부서이름,
       count(e2.EMPNO) AS "취미가 같은 친구 수"
  from emp2 e1, emp2 e2, DEPT2 d
 where to_char(e1.BIRTHDAY, 'YYYY') =
       to_char(e2.BIRTHDAY(+), 'YYYY')
   and e1.HOBBY = e2.HOBBY(+)
   and e1.EMPNO != e2.EMPNO(+)
   and e1.DEPTNO = d.DCODE
 group by e1.EMPNO, e1.NAME, e1.HOBBY, e1.PAY, d.DNAME;

--3. student, professor 테이블에서 같은지역, 
--같은 성별의 친구가 몇명인지 구하고, 
--그 학생의 담당 교수이름도 함께 출력되도록 하여라.
--단, 같은지역, 같은 성별에 본인은 포함될 수 없다.
p(+) - s1 - s2(+) ;

select s1.studno, s1.name, s1.grade,
       count(s2.studno) as 친구수,
       p.name as 교수이름
  from student s1, student s2, professor p
 where substr(s1.jumin,7,1) = substr(s2.jumin(+),7,1)
   and substr(s1.tel,1,instr(s1.tel,')')-1) = 
       substr(s2.tel(+),1,instr(s2.tel(+),')')-1)
   and s1.studno != s2.studno(+)
   and s1.profno = p.profno(+)
 group by s1.studno, s1.name, s1.grade, p.name;

--4. 교수에 대한 전체 자료를 다음과 같이 출력
--(단, 모든 교수들에 대해 출력되도록 한다)
--교수이름	지도학생수 지도학생_성적평균	A_학점자수	B_학점자수	C_학점자수	D_학점자수
--심슨      	2	        79	                    1	        0	        0	        1
--허은	        2	        83	                    0	        1	        1	        0
--조인형	    1	        97	                    1	        0	        0	        0
p - s(+) - e(+) - h(+);

select p.NAME AS 교수이름,
       count(s.NAME) AS 지도학생수,
       round(avg(nvl(e.TOTAL,0))) AS 시험성적평균,
       count(decode(substr(h.GRADE,1,1),'A',1)) AS A수,
       count(decode(substr(h.GRADE,1,1),'B',1)) AS B수,
       count(decode(substr(h.GRADE,1,1),'C',1)) AS C수,
       count(decode(substr(h.GRADE,1,1),'D',1)) AS D수
  from PROFESSOR p, STUDENT s, 
       EXAM_01 e, HAKJUM h
 where p.PROFNO = s.PROFNO(+)
   and s.STUDNO = e.STUDNO(+)
   and e.TOTAL between h.MIN_POINT(+) and h.MAX_POINT(+)
 group by p.PROFNO, p.NAME
 ;
  
--5. STUDENT 테이블과 EXAM_01 테이블을 사용하여 각 
--학생보다 같은 학년 내에 시험성적이 높은 친구의 수를
--출력하되, 이름, 학년, 학과번호, 시험성적과 함께 출력.

s1(+) - s2(+) 
|         |        =>  (s1 - e1) - (s2 - e2)(+)
e1(+) - e2(+)
;

select s1.name, s1.grade, e1.TOTAL,
       count(s2.STUDNO) AS 학생수
  from STUDENT s1, EXAM_01 e1,
       STUDENT s2, EXAM_01 e2
 where s1.STUDNO(+) = e1.STUDNO
   and s2.STUDNO = e2.STUDNO(+)
   and s1.GRADE = s2.GRADE(+)
   and e1.TOTAL(+) < e2.TOTAL
 group by s1.name, s1.grade, e1.TOTAL;


select i1.*, count(i2.studno) AS 친구수
  from (select s1.NAME, s1.GRADE, e1.TOTAL
          from STUDENT s1, EXAM_01 e1
         where s1.STUDNO = e1.STUDNO) i1,
       (select s2.studno, s2.NAME, s2.GRADE, e2.TOTAL
          from STUDENT s2, EXAM_01 e2
         where s2.STUDNO = e2.STUDNO) i2
  where i1.grade = i2.grade(+)
    and i1.total < i2.total(+)
  group by i1.name, i1.grade, i1.total;

---------- 여기까지는 복습입니다. ----------  

--1. DDL : auto commit(실행 시 즉시 반영, rollback 불가)
--1) create : 테이블 생성
--2) alter : 생성된 테이블 변경
--           (컬럼추가, 컬럼 삭제, 컬럼 데이터 타입 변경,
--           컬럼 not null 여부 변경, 컬럼 default값 변경)

--2-1) 컬럼 추가 : 맨 뒤에 컬럼 추가
alter table EMP_BAK2 add DEPTNO2 number(5);
alter table EMP_BAK2 add (DEPTNO3 number(5),
                          DEPTNO4 number(5));
alter table EMP_BAK2 add DEPTNO5 number(5) default 10;

-- 2-2) 컬럼 삭제 : 데이터 복원 불가
alter table EMP_BAK2 drop column DEPTNO4;
select * from EMP_BAK2;           
desc EMP_BAK2;

--2-3) 컬럼 데이터 타입 변경
alter table EMP_BAK2 modify ENAME VARCHAR2(15); 
--=> column size 늘리기 가능

alter table EMP_BAK2 modify ENAME VARCHAR2(1); 
--=> column size를 저장된 데이터 사이브보다 작게 불가
  
alter table EMP_BAK2 modify ENAME VARCHAR2(6); 
--=> 데이터 사이즈보다 큰 사이즈로 줄이기 가능

alter table EMP_BAK2 modify ENAME number(10); 
--=> 컬럼이 비어있지 않으면 서로 다른 타입으로 변경 불가

alter table EMP_BAK2 modify deptno2 varchar2(10); 
--=> 빈컬럼은 데이터 타입 변경 가능

select max(lengthb(ename))
  from emp;
  
--2-4) 컬럼 이름 변경  
alter table EMP_BAK2 rename column deptno2 to deptno22;

--2-5) 테이블 명 변경(객체명 변경)
rename EMP_BAK2 to EMP_BAKUP2;

--2-6) default 값 생성 및 변경 
-- 컬럼 생성 시 default값 선언, 생성 시점에 값 할당
-- default : 값이 지정되지 않으면 자동으로 부여
-- default 지정 이후 입력된 데이터에 대해 부여
alter table EMP_BAK3 add (col1 varchar2(10),
                          col2 varchar2(10) default 'a');

alter table EMP_BAK3 modify col1 default 'b';

insert into EMP_BAK3 values('HONG',10,3000,NULL,NULL);
insert into EMP_BAK3(EMP_NAME, DEPTNO, SAL)
            values('PARK',20,4000);
commit;


-- 참고 : read only, read write
insert into EMP_BAK4 values(9000,'kim',30,5000);
commit;

alter table EMP_BAK4 read only;
insert into EMP_BAK4 values(9001,'park',20,5000);
-- 수정(insert,update,delete) 불가

alter table EMP_BAK4 add col1 number(4);
-- alter로 구조 변경 불가

drop table EMP_BAK4;
-- 테이블 삭제 가능


-- 3. drop : 테이블 삭제(객체 삭제)
-- 삭제된 테이블은 휴지통에서 복구 가능
-- purge 옵션으로 삭제된 테이블은 복구 불가

-- 참고 : drop으로 삭제된 테이블의 복구
select * from user_recyclebin;  -- 휴지통

select * from EMP_BAK4;  --조회X

flashback table "BIN$x7B+A/YbTNic/qmo07vtew==$0"
to before drop;

select * from EMP_BAK4; -- 조회O

--4. truncate : 테이블 구조 남기고 데이터 전체 삭제
alter table EMP_BAK4 read write;
truncate table EMP_BAK4;

select * from EMP_BAK4; -- 조회O, 데이터 없음




