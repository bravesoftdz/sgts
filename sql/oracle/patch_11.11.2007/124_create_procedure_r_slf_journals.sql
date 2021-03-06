/* �������� ��������� ���������� ������ �������� ������� ��������� ��������� �� ������� */

CREATE OR REPLACE PROCEDURE R_SLF_JOURNAL_FIELDS_1
AS
BEGIN
  DBMS_REFRESH.REFRESH('S_SLF_JOURNAL_FIELDS_O1');
END;

--

/* �������� ��������� ���������� ������ ������� ���������� ��������� ��������� �� ������� */

CREATE OR REPLACE PROCEDURE R_SLF_JOURNAL_OBSERVATIONS_1
AS
BEGIN
  DBMS_REFRESH.REFRESH('S_SLF_JOURNAL_OBSERVATIONS_O1');
END;

--

/* �������� ��������� ���������� ������ �������� ������� ��������� ��������� �� ������ ��� */

CREATE OR REPLACE PROCEDURE R_SLF_JOURNAL_FIELDS_2
AS
BEGIN
  DBMS_REFRESH.REFRESH('S_SLF_JOURNAL_FIELDS_O2');
END;

--

/* �������� ��������� ���������� ������ ������� ���������� ��������� ��������� �� ������ ��� */

CREATE OR REPLACE PROCEDURE R_SLF_JOURNAL_OBSERVATIONS_2
AS
BEGIN
  DBMS_REFRESH.REFRESH('S_SLF_JOURNAL_OBSERVATIONS_O2');
END;

--

/* �������� ��������� ���������� ������ �������� ������� ��������� ��������� */

CREATE OR REPLACE PROCEDURE R_SLF_JOURNAL_FIELDS
AS
BEGIN
  R_SLF_JOURNAL_FIELDS_1;
  R_SLF_JOURNAL_FIELDS_2;
END;

--

/* �������� ��������� ���������� ������ ������� ���������� ��������� ��������� */

CREATE OR REPLACE PROCEDURE R_SLF_JOURNAL_OBSERVATIONS
AS
BEGIN
  R_SLF_JOURNAL_OBSERVATIONS_1;
  R_SLF_JOURNAL_OBSERVATIONS_2;
END;

--

/* �������� ��������� �� */

COMMIT