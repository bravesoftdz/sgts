/* �������� ��������� �������� ���� ������� */

CREATE OR REPLACE PROCEDURE D_INSTRUMENT_TYPE
( 
  OLD_INSTRUMENT_TYPE_ID IN INTEGER 
) 
AS 
BEGIN 
  DELETE FROM INSTRUMENT_TYPES 
        WHERE INSTRUMENT_TYPE_ID=OLD_INSTRUMENT_TYPE_ID; 
  COMMIT;         
END;

--

/* �������� ��������� */

COMMIT
