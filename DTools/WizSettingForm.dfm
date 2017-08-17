object frmWizSetting: TfrmWizSetting
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = #19987#23478#35774#32622
  ClientHeight = 179
  ClientWidth = 193
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 16
    Width = 48
    Height = 13
    Caption = #19987#23478#21517#31216
  end
  object Label2: TLabel
    Left = 8
    Top = 41
    Width = 48
    Height = 13
    Caption = #33521#25991#21035#21517
  end
  object Label3: TLabel
    Left = 8
    Top = 66
    Width = 47
    Height = 13
    Caption = 'DLL  '#36335#24452
  end
  object Label4: TLabel
    Left = 8
    Top = 91
    Width = 48
    Height = 13
    Caption = #24555'  '#25463'  '#38190
  end
  object edtWizCaption: TEdit
    Left = 62
    Top = 13
    Width = 121
    Height = 19
    Ctl3D = False
    ParentCtl3D = False
    TabOrder = 0
  end
  object edtWizName: TEdit
    Left = 62
    Top = 38
    Width = 121
    Height = 19
    Ctl3D = False
    ParentCtl3D = False
    TabOrder = 1
  end
  object edtWizDLL: TEdit
    Left = 62
    Top = 63
    Width = 121
    Height = 19
    Color = clGradientInactiveCaption
    Ctl3D = False
    ParentCtl3D = False
    ReadOnly = True
    TabOrder = 2
    OnDblClick = edtWizDLLDblClick
    OnKeyPress = edtWizDLLKeyPress
  end
  object hkWizShortCut: THotKey
    Left = 62
    Top = 88
    Width = 121
    Height = 19
    HotKey = 0
    Modifiers = []
    TabOrder = 3
  end
  object btnSave: TButton
    Left = 8
    Top = 136
    Width = 57
    Height = 25
    Caption = #20445' '#23384
    TabOrder = 4
    OnClick = btnSaveClick
  end
  object btnCancel: TButton
    Left = 88
    Top = 136
    Width = 57
    Height = 25
    Cancel = True
    Caption = #21462'  '#28040
    Default = True
    ModalResult = 2
    TabOrder = 5
  end
  object rbMainMenu: TRadioButton
    Left = 8
    Top = 113
    Width = 74
    Height = 17
    Caption = #20027#33756#21333
    Checked = True
    TabOrder = 6
    TabStop = True
  end
  object rbPopMenu: TRadioButton
    Left = 96
    Top = 113
    Width = 78
    Height = 17
    Caption = #24377#20986#33756#21333
    TabOrder = 7
  end
  object dlgOpen: TOpenDialog
    Filter = #19987#23478#25991#20214#65288'*.dll'#65289'|*.dll'
    Left = 112
    Top = 24
  end
end
