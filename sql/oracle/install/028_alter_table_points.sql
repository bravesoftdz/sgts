/* ���������� ������� ��������� ������������� ����� */

CREATE OR REPLACE VIEW S_POINTS
AS 
SELECT P.*, PT.NAME AS POINT_TYPE_NAME, O.NAME AS OBJECT_NAME,
         TRIM(CHR(10) FROM TRIM(CHR(13) FROM GET_OBJECT_PATHS(P.OBJECT_ID))) AS OBJECT_PATHS
    FROM POINTS P, POINT_TYPES PT, OBJECTS O
   WHERE P.POINT_TYPE_ID=PT.POINT_TYPE_ID
     AND P.OBJECT_ID=O.OBJECT_ID

--

/* �������� ��������� �� */

COMMIT