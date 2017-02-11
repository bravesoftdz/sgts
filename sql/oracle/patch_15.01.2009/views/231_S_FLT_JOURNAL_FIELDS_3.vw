/* �������� ��������� �������� ������� 3 ���������� */

CREATE OR REPLACE VIEW S_FLT_JOURNAL_FIELDS_3
AS
SELECT JFO3.CYCLE_ID,
       JFO3.CYCLE_NUM,
       JFO3.JOURNAL_NUM,
       JFO3.DATE_OBSERVATION,
       JFO3.MEASURE_TYPE_ID,
       JFO3.POINT_ID,
       JFO3.POINT_NAME,
       JFO3.CONVERTER_ID,
       JFO3.CONVERTER_NAME,
       JFO3.MARK,
       JFO3.VOLUME,
       JFO3.TIME,
       JFO3.EXPENSE,
       JFO3.T_WATER,
       JFO3.OBJECT_PATHS,
       JFO3.SECTION_PRIORITY,
       JFO3.JOINT_PRIORITY,
       JFO3.COORDINATE_Z
  FROM S_FLT_JOURNAL_FIELDS_O3 JFO3
UNION
SELECT JFN3.CYCLE_ID,
       JFN3.CYCLE_NUM,
       JFN3.JOURNAL_NUM,
       JFN3.DATE_OBSERVATION,
       JFN3.MEASURE_TYPE_ID,
       JFN3.POINT_ID,
       JFN3.POINT_NAME,
       JFN3.CONVERTER_ID,
       JFN3.CONVERTER_NAME,
       JFN3.MARK,
       JFN3.VOLUME,
       JFN3.TIME,
       JFN3.EXPENSE,
       JFN3.T_WATER,
       JFN3.OBJECT_PATHS,
       JFN3.SECTION_PRIORITY,
       JFN3.JOINT_PRIORITY,
       JFN3.COORDINATE_Z
  FROM S_FLT_JOURNAL_FIELDS_N3 JFN3

--

/* �������� ��������� */

COMMIT


