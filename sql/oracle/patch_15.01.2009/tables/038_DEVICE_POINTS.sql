/* �������� ������� ����� ��������� */

CREATE TABLE DEVICE_POINTS 
(
  DEVICE_ID INTEGER NOT NULL, 
  POINT_ID INTEGER NOT NULL, 
  PRIORITY INTEGER NOT NULL,
  PRIMARY KEY (DEVICE_ID,POINT_ID),
  FOREIGN KEY (DEVICE_ID) REFERENCES DEVICES (DEVICE_ID),
  FOREIGN KEY (POINT_ID) REFERENCES POINTS (POINT_ID)
)

--


/* �������� ��������� */

COMMIT