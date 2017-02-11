/* �������� ���� ������� ��������� �������� �������� ������� */

CREATE OR REPLACE TYPE SLF_JOURNAL_FIELD_OBJECT AS OBJECT
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
  VALUE_AB_RACK FLOAT,
  VALUE_AB_COMPASSES FLOAT,
  VALUE_AB_MICROMETR FLOAT,
  VALUE_BA_RACK FLOAT,
  VALUE_BA_COMPASSES FLOAT,
  VALUE_BA_MICROMETR FLOAT,
  VALUE_AC_RACK FLOAT,
  VALUE_AC_COMPASSES FLOAT,
  VALUE_AC_MICROMETR FLOAT,
  VALUE_CA_RACK FLOAT,
  VALUE_CA_COMPASSES FLOAT,
  VALUE_CA_MICROMETR FLOAT,
  VALUE_BC_RACK FLOAT,
  VALUE_BC_COMPASSES FLOAT,
  VALUE_BC_MICROMETR FLOAT,
  VALUE_CB_RACK FLOAT,
  VALUE_CB_COMPASSES FLOAT,
  VALUE_CB_MICROMETR FLOAT,
  AVERAGE_AB_COMPASSES FLOAT,
  AVERAGE_AB_MICROMETR FLOAT,
  AVERAGE_AC_COMPASSES FLOAT,
  AVERAGE_AC_MICROMETR FLOAT,
  AVERAGE_BC_COMPASSES FLOAT,
  AVERAGE_BC_MICROMETR FLOAT,
  ERROR FLOAT,
  OPENING_X FLOAT,
  OPENING_Y FLOAT,
  OPENING_Z FLOAT,
  CURRENT_OPENING_X FLOAT,
  CURRENT_OPENING_Y FLOAT,
  CURRENT_OPENING_Z FLOAT
)

--

/* �������� ���� ������� ��������� �������� �������� ������� */

CREATE OR REPLACE TYPE SLF_JOURNAL_FIELD_TABLE 
AS TABLE OF SLF_JOURNAL_FIELD_OBJECT

--

/* �������� ������� ��������� ��������� �������� � ������� ������� */

CREATE OR REPLACE FUNCTION GET_SLF_JOURNAL_FIELDS
(
  MEASURE_TYPE_ID INTEGER,
  IS_CLOSE INTEGER
)
RETURN SLF_JOURNAL_FIELD_TABLE
PIPELINED
IS
  INC2 SLF_JOURNAL_FIELD_OBJECT:=SLF_JOURNAL_FIELD_OBJECT(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
                                                          NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
														  NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
														  NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
														  NULL,NULL);
  NUM_MIN INTEGER:=NULL;
  NUM_MAX INTEGER:=NULL;
