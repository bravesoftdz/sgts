/* �������� ��������� ������ ��������� ��������*/

CREATE OR REPLACE VIEW S_INSTRUMENT_UNITS
AS 
SELECT IU.INSTRUMENT_ID,
       IU.MEASURE_UNIT_ID,
       IU.PRIORITY,
       I.NAME AS INSTRUMENT_NAME,
       MU.NAME AS MEASURE_UNIT_NAME
  FROM INSTRUMENT_UNITS IU,
       INSTRUMENTS I,
       MEASURE_UNITS MU
 WHERE I.INSTRUMENT_ID = IU.INSTRUMENT_ID
   AND MU.MEASURE_UNIT_ID = IU.MEASURE_UNIT_ID


--

/* �������� ��������� */

COMMIT

