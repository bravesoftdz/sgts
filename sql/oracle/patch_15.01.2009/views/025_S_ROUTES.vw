/* �������� ��������� ��������� */

CREATE OR REPLACE VIEW S_ROUTES
AS 
SELECT R.ROUTE_ID, R.NAME, R.DESCRIPTION, R.DATE_ROUTE, R.IS_ACTIVE
  FROM ROUTES R

--

/* �������� ��������� */

COMMIT


