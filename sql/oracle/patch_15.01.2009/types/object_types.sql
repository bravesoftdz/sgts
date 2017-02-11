/* �������� ���� ������� ��� ��������� ������������ */

CREATE OR REPLACE TYPE CRITERIA_OBJECT AS OBJECT 
( 
  POINT_ID INTEGER, 
  DATE_OBSERVATION DATE, 
  CYCLE_ID INTEGER, 
  VALUE FLOAT, 
  STATE INTEGER 
)

--

/* �������� ���� ������� ��� �������� ������� ���������� */

CREATE OR REPLACE TYPE FLT_JOURNAL_FIELD_OBJECT AS OBJECT 
( 
  CYCLE_ID INTEGER, 
  CYCLE_NUM INTEGER, 
  JOURNAL_NUM VARCHAR2(100), 
  DATE_OBSERVATION DATE, 
  MEASURE_TYPE_ID INTEGER, 
  POINT_ID INTEGER, 
  POINT_NAME INTEGER, 
  CONVERTER_ID INTEGER, 
  CONVERTER_NAME VARCHAR2(100), 
  MARK FLOAT, 
  VOLUME FLOAT, 
  TIME FLOAT, 
  EXPENSE FLOAT, 
  T_WATER FLOAT, 
  OBJECT_PATHS VARCHAR2(1000), 
  SECTION_PRIORITY INTEGER, 
  JOINT_PRIORITY INTEGER, 
  COORDINATE_Z FLOAT 
)

--

/* �������� ���� ������� ��� ������� ���������� ���������� */

CREATE OR REPLACE TYPE FLT_JOURNAL_OBSERVATION_OBJECT AS OBJECT 
( 
  CYCLE_ID INTEGER, 
  CYCLE_NUM INTEGER, 
  JOURNAL_NUM VARCHAR2(100), 
  DATE_OBSERVATION DATE, 
  MEASURE_TYPE_ID INTEGER, 
  POINT_ID INTEGER, 
  POINT_NAME INTEGER, 
  CONVERTER_ID INTEGER, 
  CONVERTER_NAME VARCHAR2(100), 
  MARK FLOAT, 
  VOLUME FLOAT, 
  TIME FLOAT, 
  EXPENSE FLOAT, 
  T_WATER FLOAT, 
  OBJECT_PATHS VARCHAR2(1000), 
  SECTION_PRIORITY INTEGER, 
  JOINT_PRIORITY INTEGER, 
  COORDINATE_Z FLOAT 
)

--

/* �������� ���� ������� ��� �������� ������� ����������������� */

CREATE OR REPLACE TYPE GMO_JOURNAL_FIELD_OBJECT AS OBJECT 
( 
  CYCLE_ID INTEGER, 
  CYCLE_NUM INTEGER, 
  DATE_OBSERVATION DATE, 
  MEASURE_TYPE_ID INTEGER, 
  POINT_ID INTEGER, 
  UVB FLOAT, 
  UNB FLOAT, 
  T_AIR FLOAT, 
  T_WATER FLOAT, 
  RAIN_DAY FLOAT, 
  PREC FLOAT, 
  UNSET FLOAT, 
  INFLUX FLOAT, 
  V_VAULT FLOAT 
)

--

/* �������� ���� ������� ��� ������� ���������� ����������������� */

CREATE OR REPLACE TYPE GMO_JOURNAL_OBSERVATION_OBJECT AS OBJECT 
( 
  CYCLE_ID INTEGER, 
  CYCLE_NUM INTEGER, 
  DATE_OBSERVATION DATE, 
  MEASURE_TYPE_ID INTEGER, 
  POINT_ID INTEGER, 
  UVB FLOAT, 
  UNB FLOAT, 
  T_AIR FLOAT, 
  T_WATER FLOAT, 
  RAIN_DAY FLOAT, 
  PREC FLOAT, 
  UNSET FLOAT, 
  INFLUX FLOAT, 
  V_VAULT FLOAT, 
  UVB_INC FLOAT, 
  RAIN_YEAR FLOAT, 
  T_AIR_10 FLOAT, 
  T_AIR_30 FLOAT   
)

--

/* �������� ���� ������� ��� �������� ������� �������������� */

