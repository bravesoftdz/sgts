/* �������� ��������� ������� �������� �������� ����� */

CREATE OR REPLACE PROCEDURE CONFIRM_CURRENT_DISPLAC_MARK (
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
   ADATE_OBSERVATION DATE;
   APARAM_ID INTEGER;
   DISPLACEMENT FLOAT;
   SM_I FLOAT;
   SM_I_1 FLOAT;
   JO INTEGER;
   FLAG BOOLEAN;
   C_ID INTEGER;
BEGIN
   SELECT MEASURE_TYPE_ID,
          CYCLE_ID,
          WHO_CONFIRM,
          DATE_CONFIRM,
          GROUP_ID,
          PRIORITY,
          POINT_ID,
          DATE_OBSERVATION,
          PARAM_ID
     INTO AMEASURE_TYPE_ID,
          ACYCLE_ID,
          AWHO_CONFIRM,
          ADATE_CONFIRM,
          AGROUP_ID,
          APRIORITY,
          APOINT_ID,
          ADATE_OBSERVATION,
          APARAM_ID
     FROM JOURNAL_FIELDS
    WHERE JOURNAL_FIELD_ID = CONFIRM_CURRENT_DISPLAC_MARK.JOURNAL_FIELD_ID;

   IF APARAM_ID = 15122 /* ������ (��� �������) */
   THEN
      DELETE FROM JOURNAL_OBSERVATIONS
            WHERE JOURNAL_FIELD_ID = CONFIRM_CURRENT_DISPLAC_MARK.JOURNAL_FIELD_ID
              AND ALGORITHM_ID = CONFIRM_CURRENT_DISPLAC_MARK.ALGORITHM_ID
              AND MEASURE_TYPE_ID = AMEASURE_TYPE_ID
              AND CYCLE_ID = ACYCLE_ID
              AND DATE_OBSERVATION = ADATE_OBSERVATION
              AND GROUP_ID = AGROUP_ID
              AND POINT_ID = APOINT_ID
              AND PARAM_ID = 17182;

      /* ������� �������� ����� */
      COMMIT;

      IF (AWHO_CONFIRM IS NOT NULL)
      THEN /* ��������� */
         SELECT VALUE
           INTO SM_I
           FROM JOURNAL_OBSERVATIONS
          WHERE JOURNAL_FIELD_ID = CONFIRM_CURRENT_DISPLAC_MARK.JOURNAL_FIELD_ID
            AND PARAM_ID = 17181;

         SELECT JOURNAL_OBSERVATION_ID
           INTO JO
           FROM JOURNAL_OBSERVATIONS
          WHERE JOURNAL_FIELD_ID = CONFIRM_CURRENT_DISPLAC_MARK.JOURNAL_FIELD_ID
            AND PARAM_ID = 17181;

         FLAG := FALSE;
         C_ID := 0;

         FOR INC IN (SELECT   *
                         FROM JOURNAL_OBSERVATIONS
                        WHERE POINT_ID = APOINT_ID
                          AND PARAM_ID = 17181
                     ORDER BY CYCLE_ID DESC)
         LOOP
            IF INC.JOURNAL_OBSERVATION_ID = JO
            THEN
               FLAG := TRUE;
            ELSE
               IF FLAG = TRUE
               THEN
                  C_ID := INC.CYCLE_ID;
                  FLAG := FALSE;
               END IF;
            END IF;
         END LOOP;

         SM_I_1 := NULL;

         FOR INC IN (SELECT VALUE
                       INTO SM_I_1
                       FROM JOURNAL_OBSERVATIONS
                      WHERE CYCLE_ID = C_ID
                        AND POINT_ID = APOINT_ID
                        AND PARAM_ID = 17181)
         LOOP
            SM_I_1 := INC.VALUE;
         END LOOP;

         IF SM_I_1 IS NULL
         THEN
            DISPLACEMENT := 0;
         END IF;

         IF SM_I_1 IS NOT NULL
         THEN
            DISPLACEMENT := SM_I - SM_I_1;
         END IF;

         I_JOURNAL_OBSERVATION (GET_JOURNAL_OBSERVATION_ID,
                                JOURNAL_FIELD_ID,
                                NULL,
                                AMEASURE_TYPE_ID,
                                13690,
                                ADATE_OBSERVATION,
                                ACYCLE_ID,
                                APOINT_ID,
                                17182, /* ������� �������� ����� */
                                DISPLACEMENT,
                                AWHO_CONFIRM,
                                ADATE_CONFIRM,
                                ALGORITHM_ID,
                                AGROUP_ID,
                                APRIORITY
                               );
      END IF;
   /* ��������� */
   END IF;
END;

--

/* �������� */

COMMIT
