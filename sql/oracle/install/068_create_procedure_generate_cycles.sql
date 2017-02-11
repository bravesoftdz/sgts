/* �������� ��������� ��������� ������ */

CREATE OR REPLACE PROCEDURE GENERATE_CYCLES
(
  DATE_BEGIN IN DATE,
  DATE_END IN DATE
)
AS
  CNT INTEGER;
  CURDATE DATE;
  CYCLE_ID INTEGER;
  CYCLE_NUM INTEGER;
  CYCLE_YEAR INTEGER;
  CYCLE_MONTH INTEGER;
  DESCRIPTION VARCHAR2(250);
  IS_CLOSE INTEGER;  
BEGIN
  CNT:=ROUND(MONTHS_BETWEEN(DATE_END,DATE_BEGIN),0);
  FOR I IN 1..CNT LOOP
    CURDATE:=ADD_MONTHS(DATE_BEGIN,I-1);
    CYCLE_ID:=GET_CYCLE_ID();
	CYCLE_NUM:=I;
	CYCLE_YEAR:=EXTRACT(YEAR FROM CURDATE);
	CYCLE_MONTH:=EXTRACT(MONTH FROM CURDATE)-1; 
	DESCRIPTION:='���� �� �����: '||TO_CHAR(CYCLE_MONTH+1)||' � ���: '||TO_CHAR(CYCLE_YEAR);
	IS_CLOSE:=0;
    I_CYCLE(CYCLE_ID,CYCLE_NUM,CYCLE_YEAR,CYCLE_MONTH,DESCRIPTION,IS_CLOSE);
  END LOOP;
END;

--

/* �������� ��������� �� */

COMMIT