unit ContainerSLL;

interface

uses
  SysUtils;

type
  TSortOrder = (ASCENDING, DESCENDING);
  TListContent = string; //change to set another content type
  PNode = ^TNode;
  TNode = record
    Content: TListContent;
    NextNode: PNode;
  end;
  TNodeData = record
    Node: PNode;
    Index: Integer;
  end;
  TSinglyLL = class
    private
      FLastNode: PNode;
      FLastRequested: TNodeData;
      FHeaderNode: PNode;
      function ExchangeCondition(const sortOrder: TSortOrder;
        const firstElement, secondElement: TListContent): Boolean;
      function NodeDataWithIndex(const index: Word): TNodeData;
      function GetSize: Word;
      function CheckIfEmpty: Boolean;
      procedure SetContent(const index: Word; const nodeContent: TListContent);
      function GetContent(const index: Word): TListContent;
    public
      constructor Create; overload;
      constructor Create(const nodesContent: array of TListContent); overload;
      destructor Destroy; override;
      property Size: Word read GetSize;
      property IsEmpty: Boolean read CheckIfEmpty;
      property Item[const Index: Word]: TListContent read GetContent write SetContent;
      procedure Append(const nodeContent: TListContent); overload;
      procedure Append(const nodesContent: array of TListContent); overload;
      procedure Cut(quantity: Word = 1);
      procedure Insert(const index: Word; const nodeContent: TListContent); overload;
      procedure Insert(const index: Word; const nodesContent: array of TListContent); overload;
      procedure Remove(const index: Word; quantity: Word = 1);
      function Pop(const index: Word = 0): TListContent;
      function PopLast: TListContent;
      function Count(const element: TListContent): Word;
      procedure Sort(const sortOrder: TSortOrder = ASCENDING);
      procedure Reverse;
      procedure Clear;
  end;

implementation

constructor TSinglyLL.Create;
begin
  inherited Create;
  New(FHeaderNode);
  FHeaderNode^.NextNode := Nil;
  FLastRequested.Node := Nil;
  FLastNode := FHeaderNode;
end;

constructor TSinglyLL.Create(const nodesContent: array of TListContent);
begin
  inherited Create;
  New(FHeaderNode);
  FHeaderNode^.NextNode := Nil;
  FLastRequested.Node := Nil;
  FLastNode := FHeaderNode;
  Append(nodesContent);
end;

destructor TSinglyLL.Destroy;
begin
  Dispose(FHeaderNode);
  inherited Destroy;
end;

function TSinglyLL.ExchangeCondition(const sortOrder: TSortOrder;
  const firstElement, secondElement: TListContent): Boolean;
begin
  Result := False;
  if firstElement > secondElement then
  begin
    if sortOrder = ASCENDING then
      Result := True;
  end
  else
    if sortOrder = DESCENDING then
      Result := True;
end;

function TSinglyLL.NodeDataWithIndex(const index: Word): TNodeData;
var
  currentData: TNodeData;
begin
  if (FLastRequested.Node <> Nil) and (index >= FLastRequested.Index) then
  begin
    currentData.Node := FLastRequested.Node;
    currentData.Index := FLastRequested.Index;
  end
  else
  begin
    currentData.Node := FHeaderNode^.NextNode;
    currentData.Index := 0;
  end;
  while currentData.Index <> index do
  begin
    currentData.Node := currentData.Node^.NextNode;
    Inc(currentData.Index);
  end;
  Result := currentData;
end;

procedure TSinglyLL.SetContent(const index: Word; const nodeContent: TListContent);
var
  currentData: TNodeData;
begin
  if index >= Size then
    raise Exception.Create('Invalid item index')
  else
  begin
    currentData := NodeDataWithIndex(index);
    if currentData.Node = Nil then
      Append(nodeContent)
    else
      currentData.Node^.Content := nodeContent;
    FLastRequested.Node := currentData.Node;
    FLastRequested.Index := currentData.Index;
  end;
end;

function TSinglyLL.GetContent(const index: Word): TListContent;
var
  currentData: TNodeData;
begin
  currentData := NodeDataWithIndex(index);
  Result := currentData.Node^.Content;
  FLastRequested.Node := currentData.Node;
  FLastRequested.Index := currentData.Index;
end;

function TSinglyLL.CheckIfEmpty: Boolean;
begin
  if FHeaderNode^.NextNode = Nil then
    Result := True
  else
    Result := False;
end;

function TSinglyLL.GetSize: Word;
var
  currentNode: TNodeData;
begin
  if IsEmpty then
    Result := 0
  else
  begin
    if FLastRequested.Node <> Nil then
    begin
      currentNode.Node := FLastRequested.Node;
      currentNode.Index := FLastRequested.Index;
    end
    else
    begin
      currentNode.Node := FHeaderNode^.NextNode;
      currentNode.Index := 0;
    end;
    while currentNode.Node <> Nil do
    begin
      currentNode.Node := currentNode.Node^.NextNode;
      Inc(currentNode.Index);
    end;
    Result := currentNode.Index;
  end;
end;

procedure TSinglyLL.Reverse;
var
  currentNode: PNode;
  newHeaderNode: PNode;
