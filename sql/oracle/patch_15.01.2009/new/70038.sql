/* ���������� �������� ������� */

BEGIN
   UPDATE JOURNAL_FIELDS
      SET MEASURE_TYPE_ID = 70038
    WHERE MEASURE_TYPE_ID = 49984 AND POINT_ID IN (SELECT POINT_ID
                                                     FROM ROUTE_POINTS
                                                    WHERE ROUTE_ID = 50042);

   COMMIT;
END;
