/* �������� ��������� ���������� ������� ���������� 3 ������ ������ ��������� ��������� */

CREATE OR REPLACE PROCEDURE R_SL1_JOURNAL_OBSERVATIONS_3
AS
BEGIN
  DBMS_REFRESH.REFRESH('S_SL1_JOURNAL_OBSERVATIONS_O3');
END;

--

/* �������� ��������� */

COMMIT
