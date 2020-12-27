unit kubo.rest.client.types;

interface

uses
  system.generics.collections;

type
  tkuboAuthenticationType = (taNone, taBasic, taBearer);
  tkuboParamKind = (kpkunKnow, kpkCookie, kpkGetPost, kpkURLSegment, kpkHTTPHeader, kpkRequestBody, kpkFile, kpkQuery);

implementation

end.
