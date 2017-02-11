/* �������� ��������� �������� �������� ��������� ��������� ��������� �� 5 ��� +10% */

CREATE OR REPLACE PROCEDURE CHECK_SL1_5_YEAR_PLUS_10 (
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
   OPENING FLOAT;
   CURRENT_OPENING FLOAT;
BEGIN
   AVALUE := VALUE;
   DEFAULT_SL1_VALUE (DATE_OBSERVATION, CYCLE_ID, POINT_ID, AVALUE, OPENING, CURRENT_OPENING);
   AMONTH := EXTRACT (MONTH FROM DATE_OBSERVATION);
   AYEAR := EXTRACT (YEAR FROM DATE_OBSERVATION);

   SELECT SUM (JF.VALUE) / COUNT (*)
     INTO AVALUE
     FROM JOURNAL_FIELDS JF
    WHERE EXTRACT (MONTH FROM JF.DATE_OBSERVATION) = AMONTH
      AND EXTRACT (YEAR FROM JF.DATE_OBSERVATION) >= (AYEAR - 5)
      AND JF.MEASURE_TYPE_ID = CHECK_SL1_5_YEAR_PLUS_10.MEASURE_TYPE_ID
      AND JF.POINT_ID = CHECK_SL1_5_YEAR_PLUS_10.POINT_ID
      AND JF.PARAM_ID = 30002   /* ��������� � ������ ���������� */
      AND JF.DATE_CONFIRM IS NOT NULL;

   AVALUE := AVALUE + AVALUE * 0.1;
   S := TO_CHAR (AVALUE);

   IF (OPENING > AVALUE)
   THEN
      SUCCESS := 0;
      INFO := '�������� �� �������. ���������=' || TO_CHAR (OPENING) || ' � > ' || S;
   ELSE
      SUCCESS := 1;
      INFO := '�������� �������. ���������=' || TO_CHAR (OPENING) || ' � <= ' || S;
   END IF;
END;

--

/* �������� ��������� */

COMMIT
