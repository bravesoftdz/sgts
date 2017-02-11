/* �������� ��������� ��������� ����������� � ������� ���������� */

CREATE OR REPLACE VIEW S_PZM_JOURNAL_OBSERVATIONS_3
AS 
SELECT JOO3.CYCLE_ID,
       JOO3.CYCLE_NUM,
       JOO3.DATE_OBSERVATION,
       JOO3.MEASURE_TYPE_ID,
       JOO3.POINT_ID,
       JOO3.POINT_NAME,
       JOO3.CONVERTER_ID,
       JOO3.CONVERTER_NAME,
       JOO3.MARK_HEAD,
       JOO3.PRESSURE_ACTIVE,
       JOO3.MARK_WATER,
       JOO3.PRESSURE_OPPOSE,
       JOO3.PRESSURE_BROUGHT,
       JOO3.OBJECT_PATHS,
       JOO3.SECTION_PRIORITY,
       JOO3.COORDINATE_Z
  FROM S_PZM_JOURNAL_OBSERVATIONS_O3 JOO3
UNION
SELECT JON3.CYCLE_ID,
       JON3.CYCLE_NUM,
       JON3.DATE_OBSERVATION,
       JON3.MEASURE_TYPE_ID,
       JON3.POINT_ID,
       JON3.POINT_NAME,
       JON3.CONVERTER_ID,
       JON3.CONVERTER_NAME,
       JON3.MARK_HEAD,
       JON3.PRESSURE_ACTIVE,
       JON3.MARK_WATER,
       JON3.PRESSURE_OPPOSE,
       JON3.PRESSURE_BROUGHT,
       JON3.OBJECT_PATHS,
       JON3.SECTION_PRIORITY,
       JON3.COORDINATE_Z
  FROM S_PZM_JOURNAL_OBSERVATIONS_N3 JON3

--

/* �������� ��������� */

COMMIT


