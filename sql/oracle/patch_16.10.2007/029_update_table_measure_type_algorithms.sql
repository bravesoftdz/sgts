/* ���������� ���� ������ �������� ��������� � ������� ����� ���������� � ����� ��������� */

ALTER TABLE MEASURE_TYPE_ALGORITHMS
ADD DATE_BEGIN DATE

--

/* ��������� �������� ��� ���� ������ */

BEGIN
  UPDATE MEASURE_TYPE_ALGORITHMS
  SET DATE_BEGIN=TO_DATE('01.01.1960','DD.MM.YYYY');
  COMMIT;
END;

--

/* ��������� ���� ������ �������� ��������� */

ALTER TABLE MEASURE_TYPE_ALGORITHMS
MODIFY DATE_BEGIN NOT NULL

--

/* ���������� ���� ��������� ��������� � ������ ������ ���������� � ����� ��������� */

ALTER TABLE MEASURE_TYPE_ALGORITHMS
ADD DATE_END DATE

--

/* �������� ��������� */

COMMIT