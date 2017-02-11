/* �������� ������� ���������� ������� */

CREATE OR REPLACE VIEW S_OTV_JOURNAL_OBSERVATIONS
AS
SELECT JF1.CYCLE_ID,
       JF1.CYCLE_NUM,
       JF1.DATE_OBSERVATION,
       JF1.MEASURE_TYPE_ID,
       JF1.POINT_ID,
       JF1.POINT_NAME,
       JF1.CONVERTER_ID,
       JF1.CONVERTER_NAME,
       JF1.DATE_ENTER,
       JF1.COUNTING_OUT_AXIS_X,
       JF1.COUNTING_OUT_AXIS_Y,
       JF1.OFFSET_X_WITH_BEGIN_OBSERV,
       JF1.OFFSET_Y_WITH_BEGIN_OBSERV,
       JF1.CURRENT_OFFSET_X,
       JF1.CURRENT_OFFSET_Y,
       JF1.GROUP_NAME,
       JF1.MARH_GRAP_OR_ANCHOR_PLUMB,
       JF1.OBJECT_PATHS,
       JF1.AXES_PRIORITY,
       JF1.SECTION_PRIORITY,
       JF1.COORDINATE_Z,
       JF1.DESCRIPTION
  FROM S_OTV_JOURNAL_OBSERVATIONS_1 JF1
UNION
SELECT JF2.CYCLE_ID,
       JF2.CYCLE_NUM,
       JF2.DATE_OBSERVATION,
       JF2.MEASURE_TYPE_ID,
       JF2.POINT_ID,
       JF2.POINT_NAME,
       JF2.CONVERTER_ID,
       JF2.CONVERTER_NAME,
       JF2.DATE_ENTER,
       JF2.COUNTING_OUT_AXIS_X,
       JF2.COUNTING_OUT_AXIS_Y,
       JF2.OFFSET_X_WITH_BEGIN_OBSERV,
       JF2.OFFSET_Y_WITH_BEGIN_OBSERV,
       JF2.CURRENT_OFFSET_X,
       JF2.CURRENT_OFFSET_Y,
       JF2.GROUP_NAME,
       JF2.MARH_GRAP_OR_ANCHOR_PLUMB,
       JF2.OBJECT_PATHS,
       JF2.AXES_PRIORITY,
       JF2.SECTION_PRIORITY,
       JF2.COORDINATE_Z,
       JF2.DESCRIPTION
  FROM S_OTV_JOURNAL_OBSERVATIONS_2 JF2

--

/* �������� ��������� */

COMMIT


