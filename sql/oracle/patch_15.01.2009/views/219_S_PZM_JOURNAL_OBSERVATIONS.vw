/* �������� ��������� ���� ����������� � ������� ���������� */

CREATE OR REPLACE VIEW S_PZM_JOURNAL_OBSERVATIONS
AS
SELECT JO1.CYCLE_ID,
       JO1.CYCLE_NUM,
       JO1.DATE_OBSERVATION,
       JO1.MEASURE_TYPE_ID,
       JO1.POINT_ID,
       JO1.POINT_NAME,
       JO1.CONVERTER_ID,
       JO1.CONVERTER_NAME,
       JO1.MARK_HEAD,
       JO1.PRESSURE_ACTIVE,
       JO1.MARK_WATER,
       JO1.PRESSURE_OPPOSE,
       JO1.PRESSURE_BROUGHT,
       JO1.OBJECT_PATHS,
       JO1.SECTION_PRIORITY,
       JO1.COORDINATE_Z
  FROM S_PZM_JOURNAL_OBSERVATIONS_1 JO1
UNION
SELECT JO2.CYCLE_ID,
       JO2.CYCLE_NUM,
       JO2.DATE_OBSERVATION,
       JO2.MEASURE_TYPE_ID,
       JO2.POINT_ID,
       JO2.POINT_NAME,
       JO2.CONVERTER_ID,
       JO2.CONVERTER_NAME,
       JO2.MARK_HEAD,
       JO2.PRESSURE_ACTIVE,
       JO2.MARK_WATER,
       JO2.PRESSURE_OPPOSE,
       JO2.PRESSURE_BROUGHT,
       JO2.OBJECT_PATHS,
       JO2.SECTION_PRIORITY,
       JO2.COORDINATE_Z
  FROM S_PZM_JOURNAL_OBSERVATIONS_2 JO2
UNION
SELECT JO3.CYCLE_ID,
       JO3.CYCLE_NUM,
       JO3.DATE_OBSERVATION,
       JO3.MEASURE_TYPE_ID,
       JO3.POINT_ID,
       JO3.POINT_NAME,
       JO3.CONVERTER_ID,
       JO3.CONVERTER_NAME,
       JO3.MARK_HEAD,
       JO3.PRESSURE_ACTIVE,
       JO3.MARK_WATER,
       JO3.PRESSURE_OPPOSE,
       JO3.PRESSURE_BROUGHT,
       JO3.OBJECT_PATHS,
       JO3.SECTION_PRIORITY,
       JO3.COORDINATE_Z
  FROM S_PZM_JOURNAL_OBSERVATIONS_3 JO3

--

/* �������� ��������� */

COMMIT