CREATE OR REPLACE TYPE HDN_JOURNAL_FIELD_OBJECT AS OBJECT 
( 
  CYCLE_ID INTEGER, 
  CYCLE_NUM INTEGER, 
  JOURNAL_NUM INTEGER, 
  JOURNAL_FIELD_ID INTEGER, 
  DATE_OBSERVATION DATE, 
  MEASURE_TYPE_ID INTEGER, 
  POINT_ID INTEGER, 
  POINT_NAME VARCHAR2(100), 
  CONVERTER_ID INTEGER, 
  CONVERTER_NAME VARCHAR2(100), 
  VALUE_MOTION_FORWARD FLOAT, 
  VALUE_MOTION_BACK FLOAT,   
  VALUE_AVERAGE FLOAT, 
  VALUE_ERROR FLOAT, 
  DATE_MOTION_BACK VARCHAR2(100), 
  HDN_NAME VARCHAR2(100), 
  HDN_NUMBER INTEGER, 
  OBJECT_SHORT_NAME VARCHAR2(100) 
)

--

/* �������� ���� ������� ��� ������� ���������� �������������� */

CREATE OR REPLACE TYPE HDN_JOURNAL_OBSERVATION_OBJECT AS OBJECT 
( 
  CYCLE_ID INTEGER, 
  CYCLE_NUM INTEGER, 
  JOURNAL_FIELD_ID INTEGER, 
  DATE_OBSERVATION DATE, 
  MEASURE_TYPE_ID INTEGER, 
  POINT_ID INTEGER, 
  POINT_NAME VARCHAR2(100), 
  CONVERTER_ID INTEGER, 
  CONVERTER_NAME VARCHAR2(100), 
  VALUE_MOTION_FORWARD FLOAT, 
  VALUE_MOTION_BACK FLOAT, 
  VALUE_DISPLACEMENT_BEGIN FLOAT, 
  VALUE_CURRENT_DISPLACEMENT FLOAT, 
  VALUE_MARK_POINT FLOAT, 
  HDN_NAME VARCHAR2(100), 
  HDN_NUMBER INTEGER, 
  OBJECT_SHORT_NAME VARCHAR2(100) 
)

--

/* �������� ���� ������� ��� �������� ������� ���������� */

CREATE OR REPLACE TYPE HMZ_JOURNAL_FIELD_OBJECT AS OBJECT 
( 
  CYCLE_ID INTEGER, 
  CYCLE_NUM INTEGER, 
  JOURNAL_NUM VARCHAR2(100), 
  DATE_OBSERVATION DATE, 
  MEASURE_TYPE_ID INTEGER, 
  POINT_ID INTEGER, 
  POINT_NAME INTEGER, 
  CONVERTER_ID INTEGER, 
  CONVERTER_NAME VARCHAR2(100), 
  MARK FLOAT, 
  PH FLOAT, 
  CO2SV FLOAT, 
  CO3_2 FLOAT, 
  CO2AGG FLOAT, 
  ALKALI FLOAT, 
  ACERBITY FLOAT, 
  CA FLOAT, 
  MG FLOAT, 
  CL FLOAT, 
  SO4_2 FLOAT, 
  HCO3 FLOAT, 
  NA_K FLOAT, 
  AGGRESSIV FLOAT, 
  OBJECT_PATHS VARCHAR2(1000), 
  SECTION_PRIORITY INTEGER, 
  COORDINATE_Z FLOAT 
)

--

/* �������� ���� ������� ��� ������� ���������� ���������� */

CREATE OR REPLACE TYPE HMZ_JOURNAL_OBSERVATION_OBJECT AS OBJECT 
( 
  CYCLE_ID INTEGER, 
  CYCLE_NUM INTEGER, 
  JOURNAL_NUM VARCHAR2(100), 
  DATE_OBSERVATION DATE, 
  MEASURE_TYPE_ID INTEGER, 
  POINT_ID INTEGER, 
  POINT_NAME INTEGER, 
  CONVERTER_ID INTEGER, 
  CONVERTER_NAME VARCHAR2(100), 
  MARK FLOAT, 
  PH FLOAT, 
  CO2SV FLOAT, 
  CO3_2 FLOAT, 
  CO2AGG FLOAT, 
  ALKALI FLOAT, 
  ACERBITY FLOAT, 
  CA FLOAT, 
  MG FLOAT, 
  CL FLOAT, 
  SO4_2 FLOAT, 
  HCO3 FLOAT, 
  NA_K FLOAT, 
  AGGRESSIV FLOAT, 
  OBJECT_PATHS VARCHAR2(1000),  
  OBJECT_PRIORITY INTEGER, 
  COORDINATE_Z FLOAT 
)

--

/* �������� ���� ������� ��� �������� ������� ����������� ������� */

