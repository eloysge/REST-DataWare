unit uRESTDWMessageCoderQuotedPrintable;

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

Interface

Uses
 Classes,
 uRESTDWMessageCoder,
 uRESTDWMessage;

 Type
  TRESTDWMessageEncoderQuotedPrintable    = Class(TRESTDWMessageEncoder)
 Public
  Procedure Encode(ASrc  : TStream;
                   ADest : TStream); Override;
 End;
 TRESTDWMessageEncoderInfoQuotedPrintable = Class(TRESTDWMessageEncoderInfo)
 Public
  Constructor Create; Override;
 End;

Implementation

Uses
  uRESTDWCoder, uRESTDWCoderMIME, uRESTDWCoderQuotedPrintable, uRESTDWException, SysUtils;

Constructor TRESTDWMessageEncoderInfoQuotedPrintable.Create;
Begin
 Inherited;
 FMessageEncoderClass := TRESTDWMessageEncoderQuotedPrintable;
End;

Procedure TRESTDWMessageEncoderQuotedPrintable.Encode(ASrc: TStream; ADest: TStream);
Var
 LEncoder : TRESTDWEncoderQuotedPrintable;
Begin
 LEncoder := TRESTDWEncoderQuotedPrintable.Create(Nil);
 Try
  LEncoder.Encode(ASrc, ADest);
 Finally
  FreeAndNil(LEncoder);
 End;
End;

Initialization
 TRESTDWMessageEncoderList.RegisterEncoder('QP', TRESTDWMessageEncoderInfoQuotedPrintable.Create);    {Do not Localize}

End.
