/* �������� ��������� ���������� ������� ���������� 1 ������ ������ ��������� ��������� */

CREATE OR REPLACE PROCEDURE R_SL1_JOURNAL_OBSERVATIONS_1
AS
BEGIN
  DBMS_REFRESH.REFRESH('S_SL1_JOURNAL_OBSERVATIONS_O1');
END;

--

/* �������� ��������� */

COMMIT
