/* �������� ������� �������� */

CREATE TABLE CHECKINGS
(
  CHECKING_ID INTEGER NOT NULL,
  MEASURE_TYPE_ID INTEGER NOT NULL,
  POINT_ID INTEGER,
  PARAM_ID INTEGER NOT NULL,  
  ALGORITHM_ID INTEGER NOT NULL,
  NAME VARCHAR2(100) NOT NULL,
  DESCRIPTION VARCHAR2(250),
  PRIORITY INTEGER,
  ENABLED INTEGER NOT NULL,
  PRIMARY KEY (CHECKING_ID),
  FOREIGN KEY (MEASURE_TYPE_ID) REFERENCES MEASURE_TYPES (MEASURE_TYPE_ID),
  FOREIGN KEY (POINT_ID) REFERENCES POINTS (POINT_ID),
  FOREIGN KEY (PARAM_ID) REFERENCES PARAMS (PARAM_ID),
  FOREIGN KEY (ALGORITHM_ID) REFERENCES ALGORITHMS (ALGORITHM_ID)
)

--

/* �������� ��������� */

COMMIT
