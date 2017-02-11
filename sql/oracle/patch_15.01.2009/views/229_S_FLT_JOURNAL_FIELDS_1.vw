/* �������� ��������� �������� ������� 1 ���������� */

CREATE OR REPLACE VIEW S_FLT_JOURNAL_FIELDS_1
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
       JFO1.MARK,
       JFO1.VOLUME,
       JFO1.TIME,
       JFO1.EXPENSE,
       JFO1.T_WATER,
       JFO1.OBJECT_PATHS,
       JFO1.SECTION_PRIORITY,
       JFO1.JOINT_PRIORITY,
       JFO1.COORDINATE_Z
  FROM S_FLT_JOURNAL_FIELDS_O1 JFO1
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
       JFN1.MARK,
       JFN1.VOLUME,
       JFN1.TIME,
       JFN1.EXPENSE,
       JFN1.T_WATER,
       JFN1.OBJECT_PATHS,
       JFN1.SECTION_PRIORITY,
       JFN1.JOINT_PRIORITY,
       JFN1.COORDINATE_Z
  FROM S_FLT_JOURNAL_FIELDS_N1 JFN1

--

/* �������� ��������� */

COMMIT


