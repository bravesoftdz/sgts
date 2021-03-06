/* �������� ��������� ��������� ���������������� */

CREATE OR REPLACE VIEW S_CONVERTER_PASSPORTS
AS 
SELECT   CP.CONVERTER_PASSPORT_ID,
         CP.COMPONENT_ID,
         CP.INSTRUMENT_ID,
         CP.MEASURE_UNIT_ID,
         CP.DESCRIPTION,
         CP.VALUE,
         CP.DATE_BEGIN,
         CP.DATE_END,
         C.NAME AS COMPONENT_NAME,
         C.CONVERTER_ID,
         I.NAME AS INSTRUMENT_NAME,
         MU.NAME AS MEASURE_UNIT_NAME
    FROM CONVERTER_PASSPORTS CP,
         COMPONENTS C,
         INSTRUMENTS I,
         MEASURE_UNITS MU
   WHERE CP.COMPONENT_ID = C.COMPONENT_ID
     AND CP.INSTRUMENT_ID = I.INSTRUMENT_ID(+)
     AND CP.MEASURE_UNIT_ID = MU.MEASURE_UNIT_ID(+)
ORDER BY C.NAME,
         CP.DATE_BEGIN DESC

--

/* �������� ��������� */

COMMIT


