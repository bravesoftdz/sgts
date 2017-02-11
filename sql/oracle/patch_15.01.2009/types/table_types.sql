/* �������� ���� ������� ��� ��������� ������������ */

CREATE OR REPLACE TYPE CRITERIA_TABLE AS TABLE OF CRITERIA_OBJECT

--

/* �������� ���� ������� ��� �������� ������� ���������� */

CREATE OR REPLACE TYPE FLT_JOURNAL_FIELD_TABLE AS TABLE OF FLT_JOURNAL_FIELD_OBJECT

--

/* �������� ���� ������� ��� ������� ���������� ���������� */

CREATE OR REPLACE TYPE FLT_JOURNAL_OBSERVATION_TABLE AS TABLE OF FLT_JOURNAL_OBSERVATION_OBJECT

--

/* �������� ���� ������� ��� �������� ������� ����������������� */

CREATE OR REPLACE TYPE GMO_JOURNAL_FIELD_TABLE AS TABLE OF GMO_JOURNAL_FIELD_OBJECT

--

/* �������� ���� ������� ��� ������� ���������� ���������������� */

CREATE OR REPLACE TYPE GMO_JOURNAL_OBSERVATION_TABLE AS TABLE OF GMO_JOURNAL_OBSERVATION_OBJECT

--

/* �������� ���� ������� ��� �������� ������� �������������� */

CREATE OR REPLACE TYPE HDN_JOURNAL_FIELD_TABLE AS TABLE OF HDN_JOURNAL_FIELD_OBJECT

--

/* �������� ���� ������� ��� ������� ���������� �������������� */

CREATE OR REPLACE TYPE HDN_JOURNAL_OBSERVATION_TABLE AS TABLE OF HDN_JOURNAL_OBSERVATION_OBJECT

--

/* �������� ���� ������� ��� �������� ������� ���������� */

CREATE OR REPLACE TYPE HMZ_JOURNAL_FIELD_TABLE AS TABLE OF HMZ_JOURNAL_FIELD_OBJECT

--

/* �������� ���� ������� ��� ������� ���������� ���������� */

CREATE OR REPLACE TYPE HMZ_JOURNAL_OBSERVATION_TABLE AS TABLE OF HMZ_JOURNAL_OBSERVATION_OBJECT

--

/* �������� ���� ������� ��� �������� ������� ����������� ������� */

CREATE OR REPLACE TYPE IND_JOURNAL_FIELD_TABLE AS TABLE OF IND_JOURNAL_FIELD_OBJECT

--

/* �������� ���� ������� ��� ������� ���������� ����������� ������� */

CREATE OR REPLACE TYPE IND_JOURNAL_OBSERVATION_TABLE AS TABLE OF IND_JOURNAL_OBSERVATION_OBJECT

--

/* �������� ���� ������� ��� �������� ������� ����������-���������������� ��������� */

CREATE OR REPLACE TYPE NDS_JOURNAL_FIELD_TABLE AS TABLE OF NDS_JOURNAL_FIELD_OBJECT

--

/* �������� ���� ������� ��� ������� ���������� ����������-���������������� ��������� */

CREATE OR REPLACE TYPE NDS_JOURNAL_OBSERVATION_TABLE AS TABLE OF NDS_JOURNAL_OBSERVATION_OBJECT

--

/* �������� ���� ������� ��� �������� ������� ������������� */

CREATE OR REPLACE TYPE NIV_JOURNAL_FIELD_TABLE AS TABLE OF NIV_JOURNAL_FIELD_OBJECT

--

/* �������� ���� ������� ��� ������� ���������� ������������� */

CREATE OR REPLACE TYPE NIV_JOURNAL_OBSERVATION_TABLE AS TABLE OF NIV_JOURNAL_OBSERVATION_OBJECT

--

/* �������� ���� ������� ��� �������� ������� NMH */

CREATE OR REPLACE TYPE NMH_JOURNAL_FIELD_TABLE AS TABLE OF NMH_JOURNAL_FIELD_OBJECT

--

/* �������� ���� ������� ��� �������� ������� ������� */

CREATE OR REPLACE TYPE OTV_JOURNAL_FIELD_TABLE AS TABLE OF OTV_JOURNAL_FIELD_OBJECT

--

/* �������� ���� ������� ��� ������� ���������� ������� */

