inherited SgtsTestForm: TSgtsTestForm
  Left = 573
  Top = 189
  Caption = #1058#1077#1089#1090#1086#1074#1072#1103' '#1092#1086#1088#1084#1072
  ClientHeight = 201
  ClientWidth = 528
  Constraints.MinHeight = 228
  Constraints.MinWidth = 536
  ExplicitLeft = 8
  ExplicitTop = 8
  ExplicitWidth = 536
  ExplicitHeight = 235
  PixelsPerInch = 96
  TextHeight = 13
  object ButtonOpen: TButton
    Left = 8
    Top = 16
    Width = 75
    Height = 25
    Caption = 'Open test'
    TabOrder = 0
    OnClick = ButtonOpenClick
  end
  object ButtonInsert: TButton
    Left = 8
    Top = 47
    Width = 75
    Height = 25
    Caption = 'Insert test'
    TabOrder = 1
    OnClick = ButtonInsertClick
  end
  object DBGrid1: TDBGrid
    Left = 96
    Top = 16
    Width = 424
    Height = 177
    Anchors = [akLeft, akTop, akRight, akBottom]
    DataSource = DataSource
    ReadOnly = True
    TabOrder = 2
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
  end
  object ButtonIface: TButton
    Left = 8
    Top = 78
    Width = 75
    Height = 25
    Caption = 'Iface select'
    TabOrder = 3
    OnClick = ButtonIfaceClick
  end
  object DataSource: TDataSource
    Left = 208
    Top = 32
  end
end
