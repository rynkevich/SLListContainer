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
    Index: Integer;
    Node: PNode;
  end;
  TSinglyLL = class
    private
      FHeaderNode: PNode;
      FLastNode: PNode;
      FLastRequested: TNodeData;
      function CheckIfEmpty: Boolean;
      function ExchangeCondition(const SortOrder: TSortOrder;
        const FirstElement, SecondElement: TListContent): Boolean;
      function GetContent(const Index: Word): TListContent;
      function GetSize: Word;
      function NodeDataWithIndex(const Index: Word): TNodeData;
      procedure SetContent(const Index: Word; const NodeContent: TListContent);
    public
      constructor Create; overload;
      constructor Create(const NodesContent: array of TListContent); overload;
      destructor Destroy; override;
      procedure Append(const NodeContent: TListContent); overload;
      procedure Append(const NodesContent: array of TListContent); overload;
      procedure Clear;
      function Count(const Element: TListContent): Word;
      procedure Cut(Quantity: Word = 1);
      procedure DumpStructure;
      procedure Insert(const Index: Word; const NodeContent: TListContent); overload;
      procedure Insert(const Index: Word; const NodesContent: array of TListContent); overload;
      function Pop(const Index: Word = 0): TListContent;
      function PopLast: TListContent;
      procedure Remove(const Index: Word; Quantity: Word = 1);
      procedure Reverse;
      procedure Sort(const SortOrder: TSortOrder = ASCENDING);
      property IsEmpty: Boolean read CheckIfEmpty;
      property Items[const index: Word]: TListContent read GetContent write SetContent;
      property Size: Word read GetSize;
  end;

implementation

function TSinglyLL.CheckIfEmpty: Boolean;
begin
  if FHeaderNode^.NextNode = Nil then
    Result := True
  else
    Result := False;
end;

function TSinglyLL.ExchangeCondition(const SortOrder: TSortOrder;
  const FirstElement, SecondElement: TListContent): Boolean;
begin
  Result := False;
  if FirstElement > SecondElement then
  begin
    if SortOrder = ASCENDING then
      Result := True;
  end
  else
    if SortOrder = DESCENDING then
      Result := True;
end;

function TSinglyLL.GetContent(const Index: Word): TListContent;
var
  CurrentData: TNodeData;
begin
  CurrentData := NodeDataWithIndex(Index);
  Result := CurrentData.Node^.Content;
  FLastRequested.Node := CurrentData.Node;
  FLastRequested.Index := CurrentData.Index;
end;

function TSinglyLL.GetSize: Word;
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

function TSinglyLL.NodeDataWithIndex(const Index: Word): TNodeData;
var
  CurrentData: TNodeData;
begin
  if (FLastRequested.Node <> Nil) and (Index >= FLastRequested.Index) then
  begin
    CurrentData.Node := FLastRequested.Node;
    CurrentData.Index := FLastRequested.Index;
  end
  else
  begin
    CurrentData.Node := FHeaderNode^.NextNode;
    CurrentData.Index := 0;
  end;
  while CurrentData.Index <> Index do
  begin
    CurrentData.Node := CurrentData.Node^.NextNode;
    Inc(CurrentData.Index);
  end;
  Result := CurrentData;
end;

procedure TSinglyLL.SetContent(const Index: Word; const NodeContent: TListContent);
var
  CurrentData: TNodeData;
begin
  if Index >= Size then
    raise Exception.Create('Invalid item index')
  else
  begin
    CurrentData := NodeDataWithIndex(Index);
    if CurrentData.Node = Nil then
      Append(NodeContent)
    else
      CurrentData.Node^.Content := NodeContent;
    FLastRequested.Node := CurrentData.Node;
    FLastRequested.Index := CurrentData.Index;
  end;
end;

constructor TSinglyLL.Create;
begin
  inherited Create;
  New(FHeaderNode);
  FHeaderNode^.NextNode := Nil;
  FLastRequested.Node := Nil;
  FLastNode := FHeaderNode;
end;

constructor TSinglyLL.Create(const NodesContent: array of TListContent);
begin
  inherited Create;
  New(FHeaderNode);
  FHeaderNode^.NextNode := Nil;
  FLastRequested.Node := Nil;
  FLastNode := FHeaderNode;
  Append(NodesContent);
end;

destructor TSinglyLL.Destroy;
begin
  Dispose(FHeaderNode);
  inherited Destroy;
end;

procedure TSinglyLL.Append(const NodeContent: TListContent);
var
  CurrentNode: PNode;
