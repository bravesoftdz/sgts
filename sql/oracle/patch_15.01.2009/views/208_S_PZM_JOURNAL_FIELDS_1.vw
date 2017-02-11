/* �������� ��������� ������� ����������� � ������� ������� */

CREATE OR REPLACE VIEW S_PZM_JOURNAL_FIELDS_1
AS 
SELECT JFO1.CYCLE_ID,
       JFO1.CYCLE_NUM,
       JFO1.JOURNAL_NUM,
       JFO1.DATE_OBSERVATION,
       JFO1.MEASURE_TYPE_ID,
       JFO1.POINT_ID,
       JFO1.POINT_NAME,
       JFO1.CONVERTER_ID,
       JFO1.CONVERTER_NAME,
       JFO1.INSTRUMENT_ID,
       JFO1.INSTRUMENT_NAME,
       JFO1.VALUE,
       JFO1.OBJECT_PATHS,
       JFO1.COORDINATE_Z
  FROM S_PZM_JOURNAL_FIELDS_O1 JFO1
UNION
SELECT JFN1.CYCLE_ID,
       JFN1.CYCLE_NUM,
       JFN1.JOURNAL_NUM,
       JFN1.DATE_OBSERVATION,
       JFN1.MEASURE_TYPE_ID,
       JFN1.POINT_ID,
       JFN1.POINT_NAME,
       JFN1.CONVERTER_ID,
       JFN1.CONVERTER_NAME,
       JFN1.INSTRUMENT_ID,
       JFN1.INSTRUMENT_NAME,
       JFN1.VALUE,
       JFN1.OBJECT_PATHS,
       JFN1.COORDINATE_Z
  FROM S_PZM_JOURNAL_FIELDS_N1 JFN1

--

/* �������� ��������� */

COMMIT

