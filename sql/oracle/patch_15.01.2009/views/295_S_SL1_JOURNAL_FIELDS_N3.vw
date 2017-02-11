/* �������� ��������� �� ������� � ������� ������� ����� ������ ��������� ��������� */

CREATE OR REPLACE VIEW S_SL1_JOURNAL_FIELDS_N3
AS 
SELECT CYCLE_ID, CYCLE_NUM, JOURNAL_NUM, DATE_OBSERVATION, MEASURE_TYPE_ID,
       POINT_ID, POINT_NAME, CONVERTER_ID, CONVERTER_NAME, OBJECT_PATHS,
       SECTION_JOINT_PRIORITY, OUTFALL_PRIORITY, AXES_PRIORITY, COORDINATE_Z,
       VALUE, OPENING, CURRENT_OPENING
  FROM TABLE (GET_SL1_JOURNAL_FIELDS (30003, 0))


--

/* �������� ��������� */

COMMIT

