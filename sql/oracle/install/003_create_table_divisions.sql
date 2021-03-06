/* �������� ������������������ ��� ������� ������� */

CREATE SEQUENCE SEQ_DIVISIONS 
INCREMENT BY 1 
START WITH 2500
MAXVALUE 1.0E28 
MINVALUE 2500
NOCYCLE 
CACHE 20 
NOORDER

--

/* �������� ������� ��������� �������������� ��� ������� ������� */

CREATE FUNCTION GET_DIVISION_ID RETURN INTEGER IS
  ID INTEGER;
BEGIN
  SELECT SEQ_DIVISIONS.NEXTVAL INTO ID FROM DUAL;
  RETURN ID;
END;

--

/* �������� ������� ������� */

CREATE TABLE DIVISIONS
(
DIVISION_ID INTEGER NOT NULL, 
PARENT_ID INTEGER,
NAME VARCHAR2(50) NOT NULL,
DESCRIPTION VARCHAR2(250),
PRIORITY INTEGER NOT NULL,
PRIMARY KEY(DIVISION_ID),
FOREIGN KEY (PARENT_ID) REFERENCES DIVISIONS (DIVISION_ID) ON DELETE CASCADE
)

--

/* �������� ��������� ������� ������� */

CREATE OR REPLACE VIEW S_DIVISIONS
AS
    SELECT D1.*, D2.NAME AS PARENT_NAME, LEVEL AS "LEVEL"
      FROM DIVISIONS D1, DIVISIONS D2 
     WHERE D1.PARENT_ID=D2.DIVISION_ID (+)  
START WITH D1.PARENT_ID IS NULL
CONNECT BY D1.PARENT_ID=PRIOR D1.DIVISION_ID
  ORDER BY LEVEL, D1.PRIORITY

--

/* �������� ��������� �������� ������ */

CREATE OR REPLACE PROCEDURE I_DIVISION
(
  DIVISION_ID IN INTEGER,
  PARENT_ID IN INTEGER, 
  NAME IN VARCHAR2,
  DESCRIPTION IN VARCHAR2,
  PRIORITY IN INTEGER
)  
AS
BEGIN
  INSERT INTO DIVISIONS (DIVISION_ID,PARENT_ID,NAME,DESCRIPTION,PRIORITY) 
                 VALUES (DIVISION_ID,PARENT_ID,NAME,DESCRIPTION,PRIORITY);
  COMMIT;
END;

--

/* �������� ��������� �������� ������������� ������ */

CREATE OR REPLACE PROCEDURE A_DIVISION_PARENT_ID
(
  DIVISION_ID IN INTEGER,
  PARENT_ID IN INTEGER
)
AS
  CNT INTEGER;
  E EXCEPTION;
  ERROR VARCHAR2(500);
BEGIN
  IF (DIVISION_ID=PARENT_ID) THEN
    ERROR:='����� �� ����� ��������� ��� �� ����.';
    RAISE E;
  END IF;
  
  SELECT COUNT(*) INTO CNT FROM DUAL
   WHERE PARENT_ID IN (SELECT D1.DIVISION_ID
                         FROM DIVISIONS D1, DIVISIONS D2 
                        WHERE D1.PARENT_ID=D2.DIVISION_ID (+)  
                   START WITH D1.DIVISION_ID=A_DIVISION_PARENT_ID.DIVISION_ID
                   CONNECT BY D1.PARENT_ID=PRIOR D1.DIVISION_ID);
		
  IF (CNT>0) THEN
    ERROR:='����� �� ����� ��������� �� �������� ������.';
    RAISE E;
  END IF;
  
EXCEPTION
  WHEN E THEN 
       RAISE_APPLICATION_ERROR(-20100,ERROR);
END;

--

/* �������� ��������� ��������� ������ */

CREATE OR REPLACE PROCEDURE U_DIVISION
(
  DIVISION_ID IN INTEGER,
  PARENT_ID IN INTEGER,
  NAME IN VARCHAR2, 
  DESCRIPTION IN VARCHAR2,
  PRIORITY IN INTEGER,
  OLD_DIVISION_ID IN INTEGER
)
AS
BEGIN
  A_DIVISION_PARENT_ID(DIVISION_ID,PARENT_ID);
  UPDATE DIVISIONS 
     SET DIVISION_ID=U_DIVISION.DIVISION_ID,
	     PARENT_ID=U_DIVISION.PARENT_ID,
         NAME=U_DIVISION.NAME,
         DESCRIPTION=U_DIVISION.DESCRIPTION,
		 PRIORITY=U_DIVISION.PRIORITY 
   WHERE DIVISION_ID=OLD_DIVISION_ID;
  COMMIT;        
END;

--

/* �������� ��������� �������� ������ */

CREATE OR REPLACE PROCEDURE D_DIVISION
(
  OLD_DIVISION_ID IN INTEGER
)
AS
BEGIN
  DELETE FROM DIVISIONS
        WHERE DIVISION_ID=OLD_DIVISION_ID;
  COMMIT;        
END;

--

/* �������� ��������� �� */

COMMIT
