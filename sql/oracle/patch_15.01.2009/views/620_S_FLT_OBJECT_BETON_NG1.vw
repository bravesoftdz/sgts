/* �������� ��������� ������� ����� ������� ���������� BETON NG1 */

CREATE OR REPLACE VIEW S_FLT_OBJECT_BETON_NG1
AS
SELECT JO.DATE_OBSERVATION,
       C.CYCLE_NUM,
       O.SHORT_NAME,
       P.COORDINATE_Z,
       JO.VALUE,
       GO.PRIORITY,
       GO.GROUP_ID
  FROM JOURNAL_OBSERVATIONS JO JOIN POINTS P ON P.POINT_ID = JO.POINT_ID
       JOIN CYCLES C ON C.CYCLE_ID = JO.CYCLE_ID
       JOIN OBJECT_TREES OT1 ON OT1.OBJECT_ID = P.OBJECT_ID
       JOIN OBJECT_TREES OT2 ON OT2.OBJECT_TREE_ID = OT1.PARENT_ID
       JOIN OBJECTS O ON O.OBJECT_ID = OT2.OBJECT_ID
       JOIN GROUP_OBJECTS GO ON GO.OBJECT_ID = O.OBJECT_ID
 WHERE JO.MEASURE_TYPE_ID = 2582
   AND GO.GROUP_ID = 2500
   AND JO.PARAM_ID = 3042
   AND P.COORDINATE_Z >= 153

--

/* �������� ��������� */

COMMIT


