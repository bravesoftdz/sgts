/* �������� ��������� ������ ���������*/

CREATE OR REPLACE VIEW S_MEASURE_UNITS
AS 
SELECT MU.MEASURE_UNIT_ID,MU.NAME,MU.DESCRIPTION
  FROM MEASURE_UNITS MU


--

/* �������� ��������� */

COMMIT

