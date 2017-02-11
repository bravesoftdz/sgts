/* �������� ��������� �������� ������� ������ ������ �������������� */

CREATE MATERIALIZED VIEW S_HDN_JOURNAL_FIELDS_O
NOLOGGING
NOCACHE
NOPARALLEL
BUILD DEFERRED
REFRESH COMPLETE
START WITH TO_DATE('01.01.2007','DD.MM.YYYY')
DISABLE QUERY REWRITE AS
SELECT * FROM TABLE(GET_HDN_JOURNAL_FIELDS(49984,1))

--

/* �������� ������� �� ���� �������� ������� ������ ������ �������������� */

CREATE INDEX IDX_HDN_JF_O1_1 ON S_HDN_JOURNAL_FIELDS_O
(CYCLE_ID)

--

/* �������� ������� �� ���� ���������� �������� ������� ������ ������ �������������� */

CREATE INDEX IDX_HDN_JF_O1_2 ON S_HDN_JOURNAL_FIELDS_O
(DATE_OBSERVATION)

--

/* �������� ������� �� ��� ��������� �������� ������� ������ ������ �������������� */

CREATE INDEX IDX_HDN_JF_O1_3 ON S_HDN_JOURNAL_FIELDS_O
(MEASURE_TYPE_ID)

--

/* �������� ��������� */

COMMIT