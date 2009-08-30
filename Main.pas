unit Main;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, StdCtrls, ShellAPI, ExtCtrls, Buttons, ToolWin, Psapi;

const
  WM_TASKICON = WM_USER + 300;

type
  TFormMain = class(TForm)
    ListViewMain: TListView;
    Panel1: TPanel;
    ButtonShow: TButton;
    ButtonRefresh: TButton;
    Button1: TButton;
    Button2: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure SpeedButtonRefreshClick(Sender: TObject);
    procedure ButtonShowClick(Sender: TObject);
    procedure ButtonRefreshClick(Sender: TObject);
    procedure ListViewMainDblClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    TaskIcon: TIcon;
    NotifyIconData: TNotifyIconData;
    procedure ApplicationMinimize(Sender: TObject);
    procedure ShowSelectedWindows(Show: Boolean);
    procedure BuildList;
    procedure ShowSplash;
  public
  protected
    procedure WMTaskIcon(var Message: TMessage); message WM_TASKICON;
  end;

var
  FormMain: TFormMain;

implementation

{$R *.DFM}

uses
  Splash;

// http://www.delphitricks.com/source-code/windows/get_exe_path_from_window_handle.html

function EnumWindowsProcx(hHwnd: HWND; lParam : integer): boolean; stdcall;
var
  pPid : DWORD;
  title, ClassName : string;
  NewItem: TListItem;

begin
    GetWindowThreadProcessId(hHwnd,pPid);
    //set a memory area to receive
    //the process class name
    SetLength(ClassName, 255);
    //get the class name and reset the
    //memory area to the size of the name
    SetLength(ClassName,
              GetClassName(hHwnd,
                           PChar(className),
                           Length(className)));
    SetLength(title, 255);
    //get the process title; usually displayed
    //on the top bar in visible process
    SetLength(title, GetWindowText(hHwnd, PChar(title), Length(title)));
    //Display the process information
    //by adding it to a list box
      NewItem := FormMain.ListViewMain.Items.Add();
      NewItem.Caption := title;
      NewItem.SubItems.Append(className);


    //ProcessForm.ProcessListBox.Items.Add
    //  ('Class Name = ' + className +
    //   '; Title = ' + title +
    //   '; HWND = ' IntToStr(hHwnd) +
    //   '; Pid = ' + IntToStr(pPid));
    Result := true;
end;

function EnumWindowsProc(Handle: HWnd; Param: Integer): Boolean; stdcall;
var
  TextLength: Integer;
  Buffer: array [1..1023] of Char;
  NewItem: TListItem;

begin
  TextLength:= GetWindowTextLength(Handle);
  if ( TextLength > 0 ) then // no
    begin
      //SetLength(Buffer, TextLength * 3);
      GetWindowText(Handle, @Buffer, 1023);
      //with FormMain.ListViewMain.Items do
      NewItem := FormMain.ListViewMain.Items.Add();
      NewItem.Caption := StrPas(@Buffer);
      NewItem.SubItems.AddObject(IntToStr(Handle), TObject(Handle));

      //NewItem.SubItems.Append();
        //Objects[Add(StrPas(@Buffer))]:= TObject(Handle);
      //Buffer := nil;
    end;
  Result:= True;
end;

procedure TFormMain.ShowSplash;
begin
  if ( FormSplash <> nil ) then
    Exit;
  FormSplash:= TFormSplash.Create(Self);
  FormSplash.Show;
end;

procedure TFormMain.BuildList;
begin
  ListViewMain.Clear;
  EnumWindows(@EnumWindowsProc, 0);
end;

procedure TFormMain.FormCreate(Sender: TObject);
begin
  BuildList;
  Application.OnMinimize:= ApplicationMinimize;
  TaskIcon:= TIcon.Create;
  TaskIcon.Assign(Application.Icon);
  NotifyIconData.cbSize:= Sizeof(TNotifyIconData);
  NotifyIconData.Wnd:= Handle;
  NotifyIconData.uID:= 0;
  NotifyIconData.uFlags:= NIF_ICON or NIF_TIP or NIF_MESSAGE;
  NotifyIconData.uCallbackMessage:= WM_TASKICON;
  NotifyIconData.hIcon:= TaskIcon.Handle;
  StrPCopy(NotifyIconData.szTip, Caption);
end;

procedure TFormMain.ApplicationMinimize(Sender: TObject);
begin
  ShowWindow(FindWindow('TApplication', @Application.Title[1]), SW_HIDE);
  Shell_NotifyIcon(NIM_ADD, @NotifyIconData);
end;

procedure TFormMain.ShowSelectedWindows(Show: Boolean);
var
  ItemCnt: Integer;
  Item: TListItem;
  Cmd: Integer;

begin
  if ( ListViewMain.SelCount = 0 ) then
    Exit;

  if (Show) then
    Cmd := SW_SHOW
  else
    Cmd := SW_HIDE;

  for ItemCnt:= 0 to ListViewMain.Items.Count - 1 do
    begin
      Item := ListViewMain.Items[ItemCnt];
      if Item.Selected then
        ShowWindow(Integer(Item.SubItems.Objects[0]), Cmd);
    end;
end;

procedure TFormMain.WMTaskIcon(var Message: TMessage);
begin
  if ( Message.LParam = WM_LBUTTONDBLCLK ) then
    begin
      Shell_NotifyIcon(NIM_DELETE, @NotifyIconData);
      ShowWindow(FindWindow('TApplication', @Application.Title[1]), SW_SHOW);
      Application.Restore;
    end;
end;

procedure TFormMain.FormDestroy(Sender: TObject);
begin
  TaskIcon.Free;
end;

procedure TFormMain.SpeedButtonRefreshClick(Sender: TObject);
begin
  BuildList;
end;

procedure TFormMain.ButtonShowClick(Sender: TObject);
begin
  ShowSelectedWindows(True);
end;

procedure TFormMain.ButtonRefreshClick(Sender: TObject);
begin
  BuildList;
end;

procedure TFormMain.ListViewMainDblClick(Sender: TObject);
begin
  ShowSelectedWindows(True);
end;

procedure TFormMain.Button1Click(Sender: TObject);
begin
  ShowSelectedWindows(False);
end;

end.
