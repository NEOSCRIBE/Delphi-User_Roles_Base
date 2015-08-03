{
  Module "Oracle Login Dialog"

  @author: SCRIBE (Volodymyr Sedler)
  @date: 24.06.2015
  @contacts: skype: neo-scribe; e-mail: justscribe@yahoo.com
  @point: AlfaBank

  Using:
  ---------------EXAMPLE---------------
  uses uLogin;

  procedure TForm1.ConnectClick(Sender: TObject);
  var
    conString, db, name, pass: string;
  begin
    if OracleLoginDialog(db, name, pass) then
    begin
      conString := 'Provider=MSDAORA.1;Password=%s;User ID=%s;Data Source=%s;Persist Security Info=True';
      ADOConnection1.ConnectionString:= Format(conString, [pass, name, db]);
      ADOConnection1.LoginPromt:= false;
      try
        ADoConnection1.Connected:= true;
      except
      on E: EADOError do
        ShowMessage('Error with: ' + E.Message);
      end
    end
    else
      Exit;
  end;
  -------------------------------------
}


unit uLogin;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Registry, StdCtrls, ExtCtrls;

type
  TfmOraLogin = class(TForm)
    Database: TComboBox;
    chbRemember: TCheckBox;
    btnLogin: TButton;
    btnCancel: TButton;
    pnlDB: TPanel;
    lbDB: TLabel;
    Bevel: TBevel;
    pnlLogin: TPanel;
    lbName: TLabel;
    lbPass: TLabel;
    UserName: TEdit;
    Password: TEdit;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    tnsnamesPath: string;
    FTNSExists, FLoaded, FRemember: boolean;
    baseList: TStringList;
    function GetSelectedBase: string;
    procedure SetSelectedBase(const Value: string);
    procedure SetRememberBase(const Value: boolean);
    function GetRememberBase: boolean;
  public
    property TNSExists: boolean read FTNSExists;
    property BaseLoaded: boolean read FLoaded;
    property SelectedBase: string read GetSelectedBase write SetSelectedBase;
    property RememberBase: boolean read GetRememberBase write SetRememberBase;
  end;

const
  regName = 'OracleLogin';

function OracleLoginDialog(var ADatabase, AUserName, APassword: string): Boolean;

implementation

{$R *.dfm}

function OracleLoginDialog(var ADatabase, AUserName, APassword: string): Boolean;
begin
  with TfmOraLogin.Create(Application) do
  try
    if BaseLoaded then
      Database.Items.Assign(baseList);
    chbRemember.Checked:= RememberBase;
    if chbRemember.Checked then
      Database.Text:= SelectedBase;
    if ADatabase <> '' then
      Database.SelText:= ADatabase;
    UserName.Text := AUserName;
    Result := False;
    if AUserName = '' then ActiveControl := UserName;
    if ShowModal = mrOk then
    begin
      ADatabase := Database.Text;
      AUserName := UserName.Text;
      APassword := Password.Text;
      RememberBase:= chbRemember.Checked;
      SelectedBase:= Database.Text;
      Result := True;
    end;
  finally
    Free;
  end;
end;

procedure TfmOraLogin.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action:= caFree;
end;

procedure TfmOraLogin.FormCreate(Sender: TObject);
var
  reg: TRegistry;
  tnsFile: TextFile;
  line: string;
