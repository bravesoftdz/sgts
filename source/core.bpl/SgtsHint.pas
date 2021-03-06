unit SgtsHint;

interface

uses Windows, Classes, Controls, Graphics, stdctrls, Messages;

type

  TSgtsHint=class;

  TFillDirection = (bdNone,bdUp,bdDown,bdLeft,bdRight,bdHorzIn,bdHorzOut,bdVertIn,bdVertOut);
  TWayDirection = (Horz,Vert);
  THintDirection=(hdUpRight,hdUpLeft,hdDownRight,hdDownLeft); 

  TSgtsHintWindow=class(THintWindow)
  private
    FHint: string;
    FHintComponent: TSgtsHint;
    procedure FillBackGround(Clr1, Clr2: TColor; Dir: TWayDirection; TwoWay: Boolean);
    function GetHintWidth(AHint: TSgtsHint; Default: Integer): Integer;
    function GetHintHeight(AHint: TSgtsHint; Default: Integer): Integer;
    function GetHintText(AHint: TSgtsHint; Default: string): string;
    function GetRealyCount(AHint: TSgtsHint): Integer;
//    procedure PaintBounds;
  protected
    property HintComponent: TSgtsHint read FHintComponent write FHintComponent;    
  public
    constructor Create(AOwner:TComponent);override;
    destructor Destroy;override;
    procedure Paint;override;
    procedure CreateParams(var Params: TCreateParams);override;
    procedure ActivateHintData(Rect: TRect; const AHint: string; AData: Pointer); override;
    function CalcHintRect(MaxWidth: Integer; const AHint: string; AData: Pointer): TRect; override;
  end;

  TSgtsHintCaption=class(TCollectionItem)
  private
    FCaption: string;
    FBrush: TBrush;
    FFont: TFont;
    FPen: TPen;
    FAlignment: TAlignment;
    FToNewLine: Boolean;
    FWidth: Integer;
    FAutoSize: Boolean;
    procedure SetBrush(Value: TBrush);
    procedure SetFont(Value: TFont);
    procedure SetPen(Value: TPen);
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy;override;
  published
    property Alignment: TAlignment read FAlignment write FAlignment;
    property AutoSize: Boolean read FAutoSize write FAutoSize;
    property Caption: string read FCaption write FCaption;
    property Brush: TBrush read FBrush write SetBrush;
    property Font: TFont read FFont write SetFont;
    property Pen: TPen read FPen write SetPen;
    property ToNewLine: Boolean read FToNewLine write FToNewLine;
    property Width: Integer read FWidth write FWidth;
  end;
  
  TSgtsHintCaptions=class(TCollection)
  private
    FHint: TSgtsHint;
    function GetHintCaption(Index: Integer): TSgtsHintCaption;
    procedure SetHintCaption(Index: Integer; Value: TSgtsHintCaption);
  protected
    function GetOwner: TPersistent; override;
  public
    constructor Create(AOwner: TSgtsHint);
    destructor Destroy; override;
    function  Add: TSgtsHintCaption;
    procedure Assign(Source: TPersistent); override;
    procedure Clear;
    procedure Delete(Index: Integer);
    function Insert(Index: Integer): TSgtsHintCaption;
    property Items[Index: Integer]: TSgtsHintCaption read GetHintCaption write SetHintCaption;
  end;

  TSgtsHint=class(TComponent)
  private
   FOldWndMethod: TWndMethod;
   FFillDirection: TFillDirection;
   FEndColor: TColor;
   FStartColor: TColor;
   FBrush: TBrush;
   FFont: TFont;
   FPen: TPen;
   FShadowVisible: Boolean;
   FShadowColor: TColor;
   FShadowWidth: Integer;
   FCaption: TStrings;
   FCaptions: TSgtsHintCaptions;
   FAlignment: TAlignment;
   FLayout: TTextLayout;
   FControl: TControl;
   FReshowTimeout: Integer;
   FHideTimeout: Integer;
   FLeft: Integer;
   FHintPosX, FHintPosY: Integer;
   FHintDirection: THintDirection;
   FHintRadius: Integer;
   FHintWidth: Integer;

   procedure SetBrush(Value: TBrush);
   procedure SetFont(Value: TFont);
   procedure SetPen(Value: TPen);
   procedure SetCaption(Value: TStrings);
   procedure SetCaptions(Value: TSgtsHintCaptions);
   procedure SetControl(Value: TControl);

   procedure ControlWindowProc(var Message: TMessage);

  protected

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ActivateHint(Point: TPoint);overload;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;

  published
    property Layout: TTextLayout read FLayout write FLayout;
    property Left: Integer read FLeft write FLeft;
    property Alignment: TAlignment read FAlignment write FAlignment;
    property Caption: TStrings read FCaption write SetCaption;
    property Captions: TSgtsHintCaptions read FCaptions write SetCaptions;
    property Control: TControl read FControl write SetControl;
    property FillDirection: TFillDirection read FFillDirection write FFillDirection;
    property StartColor: TColor read FStartColor write FStartColor;
    property EndColor: TColor read FEndColor write FEndColor;
    property Brush: TBrush read FBrush write SetBrush;
    property Font: TFont read FFont write SetFont;
    property Pen: TPen read FPen write SetPen;
    property ReshowTimeout: Integer read FReshowTimeout write FReshowTimeout;
    property HideTimeout: Integer read FHideTimeout write FHideTimeout;
    property HintPosX: Integer read FHintPosX write FHintPosX;
    property HintPosY: Integer read FHintPosY write FHintPosY;
    property HintDirection: THintDirection read FHintDirection write FHintDirection;
    property HintRadius: Integer read FHintRadius write FHintRadius;
    property HintWidth: Integer read FHintWidth write FHintWidth;
    property ShadowVisible: Boolean read FShadowVisible write FShadowVisible;
    property ShadowColor: TColor read FShadowColor write FShadowColor;
    property ShadowWidth: Integer read FShadowWidth write FShadowWidth;

  end;

