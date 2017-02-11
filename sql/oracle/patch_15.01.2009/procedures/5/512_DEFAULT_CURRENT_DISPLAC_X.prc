/* �������� ��������� ��������� �������� �������� �������� � �� ��������� */

CREATE OR REPLACE PROCEDURE DEFAULT_CURRENT_DISPLAC_X (
   DATE_OBSERVATION IN DATE,
   POINT_ID IN INTEGER,
   VALUE_2 IN FLOAT,
   VALUE_4 IN OUT FLOAT
)
AS
   JF_ID_PRED INTEGER;
   P_ID INTEGER;
   D_O DATE;
   D_O_PR DATE;
   D DATE;
   ITER INTEGER;
   JF_ID_PREDD INTEGER;
   JF_ID INTEGER;
   SMI FLOAT;
   SMI_1 FLOAT;
   DISPLACEMENT FLOAT;
   FLAG BOOLEAN;
BEGIN
   JF_ID_PRED := NULL;
   P_ID := POINT_ID;
   D_O := DATE_OBSERVATION;

   SELECT MAX (DATE_OBSERVATION)
     INTO D
     FROM JOURNAL_FIELDS
    WHERE PARAM_ID = 17161
      AND POINT_ID = P_ID;

   IF D > D_O
   THEN
      ITER := 1;
      FLAG := FALSE;

      FOR INC IN (SELECT   JOURNAL_FIELD_ID,
                           DATE_OBSERVATION
                      FROM JOURNAL_FIELDS
                     WHERE PARAM_ID = 17161
                       AND POINT_ID = P_ID
                  ORDER BY DATE_OBSERVATION)
      LOOP
         IF ITER = 1
         THEN
            JF_ID_PREDD := NULL;
            JF_ID := INC.JOURNAL_FIELD_ID;
         END IF;

         IF ITER <> 1
         THEN
            JF_ID_PREDD := JF_ID;
            JF_ID := INC.JOURNAL_FIELD_ID;
         END IF;

         ITER := ITER + 1;

         IF     (INC.DATE_OBSERVATION > D_O)
            AND (FLAG = FALSE)
         THEN
            JF_ID_PRED := JF_ID_PREDD;
            FLAG := TRUE;
         END IF;
      END LOOP;
   END IF;

   IF D < D_O
   THEN
      SELECT JOURNAL_FIELD_ID
        INTO JF_ID_PRED
        FROM JOURNAL_FIELDS
       WHERE PARAM_ID = 17161
         AND POINT_ID = P_ID
         AND DATE_OBSERVATION = D;
   END IF;

   SMI := VALUE_2;

   IF (JF_ID_PRED IS NOT NULL)
   THEN
      SELECT VALUE
        INTO SMI_1
        FROM JOURNAL_FIELDS
       WHERE JOURNAL_FIELD_ID = JF_ID_PRED;

      DISPLACEMENT := SMI - SMI_1;
   END IF;

   IF (JF_ID_PRED IS NULL)
   THEN
      DISPLACEMENT := 0;
   END IF;

   /* ��������� */
   VALUE_4 := DISPLACEMENT;
END;

--

/* �������� ��������� */

COMMIT
