--|-------------------------------------------------------------------------------------------------
--|		IDL								--| VERSION SPECIALISEE POUR LE TRAITEMENT DE GRAMMAIRE
--|-------------------------------------------------------------------------------------------------
PACKAGE IDL IS
    
       	--| CREATION/OUVERTURE FERMETURE DE FICHIER .LAR (FICHIER ARBRE)
   
  PROCEDURE CREATE_IDL_TREE_FILE	( PAGE_FILE_NAME :STRING );				--| CREE UN FICHIER "PAGE_FILE_NAME.LAR"
  PROCEDURE OPEN_IDL_TREE_FILE	( PAGE_FILE_NAME :STRING );				--| OUVRE UN FICHIER "PAGE_FILE_NAME.LAR" DEJÀ CREÉ
  PROCEDURE CLOSE_IDL_TREE_FILE;							--| FERMETURE DU FICHIER ".LAR"
   
   	--| UTILITAIRES POUR GRAMMAIRE LALR
   
       PROCEDURE READ_GRMR	( NOM_TEXTE :STRING );
       PROCEDURE OPTR_GRMR	( NOM_TEXTE :STRING );
       PROCEDURE INIT_GRMR	( NOM_TEXTE :STRING );
       PROCEDURE STAT_GRMR	( NOM_TEXTE :STRING );
       PROCEDURE LALR_GRMR	( NOM_TEXTE :STRING );
       PROCEDURE CHECK_GRMR	( NOM_TEXTE :STRING );
       PROCEDURE PRINT_STAT	( NOM_TEXTE :STRING );
       PROCEDURE LOAD_GRMR	( NOM_TEXTE :STRING );
   
   
	--| DISPOSITIF D'ACCES A UN ARBRE REPESENTANT UNE DESCRIPTION DE GRAMMAIRE
   
  TYPE NODE_NAME	IS (
	DN_root,		DN_txtrep,	DN_num_val,	DN_false,
	DN_true,		DN_nil,		DN_list,		DN_sourceline,
	DN_error,		DN_symbol_rep,	DN_hash,		DN_user_root,
	DN_rule_s,	DN_rule,		DN_terminal,	DN_nonterminal,
	DN_alt,		DN_ruleinfo,	DN_state_s,	DN_state,
	DN_void,		DN_item,		DN_terminal_s,	DN_sem_s,
	DN_sem_node,	DN_sem_op,
	DN_VIRGIN
	);
	FOR NODE_NAME'SIZE USE 8;

  TYPE ATTRIBUTE_NAME	IS (
	xd_high_page,	xd_user_root,	xd_source_list,	xd_err_count,
	spare_1,		xd_head,		xd_tail,		xd_number,
	xd_error_list,	xd_srcpos,	xd_text,		xd_deflist,
	xd_list,		xd_sourcename,	xd_grammar,	xd_statelist,
	xd_structure,	xd_timestamp,	spare_3,		xd_name,
	xd_is_nullable,	xd_ruleinfo,	lx_srcpos,	xd_alt_nbr,
	xd_rule,		xd_state_s,	xd_semantics,	xd_symrep,
	xd_ter_nbr,	xd_is_reachable,	xd_gens_ter_str,	xd_timechecked,
	xd_timechanged,	xd_rule_nbr,	xd_init_nonter_s,	xd_state_nbr,
	xd_alternative,	xd_alt_tail,	xd_syl_nbr,	xd_goto,
	xd_follow,	xd_sem_index,	xd_sem_op,	xd_kind
	);

  SUBTYPE CLASS_NON_DIANA	IS NODE_NAME RANGE DN_root	.. DN_sem_op;
  SUBTYPE CLASS_BOOLEAN	IS NODE_NAME RANGE DN_false	.. DN_true;
  SUBTYPE CLASS_RULE_S	IS NODE_NAME RANGE DN_rule_s	.. DN_rule_s;
  SUBTYPE CLASS_DEF_NAME	IS NODE_NAME RANGE DN_rule	.. DN_nonterminal;
  SUBTYPE CLASS_SYLLABLE	IS NODE_NAME RANGE DN_terminal.. DN_nonterminal;
  SUBTYPE CLASS_STATE_VOID	IS NODE_NAME RANGE DN_state	.. DN_void;
  SUBTYPE CLASS_SEMANTICS	IS NODE_NAME RANGE DN_sem_node.. DN_sem_op;
   
  TYPE SHORT			IS RANGE -32_768 .. 32767;	FOR SHORT'SIZE    USE 16;
  TYPE PAGE_IDX			IS RANGE 0 .. 16#7FFF#;	FOR PAGE_IDX'SIZE USE 15;
  TYPE LINE_IDX			IS RANGE 0 .. 127;		FOR LINE_IDX'SIZE USE 7;
  SUBTYPE ATTR_NBR			IS LINE_IDX;
  TYPE LINE_NBR			IS RANGE 0 .. 128;

  TYPE SRCCOL_IDX			IS RANGE 0 .. 255;		FOR SRCCOL_IDX'SIZE USE 8;
 
  TYPE VPTR_TYPE			IS (N, S, L, F);					--| NOEUD, SOURCE_POS, LIST, FINAL
  TYPE TREE (PT : VPTR_TYPE := N)	IS						--| TYPE FONDAMENTAL REMPLISSANT LES BLOCS D ARBRE
		RECORD
		  CASE PT IS
		  WHEN N | L =>							--| POINTEUR NORMAL DE NOEUD OU ATTRIBUT LISTE
		    PG		: PAGE_IDX;					--| REFERENCE DE PAGE VIRTUELLE
		    LN		: LINE_IDX;					--| DECALAGE DANS UNE PAGE VIRTUELLE
		    TY		: NODE_NAME;					--| TYPE DE NOEUD
		  WHEN S =>							--| POINTEUR DE SOURCE_LINE AVEC COLONNE SOURCE EN PLACE DU TYPE
		    SPG		: PAGE_IDX;					--| REFERENCE DE PAGE VIRTUELLE
		    SLN		: LINE_IDX;					--| DECALAGE DANS UNE PAGE VIRTUELLE
		    COL		: SRCCOL_IDX;					--| NUMERO DE COLONNE DANS LE TEXTE SOURCE
		  WHEN F =>							--| POINTEUR NORMAL DE NOEUD OU ATTRIBUT LISTE
		    VAL		: SHORT;						--| VALEUR NUMERIQUE ENTIERE
		    TTY		: NODE_NAME;					--| TYPE DE NOEUD
		  END CASE;
		END RECORD;
		FOR TREE'SIZE USE 32;
		FOR TREE USE RECORD AT MOD 4;
			PT	AT 0 RANGE 0..1;
			LN	AT 0 RANGE 2..8;
			SLN	AT 0 RANGE 2..8;
			PG	AT 0 RANGE 9..23;
			SPG	AT 0 RANGE 9..23;
			COL	AT 0 RANGE 24..31;
			TY	AT 0 RANGE 24..31;
			TTY	AT 0 RANGE 24..31;
			VAL	AT 0 RANGE 2..17;
			END RECORD;

  TREE_NIL		: CONSTANT TREE	:= (N, 0, 1, DN_NIL);
   
  TYPE SEQ_TYPE		IS RECORD
			  FIRST, NEXT	: TREE;
			END RECORD;
   
   	--| ACCES A L'ARBRE
   
  FUNCTION  MAKE		( NN :NODE_NAME )				RETURN TREE;	--| AJOUTE UN NOEUD DE TYPE NODE_NAME
   
  PROCEDURE D		( AN :ATTRIBUTE_NAME; T :TREE; V :TREE );			--| ECRITURE D'UN ATTRIBUT CONTENANT UN ARBRE
  FUNCTION  D		( AN :ATTRIBUTE_NAME; T :TREE )		RETURN TREE;	--| LECTURE D'UN ATTRIBUT CONTENANT UN ARBRE
   
  PROCEDURE DB		( AN :ATTRIBUTE_NAME; T :TREE; V :BOOLEAN );			--| ECRITURE D'UN ATTRIBUT CONTENANT UN BOOLEEN
  FUNCTION  DB		( AN :ATTRIBUTE_NAME; T :TREE )		RETURN BOOLEAN;	--| LECTURE D'UN ATTRIBUT CONTENANT UN BOOLEEN
   
  PROCEDURE DI		( AN :ATTRIBUTE_NAME; T :TREE; V :INTEGER );			--| ECRITURE D'UN ATTRIBUT CONTENANT UN ENTIER (16 BITS)
  FUNCTION  DI		( AN :ATTRIBUTE_NAME; T :TREE )		RETURN INTEGER;	--| LECTURE D'UN ATTRIBUT CONTENANT UN ENTIER (16 BITS)
   
  FUNCTION  LIST		( T :TREE )				RETURN SEQ_TYPE;	--| REND LA LISTE CONTENUE DANS UN NOEUD POINTE PAR LE POINTEUR D'ARBRE
  FUNCTION  IS_EMPTY	( S :SEQ_TYPE )				RETURN BOOLEAN;	--| TESTE UNE LISTE
  PROCEDURE POP		( S :IN OUT SEQ_TYPE; T :OUT TREE );				--| EXTRAIT UN ELEMENT DE LISTE ET REPOINTE S SUR LE RESTE
   
  FUNCTION  PRINT_NAME	( T :TREE )				RETURN STRING;	--| TXTREP OR SYMBOL_REP
  FUNCTION  NODE_IMAGE	( NN :NODE_NAME )				RETURN STRING;	--| CHAINE REPRESENTANT UN NOEUD
  FUNCTION  ATTR_IMAGE	( AN :ATTRIBUTE_NAME )			RETURN STRING;	--| CHAIUNE REPRESENTANT UN NOM D'ATTRIBUT

	--| AFFICHAGE DE TOUT OU PARTIE DE L'ARBRE
   	
  --|-----------------------------------------------------------------------------------------------
  --|		PRINT_NOD								--| POUR L'AFFICHAGE D'ELEMENTS D'ARBRE DIANA
  --|-----------------------------------------------------------------------------------------------
  PACKAGE PRINT_NOD IS
      
    PROCEDURE PRINT_TREE	( T :TREE );
    FUNCTION  L_PRINT_TREE	( T :TREE )		RETURN NATURAL;			--| RETOURNE LE NOMBRE DE CARACTERES
    PROCEDURE PRINT_NODE	( T :TREE; INDENT :NATURAL :=0 );
       
  --|-----------------------------------------------------------------------------------------------
  END PRINT_NOD;
   
   
   
  PRAGMA INLINE ( DB );
  PRAGMA INLINE ( DI );
  PRAGMA INLINE ( D );
   
--|-------------------------------------------------------------------------------------------------
END IDL;
