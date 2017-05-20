unit ContainerSLL;

interface

uses
  SysUtils, System.Generics.Defaults;

type
  TSortOrder = (ASCENDING, DESCENDING);
  TSinglyLL<T> = class
    type
      PNode = PNode;
      TNode = record
        Content: T;
        NextNode: PNode;
      end;
      TNodeData = record
        Index: Integer;
        Node: PNode;
      end;
    private
      FHeaderNode: PNode;
      FLastNode: PNode;
      FLastRequested: TNodeData;
      function CheckIfEmpty: Boolean;
      function ExchangeCondition(const ASortOrder: TSortOrder;
        const ACompareResult: Integer): Boolean;
      function GetContent(const AIndex: Word): T;
      function GetSize: Word;
      function NodeDataWithIndex(const AIndex: Word): TNodeData;
      procedure SetContent(const AIndex: Word; const ANodeContent: T);
    public
      constructor Create; overload;
      constructor Create(const ANodesContent: array of T); overload;
      destructor Destroy; override;
      procedure Append(const ANodeContent: T); overload;
      procedure Append(const ANodesContent: array of T); overload;
      procedure Clear;
      function Count(const AElement: T): Word;
      procedure Cut(AQuantity: Word = 1);
      procedure Insert(const AIndex: Word; const ANodeContent: T); overload;
      procedure Insert(const AIndex: Word; const ANodesContent: array of T); overload;
      function Pop(const AIndex: Word = 0): T;
      function PopLast: T;
      procedure Remove(const AIndex: Word; AQuantity: Word = 1);
      procedure Reverse;
      procedure Sort(const ASortOrder: TSortOrder = ASCENDING); overload;
      procedure Sort(const AContentComparer: IComparer<T>;
        const ASortOrder: TSortOrder = ASCENDING); overload;
      property IsEmpty: Boolean read CheckIfEmpty;
      property Items[const index: Word]: T read GetContent write SetContent;
      property Size: Word read GetSize;
  end;

implementation

function TSinglyLL<T>.CheckIfEmpty: Boolean;
begin
  if FHeaderNode^.NextNode = Nil then
    Result := True
  else
    Result := False;
end;

function TSinglyLL<T>.ExchangeCondition(const ASortOrder: TSortOrder;
  const ACompareResult: Integer): Boolean;
begin
  Result := False;
  if ACompareResult > 0 then
  begin
    if ASortOrder = ASCENDING then
      Result := True;
  end
  else
    if ASortOrder = DESCENDING then
      Result := True;
end;

function TSinglyLL<T>.GetContent(const AIndex: Word): T;
var
  CurrentData: TNodeData;
begin
  CurrentData := NodeDataWithIndex(AIndex);
  Result := CurrentData.Node^.Content;
  FLastRequested.Node := CurrentData.Node;
  FLastRequested.Index := CurrentData.Index;
end;

function TSinglyLL<T>.GetSize: Word;
var
  CurrentNode: TNodeData;
begin
  if IsEmpty then
    Result := 0
  else
  begin
    if FLastRequested.Node <> Nil then
    begin
      CurrentNode.Node := FLastRequested.Node;
      CurrentNode.Index := FLastRequested.Index;
    end
    else
    begin
      CurrentNode.Node := FHeaderNode^.NextNode;
      CurrentNode.Index := 0;
    end;
    while CurrentNode.Node <> Nil do
    begin
      CurrentNode.Node := CurrentNode.Node^.NextNode;
      Inc(currentNode.Index);
    end;
    Result := CurrentNode.Index;
  end;
end;

function TSinglyLL<T>.NodeDataWithIndex(const AIndex: Word): TNodeData;
var
  CurrentData: TNodeData;
begin
  if (FLastRequested.Node <> Nil) and (AIndex >= FLastRequested.Index) then
  begin
    CurrentData.Node := FLastRequested.Node;
    CurrentData.Index := FLastRequested.Index;
  end
  else
  begin
    CurrentData.Node := FHeaderNode^.NextNode;
    CurrentData.Index := 0;
  end;
  while CurrentData.Index <> AIndex do
  begin
    CurrentData.Node := CurrentData.Node^.NextNode;
    Inc(CurrentData.Index);
  end;
  Result := CurrentData;
