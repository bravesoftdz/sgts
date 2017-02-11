/* �������� ��������� ��������� ����� */

CREATE OR REPLACE PROCEDURE U_CYCLE
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

/* �������� ��������� */

COMMIT

