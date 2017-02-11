/* CREATE OR REPLACE VIEW S_OTV_CRITERION_VALUES_SEC_22 */

CREATE OR REPLACE VIEW S_OTV_CRITERION_VALUES_SEC_22
AS 
SELECT   '���������� �������������� ����������� ������ � ������� ��. ������� ������ � �������� ������� ������ �22' PARAM_NAME,
         38 K1,
         43 K2,
         '��-1 �������\���� �������\������ 22\����� 1\���. 247.84' POINT_NAME,
         JO.CYCLE_NUM,
         JO.DATE_OBSERVATION,
         JO.OFFSET_X_WITH_VERTIKAL VALUE,
         CASE
            WHEN JO.OFFSET_X_WITH_VERTIKAL < 38
               THEN '��������������� ��������� �� ��������� �������� ������������ 1-�� ������ (K1)'
            ELSE CASE
            WHEN JO.OFFSET_X_WITH_VERTIKAL < 43
               THEN '������������, ������������ � �������������� ��������� ��� � ��� ���������, � ����� ���������� ����������� ������������ � �������������� ���������� ��� ������������� �������� �� ���������� ������������'
            ELSE '������������ ��� � ��������� ������ ����������� ��� ������������ ���������� ����������� �� �������������� ���������� ������ ������������ � ��� ������������ ���������� ������ �������'
         END
         END MESSAGE
    FROM S_OTV_JOURNAL_OBSERVATIONS_O1 JO
   WHERE JO.POINT_ID = 6288
     AND JO.OFFSET_X_WITH_VERTIKAL IS NOT NULL
ORDER BY JO.DATE_OBSERVATION

--

/* �������� ��������� */

COMMIT


