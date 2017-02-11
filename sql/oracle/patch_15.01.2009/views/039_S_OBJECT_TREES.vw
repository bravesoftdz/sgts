/* �������� ��������� ������ �������� */

CREATE OR REPLACE VIEW S_OBJECT_TREES
AS
SELECT     OT1.OBJECT_TREE_ID,
           OT1.OBJECT_ID,
           OT1.PRIORITY,
           OT1.PARENT_ID,
           O1.NAME AS OBJECT_NAME,
           O1.DESCRIPTION AS OBJECT_DESCRIPTION,
           O2.NAME AS PARENT_NAME
      FROM OBJECT_TREES OT1,
           OBJECTS O1,
           OBJECT_TREES OT2,
           OBJECTS O2
     WHERE OT1.OBJECT_ID = O1.OBJECT_ID
       AND OT1.PARENT_ID = OT2.OBJECT_TREE_ID(+)
       AND OT2.OBJECT_ID = O2.OBJECT_ID(+)
START WITH OT1.PARENT_ID IS NULL
CONNECT BY OT1.PARENT_ID = PRIOR OT1.OBJECT_TREE_ID
  ORDER BY LEVEL,
           OT1.PRIORITY

--

/* �������� ��������� */

COMMIT

