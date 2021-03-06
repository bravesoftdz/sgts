object SgtsTableNewForm: TSgtsTableNewForm
  Left = 510
  Top = 155
  Width = 610
  Height = 350
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = #1054#1087#1088#1077#1076#1077#1083#1077#1085#1080#1077' '#1087#1086#1083#1077#1081
  Color = clBtnFace
  Constraints.MinHeight = 350
  Constraints.MinWidth = 310
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object PanelButton: TPanel
    Left = 0
    Top = 287
    Width = 602
    Height = 36
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    DesignSize = (
      602
      36)
    object ButtonOk: TButton
      Left = 440
      Top = 6
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = #1054#1050
      Default = True
      TabOrder = 0
      OnClick = ButtonOkClick
    end
    object ButtonCancel: TButton
      Left = 522
      Top = 6
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Cancel = True
      Caption = #1054#1090#1084#1077#1085#1072
      ModalResult = 2
      TabOrder = 1
    end
    object ButtonSave: TButton
      Left = 88
      Top = 6
      Width = 75
      Height = 25
      Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100
      TabOrder = 3
      OnClick = ButtonSaveClick
    end
    object ButtonLoad: TButton
      Left = 6
      Top = 6
      Width = 75
      Height = 25
      Caption = #1047#1072#1075#1088#1091#1079#1080#1090#1100
      TabOrder = 2
      OnClick = ButtonLoadClick
    end
    object ButtonClear: TButton
      Left = 170
      Top = 6
      Width = 75
      Height = 25
      Caption = #1054#1095#1080#1089#1090#1080#1090#1100
      TabOrder = 4
      OnClick = ButtonClearClick
    end
  end
  object PanelGrid: TPanel
    Left = 0
    Top = 0
    Width = 602
    Height = 287
    Align = alClient
    BevelOuter = bvNone
    BorderWidth = 3
    TabOrder = 0
    object DBGrid: TDBGrid
      Left = 3
      Top = 3
      Width = 596
      Height = 281
      Align = alClient
      DataSource = DataSource
      TabOrder = 0
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -11
      TitleFont.Name = 'MS Sans Serif'
      TitleFont.Style = []
      Columns = <
        item
          Expanded = False
          FieldName = 'NAME'
          Title.Caption = #1048#1084#1103' '#1087#1086#1083#1103
          Width = 160
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'WIDTH'
          Title.Caption = #1064#1080#1088#1080#1085#1072
          Width = 45
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'DATA_TYPE'
          Title.Caption = #1058#1080#1087' '#1076#1072#1085#1085#1099#1093
          Width = 85
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'SIZE'
          Title.Caption = #1056#1072#1079#1084#1077#1088
          Width = 50
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'PRECISION'
          Title.Caption = #1058#1086#1095#1085#1086#1089#1090#1100
          Width = 55
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'DESCRIPTION'
          Title.Caption = #1054#1087#1080#1089#1072#1085#1080#1077
          Width = 150
          Visible = True
        end>
    end
  end
  object DataSource: TDataSource
    Left = 64
    Top = 80
  end
  object OpenDialog: TOpenDialog
    Filter = 'Struct '#1092#1072#1081#1083#1099' (*.str)|*.str|'#1042#1089#1077' '#1092#1072#1081#1083#1099' (*.*)|*.*'
    Options = [ofEnableSizing]
    Left = 72
    Top = 160
  end
  object SaveDialog: TSaveDialog
    DefaultExt = '*.str'
    Filter = 'Struct '#1092#1072#1081#1083#1099' (*.str)|*.str|'#1042#1089#1077' '#1092#1072#1081#1083#1099' (*.*)|*.*'
    Options = [ofEnableSizing]
    Left = 144
    Top = 160
  end
end
