unit DWDCPcast256;

{$I ..\..\Includes\uRESTDW.inc}

{
  REST Dataware .
  Criado por XyberX (Gilbero Rocha da Silva), o REST Dataware tem como objetivo o uso de REST/JSON
 de maneira simples, em qualquer Compilador Pascal (Delphi, Lazarus e outros...).
  O REST Dataware tamb�m tem por objetivo levar componentes compat�veis entre o Delphi e outros Compiladores
 Pascal e com compatibilidade entre sistemas operacionais.
  Desenvolvido para ser usado de Maneira RAD, o REST Dataware tem como objetivo principal voc� usu�rio que precisa
 de produtividade e flexibilidade para produ��o de Servi�os REST/JSON, simplificando o processo para voc� programador.

 Membros do Grupo :

 XyberX (Gilberto Rocha)    - Admin - Criador e Administrador  do pacote.
 Alexandre Abbade           - Admin - Administrador do desenvolvimento de DEMOS, coordenador do Grupo.
 Anderson Fiori             - Admin - Gerencia de Organiza��o dos Projetos
 Fl�vio Motta               - Member Tester and DEMO Developer.
 Mobius One                 - Devel, Tester and Admin.
 Gustavo                    - Criptografia and Devel.
 Eloy                       - Devel.
 Roniery                    - Devel.
}

interface
uses
  Classes, Sysutils, DWDCPtypes, DWDCPcrypt2, DWDCPconst, DWDCPblockciphers;

type
  TRESTDWDCP_cast256= class(TDWDCP_blockcipher128)
  protected
    Kr, Km: array[0..11,0..3] of DWord;
    procedure InitKey(const Key; Size: longword); override;
  public
    class function GetId: integer; override;
    class function GetAlgorithm: string; override;
    class function GetMaxKeySize: integer; override;
    class function SelfTest: boolean; override;
    procedure Burn; override;
    procedure EncryptECB(const InData; var OutData); override;
    procedure DecryptECB(const InData; var OutData); override;
  end;


{******************************************************************************}
{******************************************************************************}
implementation
{$R-}{$Q-}
{$I DWDCPcast256.inc}

{$IFDEF SUPPORTS_UNICODE_STRING}
  {$POINTERMATH ON}
{$ENDIF}

function LRot32(a, n: dword): dword;
begin
  Result:= (a shl n) or (a shr (32-n));
end;

function SwapDword(a: dword): dword;
begin
  Result:= ((a and $FF) shl 24) or ((a and $FF00) shl 8) or ((a and $FF0000) shr 8) or ((a and $FF000000) shr 24);
end;

function F1(a,rk,mk: DWord): DWord;
var
  t: DWord;
begin
  t:= LRot32(mk + a,rk);
  Result:= ((S1[t shr 24] xor S2[(t shr 16) and $FF]) - S3[(t shr 8) and $FF]) + S4[t and $FF];
end;
function F2(a,rk,mk: DWord): DWord;
var
  t: DWord;
begin
  t:= LRot32(mk xor a,rk);
  Result:= ((S1[t shr 24] - S2[(t shr 16) and $FF]) + S3[(t shr 8) and $FF]) xor S4[t and $FF];
end;
function F3(a,rk,mk: DWord): DWord;
var
  t: DWord;
begin
  t:= LRot32(mk - a,rk);
  Result:= ((S1[t shr 24] + S2[(t shr 16) and $FF]) xor S3[(t shr 8) and $FF]) - S4[t and $FF];
end;

class function TRESTDWDCP_cast256.GetMaxKeySize: integer;
begin
  Result:= 256;
end;

class function TRESTDWDCP_cast256.GetId: integer;
begin
  Result:= DWDCP_cast256;
end;

class function TRESTDWDCP_cast256.GetAlgorithm: string;
begin
  Result:= 'Cast256';
end;

