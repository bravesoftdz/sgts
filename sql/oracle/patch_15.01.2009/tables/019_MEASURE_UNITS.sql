/* �������� ������� ������ ��������� */

CREATE TABLE MEASURE_UNITS
(
  MEASURE_UNIT_ID INTEGER NOT NULL, 
  NAME VARCHAR2(100) NOT NULL,
  DESCRIPTION VARCHAR2(250),
  PRIMARY KEY (MEASURE_UNIT_ID)
)

--

/* �������� ��������� */

COMMIT