/* �������� ��������� ���������� ����� */

CREATE OR REPLACE PROCEDURE I_PLAN
( 
  MEASURE_TYPE_ID IN INTEGER, 
  CYCLE_ID IN INTEGER, 
  DATE_BEGIN IN DATE, 
  DATE_END IN DATE 
) 
AS 
BEGIN 
  INSERT INTO PLANS (MEASURE_TYPE_ID,CYCLE_ID,DATE_BEGIN,DATE_END) 
       VALUES (MEASURE_TYPE_ID,CYCLE_ID,DATE_BEGIN,DATE_END); 
  COMMIT; 
END;

--

/* �������� ��������� */

COMMIT