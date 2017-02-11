/* �������� ��������� ������� �������� ����� � ������ ���������� */

CREATE OR REPLACE PROCEDURE CONFIRM_DISPLAC_BEGIN_MARK (
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
   F_OT FLOAT;
   L_OT FLOAT;
   M_OT FLOAT;
   M_OT_INT INTEGER;
   M_OT_STR VARCHAR2 (100);
   LAST_SYMB VARCHAR2 (1);
   ST VARCHAR2 (100);
   S_J_NULL FLOAT;
   O_SR_J_NULL FLOAT;
   Z_NULL FLOAT;
   Z_I FLOAT;
   S_L_I FLOAT;
   S_L_NULL FLOAT;
   S_P_I FLOAT;
   S_P_NULL FLOAT;
   K_J FLOAT;
   COMP_ID INTEGER;
   P_N VARCHAR2 (100);
   S_J_NULL_S VARCHAR2 (100);
   O_SR_J_NULL_S VARCHAR2 (100);
   Z_NULL_S VARCHAR2 (100);
   K_J_S VARCHAR2 (100);
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
    WHERE JOURNAL_FIELD_ID = CONFIRM_DISPLAC_BEGIN_MARK.JOURNAL_FIELD_ID;

   IF APARAM_ID = 15122 /* ������ (��� �������) */
   THEN
      DELETE FROM JOURNAL_OBSERVATIONS
            WHERE JOURNAL_FIELD_ID = CONFIRM_DISPLAC_BEGIN_MARK.JOURNAL_FIELD_ID
              AND ALGORITHM_ID = CONFIRM_DISPLAC_BEGIN_MARK.ALGORITHM_ID
              AND MEASURE_TYPE_ID = AMEASURE_TYPE_ID
              AND CYCLE_ID = ACYCLE_ID
              AND DATE_OBSERVATION = ADATE_OBSERVATION
              AND GROUP_ID = AGROUP_ID
              AND POINT_ID = APOINT_ID
              AND PARAM_ID = 17181;

      /* �������� ����� � ������ ���������� */
      COMMIT;

      IF (AWHO_CONFIRM IS NOT NULL)
      THEN /* ��������� */                         /* ������� �������� �������(��� �����), �������(��� �������) � ����� ���� */
         SELECT VALUE
           INTO L_OT
           FROM JOURNAL_OBSERVATIONS
          WHERE JOURNAL_FIELD_ID = CONFIRM_DISPLAC_BEGIN_MARK.JOURNAL_FIELD_ID
            AND PARAM_ID = 15122;

         SELECT VALUE
           INTO F_OT
           FROM JOURNAL_OBSERVATIONS
          WHERE CYCLE_ID = ACYCLE_ID
            AND POINT_ID = APOINT_ID
            AND PARAM_ID = 15121;

         Z_I := 0;

         FOR INC IN (SELECT VALUE
                       FROM JOURNAL_OBSERVATIONS
                      WHERE CYCLE_ID = ACYCLE_ID
                        AND POINT_ID = APOINT_ID
                        AND PARAM_ID = 15120)
         LOOP
            Z_I := INC.VALUE;
         END LOOP;

         /* ������� �������� �������� ������� */
         M_OT := (F_OT + L_OT) / 2;
         M_OT := M_OT * 100;
         M_OT_INT := M_OT - MOD (M_OT, 1);
         M_OT_STR := TO_NCHAR (M_OT_INT);

         SELECT SUBSTR (M_OT_STR, LENGTH (M_OT_STR), 1)
           INTO LAST_SYMB
           FROM DUAL;

         IF LAST_SYMB = '0'
         THEN
            M_OT := M_OT_INT / 100;
         END IF;

         IF    LAST_SYMB = '1'
            OR LAST_SYMB = '2'
            OR LAST_SYMB = '3'
            OR LAST_SYMB = '4'
         THEN
            SELECT SUBSTR (M_OT_STR, 1, LENGTH (M_OT_STR) - 1)
              INTO ST
              FROM DUAL;

            ST := ST || '2';
            M_OT_INT := TO_NUMBER (ST);
            M_OT := M_OT_INT / 100;
         END IF;

         IF LAST_SYMB = '5'
         THEN
            M_OT := M_OT_INT / 100;
         END IF;

         IF    LAST_SYMB = '6'
            OR LAST_SYMB = '7'
            OR LAST_SYMB = '8'
            OR LAST_SYMB = '9'
         THEN
            SELECT SUBSTR (M_OT_STR, 1, LENGTH (M_OT_STR) - 1)
              INTO ST
              FROM DUAL;

            ST := ST || '8';
            M_OT_INT := TO_NUMBER (ST);
            M_OT := M_OT_INT / 100;
         END IF;

         /* ������� Sj0 */
         SELECT COMPONENT_ID
           INTO COMP_ID
           FROM COMPONENTS
          WHERE CONVERTER_ID = APOINT_ID
            AND PARAM_ID = 14109;

         SELECT VALUE
           INTO S_J_NULL_S
           FROM CONVERTER_PASSPORTS
          WHERE COMPONENT_ID = COMP_ID;

         SELECT REPLACE (S_J_NULL_S, ',', '.')
           INTO S_J_NULL_S
           FROM DUAL;

         S_J_NULL := TO_NUMBER (S_J_NULL_S);

         /* ������� O��j0 */
         SELECT COMPONENT_ID
           INTO COMP_ID
           FROM COMPONENTS
          WHERE CONVERTER_ID = APOINT_ID
            AND PARAM_ID = 14110;

         SELECT VALUE
           INTO O_SR_J_NULL_S
           FROM CONVERTER_PASSPORTS
          WHERE COMPONENT_ID = COMP_ID;

         SELECT REPLACE (O_SR_J_NULL_S, ',', '.')
           INTO O_SR_J_NULL_S
           FROM DUAL;

         O_SR_J_NULL := TO_NUMBER (O_SR_J_NULL_S);

         /* ������� Z0 */
         SELECT COMPONENT_ID
           INTO COMP_ID
           FROM COMPONENTS
          WHERE CONVERTER_ID = APOINT_ID
            AND PARAM_ID = 14108;

         SELECT VALUE
           INTO Z_NULL_S
           FROM CONVERTER_PASSPORTS
          WHERE COMPONENT_ID = COMP_ID;

         SELECT REPLACE (Z_NULL_S, ',', '.')
           INTO Z_NULL_S
           FROM DUAL;

         Z_NULL := TO_NUMBER (Z_NULL_S);
         /* ������� Sli */
         S_L_I := GET_VALUE_NEAR_DATE (6294, 17161, ADATE_OBSERVATION);
         /* ������� Sl0 */
         S_L_NULL := 0;

         FOR INCC IN (SELECT VALUE
                        FROM JOURNAL_OBSERVATIONS
                       WHERE POINT_ID = 6294
                         AND PARAM_ID = 17161
                         AND CYCLE_ID = 3136)
         LOOP
            S_L_NULL := INCC.VALUE;
         END LOOP;

         /* ������� Spi */
         S_P_I := GET_VALUE_NEAR_DATE (6303, 17161, ADATE_OBSERVATION);
         /* ������� Sp0 */
         S_P_NULL := 0;

         FOR INCC IN (SELECT VALUE
                        FROM JOURNAL_OBSERVATIONS
                       WHERE POINT_ID = 6303
                         AND PARAM_ID = 17161
                         AND CYCLE_ID = 3136)
         LOOP
            S_P_NULL := INCC.VALUE;
         END LOOP;

         /* ������� Kj */
         SELECT COMPONENT_ID
           INTO COMP_ID
           FROM COMPONENTS
          WHERE CONVERTER_ID = APOINT_ID
            AND PARAM_ID = 14104;

         SELECT VALUE
           INTO K_J_S
           FROM CONVERTER_PASSPORTS
          WHERE COMPONENT_ID = COMP_ID;

         SELECT REPLACE (K_J_S, ',', '.')
           INTO K_J_S
           FROM DUAL;

         K_J := TO_NUMBER (K_J_S);
         /* ������� �������� */
         DISPLACEMENT := S_J_NULL + (M_OT - O_SR_J_NULL) + (Z_NULL - Z_I) + (S_L_I - S_L_NULL) + K_J * ((S_P_I - S_P_NULL) - (S_L_I - S_L_NULL)) / 54;
         DISPLACEMENT := ROUND (DISPLACEMENT * 100) / 100;
         I_JOURNAL_OBSERVATION (GET_JOURNAL_OBSERVATION_ID,
                                JOURNAL_FIELD_ID,
                                NULL,
                                AMEASURE_TYPE_ID,
                                13690,
                                ADATE_OBSERVATION,
                                ACYCLE_ID,
                                APOINT_ID,
                                17181, /* �������� ����� � ������ ���������� */
                                DISPLACEMENT,
                                AWHO_CONFIRM,
                                ADATE_CONFIRM,
                                ALGORITHM_ID,
                                AGROUP_ID,
                                APRIORITY
                               );
      END IF; /* ��������� */
   END IF;
END;

--

/* �������� */

COMMIT