/* �������� ��������� ���������� ������ �������� ������� ���������� */

CREATE OR REPLACE PROCEDURE R_HMZ_JOURNAL_FIELDS
AS
BEGIN
  DBMS_REFRESH.REFRESH('S_HMZ_JOURNAL_FIELDS_O');
END;

--

/* �������� ��������� ���������� ������ ������� ���������� ���������� */

CREATE OR REPLACE PROCEDURE R_HMZ_JOURNAL_OBSERVATIONS
AS
BEGIN
  DBMS_REFRESH.REFRESH('S_HMZ_JOURNAL_OBSERVATIONS_O');
END;

--

/* �������� ��������� �� */

COMMIT