/* �������� ��� ������� ��� �������� ��������������� ������������� ����� */

CREATE TYPE POINT_OBJECT 
AS OBJECT
(
  POINT_ID INTEGER
)

--

/* �������� ���� ������� ��� �������� ��������������� ������������� ����� */

CREATE OR REPLACE TYPE POINT_TABLE 
AS TABLE OF POINT_OBJECT

--

/* �������� ��������� */

COMMIT