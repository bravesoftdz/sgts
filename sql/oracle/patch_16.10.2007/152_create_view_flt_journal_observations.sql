/* �������� ���� ������� ���������� ������� ���������� */

CREATE OR REPLACE TYPE FLT_JOURNAL_OBSERVATION_OBJECT AS OBJECT
(
  CYCLE_ID INTEGER,
  CYCLE_NUM INTEGER,
  JOURNAL_NUM VARCHAR2(100),
  DATE_OBSERVATION DATE,
  MEASURE_TYPE_ID INTEGER,
  POINT_ID INTEGER,
  POINT_NAME INTEGER,
  CONVERTER_ID INTEGER,
  CONVERTER_NAME VARCHAR2(100),
  MARK FLOAT,
  VOLUME FLOAT,
  TIME FLOAT,
  EXPENSE FLOAT,
  T_WATER FLOAT,
  OBJECT_PATHS VARCHAR2(1000),
  COORDINATE_Z FLOAT
)

--

/* �������� ���� ������� ���������� ������� ���������� */

CREATE OR REPLACE TYPE FLT_JOURNAL_OBSERVATION_TABLE 
AS TABLE OF FLT_JOURNAL_OBSERVATION_OBJECT

--

/* �������� ������� ��������� ���������� � ������� ���������� */

