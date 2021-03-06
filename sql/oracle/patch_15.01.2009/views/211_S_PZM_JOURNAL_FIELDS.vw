/* �������� ��������� ���� ����������� � ������� ������� */

CREATE OR REPLACE VIEW S_PZM_JOURNAL_FIELDS
AS 
SELECT JF1.CYCLE_ID,
       JF1.CYCLE_NUM,
       JF1.JOURNAL_NUM,
       JF1.DATE_OBSERVATION,
       JF1.MEASURE_TYPE_ID,
       JF1.POINT_ID,
       JF1.POINT_NAME,
       JF1.CONVERTER_ID,
       JF1.CONVERTER_NAME,
       JF1.INSTRUMENT_ID,
       JF1.INSTRUMENT_NAME,
       JF1.VALUE,
       JF1.OBJECT_PATHS,
       JF1.COORDINATE_Z
  FROM S_PZM_JOURNAL_FIELDS_1 JF1
UNION
SELECT JF2.CYCLE_ID,
       JF2.CYCLE_NUM,
       JF2.JOURNAL_NUM,
       JF2.DATE_OBSERVATION,
       JF2.MEASURE_TYPE_ID,
       JF2.POINT_ID,
       JF2.POINT_NAME,
       JF2.CONVERTER_ID,
       JF2.CONVERTER_NAME,
       JF2.INSTRUMENT_ID,
       JF2.INSTRUMENT_NAME,
       JF2.VALUE,
       JF2.OBJECT_PATHS,
       JF2.COORDINATE_Z
  FROM S_PZM_JOURNAL_FIELDS_2 JF2
UNION
SELECT JF3.CYCLE_ID,
       JF3.CYCLE_NUM,
       JF3.JOURNAL_NUM,
       JF3.DATE_OBSERVATION,
       JF3.MEASURE_TYPE_ID,
       JF3.POINT_ID,
       JF3.POINT_NAME,
       JF3.CONVERTER_ID,
       JF3.CONVERTER_NAME,
       JF3.INSTRUMENT_ID,
       JF3.INSTRUMENT_NAME,
       JF3.VALUE,
       JF3.OBJECT_PATHS,
       JF3.COORDINATE_Z
  FROM S_PZM_JOURNAL_FIELDS_3 JF3

--

/* �������� ��������� */

COMMIT


