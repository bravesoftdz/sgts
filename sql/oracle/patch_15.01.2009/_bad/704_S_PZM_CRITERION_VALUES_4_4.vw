/* CREATE OR REPLACE VIEW S_PZM_CRITERION_VALUES_4_4 */

CREATE OR REPLACE VIEW S_PZM_CRITERION_VALUES_4_4
AS 
SELECT   '���������������� �����. �������� ����������. ������ �-�6, �60-�70' PARAM_NAME,
         0.98 K1,
         1.0 K2,
         JO.CONVERTER_NAME || ' ' || JO.OBJECT_PATHS || '\���. ' || JO.COORDINATE_Z POINT_NAME,
         JO.CYCLE_NUM,
         JO.DATE_OBSERVATION,
         JO.PRESSURE_BROUGHT VALUE,
         CASE
            WHEN JO.PRESSURE_BROUGHT < 0.98
               THEN '��������������� ��������� �� ��������� �������� ������������ 1-�� ������ (K1)'
            ELSE CASE
            WHEN JO.PRESSURE_BROUGHT < 1.0
               THEN '������������, ������������ � �������������� ��������� ��� � ��� ���������, � ����� ���������� ����������� ������������ � �������������� ���������� ��� ������������� �������� �� ���������� ������������'
            ELSE '������������ ��� � ��������� ������ ����������� ��� ������������ ���������� ����������� �� �������������� ���������� ������ ������������ � ��� ������������ ���������� ������ �������'
         END
         END MESSAGE
    FROM S_PZM_JOURNAL_OBSERVATIONS_O2 JO
   WHERE (   (    JO.POINT_ID >= 2719
              AND JO.POINT_ID <= 2723)
          OR (    JO.POINT_ID >= 2724
              AND JO.POINT_ID <= 2735)
          OR (    JO.POINT_ID >= 2813
              AND JO.POINT_ID <= 2825)
         )
     AND JO.PRESSURE_BROUGHT IS NOT NULL
ORDER BY JO.DATE_OBSERVATION

--

/* �������� ��������� */

COMMIT