implementation

uses Forms, SysUtils;

{ TSgtsHintWindow }

constructor TSgtsHintWindow.Create(AOwner:TComponent);
begin
  inherited Create(AOwner);
  FHintComponent:=nil;
end;

destructor TSgtsHintWindow.Destroy;
begin
  inherited Destroy;
end;

procedure TSgtsHintWindow.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.Style := WS_POPUP OR WS_DISABLED;
end;

procedure TSgtsHintWindow.ActivateHintData(Rect: TRect; const AHint: string; AData: Pointer); 
begin
  FHint:=AHint;
  FHintComponent:=AData;
  inherited;
end;

function TSgtsHintWindow.GetHintText(AHint: TSgtsHint; Default: string): string;
var
  i: Integer;
  hc: TSgtsHintCaption;
  s: string;
begin
  Result:=Default;
  if AHint=nil then exit;
  if AHint.Captions.Count=0 then begin
    Result:=Trim(AHint.Caption.Text);
  end else begin
    s:='';
    for i:=0 to AHint.Captions.Count-1 do begin
      hc:=AHint.Captions.Items[i];
      if hc.ToNewLine then s:=s+#13;
      s:=s+hc.Caption;
    end;
    Result:=s;
  end;
end;

function TSgtsHintWindow.GetHintWidth(AHint: TSgtsHint; Default: Integer): Integer;
var
  AFont: TFont;
  hc: TSgtsHintCaption;
  mw: Integer;
  s: string;
  i,cw: Integer;
