/* ��������� ������ � ������� ���� ������� */

BEGIN
  UPDATE PERMISSIONS
     SET INTERFACE='���� ������'
   WHERE INTERFACE='���� �������� ������';

  COMMIT;        
END;

--