class function TRESTDWDCP_cast256.SelfTest: boolean;
const
  Key1: array[0..15] of byte=
    ($23,$42,$bb,$9e,$fa,$38,$54,$2c,$0a,$f7,$56,$47,$f2,$9f,$61,$5d);
  InBlock1: array[0..15] of byte=
    ($00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0c,$9b,$28,$07);
  OutBlock1: array[0..15] of byte=
    ($96,$3a,$8a,$50,$ce,$b5,$4d,$08,$e0,$de,$e0,$f1,$d0,$41,$3d,$cf);
  Key2: array[0..23] of byte=
    ($23,$42,$bb,$9e,$fa,$38,$54,$2c,$be,$d0,$ac,$83,$94,$0a,$c2,$98,$ba,$c7,$7a,$77,$17,$94,$28,$63);
  InBlock2: array[0..15] of byte=
    ($00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$de,$25,$5a,$ff);
  OutBlock2: array[0..15] of byte=
    ($2b,$c1,$92,$9f,$30,$13,$47,$a9,$9d,$3f,$3e,$45,$ad,$34,$01,$e8);
  Key3: array[0..31] of byte=
    ($23,$42,$bb,$9e,$fa,$38,$54,$2c,$be,$d0,$ac,$83,$94,$0a,$c2,$98,$8d,$7c,$47,$ce,$26,$49,$08,$46,$1c,$c1,$b5,$13,$7a,$e6,$b6,$04);
  InBlock3: array[0..15] of byte=
    ($00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$c5,$fc,$eb,$19);
  OutBlock3: array[0..15] of byte=
    ($1e,$2e,$bc,$6c,$9f,$2e,$43,$8e,$1d,$90,$d9,$b9,$c6,$85,$32,$86);
var
  Block: array[0..15] of byte;
  Cipher: TRESTDWDCP_cast256;
begin
  FillChar(Block, SizeOf(Block), 0);
  Cipher:= TRESTDWDCP_cast256.Create(nil);
  Cipher.Init(Key1,Sizeof(Key1)*8,nil);
  Cipher.EncryptECB(InBlock1,Block);
  Result:= boolean(CompareMem(@Block,@OutBlock1,8));
  Cipher.DecryptECB(Block,Block);
  Result:= Result and boolean(CompareMem(@Block,@InBlock1,16));
  Cipher.Burn;
  Cipher.Init(Key2,Sizeof(Key2)*8,nil);
  Cipher.EncryptECB(InBlock2,Block);
  Result:= Result and boolean(CompareMem(@Block,@OutBlock2,8));
  Cipher.DecryptECB(Block,Block);
  Result:= Result and boolean(CompareMem(@Block,@InBlock2,16));
  Cipher.Burn;
  Cipher.Init(Key3,Sizeof(Key3)*8,nil);
  Cipher.EncryptECB(InBlock3,Block);
  Result:= Result and boolean(CompareMem(@Block,@OutBlock3,8));
  Cipher.DecryptECB(Block,Block);
  Result:= Result and boolean(CompareMem(@Block,@InBlock3,16));
  Cipher.Burn;
  Cipher.Free;
end;

procedure TRESTDWDCP_cast256.InitKey(const Key; Size: longword);
var
  x: array[0..7] of DWord;
  cm, cr: DWord;
  i, j: longword;
  tr, tm: array[0..7] of DWord;
