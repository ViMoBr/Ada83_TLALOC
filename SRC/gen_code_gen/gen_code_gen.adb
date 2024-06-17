with Text_io;
use  Text_io;
			------------
procedure			GEN_CODE_GEN
is			------------

  FS	: FILE_TYPE;
   
		---
  package		LEX
  is		---

    LINE_NBR		: NATURAL		:= 0;
    SEPA_TAB_ONLY		: BOOLEAN		:= FALSE;
       
    procedure AVANCE;										--| Prend un lexeme
    function  LEXEME	return STRING;								--| Donne le lexeme
    procedure RE_INIT;										--| Retour au début du fichier contenant les sections de CodeGen
    procedure LEX_END;										--| Termine le balayage lexical ferme le fichier des sections de CodeGen
          
  end LEX;
  --------
  package body LEX is separate;
  use LEX;

			---------
  procedure		GEN_SPECS
  is			---------

    OBJECT_NAME		: STRING( 1..256 );
    OBJECT_NAME_LEN		: NATURAL			:= 0;

  begin
    while LEXEME /= "STOP" loop
      declare
        NAME	: constant STRING	:= LEXEME;							--| CONSERVER LE LEXEME QUI SERA NOM DE PROCEDURE
      begin
        AVANCE;											--| PRENDRE LE LEXEME SUIVANT
        if LEXEME = "====>" then									--| SI C'EST LA FLECHE CA NOUS INTERESSE
	--| PREFIXER PAR "ada_" LE NAME (LEXEME POUR NOM DE PROCEDURE) POUR NE PAS CONFONDRE AVEC LES MOTS CLES (PAS DE "PROCEDURE CASE" ! )
          if   NAME = "BODY"  or NAME = "in"      or NAME = "out"    or NAME = "in_out"
            or NAME = "for"   or NAME = "reverse" or NAME = "while"
            or NAME = "with"  or NAME = "all"
            or NAME = "if"    or NAME = "delay"
            or NAME = "case"  or NAME = "loop"
            or NAME = "abort" or NAME = "terminate"
            or NAME = "exit"  or NAME = "return"
            or NAME = "goto"  or NAME = "accept"
            or NAME = "raise"
          then
            OBJECT_NAME_LEN := NAME'LENGTH + 4;								--| ALLONGER LA LONGUEUR DE CELLE DE "ada_"
            OBJECT_NAME( 1..OBJECT_NAME_LEN ) := "ada_" & NAME( NAME'FIRST..NAME'LAST );				--| NOM D'OBJET = LEXEME & PREFIXE
          else											--| PAS UN MOT CLE
            OBJECT_NAME_LEN := NAME'LENGTH;								--| NOM D'OBJET CONFONDU AVEC LE LEXEME
            OBJECT_NAME( 1..OBJECT_NAME_LEN ) := NAME( NAME'FIRST..NAME'LAST );					--| ET LONGUEUR
          end if;
                  
          PUT_LINE ( FS, "  PROCEDURE CODE_" & NAME & " ( " & OBJECT_NAME( 1..OBJECT_NAME_LEN ) & " :Tree );" );
          AVANCE;											--| POURSUIVRE LE BALAYAGE
                 
        end if;
      end;
    end loop;
    LEX.RE_INIT;											--| REVENIR EN DEBUT DE FICHIER POUR GENERER LES CORPS
  end GEN_SPECS;
  --------------

					---------
  			procedure		GEN_PROCS
					---------
  is
    IN_PROCS		: BOOLEAN		:= FALSE;
    SEEN_AN_ACTION		: BOOLEAN		:= FALSE;
    IN_IF			: BOOLEAN		:= FALSE;
    IN_REPEAT		: BOOLEAN		:= FALSE;
    OBJECT_NAME		: STRING( 1..256 );
    OBJECT_NAME_LEN		: NATURAL		:= 0;

						----------
				procedure		GEN_ACTION ( action :STRING )
						----------
    is
          
      function PARAM ( TOKEN :STRING ) return STRING is
      begin
        if TOKEN = "@" then
          AVANCE;
          declare
            ATTRIBUT	: constant STRING	:= LEXEME;
          begin
            AVANCE;
            return "D ( " & attribut & ", " & PARAM ( LEXEME ) & " )";
          end;
                  
        else
          if   LEXEME = "BODY"  or LEXEME = "in"      or LEXEME = "out"   or LEXEME = "in_out"
            or LEXEME = "for"   or LEXEME = "reverse" or LEXEME = "while"
            or LEXEME = "with"  or LEXEME = "all"
            or LEXEME = "if"    or LEXEME = "delay"
            or LEXEME = "case"  or LEXEME = "loop"
            or LEXEME = "abort" or LEXEME = "terminate"
            or LEXEME = "exit"  or LEXEME = "return"
            or LEXEME = "goto"  or LEXEME = "accept"
            or LEXEME = "raise"
          then
            return "ADA_" & LEXEME;
          else
            return LEXEME;
          end if;
        end if;
      end;
          
      procedure IF_ALTERNATIVE ( IF_IF_CLASS_DIFFERENCE :STRING ) is
      begin
        NEW_LINE ( FS );
        if not IN_IF then
          PUT ( FS, "    if " );
        else
          PUT ( FS, "    elsif " );
        end if;
        PUT_LINE ( FS, OBJECT_NAME( 1..OBJECT_NAME_LEN ) & IF_IF_CLASS_DIFFERENCE & LEXEME & " then" );
        IN_IF := TRUE;
      end;
          
    begin						-- GEN_ACTION
      SEEN_AN_ACTION := true;

      if ACTION = "call" then
        PUT ( FS, "      CODE_" & LEXEME );
        AVANCE;
        PUT ( FS,  " ( " );
        PUT_LINE ( FS, PARAM ( LEXEME ) & " );" );
        SEEN_AN_ACTION := true;
        AVANCE;
               
      elsif ACTION = "if_class" then
        IF_ALTERNATIVE ( ".TY IN CLASS_" );
        AVANCE;
            
      elsif ACTION = "if" then
        IF_ALTERNATIVE ( ".TY = DN_" );
        AVANCE;
               
      elsif ACTION = "repeat_extract" then
        declare
          LIST_NAME	: constant STRING := LEXEME;
        begin
          AVANCE;
          PUT_LINE ( FS, "    declare" );
          PUT_LINE ( FS, "      " &  OBJECT_NAME( 1..OBJECT_NAME_LEN )
                     & "eq : Seq_Type := LIST ( " & OBJECT_NAME( 1..OBJECT_NAME_LEN ) & " );" );
          PUT_LINE ( FS, "      " &  LEXEME & " : TREE;" );
          PUT_LINE ( FS, "    begin" );
          PUT_LINE ( FS, "      while not IS_EMPTY ( " & OBJECT_NAME( 1..OBJECT_NAME_LEN ) & "eq ) loop" );
          PUT_LINE ( FS, "        POP ( " & OBJECT_NAME( 1..OBJECT_NAME_LEN ) & "eq, " & LEXEME & " );" );
          IN_REPEAT := TRUE;
          AVANCE;
        end;
               
      elsif action = "end_if" then
        NEW_LINE ( FS );
        PUT_LINE ( fs, "    end if;" );
        IN_IF := FALSE;
            
      elsif action = "end_repeat" then
        PUT_LINE ( FS, "    end loop;" );
        PUT_LINE ( FS, "    end;" );
        IN_REPEAT := FALSE;
            
      else
        SEEN_AN_ACTION := FALSE;
      end if;
    end GEN_ACTION;
         
  begin												-- GEN_PROCS
    while LEXEME /= "STOP" loop
         
      declare
        NAME	: constant STRING	:= LEXEME;
      begin
        if NAME = "include" then
          SEEN_AN_ACTION := TRUE;
          SEPA_TAB_ONLY  := TRUE;
          AVANCE;
          SEPA_TAB_ONLY  := FALSE;
          PUT_LINE ( FS, "    " & LEXEME );
          AVANCE;
                  
        else
          AVANCE;
          if LEXEME = "====>" then
            if IN_PROCS then
              if not SEEN_AN_ACTION then
                PUT_LINE ( FS, "    null;" );
              end if;
              if IN_IF then
                NEW_LINE ( FS );
                PUT_LINE ( FS, "    end if;" );
                IN_IF := FALSE;
              end if;
              if IN_REPEAT then
                PUT_LINE ( FS, "    end loop;" );
                PUT_LINE ( FS, "    end;" );
                IN_REPEAT := FALSE;
              end if;
              PUT_LINE ( FS, "  end;" );
              NEW_LINE ( FS ); 
            end if;
            IN_PROCS := TRUE;
            PUT_LINE ( FS,
	"  --|-------------------------------------------------------------------------------------------" );
                 
            if   NAME = "BODY"  or NAME = "in"    or NAME = "out"     or NAME = "in_out"
              or NAME = "for"   or NAME = "while" or NAME = "reverse"
              or NAME = "with"  or NAME = "all"
              or NAME = "if"    or NAME = "delay"
              or NAME = "case"  or NAME = "loop"
              or NAME = "abort" or NAME = "terminate"
              or NAME = "exit"  or NAME = "return"
              or NAME = "goto"  or NAME = "accept"
              or NAME = "raise"
            then
              OBJECT_NAME_LEN := NAME'LENGTH + 4;
              OBJECT_NAME( 1..OBJECT_NAME_LEN ) := "ADA_" & NAME( NAME'FIRST..NAME'LAST );
            else
              OBJECT_NAME_LEN := NAME'LENGTH;
              OBJECT_NAME( 1..OBJECT_NAME_LEN ) := NAME( NAME'FIRST..NAME'LAST );
            end if;
                  
            PUT_LINE ( FS, "  procedure CODE_" & NAME & " ( " & OBJECT_NAME( 1..OBJECT_NAME_LEN ) & " :TREE ) is" );
            AVANCE;
                  
            PUT_LINE ( FS, "  begin" );
            SEEN_AN_ACTION := FALSE;
          else
            GEN_ACTION ( NAME );
          end if;
        end if;
            
      end;
            
    end loop;
    if IN_IF then
      NEW_LINE ( FS );
      PUT_LINE ( FS, "    end if;" );
      IN_IF := FALSE;
    end if;
  end GEN_PROCS;
  --------------
   
   