CREATE OR REPLACE TYPE IND_JOURNAL_FIELD_OBJECT AS OBJECT 
( 
  CYCLE_ID INTEGER, 
  CYCLE_NUM INTEGER, 
  JOURNAL_NUM VARCHAR2(100), 
  DATE_OBSERVATION DATE, 
  POINT_ID INTEGER, 
  POINT_NAME INTEGER, 
  CONVERTER_ID INTEGER, 
  CONVERTER_NAME VARCHAR2(100), 
  OBJECT_PATHS VARCHAR2(1000), 
  OBJECT_PRIORITY INTEGER, 
  COORDINATE_Z FLOAT, 
  INDICATOR_TYPE INTEGER, 
  VALUE FLOAT, 
  OFFSET_BEGIN FLOAT, 
  CURRENT_OFFSET FLOAT 
)

--

/* �������� ���� ������� ��� ������� ���������� ����������� ������� */

CREATE OR REPLACE TYPE IND_JOURNAL_OBSERVATION_OBJECT AS OBJECT 
( 
  CYCLE_ID INTEGER, 
  CYCLE_NUM INTEGER, 
  JOURNAL_NUM VARCHAR2(100), 
  DATE_OBSERVATION DATE, 
  POINT_ID INTEGER, 
  POINT_NAME INTEGER, 
  CONVERTER_ID INTEGER, 
  CONVERTER_NAME VARCHAR2(100), 
  OBJECT_PATHS VARCHAR2(1000), 
  OBJECT_PRIORITY INTEGER, 
  COORDINATE_Z FLOAT, 
  INDICATOR_TYPE INTEGER, 
  VALUE FLOAT, 
  OFFSET_BEGIN FLOAT, 
  CURRENT_OFFSET FLOAT   
)

--

/* �������� ���� ������� ��� �������� ������� ����������-���������������� ��������� */

CREATE OR REPLACE TYPE NDS_JOURNAL_FIELD_OBJECT AS OBJECT 
( 
  CYCLE_ID INTEGER, 
  CYCLE_NUM INTEGER, 
  JOURNAL_FIELD_ID INTEGER, 
  JOURNAL_NUM INTEGER, 
  DATE_OBSERVATION DATE, 
  MEASURE_TYPE_ID INTEGER, 
  POINT_ID INTEGER, 
  POINT_NAME VARCHAR2(100), 
  COORDINATE_Z FLOAT, 
  CONVERTER_ID INTEGER, 
  CONVERTER_NAME VARCHAR2(100), 
  NOTE VARCHAR(100), 
  TYPE_INSTRUMENT VARCHAR(100), 
  VALUE_RESISTANCE_LINE FLOAT,   
  VALUE_RESISTANCE FLOAT, 
  VALUE_FREQUENCY FLOAT, 
  VALUE_PERIOD FLOAT, 
  VALUE_STATER_CARRIE FLOAT, 
  OBJECT_PATHS VARCHAR2(100) 
)

--

/* �������� ���� ������� ��� ������� ���������� ����������-���������������� ��������� */

CREATE OR REPLACE TYPE NDS_JOURNAL_OBSERVATION_OBJECT AS OBJECT 
( 
  CYCLE_ID INTEGER, 
  CYCLE_NUM INTEGER, 
  DATE_OBSERVATION DATE, 
  MEASURE_TYPE_ID INTEGER, 
  POINT_ID INTEGER, 
  POINT_NAME VARCHAR2(100), 
  CONVERTER_ID INTEGER, 
  CONVERTER_NAME VARCHAR2(100), 
  TYPE VARCHAR2(100), 
  COORDINATE_Z FLOAT, 
  VALUE_STATER_CARRIE FLOAT, 
  VALUE_EXERTION FLOAT, 
  VALUE_EXERTION_ACCOUNT FLOAT, 
  VALUE_TEMPERATURE FLOAT, 
  VALUE_OPENING FLOAT, 
  VALUE_RESISTANCE FLOAT, 
  VALUE_FREQUENCY FLOAT, 
  OBJECT_PATHS VARCHAR2(100) 
)

--

/* �������� ���� ������� ��� �������� ������� ������������� */

CREATE OR REPLACE TYPE NIV_JOURNAL_FIELD_OBJECT AS OBJECT 
( 
  CYCLE_ID INTEGER, 
  CYCLE_NUM INTEGER, 
  JOURNAL_FIELD_ID INTEGER, 
  JOURNAL_NUM INTEGER, 
  DATE_OBSERVATION DATE, 
  MEASURE_TYPE_ID INTEGER, 
  POINT_ID INTEGER, 
  POINT_NAME NUMBER, 
  ROUTE_ID NUMBER, 
  COORDINATE_Z FLOAT, 
  CONVERTER_ID INTEGER, 
  CONVERTER_NAME VARCHAR2(100), 
  NOTE VARCHAR(100), 
  DESCRIPTION VARCHAR(300), 
  OBJECT_PATHS VARCHAR2(100), 
  OBJECT_PRIORITY NUMBER 
)

