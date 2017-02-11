/* �������� ��������� ��������� �������� �� ��������� ��� �-� �� ���������� ���������� �������� */

CREATE OR REPLACE PROCEDURE DEFAULT_SLF_VALUE_CA_MICROMETR (
   DATE_OBSERVATION DATE,
   POINT_ID INTEGER,
   VALUE_0 IN OUT FLOAT, /* �-� ������ */
   VALUE_1 IN OUT FLOAT, /* �-� �������������� */
   VALUE_2 IN OUT FLOAT, /* �-� ��������� */
   VALUE_3 IN OUT FLOAT, /* �-� ������ */
   VALUE_4 IN OUT FLOAT, /* �-� �������������� */
   VALUE_5 IN OUT FLOAT, /* �-� ��������� */
   VALUE_6 IN OUT FLOAT, /* �-� ������ */
   VALUE_7 IN OUT FLOAT, /* �-� �������������� */
   VALUE_8 IN OUT FLOAT, /* �-� ��������� */
   VALUE_9 IN OUT FLOAT, /* �-� ������ */
   VALUE_10 IN OUT FLOAT, /* �-� �������������� */
   VALUE_11 IN OUT FLOAT, /* �-� ��������� */
   VALUE_12 IN OUT FLOAT, /* �-� ������ */
   VALUE_13 IN OUT FLOAT, /* �-� �������������� */
   VALUE_14 IN OUT FLOAT, /* �-� ��������� */
   VALUE_15 IN OUT FLOAT, /* �-� ������ */
   VALUE_16 IN OUT FLOAT, /* �-� �������������� */
   VALUE_17 IN OUT FLOAT, /* �-� ��������� */
   VALUE_18 IN OUT FLOAT, /* �-� ��.��. */
   VALUE_19 IN OUT FLOAT, /* �-� ���.��. */
   VALUE_20 IN OUT FLOAT, /* �-� ��.��. */
   VALUE_21 IN OUT FLOAT, /* �-� ���.��. */
   VALUE_22 IN OUT FLOAT, /* �-� ��.��. */
   VALUE_23 IN OUT FLOAT, /* �-� ���.��. */
   VALUE_24 IN OUT FLOAT, /* ������� ���������� */
   VALUE_25 IN OUT FLOAT, /* ��������� � ������ ���������� �� X */
   VALUE_26 IN OUT FLOAT, /* ������� ��������� �� � */
   VALUE_27 IN OUT FLOAT, /* ��������� � ������ ���������� �� Y */
   VALUE_28 IN OUT FLOAT, /* ������� ��������� �� Y */
   VALUE_29 IN OUT FLOAT, /* ��������� � ������ ���������� �� Z */
   VALUE_30 IN OUT FLOAT /* ������� ��������� �� Z */
)
AS
BEGIN
   IF (VALUE_11 IS NULL)
   THEN
      VALUE_11 := 0.0;
   END IF;

   CALCULATE_SLF_VALUES (DATE_OBSERVATION,
                         POINT_ID,
                         VALUE_0,
                         VALUE_1,
                         VALUE_2,
                         VALUE_3,
                         VALUE_4,
                         VALUE_5,
                         VALUE_6,
                         VALUE_7,
                         VALUE_8,
                         VALUE_9,
                         VALUE_10,
                         VALUE_11,
                         VALUE_12,
                         VALUE_13,
                         VALUE_14,
                         VALUE_15,
                         VALUE_16,
                         VALUE_17,
                         VALUE_18,
                         VALUE_19,
                         VALUE_20,
                         VALUE_21,
                         VALUE_22,
                         VALUE_23,
                         VALUE_24,
                         VALUE_25,
                         VALUE_27,
                         VALUE_29,
                         VALUE_26,
                         VALUE_28,
                         VALUE_30
                        );
END;

--

/* �������� ��������� */

COMMIT
