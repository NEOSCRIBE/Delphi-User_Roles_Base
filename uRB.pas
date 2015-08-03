unit uRB;

interface

uses SysUtils, Generics.Collections, ADODB, Classes, Dialogs, Variants,
     Grids, Windows;

type

TCharSet = set of Char;

TURConnection = class
  strict private
    Conn: TADOConnection;
    fConnected: boolean;
  private
    procedure SetConnected(const Value: boolean);
  public
    Query: TADOQuery;
    constructor Create(const server, user, pass: string;
      const conStr: string = 'Provider=MSDAORA.1;Password=%s;User ID=%s;Data Source=%s;Persist Security Info=True');
    destructor Destoy;
    procedure Connect;
    procedure Disconnect;
    property Connected: boolean read fConnected write SetConnected;
end;

TRoleItem = packed record
  Role: string;
  RoleValue: integer;
end;

TURoles = array of TRoleItem;

TUser = class
  strict private
    UId: integer;
    UFio: string;
    URoles: TURoles;
  public
    property Id: integer read UId write UId;
    property Fio: string read UFio write UFio;
    property Roles: TURoles read URoles;
    function SetRole(const roleName: string; const roleVal: integer): boolean;
    function DeleteRole(const roleName: string): boolean;
    function GetRoleIndex(const roleName: string): integer;
    function RoleCount: integer;
    constructor Create;
    destructor Destroy;
end;

TUserList = class(TObjectList<TUser>)
    strict private
      FDtLoaded: boolean;
      UConn: TURConnection;
  public
    procedure Clear;
    function GetUserById(const uId: integer):TUser;
    function LoadUsers(var Conn: TURConnection): boolean;
    procedure ShowSelected(const uIndex: integer; rolesGrid: TStringGrid);
    procedure ClearGrid(var rolesGrid: TStringGrid);
    procedure AddRoleRecord(const uIndex: integer; const role: string);
    procedure UpdateRoleRecord(const uIndex: integer; const role: string; const roleVal: integer);
    procedure DeleteRoleRecord(const uIndex: integer; const role: string);
    procedure AddUser(var User: TUser);
    procedure EditUser(const uId: integer; const uFio: string);
    procedure DeleteUser(const uId: integer);
    procedure ClearBase;
    property DataLoaded: boolean read FDtLoaded;
end;

const
  uTableName = 'urUsers';
  rTableName = 'urRoles';

// GLOBAL FUNCTIONS|PROCEDURES
function StripNonNumeric(const S: string): integer;
function StripNonSymbols(const S: string): string;
//
function AddSomeStr(const sourceStr, addStr:string; posMode: integer = 1; position: integer = 0):string;
function DelSomeStr(const sourceStr, delStr: string; mode: integer = 1): string;

implementation

uses uMain;

function StripNonConforming(const S: string;
  const ValidChars: TCharSet): string;
var
  DestI: Integer;
  SourceI: Integer;
begin
  try
    SetLength(Result, Length(S));
    DestI := 0;
    for SourceI := 1 to Length(S) do
      if S[SourceI] in ValidChars then
      begin
        Inc(DestI);
        Result[DestI] := S[SourceI]
      end;
    SetLength(Result, DestI);
  except
    on E: Exception do
    begin
    end;
  end;
end;

function StripNonNumeric(const S: string): integer;
var
  str: string;
begin
  try
    str := StripNonConforming(S, ['0'..'9']);
    if str = '' then
      Result := -1
    else
      Result := round(strtofloat(str));
  except
    on E: Exception do
    begin
      Result := -1;
    end;
  end;
end;

function StripNonSymbols(const S: string): string;
begin
  try
    Result:= StripNonConforming(S, ['A'..'Z','a'..'z']);
  except
    on E: Exception do
    begin
      Result:= '';
    end;
  end;
end;

// Modes 1 - To end, 2 - To position

function AddSomeStr(const sourceStr, addStr:string; posMode: integer = 1; position: integer = 0):string;
var
  sStr: string;
begin
  case posMode of
    1:begin
      result:= sourceStr + addStr;
    end;
    2:begin
      sStr:= sourceStr;
      insert(addStr, sStr, position);
      Result:= sStr;
    end;
    else
      result:= sourceStr + addStr;
  end;
end;

// Modes 1 - First conformity 2 - all conformities

function DelSomeStr(const sourceStr, delStr: string; mode: integer = 1): string;
begin
  case mode of
    1:begin
      result:= stringreplace(sourceStr, delStr, '', [rfIgnoreCase]);
    end;
    2:begin
      result:= stringreplace(sourceStr, delStr, '', [rfReplaceAll, rfIgnoreCase]);
    end;
    else
      result:= stringreplace(sourceStr, delStr, '', [rfIgnoreCase]);
  end;
