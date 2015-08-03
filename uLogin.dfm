object fmOraLogin: TfmOraLogin
  Left = 0
  Top = 0
  ActiveControl = Password
  BorderStyle = bsDialog
  Caption = 'Oracle Login'
  ClientHeight = 170
  ClientWidth = 272
  Color = clBtnFace
  ParentFont = True
  FormStyle = fsStayOnTop
  OldCreateOrder = True
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object btnLogin: TButton
    Left = 107
    Top = 138
    Width = 75
    Height = 25
    Caption = '&Login'
    Default = True
    ModalResult = 1
    TabOrder = 0
  end
  object btnCancel: TButton
    Left = 188
    Top = 138
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 1
  end
  object pnlDB: TPanel
    Left = 8
    Top = 8
    Width = 257
    Height = 124
    BevelInner = bvRaised
    BevelOuter = bvLowered
    TabOrder = 2
    object lbDB: TLabel
      Left = 10
      Top = 11
      Width = 50
      Height = 13
      Caption = 'Database:'
    end
    object Bevel: TBevel
      Left = 2
      Top = 47
      Width = 254
      Height = 9
      Shape = bsTopLine
    end
    object pnlLogin: TPanel
      Left = 2
      Top = 57
      Width = 253
      Height = 65
      Align = alBottom
      BevelOuter = bvNone
      TabOrder = 2
      object lbName: TLabel
        Left = 8
        Top = 8
        Width = 56
        Height = 13
        Caption = '&User Name:'
        FocusControl = UserName
      end
      object lbPass: TLabel
        Left = 8
        Top = 36
        Width = 50
        Height = 13
        Caption = '&Password:'
        FocusControl = Password
      end
      object UserName: TEdit
        Left = 86
        Top = 5
        Width = 153
        Height = 21
        MaxLength = 31
        TabOrder = 0
      end
      object Password: TEdit
        Left = 86
        Top = 33
        Width = 153
        Height = 21
        MaxLength = 31
        PasswordChar = '*'
        TabOrder = 1
      end
    end
    object Database: TComboBox
      Left = 88
      Top = 8
      Width = 153
      Height = 21
      ItemHeight = 13
      TabOrder = 0
    end
    object chbRemember: TCheckBox
      Left = 88
      Top = 32
      Width = 116
      Height = 13
      Caption = 'remember base'
      Checked = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      State = cbChecked
      TabOrder = 1
    end
  end
end
