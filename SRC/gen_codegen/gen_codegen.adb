with Text_io;
use  Text_io;
--|----------------------------------------------------------------------------------------------
--|	procedure Gen_Codegen
procedure Gen_Codegen is

  fs	: File_Type;
   
  --|-------------------------------------------------------------------------------------------
  --|	package Lex
  --|-------------------------------------------------------------------------------------------
  package Lex is
       
    line_Nbr		: Natural	:= 0;
    sepa_tab_only	: Boolean	:= false;
       
    procedure Avance;				--| Prend un lexeme
    function  Lexeme	return String;			--| Donne le lexeme
    procedure Re_Init;				--| Retour au début du fichier contenant les sections de CodeGen
    procedure Lex_End;				--| Termine le balayage lexical ferme le fichier des sections de CodeGen
          
  --|-------------------------------------------------------------------------------------------
  end Lex;
      
  package body Lex is separate;
  use Lex;
   
  --|-------------------------------------------------------------------------------------------
  --|	procedure Gen_Specs
  procedure Gen_Specs is
    object_Name	: String( 1..256 );
    object_Name_Len	: Natural	:= 0;
  begin
    while LEXEME /= "STOP" loop
      declare
               name	: constant String	:= LEXEME;			--| CONSERVER LE LEXEME NOM DE PROCEDURE
      begin
        AVANCE;					--| PRENDRE LE LEXEME SUIVANT
        if LEXEME = "====>" then				--| SI C'EST LA FLECHE CA NOUS INTERESSE
	--| PREFIXER LES LEXEMES NOM DE PROCEDURE CONFONDUS AVEC DES MOTS CLES (PAS DE "PROCEDURE CASE" ! )
          if name = "BODY" or name = "in" or name = "out" or name = "in_out"
            or name = "for" or name = "reverse" or name = "while"
            or name = "with" or name = "all"
            or name = "if" or name = "delay"
            or name = "case" or name = "loop"
            or name = "abort" or name = "terminate"
            or name = "exit" or name = "return"
            or name = "goto" or name = "accept"
            or name = "raise"
          then
            object_Name_Len := name'length + 4;			--| ALLONGER LA LONGUEUR DE CELLE DE "ADA_"
            object_Name( 1..object_Name_Len ) := "ada_" & name( name'first..name'last );	--| NOM D'OBJET = LEXEME & PREFIXE
          else					--| PAS UN MOT CLE
            object_Name_Len := name'length;			--| NOM D'OBJET CONFONDU AVEC LE LEXEME
            object_Name( 1..object_Name_Len ) := name( name'first..name'last );		--| ET LONGUEUR
          end if;
                  
          PUT_LINE ( fs, "  PROCEDURE CODE_" & name & " ( " & object_Name( 1..object_Name_Len ) & " :Tree );" );
          AVANCE;					--| POURSUIVRE LE BALAYAGE
                 
        end if;
      end;
    end loop;
    Lex.RE_INIT;					--| REVENIR EN DEBUT DE FICHIER POUR GENERER LES CORPS
  end;
  --|-------------------------------------------------------------------------------------------
  --|	procedure Gen_Procs
  procedure Gen_Procs is
    in_procs		: Boolean	:= false;
    seen_An_Action	: Boolean	:= false;
    in_if		: Boolean	:= false;
    in_repeat		: Boolean	:= false;
    object_Name	: String( 1..256 );
    object_Name_Len	: Natural	:= 0;
         
    --|----------------------------------------------------------------------------------------
    --|	procedure Gen_Action
    procedure Gen_Action ( action :String ) is
          
      function Param ( token :String ) return String is
      begin
        if token = "@" then
          AVANCE;
          declare
            attribut	: constant String	:= LEXEME;
          begin
            AVANCE;
            return "D ( " & attribut & ", " & PARAM ( LEXEME ) & " )";
          end;
                  
        else
          if LEXEME = "BODY" or LEXEME = "in" or LEXEME = "out" or LEXEME = "in_out"
            or LEXEME = "for" or LEXEME = "reverse" or LEXEME = "while"
            or LEXEME = "with" or LEXEME = "all"
            or LEXEME = "if" or LEXEME = "delay"
            or LEXEME = "case" or LEXEME = "loop"
            or LEXEME = "abort" or LEXEME = "terminate"
            or LEXEME = "exit" or LEXEME = "return"
            or LEXEME = "goto" or LEXEME = "accept"
            or LEXEME = "raise"
          then
            return "ADA_" & LEXEME;
          else
            return LEXEME;
          end if;
        end if;
      end;
          
      procedure If_Alternative ( if_If_Class_Difference :String ) is
      begin
        NEW_LINE ( fs );
        if not in_if then
          PUT ( fs, "    IF " );
        else
          PUT ( fs, "    ELSIF " );
        end if;
        PUT_LINE ( fs, object_Name( 1..object_Name_Len ) & if_If_Class_Difference & LEXEME & " then" );
        in_if := true;
      end;
          
    begin -- GEN_ACTION
      seen_An_Action := true;

      if action = "call" then
        PUT ( fs, "      CODE_" & LEXEME );
        AVANCE;
        PUT ( fs,  " ( " );
        PUT_LINE ( fs, PARAM ( LEXEME ) & " );" );
        seen_An_Action := true;
        AVANCE;
               
      elsif action = "if_class" then
        IF_ALTERNATIVE ( ".TY IN CLASS_" );
        AVANCE;
            
      elsif action = "if" then
        IF_ALTERNATIVE ( ".TY = DN_" );
        AVANCE;
               
      elsif action = "repeat_extract" then
        declare
          list_name	: constant String := LEXEME;
        begin
          AVANCE;
          PUT_LINE ( fs, "    DECLARE" );
          PUT_LINE ( fs, "      " &  object_Name( 1..object_Name_Len )
                     & "eq : Seq_Type := LIST ( " & object_Name( 1..object_Name_Len ) & " );" );
          PUT_LINE ( fs, "      " &  LEXEME & " : TREE;" );
          PUT_LINE ( fs, "    BEGIN" );
          PUT_LINE ( fs, "      WHILE NOT IS_EMPTY ( " & object_Name( 1..object_Name_Len ) & "eq ) LOOP" );
          PUT_LINE ( fs, "        POP ( " & object_Name( 1..object_Name_Len ) & "eq, " & LEXEME & " );" );
          in_repeat := true;
          AVANCE;
        end;
               
      elsif action = "end_if" then
        NEW_LINE ( fs );
        PUT_LINE ( fs, "    END IF;" );
        in_if := false;
            
      elsif action = "end_repeat" then
        PUT_LINE ( fs, "    END LOOP;" );
        PUT_LINE ( fs, "    END;" );
        in_repeat := false;
            
      else
        seen_An_Action := false;
      end if;
    end GEN_ACTION;
         
  begin -- GEN_PROCS
    while LEXEME /= "STOP" loop
         
      declare
        name	: constant String	:= LEXEME;
      begin
        if name = "include" then
          seen_An_Action := true;
          sepa_tab_only := true;
          AVANCE;
          sepa_tab_only:= false;
          PUT_LINE ( fs, "    " & LEXEME );
          AVANCE;
                  
        else
          AVANCE;
          if LEXEME = "====>" then
            if in_Procs then
              if not seen_An_Action then
                PUT_LINE ( fs, "    NULL;" );
              end if;
              if in_if then
                NEW_LINE ( fs );
                PUT_LINE ( fs, "    END IF;" );
                in_if := false;
              end if;
              if in_repeat then
                PUT_LINE ( fs, "    END LOOP;" );
                PUT_LINE ( fs, "    END;" );
                in_repeat := false;
              end if;
              PUT_LINE ( fs, "  END;" );
              NEW_LINE ( fs ); 
            end if;
            in_Procs := true;
            PUT_LINE ( fs, "  --|-------------------------------------------------------------------------------------------" );
                 
            if name = "BODY" or name = "in" or name = "out" or name = "in_out"
              or name = "for" or name = "while" or name = "reverse"
              or name = "with" or name = "all"
              or name = "if" or name = "delay"
              or name = "case" or name = "loop"
              or name = "abort" or name = "terminate"
              or name = "exit" or name = "return"
              or name = "goto" or name = "accept"
              or name = "raise"
            then
              object_Name_Len := name'length + 4;
              object_Name( 1..object_Name_Len ) := "ADA_" & name( name'first..name'last );
            else
              object_Name_Len := name'length;
              object_Name( 1..object_Name_Len ) := name( name'first..name'last );
            end if;
                  
            PUT_LINE ( fs, "  PROCEDURE CODE_" & name & " ( " & object_Name( 1..object_Name_Len ) & " :TREE ) IS" );
            AVANCE;
                  
            PUT_LINE ( fs, "  BEGIN" );
            seen_An_Action := false;
          else
            GEN_ACTION ( name );
          end if;
        end if;
            
      end;
            
    end loop;
  end GEN_PROCS;
   
   
