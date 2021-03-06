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

unit frxrcClass;

interface

implementation

uses frxRes;

const resStr =
'1=��' + #13#10 +
'2=������' + #13#10 +
'3=���' + #13#10 +
'4=�������' + #13#10 +
'5=������:' + #13#10 +
'6=������� �������' + #13#10 +
'7=��������' + #13#10 +
'8=�����' + #13#10 +
'9=������� ������ �/��� ��������� �������, ����������� ��������. ��������, 1,3,5-12' + #13#10 +
'======== TfrxPreviewForm ========' + #13#10 +
'100=��������������� ��������' + #13#10 +
'101=������' + #13#10 +
'102=������' + #13#10 +
'103=�������' + #13#10 +
'104=�������' + #13#10 +
'105=���������' + #13#10 +
'106=���������' + #13#10 +
'107=�������' + #13#10 +
'108=�������' + #13#10 +
'109=�����' + #13#10 +
'110=�����' + #13#10 +
'111=�������' + #13#10 +
'112=�������� �������' + #13#10 +
'113=�� ������' + #13#10 +
'114=�� ������' + #13#10 +
'115=100%' + #13#10 +
'116=100%' + #13#10 +
'117=��� ��������' + #13#10 +
'118=��� ��������' + #13#10 +
'119=�������' + #13#10 +
'120=����' + #13#10 +
'121=�������� ��������' + #13#10 +
'122=������' + #13#10 +
'123=������ ������' + #13#10 +
'124=���������' + #13#10 +
'125=���������' + #13#10 +
'126=���������' + #13#10 +
'127=���������' + #13#10 +
'128=������' + #13#10 +
'129=������ ������' + #13#10 +
'130=���������' + #13#10 +
'131=���������' + #13#10 +
'132=������' + #13#10 +
'133=������������� ��������' + #13#10 +
'134=������' + #13#10 +
'135=�� ������ ��������' + #13#10 +
'136=����������' + #13#10 +
'137=�� ���������� ��������' + #13#10 +
'138=���������' + #13#10 +
'139=�� ��������� ��������' + #13#10 +
'140=���������' + #13#10 +
'141=�� ��������� ��������' + #13#10 +
'142=����� ��������' + #13#10 +
'150=�� ���� �����' + #13#10 +
'151=��������� � PDF' + #13#10 +
'152=�������� �� E-mail' + #13#10 +
'zmPageWidth=�� ������' + #13#10 +
'zmWholePage=�������� �������' + #13#10 +
'======== TfrxPrintDialog ========' + #13#10 +
'200=������' + #13#10 +
'201=�������' + #13#10 +
'202=��������' + #13#10 +
'203=����������' + #13#10 +
'204=��������� �� ������' + #13#10 +
'205=�����' + #13#10 +
'206=��������' + #13#10 +
'207=������' + #13#10 +
'208=���:' + #13#10 +
'209=��������...' + #13#10 +
'210=������ � ����' + #13#10 +
'211=�������' + #13#10 +
'212=���:' + #13#10 +
'213=����� ������' + #13#10 +
'214=�������� �� �����' + #13#10 +
'216=�������' + #13#10 +
'' + #13#10 +
'ppAll=��� ��������' + #13#10 +
'ppOdd=�������� ��������' + #13#10 +
'ppEven=������ ��������' + #13#10 +
'pgDefault=�� ���������' + #13#10 +
'pmDefault=�� ���������' + #13#10 +
'pmSplit=��������� ������� ��������' + #13#10 +
'pmJoin=���������� ��������� ��������' + #13#10 +
'pmScale=��������������' + #13#10 +
'poDirect=������ (1-9)' + #13#10 +
'poReverse=�������� (9-1)' + #13#10 +
'' + #13#10 +
'======== TfrxSearchDialog ========' + #13#10 +
'300=������ �����' + #13#10 +
'301=�����:' + #13#10 +
'302=��������� ������' + #13#10 +
'303=��������' + #13#10 +
'304=������ � ������' + #13#10 +
'305=��������� �������' + #13#10 +
'' + #13#10 +
'======== TfrxPageSettingsForm ========' + #13#10 +
'400=��������� ��������' + #13#10 +
'401=������' + #13#10 +
'402=������' + #13#10 +
'403=������' + #13#10 +
'404=����������' + #13#10 +
'405=�����' + #13#10 +
'406=�������' + #13#10 +
'407=������' + #13#10 +
'408=������' + #13#10 +
'409=����' + #13#10 +
'410=����������' + #13#10 +
'411=���������' + #13#10 +
'412=������' + #13#10 +
'413=��������� � ������� ��������' + #13#10 +
'414=��������� �� ���� ���������' + #13#10 +
'' + #13#10 +
'======== TfrxDMPExportDialog ========' + #13#10 +
'500=������' + #13#10 +
'501=�������' + #13#10 +
'502=��������' + #13#10 +
'503=�����' + #13#10 +
'504=����������' + #13#10 +
'505=�����' + #13#10 +
'506=ESC-�������' + #13#10 +
'507=������ � ����' + #13#10 +
'508=OEM-���������' + #13#10 +
'509=�������������' + #13#10 +
'510=���� ������ (*.prn)|*.prn' + #13#10 +
'' + #13#10 +
'======== TfrxProgress ========' + #13#10 +
'' + #13#10 +
'mbConfirm=�������������' + #13#10 +
'mbError=������' + #13#10 +
'mbInfo=����������' + #13#10 +
'xrCantFindClass=�� ������� ����� �����' + #13#10 +
'prVirtual=�����������' + #13#10 +
'prDefault=�� ���������' + #13#10 +
'prCustom=����������������' + #13#10 +
'enUnconnHeader=�� ������������ header/footer' + #13#10 +
'enUnconnGroup=��� ����-����� ��� ������' + #13#10 +
'enUnconnGFooter=��� ��������� ������' + #13#10 +
'enBandPos=����������� ���������� ����:' + #13#10 +
'dbNotConn=��������� %s �� ��������� � ������' + #13#10 +
'dbFldNotFound=���� �� �������:' + #13#10 +
'clDSNotIncl=(��������� �� ������� � Report.DataSets)' + #13#10 +
'clUnknownVar=����������� ���������� ��� ���� ��:' + #13#10 +
'clScrError=������ � ������� %s: %s' + #13#10 +
'clDSNotExist=����� ������ "%s" �� ������' + #13#10 +
'clErrors=���� ���������� ��������� ������:' + #13#10 +
'clExprError=������ � ���������' + #13#10 +
'clFP3files=������� �����' + #13#10 +
'clSaving=����������� ����...' + #13#10 +
'clCancel=������' + #13#10 +
'clClose=�������' + #13#10 +
'clPrinting=���������� ��������' + #13#10 +
'clLoading=����������� ����...' + #13#10 +
'clPageOf=�������� %d �� %d' + #13#10 +
'clFirstPass=������ ������: ��������' + #13#10 +
'clNoPrinters=� ����� ������� �� ����������� ���������' + #13#10 +
'clDecompressError=������ ���������� ������' + #13#10 +
'crFillMx=����������� cross-tab...' + #13#10 +
'crBuildMx=�������� cross-tab...' + #13#10 +
'prRunningFirst=������ ������: �������� %d' + #13#10 +
'prRunning=��������� �������� %d' + #13#10 +
'prPrinting=���������� �������� %d' + #13#10 +
'prExporting=������� �������� %d' + #13#10 +
'uCm=��' + #13#10 +
'uInch=in' + #13#10 +
'uPix=px' + #13#10 +
'uChar=chr' + #13#10 +
'dupDefault=�� ���������' + #13#10 +
'dupVert=������������' + #13#10 +
'dupHorz=��������������' + #13#10 +
'dupSimpl=�� ������������' + #13#10 +
'' + #13#10 +
'=========== FS strings ===============' + #13#10 +
'SLangNotFound=���� ''%s'' �� ������' + #13#10 +
'SInvalidLanguage=������ � �������� �����' + #13#10 +
'SIdRedeclared=������������� �������������:' + #13#10 +
'SUnknownType=����������� ���:' + #13#10 +
'SIncompatibleTypes=������������� ����' + #13#10 +
'SIdUndeclared=�������������� �������������:' + #13#10 +
'SClassRequired=��������� �����' + #13#10 +
'SIndexRequired=��������� ������' + #13#10 +
'SStringError=������ �� ����� ������� ��� �������' + #13#10 +
'SClassError=����� %s �� �������� �������� �� ���������' + #13#10 +
'SArrayRequired=��������� ������' + #13#10 +
'SVarRequired=��������� ����������' + #13#10 +
'SNotEnoughParams=������������ ����������' + #13#10 +
'STooManyParams=������� ����� ����������' + #13#10 +
'SLeftCantAssigned=����� ����� ��������� �� ����� ���� ���������' + #13#10 +
'SForError=���������� ����� FOR ������ ���� ��������' + #13#10 +
'SEventError=���������� ������� ������ ���� ����������' + #13#10 +
'' + #13#10 +
'======== TfrxPreviewOutlineForm ========' + #13#10 +
'600=�������� ���' + #13#10 +
'601=�������� ���' + #13#10 +
'';

initialization
  frxResources.AddStrings(resStr);

end.
