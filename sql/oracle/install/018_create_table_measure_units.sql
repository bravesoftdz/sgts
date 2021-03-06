/* �������� ������������������ ��� ������� ������ ��������� */

CREATE SEQUENCE SEQ_MEASURE_UNITS
INCREMENT BY 1 
START WITH 2500 
MAXVALUE 1.0E28 
MINVALUE 2500
NOCYCLE 
CACHE 20 
NOORDER

--

/* �������� ������ ��������� �������������� ��� ������� ������ ��������� */

CREATE OR REPLACE FUNCTION GET_MEASURE_UNIT_ID RETURN INTEGER IS
  ID INTEGER;
BEGIN
  SELECT SEQ_MEASURE_UNITS.NEXTVAL INTO ID FROM DUAL;
  RETURN ID;
END;

--

/* �������� ������� ������ ��������� */

CREATE TABLE MEASURE_UNITS
(
  MEASURE_UNIT_ID INTEGER NOT NULL, 
  NAME VARCHAR2(100) NOT NULL,
  DESCRIPTION VARCHAR2(250),
  PRIMARY KEY (MEASURE_UNIT_ID)
)

--

/* �������� ��������� ������� ������ ��������� */

CREATE VIEW S_MEASURE_UNITS
AS
  SELECT MU.*
    FROM MEASURE_UNITS MU

--

/* �������� ��������� �������� ������� ��������� */

CREATE OR REPLACE PROCEDURE I_MEASURE_UNIT
(
  MEASURE_UNIT_ID IN INTEGER,
  NAME IN VARCHAR2,
  DESCRIPTION IN VARCHAR2
)
AS
BEGIN
  INSERT INTO MEASURE_UNITS (MEASURE_UNIT_ID,NAME,DESCRIPTION)
       VALUES (MEASURE_UNIT_ID,NAME,DESCRIPTION);
  COMMIT;
END;

--

/* �������� ��������� ��������� ������� ��������� */

CREATE PROCEDURE U_MEASURE_UNIT
(
  MEASURE_UNIT_ID IN INTEGER,
  NAME IN VARCHAR2,
  DESCRIPTION IN VARCHAR2,
  OLD_MEASURE_UNIT_ID IN INTEGER
)
AS
BEGIN
  UPDATE MEASURE_UNITS 
     SET MEASURE_UNIT_ID=U_MEASURE_UNIT.MEASURE_UNIT_ID,
         NAME=U_MEASURE_UNIT.NAME, 
         DESCRIPTION=U_MEASURE_UNIT.DESCRIPTION 
   WHERE MEASURE_UNIT_ID=OLD_MEASURE_UNIT_ID;
  COMMIT;        
END;

--

/* �������� ��������� �������� ������� ��������� */

CREATE PROCEDURE D_MEASURE_UNIT
(
  OLD_MEASURE_UNIT_ID IN INTEGER
)
AS
BEGIN
  DELETE FROM MEASURE_UNITS
        WHERE MEASURE_UNIT_ID=OLD_MEASURE_UNIT_ID;
  COMMIT;        
END;

--

/* �������� ��������� �� */

COMMIT