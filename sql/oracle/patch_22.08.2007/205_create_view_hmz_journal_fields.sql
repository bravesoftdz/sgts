/* �������� ���� ������� ���������� �������� ������� */

CREATE OR REPLACE TYPE HMZ_JOURNAL_FIELD_OBJECT AS OBJECT
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
  SECTION VARCHAR2(100),
  PH FLOAT,
  CO2SV FLOAT,
  CO3_2 FLOAT,
  CO2AGG FLOAT,
  ALKALI FLOAT,
  ACERBITY FLOAT,
  CA FLOAT,
  MG FLOAT,
  CL FLOAT,
  SO4_2 FLOAT,
  HCO3 FLOAT,
  NA_K FLOAT,
  AGGRESSIV FLOAT
)

--

/* �������� ���� ������� ���������� �������� ������� */

CREATE OR REPLACE TYPE HMZ_JOURNAL_FIELD_TABLE 
AS TABLE OF HMZ_JOURNAL_FIELD_OBJECT

--

/* �������� ������� ��������� ���������� � ������� ������� */

CREATE OR REPLACE FUNCTION GET_HMZ_JOURNAL_FIELDS
(
  MEASURE_TYPE_ID INTEGER,
  IS_CLOSE INTEGER
)
RETURN HMZ_JOURNAL_FIELD_TABLE
PIPELINED
IS
  INC2 HMZ_JOURNAL_FIELD_OBJECT:=HMZ_JOURNAL_FIELD_OBJECT(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
                                                          NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
														  NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
  FLAG INTEGER:=0;
  OLD_GROUP_ID VARCHAR2(32):='';
  NUM_MIN INTEGER:=NULL;
  NUM_MAX INTEGER:=NULL;
BEGIN
  FOR INC IN (SELECT MIN(CYCLE_NUM) AS NUM_MIN, MAX(CYCLE_NUM) AS NUM_MAX 
                FROM CYCLES
               WHERE IS_CLOSE=GET_HMZ_JOURNAL_FIELDS.IS_CLOSE) LOOP
    NUM_MIN:=INC.NUM_MIN;
	NUM_MAX:=INC.NUM_MAX;    			   
    EXIT;			   
  END LOOP;			    
   
  FOR INC1 IN (SELECT /*+ INDEX (JF) INDEX (C) INDEX (P) INDEX (RP) INDEX (CR) */
                      JF.DATE_OBSERVATION, 
                      JF.VALUE, 
                      JF.MEASURE_TYPE_ID,
                      JF.CYCLE_ID,
                      C.CYCLE_NUM,
                      JF.POINT_ID,
                      P.NAME AS POINT_NAME,
                      CR.CONVERTER_ID,
                      CR.NAME AS CONVERTER_NAME,
                      JF.GROUP_ID,
                      JF.PARAM_ID 
                 FROM JOURNAL_FIELDS JF, CYCLES C, POINTS P,
                      ROUTE_POINTS RP, CONVERTERS CR
                WHERE JF.CYCLE_ID=C.CYCLE_ID
                  AND JF.POINT_ID=P.POINT_ID
                  AND RP.POINT_ID=JF.POINT_ID
                  AND CR.CONVERTER_ID=P.POINT_ID 
                  AND JF.MEASURE_TYPE_ID=GET_HMZ_JOURNAL_FIELDS.MEASURE_TYPE_ID
                  AND JF.PARAM_ID IN (3060, /* pH */
                                      3061, /* CO2 �� */
                                      3062, /* CO3(-2) */
                                      3063, /* CO2 ��� */
                                      3065, /* ���������� */
                                      3066, /* ��������� */
                                      3067, /* Ca(+) */
                                      3068, /* Mg(+) */
                                      3069, /* Cl(-) */
                                      3070, /* SO4(-2) */
                                      3071, /* HCO3(-) */
                                      3072, /* Na(+)+K(+) */
                                      3100 /* ������������� */)
                  AND C.CYCLE_NUM>=NUM_MIN AND C.CYCLE_NUM<=NUM_MAX
				  AND C.IS_CLOSE=GET_HMZ_JOURNAL_FIELDS.IS_CLOSE								  
                ORDER BY JF.DATE_OBSERVATION, JF.GROUP_ID, RP.PRIORITY) LOOP
    IF (FLAG=0) THEN
	  OLD_GROUP_ID:=INC1.GROUP_ID;
	  FLAG:=1;
	END IF;
    IF (OLD_GROUP_ID<>INC1.GROUP_ID) THEN
	  OLD_GROUP_ID:=INC1.GROUP_ID;
	  PIPE ROW (INC2); 
	END IF;
    INC2.CYCLE_ID:=INC1.CYCLE_ID;
    INC2.CYCLE_NUM:=INC1.CYCLE_NUM;
	INC2.DATE_OBSERVATION:=INC1.DATE_OBSERVATION;
	INC2.MEASURE_TYPE_ID:=INC1.MEASURE_TYPE_ID;
	INC2.POINT_ID:=INC1.POINT_ID;
	INC2.POINT_NAME:=INC1.POINT_NAME;
	INC2.CONVERTER_ID:=INC1.CONVERTER_ID;
	INC2.CONVERTER_NAME:=INC1.CONVERTER_NAME;
	
	IF (OLD_GROUP_ID=INC1.GROUP_ID) THEN
	
      INC2.MARK:=0;
      FOR INC IN (SELECT CP.VALUE,
   	                     CP.DATE_BEGIN,
                         CP.DATE_END
                    FROM CONVERTER_PASSPORTS CP, COMPONENTS C
                   WHERE CP.COMPONENT_ID=C.COMPONENT_ID
                     AND C.CONVERTER_ID=INC1.CONVERTER_ID
                     AND C.PARAM_ID=3002 /* ������� ������� */
                   ORDER BY CP.DATE_BEGIN) LOOP
        INC2.MARK:=TO_NUMBER(REPLACE(INC.VALUE,',','.'),'FM999.999');
  	    EXIT WHEN (INC1.DATE_OBSERVATION>=INC.DATE_BEGIN) AND (INC1.DATE_OBSERVATION<=INC.DATE_END);
      END LOOP;
  	
      INC2.SECTION:='';
      FOR INC IN (SELECT CP.VALUE,
   	                     CP.DATE_BEGIN,
                         CP.DATE_END
                    FROM CONVERTER_PASSPORTS CP, COMPONENTS C
                   WHERE CP.COMPONENT_ID=C.COMPONENT_ID
                     AND C.CONVERTER_ID=INC1.CONVERTER_ID
                     AND C.PARAM_ID=3003 /* ������ ������� */
                   ORDER BY CP.DATE_BEGIN) LOOP
        INC2.SECTION:=INC.VALUE;
  	    EXIT WHEN (INC1.DATE_OBSERVATION>=INC.DATE_BEGIN) AND (INC1.DATE_OBSERVATION<=INC.DATE_END);
      END LOOP;
  	
	  IF (INC1.PARAM_ID=3060) THEN INC2.PH:=INC1.VALUE; END IF;
	  IF (INC1.PARAM_ID=3061) THEN INC2.CO2SV:=INC1.VALUE; END IF;
	  IF (INC1.PARAM_ID=3062) THEN INC2.CO3_2:=INC1.VALUE; END IF;
	  IF (INC1.PARAM_ID=3063) THEN INC2.CO2AGG:=INC1.VALUE; END IF;
	  IF (INC1.PARAM_ID=3065) THEN INC2.ALKALI:=INC1.VALUE; END IF;
	  IF (INC1.PARAM_ID=3066) THEN INC2.ACERBITY:=INC1.VALUE; END IF;
	  IF (INC1.PARAM_ID=3067) THEN INC2.CA:=INC1.VALUE; END IF;
	  IF (INC1.PARAM_ID=3068) THEN INC2.MG:=INC1.VALUE; END IF;
	  IF (INC1.PARAM_ID=3069) THEN INC2.CL:=INC1.VALUE; END IF;
	  IF (INC1.PARAM_ID=3070) THEN INC2.SO4_2:=INC1.VALUE; END IF;
	  IF (INC1.PARAM_ID=3071) THEN INC2.HCO3:=INC1.VALUE; END IF;
	  IF (INC1.PARAM_ID=3072) THEN INC2.NA_K:=INC1.VALUE; END IF;
	  IF (INC1.PARAM_ID=3100) THEN INC2.AGGRESSIV:=INC1.VALUE; END IF;
	  						
	END IF;
	OLD_GROUP_ID:=INC1.GROUP_ID;
  END LOOP;
  IF (FLAG=1) THEN
    PIPE ROW (INC2);
  END IF;
  RETURN;
END;

--



/* �������� ��������� ���������� � ������� ������� ������ ������ */

CREATE MATERIALIZED VIEW S_HMZ_JOURNAL_FIELDS_O
NOLOGGING
NOCACHE
NOPARALLEL
BUILD DEFERRED
REFRESH COMPLETE
START WITH TO_DATE('01.06.2007','DD.MM.YYYY')
DISABLE QUERY REWRITE AS
SELECT * FROM TABLE(GET_HMZ_JOURNAL_FIELDS(2600,1))

--

/* ���������� ��������� ���������� � ������� ������� ������ ������ */

BEGIN
  DBMS_REFRESH.REFRESH('S_HMZ_JOURNAL_FIELDS_O');
END;

--

/* �������� ��������� �� */

COMMIT

--

/* �������� ������� �� ���� ��������� ���������� � ������� ������� ������ ������ */

CREATE INDEX IDX_HMZ_JF_O_1
 ON S_HMZ_JOURNAL_FIELDS_O(CYCLE_ID)

--

/* �������� ������� �� ���� ���������� ��������� ���������� � ������� ������� ������ ������ */

CREATE INDEX IDX_HMZ_JF_O_2
 ON S_HMZ_JOURNAL_FIELDS_O(DATE_OBSERVATION)

--

/* �������� ������� �� ��� ��������� ��������� ���������� � ������� ������� ������ ������ */

CREATE INDEX IDX_HMZ_JF_O_3
 ON S_HMZ_JOURNAL_FIELDS_O(MEASURE_TYPE_ID)

--

/* �������� ��������� ���������� � ������� ������� ����� ������ */

CREATE OR REPLACE VIEW S_HMZ_JOURNAL_FIELDS_N
AS
  SELECT * FROM TABLE(GET_HMZ_JOURNAL_FIELDS(2600,0))

--

/* �������� ��������� ���������� � ������� ������� */

CREATE OR REPLACE VIEW S_HMZ_JOURNAL_FIELDS
AS
  SELECT JFO.*
    FROM S_HMZ_JOURNAL_FIELDS_O JFO
   UNION
  SELECT JFN.*
    FROM S_HMZ_JOURNAL_FIELDS_N JFN

--

/* �������� ��������� �� */

COMMIT