BEGIN
  FOR INC IN (SELECT MIN(CYCLE_NUM) AS NUM_MIN, MAX(CYCLE_NUM) AS NUM_MAX 
                FROM CYCLES
               WHERE IS_CLOSE=GET_SLF_JOURNAL_FIELDS.IS_CLOSE) LOOP
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
					  MIN(DECODE(JF.PARAM_ID,30042,JF.VALUE,NULL)) AS VALUE_AB_RACK,
					  MIN(DECODE(JF.PARAM_ID,30043,JF.VALUE,NULL)) AS VALUE_AB_COMPASSES,
					  MIN(DECODE(JF.PARAM_ID,30044,JF.VALUE,NULL)) AS VALUE_AB_MICROMETR,
					  MIN(DECODE(JF.PARAM_ID,30045,JF.VALUE,NULL)) AS VALUE_BA_RACK,
					  MIN(DECODE(JF.PARAM_ID,30046,JF.VALUE,NULL)) AS VALUE_BA_COMPASSES,
					  MIN(DECODE(JF.PARAM_ID,30047,JF.VALUE,NULL)) AS VALUE_BA_MICROMETR,
					  MIN(DECODE(JF.PARAM_ID,30048,JF.VALUE,NULL)) AS VALUE_AC_RACK,
					  MIN(DECODE(JF.PARAM_ID,30049,JF.VALUE,NULL)) AS VALUE_AC_COMPASSES,
					  MIN(DECODE(JF.PARAM_ID,30050,JF.VALUE,NULL)) AS VALUE_AC_MICROMETR,
					  MIN(DECODE(JF.PARAM_ID,30051,JF.VALUE,NULL)) AS VALUE_CA_RACK,
					  MIN(DECODE(JF.PARAM_ID,30052,JF.VALUE,NULL)) AS VALUE_CA_COMPASSES,
					  MIN(DECODE(JF.PARAM_ID,30053,JF.VALUE,NULL)) AS VALUE_CA_MICROMETR,
					  MIN(DECODE(JF.PARAM_ID,30054,JF.VALUE,NULL)) AS VALUE_BC_RACK,
					  MIN(DECODE(JF.PARAM_ID,30056,JF.VALUE,NULL)) AS VALUE_BC_COMPASSES,
					  MIN(DECODE(JF.PARAM_ID,30057,JF.VALUE,NULL)) AS VALUE_BC_MICROMETR,
					  MIN(DECODE(JF.PARAM_ID,30058,JF.VALUE,NULL)) AS VALUE_CB_RACK,
					  MIN(DECODE(JF.PARAM_ID,30059,JF.VALUE,NULL)) AS VALUE_CB_COMPASSES,
					  MIN(DECODE(JF.PARAM_ID,30060,JF.VALUE,NULL)) AS VALUE_CB_MICROMETR,
					  MIN(DECODE(JF.PARAM_ID,30061,JF.VALUE,NULL)) AS AVERAGE_AB_COMPASSES,
					  MIN(DECODE(JF.PARAM_ID,30062,JF.VALUE,NULL)) AS AVERAGE_AB_MICROMETR,
					  MIN(DECODE(JF.PARAM_ID,30063,JF.VALUE,NULL)) AS AVERAGE_AC_COMPASSES,
					  MIN(DECODE(JF.PARAM_ID,30064,JF.VALUE,NULL)) AS AVERAGE_AC_MICROMETR,
					  MIN(DECODE(JF.PARAM_ID,30065,JF.VALUE,NULL)) AS AVERAGE_BC_COMPASSES,
					  MIN(DECODE(JF.PARAM_ID,30066,JF.VALUE,NULL)) AS AVERAGE_BC_MICROMETR,
					  MIN(DECODE(JF.PARAM_ID,30067,JF.VALUE,NULL)) AS ERROR,
					  MIN(DECODE(JF.PARAM_ID,30024,JF.VALUE,NULL)) AS OPENING_X,
					  MIN(DECODE(JF.PARAM_ID,30025,JF.VALUE,NULL)) AS OPENING_Y,
					  MIN(DECODE(JF.PARAM_ID,30026,JF.VALUE,NULL)) AS OPENING_Z,
					  MIN(DECODE(JF.PARAM_ID,30069,JF.VALUE,NULL)) AS CURRENT_OPENING_X,
					  MIN(DECODE(JF.PARAM_ID,30070,JF.VALUE,NULL)) AS CURRENT_OPENING_Y,
					  MIN(DECODE(JF.PARAM_ID,30071,JF.VALUE,NULL)) AS CURRENT_OPENING_Z,
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
                  AND JF.MEASURE_TYPE_ID=GET_SLF_JOURNAL_FIELDS.MEASURE_TYPE_ID
                  AND JF.PARAM_ID IN (30042, /* �-� �� ������ */
				                      30043, /* �-� �� �������������� */
									  30044, /* �-� �� ���������� */
									  30045, /* �-� �� ������ */
									  30046, /* �-� �� �������������� */
									  30047, /* �-� �� ���������� */
									  30048, /* �-� �� ������ */
									  30049, /* �-� �� �������������� */
									  30050, /* �-� �� ���������� */
									  30051, /* �-� �� ������ */
									  30052, /* �-� �� �������������� */
									  30053, /* �-� �� ���������� */
									  30054, /* �-� �� ������ */
									  30056, /* �-� �� �������������� */
									  30057, /* �-� �� ���������� */
									  30058, /* �-� �� ������ */  
									  30059, /* �-� �� �������������� */
									  30060, /* �-� �� ���������� */
									  30061, /* �-� ������� �� �������������� */
									  30062, /* �-� ������� �� ���������� */
									  30063, /* �-� ������� �� �������������� */
									  30064, /* �-� ������� �� ���������� */
									  30065, /* �-� ������� �� �������������� */
									  30066, /* �-� ������� �� ���������� */
									  30067, /* ������� ���������� */
									  30024, /* ��������� � ������ ���������� �� X */
									  30069, /* ������� ��������� �� � */
									  30025, /* ��������� � ������ ���������� �� Y */
									  30070, /* ������� ��������� �� Y */
									  30026, /* ��������� � ������ ���������� �� Z */
									  30071 /* ������� ��������� �� Z */)
                  AND C.CYCLE_NUM>=NUM_MIN AND C.CYCLE_NUM<=NUM_MAX
 				  AND C.IS_CLOSE=GET_SLF_JOURNAL_FIELDS.IS_CLOSE								  
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
	INC2.VALUE_AB_RACK:=INC1.VALUE_AB_RACK;
	INC2.VALUE_AB_COMPASSES:=INC1.VALUE_AB_COMPASSES;
	INC2.VALUE_AB_MICROMETR:=INC1.VALUE_AB_MICROMETR;
	INC2.VALUE_BA_RACK:=INC1.VALUE_BA_RACK;
	INC2.VALUE_BA_COMPASSES:=INC1.VALUE_BA_COMPASSES;
	INC2.VALUE_BA_MICROMETR:=INC1.VALUE_BA_MICROMETR;
	INC2.VALUE_AC_RACK:=INC1.VALUE_AC_RACK;
	INC2.VALUE_AC_COMPASSES:=INC1.VALUE_AC_COMPASSES;
	INC2.VALUE_AC_MICROMETR:=INC1.VALUE_AC_MICROMETR;
	INC2.VALUE_CA_RACK:=INC1.VALUE_CA_RACK;
	INC2.VALUE_CA_COMPASSES:=INC1.VALUE_CA_COMPASSES;
	INC2.VALUE_CA_MICROMETR:=INC1.VALUE_CA_MICROMETR;
	INC2.VALUE_BC_RACK:=INC1.VALUE_BC_RACK;
	INC2.VALUE_BC_COMPASSES:=INC1.VALUE_BC_COMPASSES;
	INC2.VALUE_BC_MICROMETR:=INC1.VALUE_BC_MICROMETR;
	INC2.VALUE_CB_RACK:=INC1.VALUE_CB_RACK;
	INC2.VALUE_CB_COMPASSES:=INC1.VALUE_CB_COMPASSES;
	INC2.VALUE_CB_MICROMETR:=INC1.VALUE_CB_MICROMETR;
	INC2.AVERAGE_AB_COMPASSES:=INC1.AVERAGE_AB_COMPASSES;
	INC2.AVERAGE_AB_MICROMETR:=INC1.AVERAGE_AB_MICROMETR;
	INC2.AVERAGE_AC_COMPASSES:=INC1.AVERAGE_AC_COMPASSES;
	INC2.AVERAGE_AC_MICROMETR:=INC1.AVERAGE_AC_MICROMETR;
	INC2.AVERAGE_BC_COMPASSES:=INC1.AVERAGE_BC_COMPASSES;
	INC2.AVERAGE_BC_MICROMETR:=INC1.AVERAGE_BC_MICROMETR;
	INC2.ERROR:=INC1.ERROR;
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

