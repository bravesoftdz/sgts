/* �������� ��������� ������� ���������� 4 ������ ������ ����������-���������������� ��������� */

CREATE MATERIALIZED VIEW S_NDS_JOURNAL_OBSERVATIONS_O4
NOLOGGING
NOCACHE
NOPARALLEL
BUILD DEFERRED
REFRESH COMPLETE
START WITH TO_DATE('01.01.2007','DD.MM.YYYY')
DISABLE QUERY REWRITE AS
SELECT * FROM TABLE(GET_NDS_JOURNAL_OBSERVATIONS(60004,1))

--

/* �������� ������� �� ���� ������� ���������� 4 ������ ������ ����������-���������������� ��������� */

CREATE INDEX IDX_NDS_JO_O4_1 ON S_NDS_JOURNAL_OBSERVATIONS_O4
(CYCLE_ID)

--

/* �������� ������� �� ���� ���������� ������� ���������� 4 ������ ������ ����������-���������������� ��������� */

CREATE INDEX IDX_NDS_JO_O4_2 ON S_NDS_JOURNAL_OBSERVATIONS_O4
(DATE_OBSERVATION)

--

/* �������� ������� �� ��� ��������� ������� ���������� 4 ������ ������ ����������-���������������� ��������� */

CREATE INDEX IDX_NDS_JO_O4_3 ON S_NDS_JOURNAL_OBSERVATIONS_O4
(MEASURE_TYPE_ID)

--

/* �������� ��������� */

COMMIT