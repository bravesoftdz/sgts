/* �������� ��������� ������� ���������� ������ ������ ����������� � ��������� */

CREATE MATERIALIZED VIEW S_TVL_JOURNAL_OBSERVATIONS_O
NOLOGGING
NOCACHE
NOPARALLEL
BUILD DEFERRED
REFRESH COMPLETE
START WITH TO_DATE('01.01.2007','DD.MM.YYYY')
DISABLE QUERY REWRITE AS
SELECT * FROM TABLE(GET_TVL_JOURNAL_OBSERVATIONS(1))

--

/* �������� ������� �� ���� ������� ���������� ������ ������ ����������� � ��������� */

CREATE INDEX IDX_TVL_JO_O_1 ON S_TVL_JOURNAL_OBSERVATIONS_O
(CYCLE_ID)

--

/* �������� ������� �� ���� ���������� ������� ���������� ������ ������ ����������� � ��������� */

CREATE INDEX IDX_TVL_JO_O_2 ON S_TVL_JOURNAL_OBSERVATIONS_O
(DATE_OBSERVATION)

--

/* �������� ������� �� ��� ��������� ������� ���������� ������ ������ ����������� � ��������� */

CREATE INDEX IDX_TVL_JO_O_3 ON S_TVL_JOURNAL_OBSERVATIONS_O
(MEASURE_TYPE_ID)

--

/* �������� ��������� */

COMMIT