end;

{ TUser }

function TUser.SetRole(const roleName: string; const roleVal: integer): boolean;
var
  roleMax, i: integer;
begin
  try
    result:= false;
    roleMax:= High(URoles);
    for i := 0 to roleMax do
    begin
      if URoles[i].Role = roleName then
      begin
        URoles[i].RoleValue:= roleVal;
        result:= true;
        exit;
      end;
    end;
    SetLength(URoles, Length(URoles) + 1);
    URoles[High(URoles)].Role:= roleName;
    URoles[High(URoles)].RoleValue:= roleVal;
    result:= true;
  except on E: Exception do
  begin
    result:= false;
  end;
  end;
end;

function TUser.RoleCount: integer;
begin
  result:= -1;
  try
    result:= Length(Roles);
  except on E: Exception do
    result:= -1;
  end;
end;

constructor TUser.Create;
begin
  inherited Create;
  SetLength(URoles, 0);
end;

function TUser.DeleteRole(const roleName: string): boolean;
var
  roleMax, i: integer;
  roleItem: TRoleItem;
begin
  try
    result:= false;
    roleMax:= High(URoles);
    roleItem:= URoles[roleMax];
    for i := 0 to roleMax do
    begin
      if URoles[i].Role = roleName then
      begin
        if URoles[i].Role = roleItem.Role then
          SetLength(URoles, Length(URoles) - 1)
        else
        begin
          URoles[i]:= roleItem;
          SetLength(URoles, Length(URoles) - 1);
        end;
        result:= true;
        exit;
      end;
    end;
  except on E: Exception do
  begin
    result:= false;
  end;
  end;
end;

destructor TUser.Destroy;
begin
  SetLength(URoles, 0);
  inherited Destroy;
end;

function TUser.GetRoleIndex(const roleName: string): integer;
var
  i: integer;
begin
  result:= -1;
  for i := 0 to High(URoles) do
  begin
    if URoles[i].Role = roleName then
      result:= i;
  end;
end;

{ TUserList }

