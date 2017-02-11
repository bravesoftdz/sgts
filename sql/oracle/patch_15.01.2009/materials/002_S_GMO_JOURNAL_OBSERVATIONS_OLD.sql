/* �������� ��������� ������� ���������� ������ ������ ����������������� */

CREATE MATERIALIZED VIEW S_GMO_JOURNAL_OBSERVATIONS_OLD
NOLOGGING
NOCACHE
NOPARALLEL
BUILD DEFERRED
REFRESH COMPLETE
START WITH TO_DATE('01.01.2007','DD.MM.YYYY')
DISABLE QUERY REWRITE AS
SELECT * FROM TABLE(GET_GMO_JOURNAL_OBSERVATIONS(1))

--

/* �������� ������� �� ���� ������� ���������� ������ ������ ����������������� */

CREATE INDEX IDX_GMO_JO_OLD_1 ON S_GMO_JOURNAL_OBSERVATIONS_OLD
(CYCLE_ID)

--

/* �������� ������� �� ���� ���������� ������� ���������� ������ ������ ����������������� */

CREATE INDEX IDX_GMO_JO_OLD_2 ON S_GMO_JOURNAL_OBSERVATIONS_OLD
(DATE_OBSERVATION)

--

/* �������� ��������� */

COMMIT

