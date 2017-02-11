/* CREATE OR REPLACE VIEW S_FLT_CRITERION_VALUES_DR1 */

CREATE OR REPLACE VIEW S_FLT_CRITERION_VALUES_DR1
AS
SELECT   '�������������� ������. �������� 1�� ���� �������' PARAM_NAME,
         4 K1_1,
         12 K1_2,
         15 K2,
         '�������� 1�� ���� �������' POINT_NAME,
         CYCLE_NUM,
         CASE
            WHEN LENGTH (TO_CHAR (MOD (CYCLE_NUM, 12))) = 1
               THEN CASE
                      WHEN TO_CHAR (MOD (CYCLE_NUM, 12)) = '0'
                         THEN TO_DATE ('01.12.' || TO_CHAR (FLOOR (CYCLE_NUM / 12) + 1961), 'DD.MM.YYYY')
                      ELSE TO_DATE ('01.0' || TO_CHAR (MOD (CYCLE_NUM, 12)) || '.' || TO_CHAR (FLOOR (CYCLE_NUM / 12) + 1962), 'DD.MM.YYYY')
                   END
            ELSE TO_DATE ('01.' || TO_CHAR (MOD (CYCLE_NUM, 12)) || '.' || TO_CHAR (FLOOR (CYCLE_NUM / 12) + 1962), 'DD.MM.YYYY')
         END DATE_OBSERVATION,
         SUM (EXPENSE) VALUE,
         CASE
            WHEN (SUM (EXPENSE) >= 4)
            AND (SUM (EXPENSE) <= 12)
               THEN '��������������� ��������� �� ��������� �������� ������������ 1-�� ������ (K1)'
            ELSE CASE
            WHEN (SUM (EXPENSE) < 4)
             OR (    (SUM (EXPENSE) > 12)
                 AND (SUM (EXPENSE) < 15))
               THEN '������������, ������������ � �������������� ��������� ��� � ��� ���������, � ����� ���������� ����������� ������������ � �������������� ���������� ��� ������������� �������� �� ���������� ������������'
            ELSE CASE
            WHEN (SUM (EXPENSE) >= 15)
               THEN '������������ ��� � ��������� ������ ����������� ��� ������������ ���������� ����������� �� �������������� ���������� ������ ������������ � ��� ������������ ���������� ������ �������'
         END
         END
         END MESSAGE
    FROM S_FLT_JOURNAL_OBSERVATIONS_O3
GROUP BY CYCLE_NUM
ORDER BY CYCLE_NUM

--

/* �������� ��������� */

COMMIT


