/* �������� ��������� ������������ ������� ���������� �� ������� 08-28 DR */

CREATE OR REPLACE VIEW S_FLT_SUM_EXPENSE_SEC_08_28_DR
AS 
SELECT   CYCLE_NUM,
         SUM (EXPENSE) EXPENSE
    FROM S_FLT_SUM_EXPENSE_DR1
   WHERE SECTION IN ('08')
     AND COORDINATE_Z = 131
GROUP BY CYCLE_NUM

--

/* �������� ��������� */

COMMIT


