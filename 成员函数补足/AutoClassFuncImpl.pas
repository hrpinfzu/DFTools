unit AutoClassFuncImpl;

interface

function AutoComplete: Boolean;
function AutoMakeDevSource: Boolean;

implementation

uses
    ToolsAPI, SysUtils, Dialogs, Classes, Clipbrd, CommonFun, WizConstUnit;

function AutoComplete: Boolean;
begin

end;

function AutoMakeDevSource: Boolean;
var
    OTAEditorServices: IOTAEditorServices;
    OTAServices: IOTAServices;
    OTAEditPosition: IOTAEditPosition;
    BlockText: string;
    HeaderText: string;

    CustDefines: string;
begin
    Result := False;

    if not Supports(BorlandIDEServices, IOTAServices, OTAServices) then
        Exit;

    { Returns the product Identifier, 'C++Builder' or 'Delphi' }
    if SameText(OTAServices.GetProductIdentifier, 'Delphi') then
        Exit;

    if not Supports(BorlandIDEServices, IOTAEditorServices, OTAEditorServices) then
        Exit;

    CustDefines := GetCfg(Cfg_CommonSet_CustDefines, 'DevVer', Sec_CommonSet);

    Clipboard.Clear;
    OTAEditorServices.TopView.Block.Copy(False);
    BlockText := Clipboard.AsText;
    HeaderText := StringOfChar(' ', OTAEditorServices.TopView.CursorPos.Col - 1);

    BlockText := ''
        + '#ifdef ' + CustDefines + #13#10
        + HeaderText + BlockText + #13#10
        + HeaderText + '#else'#13#10
        + HeaderText + BlockText + #13#10
        + HeaderText + '#endif';

    Clipboard.SetTextBuf(PChar(BlockText));
    OTAEditPosition := OTAEditorServices.TopView.Buffer.EditPosition;
    OTAEditPosition.Paste;
end;

end.
