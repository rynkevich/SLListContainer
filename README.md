# SLListContainer
Singly Linked List container class for Delphi.

### Linked List
**Linked list** is a linear collection of data elements, called nodes, each pointing to the next node by means of a pointer. It is a data structure consisting of a group of nodes which together represent a sequence. Under the simplest form, each node is composed of data and a link to the next node in the sequence. This structure allows for efficient insertion or removal of elements from any position in the sequence during iteration.

### Singly Linked List
**Singly linked lists** contain nodes which have a data field as well as a 'next' field, which points to the next node in line of nodes. Operations that can be performed on singly linked lists include insertion, deletion and traversal.

![Singly Linked List structure](https://upload.wikimedia.org/wikipedia/commons/thumb/6/6d/Singly-linked-list.svg/408px-Singly-linked-list.svg.png)

### Implementation features
Although this particular implementation has been created in study purposes, it can actually be used for any projects that require use of SLL.
There are options of:
* **Creation** of an empty or a filled list;
* **Appending** a node or a group of nodes to the end;
* **Cutting** the last node;
* **Insertion** of a node or a group of nodes to the end;
* **Removal** of a various quantity of nodes;
* **Popping** the last or the first node, _popping_ a node with specified index;
* **Counting** nodes with specified content;
* Ascending or descending **sort** of a list;
* **Reversion** of a list;
* **Cleansing** of a list;
* Getting a **list size** (quantity of meaningful nodes);
* **Check for emptiness** of a list;
* **Setting** or **getting** a node content;
* _etc._

Additionally, SLL is modified with header node for more effective use of structure,
some methods are accelerated by caching the last and the last requested nodes.
