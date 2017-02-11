/* �������� ��������� �������� ������� 1 ������ ������ ����������-���������������� ��������� */

CREATE MATERIALIZED VIEW S_NDS_JOURNAL_FIELDS_O1
NOLOGGING
NOCACHE
NOPARALLEL
BUILD DEFERRED
REFRESH COMPLETE
START WITH TO_DATE('01.01.2007','DD.MM.YYYY')
DISABLE QUERY REWRITE AS
SELECT * FROM TABLE(GET_NDS_JOURNAL_FIELDS(60001,1))

--

/* �������� ������� �� ���� �������� ������� 1 ������ ������ ����������-���������������� ��������� */

CREATE INDEX IDX_NDS_JF_O1_1 ON S_NDS_JOURNAL_FIELDS_O1
(CYCLE_ID)

--

/* �������� ������� �� ���� ���������� �������� ������� 1 ������ ������ ����������-���������������� ��������� */

CREATE INDEX IDX_NDS_JF_O1_2 ON S_NDS_JOURNAL_FIELDS_O1
(DATE_OBSERVATION)

--

/* �������� ������� �� ��� ��������� �������� ������� 1 ������ ������ ����������-���������������� ��������� */

CREATE INDEX IDX_NDS_JF_O1_3 ON S_NDS_JOURNAL_FIELDS_O1
(MEASURE_TYPE_ID)

--

/* �������� ��������� */

COMMIT