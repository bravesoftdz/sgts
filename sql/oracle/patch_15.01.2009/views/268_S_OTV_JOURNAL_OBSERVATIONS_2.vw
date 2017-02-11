/* �������� ��������� ������� ���������� 2 ������� */

CREATE OR REPLACE VIEW S_OTV_JOURNAL_OBSERVATIONS_2
AS 
SELECT JFO2.CYCLE_ID,
       JFO2.CYCLE_NUM,
       JFO2.DATE_OBSERVATION,
       JFO2.MEASURE_TYPE_ID,
       JFO2.POINT_ID,
       JFO2.POINT_NAME,
       JFO2.CONVERTER_ID,
       JFO2.CONVERTER_NAME,
       JFO2.DATE_ENTER,
       JFO2.COUNTING_OUT_AXIS_X,
       JFO2.COUNTING_OUT_AXIS_Y,
       JFO2.OFFSET_X_WITH_BEGIN_OBSERV,
       JFO2.OFFSET_Y_WITH_BEGIN_OBSERV,
       JFO2.CURRENT_OFFSET_X,
       JFO2.CURRENT_OFFSET_Y,
       JFO2.GROUP_NAME,
       JFO2.MARH_GRAP_OR_ANCHOR_PLUMB,
       JFO2.OBJECT_PATHS,
       JFO2.AXES_PRIORITY,
       JFO2.SECTION_PRIORITY,
       JFO2.COORDINATE_Z,
       JFO2.DESCRIPTION
  FROM S_OTV_JOURNAL_OBSERVATIONS_O2 JFO2
UNION
SELECT JFN2.CYCLE_ID,
       JFN2.CYCLE_NUM,
       JFN2.DATE_OBSERVATION,
       JFN2.MEASURE_TYPE_ID,
       JFN2.POINT_ID,
       JFN2.POINT_NAME,
       JFN2.CONVERTER_ID,
       JFN2.CONVERTER_NAME,
       JFN2.DATE_ENTER,
       JFN2.COUNTING_OUT_AXIS_X,
       JFN2.COUNTING_OUT_AXIS_Y,
       JFN2.OFFSET_X_WITH_BEGIN_OBSERV,
       JFN2.OFFSET_Y_WITH_BEGIN_OBSERV,
       JFN2.CURRENT_OFFSET_X,
       JFN2.CURRENT_OFFSET_Y,
       JFN2.GROUP_NAME,
       JFN2.MARH_GRAP_OR_ANCHOR_PLUMB,
       JFN2.OBJECT_PATHS,
       JFN2.AXES_PRIORITY,
       JFN2.SECTION_PRIORITY,
       JFN2.COORDINATE_Z,
       JFN2.DESCRIPTION
  FROM S_OTV_JOURNAL_OBSERVATIONS_N2 JFN2

--

/* �������� ��������� */

COMMIT