begin
  CREATE ( FS, OUT_FILE, "../SRC/code_gen/code_gen.adb" );
   
  PUT_LINE ( FS, "WITH EMITS, DIANA_NODE_ATTR_CLASS_NAMES, IDL, TEXT_IO;" );
  PUT_LINE ( FS, "USE  EMITS, DIANA_NODE_ATTR_CLASS_NAMES, IDL, TEXT_IO;" );

  PUT_LINE ( FS, Ascii.HT & Ascii.HT & Ascii.HT    & Ascii.HT & Ascii.HT & "--------" );
  PUT_LINE ( FS, Ascii.HT & Ascii.HT & Ascii.HT & "procedure" & Ascii.HT & Ascii.HT & "CODE_GEN" );
  PUT_LINE ( FS, Ascii.HT & Ascii.HT & Ascii.HT    & Ascii.HT & Ascii.HT & "--------" );
  PUT_LINE ( FS, "is" );
  NEW_LINE ( FS );
   
  GEN_SPECS;											--| GENERER LES SPECIFS DES PROCEDURES DE CODEGEN
  GEN_PROCS;											--| PUIS GENERER LES CORPS (QUI REFERENCENT LES SPECIFS)
   
  PUT_LINE ( FS, "  end;" );
  NEW_LINE ( FS );
  PUT_LINE ( FS, "begin" );
  PUT_LINE ( FS, "  OPEN_IDL_TREE_FILE ( LIB_PATH(1..LIB_PATH_LENGTH) & ""$$$.TMP"" );" );
  PUT_LINE ( FS, "  CODE_root ( Tree_Root );" );
  PUT_LINE ( FS, "  CLOSE_IDL_TREE_FILE;" );
  PUT_LINE ( FS, "end CODE_GEN;" );
      
  LEX_END;
     
  CLOSE ( FS );
end GEN_CODE_GEN;