--

/* �������� ���� ������� ��� ������� ���������� ������������� */

CREATE OR REPLACE TYPE NIV_JOURNAL_OBSERVATION_OBJECT AS OBJECT 
( 
  CYCLE_ID INTEGER, 
  CYCLE_NUM INTEGER, 
  DATE_OBSERVATION DATE, 
  MEASURE_TYPE_ID INTEGER, 
  POINT_ID INTEGER, 
  POINT_NAME NUMBER, 
  ROUTE_ID NUMBER, 
  COORDINATE_Z FLOAT, 
  DISPLACE FLOAT, 
  CUR_DISPLACE FLOAT, 
  CONVERTER_ID INTEGER, 
  CONVERTER_NAME VARCHAR2(100), 
  DESCRIPTION VARCHAR(300), 
  OBJECT_PATHS VARCHAR2(100), 
  OBJECT_PRIORITY NUMBER 
)

--

/* �������� ���� ������� ��� �������� ������� NMH */

CREATE OR REPLACE TYPE NMH_JOURNAL_FIELD_OBJECT AS OBJECT 
( 
  CYCLE_ID INTEGER, 
  CYCLE_NUM INTEGER, 
  DATE_OBSERVATION DATE, 
  MEASURE_TYPE_ID INTEGER, 
  POINT_ID INTEGER, 
  POINT_NAME VARCHAR2(100), 
  CONVERTER_ID INTEGER, 
  CONVERTER_NAME VARCHAR2(100), 
  VALUE_COORDINATE_Z FLOAT, 
  HDN_NUMBER INTEGER, 
  OBJECT_PATHS VARCHAR2(100) 
)

--

/* �������� ���� ������� ��� �������� ������� ������� */

CREATE OR REPLACE TYPE OTV_JOURNAL_FIELD_OBJECT AS OBJECT 
( 
  CYCLE_ID INTEGER, 
  CYCLE_NUM INTEGER, 
  JOURNAL_NUM VARCHAR2(100), 
  DATE_OBSERVATION DATE, 
  MEASURE_TYPE_ID INTEGER, 
  POINT_ID INTEGER, 
  POINT_NAME INTEGER, 
  CONVERTER_ID INTEGER, 
  CONVERTER_NAME VARCHAR2(100), 
  DATE_ENTER DATE, 
  COUNTING_OUT_AXIS_X FLOAT,   
  COUNTING_OUT_AXIS_Y FLOAT,   
  OFFSET_X_WITH_BEGIN_OBSERV FLOAT, 
  OFFSET_Y_WITH_BEGIN_OBSERV FLOAT, 
  CURRENT_OFFSET_X FLOAT, 
  CURRENT_OFFSET_Y FLOAT, 
  GROUP_NAME VARCHAR2(100), 
  MARH_GRAP_OR_ANCHOR_PLUMB FLOAT, 
  OBJECT_PATHS VARCHAR2(1000), 
  AXES_PRIORITY INTEGER, 
  SECTION_PRIORITY INTEGER, 
  COORDINATE_Z FLOAT, 
  DESCRIPTION VARCHAR2(250) 
)

--

/* �������� ���� ������� ��� ������� ���������� ������� */

CREATE OR REPLACE TYPE OTV_JOURNAL_OBSERVATION_OBJECT AS OBJECT 
( 
  CYCLE_ID INTEGER, 
  CYCLE_NUM INTEGER, 
  DATE_OBSERVATION DATE, 
  MEASURE_TYPE_ID INTEGER, 
  POINT_ID INTEGER, 
  POINT_NAME INTEGER, 
  CONVERTER_ID INTEGER, 
  CONVERTER_NAME VARCHAR2(100), 
  DATE_ENTER DATE, 
  COUNTING_OUT_AXIS_X FLOAT,   
  COUNTING_OUT_AXIS_Y FLOAT,   
  OFFSET_X_WITH_BEGIN_OBSERV FLOAT, 
  OFFSET_Y_WITH_BEGIN_OBSERV FLOAT, 
  CURRENT_OFFSET_X FLOAT, 
  CURRENT_OFFSET_Y FLOAT, 
  GROUP_NAME VARCHAR2(100), 
  MARH_GRAP_OR_ANCHOR_PLUMB FLOAT, 
  OBJECT_PATHS VARCHAR2(1000), 
  AXES_PRIORITY INTEGER, 
  SECTION_PRIORITY INTEGER, 
  COORDINATE_Z FLOAT, 
  DESCRIPTION VARCHAR2(250) 
)

