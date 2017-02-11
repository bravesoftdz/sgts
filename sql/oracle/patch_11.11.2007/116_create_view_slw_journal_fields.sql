/* �������� ���� ������� ��������� �������� �������� ������� */

CREATE OR REPLACE TYPE SLW_JOURNAL_FIELD_OBJECT AS OBJECT
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
  OBJECT_PATHS VARCHAR2(1000),
  COORDINATE_Z FLOAT,
  VALUE_X FLOAT,
  VALUE_Y FLOAT,
  VALUE_Z FLOAT,
  OPENING_X FLOAT,
  OPENING_Y FLOAT,
  OPENING_Z FLOAT,
  CURRENT_OPENING_X FLOAT,
  CURRENT_OPENING_Y FLOAT,
  CURRENT_OPENING_Z FLOAT
)

--

/* �������� ���� ������� ��������� �������� �������� ������� */

CREATE OR REPLACE TYPE SLW_JOURNAL_FIELD_TABLE 
AS TABLE OF SLW_JOURNAL_FIELD_OBJECT

--

/* �������� ������� ��������� ��������� �������� � ������� ������� */

CREATE OR REPLACE FUNCTION GET_SLW_JOURNAL_FIELDS
(
  MEASURE_TYPE_ID INTEGER,
  IS_CLOSE INTEGER
)
RETURN SLW_JOURNAL_FIELD_TABLE
PIPELINED
IS
  INC2 SLW_JOURNAL_FIELD_OBJECT:=SLW_JOURNAL_FIELD_OBJECT(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
                                                          NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
  NUM_MIN INTEGER:=NULL;
  NUM_MAX INTEGER:=NULL;
BEGIN
  FOR INC IN (SELECT MIN(CYCLE_NUM) AS NUM_MIN, MAX(CYCLE_NUM) AS NUM_MAX 
                FROM CYCLES
               WHERE IS_CLOSE=GET_SLW_JOURNAL_FIELDS.IS_CLOSE) LOOP
    NUM_MIN:=INC.NUM_MIN;
	NUM_MAX:=INC.NUM_MAX;    			   
    EXIT;			   
  END LOOP;			    
   
  FOR INC1 IN (SELECT /*+ INDEX (JF) INDEX (C) INDEX (P) INDEX (RP) INDEX (CR) */
                      JF.DATE_OBSERVATION, 
                      JF.MEASURE_TYPE_ID,
                      JF.CYCLE_ID,
                      C.CYCLE_NUM,
                      JF.POINT_ID,
                      P.NAME AS POINT_NAME,
                      CR.CONVERTER_ID,
                      CR.NAME AS CONVERTER_NAME,
                      JF.GROUP_ID,
					  MIN(DECODE(JF.PARAM_ID,30006,JF.VALUE,NULL)) AS VALUE_X,
					  MIN(DECODE(JF.PARAM_ID,30008,JF.VALUE,NULL)) AS VALUE_Y,
					  MIN(DECODE(JF.PARAM_ID,30009,JF.VALUE,NULL)) AS VALUE_Z,
					  MIN(DECODE(JF.PARAM_ID,30010,JF.VALUE,NULL)) AS OPENING_X,
					  MIN(DECODE(JF.PARAM_ID,30011,JF.VALUE,NULL)) AS OPENING_Y,
					  MIN(DECODE(JF.PARAM_ID,30012,JF.VALUE,NULL)) AS OPENING_Z,
					  MIN(DECODE(JF.PARAM_ID,30035,JF.VALUE,NULL)) AS CURRENT_OPENING_X,
					  MIN(DECODE(JF.PARAM_ID,30036,JF.VALUE,NULL)) AS CURRENT_OPENING_Y,
					  MIN(DECODE(JF.PARAM_ID,30037,JF.VALUE,NULL)) AS CURRENT_OPENING_Z,
					  OT.OBJECT_PATHS,
					  P.COORDINATE_Z,
					  JF.JOURNAL_NUM
                 FROM JOURNAL_FIELDS JF, CYCLES C, POINTS P,
                      ROUTE_POINTS RP, CONVERTERS CR,
                      (SELECT OT1.OBJECT_ID, SUBSTR(MAX(SYS_CONNECT_BY_PATH(O1.NAME,'\')),2) AS OBJECT_PATHS
                         FROM OBJECT_TREES OT1, OBJECTS O1
                        WHERE OT1.OBJECT_ID=O1.OBJECT_ID
                        START WITH OT1.PARENT_ID IS NULL
                      CONNECT BY OT1.PARENT_ID=PRIOR OT1.OBJECT_TREE_ID
					    GROUP BY OT1.OBJECT_ID) OT
                WHERE JF.CYCLE_ID=C.CYCLE_ID
                  AND JF.POINT_ID=P.POINT_ID
                  AND RP.POINT_ID=JF.POINT_ID
                  AND CR.CONVERTER_ID=P.POINT_ID
				  AND P.OBJECT_ID=OT.OBJECT_ID 
                  AND JF.MEASURE_TYPE_ID=GET_SLW_JOURNAL_FIELDS.MEASURE_TYPE_ID
                  AND JF.PARAM_ID IN (30006, /* ������ �� X */
				                      30008, /* ������ �� Y */
									  30009, /* ������ �� Z */
                                      30010, /* ��������� � ������ ���������� �� X*/
                                      30011, /* ��������� � ������ ���������� �� Y*/
                                      30012, /* ��������� � ������ ���������� �� Z*/
                                      30035, /* ������� ��������� �� X */
                                      30036, /* ������� ��������� �� Y */
                                      30037 /* ������� ��������� �� Z */)
                  AND C.CYCLE_NUM>=NUM_MIN AND C.CYCLE_NUM<=NUM_MAX
 				  AND C.IS_CLOSE=GET_SLW_JOURNAL_FIELDS.IS_CLOSE								  
                GROUP BY JF.DATE_OBSERVATION, JF.MEASURE_TYPE_ID, JF.CYCLE_ID, C.CYCLE_NUM, JF.POINT_ID, 
				         P.NAME, CR.CONVERTER_ID, CR.NAME, JF.GROUP_ID, RP.PRIORITY, CR.DATE_ENTER, 
						 OT.OBJECT_PATHS, P.COORDINATE_Z, JF.JOURNAL_NUM
                ORDER BY JF.DATE_OBSERVATION, JF.GROUP_ID, RP.PRIORITY) LOOP
    INC2.CYCLE_ID:=INC1.CYCLE_ID;
    INC2.CYCLE_NUM:=INC1.CYCLE_NUM;
    INC2.JOURNAL_NUM:=INC1.JOURNAL_NUM;
	INC2.DATE_OBSERVATION:=INC1.DATE_OBSERVATION;
	INC2.MEASURE_TYPE_ID:=INC1.MEASURE_TYPE_ID;
	INC2.POINT_ID:=INC1.POINT_ID;
	INC2.POINT_NAME:=INC1.POINT_NAME;
	INC2.CONVERTER_ID:=INC1.CONVERTER_ID;
	INC2.CONVERTER_NAME:=INC1.CONVERTER_NAME;
    INC2.OBJECT_PATHS:=INC1.OBJECT_PATHS;
    INC2.COORDINATE_Z:=INC1.COORDINATE_Z;
	INC2.VALUE_X:=INC1.VALUE_X;
	INC2.VALUE_Y:=INC1.VALUE_Y;
	INC2.VALUE_Z:=INC1.VALUE_Z;
	INC2.OPENING_X:=INC1.OPENING_X;
	INC2.OPENING_Y:=INC1.OPENING_Y;
	INC2.OPENING_Z:=INC1.OPENING_Z;
	INC2.CURRENT_OPENING_X:=INC1.CURRENT_OPENING_X;
	INC2.CURRENT_OPENING_Y:=INC1.CURRENT_OPENING_Y;
	INC2.CURRENT_OPENING_Z:=INC1.CURRENT_OPENING_Z;
	
    PIPE ROW (INC2);
  END LOOP;
  RETURN;
END;

--


/* �������� ��������� ������� � ������� ������� ������ ������ */

CREATE MATERIALIZED VIEW S_SLW_JOURNAL_FIELDS_O1
NOLOGGING
NOCACHE
NOPARALLEL
BUILD DEFERRED
REFRESH COMPLETE
START WITH TO_DATE('01.06.2007','DD.MM.YYYY')
DISABLE QUERY REWRITE AS
SELECT * FROM TABLE(GET_SLW_JOURNAL_FIELDS(30006,1))

--

/* ���������� ��������� ������� � ������� ������� ������ ������ */

BEGIN
  DBMS_REFRESH.REFRESH('S_SLW_JOURNAL_FIELDS_O1');
END;

--

/* �������� ������� �� ���� ��������� ������������� � ������� ������� ������ ������ */

CREATE INDEX IDX_SLW_JF_O1_1
 ON S_SLW_JOURNAL_FIELDS_O1(CYCLE_ID)

--

/* �������� ������� �� ���� ���������� ��������� ������� � ������� ������� ������ ������ */

CREATE INDEX IDX_SLW_JF_O1_2
 ON S_SLW_JOURNAL_FIELDS_O1(DATE_OBSERVATION)

--

/* �������� ������� �� ��� ��������� ��������� ������� � ������� ������� ������ ������ */

CREATE INDEX IDX_SLW_JF_O1_3
 ON S_SLW_JOURNAL_FIELDS_O1(MEASURE_TYPE_ID)

--

/* �������� ��������� ������� � ������� ������� ����� ������ */

CREATE OR REPLACE VIEW S_SLW_JOURNAL_FIELDS_N1
AS
  SELECT * FROM TABLE(GET_SLW_JOURNAL_FIELDS(30006,0))

--

/* �������� ��������� ������� � ������� ������� */

CREATE OR REPLACE VIEW S_SLW_JOURNAL_FIELDS_1
AS
  SELECT JFO1.*
    FROM S_SLW_JOURNAL_FIELDS_O1 JFO1
   UNION
  SELECT JFN1.*
    FROM S_SLW_JOURNAL_FIELDS_N1 JFN1

--



/* �������� ��������� ������ ��� � ������� ������� ������ ������ */

CREATE MATERIALIZED VIEW S_SLW_JOURNAL_FIELDS_O2
NOLOGGING
NOCACHE
NOPARALLEL
BUILD DEFERRED
REFRESH COMPLETE
START WITH TO_DATE('01.06.2007','DD.MM.YYYY')
DISABLE QUERY REWRITE AS
SELECT * FROM TABLE(GET_SLW_JOURNAL_FIELDS(30007,1))

--

/* ���������� ��������� ������ ��� � ������� ������� ������ ������ */

BEGIN
  DBMS_REFRESH.REFRESH('S_SLW_JOURNAL_FIELDS_O2');
END;

--

/* �������� ������� �� ���� ��������� ������ ��� � ������� ������� ������ ������ */

CREATE INDEX IDX_SLW_JF_O2_1
 ON S_SLW_JOURNAL_FIELDS_O2(CYCLE_ID)

--

/* �������� ������� �� ���� ���������� ��������� ������ ��� � ������� ������� ������ ������ */

CREATE INDEX IDX_SLW_JF_O2_2
 ON S_SLW_JOURNAL_FIELDS_O2(DATE_OBSERVATION)

--

/* �������� ������� �� ��� ��������� ��������� ������ ��� � ������� ������� ������ ������ */

CREATE INDEX IDX_SLW_JF_O2_3
 ON S_SLW_JOURNAL_FIELDS_O2(MEASURE_TYPE_ID)

--

/* �������� ��������� ������ ��� � ������� ������� ����� ������ */

CREATE OR REPLACE VIEW S_SLW_JOURNAL_FIELDS_N2
AS
  SELECT * FROM TABLE(GET_SLW_JOURNAL_FIELDS(30007,0))

--

/* �������� ��������� ������ ��� � ������� ������� */

CREATE OR REPLACE VIEW S_SLW_JOURNAL_FIELDS_2
AS
  SELECT JFO2.*
    FROM S_SLW_JOURNAL_FIELDS_O2 JFO2
   UNION
  SELECT JFN2.*
    FROM S_SLW_JOURNAL_FIELDS_N2 JFN2

--


/* �������� ��������� ��������� �������� � ������� ������� */

CREATE OR REPLACE VIEW S_SLW_JOURNAL_FIELDS
AS
  SELECT JF1.*
    FROM S_SLW_JOURNAL_FIELDS_1 JF1
   UNION
  SELECT JF2.*
    FROM S_SLW_JOURNAL_FIELDS_2 JF2

--


/* �������� ��������� �� */

COMMIT
