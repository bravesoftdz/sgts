inherited SgtsRbkPointTypeEditForm: TSgtsRbkPointTypeEditForm
  Left = 426
  Top = 226
  Width = 325
  Height = 240
  Caption = #1056#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1085#1080#1077' '#1090#1080#1087#1072' '#1090#1086#1095#1082#1080
  Constraints.MinHeight = 240
  Constraints.MinWidth = 320
  PixelsPerInch = 96
  TextHeight = 13
  inherited StatusBar: TStatusBar
    Top = 175
    Width = 317
  end
  inherited ToolBar: TToolBar
    Height = 136
  end
  inherited PanelEdit: TPanel
    Width = 282
    Height = 136
    object LabelName: TLabel
      Left = 3
      Top = 16
      Width = 79
      Height = 13
      Alignment = taRightJustify
      Caption = #1053#1072#1080#1084#1077#1085#1086#1074#1072#1085#1080#1077':'
      FocusControl = EditName
    end
    object LabelNote: TLabel
      Left = 29
      Top = 43
      Width = 53
      Height = 13
      Alignment = taRightJustify
      Caption = #1054#1087#1080#1089#1072#1085#1080#1077':'
      FocusControl = MemoNote
    end
    object EditName: TEdit
      Left = 90
      Top = 12
      Width = 184
      Height = 21
      TabOrder = 0
      Text = #1053#1086#1074#1099#1081' '#1090#1080#1087' '#1090#1086#1095#1082#1080
    end
    object MemoNote: TMemo
      Left = 90
      Top = 40
      Width = 184
      Height = 89
      TabOrder = 1
    end
  end
  inherited PanelButton: TPanel
    Top = 136
    Width = 317
    inherited ButtonCancel: TButton
      Left = 236
    end
    inherited ButtonOk: TButton
      Left = 154
    end
  end
  inherited MainMenu: TMainMenu
    Left = 176
    Top = 40
  end
  inherited ImageList: TImageList
    Left = 208
  end
end
