/* �������� �������� ����� */

CREATE OR REPLACE VIEW S_GROUPS
AS 
SELECT G.GROUP_ID,G.NAME,G.DESCRIPTION
  FROM GROUPS G

--

/* �������� ��������� */

COMMIT