begin
  reg:= TRegistry.Create(KEY_READ);
  try
    reg.RootKey:= HKEY_LOCAL_MACHINE;
    if reg.OpenKeyReadOnly('\SOFTWARE\oracle') then
    begin
      tnsnamesPath:= reg.ReadString('ORACLE_HOME') + '\network\admin\tnsnames.ora';
      if FileExists(tnsnamesPath) then
      begin
        FTNSExists:= true;
        AssignFile(tnsFile, tnsnamesPath);
        baseList:= TStringList.Create;
        {$I-}
        try
          Reset(tnsFile);
          while not EOF(tnsFile) and (IOResult = 0) do
          begin
            readln(tnsFile, line);
            if (pos('#', line) = 0) and (pos('(', line) = 0) and (pos(')', line) = 0) and (pos('=', line) > 0) then
            begin
              //line:= trim(StringReplace(copy(line, 1, pos('.', line) - 1), '=', '', [rfReplaceAll, rfIgnoreCase]));
              line:= trim(StringReplace(line, '=', '', [rfReplaceAll, rfIgnoreCase]));
              baseList.Add(line);
            end;
          end;
          if baseList.Count > 0 then
            FLoaded:= true
          else
            FLoaded:= false;
        finally
          {$I+}
          CloseFile(tnsFile);
        end;
      end
      else
      begin
        FTNSExists:= false;
        FLoaded:= false;
      end;
    end
    else
    begin
      FTNSExists:= false;
      FLoaded:= false;
      MessageBox(handle,PChar('Can''t get data from Windows Registry!'+#13#10), PChar('Error'), 16);
      Exit;
    end;
  finally
    reg.CloseKey;
    reg.Free;
  end;
end;

procedure TfmOraLogin.FormDestroy(Sender: TObject);
begin
  baseList.Free;
end;

function TfmOraLogin.GetRememberBase: boolean;
var
  reg: TRegistry;
begin
  result:= false;
  reg:= TRegistry.Create;
  try
    reg.RootKey:= HKEY_CURRENT_USER;
    if reg.OpenKeyReadOnly('\SOFTWARE\' + regName) then
    begin
      result:= reg.ReadBool('RememberBase');
    end
    else
    begin
      MessageBox(handle,PChar('Can''t get data from Windows Registry!'+#13#10), PChar('Error'), 16);
      Exit;
    end;
  finally
    reg.CloseKey;
    reg.Free;
  end;
end;

function TfmOraLogin.GetSelectedBase: string;
var
  reg: TRegistry;
begin
  result:= '';
  reg:= TRegistry.Create(KEY_READ);
  try
    reg.RootKey:= HKEY_CURRENT_USER;
    if reg.OpenKeyReadOnly('\SOFTWARE\' + regName) then
    begin
      result:= reg.ReadString('SelectedBase');
    end
    else
    begin
      MessageBox(handle,PChar('Can''t get data from Windows Registry!'+#13#10), PChar('Error'), 16);
      Exit;
    end;
  finally
    reg.CloseKey;
    reg.Free;
  end;
end;

procedure TfmOraLogin.SetRememberBase(const Value: boolean);
var
  reg: TRegistry;
begin
  FRemember:= false;
  reg:= TRegistry.Create;
  try
    reg.RootKey:= HKEY_CURRENT_USER;
    if not reg.KeyExists('\SOFTWARE\' + regName) then
    begin
      if reg.CreateKey('\SOFTWARE\' + regName) then
      begin
        reg.OpenKey('\SOFTWARE\' + regName, true);
        reg.WriteBool('RememberBase', Value);
      end
      else
      begin
        MessageBox(handle,PChar('Can''t write data to Windows Registry!'+#13#10), PChar('Error'), 16);
        Exit;
      end;
    end
    else
    begin
      try
        reg.OpenKey('\SOFTWARE\' + regName, true);
        reg.WriteBool('RememberBase', Value);
      except on E: Exception do
      begin
        MessageBox(handle,PChar('Erroe write data to Windows Registry with: ' + E.Message + #13#10), PChar('Error'), 16);
        Exit;
      end;
      end;
    end;
  finally
    reg.CloseKey;
    reg.Free;
  end;
  FRemember := Value;
end;

procedure TfmOraLogin.SetSelectedBase(const Value: string);
var
  reg: TRegistry;
begin
  reg:= TRegistry.Create;
  try
    reg.RootKey:= HKEY_CURRENT_USER;
    if not reg.KeyExists('\SOFTWARE\' + regName) then
    begin
      if reg.CreateKey('\SOFTWARE\' + regName) then
      begin
        reg.OpenKey('\SOFTWARE\' + regName, true);
        reg.WriteString('SelectedBase', Value);
      end
      else
      begin
        MessageBox(handle,PChar('Can''t write data to Windows Registry!'+#13#10), PChar('Error'), 16);
        Exit;
      end;
    end
    else
    begin
      reg.OpenKey('\SOFTWARE\' + regName, true);
      reg.WriteString('SelectedBase', Value);
    end;
  finally
    reg.CloseKey;
    reg.Free;
  end;
end;

end.
