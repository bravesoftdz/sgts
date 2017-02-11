/* �������� ��������� ���������� � ������������������ � ������� ���������� */

CREATE OR REPLACE VIEW S_HMZ_JOURNAL_OBSERVATIONS_GMO
AS
  SELECT HMZ.*,
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
    FROM S_HMZ_JOURNAL_OBSERVATIONS HMZ, S_GMO_JOURNAL_OBSERVATIONS GMO
   WHERE HMZ.DATE_OBSERVATION=GMO.DATE_OBSERVATION (+)

--

/* �������� ��������� �� */

COMMIT