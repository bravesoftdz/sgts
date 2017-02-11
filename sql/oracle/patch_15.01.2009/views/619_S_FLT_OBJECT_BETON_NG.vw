/* �������� ��������� ������� ����� ������� ���������� BETON NG */

CREATE OR REPLACE VIEW S_FLT_OBJECT_BETON_NG
AS 
SELECT JO.DATE_OBSERVATION,
       C.CYCLE_NUM,
       O.SHORT_NAME,
       P.COORDINATE_Z,
       JO.VALUE,
       GO.PRIORITY,
       GO.GROUP_ID
  FROM JOURNAL_OBSERVATIONS JO,
       POINTS P,
       OBJECT_TREES OT1,
       OBJECT_TREES OT2,
       OBJECTS O,
       GROUP_OBJECTS GO,
       CYCLES C
 WHERE JO.POINT_ID = P.POINT_ID
   AND P.OBJECT_ID = OT1.OBJECT_ID
   AND OT1.PARENT_ID = OT2.OBJECT_TREE_ID
   AND OT2.OBJECT_ID = O.OBJECT_ID
   AND GO.OBJECT_ID = O.OBJECT_ID
   AND JO.CYCLE_ID = C.CYCLE_ID
   AND JO.MEASURE_TYPE_ID = 2582
   AND GO.GROUP_ID = 2500
   AND JO.PARAM_ID = 3042
   AND P.COORDINATE_Z >= 153

--

/* �������� ��������� */

COMMIT

