/* �������� ��������� ������� ���������� ����� ������ ����������� � ��������� */

CREATE OR REPLACE VIEW S_TVL_JOURNAL_OBSERVATIONS_N
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
       VALUE_DRY,
       ADJUSTMENT_DRY,
       T_DRY,
       VALUE_WET,
       ADJUSTMENT_WET,
       T_WET,
       MOISTURE,
       OBJECT_PATHS,
       COORDINATE_Z
  FROM TABLE (GET_TVL_JOURNAL_OBSERVATIONS (0))

--

/* �������� ��������� */

COMMIT

