# TLALOC Ada 83 compiler documentation

The compiler is organised around a graph like data structure which conforms to **DIANA** (Descriptive Intermediate Attributed Notation for Ada) specification. This graph structure is built with constraints expressed in **IDL**.

## What are DIANA and the IDL ?

The structural rules which must be obeyed by the data structure are expressed by an Interface Description Language or **IDL**. The **IDL** file which expresses DIANA structural rules is **diana.idl** in the directory **./idl** of the repository. This directory contains two other idl files which are used in building some compiler elements (the LALR parser and some TBL attributes files).

 From a pragmatic point of view, the **DIANA** data structure represents an **Ada 83** program unit with a graph whose nodes have a certain kind and corresponding attributes. Attributes can be references to other nodes or terminal attributes.
 
 The file **./bin/idl_tools/diana_node_attr_class_names.ads** defines the node kinds (the **NODE_NAME** Ada enumeration type with 231 modalities) and the existing attributes (**ATTRIBUTE_NAME** Ada enumeration type with 173 modalities).
 Nodes kinds are grouped into 99 classes (each represented by a subtype of **NODE_NAME**) 
 
 the file **./bin/idl_tools/diana_node_attr_class_names.ads**  is automatically produced from the descriptive **IDL** file by the **idl_tools** program in **./bin/idl_tools** (source text in **./src/idl_tools**). The tool also produces the **diana.tbl** file, a text file which indicates which attributes has a given node kind. The **diana.tbl** is in fact translated by the compiler in a **diana.bin **binary version which must be with the compiler executable.
 
 The **IDL** file **diana.idl** has // prefixed lines which define the node kind classes composition and attributes. An heritage rule transfers class attributes to sub-classes and to terminal nodes. This compact expression is very difficult to visualize so that **idl_tools** also produces helping files **diana_CLASS_.txt**, **diana_NODES_.txt** and **diana_NODES.txt** which lists classes hierarchy and nodes' complete attribute heritage. Those files are helpful to see what attributes are available for a node kind when using access functions to the **DIANA** graph. They have LibreOffice .odt associated files **DIANA_CLASS_.odt** and **DIANA_NODES.odt** in the **./doc** directory. 
 
 The **Ada 83** package file **idl.ads** is the interface to the **DIANA** graph and contains the fundamental **TREE** type with which all the **DIANA** structure is built :
 
 <pre>
   type TREE (PT : VPTR_TYPE := P)	is record				--| TREE KIND IS NODE POINTER BY DEFAULT
		  case PT is
		  when P | L =>										--| NORMAL POINTER OR LIST ATTRIBUTE
		    TY			: NODE_NAME;						--| NODE KIND
		    PG			: PAGE_IDX;							--| VIRTUAL PAGE REFERENCE
		    LN			: LINE_IDX;							--| OFFSET IN VIRTUAL PAGE
		  when S =>											--| SOURCE_LINE POINTER
		    COL			: SRCCOL_IDX;						--| COLUMN IN SOURCE TEXT
		    SPG			: PAGE_IDX;							--| VRTUAL PAGE REFERENCE
		    SLN			: LINE_IDX;							--| OFFSET IN VIRTUAL PAGE
		  when HI =>										--| NODE HEADER OR  SHORT INTEGER CODE (ABS VAL AND 
		    NOTY		: NODE_NAME;						--| NODE KIND
		    ABSS		: POSITIVE_SHORT;					--| ABS VALUE OF SHORT INTEGER
		    NSIZ		: ATTR_NBR;							--| ATTRIBUTES NUMBER OR TWO'S COMPLEMENT INDICATOR0+ 1- FOR ABSS
		  end case;
		end record;

 </pre>
 
 This same package specification gives access subprograms to the **DIANA** graph, the **D**, **DI**, **DB** read functions and write procedures. Those subprograms are used by the **CODE_GEN** procedure.
 
 