CREATE MATERIALIZED VIEW S_SLF_JOURNAL_FIELDS_O1
NOLOGGING
NOCACHE
NOPARALLEL
BUILD DEFERRED
REFRESH COMPLETE
START WITH TO_DATE('01.06.2007','DD.MM.YYYY')
DISABLE QUERY REWRITE AS
SELECT * FROM TABLE(GET_SLF_JOURNAL_FIELDS(30010,1))

--

/* ���������� ��������� ������� � ������� ������� ������ ������ */

BEGIN
  DBMS_REFRESH.REFRESH('S_SLF_JOURNAL_FIELDS_O1');
END;

--

/* �������� ������� �� ���� ��������� ������������� � ������� ������� ������ ������ */

CREATE INDEX IDX_SLF_JF_O1_1
 ON S_SLF_JOURNAL_FIELDS_O1(CYCLE_ID)

--

/* �������� ������� �� ���� ���������� ��������� ������� � ������� ������� ������ ������ */

CREATE INDEX IDX_SLF_JF_O1_2
 ON S_SLF_JOURNAL_FIELDS_O1(DATE_OBSERVATION)

--

/* �������� ������� �� ��� ��������� ��������� ������� � ������� ������� ������ ������ */

CREATE INDEX IDX_SLF_JF_O1_3
 ON S_SLF_JOURNAL_FIELDS_O1(MEASURE_TYPE_ID)

