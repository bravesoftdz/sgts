/* �������� ��������� ���������� ������ ��������� */

CREATE OR REPLACE PROCEDURE R_TVL_JOURNALS
AS
BEGIN
  DBMS_REFRESH.REFRESH('S_TVL_JOURNAL_FIELDS_O');
  DBMS_REFRESH.REFRESH('S_TVL_JOURNAL_OBSERVATIONS_O');
END;

--

/* �������� ��������� �� */

COMMIT