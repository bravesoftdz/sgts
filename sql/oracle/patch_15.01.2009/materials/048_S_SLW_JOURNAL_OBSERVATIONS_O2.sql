/* �������� ��������� ������� ���������� 2 ������ ������ ��������� ��������� */

CREATE MATERIALIZED VIEW S_SLW_JOURNAL_OBSERVATIONS_O2
NOLOGGING
NOCACHE
NOPARALLEL
BUILD DEFERRED
REFRESH COMPLETE
START WITH TO_DATE('01.01.2007','DD.MM.YYYY')
DISABLE QUERY REWRITE AS
SELECT * FROM TABLE(GET_SLW_JOURNAL_OBSERVATIONS(30007,1))

--

/* �������� ������� �� ���� ������� ���������� 2 ������ ������ ��������� ��������� */

CREATE INDEX IDX_SLW_JO_O2_1 ON S_SLW_JOURNAL_OBSERVATIONS_O2
(CYCLE_ID)

--

/* �������� ������� �� ���� ���������� ������� ���������� 2 ������ ������ ��������� ��������� */

CREATE INDEX IDX_SLW_JO_O2_2 ON S_SLW_JOURNAL_OBSERVATIONS_O2
(DATE_OBSERVATION)

--

/* �������� ������� �� ��� ��������� ������� ���������� 2 ������ ������ ��������� ��������� */

CREATE INDEX IDX_SLW_JO_O2_3 ON S_SLW_JOURNAL_OBSERVATIONS_O2
(MEASURE_TYPE_ID)


--

/* �������� ��������� */

COMMIT
