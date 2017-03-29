# ContainerSLL
Singly Linked List container class for Delphi. BETA

### Linked List
**Linked list** is a linear collection of data elements, called nodes, each pointing to the next node by means of a pointer. It is a data structure consisting of a group of nodes which together represent a sequence. Under the simplest form, each node is composed of data and a link to the next node in the sequence. This structure allows for efficient insertion or removal of elements from any position in the sequence during iteration.

### Singly Linked List
**Singly linked lists** contain nodes which have a data field as well as a 'next' field, which points to the next node in line of nodes. Operations that can be performed on singly linked lists include insertion, deletion and traversal.

![Singly Linked List structure](https://upload.wikimedia.org/wikipedia/commons/thumb/6/6d/Singly-linked-list.svg/408px-Singly-linked-list.svg.png)

### Implementation features
This particular implementation was created in study purposed, but it can actually be used for any projects that require use of SLL.
There are options of:
* _Creation_ of an empty or a filled list;
* _Appending_ a node or a group of nodes to the end;
* _Cutting_ the last node;
* _Insertion_ of a node or a group of nodes to the end;
* _Removal_ of a various quantity of nodes;
* _Popping_ the last or the first node, _popping_ a node with specified index;
* _Counting_ nodes with specified content;
* Ascending or descending _sort_ of a list;
* _Reversion_ of a list;
* _Cleansing_ of a list;
* Getting a _list size_ (quantity of meaningful nodes);
* _Check for emptiness_ of a list;
* _Setting_ or _getting_ a node content;
* etc.

Additionally, SLL is modified by addition of header node for more effective use of structure,
some methods are accelerated by caching of the last and the last requested nodes.
