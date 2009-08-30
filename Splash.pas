unit Splash;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls;

type
  TFormSplash = class(TForm)
    ImageSplash: TImage;
    procedure FormCreate(Sender: TObject);
    procedure ImageSplashClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormSplash: TFormSplash;
  
implementation

{$R *.DFM}

procedure TFormSplash.FormCreate(Sender: TObject);
begin
  SetWindowRgn(Handle, CreateRoundRectRgn(0, 0, Width, Height, Width, Height),
  True);
  Show;
end;

procedure TFormSplash.ImageSplashClick(Sender: TObject);
begin
  Close;
end;

procedure TFormSplash.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FormSplash:= nil;
  Action:= caFree;
end;

end.
