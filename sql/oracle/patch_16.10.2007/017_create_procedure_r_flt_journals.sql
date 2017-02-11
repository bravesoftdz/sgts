/* �������� ��������� ���������� ������ �������� ������� ����� ����� �� ������� */

CREATE OR REPLACE PROCEDURE R_FLT_JOURNAL_FIELDS_1
AS
BEGIN
  DBMS_REFRESH.REFRESH('S_FLT_JOURNAL_FIELDS_O1');
END;

--

/* �������� ��������� ���������� ������ ������� ���������� ����� ����� �� ������� */

CREATE OR REPLACE PROCEDURE R_FLT_JOURNAL_OBSERVATIONS_1
AS
BEGIN
  DBMS_REFRESH.REFRESH('S_FLT_JOURNAL_OBSERVATIONS_O1');
END;

--

/* �������� ��������� ���������� ������ �������� ������� ����� ��� �� ������� */

CREATE OR REPLACE PROCEDURE R_FLT_JOURNAL_FIELDS_2
AS
BEGIN
  DBMS_REFRESH.REFRESH('S_FLT_JOURNAL_FIELDS_O2');
END;

--

/* �������� ��������� ���������� ������ ������� ���������� ����� ��� �� ������� */

CREATE OR REPLACE PROCEDURE R_FLT_JOURNAL_OBSERVATIONS_2
AS
BEGIN
  DBMS_REFRESH.REFRESH('S_FLT_JOURNAL_OBSERVATIONS_O2');
END;

--

/* �������� ��������� ���������� ������ �������� ������� ������� ���. ������� 1 ���� */

CREATE OR REPLACE PROCEDURE R_FLT_JOURNAL_FIELDS_3
AS
BEGIN
  DBMS_REFRESH.REFRESH('S_FLT_JOURNAL_FIELDS_O3');
END;

--

/* �������� ��������� ���������� ������ ������� ���������� ������� ���. ������� 1 ���� */

CREATE OR REPLACE PROCEDURE R_FLT_JOURNAL_OBSERVATIONS_3
AS
BEGIN
  DBMS_REFRESH.REFRESH('S_FLT_JOURNAL_OBSERVATIONS_O3');
END;

--

/* �������� ��������� ���������� ������ �������� ������� ����� ���������� ��� */

CREATE OR REPLACE PROCEDURE R_FLT_JOURNAL_FIELDS_4
AS
BEGIN
  DBMS_REFRESH.REFRESH('S_FLT_JOURNAL_FIELDS_O4');
END;

--

/* �������� ��������� ���������� ������ ������� ���������� ����� ���������� ��� */

CREATE OR REPLACE PROCEDURE R_FLT_JOURNAL_OBSERVATIONS_4
AS
BEGIN
  DBMS_REFRESH.REFRESH('S_FLT_JOURNAL_OBSERVATIONS_O4');
END;

--

/* �������� ��������� ���������� ������ �������� ������� �������. ������. � ��������� */

CREATE OR REPLACE PROCEDURE R_FLT_JOURNAL_FIELDS_5
AS
BEGIN
  DBMS_REFRESH.REFRESH('S_FLT_JOURNAL_FIELDS_O5');
END;

--

/* �������� ��������� ���������� ������ ������� ���������� �������. ������. � ��������� */

CREATE OR REPLACE PROCEDURE R_FLT_JOURNAL_OBSERVATIONS_5
AS
BEGIN
  DBMS_REFRESH.REFRESH('S_FLT_JOURNAL_OBSERVATIONS_O5');
END;

--

/* �������� ��������� ���������� ������ �������� ������� ������� ���. ������� 2 ���� */

CREATE OR REPLACE PROCEDURE R_FLT_JOURNAL_FIELDS_6
AS
BEGIN
  DBMS_REFRESH.REFRESH('S_FLT_JOURNAL_FIELDS_O6');
END;

--

/* �������� ��������� ���������� ������ ������� ���������� ������� ���. ������� 2 ���� */

CREATE OR REPLACE PROCEDURE R_FLT_JOURNAL_OBSERVATIONS_6
AS
BEGIN
  DBMS_REFRESH.REFRESH('S_FLT_JOURNAL_OBSERVATIONS_O6');
END;

--

/* �������� ��������� ���������� ������ �������� ������� ���������� */

CREATE OR REPLACE PROCEDURE R_FLT_JOURNAL_FIELDS
AS
BEGIN
  R_FLT_JOURNAL_FIELDS_1;
  R_FLT_JOURNAL_FIELDS_2;
  R_FLT_JOURNAL_FIELDS_3;
  R_FLT_JOURNAL_FIELDS_4;
  R_FLT_JOURNAL_FIELDS_5;
  R_FLT_JOURNAL_FIELDS_6;
END;

--

/* �������� ��������� ���������� ������ ������� ���������� ���������� */

CREATE OR REPLACE PROCEDURE R_FLT_JOURNAL_OBSERVATIONS
AS
BEGIN
  R_FLT_JOURNAL_OBSERVATIONS_1;
  R_FLT_JOURNAL_OBSERVATIONS_2;
  R_FLT_JOURNAL_OBSERVATIONS_3;
  R_FLT_JOURNAL_OBSERVATIONS_4;
  R_FLT_JOURNAL_OBSERVATIONS_5;
  R_FLT_JOURNAL_OBSERVATIONS_6;
END;

--

/* �������� ��������� �� */

COMMIT