/* �������� ��������� ���������� ������� ���������� 4 ������ ������ �������� ��������� */

CREATE OR REPLACE PROCEDURE R_SL1_JOURNAL_OBSERVATIONS_4
AS
BEGIN
  DBMS_REFRESH.REFRESH('S_SL1_JOURNAL_OBSERVATIONS_O4');
END;

--

/* �������� ��������� */

COMMIT
