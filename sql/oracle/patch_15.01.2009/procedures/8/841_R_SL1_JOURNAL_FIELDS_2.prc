/* �������� ��������� ���������� �������� ������� 2 ������ ������ ��������� ��������� */

CREATE OR REPLACE PROCEDURE R_SL1_JOURNAL_FIELDS_2
AS
BEGIN
  DBMS_REFRESH.REFRESH('S_SL1_JOURNAL_FIELDS_O2');
END;

--

/* �������� ��������� */

COMMIT