end;

procedure TSinglyLL<T>.SetContent(const AIndex: Word; const ANodeContent: T);
var
  CurrentData: TNodeData;
begin
  if AIndex >= Size then
    raise Exception.Create('Invalid item index')
  else
  begin
    CurrentData := NodeDataWithIndex(AIndex);
    if CurrentData.Node = Nil then
      Append(ANodeContent)
    else
      CurrentData.Node^.Content := ANodeContent;
    FLastRequested.Node := CurrentData.Node;
    FLastRequested.Index := CurrentData.Index;
  end;
end;

constructor TSinglyLL<T>.Create;
begin
  inherited Create;
  New(FHeaderNode);
  FHeaderNode^.NextNode := Nil;
  FLastRequested.Node := Nil;
  FLastNode := FHeaderNode;
end;

constructor TSinglyLL<T>.Create(const ANodesContent: array of T);
begin
  inherited Create;
  New(FHeaderNode);
  FHeaderNode^.NextNode := Nil;
  FLastRequested.Node := Nil;
  FLastNode := FHeaderNode;
  Append(ANodesContent);
end;

destructor TSinglyLL<T>.Destroy;
begin
  Dispose(FHeaderNode);
  inherited Destroy;
end;

procedure TSinglyLL<T>.Append(const ANodeContent: T);
var
  CurrentNode: PNode;
begin
  CurrentNode := FLastNode;
  New(CurrentNode^.NextNode);
  CurrentNode := CurrentNode^.NextNode;
  CurrentNode^.Content := ANodeContent;
  CurrentNode^.NextNode := Nil;
  FLastNode := CurrentNode;
end;

procedure TSinglyLL<T>.Append(const ANodesContent: array of T);
var
  I: Word;
begin
  for I := 0 to High(ANodesContent) do
    Append(ANodesContent[I]);
end;

procedure TSinglyLL<T>.Clear;
begin
  while FHeaderNode^.NextNode <> Nil do
    Cut;
end;

function TSinglyLL<T>.Count(const AElement: T): Word;
var
  Counter: Word;
  CurrentNode: PNode;
  ContentComparer: TComparer<T>;
begin
  Counter := 0;
  CurrentNode := FHeaderNode^.NextNode;
  while CurrentNode <> Nil do
  begin
    if ContentComparer.Compare(CurrentNode^.Content, AElement) = 0 then
      Inc(Counter);
    CurrentNode := CurrentNode^.NextNode;
  end;
  Result := Counter;
end;

procedure TSinglyLL<T>.Cut(AQuantity: Word = 1);
var
  I: Word;
begin
  for I := AQuantity downto 1 do
    PopLast;
end;

procedure TSinglyLL<T>.Insert(const AIndex: Word; const ANodeContent: T);
begin
  Insert(AIndex, [ANodeContent]);
end;

procedure TSinglyLL<T>.Insert(const AIndex: Word; const ANodesContent: array of T);
var
  CurrentData: TNodeData;
  NextNode, BuffLastNode: PNode;
begin
  CurrentData := NodeDataWithIndex(AIndex - 1);
  if CurrentData.Node^.NextNode = Nil then
    Append(ANodesContent)
  else
  begin
    NextNode := CurrentData.Node^.NextNode;
    BuffLastNode := FLastNode;
    FLastNode := CurrentData.Node;
    Append(ANodesContent);
    FLastNode^.NextNode := NextNode;
    FLastNode := BuffLastNode;
  end;
  FLastRequested.Node := CurrentData.Node;
  FLastRequested.Index := CurrentData.Index;
end;

function TSinglyLL<T>.Pop(const AIndex: Word = 0): T;
var
  CurrentData: TNodeData;
  BuffLastNode: PNode;
