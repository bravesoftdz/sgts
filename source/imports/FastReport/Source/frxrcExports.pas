{******************************************}
{                                          }
{             FastReport v4.0              }
{          Language resource file          }
{                                          }
{         Copyright (c) 1998-2006          }
{         by Alexander Tzyganenko,         }
{            Fast Reports Inc.             }
{                                          }
{******************************************}

unit frxrcExports;

interface

implementation

uses frxRes;

const resStr =
'======== TfrxXLSExportDialog ========' + #13#10 +
'8000=������� � Excel' + #13#10 +
'8001=�����' + #13#10 +
'8002=��������' + #13#10 +
'8003=���������� ������' + #13#10 +
'8004=������� �������' + #13#10 +
'8005=WYSIWYG' + #13#10 +
'8006=��� �����' + #13#10 +
'8007=���' + #13#10 +
'8008=������� Excel ����� ��������' + #13#10 +
'8009=���� Excel (*.xls)|*.xls' + #13#10 +
'8010=.xls' + #13#10 +
'' + #13#10 +
'======== TfrxXMLExportDialog ========' + #13#10 +
'8100=������� � Excel' + #13#10 +
'8101=�����' + #13#10 +
'8102=WYSIWYG' + #13#10 +
'8103=���' + #13#10 +
'8104=������� Excel ����� ��������' + #13#10 +
'8105=���� Excel (*.xls)|*.xls' + #13#10 +
'8106=.xls' + #13#10 +
'' + #13#10 +
'======== TfrxHTMLExportDialog ========' + #13#10 +
'8200=������� � HTML (���������)' + #13#10 +
'8201=������� ����� ��������' + #13#10 +
'8202=�����' + #13#10 +
'8203=��������' + #13#10 +
'8204=��� � ����� �����' + #13#10 +
'8205=����.������' + #13#10 +
'8206=���������' + #13#10 +
'8207=���������������' + #13#10 +
'8208=������� Mozilla' + #13#10 +
'8209=���' + #13#10 +
'8210=���� HTML (*.html)|*.html' + #13#10 +
'8211=.html' + #13#10 +
'' + #13#10 +
'======== TfrxTXTExportDialog ========' + #13#10 +
'8300=������� � �����' + #13#10 +
'8301=�������� ����������' + #13#10 +
'8302= �����' + #13#10 +
'8303=������� �������' + #13#10 +
'8304=OEM-���������' + #13#10 +
'8305=������ ������' + #13#10 +
'8306=������� �����' + #13#10 +
'8307=������' + #13#10 +
'8308=������� ������ �/��� ��������� �������, ����������� ��������. ��������, 1,3,5-12' + #13#10 +
'8309= �������' + #13#10 +
'8310=�� ��� X' + #13#10 +
'8311=�� ��� Y' + #13#10 +
'8312= �����' + #13#10 +
'8313=���' + #13#10 +
'8314=���������' + #13#10 +
'8315=�����������' + #13#10 +
'8316=Only with OEM codepage' + #13#10 +
'8317=������ ����� ��������' + #13#10 +
'8318=��������� ���������' + #13#10 +
'8319= ��������' + #13#10 +
'8320=������:' + #13#10 +
'8321=������:' + #13#10 +
'8322=��������' + #13#10 +
'8323=���������' + #13#10 +
'8324=���������' + #13#10 +
'8325=��������� ���� (*.txt)|*.txt' + #13#10 +
'8326=.txt' + #13#10 +
'' + #13#10 +
'======== TfrxPrnInit ========' + #13#10 +
'8400=������' + #13#10 +
'8401=�������' + #13#10 +
'8402=���' + #13#10 +
'8403=���������...' + #13#10 +
'8404=�����' + #13#10 +
'8405=����������' + #13#10 +
'8406= �����' + #13#10 +
'8407=��� ��������' + #13#10 +
'8408=.fpi' + #13#10 +
'8409=��������� �������� (*.fpi)|*.fpi' + #13#10 +
'8410=.fpi' + #13#10 +
'8411=��������� �������� (*.fpi)|*.fpi' + #13#10 +
'' + #13#10 +
'======== TfrxRTFExportDialog ========' + #13#10 +
'8500=������� � RTF (���������)' + #13#10 +
'8501=��������' + #13#10 +
'8502=WYSIWYG' + #13#10 +
'8503=������� ����� ��������' + #13#10 +
'8504=���� RTF (*.rtf)|*.rtf' + #13#10 +
'8505=.rtf' + #13#10 +
'' + #13#10 +
'======== TfrxIMGExportDialog ========' + #13#10 +
'8600=������� � �������' + #13#10 +
'8601= �����' + #13#10 +
'8602=�������� JPEG' + #13#10 +
'8603=���������� (dpi)' + #13#10 +
'8604=���������� �����' + #13#10 +
'8605=�������� ��������' + #13#10 +
'8606=�����������' + #13#10 +
'' + #13#10 +
'======== TfrxPDFExportDialog ========' + #13#10 +
'8700=������� � PDF' + #13#10 +
'8701=����������' + #13#10 +
'8702=�������� ������' + #13#10 +
'8703=������� ����������' + #13#10 +
'8704=����������' + #13#10 +
'8705=���' + #13#10 +
'8706=������� ����� ��������' + #13#10 +
'8707=���� Adobe PDF (*.pdf)|*.pdf' + #13#10 +
'8708=.pdf' + #13#10 +
'' + #13#10 +
'RTFexport=�������� Word (���������)' + #13#10 +
'BMPexport=������� BMP' + #13#10 +
'JPEGexport=������� JPEG' + #13#10 +
'TIFFexport=������� TIFF' + #13#10 +
'TextExport=��������� ���� (prn)' + #13#10 +
'XlsOLEexport=�������� Excel (OLE)' + #13#10 +
'HTMLexport=�������� HTML (���������)' + #13#10 +
'XlsXMLexport=�������� Excel (XML)' + #13#10 +
'PDFexport=�������� PDF' + #13#10 +
'ProgressWait=���������, ����������' + #13#10 +
'ProgressRows=��������� �����' + #13#10 +
'ProgressColumns=��������� �������' + #13#10 +
'ProgressStyles=��������� ������' + #13#10 +
'ProgressObjects=������� ��������' + #13#10 +
'TIFFexportFilter=������� TIFF (*.tif)|*.tif' + #13#10 +
'BMPexportFilter=������� BMP (*.bmp)|*.bmp' + #13#10 +
'JPEGexportFilter=������� JPEG (*.jpg)|*.jpg' + #13#10 +
'HTMLNavFirst=������' + #13#10 +
'HTMLNavPrev=����.' + #13#10 +
'HTMLNavNext=����.' + #13#10 +
'HTMLNavLast=�����' + #13#10 +
'HTMLNavRefresh=��������' + #13#10 +
'HTMLNavPrint=������' + #13#10 +
'HTMLNavTotal=����� �������' + #13#10 +
'======== TfrxSimpleTextExportDialog ========' + #13#10 +
'8800=������� � �����' + #13#10 +
'8801=��������� ���� (*.txt)|*.txt' + #13#10 +
'8802=.txt' + #13#10 +
'SimpleTextExport=��������� ����' + #13#10 +
'======== TfrxCSVExportDialog ========' + #13#10 +
'8850=������� � CSV' + #13#10 +
'8851=CSV ���� (*.csv)|*.csv' + #13#10 +
'8852=.csv' + #13#10 +
'8853=�����������' + #13#10 +
'CSVExport=CSV ����' + #13#10 +
'======== TfrxMailExportDialog ========' + #13#10 +
'8900=�������� �� E-mail' + #13#10 +
'8901=E-mail' + #13#10 +
'8902=����' + #13#10 +
'8903=�����������' + #13#10 +
'8904=�����' + #13#10 +
'8905=����������' + #13#10 +
'8906=������' + #13#10 +
'8907=�����' + #13#10 +
'8908=�����' + #13#10 +
'8909=������' + #13#10 +
'8910=���' + #13#10 +
'8911=������' + #13#10 +
'8912=���������' + #13#10 +
'8913=�����' + #13#10 +
'8914=�����������' + #13#10 +
'8915=������' + #13#10 +
'8916=����' + #13#10 +
'8917=��������� ���������' + #13#10 +
'8918=����������� ���� �� ���������' + #13#10 +
'8919=����������� ��������� ��������' + #13#10 +
'8920=�������' + #13#10 +
'8921=�������' + #13#10 +
'8922=����' + #13#10 +
'8923=� ���������' + #13#10 +
'8924=�������� ������ ��' + #13#10 +
'EmailExport=E-mail' + #13#10 +
'FastReportFile=FastReport ����' + #13#10 +
'======== TfrxGIFExport ========' + #13#10 +
'GifexportFilter=������� Gif (*.gif)|*.gif' + #13#10 +
'GIFexport=������� Gif' + #13#10 +
'======== 3.21 ========' + #13#10 +
'8950=�����������' + #13#10 +
'======== 3.22 ========' + #13#10 +
'8951=�����������' + #13#10 +
'8952=�����' + #13#10 +
'8953=�����������' + #13#10 +
'8954=���' + #13#10 +
'ODSExportFilter=Open Document ������� (*.ods)|*.ods' + #13#10 +
'ODSExport=Open Document �������' + #13#10 +
'ODTExportFilter=Open Document ����� (*.odt)|*.odt' + #13#10 +
'ODTExport=Open Document �����' + #13#10 +
'8960=.ods' + #13#10 +
'8961=.odt' + #13#10 +
'';

initialization
  frxResources.AddStrings(resStr);

end.
