/* �������� ��������� ���������� ������� ��������� ������� */

CREATE OR REPLACE PROCEDURE I_INSTRUMENT_UNIT
( 
  INSTRUMENT_ID IN INTEGER, 
  MEASURE_UNIT_ID IN INTEGER, 
  PRIORITY IN INTEGER 
) 
AS 
BEGIN 
  INSERT INTO INSTRUMENT_UNITS (INSTRUMENT_ID,MEASURE_UNIT_ID,PRIORITY) 
       VALUES (INSTRUMENT_ID,MEASURE_UNIT_ID,PRIORITY); 
  COMMIT; 
END;

--

/* �������� ��������� */

COMMIT