CREATE OR REPLACE TYPE OTV_JOURNAL_OBSERVATION_TABLE AS TABLE OF OTV_JOURNAL_OBSERVATION_OBJECT

--

/* �������� ���� ������� ��� ������������� ����� */

CREATE OR REPLACE TYPE POINT_TABLE AS TABLE OF POINT_OBJECT

--

/* �������� ���� ������� ��� �������� ������� �������-��������� ����������� */

CREATE OR REPLACE TYPE PVO_JOURNAL_FIELD_TABLE AS TABLE OF PVO_JOURNAL_FIELD_OBJECT

--

/* �������� ���� ������� ��� ������� ���������� �������-��������� ����������� */

CREATE OR REPLACE TYPE PVO_JOURNAL_OBSERVATION_TABLE AS TABLE OF PVO_JOURNAL_OBSERVATION_OBJECT

--

/* �������� ���� ������� ��� �������� ������� ����������� */

CREATE OR REPLACE TYPE PZM_JOURNAL_FIELD_TABLE AS TABLE OF PZM_JOURNAL_FIELD_OBJECT

--

/* �������� ���� ������� ��� ������� ���������� ����������� */

CREATE OR REPLACE TYPE PZM_JOURNAL_OBSERVATION_TABLE AS TABLE OF PZM_JOURNAL_OBSERVATION_OBJECT

--

/* �������� ���� ������� ��� ������ �������� ������������ */

CREATE OR REPLACE TYPE REPORT_CRITERIA_TABLE AS TABLE OF REPORT_CRITERIA_OBJECT

--

/* �������� ���� ������� ��� �������� ������� ��������� ��������� */

CREATE OR REPLACE TYPE SL1_JOURNAL_FIELD_TABLE AS TABLE OF SL1_JOURNAL_FIELD_OBJECT

--

/* �������� ���� ������� ��� ������� ���������� ��������� ��������� */

CREATE OR REPLACE TYPE SL1_JOURNAL_OBSERVATION_TABLE AS TABLE OF SL1_JOURNAL_OBSERVATION_OBJECT

--

/* �������� ���� ������� ��� �������� ������� ��������� ��������� */

CREATE OR REPLACE TYPE SLF_JOURNAL_FIELD_TABLE AS TABLE OF SLF_JOURNAL_FIELD_OBJECT

--

/* �������� ���� ������� ��� ������� ���������� ��������� ��������� */

CREATE OR REPLACE TYPE SLF_JOURNAL_OBSERVATION_TABLE AS TABLE OF SLF_JOURNAL_OBSERVATION_OBJECT

--

/* �������� ���� ������� ��� �������� ������� ��������� ��������� */

CREATE OR REPLACE TYPE SLW_JOURNAL_FIELD_TABLE AS TABLE OF SLW_JOURNAL_FIELD_OBJECT

--

/* �������� ���� ������� ��� ������� ���������� ��������� ��������� */

CREATE OR REPLACE TYPE SLW_JOURNAL_OBSERVATION_TABLE AS TABLE OF SLW_JOURNAL_OBSERVATION_OBJECT

--

/* �������� ���� ������� ��� ������� ������� �������-����������� ������ */

CREATE OR REPLACE TYPE SOS_JOURNAL_FIELD_TABLE AS TABLE OF SOS_JOURNAL_FIELD_OBJECT

--

/* �������� ���� ������� ��� ������� ���������� �������-����������� ������ */

CREATE OR REPLACE TYPE SOS_JOURNAL_OBSERVATION_TABLE AS TABLE OF SOS_JOURNAL_OBSERVATION_OBJECT

--

/* �������� ���� ������� ��� �������� ������� ����������� � ��������� */

CREATE OR REPLACE TYPE TVL_JOURNAL_FIELD_TABLE AS TABLE OF TVL_JOURNAL_FIELD_OBJECT

--

/* �������� ���� ������� ��� ������� ���������� ����������� � ��������� */

CREATE OR REPLACE TYPE TVL_JOURNAL_OBSERVATION_TABLE AS TABLE OF TVL_JOURNAL_OBSERVATION_OBJECT

--

/* �������� ���� ������� ��� ����� */

CREATE OR REPLACE TYPE VARCHAR_TABLE AS TABLE OF VARCHAR_OBJECT

--

/* �������� ��������� */

COMMIT