begin
  New(currentNode);
  newHeaderNode := currentNode;
  while FHeaderNode^.NextNode <> Nil do
  begin
    New(currentNode^.NextNode);
    currentNode := currentNode^.NextNode;
    currentNode^.Content := PopLast;
  end;
  currentNode^.NextNode := Nil;
  FLastNode := currentNode;
  FHeaderNode := newHeaderNode;
end;

procedure TSinglyLL.Append(const nodeContent: TListContent);
var
  currentNode: PNode;
begin
  currentNode := FLastNode;
  New(currentNode^.NextNode);
  currentNode := currentNode^.NextNode;
  currentNode^.Content := nodeContent;
  FLastNode := currentNode;
end;

procedure TSinglyLL.Append(const nodesContent: array of TListContent);
var
  i: Word;
begin
  for i := 0 to High(nodesContent) do
    Append(nodesContent[i]);
end;

procedure TSinglyLL.Cut(quantity: Word = 1);
var
  i: Word;
begin
  for i := quantity downto 1 do
    PopLast;
end;

procedure TSinglyLL.Insert(const index: Word; const nodeContent: TListContent);
begin
  Insert(index, [nodeContent]);
end;

procedure TSinglyLL.Insert(const index: Word; const nodesContent: array of TListContent);
var
  currentData: TNodeData;
  nextNode, buffLastNode: PNode;
begin
  currentData := NodeDataWithIndex(index - 1);
  if currentData.Node^.NextNode = Nil then
    Append(nodesContent)
  else
  begin
    nextNode := currentData.Node^.NextNode;
    buffLastNode := FLastNode;
    FLastNode := currentData.Node;
    Append(nodesContent);
    FLastNode^.NextNode := nextNode;
    FLastNode := buffLastNode;
  end;
  FLastRequested.Node := currentData.Node;
  FLastRequested.Index := currentData.Index;
end;

procedure TSinglyLL.Remove(const index: Word; quantity: Word = 1);
var
  currentData: TNodeData;
  buffLastNode: PNode;
begin
  if index = 0 then
  begin
    currentData.Node := FHeaderNode;
    currentData.Index := -1;
  end
  else
    currentData := NodeDataWithIndex(index - 1);
  if currentData.Node^.NextNode^.NextNode = Nil then
    Cut
  else
  begin
    FLastRequested.Node := Nil;
    buffLastNode := FLastNode;
    FLastNode := currentData.Node^.NextNode;
    while (quantity <> 0) and (FLastNode <> Nil) do
    begin
      FLastNode := FLastNode^.NextNode;
      Dec(quantity);
    end;
    if FLastNode <> Nil then
    begin
      currentData.Node^.NextNode := FLastNode;
      FLastNode := buffLastNode;
    end
    else
      FLastNode := currentData.Node;
  end;
end;

function TSinglyLL.Pop(const index: Word = 0): TListContent;
var
  currentData: TNodeData;
  buffLastNode: PNode;
begin
  FLastRequested.Node := Nil;
  if index = 0 then
  begin
    currentData.Node := FHeaderNode;
    currentData.Index := -1;
  end
  else
    currentData := NodeDataWithIndex(index - 1);
  buffLastNode := FLastNode;
  FLastNode := currentData.Node^.NextNode;
  Result := FLastNode^.Content;
  if FLastNode^.NextNode <> Nil then
  begin
    currentData.Node^.NextNode := FLastNode^.NextNode;
    FLastNode := buffLastNode;
  end
  else
  begin
    FLastNode := currentData.Node;
    currentData.Node^.NextNode := Nil;
  end;
end;

function TSinglyLL.PopLast: TListContent;
var
  i: Word;
  currentNode: PNode;
begin
  if FHeaderNode^.NextNode <> Nil then
  begin
    if (FLastRequested.Node <> Nil) and (FLastRequested.Node <> FLastNode) then
      currentNode := FLastRequested.Node
    else
      currentNode := FHeaderNode;
    while currentNode^.NextNode <> FLastNode do
      currentNode := currentNode^.NextNode;
    Result := FLastNode^.Content;
    Dispose(currentNode^.NextNode);
    FLastNode := currentNode;
    FLastNode^.NextNode := Nil;
    FLastRequested.Node := Nil;
  end;
end;

function TSinglyLL.Count(const element: TListContent): Word;
var
  counter: Word;
  currentNode: PNode;
begin
  counter := 0;
  currentNode := FHeaderNode^.NextNode;
  while currentNode <> Nil do
  begin
    if currentNode^.Content = element then
      Inc(counter);
    currentNode := currentNode^.NextNode;
  end;
  Result := counter;
end;

procedure TSinglyLL.Sort(const sortOrder: TSortOrder = ASCENDING);
var
  currentNode: PNode;
  buffContentElement: TListContent;
  isSorted: Boolean;
begin
  repeat
    isSorted := True;
    currentNode := FHeaderNode^.NextNode;
    while currentNode^.NextNode <> Nil do
    begin
      if ExchangeCondition(sortOrder, currentNode^.Content, currentNode^.NextNode^.Content) then
      begin
        isSorted := False;
        buffContentElement := currentNode^.Content;
        currentNode^.Content := currentNode^.NextNode^.Content;
        currentNode^.NextNode^.Content := buffContentElement;
      end;
      currentNode := currentNode^.NextNode;
    end;
  until isSorted;
end;

procedure TSinglyLL.Clear;
begin
  while FHeaderNode^.NextNode <> Nil do
    Cut;
end;

end.
