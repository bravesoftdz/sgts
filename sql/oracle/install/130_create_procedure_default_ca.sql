/* �������� ��������� ��������� �������� �� ��������� ��� Ca(+) */

CREATE OR REPLACE PROCEDURE DEFAULT_CA
(
  VALUE_6 IN OUT FLOAT
)  
AS
BEGIN
  IF (VALUE_6 IS NULL) THEN
    VALUE_6:=0.0;
  END IF;
END;

--

/* �������� ��������� �� */

COMMIT