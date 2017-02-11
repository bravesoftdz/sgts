/* �������� ������������������ ��� ������� ������ */

CREATE SEQUENCE SEQ_CYCLES
INCREMENT BY 1 
START WITH 2500
MAXVALUE 1.0E28 
MINVALUE 2500
NOCYCLE 
CACHE 20 
NOORDER

-- 

/* �������� ������ ��������� �������������� ��� ������� ������ */

CREATE FUNCTION GET_CYCLE_ID RETURN INTEGER IS
  ID INTEGER;
BEGIN
  SELECT SEQ_CYCLES.NEXTVAL INTO ID FROM DUAL;
  RETURN ID;
END;

--

/* �������� ������� ������ */


CREATE TABLE CYCLES 
(
CYCLE_ID INTEGER NOT NULL, 
CYCLE_NUM INTEGER NOT NULL,
CYCLE_YEAR INTEGER NOT NULL,
CYCLE_MONTH INTEGER NOT NULL,
DESCRIPTION VARCHAR2(250), 
IS_CLOSE INTEGER NOT NULL,
PRIMARY KEY (CYCLE_ID)
)  

--

/* �������� ������� �� ������ ����� ������� ������ */

CREATE INDEX IDX_CYCLES_1
 ON CYCLES(CYCLE_NUM)

--

/* �������� ������� �� ���������� ����� ������� ������ */

CREATE INDEX IDX_CYCLES_2
 ON CYCLES(IS_CLOSE)

--

/* �������� ��������� ������� ������ */

CREATE VIEW S_CYCLES 
AS 
  SELECT C.*
    FROM CYCLES C

--

/* �������� ��������� �������� ����� */

CREATE PROCEDURE I_CYCLE
(
  CYCLE_ID IN INTEGER,
  CYCLE_NUM IN INTEGER,
  CYCLE_YEAR IN INTEGER,
  CYCLE_MONTH IN INTEGER,
  DESCRIPTION IN VARCHAR2, 
  IS_CLOSE IN INTEGER
)
AS
BEGIN
  INSERT INTO CYCLES (CYCLE_ID,CYCLE_NUM,CYCLE_YEAR,CYCLE_MONTH,DESCRIPTION,IS_CLOSE)
       VALUES (CYCLE_ID,CYCLE_NUM,CYCLE_YEAR,CYCLE_MONTH,DESCRIPTION,IS_CLOSE);
END;

--

/* �������� ��������� ��������� ����� */

CREATE PROCEDURE U_CYCLE
(
  CYCLE_ID IN INTEGER,
  CYCLE_NUM IN INTEGER,
  CYCLE_YEAR IN INTEGER,
  CYCLE_MONTH IN INTEGER,
  DESCRIPTION IN VARCHAR2, 
  IS_CLOSE IN INTEGER,
  OLD_CYCLE_ID IN INTEGER
)
AS
BEGIN
  UPDATE CYCLES 
     SET CYCLE_ID=U_CYCLE.CYCLE_ID,
         CYCLE_NUM=U_CYCLE.CYCLE_NUM,
         CYCLE_YEAR=U_CYCLE.CYCLE_YEAR,
         CYCLE_MONTH=U_CYCLE.CYCLE_MONTH,
         DESCRIPTION=U_CYCLE.DESCRIPTION,
         IS_CLOSE=U_CYCLE.IS_CLOSE
   WHERE CYCLE_ID=OLD_CYCLE_ID;
  COMMIT;        
END;

--

/* �������� ��������� �������� ����� */

CREATE PROCEDURE D_CYCLE
(
  OLD_CYCLE_ID IN INTEGER
)
AS
BEGIN
  DELETE FROM CYCLES
        WHERE CYCLE_ID=OLD_CYCLE_ID;
  COMMIT;        
END;

--

/* �������� ��������� �� */

COMMIT