begin
  Size:= Size div 8;

  FillChar(x,Sizeof(x),0);
  Move(Key,x,Size);

  cm:= $5a827999;
  cr:= 19;
  for i:= 0 to 7 do
    x[i]:= (x[i] shl 24) or ((x[i] shl 8) and $FF0000) or ((x[i] shr 8) and $FF00) or (x[i] shr 24);
  for i:= 0 to 11 do
  begin
    for j:= 0 to 7 do
    begin
      tm[j]:= cm;
      Inc(cm,$6ed9eba1);
      tr[j]:= cr;
      Inc(cr,17);
    end;
    x[6]:= x[6] xor f1(x[7],tr[0],tm[0]);
    x[5]:= x[5] xor f2(x[6],tr[1],tm[1]);
    x[4]:= x[4] xor f3(x[5],tr[2],tm[2]);
    x[3]:= x[3] xor f1(x[4],tr[3],tm[3]);
    x[2]:= x[2] xor f2(x[3],tr[4],tm[4]);
    x[1]:= x[1] xor f3(x[2],tr[5],tm[5]);
    x[0]:= x[0] xor f1(x[1],tr[6],tm[6]);
    x[7]:= x[7] xor f2(x[0],tr[7],tm[7]);

    for j:= 0 to 7 do
    begin
      tm[j]:= cm;
      Inc(cm,$6ed9eba1);
      tr[j]:= cr;
      Inc(cr,17);
    end;
    x[6]:= x[6] xor f1(x[7],tr[0],tm[0]);
    x[5]:= x[5] xor f2(x[6],tr[1],tm[1]);
    x[4]:= x[4] xor f3(x[5],tr[2],tm[2]);
    x[3]:= x[3] xor f1(x[4],tr[3],tm[3]);
    x[2]:= x[2] xor f2(x[3],tr[4],tm[4]);
    x[1]:= x[1] xor f3(x[2],tr[5],tm[5]);
    x[0]:= x[0] xor f1(x[1],tr[6],tm[6]);
    x[7]:= x[7] xor f2(x[0],tr[7],tm[7]);

    Kr[i,0]:= x[0] and 31;
    Kr[i,1]:= x[2] and 31;
    Kr[i,2]:= x[4] and 31;
    Kr[i,3]:= x[6] and 31;
    Km[i,0]:= x[7];
    Km[i,1]:= x[5];
    Km[i,2]:= x[3];
    Km[i,3]:= x[1];
  end;
  FillChar(x,Sizeof(x),$FF);
end;

procedure TRESTDWDCP_cast256.Burn;
begin
  FillChar(Kr,Sizeof(Kr),$FF);
  FillChar(Km,Sizeof(Km),$FF);
  inherited Burn;
end;

procedure TRESTDWDCP_cast256.EncryptECB(const InData; var OutData);
var
  A: array[0..3] of DWord;
