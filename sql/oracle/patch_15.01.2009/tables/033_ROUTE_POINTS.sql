/* �������� ������� ����� ��������� */

CREATE TABLE ROUTE_POINTS 
(
  ROUTE_ID INTEGER NOT NULL, 
  POINT_ID INTEGER NOT NULL, 
  PRIORITY INTEGER NOT NULL,
  PRIMARY KEY (ROUTE_ID,POINT_ID),
  FOREIGN KEY (ROUTE_ID) REFERENCES ROUTES (ROUTE_ID),
  FOREIGN KEY (POINT_ID) REFERENCES POINTS (POINT_ID)
)

--

/* �������� ��������� */

COMMIT