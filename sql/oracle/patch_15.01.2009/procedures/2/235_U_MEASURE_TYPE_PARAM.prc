/* �������� ��������� ��������� ��������� ���� ��������� */

CREATE OR REPLACE PROCEDURE U_MEASURE_TYPE_PARAM
( 
  MEASURE_TYPE_ID IN INTEGER, 
  PARAM_ID IN INTEGER, 
  PRIORITY IN INTEGER, 
  OLD_MEASURE_TYPE_ID IN INTEGER, 
  OLD_PARAM_ID IN INTEGER 
) 
AS 
BEGIN 
  UPDATE MEASURE_TYPE_PARAMS  
     SET MEASURE_TYPE_ID=U_MEASURE_TYPE_PARAM.MEASURE_TYPE_ID, 
         PARAM_ID=U_MEASURE_TYPE_PARAM.PARAM_ID, 
         PRIORITY=U_MEASURE_TYPE_PARAM.PRIORITY 
   WHERE MEASURE_TYPE_ID=OLD_MEASURE_TYPE_ID  
     AND PARAM_ID=OLD_PARAM_ID; 
  COMMIT;         
END;

--

/* �������� ��������� */

COMMIT

