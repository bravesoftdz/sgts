/* �������� ��������� �������� �������� */

CREATE OR REPLACE PROCEDURE D_GRAPH (
   OLD_GRAPH_ID IN INTEGER
)
AS
   OLD_NAME VARCHAR2 (250);
BEGIN
   SELECT NAME
     INTO OLD_NAME
     FROM GRAPHS
    WHERE GRAPH_ID = OLD_GRAPH_ID;

   DELETE FROM PERMISSIONS
         WHERE INTERFACE = OLD_NAME;

   DELETE FROM GRAPHS
         WHERE GRAPH_ID = OLD_GRAPH_ID;

   COMMIT;
END;

--

/* �������� ��������� */

COMMIT

