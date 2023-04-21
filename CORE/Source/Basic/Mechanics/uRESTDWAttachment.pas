Unit uRESTDWAttachment;

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
 uRESTDWMessageParts;

 Type
  TRESTDWAttachment = Class(TRESTDWMessagePart)
 Public
  Function  OpenLoadStream    : TStream; Virtual; Abstract;
  Procedure CloseLoadStream;             Virtual; Abstract;
  Function  PrepareTempStream : TStream; Virtual; Abstract;
  Procedure FinishTempStream;            Virtual; Abstract;
  Procedure LoadFromFile(Const aFileName : String); Virtual;
  Procedure LoadFromStream(AStream: TStream);      Virtual;
  Procedure SaveToFile  (Const aFileName : String); Virtual;
  Procedure SaveToStream(AStream : TStream);       Virtual;
  Class Function PartType : TRESTDWMessagePartType; Override;
 End;
 TRESTDWAttachmentClass = Class Of TRESTDWAttachment;

Implementation

Uses
 uRESTDWBasicTypes, uRESTDWTools, uRESTDWConsts, SysUtils;

Class Function TRESTDWAttachment.PartType: TRESTDWMessagePartType;
Begin
 Result := mptAttachment;
End;

Procedure TRESTDWAttachment.LoadFromFile(const aFileName: String);
Var
 LStrm : TRESTDWReadFileExclusiveStream;
Begin
 LStrm := TRESTDWReadFileExclusiveStream.Create(aFileName);
 Try
  LoadFromStream(LStrm);
 Finally
  FreeAndNil(LStrm);
 End;
End;

Procedure TRESTDWAttachment.LoadFromStream(AStream: TStream);
Var
 LStrm : TStream;
Begin
 LStrm := PrepareTempStream;
 Try
  LStrm.CopyFrom(AStream, 0);
 Finally
  FinishTempStream;
 End;
End;

Procedure TRESTDWAttachment.SaveToFile(const aFileName: String);
Var
 LStrm : TRESTDWFileCreateStream;
Begin
 LStrm := TRESTDWFileCreateStream.Create(aFileName);
 Try
  SaveToStream(LStrm);
 Finally
  FreeAndNil(LStrm);
 End;
End;

Procedure TRESTDWAttachment.SaveToStream(AStream: TStream);
Var
 LStrm : TStream;
Begin
 LStrm := OpenLoadStream;
 Try
  AStream.CopyFrom(LStrm, 0);
 Finally
  CloseLoadStream;
 End;
End;

End.

