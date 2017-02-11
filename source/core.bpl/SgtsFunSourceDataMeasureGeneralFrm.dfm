inherited SgtsFunSourceDataMeasureGeneralFrame: TSgtsFunSourceDataMeasureGeneralFrame
  Width = 451
  Height = 304
  Align = alClient
  Constraints.MinHeight = 300
  Constraints.MinWidth = 451
  ExplicitWidth = 451
  ExplicitHeight = 304
  inherited PanelStatus: TPanel
    Width = 451
    Height = 304
    ExplicitWidth = 451
    ExplicitHeight = 304
    object PanelInfo: TPanel
      Left = 0
      Top = 147
      Width = 451
      Height = 157
      Align = alBottom
      BevelOuter = bvNone
      BorderWidth = 3
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
      object GroupBoxInfo: TGroupBox
        Left = 3
        Top = 3
        Width = 445
        Height = 151
        Align = alClient
        Caption = ' '#1044#1086#1087#1086#1083#1085#1080#1090#1077#1083#1100#1085#1086' '
        TabOrder = 0
        object LabelJournalNum: TLabel
          Left = 28
          Top = 99
          Width = 82
          Height = 13
          Alignment = taRightJustify
          Caption = #1053#1086#1084#1077#1088' '#1078#1091#1088#1085#1072#1083#1072':'
          FocusControl = DBEditJournalNum
        end
        object LabelNote: TLabel
          Left = 215
          Top = 99
          Width = 65
          Height = 13
          Alignment = taRightJustify
          Caption = #1055#1088#1080#1084#1077#1095#1072#1085#1080#1077':'
          FocusControl = DBMemoNote
        end
        object LabelPointCoordinateZ: TLabel
          Left = 216
          Top = 22
          Width = 64
          Height = 13
          Alignment = taRightJustify
          Caption = #1054#1090#1084#1077#1090#1082#1072' '#1048#1058':'
          FocusControl = EditPointCoordinateZ
        end
        object LabelConverter: TLabel
          Left = 16
          Top = 22
          Width = 94
          Height = 13
          Alignment = taRightJustify
          Caption = #1055#1088#1077#1086#1073#1088#1072#1079#1086#1074#1072#1090#1077#1083#1100':'
          FocusControl = EditConverter
        end
        object LabelPointObject: TLabel
          Left = 34
          Top = 44
          Width = 76
          Height = 26
          Alignment = taRightJustify
          Caption = #1056#1072#1089#1087#1086#1083#1086#1078#1077#1085#1080#1077' '#1086#1073#1098#1077#1082#1090#1072':'
          FocusControl = MemoPointObject
          WordWrap = True
        end
        object LabelColumn: TLabel
          Left = 370
          Top = 22
          Width = 47
          Height = 13
          Alignment = taRightJustify
          Caption = #1050#1086#1083#1086#1085#1082#1072':'
          FocusControl = EditColumn
        end
        object DBEditJournalNum: TDBEdit
          Left = 117
          Top = 96
          Width = 80
          Height = 21
          DataField = 'JOURNAL_NUM'
          DataSource = DataSource
          TabOrder = 4
          OnKeyDown = DBMemoNoteKeyDown
        end
        object DBMemoNote: TDBMemo
          Left = 287
          Top = 96
          Width = 150
          Height = 46
          DataField = 'NOTE'
          DataSource = DataSource
          TabOrder = 5
          OnExit = DBMemoNoteExit
          OnKeyDown = DBMemoNoteKeyDown
        end
        object EditPointCoordinateZ: TEdit
          Left = 287
          Top = 19
          Width = 60
          Height = 21
          Color = clBtnFace
          ReadOnly = True
          TabOrder = 1
        end
        object EditConverter: TEdit
          Left = 117
          Top = 19
          Width = 81
          Height = 21
          Color = clBtnFace
          ReadOnly = True
          TabOrder = 0
        end
        object MemoPointObject: TMemo
          Left = 117
          Top = 45
          Width = 320
          Height = 46
          Color = clBtnFace
          ReadOnly = True
          ScrollBars = ssVertical
          TabOrder = 3
          WordWrap = False
        end
        object EditColumn: TEdit
          Left = 424
          Top = 19
          Width = 13
          Height = 21
          Color = clBtnFace
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
          ReadOnly = True
          TabOrder = 2
        end
      end
    end
    object PanelGrid: TPanel
      Left = 0
      Top = 0
      Width = 451
      Height = 147
      Align = alClient
      BevelOuter = bvNone
      BorderWidth = 3
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
      object GridPattern: TDBGrid
        Left = 3
        Top = 3
        Width = 445
        Height = 141
        Align = alClient
        DataSource = DataSource
        TabOrder = 0
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -11
        TitleFont.Name = 'Tahoma'
        TitleFont.Style = []
      end
    end
  end
  object DataSource: TDataSource
    Left = 48
    Top = 32
  end
  object PopupMenuConfirm: TPopupMenu
    OnPopup = PopupMenuConfirmPopup
    Left = 128
    Top = 48
    object MenuItemConfirmCheckAll: TMenuItem
      Caption = #1059#1090#1074#1077#1088#1076#1080#1090#1100' '#1074#1089#1077
      OnClick = MenuItemConfirmCheckAllClick
    end
    object MenuItemConfirmUncheckAll: TMenuItem
      Caption = #1057#1085#1103#1090#1100' '#1091#1090#1074#1077#1088#1078#1076#1077#1085#1080#1077' '#1091' '#1074#1089#1077#1093
      OnClick = MenuItemConfirmUncheckAllClick
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object MenuItemConfirmCancel: TMenuItem
      Caption = #1054#1090#1084#1077#1085#1072
    end
  end
end