begin
  Result:=Default;
  if AHint=nil then exit;
  AFont:=TFont.Create;
  try
    AFont.Assign(Canvas.Font);
    if AHint.Captions.Count=0 then begin
      Canvas.Font.Assign(AHint.Font);
      mw:=0;
      for i:=0 to AHint.Caption.Count-1 do begin
        cw:=Canvas.TextWidth(AHint.Caption.Strings[i]);
        if cw>mw then mw:=cw;
      end;
      Result:=mw+7;
    end else begin
      mw:=0;
      s:='';
      cw:=0;
      for i:=0 to AHint.Captions.Count-1 do begin
        hc:=AHint.Captions.Items[i];
        Canvas.Font.Assign(hc.Font);
        try
          s:=hc.Caption;
          if hc.ToNewLine then cw:=0;
          if hc.AutoSize then
           cw:=cw+Canvas.TextWidth(s)
          else cw:=cw+hc.Width;
          if cw>mw then mw:=cw;
        finally
          Canvas.Font.Assign(AFont);
        end;
      end;
      Result:=mw+6;
    end;
  finally
    Canvas.Font.Assign(AFont);
    AFont.Free;
  end;
end;

function TSgtsHintWindow.GetHintHeight(AHint: TSgtsHint; Default: Integer): Integer;
var
  AFont: TFont;
  mh: Integer;
  i,ch: Integer;
begin  
  Result:=Default;
  if AHint=nil then exit;
  AFont:=TFont.Create;
  try
    AFont.Assign(Canvas.Font);
    if AHint.Captions.Count=0 then begin
      Canvas.Font.Assign(AHint.Font);
      mh:=0;
      for i:=0 to AHint.Caption.Count-1 do begin
        ch:=Canvas.TextHeight(AHint.Caption.Strings[i]);
        mh:=ch+mh;
      end;
      Result:=mh+1;
    end else begin
{      mw:=0;
      s:='';
      cw:=0;
      for i:=0 to AHint.Captions.Count-1 do begin
        hc:=AHint.Captions.Items[i];
        Canvas.Font.Assign(hc.Font);
        try
          s:=hc.Caption;
          if hc.ToNewLine then cw:=0;
          if hc.AutoSize then
           cw:=cw+Canvas.TextWidth(s)
          else cw:=cw+hc.Width;
          if cw>mw then mw:=cw;
        finally
          Canvas.Font.Assign(AFont);
        end;
      end;
      Result:=mw+6;}
    end;
  finally
    Canvas.Font.Assign(AFont);
    AFont.Free;
  end;
end;

function TSgtsHintWindow.CalcHintRect(MaxWidth: Integer; const AHint: string; AData: Pointer): TRect;
begin
  if AData=nil then begin
    Result:=inherited CalcHintRect(MaxWidth,AHint,AData);
  end else begin
    Result:=inherited CalcHintRect(MaxWidth,GetHintText(TSgtsHint(AData),AHint),AData);
    Result.Right:=GetHintWidth(TSgtsHint(AData),Result.Right);
    Result.Bottom:=GetHintHeight(TSgtsHint(AData),Result.Bottom);
  end;
end;

function TSgtsHintWindow.GetRealyCount(AHint: TSgtsHint): Integer;
var
  i: Integer;
begin
  Result:=0;
  if AHint.Captions.Count>0 then Inc(Result);
  for i:=0 to AHint.Captions.Count-1 do begin
    if AHint.Captions.Items[i].ToNewLine then Inc(Result);
  end;
end;

