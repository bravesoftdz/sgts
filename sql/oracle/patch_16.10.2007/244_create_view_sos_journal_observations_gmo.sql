/* �������� ��������� �������-����������� ������ � ������������������ � ������� ���������� */

CREATE OR REPLACE VIEW S_SOS_JOURNAL_OBSERVATIONS_GMO
AS
  SELECT SOS.*,
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
    FROM S_SOS_JOURNAL_OBSERVATIONS SOS, S_GMO_JOURNAL_OBSERVATIONS GMO
   WHERE SOS.DATE_OBSERVATION=GMO.DATE_OBSERVATION (+)

--

/* �������� ��������� �� */

COMMIT
