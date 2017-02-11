/* CREATE OR REPLACE VIEW S_PZM_CRITERION_VALUES_4_2 */

CREATE OR REPLACE VIEW S_PZM_CRITERION_VALUES_4_2
AS
   SELECT   '���������������� �����. �������� ����������. ������ �8, �10, �52' PARAM_NAME,
            0.32 K1,
            0.4 K2,
            JO.CONVERTER_NAME || ' ' || JO.OBJECT_PATHS || '\���. ' || JO.COORDINATE_Z POINT_NAME,
            JO.CYCLE_NUM,
            JO.DATE_OBSERVATION,
            JO.PRESSURE_BROUGHT VALUE,
            CASE
               WHEN JO.PRESSURE_BROUGHT < 0.32
                  THEN '��������������� ��������� �� ��������� �������� ������������ 1-�� ������ (K1)'
               ELSE CASE
               WHEN JO.PRESSURE_BROUGHT < 0.4
                  THEN '������������, ������������ � �������������� ��������� ��� � ��� ���������, � ����� ���������� ����������� ������������ � �������������� ���������� ��� ������������� �������� �� ���������� ������������'
               ELSE '������������ ��� � ��������� ������ ����������� ��� ������������ ���������� ����������� �� �������������� ���������� ������ ������������ � ��� ������������ ���������� ������ �������'
            END
            END MESSAGE
       FROM S_PZM_JOURNAL_OBSERVATIONS_O2 JO
      WHERE (   (    JO.POINT_ID >= 2736
                 AND JO.POINT_ID <= 2741)
             OR (    JO.POINT_ID >= 2803
                 AND JO.POINT_ID <= 2806))
        AND JO.PRESSURE_BROUGHT IS NOT NULL
   ORDER BY JO.DATE_OBSERVATION

--

/* �������� ��������� */

COMMIT



