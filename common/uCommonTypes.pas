unit uCommonTypes;

interface

uses Vcl.Menus, System.Classes, System.SysUtils;

type
  TObjWrapper<T: class> = class(TComponent)

  end;

  TPopupMenuEx<T: class> = class(TPopupMenu)
  private type
    TItemProc = reference to procedure(I: Integer; out ACaption: string;
      out AValue: Integer);
  protected
    FObj: T;
  public
    constructor Create(AOwner: T); reintroduce; virtual;
  public
    function AddItem(const ACaption: string; AOnClick: TNotifyEvent): TMenuItem;
    procedure AddSubItems(AItem: TMenuItem; ALow, AHigh: Integer;
      AItemF: TItemProc; AOnClick: TNotifyEvent);
    procedure UpdateItems(Sender: TObject); virtual; abstract;
  end;

implementation

{ TPopupMenuEx }

function TPopupMenuEx<T>.AddItem(const ACaption: string; AOnClick: TNotifyEvent)
  : TMenuItem;
begin
  Result := TMenuItem.Create(Self);
  Result.Caption := ACaption;
  Result.OnClick := AOnClick;
  Items.Add(Result);
end;

procedure TPopupMenuEx<T>.AddSubItems(AItem: TMenuItem; ALow, AHigh: Integer;
  AItemF: TItemProc; AOnClick: TNotifyEvent);
var
  LSubItem: TMenuItem;
  I, LValue: Integer;
  LCaption: string;
begin
  for I := ALow to AHigh do
  begin
    AItemF(I, LCaption, LValue);

    LSubItem := TMenuItem.Create(AItem);
    LSubItem.Caption := LCaption;
    LSubItem.Tag := LValue;
    LSubItem.OnClick := AOnClick;
    AItem.Add(LSubItem);
  end;
end;

constructor TPopupMenuEx<T>.Create(AOwner: T);
begin
  inherited Create(TComponent(AOwner));
  AutoHotkeys := maManual;
  OnPopup := UpdateItems;
  FObj := AOwner;
end;

end.