--

/* �������� ��������� ������� � ������� ������� ����� ������ */

CREATE OR REPLACE VIEW S_SLF_JOURNAL_FIELDS_N1
AS
  SELECT * FROM TABLE(GET_SLF_JOURNAL_FIELDS(30010,0))

--

/* �������� ��������� ������� � ������� ������� */

CREATE OR REPLACE VIEW S_SLF_JOURNAL_FIELDS_1
AS
  SELECT JFO1.*
    FROM S_SLF_JOURNAL_FIELDS_O1 JFO1
   UNION
  SELECT JFN1.*
    FROM S_SLF_JOURNAL_FIELDS_N1 JFN1

--



/* �������� ��������� ������ ��� � ������� ������� ������ ������ */

CREATE MATERIALIZED VIEW S_SLF_JOURNAL_FIELDS_O2
NOLOGGING
NOCACHE
NOPARALLEL
BUILD DEFERRED
REFRESH COMPLETE
START WITH TO_DATE('01.06.2007','DD.MM.YYYY')
DISABLE QUERY REWRITE AS
SELECT * FROM TABLE(GET_SLF_JOURNAL_FIELDS(30011,1))

--

/* ���������� ��������� ������ ��� � ������� ������� ������ ������ */

BEGIN
  DBMS_REFRESH.REFRESH('S_SLF_JOURNAL_FIELDS_O2');
END;

--

/* �������� ������� �� ���� ��������� ������ ��� � ������� ������� ������ ������ */

CREATE INDEX IDX_SLF_JF_O2_1
 ON S_SLF_JOURNAL_FIELDS_O2(CYCLE_ID)

--

/* �������� ������� �� ���� ���������� ��������� ������ ��� � ������� ������� ������ ������ */

CREATE INDEX IDX_SLF_JF_O2_2
 ON S_SLF_JOURNAL_FIELDS_O2(DATE_OBSERVATION)

--

/* �������� ������� �� ��� ��������� ��������� ������ ��� � ������� ������� ������ ������ */

CREATE INDEX IDX_SLF_JF_O2_3
 ON S_SLF_JOURNAL_FIELDS_O2(MEASURE_TYPE_ID)

--

/* �������� ��������� ������ ��� � ������� ������� ����� ������ */

CREATE OR REPLACE VIEW S_SLF_JOURNAL_FIELDS_N2
AS
  SELECT * FROM TABLE(GET_SLF_JOURNAL_FIELDS(30011,0))

--

/* �������� ��������� ������ ��� � ������� ������� */

CREATE OR REPLACE VIEW S_SLF_JOURNAL_FIELDS_2
AS
  SELECT JFO2.*
    FROM S_SLF_JOURNAL_FIELDS_O2 JFO2
   UNION
  SELECT JFN2.*
    FROM S_SLF_JOURNAL_FIELDS_N2 JFN2

--


/* �������� ��������� ��������� �������� � ������� ������� */

CREATE OR REPLACE VIEW S_SLF_JOURNAL_FIELDS
AS
  SELECT JF1.*
    FROM S_SLF_JOURNAL_FIELDS_1 JF1
   UNION
  SELECT JF2.*
    FROM S_SLF_JOURNAL_FIELDS_2 JF2

--


/* �������� ��������� �� */

COMMIT