begin
  CREATE ( fs, out_file, "../SRC/code_gen/code_gen.adb" );
   
  PUT_LINE ( fs, "WITH EMITS, node_Attr_Class_Names, IDL, TEXT_IO;" );
  PUT_LINE ( fs, "USE  EMITS, node_Attr_Class_Names, IDL, TEXT_IO;" );
  PUT_LINE ( fs, "--|----------------------------------------------------------------------------------------------" );
  PUT_LINE ( fs, "--|" & Ascii.HT & "procedure Code_Gen" );
  PUT_LINE ( fs, "PROCEDURE CODE_GEN IS" );
  NEW_LINE ( fs );
   
  GEN_SPECS;					--| GENERER LES SPECIFS DES PROCEDURES DE CODEGEN
  GEN_PROCS;					--| PUIS GENERER LES CORPS (QUI REFERENCENT LES SPECIFS)
   
  PUT_LINE ( fs, "  END;" );
  NEW_LINE ( fs );
  PUT_LINE ( fs, "BEGIN" );
  PUT_LINE ( fs, "  OPEN_IDL_TREE_FILE ( LIB_PATH(1..LPL) & ""$$$.TMP"" );" );
  PUT_LINE ( fs, "  CODE_root ( Tree_Root );" );
  PUT_LINE ( fs, "  CLOSE_IDL_TREE_FILE;" );
  PUT_LINE ( fs, "END CODE_GEN;" );
      
  LEX_END;
     
  CLOSE ( fs );
end GEN_CODEGEN;
