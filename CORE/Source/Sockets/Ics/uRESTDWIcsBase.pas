unit uRESTDWIcsBase;

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
  A. Brito                   - Admin - Administrador do desenvolvimento.
  Alexandre Abbade           - Admin - Administrador do desenvolvimento de DEMOS, coordenador do Grupo.
  Fl�vio Motta               - Member Tester and DEMO Developer.
  Mobius One                 - Devel, Tester and Admin.
  Gustavo                    - Criptografia and Devel.
  Eloy                       - Devel.
  Roniery                    - Devel.
}

// TODO 0
// Portar TODAS as classes;
// Portado TRESTServicePoolerBase;

// TODO 1
// Inserir outras propriedades do SSL no Pooler (SetHttpServerSSL);

// TODO 2
// Passar par�metros do diret�rio, p�gina e url padr�o (SetParamsHttpConnection);

interface

uses
  SysUtils, Classes, DateUtils, SyncObjs,
{$IFDEF DELPHIXE2UP}vcl.ExtCtrls{$ELSE}ExtCtrls{$ENDIF},

  uRESTDWComponentEvents, uRESTDWBasicTypes, uRESTDWJSONObject, uRESTDWBasic,
  uRESTDWBasicDB, uRESTDWParams, uRESTDWBasicClass, uRESTDWAbout,
  uRESTDWConsts, uRESTDWDataUtils, uRESTDWTools, uRESTDWAuthenticators,

  OverbyteIcsWinSock, OverbyteIcsWSocket, OverbyteIcsWndControl,
  OverbyteIcsHttpAppServer, OverbyteIcsUtils, OverbyteIcsFormDataDecoder,
  OverbyteIcsMimeUtils, OverbyteIcsSSLEAY, OverbyteIcsHttpSrv,
  OverbyteIcsWSocketS, OverbyteIcsSslX509Utils;