--

/* �������� ���� ������� ��� ������������� ����� */

CREATE OR REPLACE TYPE POINT_OBJECT AS OBJECT 
( 
  POINT_ID INTEGER 
)

--

/* �������� ���� ������� ��� �������� ������� �������-�������� ����������� */

CREATE OR REPLACE TYPE PVO_JOURNAL_FIELD_OBJECT AS OBJECT 
( 
  CYCLE_ID INTEGER, 
  CYCLE_NUM INTEGER, 
  JOURNAL_FIELD_ID INTEGER, 
  JOURNAL_NUM INTEGER, 
  DATE_OBSERVATION DATE, 
  MEASURE_TYPE_ID INTEGER, 
  POINT_ID INTEGER, 
  POINT_NAME NUMBER, 
  ROUTE_ID NUMBER, 
  H FLOAT, 
  X FLOAT, 
  Y FLOAT, 
  CONVERTER_ID INTEGER, 
  CONVERTER_NAME VARCHAR2(100), 
  NOTE VARCHAR(100), 
  DESCRIPTION VARCHAR(300), 
  OBJECT_PATHS VARCHAR2(100), 
  OBJECT_PRIORITY NUMBER 
)

--

/* �������� ���� ������� ��� ������� ���������� �������-�������� ����������� */

CREATE OR REPLACE TYPE PVO_JOURNAL_OBSERVATION_OBJECT AS OBJECT 
( 
  CYCLE_ID INTEGER, 
  CYCLE_NUM INTEGER, 
  DATE_OBSERVATION DATE, 
  MEASURE_TYPE_ID INTEGER, 
  POINT_ID INTEGER, 
  POINT_NAME NUMBER, 
  ROUTE_ID NUMBER, 
  H FLOAT, 
  H_DISPLACE FLOAT, 
  H_CUR_DISPLACE FLOAT, 
  X FLOAT, 
  X_DISPLACE FLOAT, 
  X_CUR_DISPLACE FLOAT, 
  Y FLOAT, 
  Y_DISPLACE FLOAT, 
  Y_CUR_DISPLACE FLOAT, 
  CONVERTER_ID INTEGER, 
  CONVERTER_NAME VARCHAR2(100), 
  DESCRIPTION VARCHAR(300), 
  OBJECT_PATHS VARCHAR2(100), 
  OBJECT_PRIORITY NUMBER 
)

--

/* �������� ���� ������� ��� �������� ������� ����������� */

CREATE OR REPLACE TYPE PZM_JOURNAL_FIELD_OBJECT AS OBJECT 
( 
  CYCLE_ID INTEGER, 
  CYCLE_NUM INTEGER, 
  JOURNAL_NUM VARCHAR2(100), 
  DATE_OBSERVATION DATE, 
  MEASURE_TYPE_ID INTEGER, 
  POINT_ID INTEGER, 
  POINT_NAME INTEGER, 
  CONVERTER_ID INTEGER, 
  CONVERTER_NAME VARCHAR2(100), 
  INSTRUMENT_ID INTEGER, 
  INSTRUMENT_NAME VARCHAR2(100), 
  VALUE FLOAT, 
  OBJECT_PATHS VARCHAR2(1000), 
  COORDINATE_Z FLOAT 
)

--

/* �������� ���� ������� ��� ������� ���������� ����������� */

CREATE OR REPLACE TYPE PZM_JOURNAL_OBSERVATION_OBJECT AS OBJECT 
( 
  CYCLE_ID INTEGER, 
  CYCLE_NUM INTEGER, 
  DATE_OBSERVATION DATE, 
  MEASURE_TYPE_ID INTEGER, 
  POINT_ID INTEGER, 
  POINT_NAME INTEGER, 
  CONVERTER_ID INTEGER, 
  CONVERTER_NAME VARCHAR2(100), 
  MARK_HEAD FLOAT, 
  PRESSURE_ACTIVE FLOAT, 
  MARK_WATER FLOAT, 
  PRESSURE_OPPOSE FLOAT, 
  PRESSURE_BROUGHT FLOAT, 
  OBJECT_PATHS VARCHAR2(1000), 
  SECTION_PRIORITY INTEGER, 
  COORDINATE_Z FLOAT 
)

