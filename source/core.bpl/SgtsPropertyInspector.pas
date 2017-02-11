unit SgtsPropertyInspector;

interface

uses Classes,
     ELPropInsp;

type
  TSgtsPropertyInspector=class(TELPropertyInspector)
  public
    constructor Create(AOwner: TComponent); override;
  end;

implementation

{ TSgtsPropertyInspector }

constructor TSgtsPropertyInspector.Create(AOwner: TComponent); 
begin
  inherited Create(AOwner);
  ExpandComponentRefs:=false;
end;

end.
