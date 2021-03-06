; Script generated by the Inno Setup Script Wizard.
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!

[Setup]
AppName=����
AppVerName=���� 1.0
DefaultDirName={pf}\����
DefaultGroupName=����
OutputDir=U:\install\Output
OutputBaseFilename=sgts_oracle_empty
Compression=lzma
SolidCompression=yes

[Languages]
Name: "russian"; MessagesFile: "compiler:Languages\Russian.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "U:\install\oracle_empty\adortl70.bpl"; DestDir: "{app}"; Flags: ignoreversion
Source: "U:\install\oracle_empty\core.bpl"; DestDir: "{app}"; Flags: ignoreversion
Source: "U:\install\oracle_empty\dbrtl70.bpl"; DestDir: "{app}"; Flags: ignoreversion
Source: "U:\install\oracle_empty\designide70.bpl"; DestDir: "{app}"; Flags: ignoreversion
Source: "U:\install\oracle_empty\dsnap70.bpl"; DestDir: "{app}"; Flags: ignoreversion
Source: "U:\install\oracle_empty\indy70.bpl"; DestDir: "{app}"; Flags: ignoreversion
Source: "U:\install\oracle_empty\report.bpl"; DestDir: "{app}"; Flags: ignoreversion
Source: "U:\install\oracle_empty\rtl70.bpl"; DestDir: "{app}"; Flags: ignoreversion
Source: "U:\install\oracle_empty\tee70.bpl"; DestDir: "{app}"; Flags: ignoreversion
Source: "U:\install\oracle_empty\teedb70.bpl"; DestDir: "{app}"; Flags: ignoreversion
Source: "U:\install\oracle_empty\teeui70.bpl"; DestDir: "{app}"; Flags: ignoreversion
Source: "U:\install\oracle_empty\vcl70.bpl"; DestDir: "{app}"; Flags: ignoreversion
Source: "U:\install\oracle_empty\vclactnband70.bpl"; DestDir: "{app}"; Flags: ignoreversion
Source: "U:\install\oracle_empty\vcldb70.bpl"; DestDir: "{app}"; Flags: ignoreversion
Source: "U:\install\oracle_empty\vcljpg70.bpl"; DestDir: "{app}"; Flags: ignoreversion
Source: "U:\install\oracle_empty\vclsmp70.bpl"; DestDir: "{app}"; Flags: ignoreversion
Source: "U:\install\oracle_empty\vclx70.bpl"; DestDir: "{app}"; Flags: ignoreversion
Source: "U:\install\oracle_empty\install.cmd"; DestDir: "{app}"; Flags: ignoreversion
Source: "U:\install\oracle_empty\uninstall.cmd"; DestDir: "{app}"; Flags: ignoreversion
Source: "U:\install\oracle_empty\kgesgraphs.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "U:\install\oracle_empty\midas.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "U:\install\oracle_empty\oraado.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "U:\install\oracle_empty\sgts.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "U:\install\oracle_empty\sgts.ini"; DestDir: "{app}"; Flags: ignoreversion
Source: "U:\install\oracle_empty\sgtsrd.ini"; DestDir: "{app}"; Flags: ignoreversion

Source: "U:\install\oracle_empty\JOURNAL_FIELDS_0000001_0100000.que"; DestDir: "{app}"; Flags: ignoreversion
Source: "U:\install\oracle_empty\JOURNAL_FIELDS_0100001_0200000.que"; DestDir: "{app}"; Flags: ignoreversion

Source: "U:\install\oracle_empty\JOURNAL_OBSERVATIONS_0000001_0100000.que"; DestDir: "{app}"; Flags: ignoreversion
Source: "U:\install\oracle_empty\JOURNAL_OBSERVATIONS_0100001_0200000.que"; DestDir: "{app}"; Flags: ignoreversion

Source: "U:\install\oracle_empty\install.que"; DestDir: "{app}"; Flags: ignoreversion
Source: "U:\install\oracle_empty\uninstall.que"; DestDir: "{app}"; Flags: ignoreversion
Source: "U:\install\oracle_empty\rtl70.rus"; DestDir: "{app}"; Flags: ignoreversion
Source: "U:\install\oracle_empty\vcl70.rus"; DestDir: "{app}"; Flags: ignoreversion
Source: "U:\install\oracle_empty\vcldb70.rus"; DestDir: "{app}"; Flags: ignoreversion
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Icons]
Name: "{group}\����"; Filename: "{app}\sgts.exe"
Name: "{group}\{cm:UninstallProgram,����}"; Filename: "{uninstallexe}"
Name: "{userdesktop}\����"; Filename: "{app}\sgts.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\sgts.exe"; Description: "{cm:LaunchProgram,����}"; Flags: nowait postinstall skipifsilent

[Code]

procedure CurStepChanged(CurStep: TSetupStep);
var
  ResultCode: Integer;
begin
  case CurStep of
    ssPostInstall: begin
      Exec(ExpandConstant('{sys}\regsvr32.exe'), ExpandConstant('"{app}\midas.dll" /s'), '', SW_SHOWNORMAL, ewWaitUntilTerminated, ResultCode);
      if MsgBox('���������� SQL ������� ��� ���� ������?', mbConfirmation, MB_YESNO) = idYes then begin
        if not Exec(ExpandConstant('{app}\sgts.exe'), '/install_sql install.que OracleSgts', '', SW_SHOWNORMAL, ewWaitUntilTerminated, ResultCode) then
          MsgBox(SysErrorMessage(ResultCode) + '.', mbError, MB_OK);
      end;
(*      if MsgBox('���������� SQL ������� ��� �������� ���� ������?', mbConfirmation, MB_YESNO) = idYes then begin
        if not Exec(ExpandConstant('{app}\sgts.exe'), '/install_sql install.que OracleTest', '', SW_SHOWNORMAL, ewWaitUntilTerminated, ResultCode) then
          MsgBox(SysErrorMessage(ResultCode) + '.', mbError, MB_OK);
      end;*)
      BringToFrontAndRestore();
    end;
  end;
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
var
  ResultCode: Integer;
begin
  case CurUninstallStep of
    usUninstall: begin
      Exec(ExpandConstant('{sys}\regsvr32.exe'), ExpandConstant('"{app}\midas.dll" /s'), '', SW_SHOWNORMAL, ewWaitUntilTerminated, ResultCode);
      if MsgBox('������� SQL ������� ��� ���� ������?', mbConfirmation, MB_YESNO) = idYes then begin
        if not Exec(ExpandConstant('{app}\sgts.exe'), '/uninstall_sql uninstall.que OracleSgts', '', SW_SHOWNORMAL, ewWaitUntilTerminated, ResultCode) then
          MsgBox(SysErrorMessage(ResultCode) + '.', mbError, MB_OK);
      end;
(*      if MsgBox('������� SQL ������� ��� �������� ���� ������?', mbConfirmation, MB_YESNO) = idYes then begin
        if not Exec(ExpandConstant('{app}\sgts.exe'), '/uninstall_sql uninstall.que OracleTest', '', SW_SHOWNORMAL, ewWaitUntilTerminated, ResultCode) then
          MsgBox(SysErrorMessage(ResultCode) + '.', mbError, MB_OK);
      end;*)
      Exec(ExpandConstant('{sys}\regsvr32.exe'), ExpandConstant('"{app}\midas.dll" /u /s'), '', SW_SHOWNORMAL, ewWaitUntilTerminated, ResultCode);
      BringToFrontAndRestore();
    end;
  end;
end;