type
  TPoolerHttpConnection = class(THttpAppSrvConnection)
  protected
    vRawData: AnsiString;
    vRawDataLen: Integer;
    vNeedClose: boolean;
    vBytesIn, vBytesOut: Int64;
    vProcessDocumentThread: TThread;
  public
    function GetTrafficInBytes: Int64;
    function GetTrafficOutBytes: Int64;
    procedure ProcessDocument(Sender: TObject; BodyStream: TStream; Flag: THttpGetFlag;
      ServicePooler: TRESTServicePoolerBase);
    destructor Destroy; override;
    constructor Create(AOwner: TComponent); override;
  end;

  TOnException = procedure(Sender: TPoolerHttpConnection; Error: string) of object;
  TOnServerStarted = procedure(Sender: TObject) of object;
  TOnServerStopped = procedure(Sender: TObject) of object;
  TOnClientConnect = procedure(Sender: TPoolerHttpConnection; Error: Word) of object;
  TOnClientDisconnect = procedure(Sender: TPoolerHttpConnection; Error: Word) of object;
  TOnDocumentReady = procedure(Sender: TPoolerHttpConnection; var Flags: THttpGetFlag)
    of object;
  TOnAnswered = procedure(Sender: TPoolerHttpConnection) of object;
  TOnTimeout = procedure(Sender: TPoolerHttpConnection; Reason: TTimeoutReason) of object;
  TOnBlackListBlock = procedure(IP, Port: string) of object;
  TOnBruteForceBlock = procedure(IP, Port: string) of object;
  TOnServerStatusCheckBlock = procedure(IP, Port: string) of object;

  TIcsSelfAssignedCert = class(TPersistent)
  private
    vAutoGenerateOnStart: boolean;
    vCountry: string;
    vState: string;
    vLocality: string;
    vOrganization: string;
    vOrgUnit: string;
    vExpireDays: Integer;
    vEmail: string;
    vCommonName: string;
    vPrivKeyType: TSslPrivKeyType;
    vCertDigest: TEvpDigest;
    vCert: TSslCertTools;
  public
    constructor Create;
    destructor Destroy; override;
    procedure CreateCertificate;
    function CertificateString: string;
    function PrivateKeyString: string;
  published
    property AutoGenerateOnStart: boolean read vAutoGenerateOnStart
      write vAutoGenerateOnStart default false;
    property Country: string read vCountry write vCountry;
    property State: string read vState write vState;
    property Locality: string read vLocality write vLocality;
    property Organization: string read vOrganization write vOrganization;
    property OrganizationUnit: string read vOrgUnit write vOrgUnit;
    property Email: string read vEmail write vEmail;
    property ExpireDays: Integer read vExpireDays write vExpireDays default 365;
    property CommonName: string read vCommonName write vCommonName;
    property PrivateKeyType: TSslPrivKeyType read vPrivKeyType write vPrivKeyType
      default PrivKeyRsa4096;
    property CertificateDigestType: TEvpDigest read vCertDigest write vCertDigest
      default Digest_sha512;
  end;

  TIcsBruteForceProtection = class(TPersistent)
  private
    vBruteForceCS: TCriticalSection;
    vBruteForceSampleMin: Integer;
    vBruteForceTry: Integer;
    vBruteForceExpirationMin: Integer;
    vBruteForceList: TStringList;
    vBruteForceProtectionStatus: boolean;
    vBruteForceTimer: TTimer;
    function GetBruteForceIndex(IP: string): Integer;
  public
    constructor Create;
    destructor Destroy; override;
    procedure ClearBruteForceList;
    procedure StartBruteForce;
    procedure StopBruteForce;
    procedure SampleBruteForce(Sender: TObject);
    procedure BruteForceAttempt(IP: string);
    function BruteForceAllow(IP: string): boolean;
  published
    property BruteForceProtectionStatus: boolean read vBruteForceProtectionStatus
      write vBruteForceProtectionStatus default true;
    property BruteForceSampleMin: Integer read vBruteForceSampleMin
      write vBruteForceSampleMin default 1;
    // Sampling time in minutes to clear blocked IP
    property BruteForceTry: Integer read vBruteForceTry write vBruteForceTry default 3;
    // Attempt times before block
    property BruteForceExpirationMin: Integer read vBruteForceExpirationMin
      write vBruteForceExpirationMin default 30; // Blocked IP expiration time in minutes
  end;

  TRESTDWIcsServicePooler = class(TRESTServicePoolerBase)
  private
    // Events
    vOnException: TOnException;
    vOnServerStarted: TOnServerStarted;
    vOnServerStopped: TOnServerStopped;
    vOnClientConnect: TOnClientConnect;
    vOnClientDisconnect: TOnClientDisconnect;
    vOnDocumentReady: TOnDocumentReady;
    vOnAnswered: TOnAnswered;
    vOnTimeout: TOnTimeout;
    vOnBlackListBlock: TOnBlackListBlock;
    vOnBruteForceBlock: TOnBruteForceBlock;
    vOnServerStatusCheckBlock: TOnServerStatusCheckBlock;

    // HTTP Server
    HttpAppSrv: TSslHttpAppSrv;

    // SSL Params
    vSSLRootCertFile, vSSLPrivateKeyFile, vSSLPrivateKeyPassword, vSSLCertFile: string;
    vSSLVerMethodMin, vSSLVerMethodMax: TSslVerMethod;
    vSSLVerifyMode: TSslVerifyPeerModes;
    vSSLVerifyDepth: Integer;
    vSSLVerifyPeer: boolean;
    vSSLCacheModes: TSslSessCacheModes;
    vSSLTimeoutSec: Cardinal;
    vSSLUse: boolean;
    vSSLCliCertMethod: TSslCliCertMethod;
    vIcsSelfAssignedCert: TIcsSelfAssignedCert;

    // HTTP Params
    vMaxClients: Integer;
    vServiceTimeout: Integer;
    vBuffSizeBytes: Integer;
    vBandWidthLimitBytes: Cardinal;
    vBandWidthSampleSec: Cardinal;
    vListenBacklog: Integer;

    // Security
    vBruteForceProtection: TIcsBruteForceProtection;
    vIpBlackList: TStrings;
    vServerStatusCheck: boolean;

    // Misc
    procedure DisconnectClient(Client: TPoolerHttpConnection; Server: TSslHttpAppSrv);

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    // Document procedures
    procedure onDocumentReadyServer(Sender: TObject; var Flag: THttpGetFlag);
    procedure onPostedDataServer(Sender: TObject; ErrCode: Word);
    procedure onExceptionServer(Sender: TObject; E: ESocketException);
    procedure onServerStartedServer(Sender: TObject);
    procedure onServerStoppedServer(Sender: TObject);
    procedure onAnsweredServer(Sender: TObject);
    procedure CustomAnswerStream(Pooler: TPoolerHttpConnection; Flag: THttpGetFlag;
      StatusCode: Integer; ContentType, Header: string);

    // Prepare procedures
    procedure SetHttpServerSSL;
    procedure SetHttpServerParams;
    procedure SetSocketServerParams;
    procedure SetHttpConnectionParams(Remote: TPoolerHttpConnection);

    // Misc Procedures
    function ClientCount: Integer;
    procedure SetActive(Value: boolean); override;
    procedure EchoPooler(ServerMethodsClass: TComponent; AContext: TComponent;
      var Pooler, MyIP: string; AccessTag: string; var InvalidTag: boolean); override;
    procedure onClientTimeout(Sender: TObject; Reason: TTimeoutReason);
    procedure onClientConnectServer(Sender: TObject; Client: TObject; Error: Word);
    procedure onClientDisconnectServer(Sender: TObject; Client: TObject; Error: Word);

  published
    // Events
    property OnException: TOnException read vOnException write vOnException;
    property OnServerStarted: TOnServerStarted read vOnServerStarted
      write vOnServerStarted;
    property OnServerStopped: TOnServerStopped read vOnServerStopped
      write vOnServerStopped;
    property OnClientConnect: TOnClientConnect read vOnClientConnect
      write vOnClientConnect;
    property OnClientDisconnect: TOnClientDisconnect read vOnClientDisconnect
      write vOnClientDisconnect;
    property OnDocumentReady: TOnDocumentReady read vOnDocumentReady
      write vOnDocumentReady;
    property OnAnswered: TOnAnswered read vOnAnswered write vOnAnswered;
    property OnTimeout: TOnTimeout read vOnTimeout write vOnTimeout;
    property OnBlackListBlock: TOnBlackListBlock read vOnBlackListBlock
      write vOnBlackListBlock;
    property OnBruteForceBlock: TOnBruteForceBlock read vOnBruteForceBlock
      write vOnBruteForceBlock;
    property OnServerStatusCheckBlock: TOnServerStatusCheckBlock
      read vOnServerStatusCheckBlock write vOnServerStatusCheckBlock;

    // SSL Params
    property SSLRootCertFile: string read vSSLRootCertFile write vSSLRootCertFile;
    property SSLPrivateKeyFile: string read vSSLPrivateKeyFile write vSSLPrivateKeyFile;
    property SSLPrivateKeyPassword: string read vSSLPrivateKeyPassword
      write vSSLPrivateKeyPassword;
    property SSLCertFile: string read vSSLCertFile write vSSLCertFile;
    property SSLVersionMin: TSslVerMethod read vSSLVerMethodMin write vSSLVerMethodMin
      default sslVerTLS1_2;
    property SSLVersionMax: TSslVerMethod read vSSLVerMethodMax write vSSLVerMethodMax
      default sslVerMax;
    property SSLVerifyMode: TSslVerifyPeerModes read vSSLVerifyMode write vSSLVerifyMode;
    property SSLVerifyDepth: Integer read vSSLVerifyDepth write vSSLVerifyDepth default 9;
    property SSLVerifyPeer: boolean read vSSLVerifyPeer write vSSLVerifyPeer
      default false;
    property SSLCacheModes: TSslSessCacheModes read vSSLCacheModes write vSSLCacheModes;
    property SSLTimeoutSec: Cardinal read vSSLTimeoutSec write vSSLTimeoutSec default 60;
    property SelfAssignedCert: TIcsSelfAssignedCert read vIcsSelfAssignedCert
      write vIcsSelfAssignedCert;

    // SSL TimeOut in Seconds
    property SSLUse: boolean read vSSLUse write vSSLUse default false;
    property SSLCliCertMethod: TSslCliCertMethod read vSSLCliCertMethod
      write vSSLCliCertMethod;

    // HTTP Params
    property MaxClients: Integer read vMaxClients write vMaxClients default 0;
    property RequestTimeout: Integer read vServiceTimeout write vServiceTimeout
      default 60000; // Connection TimeOut in Milliseconds
    property BuffSizeBytes: Integer read vBuffSizeBytes write vBuffSizeBytes
      default 262144; // 256kb Default
    property BandWidthLimitBytes: Cardinal read vBandWidthLimitBytes
      write vBandWidthLimitBytes default 0;
    property BandWidthSamplingSec: Cardinal read vBandWidthSampleSec
      write vBandWidthSampleSec default 1;
    property ListenBacklog: Integer read vListenBacklog write vListenBacklog default 50;

    // Secutiry
    procedure SetvIpBlackList(Lines: TStrings);
    property IpBlackList: TStrings read vIpBlackList write SetvIpBlackList;
    property BruteForceProtection: TIcsBruteForceProtection read vBruteForceProtection
      write vBruteForceProtection;
    property ServerStatusCheck: boolean read vServerStatusCheck write vServerStatusCheck
      default true;
  end;

  TProcessDocumentThread = class(TThread)
  private
    vRemote: TPoolerHttpConnection;
    vBodyStream: TStream;
    vFlag: THttpGetFlag;
    vICSService: TRESTDWIcsServicePooler;
  protected
    procedure Execute; override;
  public
    property Remote: TPoolerHttpConnection read vRemote write vRemote;
    property BodyStream: TStream read vBodyStream write vBodyStream;
    property Flag: THttpGetFlag read vFlag write vFlag;
    property ICSService: TRESTDWIcsServicePooler read vICSService write vICSService;
    constructor Create;
    destructor Destroy; override;
  end;

