unit SgtsIntegerEdit;

interface

uses Messages, Classes, StdCtrls, SgtsControls;

type

  TSgtsIntegerEdit=class(TEdit)
  private
    FMaxValue: Integer;
    FMinValue: Integer;
    function GetValue: Integer;
    procedure SetValue(Value: Integer);
    function ChopToRange(Value: Integer): Integer;
    procedure SetMaxValue(Value: Integer);
    procedure SetMinValue(Value: Integer);
    function IsInRange(Value: Integer): boolean; overload;
    function IsInRange(Value: String): boolean; overload;
  protected
     procedure WMPaste(var Msg: TMessage); message WM_PASTE;
  public
    constructor Create(AOwner: TComponent); override;
    procedure KeyPress(var Key: Char); override;

    property Value: Integer read GetValue write SetValue;
    property MaxValue: Integer read FMaxValue write SetMaxValue;
    property MinValue: Integer read FMinValue write SetMinValue;
  end;

implementation

uses SysUtils, Clipbrd, Variants, StrUtils,
     SgtsUtils;

{ TSgtsIntegerEdit }

constructor TSgtsIntegerEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FMaxValue:=MaxInt;
  FMinValue:=-MaxInt;
  MaxLength:=10;
  Width:=60;
  AutoSize:=true;
  Text:='';
end;

function TSgtsIntegerEdit.GetValue: Integer;
begin
  if Text = '' then
    Result := 0
  else
    Result := StrToIntDef(Text, 0);
end;

procedure TSgtsIntegerEdit.SetValue(Value: Integer);
begin
  Text:=IntToStr(ChopToRange(Value));
end;

function TSgtsIntegerEdit.ChopToRange(Value: Integer): Integer;
begin
  Result := Value;
  if (Value > MaxValue) then
    Result := MaxValue;

  if (Value < MinValue) then
    Result := MinValue;
end;

procedure TSgtsIntegerEdit.SetMaxValue(Value: Integer);
begin
  FMaxValue := Value;
  if MinValue > MaxValue then
    FMinValue := MaxValue;
end;

procedure TSgtsIntegerEdit.SetMinValue(Value: Integer);
begin
  FMinValue := Value;
  if MaxValue < MaxValue then
    FMaxValue := MinValue;
end;

function TSgtsIntegerEdit.IsInRange(Value: Integer): boolean;
begin
  Result := True;
  if (Value > MaxValue) then
    Result := False;
  if (Value < MinValue) then
    Result := False;
end;

function TSgtsIntegerEdit.IsInRange(Value: String): boolean;
var
  eValue: Integer;
begin
  if Value = '' then
    eValue := 0
  else
    eValue := StrToIntDef(Value, 0);

  Result := IsInRange(eValue);
end;

procedure TSgtsIntegerEdit.KeyPress(var Key: Char);
var
  lsNewText: string;
begin
  if (Ord(Key)) < Ord(' ') then
  begin
    if Key = #13 then Key := #0 else
    inherited KeyPress(Key);
    exit;
  end;

  if not CharIsDigit(Key) and (Key <> '-') then
    Key := #0;

  if Key = '-' then
  begin
    if (MinValue >= 0) then
      Key := #0
    else if SelStart <> 0 then
      Key := #0;

    if StrLeft(lsNewText, 2) = '--' then
      Key := #0;
  end;

  if (SelStart = 0) and (Key = '0') and (StrLeft(lsNewText, 1) = '0') then
    Key := #0;

  if (SelStart = 1) and (Key = '0') and (StrLeft(lsNewText, 2) = '-0') then
    Key := #0;

  lsNewText := GetChangedText(Text, SelStart, SelLength, Key);
  if not IsInRange(lsNewText) then
    Key := #0;

  if Key <> #0 then
    inherited;
end;

{$HINTS OFF}
procedure TSgtsIntegerEdit.WMPaste(var Msg: TMessage);
var
  PasteText: string;
  Buffer: Integer;
  E: Integer;
begin
  Clipboard.Open;
  PasteText:=Clipboard.AsText;
  Clipboard.Close;
  Val(PasteText, Buffer, E);
  if E = 0 then
    inherited;
end;
{$HINTS ON}


end.
