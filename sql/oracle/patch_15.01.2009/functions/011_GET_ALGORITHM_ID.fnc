/* �������� ������ ��������� �������������� ��� ������� ���������� */

CREATE OR REPLACE FUNCTION GET_ALGORITHM_ID RETURN INTEGER IS
  ID INTEGER;
BEGIN
  SELECT SEQ_ALGORITHMS.NEXTVAL INTO ID FROM DUAL;
  RETURN ID;
END;

--

/* �������� ��������� */

COMMIT