CREATE OR REPLACE FUNCTION GET_FLT_JOURNAL_OBSERVATIONS
(
  MEASURE_TYPE_ID INTEGER,
  IS_CLOSE INTEGER
)
RETURN FLT_JOURNAL_OBSERVATION_TABLE
PIPELINED
IS
  INC2 FLT_JOURNAL_OBSERVATION_OBJECT:=FLT_JOURNAL_OBSERVATION_OBJECT(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
                                                                      NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
  NUM_MIN INTEGER:=NULL;
  NUM_MAX INTEGER:=NULL;
BEGIN
  FOR INC IN (SELECT MIN(CYCLE_NUM) AS NUM_MIN, MAX(CYCLE_NUM) AS NUM_MAX 
                FROM CYCLES
               WHERE IS_CLOSE=GET_FLT_JOURNAL_OBSERVATIONS.IS_CLOSE) LOOP
    NUM_MIN:=INC.NUM_MIN;
	NUM_MAX:=INC.NUM_MAX;    			   
    EXIT;			   
  END LOOP;			    
   
  FOR INC1 IN (SELECT /*+ INDEX (JO) INDEX (C) INDEX (P) INDEX (RP) INDEX (CR) */
                      JO.DATE_OBSERVATION, 
                      JO.MEASURE_TYPE_ID,
                      JO.CYCLE_ID,
                      C.CYCLE_NUM,
                      JO.POINT_ID,
                      P.NAME AS POINT_NAME,
                      CR.CONVERTER_ID,
                      CR.NAME AS CONVERTER_NAME,
                      JO.GROUP_ID,
                      MIN(DECODE(JO.PARAM_ID,3040,JO.VALUE,NULL)) AS VOLUME,
					  MIN(DECODE(JO.PARAM_ID,3041,JO.VALUE,NULL)) AS TIME,
					  MIN(DECODE(JO.PARAM_ID,3042,JO.VALUE,NULL)) AS EXPENSE,
					  MIN(DECODE(JO.PARAM_ID,3082,JO.VALUE,NULL)) AS T_WATER,
					  (SELECT TO_NUMBER(REPLACE(CP.VALUE,',','.'),'FM99999.9999') FROM CONVERTER_PASSPORTS CP, COMPONENTS CM 
                        WHERE CP.COMPONENT_ID=CM.COMPONENT_ID
                          AND CM.CONVERTER_ID=CR.CONVERTER_ID
                          AND CM.PARAM_ID=3002 /* ������� ������� */) AS MARK,
					  OT.OBJECT_PATHS,
					  P.COORDINATE_Z
                 FROM JOURNAL_OBSERVATIONS JO, CYCLES C, POINTS P,
                      ROUTE_POINTS RP, CONVERTERS CR,
                      (SELECT OT1.OBJECT_ID, SUBSTR(MAX(SYS_CONNECT_BY_PATH(O1.NAME,'\')),2) AS OBJECT_PATHS
                         FROM OBJECT_TREES OT1, OBJECTS O1
                        WHERE OT1.OBJECT_ID=O1.OBJECT_ID
                        START WITH OT1.PARENT_ID IS NULL
                      CONNECT BY OT1.PARENT_ID=PRIOR OT1.OBJECT_TREE_ID
					    GROUP BY OT1.OBJECT_ID) OT
                WHERE JO.CYCLE_ID=C.CYCLE_ID
                  AND JO.POINT_ID=P.POINT_ID
                  AND RP.POINT_ID=JO.POINT_ID
                  AND CR.CONVERTER_ID=P.POINT_ID 
				  AND P.OBJECT_ID=OT.OBJECT_ID
                  AND JO.MEASURE_TYPE_ID=GET_FLT_JOURNAL_OBSERVATIONS.MEASURE_TYPE_ID
                  AND JO.PARAM_ID IN (3040, /* ���������� ����� */
                                      3041, /* ����� ������ */
                                      3042, /* ������ */
                                      3082 /* � ���� 2 */)
                  AND C.CYCLE_NUM>=NUM_MIN AND C.CYCLE_NUM<=NUM_MAX
				  AND C.IS_CLOSE=GET_FLT_JOURNAL_OBSERVATIONS.IS_CLOSE
                GROUP BY JO.DATE_OBSERVATION, JO.MEASURE_TYPE_ID, JO.CYCLE_ID, C.CYCLE_NUM, JO.POINT_ID, 
				         P.NAME, CR.CONVERTER_ID, CR.NAME, JO.GROUP_ID, RP.PRIORITY, CR.DATE_ENTER, 
						 OT.OBJECT_PATHS, P.COORDINATE_Z				  								  
                ORDER BY JO.DATE_OBSERVATION, JO.GROUP_ID, RP.PRIORITY) LOOP
    INC2.CYCLE_ID:=INC1.CYCLE_ID;
    INC2.CYCLE_NUM:=INC1.CYCLE_NUM;
	INC2.DATE_OBSERVATION:=INC1.DATE_OBSERVATION;
	INC2.MEASURE_TYPE_ID:=INC1.MEASURE_TYPE_ID;
	INC2.POINT_ID:=INC1.POINT_ID;
	INC2.POINT_NAME:=INC1.POINT_NAME;
	INC2.CONVERTER_ID:=INC1.CONVERTER_ID;
	INC2.CONVERTER_NAME:=INC1.CONVERTER_NAME;
    INC2.MARK:=INC1.MARK;
	INC2.VOLUME:=INC1.VOLUME;
	INC2.TIME:=INC1.TIME;
	INC2.EXPENSE:=INC1.EXPENSE;
	INC2.T_WATER:=INC1.T_WATER;
    INC2.OBJECT_PATHS:=INC1.OBJECT_PATHS;
    INC2.COORDINATE_Z:=INC1.COORDINATE_Z;
	  						
    PIPE ROW (INC2);
  END LOOP;
  RETURN;
END;

--



/* �������� ��������� ����� ����� �� ������� � ������� ���������� ������ ������ */

CREATE MATERIALIZED VIEW S_FLT_JOURNAL_OBSERVATIONS_O1
NOLOGGING
NOCACHE
NOPARALLEL
BUILD DEFERRED
REFRESH COMPLETE
START WITH TO_DATE('01.06.2007','DD.MM.YYYY')
DISABLE QUERY REWRITE AS
SELECT * FROM TABLE(GET_FLT_JOURNAL_OBSERVATIONS(2582,1))

--

/* ���������� ��������� ����� ����� �� ������� � ������� ���������� ������ ������ */

BEGIN
  DBMS_REFRESH.REFRESH('S_FLT_JOURNAL_OBSERVATIONS_O1');
END;

--

/* �������� ������� �� ���� ��������� ����� ����� �� ������� � ������� ���������� ������ ������ */

CREATE INDEX IDX_FLT_JO_O1_1
 ON S_FLT_JOURNAL_OBSERVATIONS_O1(CYCLE_ID)

--

/* �������� ������� �� ���� ���������� ��������� ����� ����� �� ������� � ������� ���������� ������ ������ */

CREATE INDEX IDX_FLT_JO_O1_2
 ON S_FLT_JOURNAL_OBSERVATIONS_O1(DATE_OBSERVATION)

--

/* �������� ������� �� ��� ��������� ��������� ����� ����� �� ������� � ������� ���������� ������ ������ */

CREATE INDEX IDX_FLT_JO_O1_3
 ON S_FLT_JOURNAL_OBSERVATIONS_O1(MEASURE_TYPE_ID)

--

/* �������� ��������� ����� ����� �� ������� � ������� ���������� ����� ������ */

CREATE OR REPLACE VIEW S_FLT_JOURNAL_OBSERVATIONS_N1
AS
  SELECT * FROM TABLE(GET_FLT_JOURNAL_OBSERVATIONS(2582,0))

--

/* �������� ��������� ����� ����� �� ������� � ������� ���������� */

CREATE OR REPLACE VIEW S_FLT_JOURNAL_OBSERVATIONS_1
AS
  SELECT JOO1.*
    FROM S_FLT_JOURNAL_OBSERVATIONS_O1 JOO1
   UNION
  SELECT JON1.*
    FROM S_FLT_JOURNAL_OBSERVATIONS_N1 JON1

--



/* �������� ��������� ����� ��� �� ������� � ������� ���������� ������ ������ */

CREATE MATERIALIZED VIEW S_FLT_JOURNAL_OBSERVATIONS_O2
NOLOGGING
NOCACHE
NOPARALLEL
BUILD DEFERRED
REFRESH COMPLETE
START WITH TO_DATE('01.06.2007','DD.MM.YYYY')
DISABLE QUERY REWRITE AS
SELECT * FROM TABLE(GET_FLT_JOURNAL_OBSERVATIONS(2583,1))

--

/* ���������� ��������� ����� ��� �� ������� � ������� ���������� ������ ������ */

BEGIN
  DBMS_REFRESH.REFRESH('S_FLT_JOURNAL_OBSERVATIONS_O2');
END;

--

/* �������� ������� �� ���� ��������� ����� ��� �� ������� � ������� ���������� ������ ������ */

CREATE INDEX IDX_FLT_JO_O2_1
 ON S_FLT_JOURNAL_OBSERVATIONS_O2(CYCLE_ID)

--

/* �������� ������� �� ���� ���������� ��������� ����� ��� �� ������� � ������� ���������� ������ ������ */

CREATE INDEX IDX_FLT_JO_O2_2
 ON S_FLT_JOURNAL_OBSERVATIONS_O2(DATE_OBSERVATION)

--

/* �������� ������� �� ��� ��������� ��������� ����� ��� �� ������� � ������� ���������� ������ ������ */

CREATE INDEX IDX_FLT_JO_O2_3
 ON S_FLT_JOURNAL_OBSERVATIONS_O2(MEASURE_TYPE_ID)

--

/* �������� ��������� ����� ��� �� ������� � ������� ���������� ����� ������ */

CREATE OR REPLACE VIEW S_FLT_JOURNAL_OBSERVATIONS_N2
AS
  SELECT * FROM TABLE(GET_FLT_JOURNAL_OBSERVATIONS(2583,0))

--

/* �������� ��������� ����� ��� �� ������� � ������� ���������� */

CREATE OR REPLACE VIEW S_FLT_JOURNAL_OBSERVATIONS_2
AS
  SELECT JOO2.*
    FROM S_FLT_JOURNAL_OBSERVATIONS_O2 JOO2
   UNION
  SELECT JON2.*
    FROM S_FLT_JOURNAL_OBSERVATIONS_N2 JON2

--



/* �������� ��������� ������� ���. ������� 1 ���� � ������� ���������� ������ ������ */

CREATE MATERIALIZED VIEW S_FLT_JOURNAL_OBSERVATIONS_O3
NOLOGGING
NOCACHE
NOPARALLEL
BUILD DEFERRED
REFRESH COMPLETE
START WITH TO_DATE('01.06.2007','DD.MM.YYYY')
DISABLE QUERY REWRITE AS
SELECT * FROM TABLE(GET_FLT_JOURNAL_OBSERVATIONS(2581,1))

--

/* ���������� ��������� ������� ���. ������� 1 ���� � ������� ���������� ������ ������ */

BEGIN
  DBMS_REFRESH.REFRESH('S_FLT_JOURNAL_OBSERVATIONS_O3');
END;

--

/* �������� ������� �� ���� ��������� ������� ���. ������� 1 ���� � ������� ���������� ������ ������ */

CREATE INDEX IDX_FLT_JO_O3_1
 ON S_FLT_JOURNAL_OBSERVATIONS_O3(CYCLE_ID)

--

/* �������� ������� �� ���� ���������� ��������� ������� ���. ������� 1 ���� � ������� ���������� ������ ������ */

CREATE INDEX IDX_FLT_JO_O3_2
 ON S_FLT_JOURNAL_OBSERVATIONS_O3(DATE_OBSERVATION)

--

/* �������� ������� �� ��� ��������� ��������� ������� ���. ������� 1 ���� � ������� ���������� ������ ������ */

CREATE INDEX IDX_FLT_JO_O3_3
 ON S_FLT_JOURNAL_OBSERVATIONS_O3(MEASURE_TYPE_ID)

--

/* �������� ��������� ������� ���. ������� 1 ���� � ������� ���������� ����� ������ */

CREATE OR REPLACE VIEW S_FLT_JOURNAL_OBSERVATIONS_N3
AS
  SELECT * FROM TABLE(GET_FLT_JOURNAL_OBSERVATIONS(2581,0))

--

/* �������� ��������� ������� ���. ������� 1 ���� � ������� ���������� */

CREATE OR REPLACE VIEW S_FLT_JOURNAL_OBSERVATIONS_3
AS
  SELECT JOO3.*
    FROM S_FLT_JOURNAL_OBSERVATIONS_O3 JOO3
   UNION
  SELECT JON3.*
    FROM S_FLT_JOURNAL_OBSERVATIONS_N3 JON3

--




/* �������� ��������� ����� ���������� ��� � ������� ���������� ������ ������ */

CREATE MATERIALIZED VIEW S_FLT_JOURNAL_OBSERVATIONS_O4
NOLOGGING
NOCACHE
NOPARALLEL
BUILD DEFERRED
REFRESH COMPLETE
START WITH TO_DATE('01.06.2007','DD.MM.YYYY')
DISABLE QUERY REWRITE AS
SELECT * FROM TABLE(GET_FLT_JOURNAL_OBSERVATIONS(2584,1))

--

/* ���������� ��������� ����� ���������� ��� � ������� ���������� ������ ������ */

BEGIN
  DBMS_REFRESH.REFRESH('S_FLT_JOURNAL_OBSERVATIONS_O4');
END;

--

/* �������� ������� �� ���� ��������� ����� ���������� ��� � ������� ���������� ������ ������ */

CREATE INDEX IDX_FLT_JO_O4_1
 ON S_FLT_JOURNAL_OBSERVATIONS_O4(CYCLE_ID)

--

/* �������� ������� �� ���� ���������� ��������� ����� ���������� ��� � ������� ���������� ������ ������ */

CREATE INDEX IDX_FLT_JO_O4_2
 ON S_FLT_JOURNAL_OBSERVATIONS_O4(DATE_OBSERVATION)

--

/* �������� ������� �� ��� ��������� ��������� ����� ���������� ��� � ������� ���������� ������ ������ */

CREATE INDEX IDX_FLT_JO_O4_3
 ON S_FLT_JOURNAL_OBSERVATIONS_O4(MEASURE_TYPE_ID)

--

/* �������� ��������� ����� ���������� ��� � ������� ���������� ����� ������ */

CREATE OR REPLACE VIEW S_FLT_JOURNAL_OBSERVATIONS_N4
AS
  SELECT * FROM TABLE(GET_FLT_JOURNAL_OBSERVATIONS(2584,0))

--

/* �������� ��������� ����� ���������� ��� � ������� ���������� */

CREATE OR REPLACE VIEW S_FLT_JOURNAL_OBSERVATIONS_4
AS
  SELECT JOO4.*
    FROM S_FLT_JOURNAL_OBSERVATIONS_O4 JOO4
   UNION
  SELECT JON4.*
    FROM S_FLT_JOURNAL_OBSERVATIONS_N4 JON4

--



/* �������� ��������� �������. ������. � ��������� � ������� ���������� ������ ������ */

CREATE MATERIALIZED VIEW S_FLT_JOURNAL_OBSERVATIONS_O5
NOLOGGING
NOCACHE
NOPARALLEL
BUILD DEFERRED
REFRESH COMPLETE
START WITH TO_DATE('01.06.2007','DD.MM.YYYY')
DISABLE QUERY REWRITE AS
SELECT * FROM TABLE(GET_FLT_JOURNAL_OBSERVATIONS(2585,1))

--

/* ���������� ��������� �������. ������. � ��������� � ������� ���������� ������ ������ */

BEGIN
  DBMS_REFRESH.REFRESH('S_FLT_JOURNAL_OBSERVATIONS_O5');
END;

--

/* �������� ������� �� ���� ��������� �������. ������. � ��������� � ������� ���������� ������ ������ */

CREATE INDEX IDX_FLT_JO_O5_1
 ON S_FLT_JOURNAL_OBSERVATIONS_O5(CYCLE_ID)

--

/* �������� ������� �� ���� ���������� ��������� �������. ������. � ��������� � ������� ���������� ������ ������ */

CREATE INDEX IDX_FLT_JO_O5_2
 ON S_FLT_JOURNAL_OBSERVATIONS_O5(DATE_OBSERVATION)

--

/* �������� ������� �� ��� ��������� ��������� �������. ������. � ��������� � ������� ���������� ������ ������ */

CREATE INDEX IDX_FLT_JO_O5_3
 ON S_FLT_JOURNAL_OBSERVATIONS_O5(MEASURE_TYPE_ID)

--

/* �������� ��������� �������. ������. � ��������� � ������� ���������� ����� ������ */

CREATE OR REPLACE VIEW S_FLT_JOURNAL_OBSERVATIONS_N5
AS
  SELECT * FROM TABLE(GET_FLT_JOURNAL_OBSERVATIONS(2585,0))

--

/* �������� ��������� �������. ������. � ��������� � ������� ���������� */

CREATE OR REPLACE VIEW S_FLT_JOURNAL_OBSERVATIONS_5
AS
  SELECT JOO5.*
    FROM S_FLT_JOURNAL_OBSERVATIONS_O5 JOO5
   UNION
  SELECT JON5.*
    FROM S_FLT_JOURNAL_OBSERVATIONS_N5 JON5

--



/* �������� ��������� ������� ���. ������� 2 ���� � ������� ���������� ������ ������ */

CREATE MATERIALIZED VIEW S_FLT_JOURNAL_OBSERVATIONS_O6
NOLOGGING
NOCACHE
NOPARALLEL
BUILD DEFERRED
REFRESH COMPLETE
START WITH TO_DATE('01.06.2007','DD.MM.YYYY')
DISABLE QUERY REWRITE AS
SELECT * FROM TABLE(GET_FLT_JOURNAL_OBSERVATIONS(2626,1))

--

/* ���������� ��������� ������� ���. ������� 2 ���� � ������� ���������� ������ ������ */

BEGIN
  DBMS_REFRESH.REFRESH('S_FLT_JOURNAL_OBSERVATIONS_O6');
END;

--

/* �������� ������� �� ���� ��������� ������� ���. ������� 2 ���� � ������� ���������� ������ ������ */

CREATE INDEX IDX_FLT_JO_O6_1
 ON S_FLT_JOURNAL_OBSERVATIONS_O6(CYCLE_ID)

--

/* �������� ������� �� ���� ���������� ��������� ������� ���. ������� 2 ���� � ������� ���������� ������ ������ */

CREATE INDEX IDX_FLT_JO_O6_2
 ON S_FLT_JOURNAL_OBSERVATIONS_O6(DATE_OBSERVATION)

--

/* �������� ������� �� ��� ��������� ��������� ������� ���. ������� 2 ���� � ������� ���������� ������ ������ */

CREATE INDEX IDX_FLT_JO_O6_3
 ON S_FLT_JOURNAL_OBSERVATIONS_O6(MEASURE_TYPE_ID)

--

/* �������� ��������� ������� ���. ������� 2 ���� � ������� ���������� ����� ������ */

CREATE OR REPLACE VIEW S_FLT_JOURNAL_OBSERVATIONS_N6
AS
  SELECT * FROM TABLE(GET_FLT_JOURNAL_OBSERVATIONS(2626,0))

--

/* �������� ��������� ������� ���. ������� 2 ���� � ������� ���������� */

CREATE OR REPLACE VIEW S_FLT_JOURNAL_OBSERVATIONS_6
AS
  SELECT JOO6.*
    FROM S_FLT_JOURNAL_OBSERVATIONS_O6 JOO6
   UNION
  SELECT JON6.*
    FROM S_FLT_JOURNAL_OBSERVATIONS_N6 JON6

--



/* �������� ��������� ���������� � ������� ���������� */

CREATE OR REPLACE VIEW S_FLT_JOURNAL_OBSERVATIONS
AS
  SELECT JO1.*
    FROM S_FLT_JOURNAL_OBSERVATIONS_1 JO1
   UNION
  SELECT JO2.*
    FROM S_FLT_JOURNAL_OBSERVATIONS_2 JO2
   UNION
  SELECT JO3.*
    FROM S_FLT_JOURNAL_OBSERVATIONS_3 JO3
   UNION
  SELECT JO4.*
    FROM S_FLT_JOURNAL_OBSERVATIONS_4 JO4
   UNION
  SELECT JO5.*
    FROM S_FLT_JOURNAL_OBSERVATIONS_5 JO5
   UNION
  SELECT JO6.*
    FROM S_FLT_JOURNAL_OBSERVATIONS_6 JO6



--


/* �������� ��������� �� */

COMMIT
