/* �������� ��������� ���������� �������� ������������ */

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

/* �������� ��������� */

COMMIT
