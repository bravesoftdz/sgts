/* �������� ��������� ������ ��� � ������� ���������� ����� ������ ��������� ��������� */

CREATE OR REPLACE VIEW S_SLW_JOURNAL_OBSERVATIONS_N2
AS 
SELECT CYCLE_ID,CYCLE_NUM,JOURNAL_NUM,DATE_OBSERVATION,MEASURE_TYPE_ID,POINT_ID,POINT_NAME,CONVERTER_ID,CONVERTER_NAME,OBJECT_PATHS,SECTION_JOINT_PRIORITY,JOINT_PRIORITY,
       COORDINATE_Z,VALUE_X,VALUE_Y,VALUE_Z,OPENING_X,OPENING_Y,OPENING_Z,CURRENT_OPENING_X,CURRENT_OPENING_Y,CURRENT_OPENING_Z,CYCLE_NULL_OPENING_X,CYCLE_NULL_OPENING_Y,
       CYCLE_NULL_OPENING_Z
FROM TABLE(GET_SLW_JOURNAL_OBSERVATIONS(30007,0))

--

/* �������� ��������� */

COMMIT


