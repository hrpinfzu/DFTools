unit InitWiz;

interface

uses ToolsAPI, Dialogs, Menus, Classes, WizMan;

type
    TShortCutBinding = class(TNotifierObject, IOTAKeyboardBinding)
    private
        FShortCutList: array of TShortCut;
        FShortCutExecList: array of TKeyBindingProc;
        FBindingServices: IOTAKeyBindingServices;

        function GetBindingType: TBindingType;
        function GetDisplayName: string;
        function GetName: string;
        procedure BindKeyboard(const BindingServices: IOTAKeyBindingServices);
    public
        constructor Create(AShortCut: TShortCut; AExcute: TKeyBindingProc); overload;
        constructor Create(AShortCutList: array of TShortCut;
            AExcuteList: array of TKeyBindingProc); overload;
    end;

    TDTools = class(TNotifierObject, IOTAWizard)
        {IOTAWizard}
        { Expert UI strings }
        function GetIDString: string;
        function GetName: string;
        function GetState: TWizardState;
        { Launch the AddIn }
        procedure Execute;

        constructor Create;
        destructor Destroy; override;
    private
        FMainMenu: TMainMenu;
        FOwnerMenu: TMenuItem; 

        FPopMenu: TPopupMenu;
        FKeybordBindingIndex: Integer;

        FWizList: TWizObjects;

        procedure LoadWizList;
        procedure CreateIDEMenu;
        procedure SetMenuClick(Sender: TObject); 

        procedure ShortProc(const Context: IOTAKeyContext;
            KeyCode: TShortcut; var BindingResult: TKeyBindingResult);
        procedure PopMenuAtMouse;
    public
        property PopMenu: TPopupMenu read FPopMenu;
    end; 

implementation

uses
    SysUtils, Forms, Windows, WizConstUnit, Global, CommonFun, ConfigForm;

var
    FMainWiz: TDTools = nil;

{ TDTools }
function GetMainWiz: TDTools;
begin
    Result := FMainWiz;
end;

constructor TDTools.Create;
var
    scPopMenu: TShortCut;
begin
    inherited Create;
    GlobalCache := TGlobalCache.Create;
    GlobalCache.AppPath := ExtractFilePath(Application.ExeName);
    GlobalCache.WizDLLPath := GlobalCache.AppPath + 'Experts\DLL\';
    ForceDirectories(GlobalCache.WizDLLPath);
    GlobalCache.WizIniPath := GlobalCache.AppPath + 'Experts\Ini\';
    ForceDirectories(GlobalCache.WizIniPath);

    FPopMenu := TPopupMenu.Create(nil);
    FWizList := TWizObjects.Create;

    CreateIDEMenu;
    LoadWizList;

    if not Assigned(FMainWiz) then
        FMainWiz := Self;

    scPopMenu := StrToIntDef(GetCfg(Cfg_CommonSet_PopMenuShortCut,
        '', Sec_CommonSet), ShortCut(Ord('X'), [ssCtrl, ssShift]));
    FKeybordBindingIndex := (BorlandIDEServices as IOTAKeyboardServices)
        .AddKeyboardBinding(TShortCutBinding.Create(scPopMenu, ShortProc))
end;

destructor TDTools.Destroy;
begin
    FreeAndNil(FPopMenu);

    FWizList.Clear;
    FWizList.Free;

    FMainWiz := nil;

    if FKeybordBindingIndex > 0 then
        (BorlandIDEServices as IOTAKeyboardServices).RemoveKeyboardBinding(FKeybordBindingIndex);

    FreeAndNil(GlobalCache);
    inherited;
end;

procedure TDTools.SetMenuClick(Sender: TObject);
begin
    frmConfig := TfrmConfig.Create(Application);
    try
        frmConfig.ShowModal;
    finally
        FreeAndNil(frmConfig);
    end;
end;

procedure TDTools.CreateIDEMenu;
var
    SubItem: TMenuItem;
