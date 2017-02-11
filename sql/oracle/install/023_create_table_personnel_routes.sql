/* �������� ������� ��������� ��������� */

CREATE TABLE PERSONNEL_ROUTES 
(
PERSONNEL_ID INTEGER NOT NULL, 
ROUTE_ID INTEGER NOT NULL, 
DEPUTY_ID INTEGER,
DATE_PURPOSE DATE NOT NULL,
PRIMARY KEY (PERSONNEL_ID,ROUTE_ID),
FOREIGN KEY (PERSONNEL_ID) REFERENCES PERSONNELS (PERSONNEL_ID),
FOREIGN KEY (ROUTE_ID) REFERENCES ROUTES (ROUTE_ID),
FOREIGN KEY (DEPUTY_ID) REFERENCES PERSONNELS (PERSONNEL_ID)
)


--

/* �������� ��������� ������� ��������� ��������� */

CREATE OR REPLACE VIEW S_PERSONNEL_ROUTES
AS
  SELECT PR.*, 
         P1.FNAME||' '||P1.NAME||' '||P1.SNAME AS PERSONNEL_NAME, 
         R.NAME AS ROUTE_NAME, 
         P2.FNAME||' '||P2.NAME||' '||P2.SNAME AS DEPUTY_NAME
    FROM PERSONNEL_ROUTES PR, PERSONNELS P1, ROUTES R, PERSONNELS P2
   WHERE P1.PERSONNEL_ID=PR.PERSONNEL_ID 
     AND R.ROUTE_ID=PR.ROUTE_ID
     AND PR.DEPUTY_ID=P2.PERSONNEL_ID (+) 

--

/* �������� ��������� ���������� �������� ��������� */

CREATE PROCEDURE I_PERSONNEL_ROUTE
(
  PERSONNEL_ID IN INTEGER,
  ROUTE_ID IN INTEGER,
  DEPUTY_ID IN INTEGER,
  DATE_PURPOSE IN DATE
)
AS
BEGIN
  INSERT INTO PERSONNEL_ROUTES (PERSONNEL_ID,ROUTE_ID,DEPUTY_ID,DATE_PURPOSE)
       VALUES (PERSONNEL_ID,ROUTE_ID,DEPUTY_ID,DATE_PURPOSE);
  COMMIT;
END;

--

/* �������� ��������� ��������� �������� ��������� */

CREATE OR REPLACE PROCEDURE U_PERSONNEL_ROUTE
(
  PERSONNEL_ID IN INTEGER,
  ROUTE_ID IN INTEGER,
  DEPUTY_ID IN INTEGER,
  DATE_PURPOSE IN DATE,
  OLD_PERSONNEL_ID IN INTEGER,
  OLD_ROUTE_ID IN INTEGER
)
AS
BEGIN
  UPDATE PERSONNEL_ROUTES 
     SET PERSONNEL_ID=U_PERSONNEL_ROUTE.PERSONNEL_ID,
         ROUTE_ID=U_PERSONNEL_ROUTE.ROUTE_ID,
         DEPUTY_ID=U_PERSONNEL_ROUTE.DEPUTY_ID,
         DATE_PURPOSE=U_PERSONNEL_ROUTE.DATE_PURPOSE
   WHERE PERSONNEL_ID=OLD_PERSONNEL_ID 
     AND ROUTE_ID=OLD_ROUTE_ID;
  COMMIT;        
END;

--

/* �������� ��������� �������� �������� ��������� */

CREATE PROCEDURE D_PERSONNEL_ROUTE
(
  OLD_PERSONNEL_ID IN INTEGER,
  OLD_ROUTE_ID IN INTEGER
)
AS
BEGIN
  DELETE FROM PERSONNEL_ROUTES
        WHERE PERSONNEL_ID=OLD_PERSONNEL_ID
          AND ROUTE_ID=OLD_ROUTE_ID;
  COMMIT;        
END;

--

/* �������� ��������� �� */

COMMIT