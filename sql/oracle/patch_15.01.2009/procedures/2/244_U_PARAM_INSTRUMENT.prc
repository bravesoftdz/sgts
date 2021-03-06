/* �������� ��������� ��������� ������� ��������� */

CREATE OR REPLACE PROCEDURE U_PARAM_INSTRUMENT
( 
  PARAM_ID IN INTEGER, 
  INSTRUMENT_ID IN INTEGER, 
  PRIORITY IN INTEGER, 
  OLD_PARAM_ID IN INTEGER, 
  OLD_INSTRUMENT_ID IN INTEGER 
) 
AS 
BEGIN 
  UPDATE PARAM_INSTRUMENTS  
     SET PARAM_ID=U_PARAM_INSTRUMENT.PARAM_ID, 
         INSTRUMENT_ID=U_PARAM_INSTRUMENT.INSTRUMENT_ID, 
         PRIORITY=U_PARAM_INSTRUMENT.PRIORITY 
   WHERE PARAM_ID=OLD_PARAM_ID  
     AND INSTRUMENT_ID=OLD_INSTRUMENT_ID; 
  COMMIT;         
END;

--

/* �������� ��������� */

COMMIT

