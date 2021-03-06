/* �������� ��������� ���������� ������� */

CREATE OR REPLACE PROCEDURE I_GRAPH (
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
   CNT INTEGER;
   GRAPH_E EXCEPTION;
   ERROR VARCHAR (500);
BEGIN
   SELECT COUNT (*)
     INTO CNT
     FROM GRAPHS
    WHERE UPPER (NAME) = UPPER (I_GRAPH.NAME);

   IF (CNT > 0)
   THEN
      ERROR := '����� ������������ ��� ����������.';
      RAISE GRAPH_E;
   END IF;

   INSERT INTO GRAPHS
               (GRAPH_ID, CUT_ID, NAME, DESCRIPTION, GRAPH_TYPE, DETERMINATION, PRIORITY, MENU)
        VALUES (GRAPH_ID, CUT_ID, NAME, DESCRIPTION, GRAPH_TYPE, DETERMINATION, PRIORITY, MENU);

   COMMIT;
EXCEPTION
   WHEN GRAPH_E
   THEN
      RAISE_APPLICATION_ERROR (-20100, ERROR);
END;

--

/* �������� ��������� */

COMMIT
