unit uRESTDWMessageCoderBinHex4;

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
  Classes,
  uRESTDWMessageCoder,
  uRESTDWMessage;

 Type
  TRESTDWMessageEncoderBinHex4 = Class(TRESTDWMessageEncoder)
 Public
  Procedure Encode(ASrc  : TStream;
                   ADest : TStream); Override;
 End;
 TRESTDWMessageEncoderInfoBinHex4 = class(TRESTDWMessageEncoderInfo)
 Public
  Constructor Create; Override;
 End;

Implementation

Uses
 uRESTDWCoder, uRESTDWCoderBinHex4, SysUtils;

Constructor TRESTDWMessageEncoderInfoBinHex4.Create;
Begin
 Inherited;
 FMessageEncoderClass := TRESTDWMessageEncoderBinHex4;
End;

Procedure TRESTDWMessageEncoderBinHex4.Encode(ASrc  : TStream;
                                              ADest : TStream);
Var
 LEncoder : TRESTDWEncoderBinHex4;
Begin
 LEncoder := TRESTDWEncoderBinHex4.Create(Nil);
 Try
  LEncoder.FileName := FileName;
  LEncoder.Encode(ASrc, ADest);
 Finally
  FreeAndNil(LEncoder);
 End;
End;

Initialization
 TRESTDWMessageEncoderList.RegisterEncoder('binhex4', TRESTDWMessageEncoderInfoBinHex4.Create);    {Do not Localize}

End.
