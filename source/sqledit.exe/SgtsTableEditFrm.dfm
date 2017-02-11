object SgtsTableEditFrame: TSgtsTableEditFrame
  Left = 0
  Top = 0
  Width = 430
  Height = 362
  TabOrder = 0
  object Splitter: TSplitter
    Left = 0
    Top = 231
    Width = 430
    Height = 3
    Cursor = crVSplit
    Align = alBottom
  end
  object PanelTop: TPanel
    Left = 0
    Top = 0
    Width = 430
    Height = 59
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object LabelTableName: TLabel
      Left = 17
      Top = 8
      Width = 70
      Height = 13
      Alignment = taRightJustify
      Caption = #1048#1084#1103' '#1090#1072#1073#1083#1080#1094#1099':'
    end
    object ButtonLoad: TButton
      Left = 89
      Top = 31
      Width = 75
      Height = 25
      Caption = #1047#1072#1075#1088#1091#1079#1080#1090#1100
      TabOrder = 1
      OnClick = ButtonLoadClick
    end
    object ButtonSave: TButton
      Left = 171
      Top = 31
      Width = 75
      Height = 25
      Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100
      TabOrder = 2
      OnClick = ButtonSaveClick
    end
    object ButtonCreate: TButton
      Left = 7
      Top = 31
      Width = 75
      Height = 25
      Caption = #1057#1086#1079#1076#1072#1090#1100
      TabOrder = 0
      OnClick = ButtonCreateClick
    end
    object ButtonClear: TButton
      Left = 253
      Top = 31
      Width = 75
      Height = 25
      Caption = #1054#1095#1080#1089#1090#1080#1090#1100
      TabOrder = 3
      OnClick = ButtonClearClick
    end
    object EditTableName: TEdit
      Left = 96
      Top = 5
      Width = 231
      Height = 21
      TabOrder = 4
    end
    object btUpColumns: TBitBtn
      Left = 334
      Top = 31
      Width = 25
      Height = 25
      Hint = #1042#1074#1077#1088#1093
      TabOrder = 5
      OnClick = btUpColumnsClick
      Glyph.Data = {
        F6000000424DF600000000000000760000002800000010000000100000000100
        0400000000008000000000000000000000001000000010000000000000000000
        8000008000000080800080000000800080008080000080808000C0C0C0000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00888888888888
        8888888888888888888888888888888888888888888888888888888880000088
        8888888880666088888888888066608888888888806660888888880000666000
        0888888066666660888888880666660888888888806660888888888888060888
        8888888888808888888888888888888888888888888888888888}
    end
    object btDownColumns: TBitBtn
      Left = 365
      Top = 31
      Width = 25
      Height = 25
      Hint = #1042#1085#1080#1079
      TabOrder = 6
      OnClick = btDownColumnsClick
      Glyph.Data = {
        F6000000424DF600000000000000760000002800000010000000100000000100
        0400000000008000000000000000000000001000000010000000000000000000
        8000008000000080800080000000800080008080000080808000C0C0C0000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00888888888888
        8888888888888888888888888888888888888888888888888888888888808888
        8888888888060888888888888066608888888888066666088888888066666660
        8888880000666000088888888066608888888888806660888888888880666088
        8888888880000088888888888888888888888888888888888888}
    end
  end
  object PanelGrid: TPanel
    Left = 0
    Top = 59
    Width = 430
    Height = 172
    Align = alClient
    BevelOuter = bvNone
    BorderWidth = 3
    TabOrder = 1
    object DBNavigator: TDBNavigator
      Left = 3
      Top = 144
      Width = 424
      Height = 25
      DataSource = DataSource
      Align = alBottom
      Flat = True
      TabOrder = 0
    end
  end
  object PanelBottom: TPanel
    Left = 0
    Top = 234
    Width = 430
    Height = 128
    Align = alBottom
    BevelOuter = bvNone
    BorderWidth = 3
    TabOrder = 2
    object GroupBoxValue: TGroupBox
      Left = 3
      Top = 3
      Width = 424
      Height = 122
      Align = alClient
      Caption = ' '#1047#1085#1072#1095#1077#1085#1080#1077' '
      TabOrder = 0
      object PanelValue: TPanel
        Left = 2
        Top = 15
        Width = 420
        Height = 105
        Align = alClient
        BevelOuter = bvNone
        BorderWidth = 5
        TabOrder = 0
        object PanelValueButton: TPanel
          Left = 326
          Top = 5
          Width = 89
          Height = 95
          Align = alRight
          BevelOuter = bvNone
          TabOrder = 1
          object ButtonGen: TButton
            Left = 8
            Top = 2
            Width = 75
            Height = 25
            Caption = #1043#1077#1085#1077#1088#1072#1090#1086#1088
            TabOrder = 0
            OnClick = ButtonGenClick
          end
          object ButtonLoadValue: TButton
            Left = 8
            Top = 34
            Width = 75
            Height = 25
            Caption = #1047#1072#1075#1088#1091#1079#1080#1090#1100
            TabOrder = 1
            OnClick = ButtonLoadValueClick
          end
          object ButtonSaveValue: TButton
            Left = 8
            Top = 66
            Width = 75
            Height = 25
            Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100
            TabOrder = 2
            OnClick = ButtonSaveValueClick
          end
        end
        object PanelMemo: TPanel
          Left = 5
          Top = 5
          Width = 321
          Height = 95
          Align = alClient
          BevelOuter = bvNone
          TabOrder = 0
          object LabelFilter: TLabel
            Left = 2
            Top = 4
            Width = 42
            Height = 13
            Caption = #1060#1080#1083#1100#1090#1088':'
          end
          object DBMemoValue: TDBMemo
            Left = 0
            Top = 27
            Width = 321
            Height = 68
            Align = alBottom
            Anchors = [akLeft, akTop, akRight, akBottom]
            DataSource = DataSource
            ScrollBars = ssBoth
            TabOrder = 2
          end
          object EditFilter: TEdit
            Left = 53
            Top = 1
            Width = 148
            Height = 21
            TabOrder = 0
          end
          object ButtonApply: TButton
            Left = 205
            Top = 1
            Width = 75
            Height = 21
            Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
            TabOrder = 1
            OnClick = ButtonApplyClick
          end
        end
      end
    end
  end
  object DataSource: TDataSource
    Left = 72
    Top = 120
  end
  object OpenDialog: TOpenDialog
    Filter = 
      'Xml '#1092#1072#1081#1083#1099' (*.xml)|*.xml|Desc '#1092#1072#1081#1083#1099' (*.des)|*.des|Query '#1092#1072#1081#1083#1099' (*.' +
      'que)|*.que|Result '#1092#1072#1081#1083#1099' (*.rsl)|*.rsl|Struct '#1092#1072#1081#1083#1099' (*.str)|*.str' +
      '|'#1042#1089#1077' '#1092#1072#1081#1083#1099' (*.*)|*.*'
    Left = 152
    Top = 128
  end
  object SaveDialog: TSaveDialog
    Filter = 
      'Xml '#1092#1072#1081#1083#1099' (*.xml)|*.xml|Desc '#1092#1072#1081#1083#1099' (*.des)|*.des|Query '#1092#1072#1081#1083#1099' (*.' +
      'que)|*.que|Result '#1092#1072#1081#1083#1099' (*.rsl)|*.rsl|Struct '#1092#1072#1081#1083#1099' (*.str)|*.str' +
      '|'#1042#1089#1077' '#1092#1072#1081#1083#1099' (*.*)|*.*'
    Left = 240
    Top = 128
  end
end
