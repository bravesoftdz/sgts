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
  CNT INTEGER;
  GRAPH_E EXCEPTION;
  ERROR VARCHAR(500);
  OLD_NAME VARCHAR2(250);
BEGIN
  
  SELECT COUNT(*) INTO CNT FROM GRAPHS 
   WHERE UPPER(NAME)=UPPER(U_GRAPH.NAME) 
     AND GRAPH_ID<>U_GRAPH.OLD_GRAPH_ID;
  IF (CNT>0) THEN
    ERROR:='����� ������������ ��� ����������.';
    RAISE GRAPH_E;
  END IF;
  
  SELECT NAME INTO OLD_NAME
    FROM GRAPHS
   WHERE GRAPH_ID=OLD_GRAPH_ID;
   	
  UPDATE PERMISSIONS
     SET INTERFACE=U_GRAPH.NAME
   WHERE INTERFACE=OLD_NAME;
   
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
          
EXCEPTION
  WHEN GRAPH_E THEN 
       RAISE_APPLICATION_ERROR(-20100,ERROR);
END;

--

/* �������� ��������� �� */

COMMIT