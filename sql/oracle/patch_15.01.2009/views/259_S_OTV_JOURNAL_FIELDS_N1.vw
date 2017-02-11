/* �������� ��������� �������� ������� 1 ����� ������ ������� */

CREATE OR REPLACE VIEW S_OTV_JOURNAL_FIELDS_N1
AS 
SELECT CYCLE_ID,
       CYCLE_NUM,
       JOURNAL_NUM,
       DATE_OBSERVATION,
       MEASURE_TYPE_ID,
       POINT_ID,
       POINT_NAME,
       CONVERTER_ID,
       CONVERTER_NAME,
       DATE_ENTER,
       COUNTING_OUT_AXIS_X,
       COUNTING_OUT_AXIS_Y,
       OFFSET_X_WITH_BEGIN_OBSERV,
       OFFSET_Y_WITH_BEGIN_OBSERV,
       CURRENT_OFFSET_X,
       CURRENT_OFFSET_Y,
       GROUP_NAME,
       MARH_GRAP_OR_ANCHOR_PLUMB,
       OBJECT_PATHS,
       AXES_PRIORITY,
       SECTION_PRIORITY,
       COORDINATE_Z,
       DESCRIPTION
  FROM TABLE (GET_OTV_JOURNAL_FIELDS (4621, 0))

--

/* �������� ��������� */

COMMIT


