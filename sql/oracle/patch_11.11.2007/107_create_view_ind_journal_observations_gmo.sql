/* �������� ��������� ����������� ������� � ������������������ � ������� ���������� */

CREATE OR REPLACE VIEW S_IND_JOURNAL_OBSERVATIONS_GMO
AS
  SELECT IND.*,
         GMO.UVB, 
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
    FROM S_IND_JOURNAL_OBSERVATIONS IND, S_GMO_JOURNAL_OBSERVATIONS GMO
   WHERE IND.DATE_OBSERVATION=GMO.DATE_OBSERVATION (+)

--

/* �������� ��������� �� */

COMMIT
