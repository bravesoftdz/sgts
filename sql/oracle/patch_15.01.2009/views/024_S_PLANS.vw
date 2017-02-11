/* �������� ��������� ������ */

CREATE OR REPLACE VIEW S_PLANS
AS 
SELECT P.MEASURE_TYPE_ID,
       P.CYCLE_ID,
       P.DATE_BEGIN,
       P.DATE_END,
       MT.NAME AS MEASURE_TYPE_NAME,
       MT.IS_VISUAL,
       C.CYCLE_NUM,
       C.CYCLE_YEAR,
       C.CYCLE_MONTH,
       C.DESCRIPTION AS CYCLE_DESCRIPTION,
       C.IS_CLOSE
  FROM PLANS P,
       MEASURE_TYPES MT,
       CYCLES C
 WHERE MT.MEASURE_TYPE_ID = P.MEASURE_TYPE_ID
   AND C.CYCLE_ID = P.CYCLE_ID

--

/* �������� ��������� */

COMMIT


