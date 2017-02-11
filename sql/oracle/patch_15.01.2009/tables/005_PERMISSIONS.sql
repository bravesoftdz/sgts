/* �������� ������� ���� */

CREATE TABLE PERMISSIONS
(
  PERMISSION_ID INTEGER NOT NULL, 
  ACCOUNT_ID INTEGER NOT NULL, 
  INTERFACE VARCHAR2(250) NOT NULL,
  PERMISSION VARCHAR2(250) NOT NULL,
  PERMISSION_VALUE VARCHAR2(250) NOT NULL,
  PRIMARY KEY (PERMISSION_ID),
  FOREIGN KEY (ACCOUNT_ID) REFERENCES ACCOUNTS (ACCOUNT_ID)
)  

--

/* �������� ��������� */

COMMIT