{
  @Test Programm "User Roles" v0.1 alfa

  @author: SCRIBE (Volodymyr Sedler)
  @date: 24.06.2015
  @contacts: skype: neo-scribe; e-mail: justscribe@yahoo.com
}

unit uMain;

interface

uses
  Windows, SysUtils, Forms, Menus, Grids, StdCtrls, Controls, Classes, Dialogs,
  TypInfo, Variants,
  // Classes units
  uRB, uLogin;

type
  TfmMain = class(TForm)
    gbUsers: TGroupBox;
    lbUsers: TListBox;
    gbRoles: TGroupBox;
    sgRoles: TStringGrid;
    mmMain: TMainMenu;
    mmFile: TMenuItem;
    mmExit: TMenuItem;
    mmInit: TMenuItem;
    mmConnect: TMenuItem;
    pmUsers: TPopupMenu;
    piUAdd: TMenuItem;
    piUDelete: TMenuItem;
    piUEdit: TMenuItem;
    pmRoles: TPopupMenu;
    piRAdd: TMenuItem;
    piRDelete: TMenuItem;
    mmClear: TMenuItem;
    procedure mmExitClick(Sender: TObject);
    procedure mmConnectClick(Sender: TObject);
    procedure mmInitClick(Sender: TObject);
    procedure lbUsersClick(Sender: TObject);
    procedure sgRolesSetEditText(Sender: TObject; ACol, ARow: Integer;
      const Value: string);
    procedure sgRolesGetEditText(Sender: TObject; ACol, ARow: Integer;
      var Value: string);
    procedure FormResize(Sender: TObject);
    procedure sgRolesSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure sgRolesExit(Sender: TObject);
    procedure piUDeleteClick(Sender: TObject);
    procedure piUAddClick(Sender: TObject);
    procedure piUEditClick(Sender: TObject);
    procedure piRDeleteClick(Sender: TObject);
    procedure piRAddClick(Sender: TObject);
    procedure mmClearClick(Sender: TObject);
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    strict private
      FUserList: TUserList;
      sgEditing: boolean;
      sgECol, sgERow: integer;
      sgEVal, sgOVal: string;
    public
      Connection: TURConnection;
      procedure LoadUserList(var list: TListBox);
      property Users: TUserList read FUserList;
  end;

var
  fmMain: TfmMain;

implementation

{$R *.dfm}

// Creating object "list of users".

constructor TfmMain.Create(AOwner: TComponent);
begin
  inherited;
  FUserList:= TUserList.Create();
end;

// Simple rule, if this created by you, THEN YOU MUST DESTROY THIS=)

destructor TfmMain.Destroy;
begin
  FUserList.Free;
  Connection.Free;
  inherited;
end;

// Resizing

procedure TfmMain.FormResize(Sender: TObject);
begin
  sgRoles.DefaultColWidth:= sgRoles.ClientWidth div 2;
end;

// Showing the roles of selected user

procedure TfmMain.lbUsersClick(Sender: TObject);
begin
  if (lbUsers.ItemIndex >= 0) and (lbUsers.ItemIndex <= lbUsers.Count - 1) then
  begin
    Users.ShowSelected(lbUsers.ItemIndex, sgRoles);
  end;
end;

// Load and view the list of users

procedure TfmMain.LoadUserList(var list: TListBox);
var
  I: Integer;
begin
  if Assigned(Users) and Users.DataLoaded then
  begin
    list.Items.BeginUpdate;
    list.Clear;
    Users.Clear;
    list.Items.EndUpdate;
  end;
  if Assigned(Connection) and Connection.Connected and Users.LoadUsers(Connection) then
  begin
    list.Items.BeginUpdate;
    for I := 0 to Users.Count - 1 do
      list.Items.Insert(I, Users[i].Fio);
    list.Items.EndUpdate;
  end;
end;

// Connecting to base

procedure TfmMain.mmClearClick(Sender: TObject);
var
  reply: word;
