/* �������� ��������� ��������� ���� ������� */

CREATE OR REPLACE PROCEDURE U_INSTRUMENT_TYPE
( 
  INSTRUMENT_TYPE_ID IN INTEGER, 
  NAME IN VARCHAR2, 
  DESCRIPTION IN VARCHAR2, 
  OLD_INSTRUMENT_TYPE_ID IN INTEGER 
) 
AS 
BEGIN 
  UPDATE INSTRUMENT_TYPES  
     SET INSTRUMENT_TYPE_ID=U_INSTRUMENT_TYPE.INSTRUMENT_TYPE_ID, 
         NAME=U_INSTRUMENT_TYPE.NAME,  
         DESCRIPTION=U_INSTRUMENT_TYPE.DESCRIPTION  
   WHERE INSTRUMENT_TYPE_ID=OLD_INSTRUMENT_TYPE_ID; 
  COMMIT;         
END;

--

/* �������� ��������� */

COMMIT

