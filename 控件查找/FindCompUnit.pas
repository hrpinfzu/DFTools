unit FindCompUnit;

interface

uses
    ToolsAPI, Forms;

function LinkSelTextComponent: Boolean;

implementation

uses
    SysUtils, Menus;

function GetFormEditor(Module: IOTAModule): IOTAFormEditor; 
var
    I: Integer;
    Editor: IOTAEditor;
begin
    for I := 0 to Module.ModuleFileCount - 1 do
    begin
        Editor := Module.ModuleFileEditors[I];
        if Supports(Editor, IOTAFormEditor, Result) then
            Exit;
    end;

    Result := nil;
end;

function FindComponent(ComponentName: string; bSelect: Boolean = False;
  bShowFormEditor: Boolean = False): IOTAComponent;
var
    OTAModuleServices: IOTAModuleServices;
    OTAFormEditor: IOTAFormEditor;
begin
    if Trim(ComponentName) = '' then
    begin
        Result := nil;
        Exit;
    end;

    if Supports(BorlandIDEServices, IOTAModuleServices, OTAModuleServices) then
    begin
        OTAFormEditor := GetFormEditor(OTAModuleServices.CurrentModule);
        if Assigned(OTAFormEditor) then
        begin
            Result := OTAFormEditor.FindComponent(ComponentName);

            if Assigned(Result) then
            begin
                if bSelect then
                begin
                    Result.Select(False);
                end;

                if bShowFormEditor then
                    OTAFormEditor.Show;
            end;
        end;
    end;
end;

function LinkSelTextComponent: Boolean;
var
    OTAEditorServices: IOTAEditorServices;
    SelText: string;
begin
    if Supports(BorlandIDEServices, IOTAEditorServices, OTAEditorServices) then
    begin
        SelText := OTAEditorServices.TopView.Block.Text;

    end
    else
        SelText := '';

    FindComponent(SelText, True, True);
end;

end.
