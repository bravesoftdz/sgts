/* �������� ��������� ������� �������� ����� � ����� ��������� �� ������� */

CREATE OR REPLACE PROCEDURE CONFIRM_DISPLAC_CYC_NULL_MARK (
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
   SM_DANN FLOAT;
   SM_NULL FLOAT;
   CYCLE_NULL_ID INTEGER;
   CYCLE_ZAP INTEGER;
BEGIN
   CYCLE_NULL_ID := 3137;

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
    WHERE JOURNAL_FIELD_ID = CONFIRM_DISPLAC_CYC_NULL_MARK.JOURNAL_FIELD_ID;

   IF APARAM_ID = 15122 /* ������ (��� �������) */
   THEN
      DELETE FROM JOURNAL_OBSERVATIONS
            WHERE JOURNAL_FIELD_ID = CONFIRM_DISPLAC_CYC_NULL_MARK.JOURNAL_FIELD_ID
              AND ALGORITHM_ID = CONFIRM_DISPLAC_CYC_NULL_MARK.ALGORITHM_ID
              AND MEASURE_TYPE_ID = AMEASURE_TYPE_ID
              AND CYCLE_ID = ACYCLE_ID
              AND DATE_OBSERVATION = ADATE_OBSERVATION
              AND GROUP_ID = AGROUP_ID
              AND POINT_ID = APOINT_ID
              AND (PARAM_ID = 17240);

      /* �������� � ����� ��������� �� �������*/
      COMMIT;

      IF (AWHO_CONFIRM IS NOT NULL)
      THEN /* ��������� */
         SELECT CYCLE_NUM
           INTO CYCLE_ZAP
           FROM CYCLES
          WHERE CYCLE_ID = ACYCLE_ID;

         IF (CYCLE_ZAP > 136)
         THEN
            SELECT VALUE
              INTO SM_DANN
              FROM JOURNAL_OBSERVATIONS
             WHERE JOURNAL_FIELD_ID = CONFIRM_DISPLAC_CYC_NULL_MARK.JOURNAL_FIELD_ID
               AND PARAM_ID = 17181;

            FOR INC IN (SELECT VALUE
                          FROM JOURNAL_OBSERVATIONS
                         WHERE POINT_ID = APOINT_ID
                           AND CYCLE_ID = CYCLE_NULL_ID
                           AND PARAM_ID = 17181)
            LOOP
               SM_NULL := INC.VALUE;
            END LOOP;

            IF SM_NULL IS NULL
            THEN
               DISPLACEMENT := 0;
            END IF;

            IF SM_NULL IS NOT NULL
            THEN
               DISPLACEMENT := SM_DANN - SM_NULL;
            END IF;
         END IF;

         IF (CYCLE_ZAP <= 136)
         THEN
            DISPLACEMENT := 0;
         END IF;

         /* ��������� */
         I_JOURNAL_OBSERVATION (GET_JOURNAL_OBSERVATION_ID,
                                JOURNAL_FIELD_ID,
                                NULL,
                                AMEASURE_TYPE_ID,
                                13690,
                                ADATE_OBSERVATION,
                                ACYCLE_ID,
                                APOINT_ID,
                                17240,
                                DISPLACEMENT,
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