(*procedure TSgtsHintWindow.PaintBounds;
var
 R        :TRect;
 FillRegion,
 ShadowRgn:HRgn;
 AP       :array[0..2] of TPoint; {Points of the Arrow }
 SP       :array[0..2] of TPoint; {Points of the Shadow}
 X,Y      :Integer;
 AddNum   :Integer; {Added num for hdDownXXX }
 MemBmp: TBitmap;
begin
 R:=ClientRect; {R is for Text output}
 inc(R.Left,8);
 inc(R.Top,3);

 AddNum:=0;
 MemBmp:=TBitmap.Create;
 try
   with FHintComponent do begin
     if FHintDirection>=hdDownRight then AddNum:=15;
     Inc(R.Top,AddNum);

     case HintDirection of
      hdUpRight:begin
                 AP[0]:=Point(10,Height-15);
                 AP[1]:=Point(20,Height-15);
                 AP[2]:=Point(0,Height);

                 SP[0]:=Point(12,Height-15);
                 SP[1]:=Point(25,Height-15);
                 SP[2]:=Point(12,Height);
                end;
      hdUpLeft: begin
                 AP[0]:=Point(Width-ShadowWidth-20,Height-15);
                 AP[1]:=Point(Width-ShadowWidth-10,Height-15);
                 AP[2]:=Point(Width-ShadowWidth,Height);

                 SP[0]:=Point(Width-ShadowWidth-27,Height-15);
                 SP[1]:=Point(Width-ShadowWidth-5,Height-15);
                 SP[2]:=Point(Width-ShadowWidth,Height);
                end;
    hdDownRight:begin
                 AP[0]:=Point(10,15);
                 AP[1]:=Point(20,15);
                 AP[2]:=Point(0,0);

                 { for hdDownXXX, SP not used now }
                 SP[0]:=Point(12,Height-15);
                 SP[1]:=Point(25,Height-15);
                 SP[2]:=Point(12,Height);
                end;
    hdDownLeft: begin
                 AP[0]:=Point(Width-ShadowWidth-20,15);
                 AP[1]:=Point(Width-ShadowWidth-10,15);
                 AP[2]:=Point(Width-ShadowWidth,0);

                 { for hdDownXXX, SP not used now }
                 SP[0]:=Point(12,Height-15);
                 SP[1]:=Point(25,Height-15);
                 SP[2]:=Point(12,Height);
                end;
      end;

      {Draw Shadow of the Hint Rect}
      if (FHintDirection<=hdUpLeft) then begin
       ShadowRgn:=CreateRoundRectRgn(10,8,Width,Height-8,HintRadius-1,HintRadius-1);
       for X:=Width-ShadowWidth-8 to Width do
        for Y:=8 to Height-14 do begin
         if (Odd(X)=Odd(Y)) and PtInRegion(ShadowRgn,X,Y) then
          MemBmp.Canvas.Pixels[X,Y]:=ShadowColor;
        end;
       for X:=10 to Width do
        for Y:=Height-14 to Height-9 do begin
         if (Odd(X)=Odd(Y)) and PtInRegion(ShadowRgn,X,Y) then
           MemBmp.Canvas.Pixels[X,Y]:=ShadowColor;
        end;


      end else begin { for hdDownXXX }
       ShadowRgn:=CreateRoundRectRgn(10,8+15,Width,Height-2,HintRadius-1,HintRadius-1);
       for X:=Width-ShadowWidth-8 to Width do
        for Y:=8+15 to Height-8 do begin
         if (Odd(X)=Odd(Y)) and PtInRegion(ShadowRgn,X,Y) then
          MemBmp.Canvas.Pixels[X,Y]:=ShadowColor;
        end;
       for X:=10 to Width do
        for Y:=Height-8 to Height-2 do begin
         if (Odd(X)=Odd(Y)) and PtInRegion(ShadowRgn,X,Y) then
          MemBmp.Canvas.Pixels[X,Y]:=ShadowColor;
        end;
      end;
      DeleteObject(ShadowRgn);

      { Draw the shadow of the arrow }
      if (HintDirection<=hdUpLeft) then begin
       ShadowRgn:=CreatePolygonRgn(SP,3,WINDING);
        for X:=SP[0].X to SP[1].X do
         for Y:=SP[0].Y to SP[2].Y do begin
          if (Odd(X)=Odd(Y)) and PtInRegion(ShadowRgn,X,Y) then
           MemBmp.Canvas.Pixels[X,Y]:=ShadowColor;
         end;
         DeleteObject(ShadowRgn);
       end;

      { Draw HintRect }
{      MemBmp.Canvas.Pen.Color:=clBlack;
      MemBmp.Canvas.Pen.Style:=psSolid;
      MemBmp.Canvas.Brush.Color:=FDanHint.HintColor;
      MemBmp.Canvas.Brush.Style:=bsSolid;
      if (FHintDirection<=hdUpLeft) then
           MemBmp.Canvas.RoundRect(0,0,Width-ShadowWidth,Height-14,HRound,HRound)
      else MemBmp.Canvas.RoundRect(0,0+AddNum,Width-ShadowWidth,Height-14+6,HRound,HRound);}

      { Draw Hint Arrow }
//      MemBmp.Canvas.Pen.Color:=FDanHint.HintColor;
      MemBmp.Canvas.MoveTo(AP[0].X,AP[0].Y);
      MemBmp.Canvas.LineTo(AP[1].X,AP[1].Y);
      MemBmp.Canvas.Pen.Color:=clBlack;
      FillRegion:=CreatePolygonRgn(AP,3,WINDING);
      FillRgn(MemBmp.Canvas.Handle,FillRegion,MemBmp.Canvas.Brush.Handle);
      DeleteObject(FillRegion);
      MemBmp.Canvas.LineTo(AP[2].X,AP[2].Y);
      MemBmp.Canvas.LineTo(AP[0].X,AP[0].Y);

      {SetBkMode makes DrawText's text be transparent }

{      SetBkMode(MemBmp.Canvas.Handle,TRANSPARENT);
      MemBmp.Canvas.Font.Assign(FDanHint.HintFont);
      DrawText(MemBmp.Canvas.Handle, StrPCopy(CCaption, Caption), -1, R,
        DT_LEFT or DT_NOPREFIX or DT_WORDBREAK);  }
      Canvas.CopyMode:=cmSrcCopy;
      Canvas.CopyRect(ClientRect,MemBmp.Canvas,ClientRect);

    end;
  finally
    MemBmp.Free;
  end;
end;*)

procedure TSgtsHintWindow.Paint;
var
  OldBrush: TBrush;
  OldFont: TFont;
  OldPen: TPen;
  rt: TRect;
  i: Integer;
  s: string;
  h,w: Integer;
  x,y,ys,xs: Integer;

  hc: TSgtsHintCaption;
  RealyY,RealyCount: Integer;
  LastW: Integer;
begin
  rt:=GetClientRect;
  if FHintComponent<>nil then begin

    OldBrush:=TBrush.Create;
    OldFont:=TFont.Create;
    OldPen:=TPen.Create;
    OldBrush.Assign(Canvas.Brush);
    OldFont.Assign(Canvas.Font);
    OldPen.Assign(Canvas.Pen);
    try

      Canvas.Brush.Assign(FHintComponent.Brush);
      Canvas.Font.Assign(FHintComponent.Font);
      Canvas.Pen.Assign(FHintComponent.Pen);


      with FHintComponent do begin
       // PaintBounds;
        case FillDirection of
          bdNone: begin
            Canvas.FillRect(rt);
          end;
          bdUp: FillBackGround(StartColor, EndColor, Horz, False);
          bdDown: FillBackGround(EndColor, StartColor, Horz, False);
          bdLeft: FillBackGround(StartColor, EndColor, Vert, False);
          bdRight: FillBackGround(EndColor, StartColor, Vert, False);
          bdHorzOut: FillBackGround(StartColor, EndColor, Horz, True);
          bdHorzIn: FillBackGround(EndColor, StartColor, Horz, True);
          bdVertIn: FillBackGround(StartColor, EndColor, Vert, True);
        else
          FillBackGround(EndColor, StartColor, Vert, True);
        end;

      end;

      h:=rt.Bottom-rt.Top;
      w:=rt.Right-rt.Left;

      if FHintComponent.Captions.Count=0 then begin

        Canvas.Brush.Assign(FHintComponent.Brush);
        Canvas.Font.Assign(FHintComponent.Font);
        Canvas.Pen.Assign(FHintComponent.Pen);

        for i:=0 to FHintComponent.Caption.Count-1 do begin
          s:=FHintComponent.Caption.Strings[i];
          x:=0;
          y:=0;
          ys:=2;
          xs:=3;
          case FHintComponent.Alignment of
            taLeftJustify: x:=xs;
            taRightJustify: x:=w-Canvas.TextWidth(s)-xs-1;
            taCenter: x:=w div 2 - Canvas.TextWidth(s) div 2;
          end;
          case FHintComponent.Layout of
            tlTop: y:=ys+Canvas.TextHeight(s)*i;
            tlBottom: y:=(h div FHintComponent.Caption.Count)*(i+1)-Canvas.TextHeight(s)-ys;
            tlCenter: y:=(h div FHintComponent.Caption.Count)*i+(h div FHintComponent.Caption.Count) div 2 - Canvas.TextHeight(s) div 2;
          end;
          Canvas.TextOut(x,y,s);
        end;

      end else begin

        x:=2;
        RealyY:=0;
        LastW:=0;
        RealyCount:=GetRealyCount(FHintComponent);
        for i:=0 to FHintComponent.Captions.Count-1 do begin
          hc:=FHintComponent.Captions.Items[i];
          Canvas.Brush.Assign(hc.Brush);
          Canvas.Font.Assign(hc.Font);
          Canvas.Pen.Assign(hc.Pen);
          try
            s:=hc.Caption;
            if hc.ToNewLine then begin
              Inc(RealyY);
              x:=2;
              y:=(h div RealyCount)*RealyY + (h div RealyCount)div 2 - Canvas.TextHeight(hc.Caption) div 2;
            end else begin
              x:=x+LastW;
              y:=(h div RealyCount)*RealyY + (h div RealyCount)div 2 - Canvas.TextHeight(hc.Caption) div 2;
              if hc.AutoSize then
                LastW:=Canvas.TextWidth(s)
              else LastW:=hc.Width;
            end;
           Canvas.TextOut(x,y,s);
          finally
            Canvas.Brush.Assign(FHintComponent.Brush);
            Canvas.Font.Assign(FHintComponent.Font);
            Canvas.Pen.Assign(FHintComponent.Pen);
          end;
        end;

      end;

      Canvas.Brush.Style:=bsClear;
      Canvas.Rectangle(rt);


    finally
     Canvas.Brush.Assign(OldBrush);
     Canvas.Font.Assign(OldFont);
     Canvas.Pen.Assign(OldPen);
     OldBrush.Free;
     OldFont.Free;
     OldPen.Free;
    end;

  end else begin

    inherited Paint;

    Canvas.Brush.Style:=bsSolid;
    Canvas.Brush.Color:=clInfoBk;
    Canvas.FillRect(rt);

    Canvas.Brush.Style:=bsClear;
    Canvas.Font.Color:=clWindowText;
    Canvas.TextOut(3,2,FHint);

    Canvas.Brush.Style:=bsClear;
    Canvas.Pen.Color:=clBlack;
    Canvas.Rectangle(rt);

  end;
end;

procedure TSgtsHintWindow.FillBackGround(Clr1,Clr2: TColor; Dir: TWayDirection; TwoWay: Boolean);
var
  RGBFrom   : array[0..2] of Byte;    { from RGB values                     }
  RGBDiff   : array[0..2] of integer; { difference of from/to RGB values    }
  ColorBand : TRect;                  { color band rectangular coordinates  }
  I         : Integer;                { color band index                    }
  R         : Byte;                   { a color band's R value              }
  G         : Byte;                   { a color band's G value              }
  B         : Byte;                   { a color band's B value              }
  Last      : Integer;                { last value in loop }
begin
  { Extract from RGB values}
  RGBFrom[0] := GetRValue(ColorToRGB(Clr1));
  RGBFrom[1] := GetGValue(ColorToRGB(Clr1));
  RGBFrom[2] := GetBValue(ColorToRGB(Clr1));
  { Calculate difference of from and to RGB values}
  RGBDiff[0] := GetRValue(ColorToRGB(Clr2)) - RGBFrom[0];
  RGBDiff[1] := GetGValue(ColorToRGB(Clr2)) - RGBFrom[1];
  RGBDiff[2] := GetBValue(ColorToRGB(Clr2)) - RGBFrom[2];
  { Set pen sytle and mode}
  { Set color band's left and right coordinates }
  if Dir = Horz then
    begin
      ColorBand.Left := 0;
      ColorBand.Right := Width;
    end
  else
    begin
      ColorBand.Top := 0;
      ColorBand.Bottom := Height;
    end;
  { Set number of iterations to do }
  if TwoWay then
    Last := $7f
  else
    Last := $ff;
  for I := 0 to Last do begin
    { Calculate color band color}
    R := RGBFrom[0] + MulDiv(I,RGBDiff[0],Last);
    G := RGBFrom[1] + MulDiv(I,RGBDiff[1],Last);
    B := RGBFrom[2] + MulDiv(I,RGBDiff[2],Last);
    { Select brush and paint color band }
    Canvas.Brush.Color := RGB(R,G,B);
    if Dir = Horz then
      begin
        { Calculate color band's top and bottom coordinates}
        ColorBand.Top    := MulDiv (I    , Height, $100);
        ColorBand.Bottom := MulDiv (I + 1, Height, $100);
      end
    else
      begin
        { Calculate color band's left and right coordinates}
        ColorBand.Left  := MulDiv (I    , Width, $100);
        ColorBand.Right := MulDiv (I + 1, Width, $100);
      end;
    Canvas.FillRect(ColorBand);
    if TwoWay then begin
      { This is a two way fill, so do the other half }
      if Dir = Horz then
        begin
          { Calculate color band's top and bottom coordinates}
          ColorBand.Top    := MulDiv ($ff - I    , Height, $100);
          ColorBand.Bottom := MulDiv ($ff - I + 1, Height, $100);
        end
      else
        begin
          { Calculate color band's left and right coordinates}
          ColorBand.Left  := MulDiv ($ff - I    , Width, $100);
          ColorBand.Right := MulDiv ($ff - I + 1, Width, $100);
        end;
      Canvas.FillRect(ColorBand);
    end;
  end;
end;


{ TSgtsHintCaption }

constructor TSgtsHintCaption.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  FBrush:=TBrush.Create;
  FBrush.Style:=bsClear;
  FFont:=TFont.Create;
  FPen:=TPen.Create;
  FAutoSize:=true;
end;

destructor TSgtsHintCaption.Destroy;
begin
  FBrush.Free;
  FFont.Free;
  FPen.Free;
  inherited;
end;

procedure TSgtsHintCaption.SetBrush(Value: TBrush);
begin
  FBrush.Assign(Value);
end;

procedure TSgtsHintCaption.SetFont(Value: TFont);
begin
  FFont.Assign(Value);
end;

procedure TSgtsHintCaption.SetPen(Value: TPen);
begin
  FPen.Assign(Value);
end;

{ TSgtsHintCaptions }

constructor TSgtsHintCaptions.Create(AOwner: TSgtsHint);
begin
  inherited Create(TSgtsHintCaption);
  FHint:=AOwner; 
end;

destructor TSgtsHintCaptions.Destroy;
begin
  inherited;
end;

function TSgtsHintCaptions.GetHintCaption(Index: Integer): TSgtsHintCaption;
begin
  Result := TSgtsHintCaption(inherited Items[Index]);
end;

procedure TSgtsHintCaptions.SetHintCaption(Index: Integer; Value: TSgtsHintCaption);
begin
  Items[Index].Assign(Value);
end;

function TSgtsHintCaptions.GetOwner: TPersistent;
begin
  Result := FHint;
end;

function  TSgtsHintCaptions.Add: TSgtsHintCaption;
begin
  Result := TSgtsHintCaption(inherited Add);
end;

procedure TSgtsHintCaptions.Assign(Source: TPersistent);
begin
  if Source is TSgtsHint then begin
  end else
   inherited Assign(Source);
end;

procedure TSgtsHintCaptions.Clear;
begin
  inherited Clear;
end;

procedure TSgtsHintCaptions.Delete(Index: Integer);
begin
  Inherited Delete(Index);
end;

function TSgtsHintCaptions.Insert(Index: Integer): TSgtsHintCaption;
begin
  Result:=TSgtsHintCaption(Inherited Insert(Index));
end;

{ TSgtsHint }

constructor TSgtsHint.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FBrush:=TBrush.Create;
  FFont:=TFont.Create;
  FPen:=TPen.Create;
  FStartColor:=clBlue;
  FEndColor:=clBlack;
  FLayout:=tlCenter;
  FCaption:=TStringList.Create;
  FCaptions:=TSgtsHintCaptions.Create(Self);
  FReshowTimeout:=500;
  FHideTimeout:=500;
  FHintPosX:=-10;
  FHintPosY:=5;
  FHintDirection:=hdUpRight;
  FShadowColor:=clPurple;
  FShadowVisible:=true;
  FShadowWidth:=6;
  FHintRadius:=9;
  FHintWidth:=100;
end;

destructor TSgtsHint.Destroy;
begin
  SetControl(nil);
  if Assigned(FCaptions) then
    FreeAndNil(FCaptions);
  if Assigned(FCaptions) then
    FreeAndNil(FCaption);
  if Assigned(FPen) then
    FreeAndNil(FPen);
  if Assigned(FFont) then
    FreeAndNil(FFont);
  if Assigned(FBrush) then
    FreeAndNil(FBrush);
  inherited Destroy;
end;

procedure TSgtsHint.SetBrush(Value: TBrush);
begin
  FBrush.Assign(Value);
end;

procedure TSgtsHint.SetFont(Value: TFont);
begin
  FFont.Assign(Value);
end;

procedure TSgtsHint.SetPen(Value: TPen);
begin
  FPen.Assign(Value);
end;

procedure TSgtsHint.SetCaption(Value: TStrings);
begin
  FCaption.Assign(Value);
end;

procedure TSgtsHint.SetCaptions(Value: TSgtsHintCaptions);
begin
  FCaptions.Assign(Value);
end;

procedure TSgtsHint.ActivateHint(Point: TPoint);
begin
  Application.ActivateHint(Point);
end;

procedure TSgtsHint.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = FControl) then
    SetControl(nil);
end;

procedure TSgtsHint.SetControl(Value: TControl);
begin
  if Value<>FControl then begin
    if FControl<>nil then
      FControl.WindowProc:=FOldWndMethod;
    if Value<>nil then begin
      FOldWndMethod:=Value.WindowProc;
      Application.ShowHint:=false;
      Application.ShowHint:=true;
    end else begin
      FOldWndMethod:=nil;
    end;
    FControl:=Value;
    if FControl<>nil then
      FControl.WindowProc:=ControlWindowProc;
  end;
end;

procedure TSgtsHint.ControlWindowProc(var Message: TMessage);
var
  P: PHintInfo;
begin
  case Message.Msg of
    CM_HINTSHOW: begin
      P:=Pointer(Message.LParam);
      if P.HintControl=FControl then begin
        P.HintData:=Self;
        P.HintWindowClass:=TSgtsHintWindow;
        P.ReshowTimeout:=FReshowTimeout;
        P.HideTimeout:=FHideTimeout;
        P.HintPos:=Point(P.HintPos.x+FHintPosX,P.HintPos.y+FHintPosY);
      end else begin
        P.HintData:=nil;
        P.HintWindowClass:=HintWindowClass;
      end;
    end;
    else
      if Assigned(FOldWndMethod) then
        FOldWndMethod(Message);
  end;
end;


end.
