/* ���������� ����� ������� � ������� ����� */

ALTER TABLE POINTS
ADD NAME2 INTEGER

--

/* ��������� �������� ������������ */

BEGIN
  UPDATE POINTS
  SET NAME2=TO_NUMBER(NAME);
END;

--

/* �������� ������� ������������ */

ALTER TABLE POINTS
DROP COLUMN NAME

--

/* �������������� ������� */

ALTER TABLE POINTS
RENAME COLUMN NAME2 TO NAME

--

/* �������� ��������� �� */

COMMIT