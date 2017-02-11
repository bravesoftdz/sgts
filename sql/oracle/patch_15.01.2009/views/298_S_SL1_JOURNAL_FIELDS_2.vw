/* �������� ��������� ������������� � ������� ������� ��������� ��������� */

CREATE OR REPLACE VIEW S_SL1_JOURNAL_FIELDS_2
AS
SELECT JFO2.CYCLE_ID, JFO2.CYCLE_NUM, JFO2.JOURNAL_NUM, JFO2.DATE_OBSERVATION,
       JFO2.MEASURE_TYPE_ID, JFO2.POINT_ID, JFO2.POINT_NAME,
       JFO2.CONVERTER_ID, JFO2.CONVERTER_NAME, JFO2.OBJECT_PATHS,
       JFO2.SECTION_JOINT_PRIORITY, JFO2.OUTFALL_PRIORITY, JFO2.AXES_PRIORITY,
       JFO2.COORDINATE_Z, JFO2.VALUE, JFO2.OPENING, JFO2.CURRENT_OPENING
  FROM S_SL1_JOURNAL_FIELDS_O2 JFO2
UNION
SELECT JFN2.CYCLE_ID, JFN2.CYCLE_NUM, JFN2.JOURNAL_NUM, JFN2.DATE_OBSERVATION,
       JFN2.MEASURE_TYPE_ID, JFN2.POINT_ID, JFN2.POINT_NAME,
       JFN2.CONVERTER_ID, JFN2.CONVERTER_NAME, JFN2.OBJECT_PATHS,
       JFN2.SECTION_JOINT_PRIORITY, JFN2.OUTFALL_PRIORITY, JFN2.AXES_PRIORITY,
       JFN2.COORDINATE_Z, JFN2.VALUE, JFN2.OPENING, JFN2.CURRENT_OPENING
  FROM S_SL1_JOURNAL_FIELDS_N2 JFN2

--

/* �������� ��������� */

COMMIT

