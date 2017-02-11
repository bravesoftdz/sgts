/* �������� ��������� ������� ���������� 3 ������ ������ ����������-���������������� ��������� */

CREATE MATERIALIZED VIEW S_NDS_JOURNAL_OBSERVATIONS_O3
NOLOGGING
NOCACHE
NOPARALLEL
BUILD DEFERRED
REFRESH COMPLETE
START WITH TO_DATE('01.01.2007','DD.MM.YYYY')
DISABLE QUERY REWRITE AS
SELECT * FROM TABLE(GET_NDS_JOURNAL_OBSERVATIONS(60003,1))

--

/* �������� ������� �� ���� ������� ���������� 3 ������ ������ ����������-���������������� ��������� */

CREATE INDEX IDX_NDS_JO_O3_1 ON S_NDS_JOURNAL_OBSERVATIONS_O3
(CYCLE_ID)

--

/* �������� ������� �� ���� ���������� ������� ���������� 3 ������ ������ ����������-���������������� ��������� */

CREATE INDEX IDX_NDS_JO_O3_2 ON S_NDS_JOURNAL_OBSERVATIONS_O3
(DATE_OBSERVATION)

--

/* �������� ������� �� ��� ��������� ������� ���������� 3 ������ ������ ����������-���������������� ��������� */

CREATE INDEX IDX_NDS_JO_O3_3 ON S_NDS_JOURNAL_OBSERVATIONS_O3
(MEASURE_TYPE_ID)

--

/* �������� ��������� */

COMMIT