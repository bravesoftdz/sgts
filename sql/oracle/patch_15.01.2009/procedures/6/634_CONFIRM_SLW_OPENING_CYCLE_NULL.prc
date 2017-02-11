/* �������� ��������� ������� ��������� ��������� ��������� � �������� ����� */

CREATE OR REPLACE PROCEDURE CONFIRM_SLW_OPENING_CYCLE_NULL (
   JOURNAL_FIELD_ID IN INTEGER,
   ALGORITHM_ID IN INTEGER
)
AS
   JOURNAL_OBSERVATION_ID INTEGER;
   AMEASURE_TYPE_ID INTEGER;
   ACYCLE_ID INTEGER;
   AWHO_CONFIRM INTEGER;
   ADATE_CONFIRM DATE;
   AGROUP_ID VARCHAR2 (32);
   APRIORITY INTEGER;
   APOINT_ID INTEGER;
   APARAM_ID INTEGER;
   DPARAM_ID INTEGER;
   ADATE_OBSERVATION DATE;
   OPENING FLOAT;
   CYCLE_NULL_ID INTEGER;
   OPENING_CYCLE_NULL FLOAT;
BEGIN
   SELECT MEASURE_TYPE_ID,
          CYCLE_ID,
          WHO_CONFIRM,
          DATE_CONFIRM,
          GROUP_ID,
          PRIORITY,
          POINT_ID,
          DATE_OBSERVATION,
          VALUE,
          PARAM_ID
     INTO AMEASURE_TYPE_ID,
          ACYCLE_ID,
          AWHO_CONFIRM,
          ADATE_CONFIRM,
          AGROUP_ID,
          APRIORITY,
          APOINT_ID,
          ADATE_OBSERVATION,
          OPENING,
          APARAM_ID
     FROM JOURNAL_FIELDS
    WHERE JOURNAL_FIELD_ID = CONFIRM_SLW_OPENING_CYCLE_NULL.JOURNAL_FIELD_ID;

   IF (APARAM_ID IN (30010, 30011, 30012))   /* ��������� � ������ ���������� �� X, Y, Z */
   THEN
      IF (APARAM_ID = 30010)
      THEN
         DPARAM_ID := 30039;
      END IF;

      IF (APARAM_ID = 30011)
      THEN
         DPARAM_ID := 30040;
      END IF;

      IF (APARAM_ID = 30012)
      THEN
         DPARAM_ID := 30041;
      END IF;

      DELETE FROM JOURNAL_OBSERVATIONS
            WHERE JOURNAL_FIELD_ID = CONFIRM_SLW_OPENING_CYCLE_NULL.JOURNAL_FIELD_ID
              AND ALGORITHM_ID = CONFIRM_SLW_OPENING_CYCLE_NULL.ALGORITHM_ID
              AND MEASURE_TYPE_ID = AMEASURE_TYPE_ID
              AND CYCLE_ID = ACYCLE_ID
              AND DATE_OBSERVATION = ADATE_OBSERVATION
              AND GROUP_ID = AGROUP_ID
              AND POINT_ID = APOINT_ID
              AND PARAM_ID = DPARAM_ID;   /* ��������� � �������� ����� �� X, Y, Z*/

      COMMIT;

      IF (AWHO_CONFIRM IS NOT NULL)
      THEN
         CYCLE_NULL_ID := 3137;
         OPENING_CYCLE_NULL := 0.0;

         IF (ACYCLE_ID >= CYCLE_NULL_ID)
         THEN
            FOR INC IN (SELECT /*+ FIRST_ROWS (20) */
                               VALUE
                          FROM JOURNAL_FIELDS
                         WHERE MEASURE_TYPE_ID = AMEASURE_TYPE_ID
                           AND POINT_ID = APOINT_ID
                           AND PARAM_ID = APARAM_ID
                           AND CYCLE_ID = CYCLE_NULL_ID
                           AND IS_BASE = 1)
            LOOP
               OPENING_CYCLE_NULL := OPENING - INC.VALUE;
               EXIT WHEN OPENING_CYCLE_NULL IS NOT NULL;
            END LOOP;
         END IF;

         I_JOURNAL_OBSERVATION (GET_JOURNAL_OBSERVATION_ID,
                                JOURNAL_FIELD_ID,
                                NULL,
                                AMEASURE_TYPE_ID,
                                NULL,
                                ADATE_OBSERVATION,
                                ACYCLE_ID,
                                APOINT_ID,
                                DPARAM_ID,   /* ��������� � �������� ����� �� X, Y, Z*/
                                OPENING_CYCLE_NULL,
                                AWHO_CONFIRM,
                                ADATE_CONFIRM,
                                ALGORITHM_ID,
                                AGROUP_ID,
                                APRIORITY
                               );
      END IF;
   END IF;
END;

--

/* �������� */

COMMIT
