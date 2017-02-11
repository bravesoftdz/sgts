/* CREATE OR REPLACE VIEW S_PZM_CRITERION_VALUES_4_1 */

CREATE OR REPLACE VIEW S_PZM_CRITERION_VALUES_4_1
AS
   SELECT   '���������������� �����. �������� ����������. �������� ������' PARAM_NAME,
            0.2 K1,
            0.25 K2,
            JO.CONVERTER_NAME || ' ' || JO.OBJECT_PATHS || '\���. ' || JO.COORDINATE_Z POINT_NAME,
            JO.CYCLE_NUM,
            JO.DATE_OBSERVATION,
            JO.PRESSURE_BROUGHT VALUE,
            CASE
               WHEN JO.PRESSURE_BROUGHT < 0.2
                  THEN '��������������� ��������� �� ��������� �������� ������������ 1-�� ������ (K1)'
               ELSE CASE
               WHEN JO.PRESSURE_BROUGHT < 0.25
                  THEN '������������, ������������ � �������������� ��������� ��� � ��� ���������, � ����� ���������� ����������� ������������ � �������������� ���������� ��� ������������� �������� �� ���������� ������������'
               ELSE '������������ ��� � ��������� ������ ����������� ��� ������������ ���������� ����������� �� �������������� ���������� ������ ������������ � ��� ������������ ���������� ������ �������'
            END
            END MESSAGE
       FROM S_PZM_JOURNAL_OBSERVATIONS_O2 JO
      WHERE (   (    JO.POINT_ID >= 2742
                 AND JO.POINT_ID <= 2770)
             OR (    JO.POINT_ID >= 2775
                 AND JO.POINT_ID <= 2802)
             OR (    JO.POINT_ID >= 2807
                 AND JO.POINT_ID <= 2812)
            )
        AND JO.PRESSURE_BROUGHT IS NOT NULL
   ORDER BY JO.DATE_OBSERVATION

--

/* �������� ��������� */

COMMIT


