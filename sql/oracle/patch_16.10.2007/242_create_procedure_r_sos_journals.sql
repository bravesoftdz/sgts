/* �������� ��������� ���������� ����� �������� ������� �������-����������� ������ */

CREATE OR REPLACE PROCEDURE R_SOS_JOURNAL_FIELDS
AS
BEGIN
  DBMS_REFRESH.REFRESH('S_SOS_JOURNAL_FIELDS_O');
END;

--

/* �������� ��������� ���������� ����� ������� ���������� �������-����������� ������ */

CREATE OR REPLACE PROCEDURE R_SOS_JOURNAL_OBSERVATIONS
AS
BEGIN
  DBMS_REFRESH.REFRESH('S_SOS_JOURNAL_OBSERVATIONS_O');
END;

--

/* �������� ��������� �� */

COMMIT