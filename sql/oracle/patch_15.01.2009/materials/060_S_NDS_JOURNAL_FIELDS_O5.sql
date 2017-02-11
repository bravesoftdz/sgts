/* �������� ��������� �������� ������� 5 ������ ������ ����������-���������������� ��������� */

CREATE MATERIALIZED VIEW S_NDS_JOURNAL_FIELDS_O5
NOLOGGING
NOCACHE
NOPARALLEL
BUILD DEFERRED
REFRESH COMPLETE
START WITH TO_DATE('01.01.2007','DD.MM.YYYY')
DISABLE QUERY REWRITE AS
SELECT * FROM TABLE(GET_NDS_JOURNAL_FIELDS(60005,1))

--

/* �������� ������� �� ���� �������� ������� 5 ������ ������ ����������-���������������� ��������� */

CREATE INDEX IDX_NDS_JF_O5_1 ON S_NDS_JOURNAL_FIELDS_O5
(CYCLE_ID)

--

/* �������� ������� �� ���� ���������� �������� ������� 5 ������ ������ ����������-���������������� ��������� */

CREATE INDEX IDX_NDS_JF_O5_2 ON S_NDS_JOURNAL_FIELDS_O5
(DATE_OBSERVATION)

--

/* �������� ������� �� ��� ��������� �������� ������� 5 ������ ������ ����������-���������������� ��������� */

CREATE INDEX IDX_NDS_JF_O5_3 ON S_NDS_JOURNAL_FIELDS_O5
(MEASURE_TYPE_ID)

--

/* �������� ��������� */

COMMIT