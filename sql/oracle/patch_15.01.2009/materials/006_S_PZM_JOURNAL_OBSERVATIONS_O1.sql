/* �������� ��������� ������� ���������� 1 ������ ������ ����������� */

CREATE MATERIALIZED VIEW S_PZM_JOURNAL_OBSERVATIONS_O1
NOLOGGING
NOCACHE
NOPARALLEL
BUILD DEFERRED
REFRESH COMPLETE
START WITH TO_DATE('01.01.2007','DD.MM.YYYY')
DISABLE QUERY REWRITE AS
SELECT * FROM TABLE(GET_PZM_JOURNAL_OBSERVATIONS(2561,1))

--

/* �������� ������� �� ���� ������� ���������� 1 ������ ������ ����������� */

CREATE INDEX IDX_PZM_JO_O1_1 ON S_PZM_JOURNAL_OBSERVATIONS_O1
(CYCLE_ID)

--

/* �������� ������� �� ���� ���������� ������� ���������� 1 ������ ������ ����������� */

CREATE INDEX IDX_PZM_JO_O1_2 ON S_PZM_JOURNAL_OBSERVATIONS_O1
(DATE_OBSERVATION)

--

/* �������� ������� �� ��� ��������� ������� ���������� 1 ������ ������ ����������� */

CREATE INDEX IDX_PZM_JO_O1_3 ON S_PZM_JOURNAL_OBSERVATIONS_O1
(MEASURE_TYPE_ID)

--

/* �������� ������� �� ����� ������� ���������� 1 ������ ������ ����������� */

CREATE INDEX IDX_PZM_JO_O1_4 ON S_PZM_JOURNAL_OBSERVATIONS_O1
(POINT_ID)

--

/* �������� ��������� */

COMMIT