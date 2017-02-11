/* CREATE OR REPLACE VIEW S_OTV_CRITERION_VALUES_SEC_37 */

CREATE OR REPLACE VIEW S_OTV_CRITERION_VALUES_SEC_37
AS 
SELECT   '���������� �������������� ����������� ������ � ������� ��. ������� ������ � �������� ������� ������ �37' PARAM_NAME,
         45 K1,
         49 K2,
         '��-2 �������\���� �������\������ 37\����� 1\���. 248.00' POINT_NAME,
         JO.CYCLE_NUM,
         JO.DATE_OBSERVATION,
         JO.OFFSET_X_WITH_VERTIKAL VALUE,
         CASE
            WHEN JO.OFFSET_X_WITH_VERTIKAL < 45
               THEN '��������������� ��������� �� ��������� �������� ������������ 1-�� ������ (K1)'
            ELSE CASE
            WHEN JO.OFFSET_X_WITH_VERTIKAL < 49
               THEN '������������, ������������ � �������������� ��������� ��� � ��� ���������, � ����� ���������� ����������� ������������ � �������������� ���������� ��� ������������� �������� �� ���������� ������������'
            ELSE '������������ ��� � ��������� ������ ����������� ��� ������������ ���������� ����������� �� �������������� ���������� ������ ������������ � ��� ������������ ���������� ������ �������'
         END
         END MESSAGE
    FROM S_OTV_JOURNAL_OBSERVATIONS_O1 JO
   WHERE JO.POINT_ID = 6292
     AND JO.OFFSET_X_WITH_VERTIKAL IS NOT NULL
ORDER BY JO.DATE_OBSERVATION

--

/* �������� ��������� */

COMMIT


