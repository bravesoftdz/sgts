/* �������� ������������������ ��� ������� ��������� �������� */

CREATE SEQUENCE SEQ_OBJECT_PASSPORTS
INCREMENT BY 1 
START WITH 2500 
MAXVALUE 1.0E28 
MINVALUE 2500
NOCYCLE 
CACHE 20 
NOORDER

--

/* �������� ������ ��������� �������������� ��� ������� ��������� �������� */

CREATE OR REPLACE FUNCTION GET_OBJECT_PASSPORT_ID RETURN INTEGER IS
  ID INTEGER;
BEGIN
  SELECT SEQ_OBJECT_PASSPORTS.NEXTVAL INTO ID FROM DUAL;
  RETURN ID;
END;

--

/* �������� ������� ��������� �������� */


CREATE TABLE OBJECT_PASSPORTS
(
  OBJECT_PASSPORT_ID INTEGER NOT NULL, 
  OBJECT_ID INTEGER NOT NULL,
  DATE_PASSPORT DATE NOT NULL,
  PARAM_NAME VARCHAR2(100),
  VALUE FLOAT,  
  DESCRIPTION VARCHAR2(250),
  PRIMARY KEY (OBJECT_PASSPORT_ID),
  FOREIGN KEY (OBJECT_ID) REFERENCES OBJECTS (OBJECT_ID)
)

--

/* �������� ��������� ������� ��������� �������� */

CREATE OR REPLACE VIEW S_OBJECT_PASSPORTS
AS
  SELECT OP.*, 
         O.NAME AS OBJECT_NAME
    FROM OBJECT_PASSPORTS OP, OBJECTS O
   WHERE OP.OBJECT_ID=O.OBJECT_ID

--

/* �������� ��������� �������� �������� ������� */

CREATE OR REPLACE PROCEDURE I_OBJECT_PASSPORT
(
  OBJECT_PASSPORT_ID IN INTEGER,
  OBJECT_ID IN INTEGER,
  DATE_PASSPORT IN DATE,
  PARAM_NAME IN VARCHAR2,
  VALUE IN FLOAT,  
  DESCRIPTION IN VARCHAR2
)
AS
BEGIN
  INSERT INTO OBJECT_PASSPORTS (OBJECT_PASSPORT_ID,OBJECT_ID,DATE_PASSPORT,
                                PARAM_NAME,VALUE,DESCRIPTION)
       VALUES (OBJECT_PASSPORT_ID,OBJECT_ID,DATE_PASSPORT,
               PARAM_NAME,VALUE,DESCRIPTION);
  COMMIT;
END;

--

/* �������� ��������� ��������� �������� ������� */

CREATE OR REPLACE PROCEDURE U_OBJECT_PASSPORT
(
  OBJECT_PASSPORT_ID IN INTEGER,
  OBJECT_ID IN INTEGER,
  DATE_PASSPORT IN DATE,
  PARAM_NAME IN VARCHAR2,
  VALUE IN FLOAT,  
  DESCRIPTION IN VARCHAR2,
  OLD_OBJECT_PASSPORT_ID IN INTEGER
)
AS
BEGIN
  UPDATE OBJECT_PASSPORTS 
     SET OBJECT_PASSPORT_ID=U_OBJECT_PASSPORT.OBJECT_PASSPORT_ID,
	     OBJECT_ID=U_OBJECT_PASSPORT.OBJECT_ID,
		 DATE_PASSPORT=U_OBJECT_PASSPORT.DATE_PASSPORT,
		 PARAM_NAME=U_OBJECT_PASSPORT.PARAM_NAME,
		 VALUE=U_OBJECT_PASSPORT.VALUE,
         DESCRIPTION=U_OBJECT_PASSPORT.DESCRIPTION 
   WHERE OBJECT_PASSPORT_ID=OLD_OBJECT_PASSPORT_ID;
  COMMIT;        
END;

--

/* �������� ��������� �������� ������� */

CREATE OR REPLACE PROCEDURE D_OBJECT_PASSPORT
(
  OLD_OBJECT_PASSPORT_ID IN INTEGER
)
AS
BEGIN
  DELETE FROM OBJECT_PASSPORTS
        WHERE OBJECT_PASSPORT_ID=OLD_OBJECT_PASSPORT_ID;
  COMMIT;        
END;

--

/* �������� ��������� �� */

COMMIT