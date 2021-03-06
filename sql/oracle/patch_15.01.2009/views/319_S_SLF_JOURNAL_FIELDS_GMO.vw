/* �������� ��������� �������� ������� ��������� ��������� ������ � ������������������ */

CREATE OR REPLACE VIEW S_SLF_JOURNAL_FIELDS_GMO
AS
SELECT SLF.CYCLE_ID, SLF.CYCLE_NUM, SLF.JOURNAL_NUM, SLF.DATE_OBSERVATION,
       SLF.MEASURE_TYPE_ID, SLF.POINT_ID, SLF.POINT_NAME, SLF.CONVERTER_ID,
       SLF.CONVERTER_NAME, SLF.OBJECT_PATHS, SLF.SECTION_JOINT_PRIORITY,
       SLF.JOINT_PRIORITY, SLF.COORDINATE_Z, SLF.VALUE_AB_RACK,
       SLF.VALUE_AB_COMPASSES, SLF.VALUE_AB_MICROMETR, SLF.VALUE_BA_RACK,
       SLF.VALUE_BA_COMPASSES, SLF.VALUE_BA_MICROMETR, SLF.VALUE_AC_RACK,
       SLF.VALUE_AC_COMPASSES, SLF.VALUE_AC_MICROMETR, SLF.VALUE_CA_RACK,
       SLF.VALUE_CA_COMPASSES, SLF.VALUE_CA_MICROMETR, SLF.VALUE_BC_RACK,
       SLF.VALUE_BC_COMPASSES, SLF.VALUE_BC_MICROMETR, SLF.VALUE_CB_RACK,
       SLF.VALUE_CB_COMPASSES, SLF.VALUE_CB_MICROMETR,
       SLF.AVERAGE_AB_COMPASSES, SLF.AVERAGE_AB_MICROMETR,
       SLF.AVERAGE_AC_COMPASSES, SLF.AVERAGE_AC_MICROMETR,
       SLF.AVERAGE_BC_COMPASSES, SLF.AVERAGE_BC_MICROMETR, SLF.ERROR,
       SLF.OPENING_X, SLF.OPENING_Y, SLF.OPENING_Z, SLF.CURRENT_OPENING_X,
       SLF.CURRENT_OPENING_Y, SLF.CURRENT_OPENING_Z, GMO.UVB, GMO.UNB,
       GMO.T_AIR, GMO.T_WATER AS GMO_T_WATER, GMO.RAIN_DAY, GMO.PREC,
       GMO.PREC_NAME, GMO.UNSET, GMO.INFLUX, GMO.V_VAULT
  FROM S_SLF_JOURNAL_FIELDS SLF, S_GMO_JOURNAL_FIELDS GMO
 WHERE SLF.DATE_OBSERVATION = GMO.DATE_OBSERVATION(+)

--

/* �������� ��������� */

COMMIT


