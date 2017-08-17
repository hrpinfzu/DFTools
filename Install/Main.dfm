object frmMain: TfrmMain
  Left = 0
  Top = 0
  Caption = 'DTools'#31649#29702#24037#20855
  ClientHeight = 76
  ClientWidth = 246
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  PixelsPerInch = 96
  TextHeight = 13
  object btnInstall: TButton
    Left = 16
    Top = 40
    Width = 75
    Height = 25
    Caption = 'Install'
    TabOrder = 0
    OnClick = btnInstallClick
  end
  object btnUninstall: TButton
    Left = 105
    Top = 40
    Width = 75
    Height = 25
    Caption = 'Uninstall'
    TabOrder = 1
    OnClick = btnUninstallClick
  end
  object cbbDelphiVer: TComboBox
    Left = 16
    Top = 8
    Width = 164
    Height = 21
    ItemIndex = 1
    TabOrder = 2
    Text = 'Delphi 2010'
    Items.Strings = (
      'Delphi 2007'
      'Delphi 2010')
  end
end