begin
  if not fInitialized then
    raise EDWDCP_blockcipher.Create('Cipher not initialized');
  A[0]:= PDWord(@InData)^;

  A[1]:= PDWord(PointerToInt(@InData)+4)^;
  A[2]:= PDWord(PointerToInt(@InData)+8)^;
  A[3]:= PDWord(PointerToInt(@InData)+12)^;

  A[0]:= SwapDWord(A[0]);
  A[1]:= SwapDWord(A[1]);
  A[2]:= SwapDWord(A[2]);
  A[3]:= SwapDWord(A[3]);

  A[2]:= A[2] xor f1(A[3],kr[0,0],km[0,0]);
  A[1]:= A[1] xor f2(A[2],kr[0,1],km[0,1]);
  A[0]:= A[0] xor f3(A[1],kr[0,2],km[0,2]);
  A[3]:= A[3] xor f1(A[0],kr[0,3],km[0,3]);
  A[2]:= A[2] xor f1(A[3],kr[1,0],km[1,0]);
  A[1]:= A[1] xor f2(A[2],kr[1,1],km[1,1]);
  A[0]:= A[0] xor f3(A[1],kr[1,2],km[1,2]);
  A[3]:= A[3] xor f1(A[0],kr[1,3],km[1,3]);
  A[2]:= A[2] xor f1(A[3],kr[2,0],km[2,0]);
  A[1]:= A[1] xor f2(A[2],kr[2,1],km[2,1]);
  A[0]:= A[0] xor f3(A[1],kr[2,2],km[2,2]);
  A[3]:= A[3] xor f1(A[0],kr[2,3],km[2,3]);
  A[2]:= A[2] xor f1(A[3],kr[3,0],km[3,0]);
  A[1]:= A[1] xor f2(A[2],kr[3,1],km[3,1]);
  A[0]:= A[0] xor f3(A[1],kr[3,2],km[3,2]);
  A[3]:= A[3] xor f1(A[0],kr[3,3],km[3,3]);
  A[2]:= A[2] xor f1(A[3],kr[4,0],km[4,0]);
  A[1]:= A[1] xor f2(A[2],kr[4,1],km[4,1]);
  A[0]:= A[0] xor f3(A[1],kr[4,2],km[4,2]);
  A[3]:= A[3] xor f1(A[0],kr[4,3],km[4,3]);
  A[2]:= A[2] xor f1(A[3],kr[5,0],km[5,0]);
  A[1]:= A[1] xor f2(A[2],kr[5,1],km[5,1]);
  A[0]:= A[0] xor f3(A[1],kr[5,2],km[5,2]);
  A[3]:= A[3] xor f1(A[0],kr[5,3],km[5,3]);

  A[3]:= A[3] xor f1(A[0],kr[6,3],km[6,3]);
  A[0]:= A[0] xor f3(A[1],kr[6,2],km[6,2]);
  A[1]:= A[1] xor f2(A[2],kr[6,1],km[6,1]);
  A[2]:= A[2] xor f1(A[3],kr[6,0],km[6,0]);
  A[3]:= A[3] xor f1(A[0],kr[7,3],km[7,3]);
  A[0]:= A[0] xor f3(A[1],kr[7,2],km[7,2]);
  A[1]:= A[1] xor f2(A[2],kr[7,1],km[7,1]);
  A[2]:= A[2] xor f1(A[3],kr[7,0],km[7,0]);
  A[3]:= A[3] xor f1(A[0],kr[8,3],km[8,3]);
  A[0]:= A[0] xor f3(A[1],kr[8,2],km[8,2]);
  A[1]:= A[1] xor f2(A[2],kr[8,1],km[8,1]);
  A[2]:= A[2] xor f1(A[3],kr[8,0],km[8,0]);
  A[3]:= A[3] xor f1(A[0],kr[9,3],km[9,3]);
  A[0]:= A[0] xor f3(A[1],kr[9,2],km[9,2]);
  A[1]:= A[1] xor f2(A[2],kr[9,1],km[9,1]);
  A[2]:= A[2] xor f1(A[3],kr[9,0],km[9,0]);
  A[3]:= A[3] xor f1(A[0],kr[10,3],km[10,3]);
  A[0]:= A[0] xor f3(A[1],kr[10,2],km[10,2]);
  A[1]:= A[1] xor f2(A[2],kr[10,1],km[10,1]);
  A[2]:= A[2] xor f1(A[3],kr[10,0],km[10,0]);
  A[3]:= A[3] xor f1(A[0],kr[11,3],km[11,3]);
  A[0]:= A[0] xor f3(A[1],kr[11,2],km[11,2]);
  A[1]:= A[1] xor f2(A[2],kr[11,1],km[11,1]);
  A[2]:= A[2] xor f1(A[3],kr[11,0],km[11,0]);
  A[0]:= SwapDWord(A[0]);
  A[1]:= SwapDWord(A[1]);
  A[2]:= SwapDWord(A[2]);
  A[3]:= SwapDWord(A[3]);

  PDWord(@OutData)^:= A[0];
  PDWord(PointerToInt(@OutData)+4)^:= A[1];
  PDWord(PointerToInt(@OutData)+8)^:= A[2];
  PDWord(PointerToInt(@OutData)+12)^:= A[3];
end;

procedure TRESTDWDCP_cast256.DecryptECB(const InData; var OutData);
var
  A: array[0..3] of DWord;
