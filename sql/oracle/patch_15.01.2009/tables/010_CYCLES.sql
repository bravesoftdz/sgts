/* �������� ������� ������ */

CREATE TABLE CYCLES 
(
  CYCLE_ID INTEGER NOT NULL, 
  CYCLE_NUM INTEGER NOT NULL,
  CYCLE_YEAR INTEGER NOT NULL,
  CYCLE_MONTH INTEGER NOT NULL,
  DESCRIPTION VARCHAR2(250), 
  IS_CLOSE INTEGER NOT NULL,
  PRIMARY KEY (CYCLE_ID)
)  

--

/* �������� ������� �� ������ ����� ������� ������ */

CREATE INDEX IDX_CYCLES_1
 ON CYCLES(CYCLE_NUM)

--

/* �������� ������� �� ���������� ����� ������� ������ */

CREATE INDEX IDX_CYCLES_2
 ON CYCLES(IS_CLOSE)

--  

/* �������� ��������� */

COMMIT