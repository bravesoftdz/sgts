/* �������� ������� ������ */

CREATE TABLE CUTS 
(
  CUT_ID INTEGER NOT NULL,
  NAME VARCHAR2(100) NOT NULL,
  DESCRIPTION VARCHAR2(250), 
  VIEW_NAME VARCHAR2(100) NOT NULL,
  PROC_NAME VARCHAR2(100),
  DETERMINATION CLOB NOT NULL,
  CONDITION VARCHAR2(250),
  PRIORITY INTEGER NOT NULL,
  PRIMARY KEY (CUT_ID),
  FOREIGN KEY (CUT_ID) REFERENCES MEASURE_TYPES (MEASURE_TYPE_ID)
)

--

/* �������� ��������� ������� ������ */

CREATE OR REPLACE VIEW S_CUTS
AS
  SELECT C.*, 
		 MT.NAME AS MEASURE_TYPE_NAME
    FROM CUTS C, MEASURE_TYPES MT
   WHERE C.CUT_ID=MT.MEASURE_TYPE_ID

--

/* �������� ��������� �������� ����� */

CREATE OR REPLACE PROCEDURE I_CUT
(
  CUT_ID IN INTEGER,
  NAME IN VARCHAR2,
  DESCRIPTION IN VARCHAR2,
  VIEW_NAME IN VARCHAR2,
  DETERMINATION IN CLOB,
  CONDITION IN VARCHAR2,
  PROC_NAME IN VARCHAR2,
  PRIORITY IN INTEGER
)
AS
BEGIN
  INSERT INTO CUTS (CUT_ID,VIEW_NAME,NAME,DESCRIPTION,DETERMINATION,CONDITION,
                    PROC_NAME,PRIORITY)
       VALUES (CUT_ID,VIEW_NAME,NAME,DESCRIPTION,DETERMINATION,CONDITION,
	           PROC_NAME,PRIORITY);
	   
  COMMIT;
END;

--

/* �������� ��������� ��������� ����� */

CREATE OR REPLACE PROCEDURE U_CUT
(
  CUT_ID IN INTEGER,
  NAME IN VARCHAR2,
  DESCRIPTION IN VARCHAR2,
  VIEW_NAME IN VARCHAR2,
  DETERMINATION IN CLOB,
  CONDITION IN VARCHAR2,
  PROC_NAME IN VARCHAR2,
  PRIORITY IN INTEGER,
  OLD_CUT_ID IN INTEGER
)
AS
BEGIN
  UPDATE CUTS 
     SET CUT_ID=U_CUT.CUT_ID,
         VIEW_NAME=U_CUT.VIEW_NAME,
         NAME=U_CUT.NAME,
		 DESCRIPTION=U_CUT.DESCRIPTION,
		 DETERMINATION=U_CUT.DETERMINATION,
		 CONDITION=U_CUT.CONDITION,
		 PROC_NAME=U_CUT.PROC_NAME,
		 PRIORITY=U_CUT.PRIORITY
   WHERE CUT_ID=OLD_CUT_ID;
  COMMIT;        
END;

--

/* �������� ��������� �������� ����� */

CREATE OR REPLACE PROCEDURE D_CUT
(
  OLD_CUT_ID IN INTEGER
)
AS
BEGIN
  DELETE FROM CUTS
        WHERE CUT_ID=OLD_CUT_ID;
  COMMIT;        
END;

--

/* �������� ��������� �� */

COMMIT