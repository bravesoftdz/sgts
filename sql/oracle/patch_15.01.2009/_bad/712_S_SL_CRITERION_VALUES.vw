/* CREATE OR REPLACE VIEW S_SL_CRITERION_VALUES */

CREATE OR REPLACE VIEW S_SL_CRITERION_VALUES
AS
   SELECT   '��������� ������������� ����' AS param_name, 3 AS k1, 3.5 AS k2,
               converter_name
            || ' '
            || object_paths
            || '\���. '
            || coordinate_z AS point_name,
            cycle_num, date_observation, opening AS VALUE,
            CASE
               WHEN opening < 3
                  THEN '��������������� ��������� �� ��������� �������� ������������ 1-�� ������ (K1)'
               ELSE CASE
               WHEN opening < 3.5
                  THEN '������������, ������������ � �������������� ��������� ��� � ��� ���������, � ����� ���������� ����������� ������������ � �������������� ���������� ��� ������������� �������� �� ���������� ������������'
               ELSE '������������ ��� � ��������� ������ ����������� ��� ������������ ���������� ����������� �� �������������� ���������� ������ ������������ � ��� ������������ ���������� ������ �������'
            END
            END MESSAGE
       FROM s_sl1_journal_observations_1
      WHERE opening IS NOT NULL
   UNION
   SELECT   '��������� ������������� ����' AS param_name, 3 AS k1, 3.5 AS k2,
               converter_name
            || ' '
            || object_paths
            || '\���. '
            || coordinate_z AS point_name,
            cycle_num, date_observation, opening_y AS VALUE,
            CASE
               WHEN opening_y < 3
                  THEN '��������������� ��������� �� ��������� �������� ������������ 1-�� ������ (K1)'
               ELSE CASE
               WHEN opening_y < 3.5
                  THEN '������������, ������������ � �������������� ��������� ��� � ��� ���������, � ����� ���������� ����������� ������������ � �������������� ���������� ��� ������������� �������� �� ���������� ������������'
               ELSE '������������ ��� � ��������� ������ ����������� ��� ������������ ���������� ����������� �� �������������� ���������� ������ ������������ � ��� ������������ ���������� ������ �������'
            END
            END MESSAGE
       FROM s_slw_journal_observations_1
      WHERE opening_y IS NOT NULL
   UNION
   SELECT   '��������� ������������� ����' AS param_name, 3 AS k1, 3.5 AS k2,
               converter_name
            || ' '
            || object_paths
            || '\���. '
            || coordinate_z AS point_name,
            cycle_num, date_observation, opening_y AS VALUE,
            CASE
               WHEN opening_y < 3
                  THEN '��������������� ��������� �� ��������� �������� ������������ 1-�� ������ (K1)'
               ELSE CASE
               WHEN opening_y < 3.5
                  THEN '������������, ������������ � �������������� ��������� ��� � ��� ���������, � ����� ���������� ����������� ������������ � �������������� ���������� ��� ������������� �������� �� ���������� ������������'
               ELSE '������������ ��� � ��������� ������ ����������� ��� ������������ ���������� ����������� �� �������������� ���������� ������ ������������ � ��� ������������ ���������� ������ �������'
            END
            END MESSAGE
       FROM s_slf_journal_observations_1
      WHERE opening_y IS NOT NULL
   ORDER BY date_observation

--

/* �������� ��������� */

COMMIT
