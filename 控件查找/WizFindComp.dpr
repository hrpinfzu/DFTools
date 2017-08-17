library WizFindComp;

uses
  ShareMem,
  SysUtils,
  Classes,
  Forms,
  Global,
  FindCompUnit;

{$R *.res}

procedure QueryInterface;
begin
    LinkSelTextComponent;
end;

procedure InitWiz(Cache: Pointer);
begin
    GlobalCache := TGlobalCache(Cache);
end;

exports QueryInterface;

exports InitWiz;

begin
end.
