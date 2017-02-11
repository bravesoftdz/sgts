/* �������� ��������� �������� ������� 2 ����������-���������������� ��������� */

CREATE OR REPLACE VIEW S_NDS_JOURNAL_FIELDS_2
AS
SELECT CYCLE_ID,
       CYCLE_NUM,
       JOURNAL_FIELD_ID,
       JOURNAL_NUM,
       DATE_OBSERVATION,
       MEASURE_TYPE_ID,
       POINT_ID,
       POINT_NAME,
       COORDINATE_Z,
       CONVERTER_ID,
       CONVERTER_NAME,
       NOTE,
       TYPE_INSTRUMENT,
       VALUE_RESISTANCE_LINE,
       VALUE_RESISTANCE,
       VALUE_FREQUENCY,
       VALUE_PERIOD,
       VALUE_STATER_CARRIE,
       OBJECT_PATHS
  FROM S_NDS_JOURNAL_FIELDS_O2
UNION
SELECT CYCLE_ID,
       CYCLE_NUM,
       JOURNAL_FIELD_ID,
       JOURNAL_NUM,
       DATE_OBSERVATION,
       MEASURE_TYPE_ID,
       POINT_ID,
       POINT_NAME,
       COORDINATE_Z,
       CONVERTER_ID,
       CONVERTER_NAME,
       NOTE,
       TYPE_INSTRUMENT,
       VALUE_RESISTANCE_LINE,
       VALUE_RESISTANCE,
       VALUE_FREQUENCY,
       VALUE_PERIOD,
       VALUE_STATER_CARRIE,
       OBJECT_PATHS
  FROM S_NDS_JOURNAL_FIELDS_N2

--

/* �������� ��������� */

COMMIT


