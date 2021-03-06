/* ���������� ������� �� ������������ ��� ����������� � ������� ���������� */

ALTER TABLE PARAMS
ADD IS_NOT_CONFIRM INTEGER

--

/* ���������� ������� ���������� */

BEGIN
  UPDATE PARAMS
     SET IS_NOT_CONFIRM=0;
  COMMIT;
END;

--

/* �������� ��������� ������� ���������� */

CREATE OR REPLACE VIEW S_PARAMS
AS
  SELECT P.*, 
         A.NAME AS ALGORITHM_NAME
    FROM PARAMS P, ALGORITHMS A 
   WHERE P.ALGORITHM_ID=A.ALGORITHM_ID (+)


--

/* �������� ��������� �������� ��������� */

CREATE OR REPLACE PROCEDURE I_PARAM
(
  PARAM_ID IN INTEGER,
  ALGORITHM_ID IN INTEGER,
  NAME IN VARCHAR2,
  DESCRIPTION IN VARCHAR2,
  PARAM_TYPE IN INTEGER,
  FORMAT IN VARCHAR2,
  DETERMINATION IN CLOB,
  IS_NOT_CONFIRM IN INTEGER
)
AS
BEGIN
  INSERT INTO PARAMS (PARAM_ID,ALGORITHM_ID,NAME,DESCRIPTION,PARAM_TYPE,FORMAT,DETERMINATION,IS_NOT_CONFIRM)
       VALUES (PARAM_ID,ALGORITHM_ID,NAME,DESCRIPTION,PARAM_TYPE,FORMAT,DETERMINATION,IS_NOT_CONFIRM);
  COMMIT;
END;

--

/* �������� ��������� ��������� ��������� */


CREATE OR REPLACE PROCEDURE U_PARAM
(
  PARAM_ID IN INTEGER,
  ALGORITHM_ID IN INTEGER,
  NAME IN VARCHAR2,
  DESCRIPTION IN VARCHAR2,
  PARAM_TYPE IN INTEGER,
  FORMAT IN VARCHAR2,
  DETERMINATION IN CLOB,
  IS_NOT_CONFIRM IN INTEGER,
  OLD_PARAM_ID IN INTEGER
)
AS
BEGIN
  UPDATE PARAMS 
     SET PARAM_ID=U_PARAM.PARAM_ID,
         ALGORITHM_ID=U_PARAM.ALGORITHM_ID,
         NAME=U_PARAM.NAME,
         DESCRIPTION=U_PARAM.DESCRIPTION,
         PARAM_TYPE=U_PARAM.PARAM_TYPE,
		 FORMAT=U_PARAM.FORMAT,
		 DETERMINATION=U_PARAM.DETERMINATION,
		 IS_NOT_CONFIRM=U_PARAM.IS_NOT_CONFIRM
   WHERE PARAM_ID=OLD_PARAM_ID;
  COMMIT;        
END;

--

/* �������� ��������� �� */

COMMIT