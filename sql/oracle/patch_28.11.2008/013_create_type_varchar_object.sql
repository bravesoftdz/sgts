/* �������� ���� ������� �����*/

CREATE TYPE VARCHAR_OBJECT 
AS OBJECT
(
  VALUE VARCHAR2(250)
)

--

/* �������� ���� ������� ����� */

CREATE OR REPLACE TYPE VARCHAR_TABLE 
AS TABLE OF VARCHAR_OBJECT

--