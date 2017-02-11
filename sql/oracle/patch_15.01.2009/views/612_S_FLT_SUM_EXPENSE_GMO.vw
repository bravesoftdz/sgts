/* �������� ��������� ������������ ������� ���������� ������ � ������������������ */

CREATE OR REPLACE VIEW S_FLT_SUM_EXPENSE_GMO
AS 
SELECT   DR1.CYCLE_NUM,
         CYC.DATE_BEGIN AS DATE_OBSERVATION,
         DR1.EXPENSE_OB AS EXPENSE_DR1,
         DR2.EXPENSE_OB AS EXPENSE_DR2,
         BET.EXPENSE_OB AS EXPENSE_BET,
         SHVI.EXPENSE_OB AS EXPENSE_SHVI,
         DR1.EXPENSE_OB + DR2.EXPENSE_OB + BET.EXPENSE_OB + SHVI.EXPENSE_OB AS EXPENSE_OB,
         GMO.UVB,
         GMO.UNB,
         GMO.T_AIR,
         GMO.T_WATER,
         GMO.RAIN_DAY,
         GMO.UNSET,
         GMO.INFLUX,
         GMO.V_VAULT,
         GMO.UVB_INC,
         GMO.RAIN_YEAR,
         GMO.T_AIR_10,
         GMO.T_AIR_30
    FROM S_FLT_SUM_EXPENSE_DR1_OB DR1,
         S_FLT_SUM_EXPENSE_DR2_OB DR2,
         S_FLT_SUM_EXPENSE_BET_OB BET,
         S_FLT_SUM_EXPENSE_SHVI_OB SHVI,
         S_GMO_CYCLE_VALUES GMO,
         S_CYCLES_REPORTS CYC
   WHERE DR1.CYCLE_NUM = DR2.CYCLE_NUM
     AND DR1.CYCLE_NUM = BET.CYCLE_NUM
     AND DR1.CYCLE_NUM = SHVI.CYCLE_NUM
     AND DR1.CYCLE_NUM = GMO.CYCLE_NUM
     AND DR1.CYCLE_NUM = CYC.CYCLE_NUM
ORDER BY DR1.CYCLE_NUM

--

/* �������� ��������� */

COMMIT


