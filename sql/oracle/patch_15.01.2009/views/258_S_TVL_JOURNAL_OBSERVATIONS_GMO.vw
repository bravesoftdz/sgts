/* �������� ��������� ������� ���������� ����������� � ��������� ������ � ������������������ */

CREATE OR REPLACE VIEW S_TVL_JOURNAL_OBSERVATIONS_GMO
AS
SELECT TVL.CYCLE_ID,TVL.CYCLE_NUM,TVL.JOURNAL_NUM,TVL.DATE_OBSERVATION,TVL.MEASURE_TYPE_ID,TVL.POINT_ID,TVL.POINT_NAME,TVL.CONVERTER_ID,
       TVL.CONVERTER_NAME,TVL.VALUE_DRY,TVL.ADJUSTMENT_DRY,TVL.T_DRY,TVL.VALUE_WET,TVL.ADJUSTMENT_WET,TVL.T_WET,
       TVL.MOISTURE,TVL.OBJECT_PATHS,TVL.COORDINATE_Z, GMO.UVB,
   GMO.UNB,
   GMO.T_AIR,
   GMO.T_WATER, 
   GMO.RAIN_DAY, 
   GMO.PREC, 
   GMO.PREC_NAME, 
   GMO.UNSET, 
   GMO.INFLUX, 
   GMO.V_VAULT, 
   GMO.UVB_INC, 
   GMO.RAIN_YEAR, 
   GMO.T_AIR_10, 
   GMO.T_AIR_30 
    FROM S_TVL_JOURNAL_OBSERVATIONS TVL, S_GMO_JOURNAL_OBSERVATIONS GMO 
   WHERE TVL.DATE_OBSERVATION=GMO.DATE_OBSERVATION (+)

--

/* �������� ��������� */

COMMIT

