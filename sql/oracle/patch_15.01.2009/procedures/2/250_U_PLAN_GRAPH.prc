/* �������� ��������� ��������� �����-������� */

CREATE OR REPLACE PROCEDURE U_PLAN_GRAPH
( 
  YEAR         INTEGER,   
  MEASURE_TYPE_ID  INTEGER, 
  JANUARY          INTEGER, 
  FEBRUARY         INTEGER, 
  MARCH            INTEGER, 
  APRIL            INTEGER, 
  MAY              INTEGER, 
  JUNE             INTEGER, 
  JULY             INTEGER, 
  AUGUST           INTEGER, 
  SEPTEMBER        INTEGER, 
  OKTOBER          INTEGER, 
  NOVEMBER         INTEGER, 
  DECEMBER         INTEGER   
) 
AS     
BEGIN 
  UPDATE MEASURE_TYPE_GRAPHS   
     SET JANUARY=U_PLAN_GRAPH.JANUARY, 
    FEBRUARY=U_PLAN_GRAPH.FEBRUARY, 
   MARCH=U_PLAN_GRAPH.MARCH, 
   APRIL=U_PLAN_GRAPH.APRIL, 
   MAY=U_PLAN_GRAPH.MAY, 
   JUNE=U_PLAN_GRAPH.JUNE, 
   JULY=U_PLAN_GRAPH.JULY, 
   AUGUST=U_PLAN_GRAPH.AUGUST, 
   SEPTEMBER=U_PLAN_GRAPH.SEPTEMBER, 
   OKTOBER=U_PLAN_GRAPH.OKTOBER, 
   NOVEMBER=U_PLAN_GRAPH.NOVEMBER, 
   DECEMBER=U_PLAN_GRAPH.DECEMBER 
   WHERE YEAR=U_PLAN_GRAPH.YEAR 
     AND MEASURE_TYPE_ID=U_PLAN_GRAPH.MEASURE_TYPE_ID;    
  COMMIT;         
END;

--

/* �������� ��������� */

COMMIT

