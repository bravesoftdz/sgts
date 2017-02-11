/* �������� ��������� ������� ���������� 5 ������ ������ ���������� */

CREATE MATERIALIZED VIEW S_FLT_JOURNAL_OBSERVATIONS_O5
NOLOGGING
NOCACHE
NOPARALLEL
BUILD DEFERRED
REFRESH COMPLETE
START WITH TO_DATE('01.01.2007','DD.MM.YYYY')
DISABLE QUERY REWRITE AS
SELECT * FROM TABLE(GET_FLT_JOURNAL_OBSERVATIONS(2585,1))

--

/* �������� ������� �� ���� ������� ���������� 5 ������ ������ ���������� */

CREATE INDEX IDX_FLT_JO_O5_1 ON S_FLT_JOURNAL_OBSERVATIONS_O5
(CYCLE_ID)

--

/* �������� ������� �� ���� ���������� ������� ���������� 5 ������ ������ ���������� */

CREATE INDEX IDX_FLT_JO_O5_2 ON S_FLT_JOURNAL_OBSERVATIONS_O5
(DATE_OBSERVATION)

--

/* �������� ������� �� ��� ��������� ������� ���������� 5 ������ ������ ���������� */

CREATE INDEX IDX_FLT_JO_O5_3 ON S_FLT_JOURNAL_OBSERVATIONS_O5
(MEASURE_TYPE_ID)

--

/* �������� ��������� */

COMMIT