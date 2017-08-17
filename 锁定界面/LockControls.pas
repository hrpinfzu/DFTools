unit LockControls;

interface

uses
    ToolsAPI, Forms;

type
    TDTFormNotifier = class(TNotifierObject, IOTAFormNotifier)
    public
        procedure FormActivated;
        procedure FormSaving;
        procedure ComponentRenamed(ComponentHandle: TOTAHandle;
            const OldName, NewName: string);
    end;

function DoLockControls: Boolean;

implementation

uses
    SysUtils, Menus, Dialogs;

var
  FIDELockControlsMenu: TMenuItem;

const
    SIDELockControlsMenuName = 'EditLockControlsItem';

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

function DoLockControls: Boolean;
var
    OTAModuleServices: IOTAModuleServices;
    OTAFormEditor: IOTAFormEditor;
begin
    Result := False;

    if Supports(BorlandIDEServices, IOTAModuleServices, OTAModuleServices) then
    begin
        OTAFormEditor := GetFormEditor(OTAModuleServices.CurrentModule);
        if Assigned(OTAFormEditor) then
        begin
            OTAFormEditor.AddNotifier(TDTFormNotifier.Create as IOTAFormNotifier);
        end;
    end;
end;

{ TDTFormNotifier }

procedure TDTFormNotifier.ComponentRenamed(ComponentHandle: TOTAHandle;
  const OldName, NewName: string);
begin

end;

procedure TDTFormNotifier.FormActivated;
begin
    FIDELockControlsMenu := TMenuItem(Application.MainForm.FindComponent(SIDELockControlsMenuName));
    if not Assigned(FIDELockControlsMenu) then
        Exit;

    ShowMessage(FIDELockControlsMenu.Caption);
    if FIDELockControlsMenu.Checked then
    begin
        FIDELockControlsMenu.Click;
        FIDELockControlsMenu.Click;
    end;
end;

procedure TDTFormNotifier.FormSaving;
begin

end;

end.