--

/* �������� ���� ������� ��� ������ �������� ������������ */

CREATE OR REPLACE TYPE REPORT_CRITERIA_OBJECT AS OBJECT 
( 
  CRITERIA_ID INTEGER, 
  POINT_ID INTEGER, 
  DATE_OBSERVATION DATE, 
  CYCLE_ID INTEGER, 
  VALUE FLOAT, 
  STATE INTEGER 
)

--

/* �������� ���� ������� ��� �������� ������� ��������� ��������� */

CREATE OR REPLACE TYPE SL1_JOURNAL_FIELD_OBJECT AS OBJECT 
( 
  CYCLE_ID INTEGER, 
  CYCLE_NUM INTEGER, 
  JOURNAL_NUM VARCHAR2(100), 
  DATE_OBSERVATION DATE, 
  MEASURE_TYPE_ID INTEGER, 
  POINT_ID INTEGER, 
  POINT_NAME INTEGER, 
  CONVERTER_ID INTEGER, 
  CONVERTER_NAME VARCHAR2(100), 
  OBJECT_PATHS VARCHAR2(1000), 
  SECTION_JOINT_PRIORITY INTEGER,  
  OUTFALL_PRIORITY INTEGER, 
  AXES_PRIORITY INTEGER, 
  COORDINATE_Z FLOAT, 
  VALUE FLOAT, 
  OPENING FLOAT, 
  CURRENT_OPENING FLOAT 
)

--

/* �������� ���� ������� ��� ������� ���������� ��������� ��������� */

CREATE OR REPLACE TYPE SL1_JOURNAL_OBSERVATION_OBJECT AS OBJECT 
( 
  CYCLE_ID INTEGER, 
  CYCLE_NUM INTEGER, 
  JOURNAL_NUM VARCHAR2(100), 
  DATE_OBSERVATION DATE, 
  MEASURE_TYPE_ID INTEGER, 
  POINT_ID INTEGER, 
  POINT_NAME INTEGER, 
  CONVERTER_ID INTEGER, 
  CONVERTER_NAME VARCHAR2(100), 
  OBJECT_PATHS VARCHAR2(1000), 
  SECTION_JOINT_PRIORITY INTEGER,  
  AXES_PRIORITY INTEGER, 
  SECTION_PRIORITY INTEGER, 
  OUTFALL_PRIORITY INTEGER, 
  COORDINATE_Z FLOAT, 
  VALUE FLOAT, 
  OPENING FLOAT, 
  CURRENT_OPENING FLOAT, 
  CYCLE_NULL_OPENING FLOAT 
)

--

/* �������� ���� ������� ��� �������� ������� ��������� ��������� */

CREATE OR REPLACE TYPE SLF_JOURNAL_FIELD_OBJECT AS OBJECT 
( 
  CYCLE_ID INTEGER, 
  CYCLE_NUM INTEGER, 
  JOURNAL_NUM VARCHAR2(100), 
  DATE_OBSERVATION DATE, 
  MEASURE_TYPE_ID INTEGER, 
  POINT_ID INTEGER, 
  POINT_NAME INTEGER, 
  CONVERTER_ID INTEGER, 
  CONVERTER_NAME VARCHAR2(100), 
  OBJECT_PATHS VARCHAR2(1000), 
  SECTION_JOINT_PRIORITY INTEGER, 
  JOINT_PRIORITY INTEGER, 
  COORDINATE_Z FLOAT, 
  VALUE_AB_RACK FLOAT, 
  VALUE_AB_COMPASSES FLOAT, 
  VALUE_AB_MICROMETR FLOAT, 
  VALUE_BA_RACK FLOAT, 
  VALUE_BA_COMPASSES FLOAT, 
  VALUE_BA_MICROMETR FLOAT, 
  VALUE_AC_RACK FLOAT, 
  VALUE_AC_COMPASSES FLOAT, 
  VALUE_AC_MICROMETR FLOAT, 
  VALUE_CA_RACK FLOAT, 
  VALUE_CA_COMPASSES FLOAT, 
  VALUE_CA_MICROMETR FLOAT, 
  VALUE_BC_RACK FLOAT, 
  VALUE_BC_COMPASSES FLOAT, 
  VALUE_BC_MICROMETR FLOAT, 
  VALUE_CB_RACK FLOAT, 
  VALUE_CB_COMPASSES FLOAT, 
  VALUE_CB_MICROMETR FLOAT, 
  AVERAGE_AB_COMPASSES FLOAT, 
  AVERAGE_AB_MICROMETR FLOAT, 
  AVERAGE_AC_COMPASSES FLOAT, 
  AVERAGE_AC_MICROMETR FLOAT, 
  AVERAGE_BC_COMPASSES FLOAT, 
  AVERAGE_BC_MICROMETR FLOAT, 
  ERROR FLOAT, 
  OPENING_X FLOAT, 
  OPENING_Y FLOAT, 
  OPENING_Z FLOAT, 
  CURRENT_OPENING_X FLOAT, 
  CURRENT_OPENING_Y FLOAT, 
  CURRENT_OPENING_Z FLOAT 
)

