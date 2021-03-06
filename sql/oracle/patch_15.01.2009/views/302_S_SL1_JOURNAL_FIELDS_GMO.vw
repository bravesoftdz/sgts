/* �������� ��������� �������� ������� ��������� ��������� ������ � ������������������ */

CREATE OR REPLACE VIEW S_SL1_JOURNAL_FIELDS_GMO
AS 
SELECT SL1.CYCLE_ID, SL1.CYCLE_NUM, SL1.JOURNAL_NUM, SL1.DATE_OBSERVATION,
       SL1.MEASURE_TYPE_ID, SL1.POINT_ID, SL1.POINT_NAME, SL1.CONVERTER_ID,
       SL1.CONVERTER_NAME, SL1.OBJECT_PATHS, SL1.SECTION_JOINT_PRIORITY,
       SL1.OUTFALL_PRIORITY, SL1.AXES_PRIORITY, SL1.COORDINATE_Z, SL1.VALUE,
       SL1.OPENING, SL1.CURRENT_OPENING, GMO.UVB, GMO.UNB, GMO.T_AIR,
       GMO.T_WATER AS GMO_T_WATER, GMO.RAIN_DAY, GMO.PREC, GMO.PREC_NAME,
       GMO.UNSET, GMO.INFLUX, GMO.V_VAULT
  FROM S_SL1_JOURNAL_FIELDS SL1, S_GMO_JOURNAL_FIELDS GMO
 WHERE SL1.DATE_OBSERVATION = GMO.DATE_OBSERVATION(+)

--

/* �������� ��������� */

COMMIT


