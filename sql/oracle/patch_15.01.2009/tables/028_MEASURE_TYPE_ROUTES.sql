/* �������� ������� ����� ��������� ��������� */

CREATE TABLE MEASURE_TYPE_ROUTES 
(
  MEASURE_TYPE_ID INTEGER NOT NULL, 
  ROUTE_ID INTEGER NOT NULL, 
  PRIORITY INTEGER NOT NULL,
  PRIMARY KEY (MEASURE_TYPE_ID,ROUTE_ID),
  FOREIGN KEY (MEASURE_TYPE_ID) REFERENCES MEASURE_TYPES (MEASURE_TYPE_ID),
  FOREIGN KEY (ROUTE_ID) REFERENCES ROUTES (ROUTE_ID)
)

--

/* �������� ��������� */

COMMIT