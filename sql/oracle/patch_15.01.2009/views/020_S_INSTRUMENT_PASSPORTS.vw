/* �������� ��������� ��������� �������� */

CREATE OR REPLACE VIEW S_INSTRUMENT_PASSPORTS
AS 
SELECT IP.INSTRUMENT_PASSPORT_ID,
       IP.INSTRUMENT_ID,
       IP.DATE_TEST,
       IP.DESCRIPTION,
       IP.RATIO,
       I.NAME AS INSTRUMENT_NAME
  FROM INSTRUMENT_PASSPORTS IP,
       INSTRUMENTS I
 WHERE IP.INSTRUMENT_ID = I.INSTRUMENT_ID

--

/* �������� ��������� */

COMMIT