begin
  CurrentNode := FLastNode;
  New(CurrentNode^.NextNode);
  CurrentNode := CurrentNode^.NextNode;
  CurrentNode^.Content := NodeContent;
  CurrentNode^.NextNode := Nil;
  FLastNode := CurrentNode;
end;

procedure TSinglyLL.Append(const NodesContent: array of TListContent);
var
  I: Word;
begin
  for I := 0 to High(NodesContent) do
    Append(NodesContent[I]);
end;

procedure TSinglyLL.Clear;
begin
  while FHeaderNode^.NextNode <> Nil do
    Cut;
end;

function TSinglyLL.Count(const Element: TListContent): Word;
var
  Counter: Word;
  CurrentNode: PNode;
begin
  Counter := 0;
  CurrentNode := FHeaderNode^.NextNode;
  while CurrentNode <> Nil do
  begin
    if CurrentNode^.Content = Element then
      Inc(Counter);
    CurrentNode := CurrentNode^.NextNode;
  end;
  Result := Counter;
end;

procedure TSinglyLL.Cut(Quantity: Word = 1);
var
  I: Word;
begin
  for I := Quantity downto 1 do
    PopLast;
end;

procedure TSinglyLL.DumpStructure;
const
  DumpFileName = 'Dump.txt';
var
  I: Word;
  DumpFile: TextFile;
begin
  try
    AssignFile(DumpFile, DumpFileName);
    Rewrite(DumpFile);
    if IsEmpty then
      Write(DumpFile, 'The structure is empty.')
    else
    begin
      Writeln(DumpFile, 'Structure dump begin:');
      for I := 0 to (Size - 1) do
      begin
        Writeln(DumpFile, '  ', Items[I]);
      end;
      Writeln(DumpFile, 'Structure dump end.');
    end;
    CloseFile(DumpFile);
  except
    CloseFile(DumpFile);
    raise Exception.Create('Structure dump fail. Possible access error.');
  end;
end;

procedure TSinglyLL.Insert(const Index: Word; const NodeContent: TListContent);
begin
  Insert(Index, [NodeContent]);
end;

procedure TSinglyLL.Insert(const Index: Word; const NodesContent: array of TListContent);
var
  CurrentData: TNodeData;
  NextNode, BuffLastNode: PNode;
begin
  CurrentData := NodeDataWithIndex(Index - 1);
  if CurrentData.Node^.NextNode = Nil then
    Append(NodesContent)
  else
  begin
    NextNode := CurrentData.Node^.NextNode;
    BuffLastNode := FLastNode;
    FLastNode := CurrentData.Node;
    Append(NodesContent);
    FLastNode^.NextNode := NextNode;
    FLastNode := BuffLastNode;
  end;
  FLastRequested.Node := CurrentData.Node;
  FLastRequested.Index := CurrentData.Index;
end;

function TSinglyLL.Pop(const Index: Word = 0): TListContent;
var
  CurrentData: TNodeData;
  BuffLastNode: PNode;
begin
  FLastRequested.Node := Nil;
  if Index = 0 then
  begin
    CurrentData.Node := FHeaderNode;
    CurrentData.Index := -1;
  end
  else
    CurrentData := NodeDataWithIndex(Index - 1);
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

function TSinglyLL.PopLast: TListContent;
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

procedure TSinglyLL.Remove(const Index: Word; Quantity: Word = 1);
var
  CurrentData: TNodeData;
  BuffLastNode: PNode;
begin
  if Index = 0 then
  begin
    CurrentData.Node := FHeaderNode;
    CurrentData.Index := -1;
  end
  else
    CurrentData := NodeDataWithIndex(Index - 1);
  if CurrentData.Node^.NextNode^.NextNode = Nil then
    Cut
  else
  begin
    FLastRequested.Node := Nil;
    BuffLastNode := FLastNode;
    FLastNode := CurrentData.Node^.NextNode;
    while (Quantity <> 0) and (FLastNode <> Nil) do
    begin
      FLastNode := FLastNode^.NextNode;
      Dec(Quantity);
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

procedure TSinglyLL.Reverse;
var
  CurrentNode: PNode;
  NewHeaderNode: PNode;
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

procedure TSinglyLL.Sort(const SortOrder: TSortOrder = ASCENDING);
var
  CurrentNode: PNode;
  BuffContentElement: TListContent;
  IsSorted: Boolean;
begin
  repeat
    IsSorted := True;
    CurrentNode := FHeaderNode^.NextNode;
    while CurrentNode^.NextNode <> Nil do
    begin
      if ExchangeCondition(SortOrder, CurrentNode^.Content, CurrentNode^.NextNode^.Content) then
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
