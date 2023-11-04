   with IDL, CG_1;
   use  IDL, CG_1;
   --|----------------------------------------------------------------------------------------------
   --|	CG_Expr
   --|----------------------------------------------------------------------------------------------
    package CG_Expr is
   
       function  Type_Spec_Of_Expr	( exp :Tree )		return Tree;
       function  Constrained	( type_spec: TREE)		return Boolean;
       function  Type_Size	( type_Spec :Tree )		return Natural;
       procedure Load_Type_Size	( type_Spec :Tree );
       procedure Compile_Expression	( exp :Tree );
       procedure Load_Address_indexed	( indexed :Tree );
       procedure Load_Object_Address	( object :Tree );
       procedure Load_Address	( object :Tree );
       procedure Get_CLO	( object :Tree; comp_Unit :out Comp_Unit_Nbr; lvl :out Level_Type; ofs :out Offset_Type );
       function  Code_Type_Of	( exp_or_type_spec :Tree )	return Code_Type;
   
   --|----------------------------------------------------------------------------------------------
   end CG_Expr;
