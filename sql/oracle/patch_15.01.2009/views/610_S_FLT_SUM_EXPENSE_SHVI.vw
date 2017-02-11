/* �������� ��������� ������������ ������� ���������� �� ���� */

CREATE OR REPLACE VIEW S_FLT_SUM_EXPENSE_SHVI
AS
SELECT   JO.CYCLE_NUM,
         JO.COORDINATE_Z,
         CP.VALUE AS SECTION,
         SUM (JO.EXPENSE) EXPENSE
    FROM S_FLT_JOURNAL_OBSERVATIONS_2 JO,
         COMPONENTS CO,
         CONVERTER_PASSPORTS CP
   WHERE CO.CONVERTER_ID = JO.POINT_ID
     AND CO.PARAM_ID = 3003
     AND CO.COMPONENT_ID = CP.COMPONENT_ID
GROUP BY JO.CYCLE_NUM,
         JO.COORDINATE_Z,
         CP.VALUE
ORDER BY JO.CYCLE_NUM,
         JO.COORDINATE_Z,
         CP.VALUE

--

/* �������� ��������� */

COMMIT


