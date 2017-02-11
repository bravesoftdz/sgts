/* �������� ��������� �������� ����������� � ������� ���������� */

CREATE OR REPLACE VIEW S_PZM_JOURNAL_OBSERVATIONS_2
AS 
SELECT JOO2.CYCLE_ID,
       JOO2.CYCLE_NUM,
       JOO2.DATE_OBSERVATION,
       JOO2.MEASURE_TYPE_ID,
       JOO2.POINT_ID,
       JOO2.POINT_NAME,
       JOO2.CONVERTER_ID,
       JOO2.CONVERTER_NAME,
       JOO2.MARK_HEAD,
       JOO2.PRESSURE_ACTIVE,
       JOO2.MARK_WATER,
       JOO2.PRESSURE_OPPOSE,
       JOO2.PRESSURE_BROUGHT,
       JOO2.OBJECT_PATHS,
       JOO2.SECTION_PRIORITY,
       JOO2.COORDINATE_Z
  FROM S_PZM_JOURNAL_OBSERVATIONS_O2 JOO2
UNION
SELECT JON2.CYCLE_ID,
       JON2.CYCLE_NUM,
       JON2.DATE_OBSERVATION,
       JON2.MEASURE_TYPE_ID,
       JON2.POINT_ID,
       JON2.POINT_NAME,
       JON2.CONVERTER_ID,
       JON2.CONVERTER_NAME,
       JON2.MARK_HEAD,
       JON2.PRESSURE_ACTIVE,
       JON2.MARK_WATER,
       JON2.PRESSURE_OPPOSE,
       JON2.PRESSURE_BROUGHT,
       JON2.OBJECT_PATHS,
       JON2.SECTION_PRIORITY,
       JON2.COORDINATE_Z
  FROM S_PZM_JOURNAL_OBSERVATIONS_N2 JON2

--

/* �������� ��������� */

COMMIT

