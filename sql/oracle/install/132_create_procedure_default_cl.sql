/* �������� ��������� ��������� �������� �� ��������� ��� Cl(+) */

CREATE OR REPLACE PROCEDURE DEFAULT_CL
(
  VALUE_8 IN OUT FLOAT
)  
AS
BEGIN
  IF (VALUE_8 IS NULL) THEN
    VALUE_8:=0.0;
  END IF;
END;

--

/* �������� ��������� �� */

COMMIT