begin
  FLastRequested.Node := Nil;
  if AIndex = 0 then
  begin
    CurrentData.Node := FHeaderNode;
    CurrentData.Index := -1;
  end
  else
    CurrentData := NodeDataWithIndex(AIndex - 1);
  BuffLastNode := FLastNode;
  FLastNode := CurrentData.Node^.NextNode;
  Result := FLastNode^.Content;
  if FLastNode^.NextNode <> Nil then
  begin
    CurrentData.Node^.NextNode := FLastNode^.NextNode;
    FLastNode := BuffLastNode;
  end
  else
  begin
    FLastNode := CurrentData.Node;
    CurrentData.Node^.NextNode := Nil;
  end;
end;

function TSinglyLL<T>.PopLast: T;
var
  I: Word;
  CurrentNode: PNode;
begin
  if FHeaderNode^.NextNode <> Nil then
  begin
    if (FLastRequested.Node <> Nil) and (FLastRequested.Node <> FLastNode) then
      CurrentNode := FLastRequested.Node
    else
      CurrentNode := FHeaderNode;
    while CurrentNode^.NextNode <> FLastNode do
      CurrentNode := CurrentNode^.NextNode;
    Result := FLastNode^.Content;
    Dispose(CurrentNode^.NextNode);
    FLastNode := CurrentNode;
    FLastNode^.NextNode := Nil;
    FLastRequested.Node := Nil;
  end;
end;

procedure TSinglyLL<T>.Remove(const AIndex: Word; AQuantity: Word = 1);
var
  CurrentData: TNodeData;
  BuffLastNode: PNode;
begin
  if AIndex = 0 then
  begin
    CurrentData.Node := FHeaderNode;
    CurrentData.Index := -1;
  end
  else
    CurrentData := NodeDataWithIndex(AIndex - 1);
  if CurrentData.Node^.NextNode^.NextNode = Nil then
    Cut
  else
  begin
    FLastRequested.Node := Nil;
    BuffLastNode := FLastNode;
    FLastNode := CurrentData.Node^.NextNode;
    while (AQuantity <> 0) and (FLastNode <> Nil) do
    begin
      FLastNode := FLastNode^.NextNode;
      Dec(AQuantity);
    end;
    if FLastNode <> Nil then
    begin
      CurrentData.Node^.NextNode := FLastNode;
      FLastNode := BuffLastNode;
    end
    else
      FLastNode := CurrentData.Node;
  end;
end;

procedure TSinglyLL<T>.Reverse;
var
  CurrentNode, NewHeaderNode: PNode;
begin
  New(CurrentNode);
  NewHeaderNode := CurrentNode;
  while FHeaderNode^.NextNode <> Nil do
  begin
    New(currentNode^.NextNode);
    CurrentNode := CurrentNode^.NextNode;
    CurrentNode^.Content := PopLast;
  end;
  CurrentNode^.NextNode := Nil;
  FLastNode := CurrentNode;
  FHeaderNode := NewHeaderNode;
end;

procedure TSinglyLL<T>.Sort(const ASortOrder: TSortOrder = ASCENDING);
begin
  Sort(TComparer<T>.Default, ASortOrder);
end;

procedure TSinglyLL<T>.Sort(const AContentComparer: IComparer<T>;
  const ASortOrder: TSortOrder = ASCENDING);
var
  CurrentNode: PNode;
  BuffContentElement: T;
  IsSorted: Boolean;
begin
  repeat
    IsSorted := True;
    CurrentNode := FHeaderNode^.NextNode;
    while CurrentNode^.NextNode <> Nil do
    begin
      if ExchangeCondition(ASortOrder,
        AContentComparer.Compare(CurrentNode^.Content,
        CurrentNode^.NextNode^.Content)) then
      begin
        IsSorted := False;
        BuffContentElement := CurrentNode^.Content;
        CurrentNode^.Content := CurrentNode^.NextNode^.Content;
        CurrentNode^.NextNode^.Content := BuffContentElement;
      end;
      CurrentNode := CurrentNode^.NextNode;
    end;
  until IsSorted;
end;

end.
