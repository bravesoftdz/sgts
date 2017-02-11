/* �������� ������� ������� ���������� */

CREATE TABLE PARAM_LEVELS 
(
  PARAM_ID INTEGER NOT NULL, 
  LEVEL_ID INTEGER NOT NULL, 
  LEVEL_MIN FLOAT NOT NULL,
  LEVEL_MAX FLOAT NOT NULL,
  PRIMARY KEY (PARAM_ID,LEVEL_ID),
  FOREIGN KEY (PARAM_ID) REFERENCES PARAMS (PARAM_ID),
  FOREIGN KEY (LEVEL_ID) REFERENCES LEVELS (LEVEL_ID)
)

--

/* �������� ��������� ������� ������� ���������� */

CREATE VIEW S_PARAM_LEVELS
AS
  SELECT PL.*, 
         P.NAME AS PARAM_NAME, 
         L.NAME AS LEVEL_NAME
    FROM PARAM_LEVELS PL, PARAMS P, LEVELS L
   WHERE P.PARAM_ID=PL.PARAM_ID 
     AND L.LEVEL_ID=PL.LEVEL_ID

--

/* �������� ��������� ���������� ������ ��������� */

CREATE PROCEDURE I_PARAM_LEVEL
(
  PARAM_ID IN INTEGER,
  LEVEL_ID IN INTEGER,
  LEVEL_MIN IN FLOAT,
  LEVEL_MAX IN FLOAT
)
AS
BEGIN
  INSERT INTO PARAM_LEVELS (PARAM_ID,LEVEL_ID,LEVEL_MIN,LEVEL_MAX)
       VALUES (PARAM_ID,LEVEL_ID,LEVEL_MIN,LEVEL_MAX);
  COMMIT;
END;

--

/* �������� ��������� ��������� ������ ��������� */

CREATE OR REPLACE PROCEDURE U_PARAM_LEVEL
(
  PARAM_ID IN INTEGER,
  LEVEL_ID IN INTEGER,
  LEVEL_MIN IN FLOAT,
  LEVEL_MAX IN FLOAT,
  OLD_PARAM_ID IN INTEGER,
  OLD_LEVEL_ID IN INTEGER
)
AS
BEGIN
  UPDATE PARAM_LEVELS 
     SET PARAM_ID=U_PARAM_LEVEL.PARAM_ID,
         LEVEL_ID=U_PARAM_LEVEL.LEVEL_ID,
         LEVEL_MIN=U_PARAM_LEVEL.LEVEL_MIN,
         LEVEL_MAX=U_PARAM_LEVEL.LEVEL_MAX
   WHERE PARAM_ID=OLD_PARAM_ID 
     AND LEVEL_ID=OLD_LEVEL_ID;
  COMMIT;        
END;

--

/* �������� ��������� �������� ������ ��������� */

CREATE PROCEDURE D_PARAM_LEVEL
(
  OLD_PARAM_ID IN INTEGER,
  OLD_LEVEL_ID IN INTEGER
)
AS
BEGIN
  DELETE FROM PARAM_LEVELS
        WHERE PARAM_ID=OLD_PARAM_ID
          AND LEVEL_ID=OLD_LEVEL_ID;
  COMMIT;        
END;

--

/* �������� ��������� �� */

COMMIT