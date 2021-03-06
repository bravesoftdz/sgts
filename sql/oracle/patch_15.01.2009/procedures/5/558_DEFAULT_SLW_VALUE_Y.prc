/* �������� ��������� ��������� �������� �� ��������� ��� ������� �� Y ���������� �������� */

CREATE OR REPLACE PROCEDURE DEFAULT_SLW_VALUE_Y (
   DATE_OBSERVATION DATE,
   CYCLE_ID INTEGER,
   POINT_ID INTEGER,
   VALUE_3 IN OUT FLOAT,
   VALUE_4 IN OUT FLOAT,
   VALUE_5 IN OUT FLOAT
)
AS
   BASE_COUNTING_OUT_Y FLOAT;
   BASE_OPENING_Y FLOAT;
   COUNTING_OUT_Y FLOAT;
   OPENING_Y FLOAT;
   OPENING_LAST_Y FLOAT;
   ACYCLE_ID INTEGER;
   APOINT_ID INTEGER;
   ADATE DATE;
BEGIN
   IF (VALUE_3 IS NULL)
   THEN
      VALUE_3 := 0.0;
   END IF;

   COUNTING_OUT_Y := VALUE_3;
   APOINT_ID := POINT_ID;
   BASE_COUNTING_OUT_Y := 0.0;

   FOR INC IN (SELECT   CP.VALUE,
                        CP.DATE_BEGIN,
                        CP.DATE_END
                   FROM CONVERTER_PASSPORTS CP,
                        COMPONENTS C
                  WHERE CP.COMPONENT_ID = C.COMPONENT_ID
                    AND C.CONVERTER_ID = APOINT_ID
                    AND C.PARAM_ID = 30008 /* ������ �� Y */
               ORDER BY CP.DATE_BEGIN)
   LOOP
      BASE_COUNTING_OUT_Y := TO_NUMBER (REPLACE (INC.VALUE, ',', '.'), 'FM99999.9999');
      EXIT WHEN (DATE_OBSERVATION >= INC.DATE_BEGIN)
           AND (DATE_OBSERVATION < INC.DATE_END);
   END LOOP;

   BASE_OPENING_Y := 0.0;

   FOR INC IN (SELECT   CP.VALUE,
                        CP.DATE_BEGIN,
                        CP.DATE_END
                   FROM CONVERTER_PASSPORTS CP,
                        COMPONENTS C
                  WHERE CP.COMPONENT_ID = C.COMPONENT_ID
                    AND C.CONVERTER_ID = APOINT_ID
                    AND C.PARAM_ID = 30011 /* ��������� � ������ ���������� �� Y */
               ORDER BY CP.DATE_BEGIN)
   LOOP
      BASE_OPENING_Y := TO_NUMBER (REPLACE (INC.VALUE, ',', '.'), 'FM99999.9999');
      EXIT WHEN (DATE_OBSERVATION >= INC.DATE_BEGIN)
           AND (DATE_OBSERVATION < INC.DATE_END);
   END LOOP;

   OPENING_Y := COUNTING_OUT_Y - BASE_COUNTING_OUT_Y + BASE_OPENING_Y;
   ADATE := DATE_OBSERVATION;
   OPENING_LAST_Y := 0.0;

   FOR INC IN (SELECT   J.VALUE
                   FROM JOURNAL_FIELDS J,
                        CYCLES C
                  WHERE J.CYCLE_ID = C.CYCLE_ID
                    AND J.POINT_ID = APOINT_ID
                    AND J.PARAM_ID = 30011 /* ��������� � ������ ���������� �� Y */
                    AND J.DATE_OBSERVATION < ADATE
               ORDER BY J.DATE_OBSERVATION DESC)
   LOOP
      OPENING_LAST_Y := INC.VALUE;
      EXIT WHEN OPENING_LAST_Y IS NOT NULL;
   END LOOP;

   VALUE_4 := OPENING_Y;
   VALUE_5 := OPENING_Y - OPENING_LAST_Y;
END;

--

/* �������� ��������� */

COMMIT
