/* �������� ��������� �������� �������� �� 5 ��� +10% */

CREATE OR REPLACE PROCEDURE CHECK_5_YEAR_PLUS_10 (
   DATE_OBSERVATION IN DATE,
   CYCLE_ID IN INTEGER,
   MEASURE_TYPE_ID IN INTEGER,
   OBJECT_ID IN INTEGER,
   POINT_ID IN INTEGER,
   PARAM_ID IN INTEGER,
   VALUE IN FLOAT,
   SUCCESS OUT INTEGER,
   INFO OUT VARCHAR2
)
AS
   AVALUE FLOAT;
   AMONTH INTEGER;
   AYEAR INTEGER;
   S VARCHAR2 (100);
BEGIN
   AMONTH := EXTRACT (MONTH FROM DATE_OBSERVATION);
   AYEAR := EXTRACT (YEAR FROM DATE_OBSERVATION);

   SELECT SUM (JF.VALUE) / COUNT (*)
     INTO AVALUE
     FROM JOURNAL_FIELDS JF
    WHERE EXTRACT (MONTH FROM JF.DATE_OBSERVATION) = AMONTH
      AND EXTRACT (YEAR FROM JF.DATE_OBSERVATION) >= (AYEAR - 5)
      AND JF.MEASURE_TYPE_ID = CHECK_5_YEAR_PLUS_10.MEASURE_TYPE_ID
      AND JF.POINT_ID = CHECK_5_YEAR_PLUS_10.POINT_ID
      AND JF.PARAM_ID = CHECK_5_YEAR_PLUS_10.PARAM_ID
      AND JF.DATE_CONFIRM IS NOT NULL;

   AVALUE := AVALUE + AVALUE * 0.1;
   S := TO_CHAR (AVALUE);

   IF (VALUE > AVALUE)
   THEN
      SUCCESS := 0;
      INFO := '�������� �� �������. �������� > ' || S;
   ELSE
      SUCCESS := 1;
      INFO := '�������� �������. �������� <= ' || S;
   END IF;
END;

--

/* �������� ��������� */

COMMIT
