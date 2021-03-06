/* �������� ������������������ ��� ������� �������� */

CREATE SEQUENCE SEQ_GRAPHS 
INCREMENT BY 1 
START WITH 2500
MAXVALUE 1.0E28 
MINVALUE 2500
NOCYCLE 
CACHE 20 
NOORDER

--

/* �������� ������� ��������� �������������� ��� ������� �������� */

CREATE FUNCTION GET_GRAPH_ID RETURN INTEGER IS
  ID INTEGER;
BEGIN
  SELECT SEQ_GRAPHS.NEXTVAL INTO ID FROM DUAL;
  RETURN ID;
END;

--

/* �������� ������� �������� */

CREATE TABLE GRAPHS 
(
  GRAPH_ID INTEGER NOT NULL,
  CUT_ID INTEGER NOT NULL,
  NAME VARCHAR2(100) NOT NULL,
  DESCRIPTION VARCHAR2(250),
  GRAPH_TYPE INTEGER NOT NULL,
  DETERMINATION CLOB,
  PRIORITY INTEGER NOT NULL,
  MENU VARCHAR2(250),
  PRIMARY KEY (GRAPH_ID),
  FOREIGN KEY (CUT_ID) REFERENCES CUTS (CUT_ID)
)

--

/* �������� ��������� ������� �������� */

CREATE OR REPLACE VIEW S_GRAPHS
AS
  SELECT G.*, 
         C.NAME AS CUT_NAME,
         C.DETERMINATION AS CUT_DETERMINATION,
         C.VIEW_NAME,
         C.CONDITION
    FROM GRAPHS G, CUTS C
   WHERE G.CUT_ID=C.CUT_ID

--

/* �������� ��������� �������� ������� */

CREATE OR REPLACE PROCEDURE I_GRAPH
(
  GRAPH_ID IN INTEGER,
  CUT_ID IN INTEGER,
  NAME IN VARCHAR2,
  DESCRIPTION IN VARCHAR2,
  GRAPH_TYPE IN INTEGER,
  DETERMINATION IN CLOB,
  PRIORITY IN INTEGER,
  MENU IN VARCHAR2
)
AS
BEGIN
  INSERT INTO GRAPHS (GRAPH_ID,CUT_ID,NAME,DESCRIPTION,GRAPH_TYPE,DETERMINATION,PRIORITY,MENU)
       VALUES (GRAPH_ID,CUT_ID,NAME,DESCRIPTION,GRAPH_TYPE,DETERMINATION,PRIORITY,MENU);
	   
  COMMIT;
END;

--

/* �������� ��������� ��������� ������� */

CREATE OR REPLACE PROCEDURE U_GRAPH
(
  GRAPH_ID IN INTEGER,
  CUT_ID IN INTEGER,
  NAME IN VARCHAR2,
  DESCRIPTION IN VARCHAR2,
  GRAPH_TYPE IN INTEGER,
  DETERMINATION IN CLOB,
  PRIORITY IN INTEGER,
  MENU IN VARCHAR2,
  OLD_GRAPH_ID IN INTEGER
)
AS
BEGIN
  UPDATE GRAPHS 
     SET GRAPH_ID=U_GRAPH.GRAPH_ID,
         CUT_ID=U_GRAPH.CUT_ID,
         NAME=U_GRAPH.NAME,
  	   DESCRIPTION=U_GRAPH.DESCRIPTION,
	   GRAPH_TYPE=U_GRAPH.GRAPH_TYPE,
	   DETERMINATION=U_GRAPH.DETERMINATION,
	   PRIORITY=U_GRAPH.PRIORITY,
	   MENU=U_GRAPH.MENU
   WHERE GRAPH_ID=OLD_GRAPH_ID;
  COMMIT;        
END;

--

/* �������� ��������� �������� ������� */

CREATE OR REPLACE PROCEDURE D_GRAPH
(
  OLD_GRAPH_ID IN INTEGER
)
AS
BEGIN
  DELETE FROM GRAPHS
        WHERE GRAPH_ID=OLD_GRAPH_ID;
  COMMIT;        
END;

--

/* �������� ��������� �� */

COMMIT