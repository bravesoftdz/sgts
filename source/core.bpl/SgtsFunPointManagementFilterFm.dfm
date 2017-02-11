inherited SgtsFunPointManagementFilterForm: TSgtsFunPointManagementFilterForm
  Left = 712
  Top = 218
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSizeable
  Caption = #1060#1080#1083#1100#1090#1088' '#1080#1079#1084#1077#1088#1080#1090#1077#1083#1100#1085#1099#1093' '#1090#1086#1095#1077#1082
  ClientHeight = 303
  ClientWidth = 312
  Constraints.MinHeight = 330
  Constraints.MinWidth = 320
  OldCreateOrder = False
  ExplicitLeft = 712
  ExplicitTop = 218
  ExplicitHeight = 330
  PixelsPerInch = 96
  TextHeight = 13
  inherited PanelDialog: TPanel
    Width = 312
    Height = 265
    ExplicitWidth = 312
    ExplicitHeight = 265
    object GroupBoxMeasureType: TGroupBox
      Left = 7
      Top = 3
      Width = 298
      Height = 50
      Anchors = [akLeft, akTop, akRight]
      Caption = ' '#1042#1080#1076' '#1080#1079#1084#1077#1088#1077#1085#1080#1103' '
      TabOrder = 0
      DesignSize = (
        298
        50)
      object EditMeasureType: TEdit
        Left = 10
        Top = 19
        Width = 251
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        Color = clBtnFace
        ReadOnly = True
        TabOrder = 0
        OnKeyDown = EditMeasureTypeKeyDown
      end
      object ButtonMeasureType: TButton
        Left = 267
        Top = 19
        Width = 21
        Height = 21
        Hint = #1042#1099#1073#1088#1072#1090#1100' '#1074#1080#1076' '#1080#1079#1084#1077#1088#1077#1085#1080#1103
        Anchors = [akTop, akRight]
        Caption = '...'
        ParentShowHint = False
        ShowHint = True
        TabOrder = 1
        OnClick = ButtonMeasureTypeClick
      end
    end
    object GroupBoxCoordinateZ: TGroupBox
      Left = 7
      Top = 56
      Width = 298
      Height = 51
      Anchors = [akLeft, akTop, akRight]
      Caption = ' '#1054#1090#1084#1077#1090#1082#1072' '
      TabOrder = 1
      object LabelCoordinateZFrom: TLabel
        Left = 38
        Top = 23
        Width = 16
        Height = 13
        Alignment = taRightJustify
        Caption = #1086#1090':'
        FocusControl = EditCoordinateZFrom
      end
      object LabelCoordinateZTo: TLabel
        Left = 158
        Top = 23
        Width = 17
        Height = 13
        Alignment = taRightJustify
        Caption = #1076#1086':'
        FocusControl = EditCoordinateZTo
      end
      object EditCoordinateZFrom: TEdit
        Left = 60
        Top = 20
        Width = 80
        Height = 21
        TabOrder = 0
      end
      object EditCoordinateZTo: TEdit
        Left = 181
        Top = 20
        Width = 80
        Height = 21
        TabOrder = 1
      end
    end
    object GroupBoxObjects: TGroupBox
      Left = 7
      Top = 110
      Width = 298
      Height = 55
      Anchors = [akLeft, akTop, akRight]
      Caption = ' '#1056#1072#1089#1087#1086#1083#1086#1078#1077#1085#1080#1077' '#1086#1073#1098#1077#1082#1090#1072' '
      TabOrder = 2
      DesignSize = (
        298
        55)
      object EditObject: TEdit
        Left = 10
        Top = 24
        Width = 251
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 0
      end
      object ButtonObject: TButton
        Left = 267
        Top = 24
        Width = 21
        Height = 21
        Hint = #1042#1099#1073#1088#1072#1090#1100' '#1086#1073#1098#1077#1082#1090
        Anchors = [akTop, akRight]
        Caption = '...'
        ParentShowHint = False
        ShowHint = True
        TabOrder = 1
        OnClick = ButtonObjectClick
      end
    end
    object GroupBoxParams: TGroupBox
      Left = 7
      Top = 168
      Width = 298
      Height = 95
      Anchors = [akLeft, akTop, akRight, akBottom]
      Caption = ' '#1055#1072#1089#1087#1086#1088#1090#1072' '#1087#1088#1077#1086#1073#1088#1072#1079#1086#1074#1072#1090#1077#1083#1077#1081'  '
      TabOrder = 3
      object PanelParams: TPanel
        Left = 2
        Top = 15
        Width = 294
        Height = 78
        Align = alClient
        BevelOuter = bvNone
        BorderWidth = 5
        TabOrder = 0
        object GridPattern: TDBGrid
          Left = 5
          Top = 5
          Width = 284
          Height = 68
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
  end
  inherited PanelButton: TPanel
    Top = 265
    Width = 312
    ExplicitTop = 265
    ExplicitWidth = 312
    inherited ButtonOk: TButton
      Left = 150
      Top = 8
      ExplicitLeft = 150
      ExplicitTop = 8
    end
    inherited ButtonCancel: TButton
      Left = 232
      Top = 8
      ExplicitLeft = 232
      ExplicitTop = 8
    end
  end
  object DataSource: TDataSource
    Left = 113
    Top = 199
  end
end
