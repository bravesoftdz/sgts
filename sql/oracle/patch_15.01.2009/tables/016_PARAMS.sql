/* �������� ������� ���������� */

CREATE TABLE PARAMS
(
  PARAM_ID INTEGER NOT NULL, 
  ALGORITHM_ID INTEGER,
  NAME VARCHAR2(100) NOT NULL,
  DESCRIPTION VARCHAR2(250),
  PARAM_TYPE INTEGER NOT NULL,
  FORMAT VARCHAR2(100),
  DETERMINATION CLOB,
  IS_NOT_CONFIRM INTEGER,
  PRIMARY KEY (PARAM_ID),
  FOREIGN KEY (ALGORITHM_ID) REFERENCES ALGORITHMS (ALGORITHM_ID)
)

--

/* �������� ��������� */

COMMIT