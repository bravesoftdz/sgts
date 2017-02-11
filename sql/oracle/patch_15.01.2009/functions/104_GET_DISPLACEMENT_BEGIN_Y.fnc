/* CREATE OR REPLACE FUNCTION get_displacement_begin_y */

CREATE OR REPLACE FUNCTION get_displacement_begin_y (
   date_observation   DATE,
   point_id           INTEGER,
   value_1            FLOAT
)
   RETURN FLOAT
IS
   value_3         FLOAT;
   d_o             DATE;
   p_id            INTEGER;
   val             FLOAT;
   comp_id         INTEGER;
   pol_izm_stol    VARCHAR2 (100);
   gruppa_otvesa   VARCHAR2 (100);
   instr_id        INTEGER;
   sm              FLOAT;
   baz_zn          VARCHAR2 (100);
   baz_zn_f        FLOAT;
BEGIN /* ���������� ���� ����������, ��������, ����� � �������� � ��� */
   d_o := date_observation;
   p_id := point_id;
   val := value_1;

   FOR inc2 IN (SELECT component_id, param_id, converter_id
                  FROM components
                 WHERE (converter_id = p_id) AND (param_id = 16146))
   LOOP
      comp_id := inc2.component_id;
   END LOOP;

   /* ���������� ��������� �������������� ������� */
   FOR inc2 IN (SELECT component_id, VALUE
                  FROM converter_passports
                 WHERE (component_id = comp_id))
   LOOP
      pol_izm_stol := inc2.VALUE;
   END LOOP;

   FOR inc2 IN (SELECT component_id, param_id, converter_id
                  FROM components
                 WHERE (converter_id = p_id) AND (param_id = 16140))
   LOOP
      comp_id := inc2.component_id;
   END LOOP;

   /* ���������� ������ ������ */
   FOR inc2 IN (SELECT component_id, VALUE
                  FROM converter_passports
                 WHERE (component_id = comp_id))
   LOOP
      gruppa_otvesa := inc2.VALUE;
   END LOOP;

   /* ���� ���������� �������� ���� ������ �� X */             /* ������� ���������� �������� �������� �������� � ����� ������� */
   FOR inc2 IN (SELECT component_id, param_id, converter_id
                  FROM components
                 WHERE (converter_id = p_id) AND (param_id = 17156))
   LOOP
      comp_id := inc2.component_id;

      FOR inc3 IN (SELECT component_id, instrument_id, date_begin, date_end,
                          VALUE
                     FROM converter_passports
                    WHERE (component_id = comp_id))
      LOOP
         IF (   ((d_o >= inc3.date_begin) AND (d_o < inc3.date_end))
             OR ((d_o >= inc3.date_begin) AND (inc3.date_end IS NULL))
            )
         THEN
            instr_id := inc3.instrument_id;
            baz_zn := inc3.VALUE;
         END IF;
      END LOOP;
   END LOOP;

   SELECT REPLACE (baz_zn, ',', '.')
     INTO baz_zn
     FROM DUAL;

   baz_zn_f := TO_NUMBER (baz_zn);

   /* ���������� ������ �������� �� ��� �� �������� ���������� ������ ��� �� */
   IF (gruppa_otvesa = '�� ���������') OR (gruppa_otvesa = '�� ����������')
   THEN
      IF (instr_id = 5162)
      THEN
         sm := val - baz_zn_f;
      END IF;

      IF (instr_id = 5163) AND (pol_izm_stol = '�� ������� ��')
      THEN
         sm := baz_zn_f - val;
      END IF;

      IF (instr_id = 5163) AND (pol_izm_stol = '�� ������� ��')
      THEN
         sm := val - baz_zn_f;
      END IF;
   END IF;

   /* ���������� ������ �������� �� ��� �� ��������� ���������� ������ ��� �� */
   IF (gruppa_otvesa = '��')
   THEN
      IF (pol_izm_stol = '�� ������� ��')
      THEN
         sm := val - baz_zn_f;
      END IF;

      IF (pol_izm_stol = '�� ������� ��')
      THEN
         sm := baz_zn_f - val;
      END IF;
   END IF;

   /* ��������� */
   value_3 := sm;
   RETURN value_3;
END;

--

/* �������� ��������� */

COMMIT