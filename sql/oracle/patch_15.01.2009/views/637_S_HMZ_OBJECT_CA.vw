/* �������� ��������� ������� � ������� �������� ���������� */

CREATE OR REPLACE VIEW S_HMZ_OBJECT_CA
AS 
SELECT JO.CYCLE_NUM,
       JO.DATE_OBSERVATION,
       OT2.OBJECT_ID,
       O.SHORT_NAME AS OBJECT_NAME,
       GO.GROUP_ID,
       GO.PRIORITY,
       JO.CA
  FROM S_HMZ_JOURNAL_OBSERVATIONS JO,
       POINTS P,
       OBJECT_TREES OT1,
       OBJECT_TREES OT2,
       OBJECTS O,
       GROUP_OBJECTS GO
 WHERE JO.POINT_ID = P.POINT_ID
   AND P.OBJECT_ID = OT1.OBJECT_ID
   AND OT1.PARENT_ID = OT2.OBJECT_TREE_ID
   AND OT2.OBJECT_ID = O.OBJECT_ID
   AND GO.OBJECT_ID = OT2.OBJECT_ID

--

/* �������� ��������� */

COMMIT


