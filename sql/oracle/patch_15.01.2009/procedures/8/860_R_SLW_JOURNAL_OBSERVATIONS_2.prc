/* �������� ��������� ���������� ������� ���������� 2 ������ ������ ��������� ��������� */

CREATE OR REPLACE PROCEDURE R_SLW_JOURNAL_OBSERVATIONS_2
AS
BEGIN
  DBMS_REFRESH.REFRESH('S_SLW_JOURNAL_OBSERVATIONS_O2');
END;

--

/* �������� ��������� */

COMMIT