procedure TUserList.AddRoleRecord(const uIndex: integer; const role: string);
begin
  if UConn.Connected then
  begin
    try
      uConn.Query.Active:= false;
      uConn.Query.SQL.Clear;
      uConn.Query.SQL.Text:= 'SELECT role FROM ' + rTableName +
                            ' WHERE U_ID=' + inttostr(self[uIndex].Id) +
                            ' AND ROLE=''' + role + '''';
      uConn.Query.Active:= true;

      if uConn.Query.Fields[0].AsString = '' then
      begin
        try
          Uconn.Query.Active:= false;
          UConn.Query.SQL.Clear;
          UConn.Query.SQL.Text:= 'INSERT INTO ' + rTableName + ' (u_id, role, roleValue) VALUES(' +
                                  inttostr(self[uIndex].Id) + ', ''' + role + ''', 0)';
          UConn.Query.ExecSQL;
          if uConn.Query.RowsAffected > 0 then
            ShowMessage('Role successfully added.')
          else
          begin
            ShowMessage('Something wrong happened while adding role.');
            Exit;
          end;
          self[uIndex].SetRole(role, 0);
        except on E: Exception do
          ShowMessage('Error while adding role with: ' + E.Message);
        end;
      end
      else
        ShowMessage('Error, role already exists.');
    except on E: Exception do
    begin
      ShowMessage('Error while adding role with: ' + E.Message);
    end;
    end;
  end;
end;

procedure TUserList.AddUser(var User: TUser);
var
  maxId: integer;
begin
  if Assigned(uConn) and uConn.Connected then
  begin
    try
      uConn.Query.Active:= false;
      uConn.Query.SQL.Clear;
      uConn.Query.SQL.Text:= 'SELECT MAX(id)id FROM ' + uTableName;
      uConn.Query.Active:= true;

      maxId:= uConn.Query.Fields[0].AsInteger;

      uConn.Query.Active:= false;
      uConn.Query.SQL.Clear;
      uConn.Query.SQL.Text:= 'INSERT into ' + uTableName + ' (id, fio) VALUES(' + inttostr(maxId + 1)  + ', ''' + User.Fio + ''')';
      uConn.Query.ExecSQL;
      if uConn.Query.RowsAffected > 0 then
        ShowMessage('User successfully added.')
      else
        ShowMessage('Something wrong happened while adding user.')
    except on E: Exception do
      ShowMessage('Error while adding user with: ' + E.Message);
    end;
  end;
end;

procedure TUserList.Clear;
begin
  FDtLoaded:= false;
  inherited Clear;
end;

procedure TUserList.ClearBase;
begin
if UConn.Connected then
  begin
    try
      //users
      Uconn.Query.Active:= false;
      UConn.Query.SQL.Clear;
      UConn.Query.SQL.Text:= 'DROP TABLE ' + uTableName ;
      UConn.Query.ExecSQL;
      //roles
      Uconn.Query.Active:= false;
      UConn.Query.SQL.Clear;
      UConn.Query.SQL.Text:= 'DROP TABLE ' + rTableName ;
      UConn.Query.ExecSQL;
    except on E: Exception do
    begin
      ShowMessage('Error while clearing base with: ' + E.Message);
      Exit;
    end;
    end;
  end;
end;

procedure TUserList.ClearGrid(var rolesGrid: TStringGrid);
var
  I: Integer;
begin
  for I := 0 to rolesGrid.RowCount - 1 do
    rolesGrid.Rows[I].Clear();
end;

procedure TUserList.DeleteRoleRecord(const uIndex: integer; const role: string);
begin
  if UConn.Connected then
  begin
    try
      Uconn.Query.Active:= false;
      UConn.Query.SQL.Clear;
      UConn.Query.SQL.Text:= 'DELETE FROM ' + rTableName +
                            ' WHERE U_ID=' + inttostr(self[uIndex].Id) +
                            ' AND ROLE=''' + role + '''';
      UConn.Query.ExecSQL;
      if uConn.Query.RowsAffected > 0 then
        ShowMessage('Role successfully deleted.')
      else
      begin
        ShowMessage('Something wrong happened while adding role.');
        Exit;
      end;
      self[uIndex].DeleteRole(role);
    except on E: Exception do
    begin
      ShowMessage('Update record error with: ' + E.Message);
    end;
    end;
  end;
end;

procedure TUserList.DeleteUser(const uId: integer);
begin
  if Assigned(uConn) and uConn.Connected then
  begin
    try
      // deleting user
      uConn.Query.Active:= false;
      uConn.Query.SQL.Clear;
      uConn.Query.SQL.Text:= 'DELETE FROM ' + uTableName + ' WHERE id=' + inttostr(uId);
      uConn.Query.ExecSQL;
      if uConn.Query.RowsAffected > 0 then
        ShowMessage('User successfully deleted.')
      else
      begin
        ShowMessage('Something wrong happened while deleting user.');
        Exit;
      end;
      // deleting all roles of this user
      uConn.Query.Active:= false;
      uConn.Query.SQL.Clear;
      uConn.Query.SQL.Text:= 'DELETE FROM ' + rTableName + ' WHERE u_id=' + inttostr(uId);
      uConn.Query.ExecSQL;
      if uConn.Query.RowsAffected > 0 then
        ShowMessage('Role successfully deleted.')
      else
      begin
        ShowMessage('Something wrong happened while deleting role.');
        Exit;
      end;
    except on E: Exception do
      ShowMessage('Error while deleting user with: ' + E.Message);
    end;
  end;
end;

procedure TUserList.EditUser(const uId: integer; const uFio: string);
begin
  if Assigned(uConn) and uConn.Connected then
  begin
    try
      // если все ок, обновляем негодяя=)
      uConn.Query.Active:= false;
      uConn.Query.SQL.Clear;
      uConn.Query.SQL.Text:= 'UPDATE ' + uTableName + ' SET fio=''' + uFio + ''' WHERE id=' + inttostr(uId);
      uConn.Query.ExecSQL;
      if uConn.Query.RowsAffected > 0 then
        ShowMessage('User successfully edited.')
      else
      begin
        ShowMessage('Something wrong happened while editing user.');
        Exit;
      end;
    except on E: Exception do
      ShowMessage('Error while changing user with: ' + E.Message);
    end;
  end;
end;

function TUserList.GetUserById(const uId: integer): TUser;
var
  i: Integer;
begin
  result:= nil;
  for i := 0 to self.Count - 1 do
  begin
    if self[i].Id = uId then
      result:= self[i];
  end;
end;

// Загрузка данных, если таких таблиц нет, то они будут созданы.

function TUserList.LoadUsers(var Conn: TURConnection): boolean;
var
  i: Integer;
  uInfo: TUser;
begin
  UConn:= Conn;
  if Conn.Connected then
  begin
    try
      Conn.Query.Active:= false;
      Conn.Query.SQL.Clear;
      Conn.Query.SQL.Text:= 'SELECT id, fio FROM ' + uTableName + ' ORDER BY id';
      Conn.Query.Active:= true;
      Conn.Query.First;
      while not Conn.Query.EOF do
      begin
        uInfo:= TUser.Create;
        uInfo.Id:= Conn.Query.Fields[0].AsInteger;
        uInfo.Fio:= Conn.Query.Fields[1].AsString;
        self.Add(uInfo);
        Conn.Query.Next;
      end;
      try
        Conn.Query.Active:= false;
        Conn.Query.SQL.Clear;
        Conn.Query.SQL.Text:= 'SELECT u_id, role, roleValue FROM ' + rTableName + ' order by u_id';
        Conn.Query.Active:= true;
        Conn.Query.First;
        while not Conn.Query.EOF do
        begin
          for i := 0 to self.Count - 1 do
          begin
            if self[i].Id = Conn.Query.Fields[0].AsInteger then
            begin
              self[i].SetRole(Conn.Query.Fields[1].AsString, Conn.Query.Fields[2].asInteger);
            end;
          end;
          Conn.Query.Next;
        end;
      except on E: Exception do
      begin
        if pos('ORA-00942', E.Message) > 0 then
        begin
          try
            Conn.Query.Active:= false;
            Conn.Query.SQL.Clear;
            Conn.Query.SQL.Text:= 'CREATE table ' + rTableName + ' (u_id number, role varchar2(255), roleValue number)';
            Conn.Query.ExecSQL;
            FDtLoaded:= true;
            result:= true;
          except on E: Exception do
          begin
            FDtLoaded:= false;
            result:= false;
            ShowMessage('Can''t create table with error: ' + E.Message);
          end;
          end;
        end
        else
        begin
          ShowMessage('Something wrong with: ' + E.Message);
        end;
      end;
      end;
      FDtLoaded:= true;
      result:= true;
    except on E: Exception do
    begin
      if pos('ORA-00942', E.Message) > 0 then
      begin
        try
          Conn.Query.Active:= false;
          Conn.Query.SQL.Clear;
          Conn.Query.SQL.Text:= 'CREATE table ' + uTableName + ' (id number, fio varchar2(255))';
          Conn.Query.ExecSQL;
          FDtLoaded:= true;
          result:= true;
        except on E: Exception do
        begin
          FDtLoaded:= false;
          result:= false;
          ShowMessage('Can''t create table with error: ' + E.Message);
        end;
        end;
      end
      else
      begin
        ShowMessage('Something wrong with: ' + E.Message);
      end;
    end;
    end;
  end;
end;

procedure TUserList.ShowSelected(const uIndex: integer; rolesGrid: TStringGrid);
var
  i: Integer;
begin
  self.ClearGrid(rolesGrid);
  rolesGrid.RowCount:= 0;
  for i := 0 to length(self[uIndex].Roles) - 1 do
  begin
    rolesGrid.Cells[0, i]:=self[uIndex].Roles[i].Role;
    rolesGrid.Cells[1, i]:=inttostr(self[uIndex].Roles[i].RoleValue);
    rolesGrid.RowCount:= rolesGrid.RowCount + 1;
  end;
  rolesGrid.RowCount:= rolesGrid.RowCount - 1;
end;

procedure TUserList.UpdateRoleRecord(const uIndex: integer; const role: string;
  const roleVal: integer);
begin
  if UConn.Connected then
  begin
    try
      Uconn.Query.Active:= false;
      UConn.Query.SQL.Clear;
      UConn.Query.SQL.Text:= 'UPDATE ' + rTableName + ' SET ROLEVALUE='+ inttostr(roleVal) +
                            ' WHERE U_ID=' + inttostr(self[uIndex].Id) +
                            ' AND ROLE=''' + role + '''';
      UConn.Query.ExecSQL;
      self[uIndex].SetRole(role, roleVal);
    except on E: Exception do
    begin
      ShowMessage('Update record error with: ' + E.Message);
    end;
    end;
  end;
end;

{ TURConnection }

procedure TURConnection.Connect;
begin
  Conn.Connected:= true;
  fConnected:= Conn.Connected;
end;

constructor TURConnection.Create(const server, user, pass: string;
  const conStr: string = 'Provider=MSDAORA.1;Password=%s;User ID=%s;Data Source=%s;Persist Security Info=True');
begin
  inherited Create;
  try
    Conn:= TADOConnection.Create(nil);
    Conn.ConnectionString:= Format(conStr, [pass, user, server]);
    Conn.LoginPrompt:= false;
    Query:= TADOQuery.Create(nil);
    Query.Connection:= Conn;
  except on E: Exception do
    Destoy;
  end;
end;

destructor TURConnection.Destoy;
begin
  Query.Close;
  Conn.Close;
  Query.Free;
  Conn.Free;
  inherited Destroy;
end;

procedure TURConnection.Disconnect;
begin
  Conn.Connected:= false;
  fConnected:= Conn.Connected;
end;

procedure TURConnection.SetConnected(const Value: boolean);
begin
  try
    Conn.Connected:= Value;
    fConnected := Conn.Connected;
  except on E: Exception do
  begin
    Conn.Connected:= false;
    fConnected := Conn.Connected;
  end;
  end;
end;

end.
