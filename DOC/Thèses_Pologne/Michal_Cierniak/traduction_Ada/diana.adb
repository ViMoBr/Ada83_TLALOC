package body DIANA is

	MAXNODENUMBER : constant := 2000; -- Max: 7280

	type NODEARRAY_TYPE is array (1 .. MAXNODENUMBER) of NODE;
	type NODEARRAY_ACCESS is access NODEARRAY_TYPE;

	NODEARRAY     : NODEARRAY_ACCESS := new NODEARRAY_TYPE;
	NUMBEROFNODES : TREE := 0;

	procedure CONDITIONALERROR (ERRORNUMBER : INTEGER; ERRORCONDITION : BOOLEAN) is
	begin
		if ERRORCONDITION then
			ERROR (ERRORNUMBER);
		end if;
	end CONDITIONALERROR;

	function KIND (T : TREE) return NODE_NAME is
	begin
		CONDITIONALERROR (3, T > NUMBEROFNODES);
		return NODEARRAY (T).KIND;
	end KIND;

	procedure GET_NODE (T : TREE; ND : out NODE) is
	begin
		CONDITIONALERROR (3, T > NUMBEROFNODES);
		ND := NODEARRAY (T);
	end GET_NODE;
	function GET_NODE (T :in TREE ) return NODE is
	begin
		CONDITIONALERROR (3, T > NUMBEROFNODES);
		return NODEARRAY (T);
	end GET_NODE;

	procedure PUT_NODE (T : TREE; ND : NODE) is
	begin
		CONDITIONALERROR (5003, T > MAXNODENUMBER);
		if T > NUMBEROFNODES then
			NUMBEROFNODES := T;
		end if;
		NODEARRAY (T) := ND;
	end PUT_NODE;

	function GET_EMPTY return SEQ_TYPE is
	begin
		return null;  -- Assuming SEQ_TYPE is a pointer type, null in Ada corresponds to null in Pascal
	end GET_EMPTY;

	function HEAD (L : SEQ_TYPE) return TREE is
	begin
		return L.ELEM;
	end HEAD;

	function TAIL (L : SEQ_TYPE) return SEQ_TYPE is
	begin
		return L.NEXT;
	end TAIL;

	function IS_EMPTY (L : SEQ_TYPE) return BOOLEAN is
	begin
		return L = null;
	end IS_EMPTY;

	function INSERT (L : SEQ_TYPE; T : TREE) return SEQ_TYPE is
		PTR : SEQ_TYPE_PTR;
	begin
		PTR := new SEQ_TYPE;
		PTR.ELEM := T;
		PTR.NEXT := L;
		return PTR;
	end INSERT;

	function APPEND (L : SEQ_TYPE; T : TREE) return SEQ_TYPE is
	begin
		if L = null then
			return INSERT (L, T);
		else
			declare
				TEMP : SEQ_TYPE := L;
			begin
				while TEMP.NEXT /= null loop
					TEMP := TEMP.NEXT;
				end loop;
				TEMP.NEXT := INSERT (null, T);
				return L;
			end;
		end if;
	end APPEND;

begin
	NUMBEROFNODES := 0;
end DIANA;