begin
    FMainMenu := (BorlandIDEServices as INTAServices).MainMenu;
    FOwnerMenu := TMenuItem.Create(nil);
    FOwnerMenu.Caption := WizMenuCaption;
    //Insert new menu item
    FMainMenu.Items.Insert(1, FOwnerMenu);

    SubItem := TMenuItem.Create(nil);
    SubItem.Caption := '…Ë÷√(&S)';
    SubItem.OnClick := SetMenuClick;
    SubItem.Tag := 9999;
    FOwnerMenu.Insert(FOwnerMenu.Count, SubItem);
end;

procedure TDTools.Execute;
begin
    // ShowMessage('Hello');
end;

function TDTools.GetIDString: string;
begin
    Result := WizID;
end;

function TDTools.GetName: string;
begin
    Result := WizName;
end;

function TDTools.GetState: TWizardState;
begin
    Result := [wsEnabled];
end;

procedure TDTools.LoadWizList;
var
    I: Integer;
    iWizCount: Integer;
    sWizName: string;
    WizObject: TWizObject;

    SubItem: TMenuItem;
begin
    iWizCount := StrToIntDef(GetCfg('WizCount', '-1', Sec_WizMan), -1);
    for I := 0 to iWizCount - 1 do
    begin
        sWizName := GetCfg('Item' + IntToStr(I), '', Sec_WizMan);

        WizObject := FWizList[FWizList.Add];
        WizObject.LoadWiz(sWizName);
        WizObject.ObjectInfo.WizInitIntf(GlobalCache);

        if SameText(WizObject.ObjectInfo.WizMenuType, 'main') then
        begin
            SubItem := TMenuItem.Create(nil);
            SubItem.Caption := WizObject.ObjectInfo.WizCaption;
            SubItem.OnClick := WizObject.OnClick;
            SubItem.ShortCut := WizObject.ObjectInfo.WizShortCut;
            FOwnerMenu.Insert(FOwnerMenu.Count - 1, SubItem);
        end
        else
        begin
            SubItem := TMenuItem.Create(nil);
            SubItem.Caption := WizObject.ObjectInfo.WizCaption;
            SubItem.OnClick := WizObject.OnClick;
            SubItem.ShortCut := WizObject.ObjectInfo.WizShortCut;
            FPopMenu.Items.Add(SubItem);
        end;
    end;        
end;

procedure TDTools.ShortProc(const Context: IOTAKeyContext;
    KeyCode: TShortcut; var BindingResult: TKeyBindingResult);
begin
    PopMenuAtMouse;
    BindingResult := krHandled;
end;

procedure TDTools.PopMenuAtMouse;
var
    Pos: TPoint;
begin
    if GetCursorPos(Pos) then
        GetMainWiz.PopMenu.Popup(Pos.X, Pos.Y);
end;

{ TShortCutBinding }

procedure TShortCutBinding.BindKeyboard(
    const BindingServices: IOTAKeyBindingServices);
var
    I: Integer;
begin
    FBindingServices := BindingServices;

    for I := Low(FShortCutList) to High(FShortCutList) do
    begin
        FBindingServices.AddKeyBinding([FShortCutList[I]], FShortCutExecList[I],
            nil);
    end;
end;

constructor TShortCutBinding.Create(AShortCut: TShortCut;
    AExcute: TKeyBindingProc);
begin
    SetLength(FShortCutList, 1);
    SetLength(FShortCutExecList, 1);

    FShortCutList[0] := AShortCut;
    FShortCutExecList[0] := AExcute;
end;

constructor TShortCutBinding.Create(AShortCutList: array of TShortCut;
    AExcuteList: array of TKeyBindingProc);
var
    I: Integer;
begin
    SetLength(FShortCutList, High(AShortCutList) - Low(AShortCutList) + 1);
    SetLength(FShortCutExecList, High(AShortCutList) - Low(AShortCutList) + 1);
    SetLength(FShortCutExecList, 1);
    for I := Low(AShortCutList) to High(AShortCutList) do
    begin
        FShortCutList[I] := AShortCutList[I];
        FShortCutExecList[I] := AExcuteList[I];
    end;
end;

function TShortCutBinding.GetBindingType: TBindingType;
begin
    Result := btPartial;
end;

function TShortCutBinding.GetDisplayName: string;
begin
    Result := KeyBindDispName;
end;

function TShortCutBinding.GetName: string;
begin
    Result := KeyBindName;
end;

end.
