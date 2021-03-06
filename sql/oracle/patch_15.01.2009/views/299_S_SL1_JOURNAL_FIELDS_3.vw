/* �������� ��������� �� ������� � ������� ������� ��������� ��������� */

CREATE OR REPLACE VIEW S_SL1_JOURNAL_FIELDS_3
AS
SELECT JFO3.CYCLE_ID, JFO3.CYCLE_NUM, JFO3.JOURNAL_NUM, JFO3.DATE_OBSERVATION,
       JFO3.MEASURE_TYPE_ID, JFO3.POINT_ID, JFO3.POINT_NAME,
       JFO3.CONVERTER_ID, JFO3.CONVERTER_NAME, JFO3.OBJECT_PATHS,
       JFO3.SECTION_JOINT_PRIORITY, JFO3.OUTFALL_PRIORITY, JFO3.AXES_PRIORITY,
       JFO3.COORDINATE_Z, JFO3.VALUE, JFO3.OPENING, JFO3.CURRENT_OPENING
  FROM S_SL1_JOURNAL_FIELDS_O3 JFO3
UNION
SELECT JFN3.CYCLE_ID, JFN3.CYCLE_NUM, JFN3.JOURNAL_NUM, JFN3.DATE_OBSERVATION,
       JFN3.MEASURE_TYPE_ID, JFN3.POINT_ID, JFN3.POINT_NAME,
       JFN3.CONVERTER_ID, JFN3.CONVERTER_NAME, JFN3.OBJECT_PATHS,
       JFN3.SECTION_JOINT_PRIORITY, JFN3.OUTFALL_PRIORITY, JFN3.AXES_PRIORITY,
       JFN3.COORDINATE_Z, JFN3.VALUE, JFN3.OPENING, JFN3.CURRENT_OPENING
  FROM S_SL1_JOURNAL_FIELDS_N3 JFN3

--

/* �������� ��������� */

COMMIT

