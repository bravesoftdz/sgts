/* �������� ��������� ���������� ������ �������� ������� ��������� ������������� ��������� */

CREATE OR REPLACE PROCEDURE R_SL1_JOURNAL_FIELDS_1
AS
BEGIN
  DBMS_REFRESH.REFRESH('S_SL1_JOURNAL_FIELDS_O1');
END;

--

/* �������� ��������� ���������� ������ ������� ���������� ��������� ������������� ��������� */

CREATE OR REPLACE PROCEDURE R_SL1_JOURNAL_OBSERVATIONS_1
AS
BEGIN
  DBMS_REFRESH.REFRESH('S_SL1_JOURNAL_OBSERVATIONS_O1');
END;

--

/* �������� ��������� ���������� ������ �������� ������� ��������� ������������� ��������� */

CREATE OR REPLACE PROCEDURE R_SL1_JOURNAL_FIELDS_2
AS
BEGIN
  DBMS_REFRESH.REFRESH('S_SL1_JOURNAL_FIELDS_O2');
END;

--

/* �������� ��������� ���������� ������ ������� ���������� ��������� ������������� ��������� */

CREATE OR REPLACE PROCEDURE R_SL1_JOURNAL_OBSERVATIONS_2
AS
BEGIN
  DBMS_REFRESH.REFRESH('S_SL1_JOURNAL_OBSERVATIONS_O2');
END;

--

/* �������� ��������� ���������� ������ �������� ������� ��������� ��������� �� ������� */

CREATE OR REPLACE PROCEDURE R_SL1_JOURNAL_FIELDS_3
AS
BEGIN
  DBMS_REFRESH.REFRESH('S_SL1_JOURNAL_FIELDS_O3');
END;

--

/* �������� ��������� ���������� ������ ������� ���������� ��������� ��������� �� �������  */

CREATE OR REPLACE PROCEDURE R_SL1_JOURNAL_OBSERVATIONS_3
AS
BEGIN
  DBMS_REFRESH.REFRESH('S_SL1_JOURNAL_OBSERVATIONS_O3');
END;

--

/* �������� ��������� ���������� ������ �������� ������� ��������� ��������� �� ��������� �������  */

CREATE OR REPLACE PROCEDURE R_SL1_JOURNAL_FIELDS_4
AS
BEGIN
  DBMS_REFRESH.REFRESH('S_SL1_JOURNAL_FIELDS_O4');
END;

--

/* �������� ��������� ���������� ������ ������� ���������� ��������� ��������� �� ��������� ������� */

CREATE OR REPLACE PROCEDURE R_SL1_JOURNAL_OBSERVATIONS_4
AS
BEGIN
  DBMS_REFRESH.REFRESH('S_SL1_JOURNAL_OBSERVATIONS_O4');
END;

--

/* �������� ��������� ���������� ������ �������� ������� ��������� ��������� */

CREATE OR REPLACE PROCEDURE R_SL1_JOURNAL_FIELDS
AS
BEGIN
  R_SL1_JOURNAL_FIELDS_1;
  R_SL1_JOURNAL_FIELDS_2;
  R_SL1_JOURNAL_FIELDS_3;
  R_SL1_JOURNAL_FIELDS_4;
END;

--

/* �������� ��������� ���������� ������ ������� ���������� ��������� ��������� */

CREATE OR REPLACE PROCEDURE R_SL1_JOURNAL_OBSERVATIONS
AS
BEGIN
  R_SL1_JOURNAL_OBSERVATIONS_1;
  R_SL1_JOURNAL_OBSERVATIONS_2;
  R_SL1_JOURNAL_OBSERVATIONS_3;
  R_SL1_JOURNAL_OBSERVATIONS_4;
END;

--

/* �������� ��������� �� */

COMMIT