/* CREATE OR REPLACE VIEW S_FLT_CRITERION_VALUES_DR2 */

CREATE OR REPLACE VIEW S_FLT_CRITERION_VALUES_DR2
AS
SELECT   '�������������� ������. �������� 2�� ���� �������' PARAM_NAME,
         1.5 K1_1,
         6.5 K1_2,
         10 K2,
         '�������� 2�� ���� �������' POINT_NAME,
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
            WHEN (SUM (EXPENSE) >= 1.5)
            AND (SUM (EXPENSE) <= 6.5)
               THEN '��������������� ��������� �� ��������� �������� ������������ 1-�� ������ (K1)'
            ELSE CASE
            WHEN (SUM (EXPENSE) < 1.5)
             OR (    (SUM (EXPENSE) > 6.5)
                 AND (SUM (EXPENSE) < 10))
               THEN '������������, ������������ � �������������� ��������� ��� � ��� ���������, � ����� ���������� ����������� ������������ � �������������� ���������� ��� ������������� �������� �� ���������� ������������'
            ELSE CASE
            WHEN (SUM (EXPENSE) >= 10)
               THEN '������������ ��� � ��������� ������ ����������� ��� ������������ ���������� ����������� �� �������������� ���������� ������ ������������ � ��� ������������ ���������� ������ �������'
         END
         END
         END MESSAGE
    FROM S_FLT_JOURNAL_OBSERVATIONS_O6
GROUP BY CYCLE_NUM
ORDER BY CYCLE_NUM

--

/* �������� ��������� */

COMMIT


