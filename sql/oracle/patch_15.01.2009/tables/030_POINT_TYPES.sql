/* �������� ������� ����� ����� */

CREATE TABLE POINT_TYPES
(
  POINT_TYPE_ID INTEGER NOT NULL, 
  NAME VARCHAR2(100) NOT NULL,
  DESCRIPTION VARCHAR2(250),
  PRIMARY KEY (POINT_TYPE_ID)
)

--

/* �������� ��������� */

COMMIT