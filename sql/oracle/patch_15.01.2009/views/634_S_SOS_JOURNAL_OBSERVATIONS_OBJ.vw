/* �������� ��������� ������� ���������� ������ � �������� ��� �������-����������� ������ */

CREATE OR REPLACE VIEW S_SOS_JOURNAL_OBSERVATIONS_OBJ
AS 
SELECT JO.CYCLE_ID,JO.CYCLE_NUM,JO.DATE_OBSERVATION,JO.POINT_ID,JO.POINT_NAME,JO.CONVERTER_ID,JO.CONVERTER_NAME,JO.PLACE_ZERO,JO.DIRECTION_MOVE,
      JO.VALUE,JO.DIFFERENCE_MOVE,JO.VALUE_AVERAGE,JO.ERROR_MARK,JO.OFFSET_MARK_BEGIN_OBSERV,JO.OFFSET_MARK_CYCLE_ZERO,JO.CURRENT_OFFSET_MARK,JO.OBJECT_PATHS,
      P.OBJECT_ID
FROM S_SOS_JOURNAL_OBSERVATIONS JO,  POINTS P
WHERE JO.POINT_ID=P.POINT_ID

--

/* �������� ��������� */

COMMIT


