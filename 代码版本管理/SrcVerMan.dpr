library SrcVerMan;

uses
  ShareMem,
  Forms,
  Dialogs,
  SysUtils,
  Classes,
  Global,
  SourceManForm in 'SourceManForm.pas' {frmSourceMan};

{$R *.res}

procedure QueryInterface;
begin
    with TfrmSourceMan.Create(Application) do
    try
        ShowModal;   
    finally
        Free;
    end;
end;

procedure InitWiz(Cache: Pointer);
begin
    GlobalCache := TGlobalCache(Cache);
end;

exports QueryInterface;

exports InitWiz;

begin
end.
