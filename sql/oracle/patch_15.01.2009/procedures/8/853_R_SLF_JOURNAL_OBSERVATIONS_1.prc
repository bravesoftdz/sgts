/* �������� ��������� ���������� ������� ���������� 1 ������ ������ ��������� ��������� */

CREATE OR REPLACE PROCEDURE R_SLF_JOURNAL_OBSERVATIONS_1
AS
BEGIN
  DBMS_REFRESH.REFRESH('S_SLF_JOURNAL_OBSERVATIONS_O1');
END;

--

/* �������� ��������� */

COMMIT
