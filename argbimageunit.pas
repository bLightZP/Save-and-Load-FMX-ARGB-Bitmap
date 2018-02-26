{

  Save and Load uncompressed ARGB (Alpha/Red/Green/Blue) images from/to a firemoney TBitmap, preserving transparency (Alpha channel).

}

unit argbimageunit;

interface 

uses
  System.Types, System.UITypes, System.SysUtils, System.Classes, FMX.Graphics, FMX.Types;


function LoadARGBBitmap(FileName : String; dstBitmap : TBitmap) : Boolean;
function SaveARGBBitmap(srcBitmap : TBitmap; FileName : String) : Boolean;


implementation


function LoadARGBBitmap(FileName : String; dstBitmap : TBitmap) : Boolean;
var
  Y                          : Integer;
  AlphaScanLine              : Array[0..4095] of TAlphaColor;
  bitmapData                 : FMX.Graphics.TBitmapData;
  tmpScanLine                : Pointer;
  fStream                    : TFileStream;
  iSize                      : TSize;
begin
  Result := False;
  Try
    fStream := TFileStream.Create(FileName,fmOpenRead);
  Except
    fStream := nil;
  End;

  If fStream <> nil then If fStream.Size > 8 then
  Begin
    fStream.Read(iSize,Sizeof(TSize));

    dstBitmap.SetSize(iSize.CX,iSize.CY); // Read image resolution from stream
    If dstBitmap.Map(TMapAccess.Write, bitmapData) then
    try
      For Y := 0 to dstBitmap.Height-1 do
      Begin
        fStream.Read(AlphaScanLine,iSize.CX*4);
        tmpScanLine := bitmapData.GetScanline(Y);
        AlphaColorToScanLine(@AlphaScanLine,tmpScanLine,dstBitmap.Width,dstBitmap.PixelFormat);
      End;
      Result := True;
    finally
      dstBitmap.Unmap(bitmapData);
    end;
    fStream.Free;
  End;
end;


function SaveARGBBitmap(srcBitmap : TBitmap; FileName : String) : Boolean;
var
  Y                          : Integer;
  AlphaScanLine              : Array[0..4095] of TAlphaColor;
  bitmapData                 : FMX.Graphics.TBitmapData;
  tmpScanLine                : Pointer;
  fStream                    : TFileStream;
  iSize                      : TSize;
begin
  Result := False;
  Try
    fStream := TFileStream.Create(FileName,fmCreate);
  Except
    fStream := nil;
  End;

  If fStream <> nil then
  Begin
    iSize := srcBitmap.Size;
    fStream.Write(iSize,Sizeof(TSize));
    If srcBitmap.Map(TMapAccess.Read,bitmapData) then
    try
      For Y := 0 to srcBitmap.Height-1 do
      Begin
        tmpScanLine := bitmapData.GetScanline(Y);
        ScanlineToAlphaColor(tmpScanLine,@AlphaScanLine[0],SrcBitmap.Width,SrcBitmap.PixelFormat);
        fStream.Write(AlphaScanLine,SrcBitmap.Width*4);
      End;
      Result := True;
    finally
      srcBitmap.Unmap(bitmapData);
    end;
    fStream.Free;
  End;
end;

end.