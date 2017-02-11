/* �������� ������������������ ��� ������� ��������� ������������ */

CREATE SEQUENCE SEQ_CRITERIAS
INCREMENT BY 1 
START WITH 2900 
MAXVALUE 1.0E28 
MINVALUE 2900
NOCYCLE 
CACHE 20 
NOORDER

--

/* �������� ������ ��������� �������������� ��� ������� ��������� ������������ */

CREATE OR REPLACE FUNCTION GET_CRITERIA_ID RETURN INTEGER IS
  ID INTEGER;
BEGIN
  SELECT SEQ_CRITERIAS.NEXTVAL INTO ID FROM DUAL;
  RETURN ID;
END;

--

/* �������� ������� ��������� ������������ */

CREATE TABLE CRITERIAS
(
  CRITERIA_ID INTEGER NOT NULL,
  ALGORITHM_ID INTEGER NOT NULL,
  MEASURE_UNIT_ID INTEGER,
  NAME VARCHAR2(250) NOT NULL,
  DESCRIPTION VARCHAR2(250),
  FIRST_MIN_VALUE FLOAT NOT NULL,
  FIRST_MAX_VALUE FLOAT,
  FIRST_MODULO INTEGER NOT NULL,
  SECOND_MIN_VALUE FLOAT NOT NULL,
  SECOND_MAX_VALUE FLOAT,
  SECOND_MODULO INTEGER NOT NULL,
  ENABLED INTEGER NOT NULL,
  PRIORITY INTEGER NOT NULL,
  PRIMARY KEY (CRITERIA_ID),
  FOREIGN KEY (ALGORITHM_ID) REFERENCES ALGORITHMS (ALGORITHM_ID),
  FOREIGN KEY (MEASURE_UNIT_ID) REFERENCES MEASURE_UNITS (MEASURE_UNIT_ID)
)

--

/* �������� ��������� ������� ��������� ������������ */

CREATE OR REPLACE VIEW S_CRITERIAS
AS
  SELECT C.*, 
         A.NAME AS ALGORITHM_NAME,
         A.PROC_NAME,
		 M.NAME AS MEASURE_UNIT_NAME
    FROM CRITERIAS C, ALGORITHMS A, MEASURE_UNITS M
   WHERE C.ALGORITHM_ID=A.ALGORITHM_ID
     AND C.MEASURE_UNIT_ID=M.MEASURE_UNIT_ID(+)

--

/* �������� ��������� �������� �������� ������������ */

CREATE OR REPLACE PROCEDURE I_CRITERIA
(
  CRITERIA_ID IN INTEGER,
  ALGORITHM_ID IN INTEGER,
  MEASURE_UNIT_ID IN INTEGER,
  NAME IN VARCHAR2,
  DESCRIPTION IN VARCHAR2,
  FIRST_MIN_VALUE IN FLOAT,
  FIRST_MAX_VALUE IN FLOAT,
  FIRST_MODULO IN INTEGER,
  SECOND_MIN_VALUE IN FLOAT,
  SECOND_MAX_VALUE IN FLOAT,
  SECOND_MODULO IN INTEGER,
  ENABLED IN INTEGER,
  PRIORITY IN INTEGER
)
AS
BEGIN
  INSERT INTO CRITERIAS (CRITERIA_ID,ALGORITHM_ID,MEASURE_UNIT_ID,NAME,DESCRIPTION,
                         FIRST_MIN_VALUE,FIRST_MAX_VALUE,FIRST_MODULO,
						 SECOND_MIN_VALUE,SECOND_MAX_VALUE,SECOND_MODULO,  
                         ENABLED,PRIORITY)
       VALUES (CRITERIA_ID,ALGORITHM_ID,MEASURE_UNIT_ID,NAME,DESCRIPTION,
               FIRST_MIN_VALUE,FIRST_MAX_VALUE,FIRST_MODULO,
			   SECOND_MIN_VALUE,SECOND_MAX_VALUE,SECOND_MODULO,  
	           ENABLED,PRIORITY);
  COMMIT;
END;

--

/* �������� ��������� ��������� �������� ������������ */

CREATE OR REPLACE PROCEDURE U_CRITERIA
(
  CRITERIA_ID IN INTEGER,
  ALGORITHM_ID IN INTEGER,
  MEASURE_UNIT_ID IN INTEGER,
  NAME IN VARCHAR2,
  DESCRIPTION IN VARCHAR2,
  FIRST_MIN_VALUE IN FLOAT,
  FIRST_MAX_VALUE IN FLOAT,
  FIRST_MODULO IN INTEGER,
  SECOND_MIN_VALUE IN FLOAT,
  SECOND_MAX_VALUE IN FLOAT,
  SECOND_MODULO IN INTEGER,
  ENABLED IN INTEGER,
  PRIORITY IN INTEGER,
  OLD_CRITERIA_ID IN INTEGER
)
AS
BEGIN
  UPDATE CRITERIAS 
     SET CRITERIA_ID=U_CRITERIA.CRITERIA_ID,
	     ALGORITHM_ID=U_CRITERIA.ALGORITHM_ID,
		 MEASURE_UNIT_ID=U_CRITERIA.MEASURE_UNIT_ID,
         NAME=U_CRITERIA.NAME,
         DESCRIPTION=U_CRITERIA.DESCRIPTION,
		 FIRST_MIN_VALUE=U_CRITERIA.FIRST_MIN_VALUE,
		 FIRST_MAX_VALUE=U_CRITERIA.FIRST_MAX_VALUE,
		 FIRST_MODULO=U_CRITERIA.FIRST_MODULO,
		 SECOND_MIN_VALUE=U_CRITERIA.SECOND_MIN_VALUE,
		 SECOND_MAX_VALUE=U_CRITERIA.SECOND_MAX_VALUE,
		 SECOND_MODULO=U_CRITERIA.SECOND_MODULO,
		 ENABLED=U_CRITERIA.ENABLED,
		 PRIORITY=U_CRITERIA.PRIORITY
   WHERE CRITERIA_ID=OLD_CRITERIA_ID;
  COMMIT;        
END;

--

/* �������� ��������� �������� �������� ������������ */

CREATE PROCEDURE D_CRITERIA
(
  OLD_CRITERIA_ID IN INTEGER
)
AS
BEGIN
  DELETE FROM CRITERIAS
        WHERE CRITERIA_ID=OLD_CRITERIA_ID;
  COMMIT;        
END;

--

/* �������� ��������� �� */

COMMIT