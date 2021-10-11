unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, ComCtrls, StdCtrls, Buttons, ExtDlgs;

type
  TForm1 = class(TForm)
    PanSubstCor: TPanel;
    Label31: TLabel;
    Label32: TLabel;
    PanAltDest: TPanel;
    PanAltOrig: TPanel;
    CBFotoRendering: TCheckBox;
    GroupBox1: TGroupBox;
    Label25: TLabel;
    LblTolR: TLabel;
    Label29: TLabel;
    LblTolG: TLabel;
    Label27: TLabel;
    LblTolB: TLabel;
    Label23: TLabel;
    Label24: TLabel;
    TrackBSubstCorR: TTrackBar;
    TrackBSubstCorG: TTrackBar;
    TrackBSubstCorB: TTrackBar;
    Image1: TImage;
    OpenDlg: TOpenPictureDialog;
    ColorDlg: TColorDialog;
    BtnRefresh: TBitBtn;
    SBLoad: TSpeedButton;
    CBGrouped: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure SBLoadClick(Sender: TObject);
    procedure Image1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PanAltOrigClick(Sender: TObject);
    procedure PanAltDestClick(Sender: TObject);
    procedure BtnRefreshClick(Sender: TObject);
    procedure CBGroupedClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

  BackupBmp: TBitmap;

  procedure BITMAP_SUBSTITUIR_COR(Bmp: TBitmap; CorOrig: TColor; CorDest: TColor; TolR, TolG, TolB: Word; KeepIntervalColor: Boolean; RefreshBmp: Boolean);
  
implementation

{$R *.dfm}

procedure BITMAP_SUBSTITUIR_COR(Bmp: TBitmap; CorOrig: TColor; CorDest: TColor; TolR, TolG, TolB: Word; KeepIntervalColor: Boolean; RefreshBmp: Boolean);
type
    TRGBArray = ARRAY[0..0] OF TRGBTriple; // élément de bitmap (API windows)
    pRGBArray = ^TRGBArray; // type pointeur vers tableau 3 octets 24 bits
    // RGBTriple est découpé en
    // BYTE rgbtBlue;
    // BYTE rgbtGreen;
    // BYTE rgbtRed;

var x, y, Tmp  : integer;   // colonnes, lignes
    Row   : PRGBArray;  // pointeur scanline
    R,G,B, _R,_G,_B : integer;  // les 3 couleurs
    CorOrigR, CorOrigG, CorOrigB : integer;  // les 3 couleurs
    CorDestR, CorDestG, CorDestB : integer;  // les 3 couleurs

    SauvPixelFormat: TPixelFormat;
begin
  SauvPixelFormat := Bmp.PixelFormat;
  If Bmp.PixelFormat <> pf24Bit Then Bmp.PixelFormat := pf24Bit;

  Tmp := ColorToRGB(CorOrig);

  CorOrigR := GetRValue(Tmp);
  CorOrigG := GetGValue(Tmp);
  CorOrigB := GetBValue(Tmp);

  Tmp := ColorToRGB(CorDest);

  CorDestR := GetRValue(Tmp);
  CorDestG := GetGValue(Tmp);
  CorDestB := GetBValue(Tmp);

  For y := 0 to Bmp.height-1 do   // attention au -1
  begin
    row := Bmp.scanline[y];      // scanline

    for x := 0 to Bmp.width-1 do // attention au -1
    begin
      R := Row[x].rgbTred;
      G := Row[x].rgbTgreen;
      B := Row[x].rgbTblue;

      If (R >= CorOrigR - TolR) And (R <= CorOrigR + TolR)
        And (G >= CorOrigG - TolG) And (G <= CorOrigG + TolG)
          And (B >= CorOrigB - TolB) And (B <= CorOrigB + TolB)
      Then Begin
        If KeepIntervalColor
        Then Begin
          _R := CorDestR + (R - CorOrigR);
          _G := CorDestG + (G - CorOrigG);
          _B := CorDestB + (B - CorOrigB);

          if _R > 255 then _R := 255 else if _R < 0 then _R := 0;
          if _G > 255 then _G := 255 else if _G < 0 then _G := 0;
          if _B > 255 then _B := 255 else if _B < 0 then _B := 0;

          row[x].rgbtred   := _R;
          row[x].rgbtgreen := _G;
          row[x].rgbtblue  := _B;
        End
        Else Begin
          row[x].rgbtred   := CorDestR;
          row[x].rgbtgreen := CorDestG;
          row[x].rgbtblue  := CorDestB;
        End;
      End;
    end;
  end;

  If SauvPixelFormat <> pf24Bit Then Bmp.PixelFormat := SauvPixelFormat;

  If RefreshBmp Then Bmp.Modified := True;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  BackupBmp := TBitmap.Create;
  BackupBmp.Assign(Image1.Picture.Bitmap);
  //
  Image1.Parent.DoubleBuffered:=true;
end;

procedure TForm1.SBLoadClick(Sender: TObject);
begin
  if OpenDlg.Execute
  then begin
    Image1.Picture.LoadFromFile(OpenDlg.FileName);
    BackupBmp.Assign(Image1.Picture.Bitmap);
  end;
end;

procedure TForm1.Image1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin                 
  if Button = mbLeft
  then PanAltOrig.Color := Image1.Picture.Bitmap.Canvas.Pixels[x, y]
  else PanAltDest.Color := Image1.Picture.Bitmap.Canvas.Pixels[x, y];
end;

procedure TForm1.PanAltOrigClick(Sender: TObject);
begin
 ColorDlg.Color := PanAltOrig.Color;

 if ColorDlg.Execute
 then PanAltOrig.Color := ColorDlg.Color;
end;

procedure TForm1.PanAltDestClick(Sender: TObject);
begin
 ColorDlg.Color := PanAltDest.Color;

 if ColorDlg.Execute
 then PanAltDest.Color := ColorDlg.Color;
end;

procedure TForm1.BtnRefreshClick(Sender: TObject);
begin
  Image1.Picture.Bitmap.Assign(BackupBmp);
  
  BITMAP_SUBSTITUIR_COR(Image1.Picture.Bitmap, PanAltOrig.Color, PanAltDest.Color,
                        TrackBSubstCorR.Position, TrackBSubstCorG.Position, TrackBSubstCorB.Position,
                        CBFotoRendering.Checked, True);
end;

procedure TForm1.CBGroupedClick(Sender: TObject);

          procedure ALTERAR_POSICAO(_Track: TTrackBar; _Valor: Integer);
          begin
            _Track.OnChange := Nil;
            _Track.Position := _Valor;
            _Track.OnChange := CBGroupedClick;
          end;

var Valeur: Integer;
begin
  If CBGrouped.Checked
  Then Begin
    Valeur := TrackBSubstCorR.Position;
    If Sender = TrackBSubstCorG Then Valeur := TrackBSubstCorG.Position;
    If Sender = TrackBSubstCorB Then Valeur := TrackBSubstCorB.Position;

    ALTERAR_POSICAO(TrackBSubstCorR, Valeur);
    ALTERAR_POSICAO(TrackBSubstCorG, Valeur);
    ALTERAR_POSICAO(TrackBSubstCorB, Valeur);
  End;

  LblTolR.Caption := IntToStr(TrackBSubstCorR.Position);
  LblTolG.Caption := IntToStr(TrackBSubstCorG.Position);
  LblTolB.Caption := IntToStr(TrackBSubstCorB.Position);

  BtnRefresh.OnClick(Nil);
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  BackupBmp.Free; 
end;

end.
