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

/* �������� ��������� ������� ����� ��������� */

CREATE OR REPLACE VIEW S_DEVICE_POINTS
AS
  SELECT DP.*, 
         D.NAME AS DEVICE_NAME, 
		 P.NAME AS POINT_NAME
    FROM DEVICE_POINTS DP, DEVICES D, POINTS P
   WHERE D.DEVICE_ID=DP.DEVICE_ID 
     AND P.POINT_ID=DP.POINT_ID

--

/* �������� ��������� ���������� ����� ���������� */

CREATE PROCEDURE I_DEVICE_POINT
(
  DEVICE_ID IN INTEGER,
  POINT_ID IN INTEGER,
  PRIORITY IN INTEGER
)
AS
BEGIN
  INSERT INTO DEVICE_POINTS (DEVICE_ID,POINT_ID,PRIORITY)
       VALUES (DEVICE_ID,POINT_ID,PRIORITY);
  COMMIT;
END;

--

/* �������� ��������� ��������� ����� � ���������� */

CREATE OR REPLACE PROCEDURE U_DEVICE_POINT
(
  DEVICE_ID IN INTEGER,
  POINT_ID IN INTEGER,
  PRIORITY IN INTEGER,
  OLD_DEVICE_ID IN INTEGER,
  OLD_POINT_ID IN INTEGER
)
AS
BEGIN
  UPDATE DEVICE_POINTS 
     SET DEVICE_ID=U_DEVICE_POINT.DEVICE_ID,
         POINT_ID=U_DEVICE_POINT.POINT_ID,
         PRIORITY=U_DEVICE_POINT.PRIORITY
   WHERE DEVICE_ID=OLD_DEVICE_ID 
     AND POINT_ID=OLD_POINT_ID;
  COMMIT;        
END;

--

/* �������� ��������� �������� ����� � ���������� */

CREATE PROCEDURE D_DEVICE_POINT
(
  OLD_DEVICE_ID IN INTEGER,
  OLD_POINT_ID IN INTEGER
)
AS
BEGIN
  DELETE FROM DEVICE_POINTS
        WHERE DEVICE_ID=OLD_DEVICE_ID
          AND POINT_ID=OLD_POINT_ID;
  COMMIT;        
END;

--

/* �������� ��������� �� */

COMMIT