begin
  Screen.Cursor:= crSQLWait;
  try
    if not Assigned(Connection) or not Connection.Connected or not Users.DataLoaded then
      Exit;
    reply := MessageBox(handle,PChar('Confirm clearing base?'+#13#10), PChar('Clear base'), 36);
    if reply = IDYES then
    begin
      Users.ClearBase;
      mmConnect.Click;
    end;
    if reply = IDNO then
      Exit;
  finally
    Screen.Cursor:= crDefault;
  end;
end;

procedure TfmMain.mmConnectClick(Sender: TObject);
var
  db, name, pass: string;
begin
  Screen.Cursor:= crSQLWait;
  try
    if not Assigned(Connection) or not Connection.Connected then
    begin
      if OracleLoginDialog(db, name, pass) then
      begin
        Connection:= TURConnection.Create(db, name, pass);
      end
      else
        Exit;
    end;
    mmConnect.Checked:= not mmConnect.Checked;
    case mmConnect.Checked of
      true:
      try
        Connection.Connect;
        Users.ClearGrid(sgRoles);
        lbUsers.Clear;
        Users.Clear;
        fmMain.Caption:= AddSomeStr(fmMain.Caption, ' - connected');
      except on E: Exception do
      begin
        mmConnect.Checked:= false;
        ShowMessage('Error while connecting with: ' + E.Message);
      end;
      end
      else
      try
        Connection.Disconnect;
        Users.ClearGrid(sgRoles);
        lbUsers.Clear;
        Users.Clear;
        fmMain.Caption:= DelSomeStr(fmMain.Caption, ' - connected');
      except on E: Exception do
      begin
        mmConnect.Checked:= false;
        ShowMessage('Error while disconnecting with: ' + E.Message);
      end;
      end;
    end;
  finally
    Screen.Cursor:= crDefault;
  end;
end;

procedure TfmMain.mmExitClick(Sender: TObject);
begin
  fmMain.Close;
end;

// Loading user list

procedure TfmMain.mmInitClick(Sender: TObject);
begin
  LoadUserList(lbUsers);
end;

// Add role

procedure TfmMain.piRAddClick(Sender: TObject);
var
  reply: boolean;
  replyW: word;
  uRole: string;
  uSelected: integer;
begin
  if Assigned(Connection) and Connection.Connected and Users.DataLoaded and (lbUsers.Count > 0) then
  begin
    uSelected:= lbUsers.ItemIndex;
    reply:= InputQuery( 'Add new role', 'Please enter the name of new role for user "' + Users[uSelected].Fio + '":', uRole);
    if not reply then
    begin
      Exit;
    end
    else
    begin
      uRole:= StripNonSymbols(uRole);
      if uRole <> '' then
      begin
        replyW := MessageBox(handle,PChar('Add role with filtered name: ' + uRole + '?' + #13#10), PChar('Add new role'), 36);
        if replyW = IDYES then
        begin
          Users.AddRoleRecord(uSelected, uRole);
          lbUsers.ItemIndex:= uSelected;
          Users.ShowSelected(uSelected, sgRoles);
          //LoadUserList(lbUsers);
        end;
        if replyW = IDNO then
          Exit;
      end
      else
        ShowMessage('Role has not been added due to incorrect name!');
    end;
  end;
end;

// Delete role

procedure TfmMain.piRDeleteClick(Sender: TObject);
var
  reply: word;
  uSelected: integer;
begin
  if Assigned(Connection) and Connection.Connected and Users.DataLoaded and (lbUsers.Count > 0) then
  begin
    uSelected:= lbUsers.ItemIndex;
    reply := MessageBox(handle,PChar('Confirm deleting role "' + sgRoles.Cells[0, sgRoles.Row] +'" of user "'+ Users[uSelected].Fio +'"?'+#13#10), PChar('Delete role'), 36);
    if reply = IDYES then
    begin
      Users.DeleteRoleRecord(uSelected, sgRoles.Cells[0, sgRoles.Row]);
      //LoadUserList(lbUsers);
      lbUsers.ItemIndex:= uSelected;
      Users.ShowSelected(uSelected, sgRoles);
    end;
    if reply = IDNO then
      Exit;
  end;
end;

// Add user

procedure TfmMain.piUAddClick(Sender: TObject);
var
  mUser: TUser;
  reply: boolean;
  replyW: word;
  uFio: string;
begin
  if Assigned(Connection) and Connection.Connected and Users.DataLoaded then
  begin
    mUser:= tUser.Create;
    reply:= InputQuery( 'Add new user', 'Please enter the name of new user:', uFio);
    if not reply then
    begin
      mUser.Free;
      Exit;
    end
    else
    begin
      uFio:= StripNonSymbols(uFio);
      if uFio <> '' then
      begin
        replyW := MessageBox(handle,PChar('Add user with filtered name: ' + uFio + '?' + #13#10), PChar('Add new user'), 36);
        if replyW = IDYES then
        begin
          mUser.Fio:= uFio;
          Users.AddUser(mUser);
          LoadUserList(lbUsers);
        end;
        if replyW = IDNO then
          Exit;
      end
      else
        ShowMessage('User has not been added due to incorrect name!');
    end;
  end;
end;

// Delete user

procedure TfmMain.piUDeleteClick(Sender: TObject);
var
  reply: word;
begin
  if Assigned(Connection) and Connection.Connected and Users.DataLoaded and (lbUsers.Count > 0) then
  begin
    reply:= MessageBox(handle,PChar('Confirm deleting user "' +
           Users[lbUsers.ItemIndex].Fio + '"'+#13#10), PChar('Delete user'), 36);
    if reply = IDYES then
    begin
      Users.DeleteUser(Users[lbUsers.ItemIndex].Id);
      LoadUserList(lbUsers);
    end;
    if reply = IDNO then
      Exit;
  end;
end;

// Edit user

procedure TfmMain.piUEditClick(Sender: TObject);
var
  reply: boolean;
  replyW: word;
  uFio: string;
begin
  if Assigned(Connection) and Connection.Connected and Users.DataLoaded and (lbUsers.Count > 0) then
  begin
    reply:= InputQuery('Edit user', 'Please enter the new name of user "' + Users[lbUsers.ItemIndex].Fio + '" :', uFio);
    if not reply then
    begin
      Exit;
    end
    else
    begin
      uFio:= StripNonSymbols(uFio);
      if uFio <> '' then
      begin
        replyW := MessageBox(handle,PChar('Change user with filtered name: ' + uFio + '?' + #13#10), PChar('Edit user'), 36);
        if replyW = IDYES then
        begin
          Users[lbUsers.ItemIndex].Fio:= uFio;
          Users.EditUser(Users[lbUsers.ItemIndex].Id, Users[lbUsers.ItemIndex].Fio);
          LoadUserList(lbUsers);
        end;
        if replyW = IDNO then
          Exit;
      end
      else
        ShowMessage('User name has not been changed due to incorrect one!');
    end;
  end;
end;

// Committing changes if grid lost focus and value has been edited.

procedure TfmMain.sgRolesExit(Sender: TObject);
begin
  if sgEditing then
  begin
    sgEditing:= false;
    Users.UpdateRoleRecord(lbUsers.ItemIndex, sgRoles.Cells[0, sgERow], strtoint(sgEVal));
  end;
end;

// Preventing value to be empty

procedure TfmMain.sgRolesGetEditText(Sender: TObject; ACol, ARow: Integer;
  var Value: string);
begin
  if Value='' then
    Exit;
  sgOVal:= Value;
end;

// If select another cell, committing changes

procedure TfmMain.sgRolesSelectCell(Sender: TObject; ACol, ARow: Integer;
  var CanSelect: Boolean);
begin
  if (ACol <> sgECol) or (ARow <> sgERow) then
  begin
    CanSelect:= true;
    if sgEditing then
    begin
      sgEditing:= false;
      Users.UpdateRoleRecord(lbUsers.ItemIndex, sgRoles.Cells[0, sgERow], strtoint(sgEVal));
    end;
  end;
end;

// Preventing value to be empty, setting the flag of "editing mode"

procedure TfmMain.sgRolesSetEditText(Sender: TObject; ACol, ARow: Integer;
  const Value: string);
begin
  if Value='' then
    Exit;
  if Assigned(Connection) and Connection.Connected and Users.DataLoaded and (lbUsers.Count > 0) then
  begin
    if (Value = sgEVal) and (ACol = sgECol) and (ARow = sgERow) or (Value = sgOVal) then
      Exit;
    sgEditing:= true;
    sgECol:= ACol;
    sgERow:= ARow;
    sgEVal:= inttostr(StripNonNumeric(Value));
  end
  else
  begin
    sgEditing:= false;
    Exit;
  end;
end;

end.
