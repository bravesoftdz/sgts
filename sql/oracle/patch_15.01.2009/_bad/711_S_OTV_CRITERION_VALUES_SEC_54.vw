/* CREATE OR REPLACE VIEW S_OTV_CRITERION_VALUES_SEC_54 */

CREATE OR REPLACE VIEW S_OTV_CRITERION_VALUES_SEC_54
AS 
SELECT   '���������� �������������� ����������� ������ � ������� ��. ������� ������ � �������� ������� ������ �54' PARAM_NAME,
         40 K1,
         44 K2,
         '��-3 �������\���� �������\������ 54\����� 2\���. 248.00' POINT_NAME,
         JO.CYCLE_NUM,
         JO.DATE_OBSERVATION,
         JO.OFFSET_X_WITH_VERTIKAL VALUE,
         CASE
            WHEN JO.OFFSET_X_WITH_VERTIKAL < 40
               THEN '��������������� ��������� �� ��������� �������� ������������ 1-�� ������ (K1)'
            ELSE CASE
            WHEN JO.OFFSET_X_WITH_VERTIKAL < 44
               THEN '������������, ������������ � �������������� ��������� ��� � ��� ���������, � ����� ���������� ����������� ������������ � �������������� ���������� ��� ������������� �������� �� ���������� ������������'
            ELSE '������������ ��� � ��������� ������ ����������� ��� ������������ ���������� ����������� �� �������������� ���������� ������ ������������ � ��� ������������ ���������� ������ �������'
         END
         END MESSAGE
    FROM S_OTV_JOURNAL_OBSERVATIONS_O1 JO
   WHERE JO.POINT_ID = 6289
     AND JO.OFFSET_X_WITH_VERTIKAL IS NOT NULL
ORDER BY JO.DATE_OBSERVATION

--

/* �������� ��������� */

COMMIT


