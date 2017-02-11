/* �������� ��������� ������� ���������� ���������� */

CREATE OR REPLACE VIEW S_HMZ_JOURNAL_OBSERVATIONS
AS 
SELECT JOO.CYCLE_ID,
       JOO.CYCLE_NUM,
       JOO.JOURNAL_NUM,
       JOO.DATE_OBSERVATION,
       JOO.MEASURE_TYPE_ID,
       JOO.POINT_ID,
       JOO.POINT_NAME,
       JOO.CONVERTER_ID,
       JOO.CONVERTER_NAME,
       JOO.MARK,
       JOO.PH,
       JOO.CO2SV,
       JOO.CO3_2,
       JOO.CO2AGG,
       JOO.ALKALI,
       JOO.ACERBITY,
       JOO.CA,
       JOO.MG,
       JOO.CL,
       JOO.SO4_2,
       JOO.HCO3,
       JOO.NA_K,
       JOO.AGGRESSIV,
       JOO.OBJECT_PATHS,
       JOO.OBJECT_PRIORITY,
       JOO.COORDINATE_Z
  FROM S_HMZ_JOURNAL_OBSERVATIONS_O JOO
UNION
SELECT JON.CYCLE_ID,
       JON.CYCLE_NUM,
       JON.JOURNAL_NUM,
       JON.DATE_OBSERVATION,
       JON.MEASURE_TYPE_ID,
       JON.POINT_ID,
       JON.POINT_NAME,
       JON.CONVERTER_ID,
       JON.CONVERTER_NAME,
       JON.MARK,
       JON.PH,
       JON.CO2SV,
       JON.CO3_2,
       JON.CO2AGG,
       JON.ALKALI,
       JON.ACERBITY,
       JON.CA,
       JON.MG,
       JON.CL,
       JON.SO4_2,
       JON.HCO3,
       JON.NA_K,
       JON.AGGRESSIV,
       JON.OBJECT_PATHS,
       JON.OBJECT_PRIORITY,
       JON.COORDINATE_Z
  FROM S_HMZ_JOURNAL_OBSERVATIONS_N JON

--

/* �������� ��������� */

COMMIT


