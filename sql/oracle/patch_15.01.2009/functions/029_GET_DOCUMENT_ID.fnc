/* �������� ������ ��������� �������������� ��� ������� ���������� */

CREATE OR REPLACE FUNCTION GET_DOCUMENT_ID RETURN INTEGER IS
  ID INTEGER;
BEGIN
  SELECT SEQ_DOCUMENTS.NEXTVAL INTO ID FROM DUAL;
  RETURN ID;
END;

--

/* �������� ��������� */

COMMIT