const
  cIcsHTTPServerNotFound = 'No HTTP server found.';
  cIcsHTTPConnectionClosed = 'Closed HTTP connection.';
  cIcsCorruptedPackage = 'Corrupted package: RequestContentLength <> Stream.Size.';
  cIcsSSLLibNotFoundForSSLDisabled =
    'OpenSSL libs are required by ICS to digest AuthTypes Token and OAuth even if SSL is disabled.';

implementation

uses uRESTDWJSONInterface, vcl.Dialogs, OverbyteIcsWSockBuf; // , vcl.Forms;

procedure TRESTDWIcsServicePooler.SetHttpServerSSL;
var
  x: Integer;
begin
  if Assigned(HttpAppSrv) then
  begin
    if vSSLUse then
    begin
      HttpAppSrv.SSLContext := TSslContext.Create(HttpAppSrv);

      HttpAppSrv.SslEnable := true;

      for x := 0 to HttpAppSrv.MultiListenSockets.Count - 1 do
        HttpAppSrv.MultiListenSockets[x].SslEnable := true;

      HttpAppSrv.SSLContext.SslSessionTimeout := vSSLTimeoutSec;
      HttpAppSrv.SSLContext.SslSessionCacheModes := vSSLCacheModes;
      HttpAppSrv.SSLContext.SSLVerifyPeer := vSSLVerifyPeer;
      HttpAppSrv.SSLContext.SSLVerifyDepth := vSSLVerifyDepth;
      HttpAppSrv.SSLContext.SslVerifyPeerModes := vSSLVerifyMode;
      HttpAppSrv.SSLContext.SslMinVersion := vSSLVerMethodMin;
      HttpAppSrv.SSLContext.SslMaxVersion := vSSLVerMethodMax;

      if vIcsSelfAssignedCert.vAutoGenerateOnStart then
      begin
        vIcsSelfAssignedCert.CreateCertificate;

        HttpAppSrv.SSLContext.SslPrivKeyLines.Text :=
          vIcsSelfAssignedCert.PrivateKeyString;
        HttpAppSrv.SSLContext.SslCertLines.Text := vIcsSelfAssignedCert.CertificateString;
      end
      else
      begin
        HttpAppSrv.SSLContext.SSLCertFile := vSSLCertFile;
        HttpAppSrv.SSLContext.SslPrivKeyFile := vSSLPrivateKeyFile;
        HttpAppSrv.SSLContext.SslPassPhrase := vSSLPrivateKeyPassword;
        HttpAppSrv.RootCA := vSSLRootCertFile;
      end;

      // TODO 1
      HttpAppSrv.SSLContext.SslCliSecurity := TSslCliSecurity.sslCliSecIgnore;
      HttpAppSrv.SSLContext.SslSecLevel := TSslSecLevel.sslSecLevelAny;
    end
    else
    begin
      HttpAppSrv.SslEnable := false;

      for x := 0 to HttpAppSrv.MultiListenSockets.Count - 1 do
        HttpAppSrv.MultiListenSockets[x].SslEnable := false;

      // Destroy old SSL Context
      if Assigned(HttpAppSrv.SSLContext) then
      begin
        HttpAppSrv.SSLContext.Free;
        HttpAppSrv.SSLContext := nil;
      end;

      // OpenSSL libs are required by ICS to digest
      // AuthTypes rdwAOBearer, rdwAOToken and rdwOAuth even if SSL is disabled
      try
        if atDigest in HttpAppSrv.AuthTypes then
        begin
          HttpAppSrv.SSLContext := TSslContext.Create(HttpAppSrv);

          HttpAppSrv.SSLContext.InitializeSsl;
        end;
      except
        on E: Exception do
        begin
          raise Exception.Create(cIcsSSLLibNotFoundForSSLDisabled + #10#10 + E.Message);
        end;
      end;
    end;
  end
  else
    raise Exception.Create(cIcsHTTPServerNotFound);
end;

procedure TRESTDWIcsServicePooler.SetSocketServerParams;
begin
  HttpAppSrv.WSocketServer.BufSize := vBuffSizeBytes;
  HttpAppSrv.WSocketServer.SocketRcvBufSize := vBuffSizeBytes;
  HttpAppSrv.WSocketServer.SocketSndBufSize := vBuffSizeBytes;
end;

procedure TRESTDWIcsServicePooler.SetHttpServerParams;
var
  x: Integer;
  vKeepAliveTimeSec: Integer;
begin
  if Assigned(HttpAppSrv) then
  begin
    HttpAppSrv.ClientClass := TPoolerHttpConnection;

    HttpAppSrv.MaxClients := vMaxClients;
    HttpAppSrv.MaxRequestsKeepAlive := vMaxClients;

    if ((vServiceTimeout > 0) and (vServiceTimeout < 1000)) then
      vKeepAliveTimeSec := 1
    else if vServiceTimeout <= 0 then
      vKeepAliveTimeSec := 0
    else
      vKeepAliveTimeSec := trunc(vServiceTimeout / 1000);

    HttpAppSrv.KeepAliveTimeSec := vKeepAliveTimeSec;
    HttpAppSrv.KeepAliveTimeXferSec := vKeepAliveTimeSec;

    HttpAppSrv.SessionTimeout := vServiceTimeout;

    HttpAppSrv.MaxBlkSize := vBuffSizeBytes;

    HttpAppSrv.BandwidthLimit := vBandWidthLimitBytes;

    if vBandWidthSampleSec < 1 then
      HttpAppSrv.BandwidthSampling := 1000
    else
      HttpAppSrv.BandwidthSampling := vBandWidthSampleSec * 1000;

    HttpAppSrv.OnClientConnect := onClientConnectServer;
    HttpAppSrv.OnClientDisconnect := onClientDisconnectServer;
    HttpAppSrv.OnServerStarted := onServerStartedServer;
    HttpAppSrv.OnServerStopped := onServerStoppedServer;

    if Authenticator <> nil then
    begin
      if Authenticator is TRESTDWAuthBasic then
        HttpAppSrv.AuthTypes := [atBasic]
      else if (Authenticator is TRESTDWAuthToken) or (Authenticator is TRESTDWAuthOAuth)
      then
        HttpAppSrv.AuthTypes := [atDigest];
    end
    else
      HttpAppSrv.AuthTypes := [atNone];

    if ((ServerIPVersionConfig.ServerIpVersion = sivBoth) or
      (ServerIPVersionConfig.ServerIpVersion = sivIPv4)) then
    begin

      HttpAppSrv.Port := IntToStr(ServicePort);
      HttpAppSrv.ListenBacklog := vListenBacklog;
      HttpAppSrv.SocketFamily := sfAnyIPv4;
      HttpAppSrv.Addr := ServerIPVersionConfig.IPv4Address;

      HttpAppSrv.MultiListenSockets.Clear;

      if (ServerIPVersionConfig.ServerIpVersion = sivBoth) then
      begin
        with HttpAppSrv.MultiListenSockets.Add do
        begin

          Port := IntToStr(ServicePort);
          ListenBacklog := vListenBacklog;
          SocketFamily := sfAnyIPv6;
          Addr := ServerIPVersionConfig.IPv6Address;

        end;
      end;
    end
    else if (ServerIPVersionConfig.ServerIpVersion = sivIPv6) then
    begin

      HttpAppSrv.Port := IntToStr(ServicePort);
      HttpAppSrv.ListenBacklog := vListenBacklog;
      HttpAppSrv.SocketFamily := sfAnyIPv6;
      HttpAppSrv.Addr := ServerIPVersionConfig.IPv6Address;

      HttpAppSrv.MultiListenSockets.Clear;

    end;

  end
  else
    raise Exception.Create(cIcsHTTPServerNotFound);
end;

procedure TRESTDWIcsServicePooler.onExceptionServer(Sender: TObject; E: ESocketException);
var
  Remote: TPoolerHttpConnection;
begin
  Remote := Sender as TPoolerHttpConnection;

  if Assigned(vOnException) then
  begin
    if HttpAppSrv.IsClient(Remote) then
      vOnException(Remote, E.Message)
    else
      vOnException(nil, E.Message);
  end;
end;

procedure TRESTDWIcsServicePooler.onServerStartedServer(Sender: TObject);
begin
  if Assigned(vOnServerStarted) then
    vOnServerStarted(Sender);
end;

procedure TRESTDWIcsServicePooler.onServerStoppedServer(Sender: TObject);
begin
  if Assigned(vOnServerStopped) then
    vOnServerStopped(Sender);
end;

procedure TRESTDWIcsServicePooler.SetvIpBlackList(Lines: TStrings);
begin
  vIpBlackList.Assign(Lines);
end;

procedure TRESTDWIcsServicePooler.onClientTimeout(Sender: TObject;
  Reason: TTimeoutReason);
var
  Remote: TPoolerHttpConnection;
begin
  Remote := Sender as TPoolerHttpConnection;

  try
    if Assigned(vOnTimeout) then
      vOnTimeout(Remote, Reason);
  finally
    DisconnectClient(Remote, HttpAppSrv);
  end;
end;

procedure TRESTDWIcsServicePooler.SetHttpConnectionParams(Remote: TPoolerHttpConnection);
begin
  Remote.TimeoutIdle := vServiceTimeout;
  Remote.TimeoutConnect := vServiceTimeout;
  Remote.TimeoutSampling := 500;
  Remote.TimeoutKeepThreadAlive := false;
  Remote.TimeoutStartSampling;

  Remote.LineMode := true;
  Remote.LineLimit := MaxInt;
  Remote.LineEnd := sLineBreak;

  Remote.OnTimeout := onClientTimeout;
  Remote.OnGetDocument := onDocumentReadyServer;
  Remote.OnPostDocument := onDocumentReadyServer;
  Remote.OnPutDocument := onDocumentReadyServer;
  Remote.OnDeleteDocument := onDocumentReadyServer;
  Remote.OnPatchDocument := onDocumentReadyServer;
  Remote.OnOptionsDocument := onDocumentReadyServer;
  Remote.OnPostedData := onPostedDataServer;
  Remote.OnException := onExceptionServer;
  Remote.OnAfterAnswer := onAnsweredServer;
end;

function TRESTDWIcsServicePooler.ClientCount: Integer;
begin
  try
    if Assigned(HttpAppSrv) then
      Result := HttpAppSrv.ClientCount;
  except
    Result := -1;
  end;
end;

constructor TRESTDWIcsServicePooler.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  HttpAppSrv := TSslHttpAppSrv.Create(nil);

  // Permitir OPTIONS, DELETE e PUT
  HttpAppSrv.Options := [hoAllowOptions, hoAllowDelete, hoAllowPut];

  if Assigned(HttpAppSrv.SSLContext) then
  begin
    HttpAppSrv.SSLContext.Free;
    HttpAppSrv.SSLContext := nil;
  end;

  // TODO 2
  HttpAppSrv.DocDir := '';
  HttpAppSrv.TemplateDir := '';
  HttpAppSrv.DefaultDoc := '';

  vSSLVerMethodMin := sslVerTLS1_2;
  vSSLVerMethodMax := sslVerMax;
  vSSLVerifyDepth := 9;
  vSSLVerifyPeer := false;
  vSSLTimeoutSec := 60; // SSL TimeOut in Seconds
  vSSLUse := false;
  vIcsSelfAssignedCert := TIcsSelfAssignedCert.Create;

  vMaxClients := 0;
  vServiceTimeout := 60000; // TimeOut in Milliseconds
  vBuffSizeBytes := 262144; // 256kb Default
  vBandWidthLimitBytes := 0;
  vBandWidthSampleSec := 1;
  vListenBacklog := 50;

  vIpBlackList := TStringList.Create;
  vIpBlackList.Clear;
  vServerStatusCheck := true;

  vBruteForceProtection := TIcsBruteForceProtection.Create;
end;

procedure TRESTDWIcsServicePooler.onAnsweredServer(Sender: TObject);
var
  Remote: TPoolerHttpConnection;
begin
  Remote := Sender as TPoolerHttpConnection;

  Remote.vBytesOut := Remote.vBytesOut + Remote.DocStream.Size;

  try
    if Assigned(vOnAnswered) then
      vOnAnswered(Remote);
  finally
    // Force client disconnection after answer
    // Avoid ghost connections and timeouts
    DisconnectClient(Remote, HttpAppSrv);
  end;
end;

procedure TRESTDWIcsServicePooler.onClientConnectServer(Sender: TObject; Client: TObject;
  Error: Word);
var
  Remote: TPoolerHttpConnection;
  i: Integer;
begin
  Remote := Client as TPoolerHttpConnection;

  // Check for Brute Force exploit
  if not(vBruteForceProtection.BruteForceAllow(Remote.PeerAddr)) then
  begin
    try
      if Assigned(vOnClientConnect) then
        vOnClientConnect(Remote, Remote.LastError);

      if Assigned(vOnBruteForceBlock) then
        vOnBruteForceBlock(Remote.PeerAddr, Remote.PeerPort);
    finally
      DisconnectClient(Remote, HttpAppSrv);
    end;

    exit;
  end;

  // Blocking the black list IPs
  if vIpBlackList.Count > 0 then
  begin
    if vIpBlackList.IndexOf(Remote.PeerAddr) <> -1 then
    begin
      try
        if Assigned(vOnClientConnect) then
          vOnClientConnect(Remote, Remote.LastError);

        if Assigned(vOnBlackListBlock) then
          vOnBlackListBlock(Remote.PeerAddr, Remote.PeerPort);
      finally
        DisconnectClient(Remote, HttpAppSrv);
      end;

      exit;
    end;
  end;

  try
    if Assigned(vOnClientConnect) then
      vOnClientConnect(Remote, Error);
  finally
    SetHttpConnectionParams(Remote);
  end;
end;

procedure TRESTDWIcsServicePooler.onClientDisconnectServer(Sender: TObject;
  Client: TObject; Error: Word);
var
  Remote: TPoolerHttpConnection;
begin
  Remote := Client as TPoolerHttpConnection;

  if Assigned(vOnClientDisconnect) then
    vOnClientDisconnect(Remote, Error);
end;

destructor TRESTDWIcsServicePooler.Destroy;
begin
  try
    if Active then
    begin
      if HttpAppSrv.ListenAllOK then
        HttpAppSrv.Stop;
    end;
  except
    //
  end;

  if Assigned(HttpAppSrv) then
  begin
    if Assigned(HttpAppSrv.SSLContext) then
    begin
      HttpAppSrv.SSLContext.Free;
      HttpAppSrv.SSLContext := nil;
    end;

    FreeAndNil(HttpAppSrv);
  end;

  if Assigned(vBruteForceProtection) then
    FreeAndNil(vBruteForceProtection);

  if Assigned(vIcsSelfAssignedCert) then
    FreeAndNil(vIcsSelfAssignedCert);

  if Assigned(vIpBlackList) then
    FreeAndNil(vIpBlackList);

  inherited Destroy;
end;

procedure TRESTDWIcsServicePooler.EchoPooler(ServerMethodsClass, AContext: TComponent;
  var Pooler, MyIP: string; AccessTag: string; var InvalidTag: boolean);
var
  Remote: THttpAppSrvConnection;
  i: Integer;
begin
  inherited;

  InvalidTag := false;

  MyIP := '';

  if ServerMethodsClass <> nil then
  begin

    for i := 0 to ServerMethodsClass.ComponentCount - 1 do
    begin

      if (ServerMethodsClass.Components[i].ClassType = TRESTDWPoolerDB) or
        (ServerMethodsClass.Components[i].InheritsFrom(TRESTDWPoolerDB)) then
      begin

        if Pooler = Format('%s.%s', [ServerMethodsClass.ClassName,
          ServerMethodsClass.Components[i].Name]) then
        begin

          if Trim(TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag) <> '' then
          begin

            if TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag <> AccessTag
            then
            begin
              InvalidTag := true;

              exit;
            end;

          end;

          if AContext <> nil then
          begin
            Remote := THttpAppSrvConnection(AContext);

            MyIP := Remote.PeerAddr;
          end;

          Break;

        end;

      end;

    end;

  end;

  if MyIP = '' then
    raise Exception.Create(cInvalidPoolerName);
end;

procedure TRESTDWIcsServicePooler.onPostedDataServer(Sender: TObject; ErrCode: Word);
var
  Remote: TPoolerHttpConnection;
  Len: Integer;
  lCount: Integer;
  RawDataTemp: AnsiString;
  Stream: TStream;
begin
  try
    Remote := (Sender as TPoolerHttpConnection);

    repeat
    begin
      SetLength(RawDataTemp, Remote.BufSize);

      lCount := Remote.Receive(@RawDataTemp[1], Remote.BufSize);

      if lCount > 0 then
      begin
        SetLength(RawDataTemp, lCount);
        Remote.vRawData := Remote.vRawData + RawDataTemp;
        Remote.vRawDataLen := Remote.vRawDataLen + lCount;
      end
      else
        lCount := 0;

      SetLength(RawDataTemp, 0);
    end
    until lCount <= 0;

    if Remote.RequestContentLength = Remote.vRawDataLen then
    begin
      Remote.PostedDataReceived;

      try
        Stream := nil;

        Stream := TStringStream.Create(Remote.vRawData);

        Stream.Position := 0;

        Remote.ProcessDocument(Sender, Stream, hgWillSendMySelf, Self);
      finally
        FreeAndNil(Stream);
      end;
    end;
  except
    on E: Exception do
    begin
      try
        if Assigned(vOnException) then
        begin
          if HttpAppSrv.IsClient(Remote) then
            vOnException(Remote, 'onPostedDataServer - ' + E.Message)
          else
            vOnException(nil, 'onPostedDataServer - ' + cIcsHTTPConnectionClosed);
        end;
      finally
        DisconnectClient(Remote, HttpAppSrv);
      end;
    end;
  end;
end;

procedure TRESTDWIcsServicePooler.DisconnectClient(Client: TPoolerHttpConnection;
  Server: TSslHttpAppSrv);
begin
  try
    Client.vNeedClose := true;

    // Try disconnecting gracefully
    if Server.IsClient(Client) then
      Client.Shutdown(2);
  except
    on E: Exception do
    begin
      try
        if Assigned(vOnException) then
        begin
          if Server.IsClient(Client) then
            vOnException(Client, 'DisconnectClient - ' + E.Message)
          else
            vOnException(nil, 'DisconnectClient - ' + cIcsHTTPConnectionClosed);
        end;
      finally
        // Forced disconnection
        if Server.IsClient(Client) then
          Server.WSocketServer.Disconnect(Client);
      end;
    end;
  end;
end;

procedure TRESTDWIcsServicePooler.CustomAnswerStream(Pooler: TPoolerHttpConnection;
  Flag: THttpGetFlag; StatusCode: Integer; ContentType: string; Header: string);
begin
  if ((HttpAppSrv.IsClient(Pooler) = false) or (Pooler.vNeedClose = true)) then
    raise Exception.Create(cIcsHTTPConnectionClosed);

  case StatusCode of
    401:
      begin
        vBruteForceProtection.BruteForceAttempt(Pooler.PeerAddr);

        if vBruteForceProtection.BruteForceAllow(Pooler.PeerAddr) then
        begin
          if Self.Authenticator <> nil then
            Pooler.Answer401
          else
            Pooler.Answer403;
        end
        else
          Pooler.Answer403;
      end;
    403:
      Pooler.Answer403;
    404:
      Pooler.Answer404;
  else
    Pooler.AnswerStream(Flag, IntToStr(StatusCode), ContentType, Header);
  end;
end;

procedure TRESTDWIcsServicePooler.onDocumentReadyServer(Sender: TObject;
  var Flag: THttpGetFlag);
var
  Remote: TPoolerHttpConnection;
begin
  Remote := (Sender as TPoolerHttpConnection);

  Remote.OnDataSent := nil;

  try
    Remote.vBytesIn := Remote.vBytesIn + Remote.RequestContentLength;

    if Assigned(vOnDocumentReady) then
      vOnDocumentReady(Remote, Flag);
  finally
    try
      if not(Remote.RequestMethod in [THttpMethod.httpMethodGet,
        THttpMethod.httpMethodDelete, THttpMethod.httpMethodOptions]) then
        Flag := hgAcceptData
      else
      begin
        Flag := hgWillSendMySelf;

        Remote.ProcessDocument(Sender, nil, Flag, Self);
      end;
    except
      on E: Exception do
      begin
        try
          if Assigned(vOnException) then
          begin
            if HttpAppSrv.IsClient(Remote) then
              vOnException(Remote, 'onDocumentReadyServer - ' + E.Message)
            else
              vOnException(nil, 'onDocumentReadyServer - ' + cIcsHTTPConnectionClosed);
          end;
        finally
          DisconnectClient(Remote, HttpAppSrv);
        end;
      end;
    end;
  end;
end;

procedure TRESTDWIcsServicePooler.SetActive(Value: boolean);
var
  x: Integer;
begin
  if (Value) then
  begin
    try
      if not(Assigned(ServerMethodClass)) and (Self.GetDataRouteCount = 0) then
        raise Exception.Create(cServerMethodClassNotAssigned);

      if not HttpAppSrv.ListenAllOK then
      begin
        SetHttpServerParams;

        SetHttpServerSSL;

        HttpAppSrv.Start;

        SetSocketServerParams;

        vBruteForceProtection.StartBruteForce;
      end;
    except
      on E: Exception do
      begin
        raise Exception.Create(E.Message);
      end;
    end;
  end
  else if not(Value) then
  begin
    try
      if HttpAppSrv.ListenAllOK then
        HttpAppSrv.Stop;

      HttpAppSrv.MultiListenSockets.Clear;

      vBruteForceProtection.StopBruteForce;
    except
    end;
  end;
  inherited SetActive(Value);
end;

{ TPoolerHttpConnection }

constructor TPoolerHttpConnection.Create(AOwner: TComponent);
begin
  DocStream := nil;

  vProcessDocumentThread := nil;

  inherited Create(AOwner);

  vNeedClose := false;
  SetLength(vRawData, 0);
  vRawDataLen := 0;
  vBytesIn := 0;
  vBytesOut := 0;
end;

destructor TPoolerHttpConnection.Destroy;
begin
  vNeedClose := true;

  DocStream.Free;
  DocStream := nil;

  inherited Destroy;
end;

function TPoolerHttpConnection.GetTrafficInBytes: Int64;
begin
  Result := vBytesIn;
end;

function TPoolerHttpConnection.GetTrafficOutBytes: Int64;
begin
  Result := vBytesOut;
end;

procedure TPoolerHttpConnection.ProcessDocument(Sender: TObject; BodyStream: TStream;
  Flag: THttpGetFlag; ServicePooler: TRESTServicePoolerBase);
var
  Remote: TPoolerHttpConnection;
  ICSService: TRESTDWIcsServicePooler;
  vProcessDocumentThreadAux: TProcessDocumentThread;
begin
  try
    vProcessDocumentThread := TProcessDocumentThread.Create;

    vProcessDocumentThreadAux := (vProcessDocumentThread as TProcessDocumentThread);
    Remote := Sender as TPoolerHttpConnection;
    ICSService := (ServicePooler as TRESTDWIcsServicePooler);

    vProcessDocumentThreadAux.Remote := Remote;
    vProcessDocumentThreadAux.Flag := Flag;
    vProcessDocumentThreadAux.ICSService := ICSService;

    if BodyStream = nil then
    begin
      vProcessDocumentThreadAux.BodyStream.Size := 0;

      vProcessDocumentThreadAux.BodyStream.Position := 0;
    end
    else
    begin
      vProcessDocumentThreadAux.BodyStream.CopyFrom(BodyStream, BodyStream.Size);

      vProcessDocumentThreadAux.BodyStream.Position := 0;
    end;

    if (Remote.RequestContentLength <> vProcessDocumentThreadAux.BodyStream.Size) then
      raise Exception.Create(cIcsCorruptedPackage);

    vProcessDocumentThreadAux.Start;
  except
    on E: Exception do
    begin
      try
        if Assigned(ICSService.vOnException) then
        begin
          if ICSService.HttpAppSrv.IsClient(Remote) then
            ICSService.vOnException(Remote, 'ProcessDocument - ' + E.Message)
          else
            ICSService.vOnException(nil, 'ProcessDocument - ' + cIcsHTTPConnectionClosed);
        end;
      finally
        ICSService.DisconnectClient(Remote, ICSService.HttpAppSrv);
      end;
    end;
  end;
end;

{ TIcsBruteForceProtection }

function TIcsBruteForceProtection.BruteForceAllow(IP: string): boolean;
var
  aux: TStringList;

begin
  vBruteForceCS.Acquire;

  try
    try
      aux := nil;

      if vBruteForceProtectionStatus then
      begin
        aux := TStringList.Create;
        aux.Delimiter := ';';
        aux.StrictDelimiter := true;
        aux.Clear;

        if GetBruteForceIndex(IP) > -1 then
        begin
          aux.DelimitedText := vBruteForceList.ValueFromIndex[GetBruteForceIndex(IP)];

          if ((aux[0].ToInteger > vBruteForceTry) and
            (IncMinute(aux[1].ToDouble, vBruteForceExpirationMin) > now)) then
            Result := false
          else
          begin
            if (IncMinute(aux[1].ToDouble, vBruteForceExpirationMin) < now) then
              vBruteForceList.Delete(GetBruteForceIndex(IP));

            Result := true;
          end;
        end
        else
          Result := true;
      end
      else
        Result := true;
    except
      Result := false;
    end;
  finally
    try
      FreeAndNil(aux);
    finally
      vBruteForceCS.Release;
    end;
  end;
end;

function TIcsBruteForceProtection.GetBruteForceIndex(IP: string): Integer;
begin
  Result := vBruteForceList.IndexOfName(IP);
end;

procedure TIcsBruteForceProtection.SampleBruteForce(Sender: TObject);
var
  x: Integer;
  aux: TStringList;
begin
  vBruteForceCS.Acquire;

  try
    aux := nil;

    aux := TStringList.Create;

    for x := 0 to vBruteForceList.Count - 1 do
    begin

      aux.Delimiter := ';';
      aux.StrictDelimiter := true;
      aux.Clear;

      aux.DelimitedText := vBruteForceList[x];

      if (IncMinute(aux[1].ToDouble, vBruteForceExpirationMin) < now) then
        vBruteForceList.Delete(x);
    end;
  finally
    try
      FreeAndNil(aux);
    finally
      vBruteForceCS.Release;
    end;
  end;
end;

procedure TIcsBruteForceProtection.StartBruteForce;
begin
  if Assigned(vBruteForceTimer) then
  begin
    vBruteForceTimer.Enabled := false;

    FreeAndNil(vBruteForceTimer);
  end;

  if vBruteForceProtectionStatus then
  begin
    vBruteForceTimer := TTimer.Create(nil);

    vBruteForceTimer.Enabled := false;

    vBruteForceTimer.Interval := vBruteForceSampleMin * 60 * 1000;

    vBruteForceTimer.OnTimer := SampleBruteForce;

    vBruteForceTimer.Enabled := true;
  end;
end;

procedure TIcsBruteForceProtection.StopBruteForce;
begin
  if Assigned(vBruteForceTimer) then
  begin
    vBruteForceTimer.Enabled := false;

    FreeAndNil(vBruteForceTimer);
  end;

  ClearBruteForceList;
end;

procedure TIcsBruteForceProtection.BruteForceAttempt(IP: string);
var
  aux: TStringList;

begin
  vBruteForceCS.Acquire;

  try
    try
      aux := nil;

      if vBruteForceProtectionStatus then
      begin
        aux := TStringList.Create;
        aux.Delimiter := ';';
        aux.StrictDelimiter := true;
        aux.Clear;

        if GetBruteForceIndex(IP) > -1 then
        begin
          aux.DelimitedText := vBruteForceList.ValueFromIndex[GetBruteForceIndex(IP)];

          aux[0] := (aux[0].ToInteger + 1).ToString;

          aux[1] := FloatToStr(now);

          vBruteForceList.ValueFromIndex[GetBruteForceIndex(IP)] := aux.DelimitedText;
        end
        else
        begin
          vBruteForceList.AddPair(IP, '1;' + FloatToStr(now));
        end;
      end;
    except
      //
    end;
  finally
    try
      FreeAndNil(aux);
    finally
      vBruteForceCS.Release;
    end;
  end;
end;

procedure TIcsBruteForceProtection.ClearBruteForceList;
begin
  vBruteForceCS.Acquire;

  try
    if Assigned(vBruteForceList) then
    begin
      vBruteForceList.Clear;

      vBruteForceList.NameValueSeparator := '=';
    end;
  finally
    vBruteForceCS.Release;
  end;
end;

constructor TIcsBruteForceProtection.Create;
begin
  vBruteForceCS := TCriticalSection.Create;

  vBruteForceSampleMin := 1;
  vBruteForceTry := 3;
  vBruteForceExpirationMin := 30;
  vBruteForceProtectionStatus := true;

  vBruteForceList := TStringList.Create;
  vBruteForceList.Clear;
  vBruteForceList.NameValueSeparator := '=';
end;

destructor TIcsBruteForceProtection.Destroy;
begin
  StopBruteForce;

  if Assigned(vBruteForceList) then
    FreeAndNil(vBruteForceList);

  if Assigned(vBruteForceCS) then
    FreeAndNil(vBruteForceCS);

  inherited Destroy;
end;

{ TIcsSelfAssignedCert }

function TIcsSelfAssignedCert.CertificateString: string;
begin
  Result := vCert.SaveCertToText;
end;

constructor TIcsSelfAssignedCert.Create;
begin
  if Assigned(vCert) then
    FreeAndNil(vCert);

  vCert := TSslCertTools.Create(nil);

  vAutoGenerateOnStart := false;
  vPrivKeyType := TSslPrivKeyType.PrivKeyRsa4096;
  vCertDigest := TEvpDigest.Digest_sha512;
  vExpireDays := 365;
end;

procedure TIcsSelfAssignedCert.CreateCertificate;
begin
  vCert.DoClearCerts;
  vCert.DoClearCA;
  vCert.ClearAll;

  vCert.Country := vCountry;
  vCert.State := vState;
  vCert.Locality := vLocality;
  vCert.Organization := vOrganization;
  vCert.OrgUnit := vOrgUnit;
  vCert.Email := vEmail;
  vCert.CommonName := vCommonName;
  vCert.PrivKeyType := vPrivKeyType;
  vCert.CertDigest := vCertDigest;
  vCert.ExpireDays := vExpireDays;

  vCert.DoKeyPair;
  vCert.DoSelfSignCert;
end;

destructor TIcsSelfAssignedCert.Destroy;
begin
  if Assigned(vCert) then
    FreeAndNil(vCert);

  inherited Destroy;
end;

function TIcsSelfAssignedCert.PrivateKeyString: string;
begin
  Result := vCert.SavePKeyToText;
end;

{ TProcessDocumentThread }

constructor TProcessDocumentThread.Create;
begin
  inherited Create(true);

  FreeOnTerminate := true;

  vBodyStream := nil;
  BodyStream := TMemoryStream.Create;
end;

destructor TProcessDocumentThread.Destroy;
begin
  FreeAndNil(vBodyStream);

  inherited Destroy;
end;

procedure TProcessDocumentThread.Execute;
var
  vCharSet, vToken, vErrorMessage, vAuthRealm, vContentType, vResponseString: string;
  StatusCode: Integer;
  ResultStream: TStream;
  vResponseHeader: TStringList;
  vParams: TStringList;
  vCORSHeader: TStringList;
  vRedirect: TRedirect;

  procedure DestroyComponents;
  begin
    FreeAndNil(vResponseHeader);

    FreeAndNil(vParams);

    FreeAndNil(ResultStream);

    FreeAndNil(vCORSHeader);
  end;

  procedure Redirect(Url: string);
  begin
    vRemote.WebRedirectURL := Url;
  end;

  procedure SetReplyCORS;
  var
    i: Integer;
  begin
    if vICSService.CORS then
    begin
      if vICSService.CORS_CustomHeaders.Count > 0 then
      begin

        for i := 0 to vICSService.CORS_CustomHeaders.Count - 1 do
          vResponseHeader.AddPair(vICSService.CORS_CustomHeaders.Names[i],
            vICSService.CORS_CustomHeaders.ValueFromIndex[i]);
      end
      else
        vResponseHeader.AddPair('Access-Control-Allow-Origin', '*');

      if Assigned(vCORSHeader) then
      begin
        if vCORSHeader.Count > 0 then
        begin
          for i := 0 to vCORSHeader.Count - 1 do
            vResponseHeader.AddPair(vCORSHeader.Names[i], vCORSHeader.ValueFromIndex[i]);
        end;
      end;

    end;
  end;

begin
  inherited;

  try
    try
      vCORSHeader := nil;
      vResponseHeader := nil;
      vParams := nil;
      ResultStream := nil;

      // Do not process the document if HTTP conection needs to be closed
      // but for some reason it was not closed, or if it was closed before answer
      if ((vICSService.HttpAppSrv.IsClient(vRemote) = false) or
        (vRemote.vNeedClose = true)) then
        raise Exception.Create(cIcsHTTPConnectionClosed);

      // Server status check protection
      if ((vICSService.vServerStatusCheck = false) and
        ((string.IsNullOrEmpty(vRemote.Path)) or (vRemote.Path = '/'))) then
      begin
        try
          if Assigned(vICSService.vOnServerStatusCheckBlock) then
            vICSService.vOnServerStatusCheckBlock(vRemote.PeerAddr, vRemote.PeerPort);
        finally
          vICSService.DisconnectClient(vRemote, vICSService.HttpAppSrv);
        end;

        exit;
      end;

      vCORSHeader := TStringList.Create;
      vResponseHeader := TStringList.Create;
      vParams := TStringList.Create;

      vResponseString := '';
      @vRedirect := @Redirect;
      vToken := vRemote.AuthDigestUri;
      vAuthRealm := vRemote.AuthRealm;
      vContentType := vRemote.RequestContentType;
      vParams.Delimiter := '&';
      vParams.DelimitedText := vRemote.Params;

      try
        vICSService.CommandExec(TComponent(vRemote),
          RemoveBackslashCommands(vRemote.Path), vRemote.Method + ' ' + vRemote.Path,
          vContentType, vRemote.PeerAddr, vRemote.RequestUserAgent, vRemote.AuthUserName,
          vRemote.AuthPassword, vToken, vRemote.RequestHeader, StrToInt(vRemote.PeerPort),
          vRemote.RequestHeader, vParams, vRemote.Params, vBodyStream, vAuthRealm,
          vCharSet, vErrorMessage, StatusCode, vResponseHeader, vResponseString,
          ResultStream, TStrings(vCORSHeader), vRedirect);
      except
        on E: Exception do
        begin
          raise Exception.Create('CommandExec - ' + E.Message);
        end;
      end;

      SetReplyCORS;

      vRemote.AuthRealm := vAuthRealm;

      if (vResponseString <> '') or (vErrorMessage <> '') then
      begin
        FreeAndNil(ResultStream);

        if (vResponseString <> '') then
          ResultStream := TStringStream.Create(vResponseString)
        else
          ResultStream := TStringStream.Create(vErrorMessage);
      end;

      if Assigned(ResultStream) then
      begin
        ResultStream.Position := 0;

        vRemote.DocStream := TStringStream.Create;
        vRemote.DocStream.CopyFrom(ResultStream, ResultStream.Size);
        vRemote.DocStream.Position := 0;

        vICSService.CustomAnswerStream(vRemote, vFlag, StatusCode, vContentType,
          StringReplace(vResponseHeader.Text, '=', ': ', [rfReplaceAll]));
      end
      else
        vICSService.DisconnectClient(vRemote, vICSService.HttpAppSrv);
    except
      on E: Exception do
      begin
        try
          if Assigned(vICSService.vOnException) then
          begin
            if vICSService.HttpAppSrv.IsClient(vRemote) then
              vICSService.vOnException(vRemote, 'ProcessDocumentThread - ' + E.Message)
            else
              vICSService.vOnException(nil, 'ProcessDocumentThread - ' +
                cIcsHTTPConnectionClosed);
          end;
        finally
          vICSService.DisconnectClient(vRemote, vICSService.HttpAppSrv);
        end;
      end;
    end;
  finally
    try
      DestroyComponents;
    finally
      vRemote.vNeedClose := true;
    end;
  end;
end;

end.