begin
  if not fInitialized then
    raise EDWDCP_blockcipher.Create('Cipher not initialized');
  A[0]:= PDWord(@InData)^;
  A[1]:= PDWord(PointerToInt(@InData)+4)^;
  A[2]:= PDWord(PointerToInt(@InData)+8)^;
  A[3]:= PDWord(PointerToInt(@InData)+12)^;

  A[0]:= SwapDWord(A[0]);
  A[1]:= SwapDWord(A[1]);
  A[2]:= SwapDWord(A[2]);
  A[3]:= SwapDWord(A[3]);
  A[2]:= A[2] xor f1(A[3],kr[11,0],km[11,0]);
  A[1]:= A[1] xor f2(A[2],kr[11,1],km[11,1]);
  A[0]:= A[0] xor f3(A[1],kr[11,2],km[11,2]);
  A[3]:= A[3] xor f1(A[0],kr[11,3],km[11,3]);
  A[2]:= A[2] xor f1(A[3],kr[10,0],km[10,0]);
  A[1]:= A[1] xor f2(A[2],kr[10,1],km[10,1]);
  A[0]:= A[0] xor f3(A[1],kr[10,2],km[10,2]);
  A[3]:= A[3] xor f1(A[0],kr[10,3],km[10,3]);
  A[2]:= A[2] xor f1(A[3],kr[9,0],km[9,0]);
  A[1]:= A[1] xor f2(A[2],kr[9,1],km[9,1]);
  A[0]:= A[0] xor f3(A[1],kr[9,2],km[9,2]);
  A[3]:= A[3] xor f1(A[0],kr[9,3],km[9,3]);
  A[2]:= A[2] xor f1(A[3],kr[8,0],km[8,0]);
  A[1]:= A[1] xor f2(A[2],kr[8,1],km[8,1]);
  A[0]:= A[0] xor f3(A[1],kr[8,2],km[8,2]);
  A[3]:= A[3] xor f1(A[0],kr[8,3],km[8,3]);
  A[2]:= A[2] xor f1(A[3],kr[7,0],km[7,0]);
  A[1]:= A[1] xor f2(A[2],kr[7,1],km[7,1]);
  A[0]:= A[0] xor f3(A[1],kr[7,2],km[7,2]);
  A[3]:= A[3] xor f1(A[0],kr[7,3],km[7,3]);
  A[2]:= A[2] xor f1(A[3],kr[6,0],km[6,0]);
  A[1]:= A[1] xor f2(A[2],kr[6,1],km[6,1]);
  A[0]:= A[0] xor f3(A[1],kr[6,2],km[6,2]);
  A[3]:= A[3] xor f1(A[0],kr[6,3],km[6,3]);

  A[3]:= A[3] xor f1(A[0],kr[5,3],km[5,3]);
  A[0]:= A[0] xor f3(A[1],kr[5,2],km[5,2]);
  A[1]:= A[1] xor f2(A[2],kr[5,1],km[5,1]);
  A[2]:= A[2] xor f1(A[3],kr[5,0],km[5,0]);
  A[3]:= A[3] xor f1(A[0],kr[4,3],km[4,3]);
  A[0]:= A[0] xor f3(A[1],kr[4,2],km[4,2]);
  A[1]:= A[1] xor f2(A[2],kr[4,1],km[4,1]);
  A[2]:= A[2] xor f1(A[3],kr[4,0],km[4,0]);
  A[3]:= A[3] xor f1(A[0],kr[3,3],km[3,3]);
  A[0]:= A[0] xor f3(A[1],kr[3,2],km[3,2]);
  A[1]:= A[1] xor f2(A[2],kr[3,1],km[3,1]);
  A[2]:= A[2] xor f1(A[3],kr[3,0],km[3,0]);
  A[3]:= A[3] xor f1(A[0],kr[2,3],km[2,3]);
  A[0]:= A[0] xor f3(A[1],kr[2,2],km[2,2]);
  A[1]:= A[1] xor f2(A[2],kr[2,1],km[2,1]);
  A[2]:= A[2] xor f1(A[3],kr[2,0],km[2,0]);
  A[3]:= A[3] xor f1(A[0],kr[1,3],km[1,3]);
  A[0]:= A[0] xor f3(A[1],kr[1,2],km[1,2]);
  A[1]:= A[1] xor f2(A[2],kr[1,1],km[1,1]);
  A[2]:= A[2] xor f1(A[3],kr[1,0],km[1,0]);
  A[3]:= A[3] xor f1(A[0],kr[0,3],km[0,3]);
  A[0]:= A[0] xor f3(A[1],kr[0,2],km[0,2]);
  A[1]:= A[1] xor f2(A[2],kr[0,1],km[0,1]);
  A[2]:= A[2] xor f1(A[3],kr[0,0],km[0,0]);
  A[0]:= SwapDWord(A[0]);
  A[1]:= SwapDWord(A[1]);
  A[2]:= SwapDWord(A[2]);
  A[3]:= SwapDWord(A[3]);

  PDWord(@OutData)^:= A[0];
  PDWord(PointerToInt(@OutData)+4)^:= A[1];
  PDWord(PointerToInt(@OutData)+8)^:= A[2];
  PDWord(PointerToInt(@OutData)+12)^:= A[3];
end;


end.