--

/* �������� ���� ������� ��� ������� ���������� ��������� ��������� */

CREATE OR REPLACE TYPE SLF_JOURNAL_OBSERVATION_OBJECT AS OBJECT 
( 
  CYCLE_ID INTEGER, 
  CYCLE_NUM INTEGER, 
  JOURNAL_NUM VARCHAR2(100), 
  DATE_OBSERVATION DATE, 
  MEASURE_TYPE_ID INTEGER, 
  POINT_ID INTEGER, 
  POINT_NAME INTEGER, 
  CONVERTER_ID INTEGER, 
  CONVERTER_NAME VARCHAR2(100), 
  OBJECT_PATHS VARCHAR2(1000), 
  SECTION_JOINT_PRIORITY INTEGER, 
  JOINT_PRIORITY INTEGER, 
  COORDINATE_Z FLOAT, 
  OPENING_X FLOAT, 
  OPENING_Y FLOAT, 
  OPENING_Z FLOAT, 
  CURRENT_OPENING_X FLOAT, 
  CURRENT_OPENING_Y FLOAT, 
  CURRENT_OPENING_Z FLOAT, 
  CYCLE_NULL_OPENING_X FLOAT, 
  CYCLE_NULL_OPENING_Y FLOAT, 
  CYCLE_NULL_OPENING_Z FLOAT 
)

--

/* �������� ���� ������� ��� �������� ������� ��������� ��������� */

CREATE OR REPLACE TYPE SLW_JOURNAL_FIELD_OBJECT AS OBJECT 
( 
  CYCLE_ID INTEGER, 
  CYCLE_NUM INTEGER, 
  JOURNAL_NUM VARCHAR2(100), 
  DATE_OBSERVATION DATE, 
  MEASURE_TYPE_ID INTEGER, 
  POINT_ID INTEGER, 
  POINT_NAME INTEGER, 
  CONVERTER_ID INTEGER, 
  CONVERTER_NAME VARCHAR2(100), 
  OBJECT_PATHS VARCHAR2(1000), 
  SECTION_JOINT_PRIORITY INTEGER, 
  JOINT_PRIORITY INTEGER, 
  COORDINATE_Z FLOAT, 
  VALUE_X FLOAT, 
  VALUE_Y FLOAT, 
  VALUE_Z FLOAT, 
  OPENING_X FLOAT, 
  OPENING_Y FLOAT, 
  OPENING_Z FLOAT, 
  CURRENT_OPENING_X FLOAT, 
  CURRENT_OPENING_Y FLOAT, 
  CURRENT_OPENING_Z FLOAT 
)

--

/* �������� ���� ������� ��� ������� ���������� ��������� ��������� */

CREATE OR REPLACE TYPE SLW_JOURNAL_OBSERVATION_OBJECT AS OBJECT 
( 
  CYCLE_ID INTEGER, 
  CYCLE_NUM INTEGER, 
  JOURNAL_NUM VARCHAR2(100), 
  DATE_OBSERVATION DATE, 
  MEASURE_TYPE_ID INTEGER, 
  POINT_ID INTEGER, 
  POINT_NAME INTEGER, 
  CONVERTER_ID INTEGER, 
  CONVERTER_NAME VARCHAR2(100), 
  OBJECT_PATHS VARCHAR2(1000),   
  SECTION_JOINT_PRIORITY INTEGER, 
  JOINT_PRIORITY INTEGER, 
  COORDINATE_Z FLOAT, 
  VALUE_X FLOAT, 
  VALUE_Y FLOAT, 
  VALUE_Z FLOAT, 
  OPENING_X FLOAT, 
  OPENING_Y FLOAT, 
  OPENING_Z FLOAT, 
  CURRENT_OPENING_X FLOAT, 
  CURRENT_OPENING_Y FLOAT, 
  CURRENT_OPENING_Z FLOAT, 
  CYCLE_NULL_OPENING_X FLOAT, 
  CYCLE_NULL_OPENING_Y FLOAT, 
  CYCLE_NULL_OPENING_Z FLOAT 
)

