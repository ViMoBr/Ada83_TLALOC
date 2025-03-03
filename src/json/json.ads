--	JSON.ADS	VINCENT MORIN	25/2/2025		UNIVERSITE DE BRETAGNE OCCIDENTALE	(UBO)
-------------------------------------------------------------------------------------------------------------------------
--	1	2	3	4	5	6	7	8	9	0	1	2


with TEXT_IO;
						----
			package			JSON
						----
is

  type ITEM		is private;

  type ITEM_TYPE		is ( OBJECT_ITEM, ARRAY_ITEM,
			     STRING_ITEM, INTEGER_ITEM, FLOAT_ITEM, BOOLEAN_ITEM, NULL_ITEM );

  subtype TERMINAL_TYPE	is ITEM_TYPE range STRING_ITEM .. NULL_ITEM;

  subtype FILE_TYPE		is TEXT_IO.FILE_TYPE;

  MAX_STRING_LENGTH		:constant NATURAL	:= 2**15-1;
  subtype STRING_LENGTH	is NATURAL range 0 .. MAX_STRING_LENGTH;

  type VALUE_DATA (KIND :TERMINAL_TYPE := NULL_ITEM; LENGTH :STRING_LENGTH := 0)
			is record
			  case  KIND
			  is
			    when STRING_ITEM	=> STRING_VAL	:STRING( 1 .. LENGTH );
			    when INTEGER_ITEM	=> INT_VAL	:INTEGER;
			    when FLOAT_ITEM		=> FLOAT_VAL	:LONG_FLOAT;
			    when BOOLEAN_ITEM	=> BOOL_VAL	:BOOLEAN;
			    when NULL_ITEM		=> null;
			  end case;
			end record;


				--  J S O N   I T E M   I / O


  procedure GET			( FILE :in JSON.FILE_TYPE; THE_ITEM :out ITEM );
  procedure PUT			( FILE :in out JSON.FILE_TYPE; THE_ITEM :ITEM );
  function  STRING_OF		( THE_ITEM :ITEM)				return STRING;
  function  ITEM_OF			( THE_STRING :STRING)			return ITEM;


				--  J S O N   I T E M   I N T E R A C T I O N


  function  KIND			( OF_ITEM :ITEM )				return ITEM_TYPE;
  function  IS_PRESENT		( KEY :STRING; IN_OBJECT :ITEM )		return BOOLEAN;
  function  ITEM_BY_KEY		( KEY :STRING; IN_OBJECT :ITEM )		return ITEM;
  function  ITEM_VALUE		( OF_ITEM :ITEM )				return VALUE_DATA;
  function  NUMBER_OF_SUB_ITEMS	( IN_ITEM :ITEM )				return NATURAL;
  procedure FREE			( THE_ITEM :in out ITEM );

  generic
    with procedure APPLY_PROCESS ( ON_ITEM :in out ITEM; LAST_ONE :in BOOLEAN; STOP_PROCESS :out BOOLEAN );
  procedure FOR_EACH_JSON_ITEM	( OF_ARRAY :ITEM );

  generic
    with procedure APPLY_PROCESS ( KEY :STRING; ON_ITEM :in out ITEM; LAST_ONE :in BOOLEAN; STOP_PROCESS :out BOOLEAN );
  procedure FOR_EACH_JSON_FIELD	( OF_OBJECT :ITEM );


  SYNTAX_ERROR, BAD_ITEM_TYPE, VALUE_NOT_FOUND	: exception;


--	1	2	3	4	5	6	7	8	9	0	1	2
-------------------------------------------------------------------------------------------------------------------------

										pragma PAGE;
private

  type ITEM_DEFINITION (KIND :JSON.ITEM_TYPE);
  type ITEM			is access ITEM_DEFINITION;

  type OBJECT_FIELD;
  type OBJECT_FIELD_ACCESS		is access OBJECT_FIELD;

  type ITEM_LIST_ELEMENT;
  type LIST_OF_ITEMS		is access ITEM_LIST_ELEMENT;

  type STRING_ACCESS		is access STRING;


  type ITEM_DEFINITION (KIND :ITEM_TYPE)	is record
				  case KIND is
				  when  OBJECT_ITEM		=> FIELDS_LIST	: OBJECT_FIELD_ACCESS;
				  when  ARRAY_ITEM		=> ITEMS_LIST	: LIST_OF_ITEMS;
				  when  STRING_ITEM		=> STR_ACCESS	: STRING_ACCESS;
				  when  INTEGER_ITEM	=> INT_VAL	: INTEGER;
				  when  FLOAT_ITEM		=> FLOAT_VAL	: LONG_FLOAT;
				  when  BOOLEAN_ITEM	=> BOOL_VAL	: BOOLEAN;
				  when  NULL_ITEM		=> null;
				  end case;
				end record;


  type OBJECT_FIELD			is record
				  FIELD_KEY	: STRING_ACCESS;
				  FIELD_ITEM	: ITEM;
				  NEXT		: OBJECT_FIELD_ACCESS;
				end record;


  type ITEM_LIST_ELEMENT		is record
				  LIST_ITEM	: ITEM;
				  NEXT		: LIST_OF_ITEMS;
				end record;

	----
end	JSON;
	----

--	1	2	3	4	5	6	7	8	9	0	1	2
-------------------------------------------------------------------------------------------------------------------------

