/* �������� ��������� ������ NEW �������� */

CREATE OR REPLACE VIEW S_HMZ_REPORT_NEW
AS 
SELECT   JO.CONVERTER_NAME,
         P.COORDINATE_Z,
         JO.DATE_OBSERVATION,
         JO.CYCLE_NUM,
         JO.PH,
         JO.CO2SV,
         JO.CO3_2,
         JO.CO2AGG,
         JO.ALKALI,
         JO.ACERBITY,
         JO.CA,
         JO.MG,
         JO.CL,
         JO.SO4_2,
         JO.HCO3,
         JO.NA_K,
         JO.AGGRESSIV,
         (CASE
             WHEN PP.DESCRIPTION = '�������������� �����: ������� ��������� 1�� ����'
                THEN '������ ��������� 1�� ����'
             WHEN PP.DESCRIPTION = '�������������� �����: ������� ��������� 2�� ����'
                THEN '������ ��������� 2�� ����'
             WHEN PP.DESCRIPTION = '�������������� �����: ������� ������ � ���'
                THEN '������� ������ � ���'
             WHEN PP.DESCRIPTION = '�������������� �����: ������� ����������'
                THEN '������� ����������'
             WHEN PP.DESCRIPTION = '�������������� �����: ������� ����'
                THEN '������� ����'
             ELSE ''
          END
         ) AS GROUP_NAME,
         (CASE
             WHEN PP.DESCRIPTION = '�������������� �����: ������� ��������� 1�� ����'
                THEN 1
             WHEN PP.DESCRIPTION = '�������������� �����: ������� ��������� 2�� ����'
                THEN 2
             WHEN PP.DESCRIPTION = '�������������� �����: ������� ������ � ���'
                THEN 3
             WHEN PP.DESCRIPTION = '�������������� �����: ������� ����������'
                THEN 4
             WHEN PP.DESCRIPTION = '�������������� �����: ������� ����'
                THEN 5
             ELSE 0
          END
         ) AS GROUP_PRIORITY
    FROM POINT_PASSPORTS PP,
         S_HMZ_JOURNAL_OBSERVATIONS JO,
         POINTS P
   WHERE (PP.POINT_ID >= 4001)
     AND (PP.POINT_ID <= 4104)
     AND (PP.POINT_ID = JO.POINT_ID)
     AND (P.POINT_ID = JO.POINT_ID)
ORDER BY DATE_OBSERVATION,
         COORDINATE_Z

--

/* �������� ��������� */

COMMIT