--

/* �������� ���� ������� ��� �������� ������� �������-����������� ������ */

CREATE OR REPLACE TYPE SOS_JOURNAL_FIELD_OBJECT AS OBJECT 
( 
  CYCLE_ID INTEGER, 
  CYCLE_NUM INTEGER, 
  JOURNAL_NUM VARCHAR2(100), 
  DATE_OBSERVATION DATE, 
  POINT_ID INTEGER, 
  POINT_NAME INTEGER, 
  CONVERTER_ID INTEGER, 
  CONVERTER_NAME VARCHAR2(100), 
  PLACE_ZERO FLOAT, 
  DIRECTION_MOVE FLOAT, 
  VALUE FLOAT, 
  DIFFERENCE_MOVE FLOAT, 
  ERROR_MARK FLOAT, 
  VALUE_AVERAGE FLOAT, 
  OBJECT_PATHS VARCHAR2(1000) 
)

--

/* �������� ���� ������� ��� ������� ���������� �������-����������� ������ */

CREATE OR REPLACE TYPE SOS_JOURNAL_OBSERVATION_OBJECT AS OBJECT 
( 
  CYCLE_ID INTEGER, 
  CYCLE_NUM INTEGER, 
  DATE_OBSERVATION DATE, 
  POINT_ID INTEGER, 
  POINT_NAME INTEGER, 
  CONVERTER_ID INTEGER, 
  CONVERTER_NAME VARCHAR2(100), 
  PLACE_ZERO FLOAT, 
  DIRECTION_MOVE FLOAT, 
  VALUE FLOAT, 
  DIFFERENCE_MOVE FLOAT, 
  OFFSET_MARK_BEGIN_OBSERV FLOAT, 
  OFFSET_MARK_CYCLE_ZERO FLOAT, 
  ERROR_MARK FLOAT, 
  VALUE_AVERAGE FLOAT, 
  CURRENT_OFFSET_MARK FLOAT, 
  OBJECT_PATHS VARCHAR2(1000) 
)

--

/* �������� ���� ������� ��� �������� ������� ����������� � ��������� */

CREATE OR REPLACE TYPE TVL_JOURNAL_FIELD_OBJECT AS OBJECT 
( 
  CYCLE_ID INTEGER, 
  CYCLE_NUM INTEGER, 
  JOURNAL_NUM VARCHAR2(100), 
  DATE_OBSERVATION DATE, 
  MEASURE_TYPE_ID INTEGER, 
  POINT_ID INTEGER, 
  POINT_NAME INTEGER, 
  CONVERTER_ID INTEGER, 
  CONVERTER_NAME VARCHAR2(100), 
  VALUE_DRY FLOAT, 
  ADJUSTMENT_DRY FLOAT, 
  T_DRY FLOAT, 
  VALUE_WET FLOAT, 
  ADJUSTMENT_WET FLOAT, 
  T_WET FLOAT, 
  MOISTURE FLOAT, 
  OBJECT_PATHS VARCHAR2(1000), 
  COORDINATE_Z FLOAT 
)

--

/* �������� ���� ������� ��� ������� ���������� ����������� � ��������� */

CREATE OR REPLACE TYPE TVL_JOURNAL_OBSERVATION_OBJECT AS OBJECT 
( 
  CYCLE_ID INTEGER, 
  CYCLE_NUM INTEGER, 
  JOURNAL_NUM VARCHAR2(100), 
  DATE_OBSERVATION DATE, 
  MEASURE_TYPE_ID INTEGER, 
  POINT_ID INTEGER, 
  POINT_NAME INTEGER, 
  CONVERTER_ID INTEGER, 
  CONVERTER_NAME VARCHAR2(100), 
  VALUE_DRY FLOAT, 
  ADJUSTMENT_DRY FLOAT, 
  T_DRY FLOAT, 
  VALUE_WET FLOAT, 
  ADJUSTMENT_WET FLOAT, 
  T_WET FLOAT, 
  MOISTURE FLOAT, 
  OBJECT_PATHS VARCHAR2(1000), 
  COORDINATE_Z FLOAT 
)

--

/* �������� ���� ������� ��� ������ */

CREATE OR REPLACE TYPE VARCHAR_OBJECT AS OBJECT 
( 
  VALUE VARCHAR2(250) 
)

--

/* �������� ��������� */

COMMIT


