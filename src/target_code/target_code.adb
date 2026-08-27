------------------------------------------------------------------------------------------------------------------------
-- SPDX-FileCopyrightText: 2026 VINCENT MORIN, UBO
-- SPDX-License-Identifier: GPL-3.0-or-later
------------------------------------------------------------------------------------------------------------------------
--	1	2	3	4	5	6	7	8	9	0	1	2
--
--				T A R G E T _ C O D E   --   assembleur natif LLIR / FINC  ->  ELF executable
--
--	Outil autonome au meme titre que l'EXPANDER : etant donne le nom d'un .fas
--	initial et des FINC corrects, tout s'enchaine sans le frontend.
--	Reference : NOTE_SUBSET_FASMG v1. Implementations de reference : fasmg +
--	codi_x86_64.finc / codi_arm64.finc / codi_riscv64.finc (les db/dd commentes
--	des codi SONT les specs d'encodage).
--
--	DOCTRINE (v1 par 2.5) :
--	  - UNE lecture du texte, puis des phases sur l'IR en memoire. Pas de
--	    convergence d'adresses : INVARIANT DE TAILLE DETERMINISTE — la taille
--	    de chaque invocation est calculable avant de connaitre les adresses,
--	    grace aux formes canoniques (rel32/AUIPC+JALR fixes ; toute constante
--	    de classe ADRESSE en forme fixe : movabs / movz+movk / lui+addi).
--	  - Le lazy fasmg (postpone + ~definite) est remplace par le calcul
--	    d'ATTEIGNABILITE : point fixe sur un ensemble fini croissant de
--	    marques — borne par le nombre de sous-programmes, aucune oscillation.
--	  - Refus BRUYANTS (doctrine R6) : les err/assert des codi deviennent des
--	    levees explicites avec message ; jamais de repli muet.
--
--	PHASES :
--	  P0  LEX + PARSE   : .fas + includes (gardes de with = inclusion unique) ;
--	                      IR complete, y compris corps sous garde "if defined".
--	  P1  REACHABILITY  : marquage depuis l'entree via CALL/LSPA ; fermeture.
--	  P2  LAYOUT        : PRMzone/VARzone/STATOFS (unites atteignables) ;
--	                      tailles puis adresses de chaque invocation ;
--	                      constantes differees placees APRES le code en ordre
--	                      LIFO d'enregistrement (releve DIS_BONJOUR) ;
--	                      ASM_SIZE en dernier. assert image < 2**32.
--	  P3  EMIT          : en-tete ELF + amorcage + code + constantes, via la
--	                      table d'encodage de la cible ; MAP sous option.
--
-----------------------------------------------------------------------------------------------------------------------

with TEXT_IO, SEQUENTIAL_IO;
use  TEXT_IO;

					-----------
procedure					TARGET_CODE
is					-----------


  --				C I B L E S   E T   T R A I T S

  type CPU_KIND		is ( X86_64, ARM64, RISCV64 );

  TARGET_CPU		: CPU_KIND	:= X86_64;						--| choisi par option de commande ("a la DCL", a venir)

  GENERATE_BINARY_MAP	: BOOLEAN		:= FALSE;							--| pendant du flag homonyme de l'expander : reproduit
												--| les display/hexa_show (carto) sous option

  type TARGET_TRAITS	is record
			  E_MACHINE	: INTEGER;						--| 62 / 183 / 243
			  ORIG		: INTEGER;						--| 16#400000#
			  ENTRY_POINT	: INTEGER;						--| 16#400078#
			  PAD_BYTE	: INTEGER;						--| remplissage align_* : 16#90# x86, 0 sinon (byte-diff !)
			  CALL_FRAME	: INTEGER;						--| micro-pile par CALL : 8 x86, 16 arm/riscv (alignement SP)
			  MEMSZ_RESERVE	: LONG_INTEGER;						--| reserve co-pile au dessus du code (p_memsz)
			  PROLOGUE_SIZE	: INTEGER;						--| amorcage (codi queue) : 82 x86, 92 arm
			  BRA_SIZE	: INTEGER;						--| taille du BRA de BEGIN_BLOC_DEF : 5 x86, 4 arm
      --  numeros de syscalls (openat/unlinkat cote arm et riscv), constantes ioctl, etc.
			end record;

  --| Une constante TRAITS par cible, initialisee dans EMIT (corps separate).


			---
  package			LEX
  is			---

    --| P0 : flot de lignes du .fas et de ses includes (repertoire courant =
    --| ADA__LIB), LF seul, CR/FF neutralises, tabulations libres. Une
    --| invocation par ligne ; vocabulaire CLOS (NOTE v1 par 1).
    --|
    --| Effets STRUCTURELS executes AU PARSING : namespaces (litteraux et
    --| ouverts par PRO/endPRO), labels, gardes n 97 (NAME = '...'),
    --| STR/CST (declaration CONSTANT_ADDR + enregistrement differe LIFO),
    --| gardes "~ definite" (inclusion unique : bloc saute si defini).
    --| Les gardes "defined" ne sont JAMAIS evaluees a P0 : condition
    --| d'atteignabilite enregistree dans l'IR, filtree en P2/P3.
    --| Les OPERANDES restent du texte non resolu jusqu'a P2.

    LEX_FAULT		: exception;								--| refus bruyant (doctrine R6)

    TEXT_MAX		: constant	:= 50_000_000;

    type SLICE		is record
			  F	: NATURAL	:= 0;							--| tranche dans la reserve de texte
			  L	: NATURAL	:= 0;							--| F = 0 ou L < F : tranche vide
			end record;

    function  IMAGE		( S :SLICE )			return STRING;
    function  POOL_STRING	( S :STRING )			return SLICE;				--| pour les temoins et outils

    procedure RUN_P0	( FAS_NAME :STRING );							--| parse tout, alimente SYMBOLS et IR

    function  EVAL		( S :SLICE )			return LONG_INTEGER;			--| + - * / mod, parentheses ; noms resolus

    function  TEXT_USED					return NATURAL;				--| jauge : occupation de la reserve de texte
												--| BRUYAMMENT via SYMBOLS (usage : P2)
	---
  end	LEX;
	---


			-------
  package			SYMBOLS
  is			-------
    --| Arbre de portees calque sur fasmg : "namespace X" ouvre — ou ROUVRE,
    --| cumulativement (STANDARD en tete de chaque FINC) — le fils X du scope
    --| courant. RESOLUTION D'UN NOM NON POINTE = portee courante puis
    --| REMONTEE DES PARENTS UNIQUEMENT — JAMAIS les freres (piege n 105 ;
    --| l'expander emet REGIONS_PATH en s'y fiant : tout ecart casse des FINC
    --| valides). Nom pointe = premier composant par remontee, puis descente.
    --|
    --| Layout (P2) — MIROIR DE LAYOUT, piege n 110 : TARGET_CODE est la
    --| TROISIEME implementation du calcul d'alignement (fasmg,
    --| ALIGN_STATIC_BITS, ici) ; test-miroir obligatoire. Zones EMPILABLES
    --| (la VARzone ouverte par ELB peut contenir des virtual at 0).
    --|
    --| Atteignabilite (P1) : remplace le lazy fasmg (postpone + ~definite,
    --| qui exigeait structurellement le multi-passes). MARK pose
    --| PREFIX.SUBNAME_ (classe LAZY_MARK) ; les gardes "if defined X_" de
    --| l'IR s'evaluent via IS_DEFINED ; point fixe pilote par P1 sur la
    --| croissance de REACH_COUNT (ensemble fini croissant : terminaison
    --| garantie, sans rapport avec les adresses).

    SYMBOL_FAULT		: exception;								--| refus bruyant (doctrine R6)

    subtype VALUE_TYPE	is LONG_INTEGER;								--| INTEGER TLALOC = 64 bits

    type SYM_CLASS		is ( SCOPE_NAME,								--| namespace (ouvre un scope)
			     CODE_LABEL,								--| label:, elab, post, ret_lbl (adresse posee en P2)
			     FRAME_OFFSET,								--| VAR _disp, USEINFO __u  (VARzone, base 8)
			     PARAM_OFFSET,								--| PRM _ofs  (PRMzone, base 8)
			     STATIC_OFFSET,								--| STATOFS   (virtual at 0)
			     CONSTANT_ADDR,								--| STR / CST (adresse posee en P2, zone differee)
			     GUARD,								--| NAME = 'NAME' (n 97) — redefinissable
			     LAZY_MARK,								--| PREFIX.SUBNAME_ (atteignabilite)
			     PLAIN_VALUE );								--| affectation quelconque — redefinissable

    SYM_MAX		:constant			:= 1_048_576;
    type SYM_ID		is range 0 .. SYM_MAX;
    NO_SYM		:constant SYM_ID		:= 0;

    SCOPE_MAX		:constant			:= 65_536;
    type SCOPE_ID		is range 0 .. SCOPE_MAX;
    ROOT_SCOPE		:constant SCOPE_ID		:= 1;


  --				P O R T E E S

    procedure ENTER_SCOPE	( NAME :STRING );								--| ouvre ou ROUVRE le fils NAME du scope courant
    procedure LEAVE_SCOPE;
    function  CURRENT_SCOPE					return SCOPE_ID;				--| memorise par l'IR sur chaque element
    procedure USE_SCOPE	( S :SCOPE_ID );								--| repositionnement en P1/P2/P3


  --				D E C L A R A T I O N S   R E S O L U T I O N S

    procedure DECLARE_SYM	( NAME :STRING; CLASS :SYM_CLASS; VALUE :VALUE_TYPE := 0 );
    function  DECLARE_SYM	( NAME :STRING; CLASS :SYM_CLASS; VALUE :VALUE_TYPE := 0 ) return SYM_ID;
    procedure SET_VALUE	( S :SYM_ID; VALUE :VALUE_TYPE );						--| adresses et tailles posees en P2
    function  RESOLVE	( DOTTED :STRING ) 			return SYM_ID;				--| leve SYMBOL_FAULT si introuvable
    function  TRY_RESOLVE	( DOTTED :STRING )			return SYM_ID;				--| NO_SYM si introuvable (defined / ~definite)
    function  IS_DEFINED	( DOTTED :STRING )			return BOOLEAN;
    function  CLASS_OF	( S :SYM_ID )			return SYM_CLASS;
    function  VALUE_OF	( S :SYM_ID )			return VALUE_TYPE;				--| leve si valeur non posee (garde anti bug de phase)
    function  SCOPE_UNDER	( S :SYM_ID )			return SCOPE_ID;				--| scope OUVERT par S (classe SCOPE_NAME)
    procedure SET_EPOCH	( N :NATURAL );								--| epoque des boucles d'elements (TC-24)


  --				Z O N E S   D E   L A Y O U T

    procedure OPEN_ZONE	( BASE :VALUE_TYPE );
    procedure ZONE_ALIGN	( ALGN :VALUE_TYPE );							--| padding VIRTUEL (les octets 90/00 : affaire d'EMIT)
    procedure ZONE_RESERVE	( SIZE :VALUE_TYPE );
    function  ZONE_POS					return VALUE_TYPE;				--| le "$" fasmg de la zone courante
    function  CLOSE_ZONE					return VALUE_TYPE;				--| position finale (prm_siz/loc_siz ajustes par l'appelant)


  --				A T T E I G N A B I L I T E

    procedure MARK		( PREFIX, SUBNAME :STRING );							--| declare PREFIX.SUBNAME_ si absente
    function  REACH_COUNT					return NATURAL;				--| croissance => continuer le point fixe


  --				C A R T O

    procedure DUMP_MAP;										--| sous GENERATE_BINARY_MAP

  --				J A U G E S

    function  POOL_USED					return NATURAL;				--| jauges capacites (TC-22)
    function  POOL_CAPACITY					return NATURAL;				--| borne du pool (declaree au corps)
    function  SYM_COUNT					return NATURAL;
    function  SCOPE_COUNT					return NATURAL;

	-------
  end	SYMBOLS;
	-------


			--
  package			IR
  is			--

    --| Liste sequentielle des elements entre P0 et P3. Chaque element est
    --| estampille a sa creation : scope courant et garde lazy courante
    --| (condition d'atteignabilite ; tranche vide = inconditionnel). Les
    --| corps sous "if defined" sont PRESENTS, filtres en P2/P3.
    --| Differes (STR/CST) en ordre d'enregistrement ; emission en ordre
    --| INVERSE (LIFO fasmg, releve DIS_BONJOUR) juste apres le code ;
    --| ASM_SIZE en tout dernier. TAILLE et ADRESSE par element : champs
    --| poses en P2 (livraison TC-03).

    IR_FAULT		: exception;								--| refus bruyant (doctrine R6)

    ELT_MAX		:constant			:= 1_000_000;
    type ELT_ID		is range 0 .. ELT_MAX;

    OPS_MAX		:constant			:= 5_000_000;
    DEFER_MAX		:constant			:= 200_000;

    type ELT_KIND		is ( MACRO_CALL,								--| toute macro LLIR (y compris STATOFS, db...)
			     LABEL_DEF,								--| "nom:"
			     ASSIGNMENT,								--| "X = expr" hors garde n 97 (evaluee en P2)
			     VIRT_OPEN,								--| "virtual at N"
			     VIRT_CLOSE,								--| "end virtual"
			     MAP_NOTE,								--| display / hexa_show (emis sous option)
			     AREA_DEF,								--| "nom::" : zone d'adressage (VARzone, tete .fas)
			     VIRT_REOPEN );								--| "virtual NOM" : reouverture de zone (queue .fas)

    type OPERAND_TAG	is ( EMPTY_OP, INT_OP, FLT_OP, NAME_OP, EXPR_OP, STRB_OP );

    --  construction (LEX, dans l'ordre du texte) ------------------------------------------------------------------
    procedure NEW_ELT	( KIND :ELT_KIND; MNEMO :LEX.SLICE );						--| estampille scope + garde lazy
    procedure ADD_OP	( TAG :OPERAND_TAG; TXT :LEX.SLICE;
			  IVAL :LONG_INTEGER := 0; FVAL :LONG_FLOAT := 0.0 );
    procedure SET_LAZY	( GUARD :LEX.SLICE );
    procedure CLEAR_LAZY;
    procedure DEFER_LAST;										--| STR/CST : enregistrement LIFO

    --  acces (P1, P2, P3, temoins) --------------------------------------------------------------------------------
    function  ELT_COUNT					return NATURAL;
    function  DEFER_COUNT					return NATURAL;
    function  DEFER_AT	( I :NATURAL )			return ELT_ID;
    function  KIND_OF	( E :ELT_ID )			return ELT_KIND;
    function  MNEMO_OF	( E :ELT_ID )			return LEX.SLICE;
    function  SCOPE_OF	( E :ELT_ID )			return SYMBOLS.SCOPE_ID;
    function  LAZY_OF	( E :ELT_ID )			return LEX.SLICE;
    function  N_OPS		( E :ELT_ID )			return NATURAL;
    function  OP_TAG	( E :ELT_ID; I :NATURAL )		return OPERAND_TAG;
    function  OP_TXT	( E :ELT_ID; I :NATURAL )		return LEX.SLICE;
    function  OP_INT	( E :ELT_ID; I :NATURAL )		return LONG_INTEGER;
    function  OP_FLT	( E :ELT_ID; I :NATURAL )		return LONG_FLOAT;

	--
  end	IR;
	--

			------
  package			PASSES
  is			------

    --| P1 : remplace le lazy fasmg (postpone + ~definite, qui exigeait le
    --| multi-passes). Point fixe sur les marques : les CALL/LSPA des
    --| elements ACTIFS posent PREFIX.SUBNAME_ ; un element est actif si sa
    --| garde lazy, evaluee DANS SON SCOPE estampille (lecon TC-02f), est
    --| definie. Ensemble fini croissant : terminaison garantie.
    --| P2 : layout, miroir n 110 (troisieme implementation). Regles :
    --| PRMzone base 8 (dq par PRM, prm_siz = $-8) ; VARzone base 8 a l'ELB
    --| (align par caractere b/w/d/q, taille litterale = octets + align_q,
    --| USEINFO reserve nom__u, loc_siz aligne q a endPRO) ; virtual at N +
    --| STATOFS (algn OCTETS 1/2/4/8, repli par taille si 0, reservation
    --| rb = octets), zones empilables. ELB declare elab, endPRO declare
    --| post (labels internes aux macros codi). Q7 : VARzone en modele PILE
    --| par frame — oracle DEBUG_LLIR (show loc_siz) pour trancher.
    --| Adresses et tailles d'instructions : TC-04 (EMITS.SIZE_OF).

    PASS_FAULT		: exception;								--| refus bruyant (doctrine R6)

    function  ACTIVE	( E :IR.ELT_ID )		return BOOLEAN;					--| garde lazy evaluee dans le scope de E
    procedure P1_REACH;
    procedure P2_LAYOUT	( FROM, TO :IR.ELT_ID );							--| par plage : rejouable (les labels de macro
												--| elab/post ne sont pas redefinissables)

	------
  end	PASSES;
	------


			-----
  package			EMITS
  is			-----

    --| Deux services par macro LLIR : SIZE_OF (P2B) et ENCODE (P3).
    --| CONTRAT : SIZE_OF ne depend JAMAIS d'une adresse non encore posee
    --| (formes canoniques — NOTE v1 par 2.5) ; P3 verifie octets emis =
    --| SIZE_OF a chaque element (refus bruyant sinon).
    --| Tranche TC-04, x86-64 seul : DROP DUP LI ADD SUB MUL BRA SYS_EXIT,
    --| en-tete ELF64 + Phdr, amorcage 82 octets, ASM_SIZE, ecriture du
    --| binaire (SEQUENTIAL_IO(CHARACTER)). Hors tranche : refus bruyant.
    --| Differes STR/CST (LIFO) : TC-05. Retarget (TRAITS par cible,
    --| ENCODE_ARM64 / ENCODE_RISCV64 a specification identique) :
    --| reintroduit une fois la table x86 complete.

    EMIT_FAULT		: exception;								--| refus bruyant (doctrine R6)

    procedure P2B_ADDRESSES	( FROM, TO :IR.ELT_ID );							--| adresses des elements ACTIFS de la plage ;
												--| labels poses ; ASM_SIZE ; assert < 2**32
    procedure P3_EMIT	( FROM, TO :IR.ELT_ID; BIN_NAME :STRING );					--| ELF + amorcage + code ; ecrit le binaire
    function  ASM_SIZE						return SYMBOLS.VALUE_TYPE;

    function  BIN_CAPACITY				return NATURAL;				--| jauge : borne du tampon binaire

	-----
  end	EMITS;
	-----


  --|  Conventions de nommage par cible. CODI_NAME : suffixe de l'include
  --|  codi que le .fas DOIT porter (controle croise dans LEX : la cible
  --|  choisie au lancement et celle declaree par le .fas ne divergent
  --|  jamais en silence). FAS_EXT / EXE_EXT : extensions du source et du
  --|  binaire (.fas x86 historique, .arm64fas, .riscv64fas).

			---------
  function		CODI_NAME				return STRING
  is			---------
  begin
    case  TARGET_CPU  is
      when X86_64  => return "x86_64.finc";
      when ARM64   => return "arm64.finc";
      when RISCV64 => return "riscv64.finc";
    end case;
  end	CODI_NAME;
	---------

			-------
  function		FAS_EXT					return STRING
  is			-------
  begin
    case  TARGET_CPU  is
      when X86_64  => return ".fas";
      when ARM64   => return ".arm64fas";
      when RISCV64 => return ".riscv64fas";
    end case;
  end	FAS_EXT;
	-------

			-------
  function		EXE_EXT					return STRING
  is			-------
  begin
    case  TARGET_CPU  is
      when X86_64  => return ".x86exe";
      when ARM64   => return ".arm64exe";
      when RISCV64 => return ".riscv64exe";
    end case;
  end	EXE_EXT;
	-------


  package body		LEX		is separate;						--| target_code-lex.adb
  package body		SYMBOLS		is separate;						--| target_code-symbols.adb
  package body		IR		is separate;						--| target_code-ir.adb
  package body		PASSES		is separate;						--| target_code-passes.adb
  package body		EMITS		is separate;						--| target_code-emits.adb (+ encode_* en sous-unites)


  --			P I L O T E

begin
  declare
    TAMPON	: STRING( 1 .. 32 );
    LONGUEUR	: NATURAL;
    package CPU_KIND_IO	is new ENUMERATION_IO( CPU_KIND );
    CPU_TYPE_OK		: BOOLEAN		:= FALSE;
  begin
    loop
      begin
        PUT( "ASSEMBLAGE POUR : (X86_64, ARM64, RISCV64) (simple ret X86_64) : " );
        GET_LINE( TAMPON, LONGUEUR );
        if  LONGUEUR = 0  then
	TARGET_CPU := X86_64;
	exit;
        end if;
        CPU_KIND_IO.GET( TAMPON( 1 .. LONGUEUR ), TARGET_CPU, LONGUEUR );
        CPU_TYPE_OK := TRUE;
      exception
        when DATA_ERROR => CPU_TYPE_OK := FALSE;		--| retry
      end;
      exit when CPU_TYPE_OK;
    end loop;
  end;

  PUT( "NOM FICHIER .fas (sans extension, simple ret faire les tests) : " );
  declare
    TAMPON	: STRING( 1 .. 255 );
    LONGUEUR	: NATURAL;
    F		: FILE_TYPE;

  begin
    GET_LINE( TAMPON, LONGUEUR );
    if  LONGUEUR /= 0  then
      LEX.RUN_P0( TAMPON( 1 .. LONGUEUR ) & FAS_EXT );
      PASSES.P1_REACH;
      PASSES.P2_LAYOUT( 1, IR.ELT_ID( IR.ELT_COUNT ) );
      EMITS.P2B_ADDRESSES( 1, IR.ELT_ID( IR.ELT_COUNT ) );
      EMITS.P3_EMIT( 1, IR.ELT_ID( IR.ELT_COUNT ), TAMPON( 1 .. LONGUEUR ) & EXE_EXT );

      PUT_LINE( "CARTO capacites :" );
      PUT_LINE( "  elements " & NATURAL'IMAGE( IR.ELT_COUNT )
		& " /" & INTEGER'IMAGE( IR.ELT_MAX )
		& "   differes" & NATURAL'IMAGE( IR.DEFER_COUNT )
		& " /" & INTEGER'IMAGE( IR.DEFER_MAX ) );
      PUT_LINE( "  texte    " & NATURAL'IMAGE( LEX.TEXT_USED )
		& " /" & INTEGER'IMAGE( LEX.TEXT_MAX ) );
      PUT_LINE( "  symboles " & NATURAL'IMAGE( SYMBOLS.SYM_COUNT )
		& " /" & INTEGER'IMAGE( SYMBOLS.SYM_MAX )
		& "   scopes" & NATURAL'IMAGE( SYMBOLS.SCOPE_COUNT )
		& " /" & INTEGER'IMAGE( SYMBOLS.SCOPE_MAX ) );
      PUT_LINE( "  pool     " & NATURAL'IMAGE( SYMBOLS.POOL_USED )
		& " /" & NATURAL'IMAGE( SYMBOLS.POOL_CAPACITY ) );
      PUT_LINE( "  octets   " & SYMBOLS.VALUE_TYPE'IMAGE( EMITS.ASM_SIZE )
		& " /" & NATURAL'IMAGE( EMITS.BIN_CAPACITY ) );

      return;
    end if;
  end;

			---------------
			-- T E S T S --
			---------------

  TARGET_CPU := X86_64;										--| les temoins TC_TEST04..25 ecrivent "include codi_x86_64"

  --  P0 : LEX.OPEN_SOURCE( nom du .fas ) ; construire l'IR et les portees.
  --  P1 : SYMBOLS : fermeture d'atteignabilite depuis l'entree.
  --  P2 : layouts (PRMzone/VARzone/STATOFS), tailles via EMITS.SIZE_OF,
  --       adresses, placement LIFO des constantes, ASM_SIZE ;
  --       assert TRAITS.ORIG + ASM_SIZE < 2**32  (forme canonique d'adresse).
  --  P3 : EMITS.ENCODE sur les elements atteignables ; ecrire l'ELF ;
  --       MAP si GENERATE_BINARY_MAP.

  --|  TEMOIN TEMPORAIRE DE SYMBOLS — auto-jugeant (convention du filet :
  --|  "PASSE" attendu, toute ligne "ECHEC" est un verdict negatif).
  --|  A RETIRER quand LEX alimentera le pilote.
  declare
    use SYMBOLS;
    OK			: BOOLEAN	:= TRUE;
    SIZ			: VALUE_TYPE;

    procedure CHECK ( COND :BOOLEAN; MSG :STRING )
    is
    begin
      if not COND
      then
	OK := FALSE;
	PUT_LINE( "ECHEC symbols : " & MSG );
      end if;
    end CHECK;

  begin
    --  visibilite par remontee des parents
    DECLARE_SYM( "RACINE_A", PLAIN_VALUE, 1 );
    ENTER_SCOPE( "FRERE1" );
    DECLARE_SYM( "S1", CODE_LABEL );
    CHECK( TRY_RESOLVE( "RACINE_A" ) /= NO_SYM, "remontee des parents" );
    LEAVE_SCOPE;

    --  piege n 105 : JAMAIS les freres
    ENTER_SCOPE( "FRERE2" );
    CHECK( TRY_RESOLVE( "S1" ) = NO_SYM,         "contenu d'un frere invisible (piege n 105)" );
    CHECK( TRY_RESOLVE( "FRERE1.S1" ) /= NO_SYM, "acces pointe via remontee puis descente" );
    LEAVE_SCOPE;

    --  reouverture cumulative (namespace STANDARD dans chaque FINC)
    ENTER_SCOPE( "FRERE1" );
    DECLARE_SYM( "S2", CODE_LABEL );
    LEAVE_SCOPE;
    CHECK( TRY_RESOLVE( "FRERE1.S2" ) /= NO_SYM  and then
	   TRY_RESOLVE( "FRERE1.S1" ) /= NO_SYM, "reouverture cumulative" );

    --  layout VARzone : base 8, caractere b puis align q (regles par 2.2)
    OPEN_ZONE( 8 );
    DECLARE_SYM( "X_disp", FRAME_OFFSET, ZONE_POS );
    ZONE_RESERVE( 1 );
    ZONE_ALIGN( 8 );
    DECLARE_SYM( "Y_disp", FRAME_OFFSET, ZONE_POS );
    ZONE_RESERVE( 8 );
    ZONE_ALIGN( 8 );
    SIZ := CLOSE_ZONE;
    CHECK( VALUE_OF( RESOLVE( "X_disp" ) ) = 8   and then
	   VALUE_OF( RESOLVE( "Y_disp" ) ) = 16  and then
	   SIZ = 24,                                 "layout VARzone (8, 16, loc_siz 24)" );

    --  garde n 97 redefinissable ; label duplique = refus bruyant
    DECLARE_SYM( "GARDE", GUARD );
    DECLARE_SYM( "GARDE", GUARD );
    begin
      DECLARE_SYM( "RACINE_A", CODE_LABEL );
      CHECK( FALSE, "duplication de label non refusee" );
    exception
      when SYMBOL_FAULT =>
	null;								--| refus bruyant attendu
    end;

    --  atteignabilite
    MARK( "FRERE1", "SP" );
    CHECK( IS_DEFINED( "FRERE1.SP_" ), "marque d'atteignabilite" );
    CHECK( REACH_COUNT = 1,            "compteur de point fixe" );

    if OK
    then
      PUT_LINE( "PASSE symbols" );
    end if;
  end;


  declare
    use LEX, SYMBOLS, IR;
    OK			: BOOLEAN	:= TRUE;
    F			: FILE_TYPE;
    LAZY_SEEN		: NATURAL	:= 0;

    procedure CHECK ( COND :BOOLEAN; MSG :STRING )
    is
    begin
      if not COND
      then
	OK := FALSE;
	PUT_LINE( "ECHEC lex : " & MSG );
      end if;
    end CHECK;

  begin
    CREATE( F, OUT_FILE, "TC_TEST_INC.FINC" );
    PUT_LINE( F, "TC_INC = 'TC_INC'" );
    PUT_LINE( F, "namespace TC_PACK" );
    PUT_LINE( F, "lbl_inc:" );
    PUT_LINE( F, "	LI	42" );
    PUT_LINE( F, "end namespace" );
    CLOSE( F );

    CREATE( F, OUT_FILE, "TC_TEST.FAS" );
    PUT_LINE( F, "namespace STANDARD" );
    PUT_LINE( F, "GLOB = 'GLOB'" );
    PUT_LINE( F, "if ~ definite TC_INC" );
    PUT_LINE( F, "include 'TC_TEST_INC.FINC'" );
    PUT_LINE( F, "end if" );
    PUT_LINE( F, "if ~ definite TC_INC" );
    PUT_LINE( F, "include 'TC_TEST_INC.FINC'" );
    PUT_LINE( F, "end if" );
    PUT_LINE( F, "main:" );
    PUT_LINE( F, "	LIA	, , 16" );
    PUT_LINE( F, "	LIF	1.5" );
    PUT_LINE( F, "	PRO	SP1" );
    PUT_LINE( F, "ret_lbl:" );
    PUT_LINE( F, "	UNLINK" );
    PUT_LINE( F, "	RTD	0" );
    PUT_LINE( F, "	endPRO" );
    PUT_LINE( F, "if defined SP1_" );
    PUT_LINE( F, "	LI	7	; corps sous garde lazy" );
    PUT_LINE( F, "end if" );
    PUT_LINE( F, "	STR	msg, 'Bonjour'" );
    PUT_LINE( F, "end namespace" );
    CLOSE( F );

    RUN_P0( "TC_TEST.FAS" );

    CHECK( IR.ELT_COUNT = 12,   "nombre d'elements (inclusion unique)" );
    CHECK( IR.DEFER_COUNT = 1,  "STR enregistree en differe" );
    --| Les gardes n 97 vivent dans le namespace ou la tete du FINC
    --| s'execute (STANDARD) -- semantique fasmg ; le CHECK s'execute
    --| scope racine, donc interrogation QUALIFIEE.
    CHECK( IS_DEFINED( "STANDARD.TC_INC" ) and then IS_DEFINED( "STANDARD.GLOB" ),
	   "gardes n 97 declarees dans STANDARD" );
    CHECK( TRY_RESOLVE( "STANDARD.TC_PACK.lbl_inc" ) /= NO_SYM,
	   "label du fichier inclus, scope litteral" );
    CHECK( TRY_RESOLVE( "STANDARD.SP1.ret_lbl" ) /= NO_SYM,
	   "label dans le scope ouvert par PRO" );
    CHECK( CLASS_OF( RESOLVE( "STANDARD.msg" ) ) = SCOPE_NAME
	   and then TRY_RESOLVE( "STANDARD.msg.data_ptr" ) /= NO_SYM
	   and then TRY_RESOLVE( "STANDARD.msg.LST_1" ) /= NO_SYM,
	   "STR = namespace (data_ptr, statiques presents)" );
    CHECK( IR.N_OPS( 4 ) = 3
	   and then IR.OP_TAG( 4, 1 ) = IR.EMPTY_OP
	   and then IR.OP_TAG( 4, 2 ) = IR.EMPTY_OP
	   and then IR.OP_TAG( 4, 3 ) = IR.INT_OP
	   and then IR.OP_INT( 4, 3 ) = 16,
	   "LIA , , 16 : virgules conservees" );
    CHECK( IR.OP_TAG( 5, 1 ) = IR.FLT_OP,
	   "litteral flottant de LIF" );
     --| Variable intermediaire : la forme directe
    --| IR.LAZY_OF( IR.ELT_ID( E ) ).F plante l'expander (SM_DEFN absent
    --| sur le DN_SELECTED du nom d'appel etendu en prefixe de composant --
    --| temoin de bissection : selfun_test.adb). A simplifier quand le
    --| temoin passera en entier.
    declare
      SL		: LEX.SLICE;
    begin
      for E in 1 .. IR.ELT_COUNT
      loop
	SL := IR.LAZY_OF( IR.ELT_ID( E ) );
	if SL.F /= 0
	then
	  LAZY_SEEN := LAZY_SEEN + 1;
	end if;
      end loop;
      SL := IR.LAZY_OF( 11 );
      CHECK( LAZY_SEEN = 1
	     and then SL.F /= 0
	     and then IMAGE( SL ) = "SP1_",
	     "garde lazy enregistree, jamais evaluee a P0" );
    end;
    CHECK( EVAL( POOL_STRING( "8*(5-2)+6/3-1" ) ) = 25,
	   "evaluateur d'expressions" );

    if OK
    then
      PUT_LINE( "PASSE lex" );
    end if;
  end;


  --|  TEMOIN TEMPORAIRE DE PASSES (P1 + P2) — auto-jugeant. Genere un
  --|  troisieme source de test (noms M3* pour ne pas heurter les temoins
  --|  precedents, dont l'IR et les tables subsistent), le parse, puis
  --|  deroule P1 et P2. A RETIRER quand le pilote enchainera les phases.
  declare
    use LEX;
    use SYMBOLS;
    use IR;
    OK			: BOOLEAN	:= TRUE;
    F			: FILE_TYPE;

    procedure CHECK ( COND :BOOLEAN; MSG :STRING )
    is
    begin
      if not COND
      then
	OK := FALSE;
	PUT_LINE( "ECHEC passes : " & MSG );
      end if;
    end CHECK;

  begin
    CREATE( F, OUT_FILE, "TC_TEST3.FAS" );
    PUT_LINE( F, "namespace STANDARD" );
    PUT_LINE( F, "main3:" );
    PUT_LINE( F, "	CALL	STANDARD., M3SP1" );
    PUT_LINE( F, "if defined M3SP1_" );
    PUT_LINE( F, "	PRO	M3SP1" );
    PUT_LINE( F, "	PRMS" );
    PUT_LINE( F, "	PRM	X3_ofs" );
    PUT_LINE( F, "	PRM	Y3_ofs" );
    PUT_LINE( F, "	endPRMS" );
    PUT_LINE( F, "	ELB	1" );
    PUT_LINE( F, "	VAR	A3_disp, B" );
    PUT_LINE( F, "	VAR	B3_disp, Q, 2" );
    PUT_LINE( F, "	VAR	C3_disp, 24" );
    PUT_LINE( F, "	USEINFO	1, BUF3, LI 0" );
    PUT_LINE( F, "virtual at 0" );
    PUT_LINE( F, "	STATOFS	FA3, 1, 1" );
    PUT_LINE( F, "	STATOFS	FB3, 4, 4" );
    PUT_LINE( F, "	STATOFS	FC3, 8, 0" );
    PUT_LINE( F, "end virtual" );
    PUT_LINE( F, "	CALL	STANDARD., M3SP3" );
    PUT_LINE( F, "ret3:" );
    PUT_LINE( F, "	UNLINK" );
    PUT_LINE( F, "	RTD	0" );
    PUT_LINE( F, "	endPRO" );
    PUT_LINE( F, "end if" );
    PUT_LINE( F, "if defined M3SP2_" );
    PUT_LINE( F, "	PRO	M3SP2" );
    PUT_LINE( F, "	ELB	1" );
    PUT_LINE( F, "	VAR	Z3_disp, Q" );
    PUT_LINE( F, "	endPRO" );
    PUT_LINE( F, "end if" );
    PUT_LINE( F, "if defined M3SP3_" );
    PUT_LINE( F, "	PRO	M3SP3" );
    PUT_LINE( F, "	ELB	1" );
    PUT_LINE( F, "	endPRO" );
    PUT_LINE( F, "end if" );
    PUT_LINE( F, "end namespace" );
    CLOSE( F );

    declare
      FROM3		: constant IR.ELT_ID := IR.ELT_ID( IR.ELT_COUNT + 1 );
    begin
      RUN_P0( "TC_TEST3.FAS" );
      PASSES.P1_REACH;
      PASSES.P2_LAYOUT( FROM3, IR.ELT_ID( IR.ELT_COUNT ) );
    end;

    CHECK( REACH_COUNT = 3,
	   "point fixe : transitivite main3 -> M3SP1 -> M3SP3, M3SP2 mort" );
    CHECK( IS_DEFINED( "STANDARD.M3SP1_" )
	   and then IS_DEFINED( "STANDARD.M3SP3_" )
	   and then not IS_DEFINED( "STANDARD.M3SP2_" ),
	   "marques posees dans STANDARD" );
    CHECK( not PASSES.ACTIVE( 11 ),
	   "garde lazy du temoin lex toujours inactive" );
    CHECK( VALUE_OF( RESOLVE( "STANDARD.M3SP1.X3_ofs" ) ) = 8
	   and then VALUE_OF( RESOLVE( "STANDARD.M3SP1.Y3_ofs" ) ) = 16
	   and then VALUE_OF( RESOLVE( "STANDARD.M3SP1.prm_siz" ) ) = 16,
	   "PRMzone (8, 16 ; prm_siz 16)" );
    CHECK( VALUE_OF( RESOLVE( "STANDARD.M3SP1.A3_disp" ) ) = 8,
	   "A3_disp attendu 8, obtenu"
	   & LONG_INTEGER'IMAGE( VALUE_OF( RESOLVE( "STANDARD.M3SP1.A3_disp" ) ) ) );
    CHECK( VALUE_OF( RESOLVE( "STANDARD.M3SP1.B3_disp" ) ) = 16,
	   "B3_disp attendu 16, obtenu"
	   & LONG_INTEGER'IMAGE( VALUE_OF( RESOLVE( "STANDARD.M3SP1.B3_disp" ) ) ) );
    CHECK( VALUE_OF( RESOLVE( "STANDARD.M3SP1.C3_disp" ) ) = 32,
	   "C3_disp attendu 32, obtenu"
	   & LONG_INTEGER'IMAGE( VALUE_OF( RESOLVE( "STANDARD.M3SP1.C3_disp" ) ) ) );
    CHECK( VALUE_OF( RESOLVE( "STANDARD.M3SP1.BUF3__u" ) ) = 56,
	   "BUF3__u attendu 56, obtenu"
	   & LONG_INTEGER'IMAGE( VALUE_OF( RESOLVE( "STANDARD.M3SP1.BUF3__u" ) ) ) );
    CHECK( VALUE_OF( RESOLVE( "STANDARD.M3SP1.loc_siz" ) ) = 64,
	   "loc_siz attendu 64, obtenu"
	   & LONG_INTEGER'IMAGE( VALUE_OF( RESOLVE( "STANDARD.M3SP1.loc_siz" ) ) ) );
    CHECK( VALUE_OF( RESOLVE( "STANDARD.M3SP1.FA3" ) ) = 0
	   and then VALUE_OF( RESOLVE( "STANDARD.M3SP1.FB3" ) ) = 4
	   and then VALUE_OF( RESOLVE( "STANDARD.M3SP1.FC3" ) ) = 8,
	   "STATOFS (algn1:0, algn4:4, repli siz8:8)" );
    CHECK( TRY_RESOLVE( "STANDARD.M3SP2.Z3_disp" ) = NO_SYM,
	   "corps mort : aucun layout" );
    CHECK( TRY_RESOLVE( "STANDARD.M3SP1.elab" ) /= NO_SYM
	   and then TRY_RESOLVE( "STANDARD.M3SP1.post" ) /= NO_SYM,
	   "labels elab / post declares par P2" );
    CHECK( VALUE_OF( RESOLVE( "STANDARD.M3SP3.loc_siz" ) ) = 8,
	   "frame vide : loc_siz 8" );

    if OK
    then
      PUT_LINE( "PASSE passes" );
    end if;
  end;


  --|  TEMOIN TEMPORAIRE DE EMITS (P2B + P3) — auto-jugeant en interne,
  --|  byte-diff contre fasmg en externe (le MEME TC_TEST4.FAS s'assemble
  --|  des deux cotes : fasmg lit l'include codi, TARGET_CODE le saute).
  --|  A RETIRER quand le pilote enchainera les phases.
  declare
    use LEX, SYMBOLS, IR;
    OK			: BOOLEAN	:= TRUE;
    F			: FILE_TYPE;
    FROM4			: IR.ELT_ID;

    procedure CHECK ( COND :BOOLEAN; MSG :STRING )
    is
    begin
      if not COND
      then
	OK := FALSE;
	PUT_LINE( "ECHEC emits : " & MSG );
      end if;
    end CHECK;

  begin
    CREATE( F, OUT_FILE, "TC_TEST4.FAS" );
    PUT_LINE( F, "include '../../src/expander/fasmg/codi_x86_64.finc'" );
    PUT_LINE( F, "namespace STANDARD" );
    PUT_LINE( F, "main4:" );
    PUT_LINE( F, "	LI	5" );
    PUT_LINE( F, "	LI	7" );
    PUT_LINE( F, "	ADD" );
    PUT_LINE( F, "	DUP" );
    PUT_LINE( F, "	DROP" );
    PUT_LINE( F, "	LI	3" );
    PUT_LINE( F, "	SUB" );
    PUT_LINE( F, "	BRA	fin4" );
    PUT_LINE( F, "	LI	99" );
    PUT_LINE( F, "fin4:" );
    PUT_LINE( F, "	DROP" );
    PUT_LINE( F, "	SYS_EXIT	0" );
    PUT_LINE( F, "end namespace" );
    CLOSE( F );

    FROM4 := IR.ELT_ID( IR.ELT_COUNT + 1 );
    RUN_P0( "TC_TEST4.FAS" );
    EMITS.P2B_ADDRESSES( FROM4, IR.ELT_ID( IR.ELT_COUNT ) );
    EMITS.P3_EMIT( FROM4, IR.ELT_ID( IR.ELT_COUNT ), "TC_TEST4.BIN" );

    CHECK( EMITS.ASM_SIZE = 210,
	   "ASM_SIZE = 82 (amorcage) + 128 (code) = 210" );
    CHECK( VALUE_OF( RESOLVE( "STANDARD.fin4" ) ) = 16#400078# + 199,
	   "adresse de fin4 (apres 117 octets de code)" );
    CHECK( VALUE_OF( RESOLVE( "STANDARD.main4" ) ) = 16#400078# + 82,
	   "main4 au premier octet apres l'amorcage" );

    if  OK  then
      PUT_LINE( "PASSE emits" );
      PUT_LINE( "TC_TEST4.BIN ecrit - oracle externe :" );
      PUT_LINE( "  fasmg TC_TEST4.FAS TC_REF4 && cmp TC_REF4 TC_TEST4.BIN" );
      PUT_LINE( "  chmod +x TC_TEST4.BIN && ./TC_TEST4.BIN ; echo $?" );
    end if;
  end;


  --|  TEMOIN TC-ARM04 : jumeau arm64 de TC_TEST4 (meme programme, memes
  --|  mnemoniques, include codi_arm64). Auto-jugeant sur les tailles (LI 5 =
  --|  movz + PUSH_RAX = 12, ADD/SUB = 20, BRA = 4, SYS_EXIT 0 = 12, amorcage
  --|  92) ; oracle externe : fasmg + cmp sur le laptop, execution sur le Pi.
  --|  Le temoin pose SA cible et la rend a X86_64 en sortant (les temoins
  --|  suivants sont x86). Labels distincts de TC_TEST4 (meme namespace).

  TARGET_CPU := ARM64;										--| TEST ARM
  declare
    use LEX, SYMBOLS, IR;
    OK			: BOOLEAN	:= TRUE;
    F			: FILE_TYPE;
    FROMA		: IR.ELT_ID;

    procedure CHECK ( COND :BOOLEAN; MSG :STRING )
    is
    begin
      if not COND
      then
	OK := FALSE;
	PUT_LINE( "ECHEC arm04 : " & MSG );
      end if;
    end CHECK;

  begin
    CREATE( F, OUT_FILE, "TC_ARM04.FAS" );
    PUT_LINE( F, "include '../../src/expander/fasmg/codi_arm64.finc'" );
    PUT_LINE( F, "namespace STANDARD" );
    PUT_LINE( F, "main_a4:" );
    PUT_LINE( F, "	LI	5" );
    PUT_LINE( F, "	LI	7" );
    PUT_LINE( F, "	ADD" );
    PUT_LINE( F, "	DUP" );
    PUT_LINE( F, "	DROP" );
    PUT_LINE( F, "	LI	3" );
    PUT_LINE( F, "	SUB" );
    PUT_LINE( F, "	BRA	fin_a4" );
    PUT_LINE( F, "	LI	99" );
    PUT_LINE( F, "fin_a4:" );
    PUT_LINE( F, "	DROP" );
    PUT_LINE( F, "	SYS_EXIT	0" );
    PUT_LINE( F, "end namespace" );
    CLOSE( F );

    FROMA := IR.ELT_ID( IR.ELT_COUNT + 1 );
    RUN_P0( "TC_ARM04.FAS" );
    EMITS.P2B_ADDRESSES( FROMA, IR.ELT_ID( IR.ELT_COUNT ) );
    EMITS.P3_EMIT( FROMA, IR.ELT_ID( IR.ELT_COUNT ), "TC_ARM04.BIN" );

    CHECK( EMITS.ASM_SIZE = 216,
	   "ASM_SIZE = 92 (amorcage) + 124 (code) = 216" );
    CHECK( VALUE_OF( RESOLVE( "STANDARD.fin_a4" ) ) = 16#400078# + 200,
	   "adresse de fin_a4 (apres 108 octets de code)" );
    CHECK( VALUE_OF( RESOLVE( "STANDARD.main_a4" ) ) = 16#400078# + 92,
	   "main_a4 au premier octet apres l'amorcage" );

    if  OK  then
      PUT_LINE( "PASSE arm04" );
      PUT_LINE( "TC_ARM04.BIN ecrit - oracle externe :" );
      PUT_LINE( "  fasmg TC_ARM04.FAS TC_ARM_REF4 && cmp TC_ARM_REF4 TC_ARM04.BIN" );
      PUT_LINE( "  sur le Pi : chmod +x TC_ARM04.BIN && ./TC_ARM04.BIN ; echo $?   (attendu 0)" );
    end if;
  end;

  --|  TEMOIN TEMPORAIRE DES DIFFERES (TC-05) - LIFO, LCA, SYS_PUT_STR.
  --|  Sortie attendue du binaire : "okAH". A RETIRER avec les autres.
  TARGET_CPU := X86_64;										--| TEST X86
  declare
    use LEX, SYMBOLS, IR;
    OK			: BOOLEAN	:= TRUE;
    F			: FILE_TYPE;
    FROM5			: IR.ELT_ID;

    procedure CHECK ( COND :BOOLEAN; MSG :STRING )
    is
    begin
      if not COND
      then
	OK := FALSE;
	PUT_LINE( "ECHEC defer : " & MSG );
      end if;
    end CHECK;

  begin
    CREATE( F, OUT_FILE, "TC_TEST5.FAS" );
    PUT_LINE( F, "include '../../src/expander/fasmg/codi_x86_64.finc'" );
    PUT_LINE( F, "namespace STANDARD" );
    PUT_LINE( F, "main5:" );
    PUT_LINE( F, "	LCA	MSG5A.data_ptr" );
    PUT_LINE( F, "	SYS_PUT_STR" );
    PUT_LINE( F, "	LCA	MSG5B.data_ptr" );
    PUT_LINE( F, "	SYS_PUT_STR" );
    PUT_LINE( F, "	SYS_EXIT	0" );
    PUT_LINE( F, "STR	MSG5A, 'ok'" );
    PUT_LINE( F, "STR	MSG5B, 'AH'" );
    PUT_LINE( F, "	CST	K5, q, 123" );
    PUT_LINE( F, "end namespace" );
    CLOSE( F );

    FROM5 := IR.ELT_ID( IR.ELT_COUNT + 1 );
    RUN_P0( "TC_TEST5.FAS" );
    EMITS.P2B_ADDRESSES( FROM5, IR.ELT_ID( IR.ELT_COUNT ) );
    EMITS.P3_EMIT( FROM5, IR.ELT_ID( IR.ELT_COUNT ), "TC_TEST5.BIN" );

    --  LIFO (DIS_BONJOUR) : dernier enregistre = premier place.
    --  Ordre d'enregistrement : MSG5A, MSG5B, K5 -> placement K5,
    --  MSG5B, MSG5A ; donc K5 < MSG5B < MSG5A en adresses.
    CHECK( VALUE_OF( RESOLVE( "STANDARD.K5" ) )
	     < VALUE_OF( RESOLVE( "STANDARD.MSG5B.data_ptr" ) )
	   and then VALUE_OF( RESOLVE( "STANDARD.MSG5B.data_ptr" ) )
	     < VALUE_OF( RESOLVE( "STANDARD.MSG5A.data_ptr" ) ),
	   "placement LIFO des differes" );
    CHECK( VALUE_OF( RESOLVE( "STANDARD.MSG5A.data" ) )
	     = VALUE_OF( RESOLVE( "STANDARD.MSG5A.data_ptr" ) ) + 32,
	   "structure du bloc STR (data a +32)" );
    CHECK( VALUE_OF( RESOLVE( "STANDARD.MSG5A.SIZ" ) ) = 0
	   and then VALUE_OF( RESOLVE( "STANDARD.MSG5A.LST_1" ) ) = 12,
	   "statiques du STR (0/4/8/12)" );

    if OK
    then
      PUT_LINE( "PASSE defer" );
      PUT_LINE( "TC_TEST5.BIN ecrit - oracle externe :" );
      PUT_LINE( "  fasmg TC_TEST5.FAS TC_REF5 && cmp TC_REF5 TC_TEST5.BIN" );
      PUT_LINE( "  chmod +x TC_TEST5.BIN && ./TC_TEST5.BIN ; echo $?   (attendu : okAH puis 0)" );
    end if;
  end;



  --|  TEMOIN TC-ARM05 : jumeau arm64 de TC_TEST5 (differes LIFO, LCA,
  --|  SYS_PUT_STR). Les differes sont generiques depuis C0 : le temoin verifie
  --|  que le placement suit le code arm (LCA 16 + SYS_PUT_STR 44). Sortie
  --|  attendue du binaire sur le Pi : "okAH".

  TARGET_CPU := ARM64;
  declare
    use LEX, SYMBOLS, IR;
    OK			: BOOLEAN	:= TRUE;
    F			: FILE_TYPE;
    FROMA		: IR.ELT_ID;

    procedure CHECK ( COND :BOOLEAN; MSG :STRING )
    is
    begin
      if not COND
      then
	OK := FALSE;
	PUT_LINE( "ECHEC arm05 : " & MSG );
      end if;
    end CHECK;

  begin
    CREATE( F, OUT_FILE, "TC_ARM05.FAS" );
    PUT_LINE( F, "include '../../src/expander/fasmg/codi_arm64.finc'" );
    PUT_LINE( F, "namespace STANDARD" );
    PUT_LINE( F, "main_a5:" );
    PUT_LINE( F, "	LCA	MSGA5A.data_ptr" );
    PUT_LINE( F, "	SYS_PUT_STR" );
    PUT_LINE( F, "	LCA	MSGA5B.data_ptr" );
    PUT_LINE( F, "	SYS_PUT_STR" );
    PUT_LINE( F, "	SYS_EXIT	0" );
    PUT_LINE( F, "STR	MSGA5A, 'ok'" );
    PUT_LINE( F, "STR	MSGA5B, 'AH'" );
    PUT_LINE( F, "	CST	KA5, q, 123" );
    PUT_LINE( F, "end namespace" );
    CLOSE( F );

    FROMA := IR.ELT_ID( IR.ELT_COUNT + 1 );
    RUN_P0( "TC_ARM05.FAS" );
    EMITS.P2B_ADDRESSES( FROMA, IR.ELT_ID( IR.ELT_COUNT ) );
    EMITS.P3_EMIT( FROMA, IR.ELT_ID( IR.ELT_COUNT ), "TC_ARM05.BIN" );

    CHECK( VALUE_OF( RESOLVE( "STANDARD.KA5" ) )
	     < VALUE_OF( RESOLVE( "STANDARD.MSGA5B.data_ptr" ) )
	   and then VALUE_OF( RESOLVE( "STANDARD.MSGA5B.data_ptr" ) )
	     < VALUE_OF( RESOLVE( "STANDARD.MSGA5A.data_ptr" ) ),
	   "placement LIFO des differes" );
    CHECK( VALUE_OF( RESOLVE( "STANDARD.MSGA5A.data" ) )
	     = VALUE_OF( RESOLVE( "STANDARD.MSGA5A.data_ptr" ) ) + 32,
	   "structure du bloc STR (data a +32)" );
    CHECK( VALUE_OF( RESOLVE( "STANDARD.KA5" ) ) = 16#400078# + 92 + 132,
	   "KA5 (premier differe, LIFO) juste apres 132 octets de code : 2 x (16 + 44) + 12" );

    if  OK  then
      PUT_LINE( "PASSE arm05" );
      PUT_LINE( "TC_ARM05.BIN ecrit - oracle externe :" );
      PUT_LINE( "  fasmg TC_ARM05.FAS TC_ARM_REF5 && cmp TC_ARM_REF5 TC_ARM05.BIN" );
      PUT_LINE( "  sur le Pi : chmod +x TC_ARM05.BIN && ./TC_ARM05.BIN ; echo $?   (attendu : okAH puis 0)" );
    end if;
  end;



  --|  TEMOIN TEMPORAIRE FRAME (TC-06) - LINK/UNLINK, charges et
  --|  rangements avec selections disp0/8/32, CEQ/BT. Le BINAIRE rend le
  --|  verdict par code de sortie : 0 = tout bon, 1 = chemin octet,
  --|  2 = chemin qword. A RETIRER avec les autres.
  TARGET_CPU := X86_64;
  declare
    use LEX;
    use SYMBOLS;
    use IR;
    OK			: BOOLEAN	:= TRUE;
    F			: FILE_TYPE;
    FROM6		: IR.ELT_ID;

    procedure CHECK ( COND :BOOLEAN; MSG :STRING )
    is
    begin
      if not COND
      then
	OK := FALSE;
	PUT_LINE( "ECHEC frame : " & MSG );
      end if;
    end CHECK;

  begin
    CREATE( F, OUT_FILE, "TC_TEST6.FAS" );
    PUT_LINE( F, "include '../../src/expander/fasmg/codi_x86_64.finc'" );
    PUT_LINE( F, "namespace STANDARD" );
    PUT_LINE( F, "main6:" );
    PUT_LINE( F, "	LINK	1, 200" );
    PUT_LINE( F, "	LI	65" );
    PUT_LINE( F, "	SB	1, 130" );
    PUT_LINE( F, "	LB	1, 130" );
    PUT_LINE( F, "	LI	65" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	t6" );
    PUT_LINE( F, "	UNLINK	1" );
    PUT_LINE( F, "	SYS_EXIT	1" );
    PUT_LINE( F, "t6:" );
    PUT_LINE( F, "	LI	7" );
    PUT_LINE( F, "	SD	1, 8" );
    PUT_LINE( F, "	LI	5" );
    PUT_LINE( F, "	SD	1, 160" );
    PUT_LINE( F, "	LD	1, 8" );
    PUT_LINE( F, "	LD	1, 160" );
    PUT_LINE( F, "	ADD" );
    PUT_LINE( F, "	SA	1, 16" );
    PUT_LINE( F, "	LA	1, 16" );
    PUT_LINE( F, "	LVA	1, 16" );
    PUT_LINE( F, "	LQ	-1" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	ok6" );
    PUT_LINE( F, "	UNLINK	1" );
    PUT_LINE( F, "	SYS_EXIT	2" );
    PUT_LINE( F, "ok6:" );
    PUT_LINE( F, "	UNLINK	1" );
    PUT_LINE( F, "	SYS_EXIT	0" );
    PUT_LINE( F, "end namespace" );
    CLOSE( F );

    FROM6 := IR.ELT_ID( IR.ELT_COUNT + 1 );
    RUN_P0( "TC_TEST6.FAS" );
    EMITS.P2B_ADDRESSES( FROM6, IR.ELT_ID( IR.ELT_COUNT ) );
    EMITS.P3_EMIT( FROM6, IR.ELT_ID( IR.ELT_COUNT ), "TC_TEST6.BIN" );

    CHECK( EMITS.ASM_SIZE = 523,
	   "ASM_SIZE = 82 + 441 = 523, obtenu"
	   & LONG_INTEGER'IMAGE( EMITS.ASM_SIZE ) );
    CHECK( VALUE_OF( RESOLVE( "STANDARD.main6" ) ) = 16#400078# + 82,
	   "main6 au premier octet apres l'amorcage" );

    if OK
    then
      PUT_LINE( "PASSE frame" );
      PUT_LINE( "TC_TEST6.BIN ecrit - oracle externe :" );
      PUT_LINE( "  fasmg TC_TEST6.FAS TC_REF6 && cmp TC_REF6 TC_TEST6.BIN" );
      PUT_LINE( "  chmod +x TC_TEST6.BIN && ./TC_TEST6.BIN ; echo $?   (attendu : 0)" );
    end if;
  end;


  --|  TEMOIN TC-ARM06 : jumeau arm64 de TC_TEST6 (LINK/UNLINK, charges et
  --|  rangements a disp 8/16/130/160 - plages imm12 scalee -, LVA, LQ -1,
  --|  CEQ/BT). Le binaire rend le verdict par code de sortie sur le Pi.

  TARGET_CPU := ARM64;
  declare
    use LEX, SYMBOLS, IR;
    OK			: BOOLEAN	:= TRUE;
    F			: FILE_TYPE;
    FROMA		: IR.ELT_ID;

    procedure CHECK ( COND :BOOLEAN; MSG :STRING )
    is
    begin
      if not COND
      then
	OK := FALSE;
	PUT_LINE( "ECHEC arm06 : " & MSG );
      end if;
    end CHECK;

  begin
    CREATE( F, OUT_FILE, "TC_ARM06.FAS" );
    PUT_LINE( F, "include '../../src/expander/fasmg/codi_arm64.finc'" );
    PUT_LINE( F, "namespace STANDARD" );
    PUT_LINE( F, "main_a6:" );
    PUT_LINE( F, "	LINK	1, 200" );
    PUT_LINE( F, "	LI	65" );
    PUT_LINE( F, "	SB	1, 130" );
    PUT_LINE( F, "	LB	1, 130" );
    PUT_LINE( F, "	LI	65" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	t_a6" );
    PUT_LINE( F, "	UNLINK	1" );
    PUT_LINE( F, "	SYS_EXIT	1" );
    PUT_LINE( F, "t_a6:" );
    PUT_LINE( F, "	LI	7" );
    PUT_LINE( F, "	SD	1, 8" );
    PUT_LINE( F, "	LI	5" );
    PUT_LINE( F, "	SD	1, 160" );
    PUT_LINE( F, "	LD	1, 8" );
    PUT_LINE( F, "	LD	1, 160" );
    PUT_LINE( F, "	ADD" );
    PUT_LINE( F, "	SA	1, 16" );
    PUT_LINE( F, "	LA	1, 16" );
    PUT_LINE( F, "	LVA	1, 16" );
    PUT_LINE( F, "	LQ	-1" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	ok_a6" );
    PUT_LINE( F, "	UNLINK	1" );
    PUT_LINE( F, "	SYS_EXIT	2" );
    PUT_LINE( F, "ok_a6:" );
    PUT_LINE( F, "	UNLINK	1" );
    PUT_LINE( F, "	SYS_EXIT	0" );
    PUT_LINE( F, "end namespace" );
    CLOSE( F );

    FROMA := IR.ELT_ID( IR.ELT_COUNT + 1 );
    RUN_P0( "TC_ARM06.FAS" );
    EMITS.P2B_ADDRESSES( FROMA, IR.ELT_ID( IR.ELT_COUNT ) );
    EMITS.P3_EMIT( FROMA, IR.ELT_ID( IR.ELT_COUNT ), "TC_ARM06.BIN" );

    CHECK( EMITS.ASM_SIZE = 532,
	   "ASM_SIZE = 92 + 440 = 532, obtenu"
	   & LONG_INTEGER'IMAGE( EMITS.ASM_SIZE ) );
    CHECK( VALUE_OF( RESOLVE( "STANDARD.main_a6" ) ) = 16#400078# + 92,
	   "main_a6 au premier octet apres l'amorcage" );
    CHECK( VALUE_OF( RESOLVE( "STANDARD.t_a6" ) ) = 16#400078# + 92 + 160,
	   "t_a6 : LINK 32, LI 12, SB 16, LB 16, LI 12, CEQ 24, BT 16, UNLINK 20, SYS_EXIT 12" );
    CHECK( VALUE_OF( RESOLVE( "STANDARD.ok_a6" ) ) = 16#400078# + 92 + 160 + 248,
	   "ok_a6 : 248 octets de t_a6 a ok_a6" );

    if  OK  then
      PUT_LINE( "PASSE arm06" );
      PUT_LINE( "TC_ARM06.BIN ecrit - oracle externe :" );
      PUT_LINE( "  fasmg TC_ARM06.FAS TC_ARM_REF6 && cmp TC_ARM_REF6 TC_ARM06.BIN" );
      PUT_LINE( "  sur le Pi : chmod +x TC_ARM06.BIN && ./TC_ARM06.BIN ; echo $?   (attendu : 0 ; 1 = chemin octet, 2 = chemin qword)" );
    end if;
  end;


  --|  TEMOIN TEMPORAIRE APPEL (TC-07) - CALL vers .elab (lazy reel des
  --|  deux cotes : multipasse fasmg / atteignabilite P1), PRO/ELB/endPRO,
  --|  RTD, ecriture inter-frames par le display. Verdict du binaire :
  --|  0 = 42 revenu dans la frame de main, 1 = non. A RETIRER.

  TARGET_CPU := X86_64;
  declare
    use LEX;
    use SYMBOLS;
    use IR;
    OK			: BOOLEAN	:= TRUE;
    F			: FILE_TYPE;
    FROM7		: IR.ELT_ID;

    procedure CHECK ( COND :BOOLEAN; MSG :STRING )
    is
    begin
      if not COND
      then
	OK := FALSE;
	PUT_LINE( "ECHEC call : " & MSG );
      end if;
    end CHECK;

  begin
    CREATE( F, OUT_FILE, "TC_TEST7.FAS" );
    PUT_LINE( F, "include '../../src/expander/fasmg/codi_x86_64.finc'" );
    PUT_LINE( F, "STANDARD = 'STANDARD'" );
    PUT_LINE( F, "namespace STANDARD" );
    PUT_LINE( F, "main7:" );
    PUT_LINE( F, "	LINK	1, 32" );
    PUT_LINE( F, "	CALL	STANDARD., SP7" );
    PUT_LINE( F, "	LD	1, 8" );
    PUT_LINE( F, "	LI	42" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	ok7" );
    PUT_LINE( F, "	UNLINK	1" );
    PUT_LINE( F, "	SYS_EXIT	1" );
    PUT_LINE( F, "ok7:" );
    PUT_LINE( F, "	UNLINK	1" );
    PUT_LINE( F, "	SYS_EXIT	0" );
    PUT_LINE( F, "if defined SP7_" );
    PUT_LINE( F, "	PRO	SP7" );
    PUT_LINE( F, "	ELB	2" );
    PUT_LINE( F, "	VAR	T7_disp, Q" );
    PUT_LINE( F, "	LI	6" );
    PUT_LINE( F, "	LI	7" );
    PUT_LINE( F, "	MUL" );
    PUT_LINE( F, "	SQ	2, T7_disp" );
    PUT_LINE( F, "	LQ	2, T7_disp" );
    PUT_LINE( F, "	SD	1, 8" );
    PUT_LINE( F, "	UNLINK	2" );
    PUT_LINE( F, "	RTD	0" );
    PUT_LINE( F, "	endPRO" );
    PUT_LINE( F, "end if" );
    PUT_LINE( F, "end namespace" );
    CLOSE( F );

    FROM7 := IR.ELT_ID( IR.ELT_COUNT + 1 );
    RUN_P0( "TC_TEST7.FAS" );
    PASSES.P1_REACH;
    PASSES.P2_LAYOUT( FROM7, IR.ELT_ID( IR.ELT_COUNT ) );
    EMITS.P2B_ADDRESSES( FROM7, IR.ELT_ID( IR.ELT_COUNT ) );
    EMITS.P3_EMIT( FROM7, IR.ELT_ID( IR.ELT_COUNT ), "TC_TEST7.BIN" );

    CHECK( EMITS.ASM_SIZE = 403,
	   "ASM_SIZE = 82 + 321 = 403, obtenu"
	   & LONG_INTEGER'IMAGE( EMITS.ASM_SIZE ) );
    CHECK( VALUE_OF( RESOLVE( "STANDARD.SP7.elab" ) ) = 16#400078# + 245,
	   "elab de SP7 (apres main + BRA de PRO)" );
    CHECK( VALUE_OF( RESOLVE( "STANDARD.SP7.post" ) ) = 16#400078# + 403,
	   "post de SP7 en fin de corps" );

    if OK
    then
      PUT_LINE( "PASSE call" );
      PUT_LINE( "TC_TEST7.BIN ecrit - oracle externe :" );
      PUT_LINE( "  fasmg TC_TEST7.FAS TC_REF7 && cmp TC_REF7 TC_TEST7.BIN" );
      PUT_LINE( "  chmod +x TC_TEST7.BIN && ./TC_TEST7.BIN ; echo $?   (attendu : 0)" );
    end if;
  end;



  --|  TEMOIN TC-ARM07 : jumeau arm64 de TC_TEST7 (CALL vers .elab lazy,
  --|  PRO/ELB/endPRO, RTD, micro-pile de retours par sp, ecriture
  --|  inter-frames par le display). Verdict du binaire : 0 = 42 revenu.

  TARGET_CPU := ARM64;
  declare
    use LEX, SYMBOLS, IR;
    OK			: BOOLEAN	:= TRUE;
    F			: FILE_TYPE;
    FROMA		: IR.ELT_ID;

    procedure CHECK ( COND :BOOLEAN; MSG :STRING )
    is
    begin
      if not COND
      then
	OK := FALSE;
	PUT_LINE( "ECHEC arm07 : " & MSG );
      end if;
    end CHECK;

  begin
    CREATE( F, OUT_FILE, "TC_ARM07.FAS" );
    PUT_LINE( F, "include '../../src/expander/fasmg/codi_arm64.finc'" );
    PUT_LINE( F, "STANDARD = 'STANDARD'" );
    PUT_LINE( F, "namespace STANDARD" );
    PUT_LINE( F, "main_a7:" );
    PUT_LINE( F, "	LINK	1, 32" );
    PUT_LINE( F, "	CALL	STANDARD., SPA7" );
    PUT_LINE( F, "	LD	1, 8" );
    PUT_LINE( F, "	LI	42" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	ok_a7" );
    PUT_LINE( F, "	UNLINK	1" );
    PUT_LINE( F, "	SYS_EXIT	1" );
    PUT_LINE( F, "ok_a7:" );
    PUT_LINE( F, "	UNLINK	1" );
    PUT_LINE( F, "	SYS_EXIT	0" );
    PUT_LINE( F, "if defined SPA7_" );
    PUT_LINE( F, "	PRO	SPA7" );
    PUT_LINE( F, "	ELB	2" );
    PUT_LINE( F, "	VAR	TA7_disp, Q" );
    PUT_LINE( F, "	LI	6" );
    PUT_LINE( F, "	LI	7" );
    PUT_LINE( F, "	MUL" );
    PUT_LINE( F, "	SQ	2, TA7_disp" );
    PUT_LINE( F, "	LQ	2, TA7_disp" );
    PUT_LINE( F, "	SD	1, 8" );
    PUT_LINE( F, "	UNLINK	2" );
    PUT_LINE( F, "	RTD	0" );
    PUT_LINE( F, "	endPRO" );
    PUT_LINE( F, "end if" );
    PUT_LINE( F, "end namespace" );
    CLOSE( F );

    FROMA := IR.ELT_ID( IR.ELT_COUNT + 1 );
    RUN_P0( "TC_ARM07.FAS" );
    PASSES.P1_REACH;											--| lazy : active le bloc "if defined SPA7_" (CALL)
    PASSES.P2_LAYOUT( FROMA, IR.ELT_ID( IR.ELT_COUNT ) );							--| VAR, loc_siz
    EMITS.P2B_ADDRESSES( FROMA, IR.ELT_ID( IR.ELT_COUNT ) );
    EMITS.P3_EMIT( FROMA, IR.ELT_ID( IR.ELT_COUNT ), "TC_ARM07.BIN" );

    CHECK( EMITS.ASM_SIZE = 432,
	   "ASM_SIZE = 92 + 180 (main) + 160 (SPA7) = 432, obtenu"
	   & LONG_INTEGER'IMAGE( EMITS.ASM_SIZE ) );
    CHECK( VALUE_OF( RESOLVE( "STANDARD.SPA7.elab" ) ) = 16#400078# + 92 + 180 + 4,
	   "SPA7.elab apres main (180) et le BRA post (4)" );
    CHECK( VALUE_OF( RESOLVE( "STANDARD.SPA7.post" ) ) = 16#400078# + 432,
	   "SPA7.post = fin du code" );

    if  OK  then
      PUT_LINE( "PASSE arm07" );
      PUT_LINE( "TC_ARM07.BIN ecrit - oracle externe :" );
      PUT_LINE( "  fasmg TC_ARM07.FAS TC_ARM_REF7 && cmp TC_ARM_REF7 TC_ARM07.BIN" );
      PUT_LINE( "  sur le Pi : chmod +x TC_ARM07.BIN && ./TC_ARM07.BIN ; echo $?   (attendu : 0)" );
    end if;
  end;


  --|  TEMOIN TEMPORAIRE TETE/QUEUE (TC-08) - frame de NIVEAU 0 : tete
  --|  canonique (VARzone:: dans virtual at 8, LINK 0 retropropage,
  --|  VAR de niveau 0) et queue (virtual VARzone / loc_siz = $ SANS
  --|  align_q), coexistence avec un sous-programme imbrique (modele
  --|  pile, mini-Q7). Tete et queue TEXTUELLEMENT identiques a celles
  --|  de l'expander (CREATE_FAS_MAIN_FILE). Verdict du binaire :
  --|  0 = 42 relu au niveau 0 apres ecriture par SP8 via le display,
  --|  1 = non. A RETIRER avec les autres.

  TARGET_CPU := X86_64;
  declare
    use LEX;
    use SYMBOLS;
    use IR;
    OK			: BOOLEAN	:= TRUE;
    F			: FILE_TYPE;
    FROM8		: IR.ELT_ID;

    procedure CHECK ( COND :BOOLEAN; MSG :STRING )
    is
    begin
      if not COND
      then
	OK := FALSE;
	PUT_LINE( "ECHEC niveau0 : " & MSG );
      end if;
    end CHECK;

  begin
    CREATE( F, OUT_FILE, "TC_TEST8.FAS" );
    PUT_LINE( F, "	include '../../src/expander/fasmg/codi_x86_64.finc'" );
    PUT_LINE( F, "STANDARD = 'STANDARD'" );
    PUT_LINE( F, "namespace STANDARD" );
    PUT_LINE( F, "  virtual at 8" );
    PUT_LINE( F, "    VARzone::" );
    PUT_LINE( F, "  end virtual" );
    PUT_LINE( F, "	LINK	0, loc_siz" );
    PUT_LINE( F, "	VAR	G8_disp, Q" );
    PUT_LINE( F, "	VAR	B8_disp, B, 3" );
    PUT_LINE( F, "	LI	41" );
    PUT_LINE( F, "	SQ	0, G8_disp" );
    PUT_LINE( F, "	CALL	STANDARD., SP8" );
    PUT_LINE( F, "	LQ	0, G8_disp" );
    PUT_LINE( F, "	LI	42" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	ok8" );
    PUT_LINE( F, "	SYS_EXIT	1" );
    PUT_LINE( F, "ok8:" );
    PUT_LINE( F, "	SYS_EXIT	0" );
    PUT_LINE( F, "if defined SP8_" );
    PUT_LINE( F, "	PRO	SP8" );
    PUT_LINE( F, "	ELB	1" );
    PUT_LINE( F, "	VAR	T8_disp, Q" );
    PUT_LINE( F, "	LQ	0, G8_disp" );
    PUT_LINE( F, "	LI	1" );
    PUT_LINE( F, "	ADD" );
    PUT_LINE( F, "	SQ	1, T8_disp" );
    PUT_LINE( F, "	LQ	1, T8_disp" );
    PUT_LINE( F, "	SQ	0, G8_disp" );
    PUT_LINE( F, "	UNLINK	1" );
    PUT_LINE( F, "	RTD	0" );
    PUT_LINE( F, "	endPRO" );
    PUT_LINE( F, "end if" );
    PUT_LINE( F, " virtual VARzone" );
    PUT_LINE( F, "   loc_siz = $" );
    PUT_LINE( F, "  end virtual" );
    PUT_LINE( F, "end namespace" );
    CLOSE( F );

    FROM8 := IR.ELT_ID( IR.ELT_COUNT + 1 );
    RUN_P0( "TC_TEST8.FAS" );
    PASSES.P1_REACH;
    PASSES.P2_LAYOUT( FROM8, IR.ELT_ID( IR.ELT_COUNT ) );
    EMITS.P2B_ADDRESSES( FROM8, IR.ELT_ID( IR.ELT_COUNT ) );
    EMITS.P3_EMIT( FROM8, IR.ELT_ID( IR.ELT_COUNT ), "TC_TEST8.BIN" );

    CHECK( VALUE_OF( RESOLVE( "STANDARD.G8_disp" ) ) = 8
	   and then VALUE_OF( RESOLVE( "STANDARD.B8_disp" ) ) = 16,
	   "VAR de niveau 0 dans le frame 0 (8, 16)" );
    CHECK( VALUE_OF( RESOLVE( "STANDARD.loc_siz" ) ) = 19,
	   "loc_siz de niveau 0 NON aligne (attendu 19), obtenu"
	   & LONG_INTEGER'IMAGE( VALUE_OF( RESOLVE( "STANDARD.loc_siz" ) ) ) );
    CHECK( VALUE_OF( RESOLVE( "STANDARD.SP8.T8_disp" ) ) = 8
	   and then VALUE_OF( RESOLVE( "STANDARD.SP8.loc_siz" ) ) = 16,
	   "frame imbrique intact (pile : T8 8, loc_siz 16)" );

    if OK
    then
      PUT_LINE( "PASSE niveau0" );
      PUT_LINE( "TC_TEST8.BIN ecrit - oracle externe :" );
      PUT_LINE( "  fasmg TC_TEST8.FAS TC_REF8 && cmp TC_REF8 TC_TEST8.BIN" );
      PUT_LINE( "  chmod +x TC_TEST8.BIN && ./TC_TEST8.BIN ; echo $?   (attendu : 0)" );
    end if;
  end;


  --|  TEMOIN TEMPORAIRE EXCEPTIONS (TC-09) - EXC_MACH 0 (photo du
  --|  contexte-sentinelle, motif exact de la tete reelle : EXC_MACH,
  --|  LCA dispatch, Sa ctx+8, LVA, Sa top), puis levee depuis un frame
  --|  imbrique : BRA vers l'instance unique EXC_RAISE (region apres
  --|  SYS_EXIT, comme le .fas reel), deroulage, dispatch sur h9_,
  --|  verification que l'etat de niveau 0 est restaure (G9 = 7 relu
  --|  sur la pile restauree). Verdict : 0 = deroulage et dispatch
  --|  corrects ; 1 = G9 faux apres deroulage ; 2 = EXC_RAISE n'a pas
  --|  detourne le flot. A RETIRER avec les autres.
  TARGET_CPU := X86_64;
  declare
    use LEX;
    use SYMBOLS;
    use IR;
    OK			: BOOLEAN	:= TRUE;
    F			: FILE_TYPE;
    FROM9		: IR.ELT_ID;

    procedure CHECK ( COND :BOOLEAN; MSG :STRING )
    is
    begin
      if not COND
      then
	OK := FALSE;
	PUT_LINE( "ECHEC exc : " & MSG );
      end if;
    end CHECK;

  begin
    CREATE( F, OUT_FILE, "TC_TEST9.FAS" );
    PUT_LINE( F, "	include '../../src/expander/fasmg/codi_x86_64.finc'" );
    PUT_LINE( F, "STANDARD = 'STANDARD'" );
    PUT_LINE( F, "namespace STANDARD" );
    PUT_LINE( F, "  virtual at 8" );
    PUT_LINE( F, "    VARzone::" );
    PUT_LINE( F, "  end virtual" );
    PUT_LINE( F, "	LINK	0, loc_siz" );
    PUT_LINE( F, "	VAR	CTX9_disp, 64" );
    PUT_LINE( F, "	VAR	TOP9_disp, Q" );
    PUT_LINE( F, "	VAR	G9_disp, Q" );
    PUT_LINE( F, "	EXC_MACH	0, CTX9_disp" );
    PUT_LINE( F, "	LCA	h9_" );
    PUT_LINE( F, "	SA	0, CTX9_disp + 8" );
    PUT_LINE( F, "	LVA	0, CTX9_disp" );
    PUT_LINE( F, "	SA	0, TOP9_disp" );
    PUT_LINE( F, "	LI	7" );
    PUT_LINE( F, "	SQ	0, G9_disp" );
    PUT_LINE( F, "	CALL	STANDARD., SP9" );
    PUT_LINE( F, "	SYS_EXIT	2" );
    PUT_LINE( F, "exc_raise9_:" );
    PUT_LINE( F, "	EXC_RAISE	TOP9_disp" );
    PUT_LINE( F, "h9_:" );
    PUT_LINE( F, "	LQ	0, G9_disp" );
    PUT_LINE( F, "	LI	7" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	ok9" );
    PUT_LINE( F, "	SYS_EXIT	1" );
    PUT_LINE( F, "ok9:" );
    PUT_LINE( F, "	SYS_EXIT	0" );
    PUT_LINE( F, "if defined SP9_" );
    PUT_LINE( F, "	PRO	SP9" );
    PUT_LINE( F, "	ELB	1" );
    PUT_LINE( F, "	VAR	T9_disp, Q" );
    PUT_LINE( F, "	LI	13" );
    PUT_LINE( F, "	SQ	1, T9_disp" );
    PUT_LINE( F, "	BRA	exc_raise9_" );
    PUT_LINE( F, "	UNLINK	1" );
    PUT_LINE( F, "	RTD	0" );
    PUT_LINE( F, "	endPRO" );
    PUT_LINE( F, "end if" );
    PUT_LINE( F, " virtual VARzone" );
    PUT_LINE( F, "   loc_siz = $" );
    PUT_LINE( F, "  end virtual" );
    PUT_LINE( F, "end namespace" );
    CLOSE( F );

    FROM9 := IR.ELT_ID( IR.ELT_COUNT + 1 );
    RUN_P0( "TC_TEST9.FAS" );
    PASSES.P1_REACH;
    PASSES.P2_LAYOUT( FROM9, IR.ELT_ID( IR.ELT_COUNT ) );
    EMITS.P2B_ADDRESSES( FROM9, IR.ELT_ID( IR.ELT_COUNT ) );
    EMITS.P3_EMIT( FROM9, IR.ELT_ID( IR.ELT_COUNT ), "TC_TEST9.BIN" );

    CHECK( VALUE_OF( RESOLVE( "STANDARD.CTX9_disp" ) ) = 8
	   and then VALUE_OF( RESOLVE( "STANDARD.TOP9_disp" ) ) = 72
	   and then VALUE_OF( RESOLVE( "STANDARD.G9_disp" ) ) = 80,
	   "layout niveau 0 (ctx 8, top 72, g 80)" );
    CHECK( VALUE_OF( RESOLVE( "STANDARD.loc_siz" ) ) = 88,
	   "loc_siz de niveau 0 (attendu 88), obtenu"
	   & LONG_INTEGER'IMAGE( VALUE_OF( RESOLVE( "STANDARD.loc_siz" ) ) ) );
    CHECK( VALUE_OF( RESOLVE( "STANDARD.SP9.T9_disp" ) ) = 8
	   and then VALUE_OF( RESOLVE( "STANDARD.SP9.loc_siz" ) ) = 16,
	   "frame imbrique (T9 8, loc_siz 16)" );

    if OK
    then
      PUT_LINE( "PASSE exc" );
      PUT_LINE( "TC_TEST9.BIN ecrit - oracle externe :" );
      PUT_LINE( "  fasmg TC_TEST9.FAS TC_REF9 && cmp TC_REF9 TC_TEST9.BIN" );
      PUT_LINE( "  chmod +x TC_TEST9.BIN && ./TC_TEST9.BIN ; echo $?   (attendu : 0)" );
    end if;
  end;


  --|  TEMOIN TC-ARM09 : jumeau arm64 de TC_TEST9 (EXC_MACH 0, motif exact
  --|  de la tete reelle, levee depuis un frame imbrique, deroulage par
  --|  EXC_RAISE - y compris la micro-pile de retours par sp -, dispatch
  --|  sur h_a9_, etat de niveau 0 restaure). Verdict par code de sortie.

  TARGET_CPU := ARM64;
  declare
    use LEX, SYMBOLS, IR;
    OK			: BOOLEAN	:= TRUE;
    F			: FILE_TYPE;
    FROMA		: IR.ELT_ID;

    procedure CHECK ( COND :BOOLEAN; MSG :STRING )
    is
    begin
      if not COND
      then
	OK := FALSE;
	PUT_LINE( "ECHEC arm09 : " & MSG );
      end if;
    end CHECK;

  begin
    CREATE( F, OUT_FILE, "TC_ARM09.FAS" );
    PUT_LINE( F, "include '../../src/expander/fasmg/codi_arm64.finc'" );
    PUT_LINE( F, "STANDARD = 'STANDARD'" );
    PUT_LINE( F, "namespace STANDARD" );
    PUT_LINE( F, "  virtual at 8" );
    PUT_LINE( F, "    VARzone::" );
    PUT_LINE( F, "  end virtual" );
    PUT_LINE( F, "	LINK	0, loc_siz" );
    PUT_LINE( F, "	VAR	CTXA9_disp, 64" );
    PUT_LINE( F, "	VAR	TOPA9_disp, Q" );
    PUT_LINE( F, "	VAR	GA9_disp, Q" );
    PUT_LINE( F, "	EXC_MACH	0, CTXA9_disp" );
    PUT_LINE( F, "	LCA	h_a9_" );
    PUT_LINE( F, "	SA	0, CTXA9_disp + 8" );
    PUT_LINE( F, "	LVA	0, CTXA9_disp" );
    PUT_LINE( F, "	SA	0, TOPA9_disp" );
    PUT_LINE( F, "	LI	7" );
    PUT_LINE( F, "	SQ	0, GA9_disp" );
    PUT_LINE( F, "	CALL	STANDARD., SPA9" );
    PUT_LINE( F, "	SYS_EXIT	2" );
    PUT_LINE( F, "exc_raise_a9_:" );
    PUT_LINE( F, "	EXC_RAISE	TOPA9_disp" );
    PUT_LINE( F, "h_a9_:" );
    PUT_LINE( F, "	LQ	0, GA9_disp" );
    PUT_LINE( F, "	LI	7" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	ok_a9" );
    PUT_LINE( F, "	SYS_EXIT	1" );
    PUT_LINE( F, "ok_a9:" );
    PUT_LINE( F, "	SYS_EXIT	0" );
    PUT_LINE( F, "if defined SPA9_" );
    PUT_LINE( F, "	PRO	SPA9" );
    PUT_LINE( F, "	ELB	1" );
    PUT_LINE( F, "	VAR	TA9_disp, Q" );
    PUT_LINE( F, "	LI	13" );
    PUT_LINE( F, "	SQ	1, TA9_disp" );
    PUT_LINE( F, "	BRA	exc_raise_a9_" );
    PUT_LINE( F, "	UNLINK	1" );
    PUT_LINE( F, "	RTD	0" );
    PUT_LINE( F, "	endPRO" );
    PUT_LINE( F, "end if" );
    PUT_LINE( F, " virtual VARzone" );
    PUT_LINE( F, "   loc_siz = $" );
    PUT_LINE( F, "  end virtual" );
    PUT_LINE( F, "end namespace" );
    CLOSE( F );

    FROMA := IR.ELT_ID( IR.ELT_COUNT + 1 );
    RUN_P0( "TC_ARM09.FAS" );
    PASSES.P1_REACH;											--| lazy : active le bloc "if defined SPA7_" (CALL)
    PASSES.P2_LAYOUT( FROMA, IR.ELT_ID( IR.ELT_COUNT ) );							--| VAR, loc_siz
    EMITS.P2B_ADDRESSES( FROMA, IR.ELT_ID( IR.ELT_COUNT ) );
    EMITS.P3_EMIT( FROMA, IR.ELT_ID( IR.ELT_COUNT ), "TC_ARM09.BIN" );

    CHECK( VALUE_OF( RESOLVE( "STANDARD.CTXA9_disp" ) ) = 8
	   and then VALUE_OF( RESOLVE( "STANDARD.TOPA9_disp" ) ) = 72
	   and then VALUE_OF( RESOLVE( "STANDARD.GA9_disp" ) ) = 80,
	   "layout de niveau 0 (8 / 72 / 80)" );
    CHECK( VALUE_OF( RESOLVE( "STANDARD.loc_siz" ) ) = 88,
	   "loc_siz de niveau 0 (attendu 88), obtenu"
	   & LONG_INTEGER'IMAGE( VALUE_OF( RESOLVE( "STANDARD.loc_siz" ) ) ) );
    CHECK( VALUE_OF( RESOLVE( "STANDARD.h_a9_" ) ) - VALUE_OF( RESOLVE( "STANDARD.exc_raise_a9_" ) ) = 84,
	   "EXC_RAISE top = 72 : 76 + 2 x 4 = 84 octets" );

    if  OK  then
      PUT_LINE( "PASSE arm09" );
      PUT_LINE( "TC_ARM09.BIN ecrit - oracle externe :" );
      PUT_LINE( "  fasmg TC_ARM09.FAS TC_ARM_REF9 && cmp TC_ARM_REF9 TC_ARM09.BIN" );
      PUT_LINE( "  sur le Pi : chmod +x TC_ARM09.BIN && ./TC_ARM09.BIN ; echo $?   (attendu : 0 ; 1 = etat de niveau 0 non restaure ; 2 = flot non detourne)" );
    end if;
  end;


  --|  TEMOIN TEMPORAIRE USEINFO CODE (TC-10) - la forme exacte du
  --|  corpus expander : bloc type (garde + namespace + VAR use__info,q
  --|  + Sa lvl, use__info local), puis USEINFO lvl, NOM avec charge
  --|  "La lvl, chemin.use__info" (deux morceaux : la reconstruction
  --|  avec virgule est exercee), relecture par NOM__u. Le VAR dans un
  --|  namespace non-PRO loge dans le frame 0 (portee et pile, mini-Q7).
  --|  Verdict : 0 = la valeur a traverse use__info -> NOM__u ; 1 = non.
  --|  A RETIRER avec les autres.

  TARGET_CPU := X86_64;
  declare
    use LEX;
    use SYMBOLS;
    use IR;
    OK			: BOOLEAN	:= TRUE;
    F			: FILE_TYPE;
    FROM10		: IR.ELT_ID;

    procedure CHECK ( COND :BOOLEAN; MSG :STRING )
    is
    begin
      if not COND
      then
	OK := FALSE;
	PUT_LINE( "ECHEC useinfo : " & MSG );
      end if;
    end CHECK;

  begin
    CREATE( F, OUT_FILE, "TC_TEST10.FAS" );
    PUT_LINE( F, "	include '../../src/expander/fasmg/codi_x86_64.finc'" );
    PUT_LINE( F, "STANDARD = 'STANDARD'" );
    PUT_LINE( F, "namespace STANDARD" );
    PUT_LINE( F, "  virtual at 8" );
    PUT_LINE( F, "    VARzone::" );
    PUT_LINE( F, "  end virtual" );
    PUT_LINE( F, "	LINK	0, loc_siz" );
    PUT_LINE( F, "_T10 = '_T10'" );
    PUT_LINE( F, " namespace _T10" );
    PUT_LINE( F, "VAR use__info, Q" );
    PUT_LINE( F, "	LI	5150" );
    PUT_LINE( F, "	SA	0, use__info" );
    PUT_LINE( F, "end namespace " );
    PUT_LINE( F, "	USEINFO	0, ARR10, 	LA 0, _T10.use__info" );
    PUT_LINE( F, "	LQ	0, ARR10__u" );
    PUT_LINE( F, "	LI	5150" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	ok10" );
    PUT_LINE( F, "	SYS_EXIT	1" );
    PUT_LINE( F, "ok10:" );
    PUT_LINE( F, "	SYS_EXIT	0" );
    PUT_LINE( F, " virtual VARzone" );
    PUT_LINE( F, "   loc_siz = $" );
    PUT_LINE( F, "  end virtual" );
    PUT_LINE( F, "end namespace" );
    CLOSE( F );

    FROM10 := IR.ELT_ID( IR.ELT_COUNT + 1 );
    RUN_P0( "TC_TEST10.FAS" );
    PASSES.P1_REACH;
    PASSES.P2_LAYOUT( FROM10, IR.ELT_ID( IR.ELT_COUNT ) );
    EMITS.P2B_ADDRESSES( FROM10, IR.ELT_ID( IR.ELT_COUNT ) );
    EMITS.P3_EMIT( FROM10, IR.ELT_ID( IR.ELT_COUNT ), "TC_TEST10.BIN" );

    CHECK( VALUE_OF( RESOLVE( "STANDARD._T10.use__info" ) ) = 8,
	   "use__info du bloc type dans le frame 0 (8)" );
    CHECK( VALUE_OF( RESOLVE( "STANDARD.ARR10__u" ) ) = 16,
	   "ARR10__u reserve apres (16), obtenu"
	   & LONG_INTEGER'IMAGE( VALUE_OF( RESOLVE( "STANDARD.ARR10__u" ) ) ) );
    CHECK( VALUE_OF( RESOLVE( "STANDARD.loc_siz" ) ) = 24,
	   "loc_siz de niveau 0 (24)" );

    if OK
    then
      PUT_LINE( "PASSE useinfo" );
      PUT_LINE( "TC_TEST10.BIN ecrit - oracle externe :" );
      PUT_LINE( "  fasmg TC_TEST10.FAS TC_REF10 && cmp TC_REF10 TC_TEST10.BIN" );
      PUT_LINE( "  chmod +x TC_TEST10.BIN && ./TC_TEST10.BIN ; echo $?   (attendu : 0)" );
    end if;
  end;



  --|  TEMOIN TEMPORAIRE TETE REELLE (TC-11) - reproduction integrale
  --|  de la tete et de la queue de CREATE_FAS_MAIN_FILE (sans les
  --|  includes d'unites) : sentinelle pilier 11 (EXC_MACH 0 avec
  --|  l'operande EXPR ctx + _EXCEPTION_CONTEXT.DISPATCH), trampolines
  --|  exc_raise_ / exc_uncaught_ / ce_raise_ / ne_raise_, STR a octet
  --|  litteral (EXC_NL__, 10). Le main fait BRA ce_raise_ : chemin
  --|  "exception non rattrapee" de bout en bout. Verdict du binaire :
  --|  sortie "EXCEPTION NON RATTRAPEE : CONSTRAINT_ERROR" + LF, code 1
  --|  (le code 0 du SYS_EXIT nu apres le BRA ne doit JAMAIS sortir).
  --|  A RETIRER avec les autres.
  declare
    use LEX;
    use SYMBOLS;
    use IR;
    OK			: BOOLEAN	:= TRUE;
    F			: FILE_TYPE;
    FROM11		: IR.ELT_ID;

    procedure CHECK ( COND :BOOLEAN; MSG :STRING )
    is
    begin
      if not COND
      then
	OK := FALSE;
	PUT_LINE( "ECHEC tete : " & MSG );
      end if;
    end CHECK;

  begin
    CREATE( F, OUT_FILE, "TC_TEST11.FAS" );
    PUT_LINE( F, "	include '../../src/expander/fasmg/codi_x86_64.finc'" );
    PUT_LINE( F, "STANDARD = 'STANDARD'" );
    PUT_LINE( F, "namespace STANDARD" );
    PUT_LINE( F, "  virtual at 8" );
    PUT_LINE( F, "    VARzone::" );
    PUT_LINE( F, "  end virtual" );
    PUT_LINE( F, "	LINK	0, loc_siz" );
    PUT_LINE( F, "_EXCEPTION_CONTEXT = '_EXCEPTION_CONTEXT'" );
    PUT_LINE( F, " namespace _EXCEPTION_CONTEXT" );
    PUT_LINE( F, "virtual at 0" );
    PUT_LINE( F, "	STATOFS	PREV_CTX, 8, 8" );
    PUT_LINE( F, "	STATOFS	DISPATCH, 8, 8" );
    PUT_LINE( F, "end virtual" );
    PUT_LINE( F, "end namespace " );
    PUT_LINE( F, "	VAR	EXC_CTX0__dat, 64" );
    PUT_LINE( F, "	VAR	EXCEPTIONS_TOP_CTX_disp, Q" );
    PUT_LINE( F, "	VAR	EXCEPTIONS_CURRENT_disp, Q" );
    PUT_LINE( F, "	EXC_MACH	0, EXC_CTX0__dat" );
    PUT_LINE( F, "	LCA	exc_uncaught_" );
    PUT_LINE( F, "	SA	0, EXC_CTX0__dat + _EXCEPTION_CONTEXT.DISPATCH" );
    PUT_LINE( F, "	LVA	0, EXC_CTX0__dat" );
    PUT_LINE( F, "	SA	0, EXCEPTIONS_TOP_CTX_disp" );
    PUT_LINE( F, "	BRA	ce_raise_" );
    PUT_LINE( F, "	SYS_EXIT" );
    PUT_LINE( F, "exc_raise_:" );
    PUT_LINE( F, "	EXC_RAISE	EXCEPTIONS_TOP_CTX_disp" );
    PUT_LINE( F, "exc_uncaught_:" );
    PUT_LINE( F, "	STR	EXC_MSG__, 'EXCEPTION NON RATTRAPEE : '" );
    PUT_LINE( F, "	STR	EXC_NL__, 10" );
    PUT_LINE( F, "	LCA	EXC_MSG__.data_ptr" );
    PUT_LINE( F, "	SYS_PUT_STR" );
    PUT_LINE( F, "	LA	0, EXCEPTIONS_CURRENT_disp" );
    PUT_LINE( F, "	SYS_PUT_STR" );
    PUT_LINE( F, "	LCA	EXC_NL__.data_ptr" );
    PUT_LINE( F, "	SYS_PUT_STR" );
    PUT_LINE( F, "	SYS_EXIT	1" );
    PUT_LINE( F, "ce_raise_:" );
    PUT_LINE( F, "	LCA	CONSTRAINT_ERROR__exc.data_ptr" );
    PUT_LINE( F, "	SA	0, EXCEPTIONS_CURRENT_disp" );
    PUT_LINE( F, "	BRA	exc_raise_" );
    PUT_LINE( F, "ne_raise_:" );
    PUT_LINE( F, "	LCA	NUMERIC_ERROR__exc.data_ptr" );
    PUT_LINE( F, "	SA	0, EXCEPTIONS_CURRENT_disp" );
    PUT_LINE( F, "	BRA	exc_raise_" );
    PUT_LINE( F, "	STR	CONSTRAINT_ERROR__exc, 'CONSTRAINT_ERROR'" );
    PUT_LINE( F, "	STR	NUMERIC_ERROR__exc, 'NUMERIC_ERROR'" );
    PUT_LINE( F, " virtual VARzone" );
    PUT_LINE( F, "   loc_siz = $" );
    PUT_LINE( F, "  end virtual" );
    PUT_LINE( F, "end namespace" );
    CLOSE( F );

    FROM11 := IR.ELT_ID( IR.ELT_COUNT + 1 );
    RUN_P0( "TC_TEST11.FAS" );
    PASSES.P1_REACH;
    PASSES.P2_LAYOUT( FROM11, IR.ELT_ID( IR.ELT_COUNT ) );
    EMITS.P2B_ADDRESSES( FROM11, IR.ELT_ID( IR.ELT_COUNT ) );
    EMITS.P3_EMIT( FROM11, IR.ELT_ID( IR.ELT_COUNT ), "TC_TEST11.BIN" );

    CHECK( VALUE_OF( RESOLVE( "STANDARD._EXCEPTION_CONTEXT.DISPATCH" ) ) = 8,
	   "record statique du contexte (DISPATCH 8)" );
    CHECK( VALUE_OF( RESOLVE( "STANDARD.EXC_CTX0__dat" ) ) = 8
	   and then VALUE_OF( RESOLVE( "STANDARD.EXCEPTIONS_TOP_CTX_disp" ) ) = 72
	   and then VALUE_OF( RESOLVE( "STANDARD.EXCEPTIONS_CURRENT_disp" ) ) = 80,
	   "sentinelle et globales pilier 11 (8, 72, 80)" );
    CHECK( VALUE_OF( RESOLVE( "STANDARD.loc_siz" ) ) = 88,
	   "loc_siz de niveau 0 (88)" );
    CHECK( VALUE_OF( RESOLVE( "STANDARD.EXC_NL__.data" ) )
	     = VALUE_OF( RESOLVE( "STANDARD.EXC_NL__.data_ptr" ) ) + 32,
	   "bloc STR a octet litteral : structure standard" );

    if OK
    then
      PUT_LINE( "PASSE tete" );
      PUT_LINE( "TC_TEST11.BIN ecrit - oracle externe :" );
      PUT_LINE( "  fasmg TC_TEST11.FAS TC_REF11 && cmp TC_REF11 TC_TEST11.BIN" );
      PUT_LINE( "  chmod +x TC_TEST11.BIN && ./TC_TEST11.BIN ; echo $?" );
      PUT_LINE( "  (attendu : EXCEPTION NON RATTRAPEE : CONSTRAINT_ERROR puis 1)" );
    end if;
  end;


  --|  TEMOIN TEMPORAIRE LEXIQUE FINC (TC-12) - guillemets doubles
  --|  (vide, delimiteur oppose, doublages des deux delimiteurs),
  --|  record manuel "X = $ / rd N / size = $" en virtual at 4, LI a
  --|  operande EXPR (LI size*8, forme corpus). Verdict : affiche
  --|  c'est l'ete dit "oui"  puis 0 = SIZ12 (=128 via size12*8)
  --|  relu ; 2 = non. A RETIRER avec les autres.
  declare
    use LEX;
    use SYMBOLS;
    use IR;
    OK			: BOOLEAN	:= TRUE;
    F			: FILE_TYPE;
    FROM12		: IR.ELT_ID;

    procedure CHECK ( COND :BOOLEAN; MSG :STRING )
    is
    begin
      if not COND
      then
	OK := FALSE;
	PUT_LINE( "ECHEC lexfinc : " & MSG );
      end if;
    end CHECK;

  begin
    CREATE( F, OUT_FILE, "TC_TEST12.FAS" );
    PUT_LINE( F, "	include '../../src/expander/fasmg/codi_x86_64.finc'" );
    PUT_LINE( F, "STANDARD = 'STANDARD'" );
    PUT_LINE( F, "namespace STANDARD" );
    PUT_LINE( F, "  virtual at 8" );
    PUT_LINE( F, "    VARzone::" );
    PUT_LINE( F, "  end virtual" );
    PUT_LINE( F, "	LINK	0, loc_siz" );
    PUT_LINE( F, "_R12 = '_R12'" );
    PUT_LINE( F, " namespace _R12" );
    PUT_LINE( F, "VAR SIZ12, D" );
    PUT_LINE( F, "  virtual at 4" );
    PUT_LINE( F, "A12 = $" );
    PUT_LINE( F, "	rd 1 " );
    PUT_LINE( F, "B12 = $" );
    PUT_LINE( F, "	rd 2" );
    PUT_LINE( F, "size12 = $" );
    PUT_LINE( F, "  end virtual" );
    PUT_LINE( F, "	LI	 size12*8" );
    PUT_LINE( F, "	SD	0, SIZ12" );
    PUT_LINE( F, "end namespace " );
    PUT_LINE( F, "	STR	V12, "" l'ete """ );
    PUT_LINE( F, "	STR	W12, 'c''est'" );
    PUT_LINE( F, "	STR	X12, ""dit """"oui""""""" );
    PUT_LINE( F, "	STR	E12, """"" );
    PUT_LINE( F, "	LCA	W12.data_ptr" );
    PUT_LINE( F, "	SYS_PUT_STR" );
    PUT_LINE( F, "	LCA	V12.data_ptr" );
    PUT_LINE( F, "	SYS_PUT_STR" );
    PUT_LINE( F, "	LCA	X12.data_ptr" );
    PUT_LINE( F, "	SYS_PUT_STR" );
    PUT_LINE( F, "	LD	0, _R12.SIZ12" );
    PUT_LINE( F, "	LI	128" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	ok12" );
    PUT_LINE( F, "	SYS_EXIT	2" );
    PUT_LINE( F, "ok12:" );
    PUT_LINE( F, "	SYS_EXIT	0" );
    PUT_LINE( F, " virtual VARzone" );
    PUT_LINE( F, "   loc_siz = $" );
    PUT_LINE( F, "  end virtual" );
    PUT_LINE( F, "end namespace" );
    CLOSE( F );

    FROM12 := IR.ELT_ID( IR.ELT_COUNT + 1 );
    RUN_P0( "TC_TEST12.FAS" );
    PASSES.P1_REACH;
    PASSES.P2_LAYOUT( FROM12, IR.ELT_ID( IR.ELT_COUNT ) );
    EMITS.P2B_ADDRESSES( FROM12, IR.ELT_ID( IR.ELT_COUNT ) );
    EMITS.P3_EMIT( FROM12, IR.ELT_ID( IR.ELT_COUNT ), "TC_TEST12.BIN" );

    CHECK( VALUE_OF( RESOLVE( "STANDARD._R12.A12" ) ) = 4
	   and then VALUE_OF( RESOLVE( "STANDARD._R12.B12" ) ) = 8
	   and then VALUE_OF( RESOLVE( "STANDARD._R12.size12" ) ) = 16,
	   "record manuel en virtual at 4 (A 4, B 8, size 16)" );
    CHECK( VALUE_OF( RESOLVE( "STANDARD._R12.SIZ12" ) ) = 8
	   and then VALUE_OF( RESOLVE( "STANDARD.loc_siz" ) ) = 12,
	   "layout niveau 0 (SIZ12 8, loc_siz 12)" );
    CHECK( VALUE_OF( RESOLVE( "STANDARD.X12.data_ptr" ) )
	     = VALUE_OF( RESOLVE( "STANDARD.E12.data_ptr" ) ) + 32
	   and then VALUE_OF( RESOLVE( "STANDARD.W12.data_ptr" ) )
	     = VALUE_OF( RESOLVE( "STANDARD.X12.data_ptr" ) ) + 48
	   and then VALUE_OF( RESOLVE( "STANDARD.V12.data_ptr" ) )
	     = VALUE_OF( RESOLVE( "STANDARD.W12.data_ptr" ) ) + 40,
	   "longueurs normalisees (0, 9, 5) et placement LIFO" );

    if OK
    then
      PUT_LINE( "PASSE lexfinc" );
      PUT_LINE( "TC_TEST12.BIN ecrit - oracle externe :" );
      PUT_LINE( "  fasmg TC_TEST12.FAS TC_REF12 && cmp TC_REF12 TC_TEST12.BIN" );
      PUT_LINE( "  chmod +x TC_TEST12.BIN && ./TC_TEST12.BIN ; echo $?" );
      PUT_LINE( "  (attendu : c'est l'ete dit ""oui"" puis 0)" );
    end if;
  end;


  --|  TEMOIN TEMPORAIRE ACCES (TC-14) - la famille indirecte du corpus
  --|  regenere : SIQ/SIB/SID (rangements indirects), ULIB/ULID/LID/LIQ
  --|  (charges indirectes signees et non), LIA (alias LIQ) en forme
  --|  pile a operandes VIDES (defauts du codi), LIVA (adresse
  --|  indirecte), SW en forme pile, ULB/ULD (zero-extension, dont un
  --|  deplacement 32 bits), LIF (IEEE 754 : aller-retour execute sur
  --|  10.0 ; 0.1, 0.5, 1.0E38, 1.0E308, -2.5 assembles pour le
  --|  byte-diff). Verdicts : 0 = tout bon ; 3..12 = etape fautive.
  --|  Premier LINK 0 en alloc32 (loc_siz 256). A RETIRER avec les
  --|  autres.
  declare
    use LEX;
    use SYMBOLS;
    use IR;
    OK			: BOOLEAN	:= TRUE;
    F			: FILE_TYPE;
    FROM14		: IR.ELT_ID;

    procedure CHECK ( COND :BOOLEAN; MSG :STRING )
    is
    begin
      if not COND
      then
	OK := FALSE;
	PUT_LINE( "ECHEC acces : " & MSG );
      end if;
    end CHECK;

  begin
    CREATE( F, OUT_FILE, "TC_TEST14.FAS" );
    PUT_LINE( F, "	include '../../src/expander/fasmg/codi_x86_64.finc'" );
    PUT_LINE( F, "STANDARD = 'STANDARD'" );
    PUT_LINE( F, "namespace STANDARD" );
    PUT_LINE( F, "  virtual at 8" );
    PUT_LINE( F, "    VARzone::" );
    PUT_LINE( F, "  end virtual" );
    PUT_LINE( F, "	LINK	0, loc_siz" );
    PUT_LINE( F, "	VAR	P14_disp, Q" );
    PUT_LINE( F, "	VAR	B14_disp, B, 1" );
    PUT_LINE( F, "	VAR	PAD14_disp, 199" );
    PUT_LINE( F, "	VAR	FAR14_disp, D" );
    PUT_LINE( F, "	VAR	BLK14_disp, 24" );
    PUT_LINE( F, "	LVA	0, BLK14_disp" );
    PUT_LINE( F, "	SA	0, P14_disp" );
    PUT_LINE( F, "	LI	81985529216486895" );
    PUT_LINE( F, "	SIQ	0, P14_disp, 16" );
    PUT_LINE( F, "	LI	0" );
    PUT_LINE( F, "	SIQ	0, P14_disp, 8" );
    PUT_LINE( F, "	LI	255" );
    PUT_LINE( F, "	SIB	0, P14_disp, 2" );
    PUT_LINE( F, "	LI	-2" );
    PUT_LINE( F, "	SID	0, P14_disp, 4" );
    PUT_LINE( F, "	ULIB	0, P14_disp, 2" );
    PUT_LINE( F, "	LI	255" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k1" );
    PUT_LINE( F, "	SYS_EXIT	3" );
    PUT_LINE( F, "k1:" );
    PUT_LINE( F, "	ULID	0, P14_disp, 4" );
    PUT_LINE( F, "	LI	4294967294" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k2" );
    PUT_LINE( F, "	SYS_EXIT	4" );
    PUT_LINE( F, "k2:" );
    PUT_LINE( F, "	LID	0, P14_disp, 4" );
    PUT_LINE( F, "	LI	-2" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k3" );
    PUT_LINE( F, "	SYS_EXIT	5" );
    PUT_LINE( F, "k3:" );
    PUT_LINE( F, "	LIQ	0, P14_disp, 16" );
    PUT_LINE( F, "	LI	81985529216486895" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k4" );
    PUT_LINE( F, "	SYS_EXIT	6" );
    PUT_LINE( F, "k4:" );
    PUT_LINE( F, "	LVA	0, P14_disp" );
    PUT_LINE( F, "	LIA	, , 16" );
    PUT_LINE( F, "	LI	81985529216486895" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k5" );
    PUT_LINE( F, "	SYS_EXIT	7" );
    PUT_LINE( F, "k5:" );
    PUT_LINE( F, "	LIVA	0, P14_disp, 16" );
    PUT_LINE( F, "	LVA	0, BLK14_disp + 16" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k6" );
    PUT_LINE( F, "	SYS_EXIT	8" );
    PUT_LINE( F, "k6:" );
    PUT_LINE( F, "	LVA	0, BLK14_disp + 8" );
    PUT_LINE( F, "	LI	48879" );
    PUT_LINE( F, "	SW	, 0" );
    PUT_LINE( F, "	ULD	0, BLK14_disp + 8" );
    PUT_LINE( F, "	LI	48879" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k7" );
    PUT_LINE( F, "	SYS_EXIT	9" );
    PUT_LINE( F, "k7:" );
    PUT_LINE( F, "	LI	255" );
    PUT_LINE( F, "	SB	0, B14_disp" );
    PUT_LINE( F, "	ULB	0, B14_disp" );
    PUT_LINE( F, "	LI	255" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k8" );
    PUT_LINE( F, "	SYS_EXIT	10" );
    PUT_LINE( F, "k8:" );
    PUT_LINE( F, "	LI	-1" );
    PUT_LINE( F, "	SD	0, FAR14_disp" );
    PUT_LINE( F, "	ULD	0, FAR14_disp" );
    PUT_LINE( F, "	LI	4294967295" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k9" );
    PUT_LINE( F, "	SYS_EXIT	11" );
    PUT_LINE( F, "k9:" );
    PUT_LINE( F, "	LIF	10.0" );
    PUT_LINE( F, "	SIQ	0, P14_disp, 0" );
    PUT_LINE( F, "	LIF	10.0" );
    PUT_LINE( F, "	LIQ	0, P14_disp, 0" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k10" );
    PUT_LINE( F, "	SYS_EXIT	12" );
    PUT_LINE( F, "k10:" );
    PUT_LINE( F, "	SYS_EXIT	0" );
    PUT_LINE( F, "	LIF	0.1" );  -- induit diff fasmg
    PUT_LINE( F, "	LIF	0.5" );  -- ok
    PUT_LINE( F, "	LIF	1.0E38" );  -- induit diff fasmg
    PUT_LINE( F, "	LIF	1.0E308" );  -- DATA_ERROR
    PUT_LINE( F, "	LIF	-2.5" );  -- ok
    PUT_LINE( F, " virtual VARzone" );
    PUT_LINE( F, "   loc_siz = $" );
    PUT_LINE( F, "  end virtual" );
    PUT_LINE( F, "end namespace" );
    CLOSE( F );

    FROM14 := IR.ELT_ID( IR.ELT_COUNT + 1 );
    RUN_P0( "TC_TEST14.FAS" );
    PASSES.P1_REACH;
    PASSES.P2_LAYOUT( FROM14, IR.ELT_ID( IR.ELT_COUNT ) );
    EMITS.P2B_ADDRESSES( FROM14, IR.ELT_ID( IR.ELT_COUNT ) );
    EMITS.P3_EMIT( FROM14, IR.ELT_ID( IR.ELT_COUNT ), "TC_TEST14.BIN" );

    CHECK( VALUE_OF( RESOLVE( "STANDARD.P14_disp" ) ) = 8
	   and then VALUE_OF( RESOLVE( "STANDARD.B14_disp" ) ) = 16
	   and then VALUE_OF( RESOLVE( "STANDARD.FAR14_disp" ) ) = 224
	   and then VALUE_OF( RESOLVE( "STANDARD.BLK14_disp" ) ) = 232,
	   "layout niveau 0 (8, 16, 224, 232)" );
    CHECK( VALUE_OF( RESOLVE( "STANDARD.loc_siz" ) ) = 256,
	   "loc_siz 256 (LINK 0 en alloc32, premiere fois)" );

    if OK
    then
      PUT_LINE( "PASSE acces" );
      PUT_LINE( "TC_TEST14.BIN ecrit - oracle externe :" );
      PUT_LINE( "  fasmg TC_TEST14.FAS TC_REF14 && cmp TC_REF14 TC_TEST14.BIN" );
      PUT_LINE( "  chmod +x TC_TEST14.BIN && ./TC_TEST14.BIN ; echo $?   (attendu : 0)" );
    end if;
  end;


  --|  TEMOIN TEMPORAIRE CALCUL (TC-16) - les 28 mnemoniques de la
  --|  tranche E3, chacun sous verdict d'execution discriminant :
  --|  division tronquee / reste / modulo Ada (signes croises), NEG,
  --|  INC/DEC, CLAMP0 (deux bords), OUX, SHL, les cinq comparaisons
  --|  entieres (vraies par BT, fausses par BF), l'arithmetique et les
  --|  comparaisons flottantes (FCNE en filtre d'egalite), FNEG, les
  --|  conversions CVTIF / CVTFI (troncature) / CVTFIR (arrondi machine
  --|  pair : 3.5 -> 4) / CVTIX (7 * 2 / 3 = 4). Verdicts : 0 = tout
  --|  bon ; 3..30 = etape fautive. A RETIRER avec les autres.
  declare
    use LEX;
    use SYMBOLS;
    use IR;
    OK			: BOOLEAN	:= TRUE;
    F			: FILE_TYPE;
    FROM16		: IR.ELT_ID;

    procedure CHECK ( COND :BOOLEAN; MSG :STRING )
    is
    begin
      if not COND
      then
	OK := FALSE;
	PUT_LINE( "ECHEC calcul : " & MSG );
      end if;
    end CHECK;

  begin
    CREATE( F, OUT_FILE, "TC_TEST16.FAS" );
    PUT_LINE( F, "	include '../../src/expander/fasmg/codi_x86_64.finc'" );
    PUT_LINE( F, "STANDARD = 'STANDARD'" );
    PUT_LINE( F, "namespace STANDARD" );
    PUT_LINE( F, "  virtual at 8" );
    PUT_LINE( F, "    VARzone::" );
    PUT_LINE( F, "  end virtual" );
    PUT_LINE( F, "	LINK	0, loc_siz" );
    PUT_LINE( F, "	LI	17" );
    PUT_LINE( F, "	LI	-5" );
    PUT_LINE( F, "	DIV" );
    PUT_LINE( F, "	LI	-3" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k16_3" );
    PUT_LINE( F, "	SYS_EXIT	3" );
    PUT_LINE( F, "k16_3:" );
    PUT_LINE( F, "	LI	17" );
    PUT_LINE( F, "	LI	-5" );
    PUT_LINE( F, "	REMI" );
    PUT_LINE( F, "	LI	2" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k16_4" );
    PUT_LINE( F, "	SYS_EXIT	4" );
    PUT_LINE( F, "k16_4:" );
    PUT_LINE( F, "	LI	17" );
    PUT_LINE( F, "	LI	-5" );
    PUT_LINE( F, "	MODI" );
    PUT_LINE( F, "	LI	-3" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k16_5" );
    PUT_LINE( F, "	SYS_EXIT	5" );
    PUT_LINE( F, "k16_5:" );
    PUT_LINE( F, "	LI	-17" );
    PUT_LINE( F, "	LI	5" );
    PUT_LINE( F, "	MODI" );
    PUT_LINE( F, "	LI	3" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k16_6" );
    PUT_LINE( F, "	SYS_EXIT	6" );
    PUT_LINE( F, "k16_6:" );
    PUT_LINE( F, "	LI	42" );
    PUT_LINE( F, "	NEG" );
    PUT_LINE( F, "	LI	-42" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k16_7" );
    PUT_LINE( F, "	SYS_EXIT	7" );
    PUT_LINE( F, "k16_7:" );
    PUT_LINE( F, "	LI	7" );
    PUT_LINE( F, "	INC" );
    PUT_LINE( F, "	INC" );
    PUT_LINE( F, "	DEC" );
    PUT_LINE( F, "	LI	8" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k16_8" );
    PUT_LINE( F, "	SYS_EXIT	8" );
    PUT_LINE( F, "k16_8:" );
    PUT_LINE( F, "	LI	-7" );
    PUT_LINE( F, "	CLAMP0" );
    PUT_LINE( F, "	LI	0" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k16_9" );
    PUT_LINE( F, "	SYS_EXIT	9" );
    PUT_LINE( F, "k16_9:" );
    PUT_LINE( F, "	LI	5" );
    PUT_LINE( F, "	CLAMP0" );
    PUT_LINE( F, "	LI	5" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k16_10" );
    PUT_LINE( F, "	SYS_EXIT	10" );
    PUT_LINE( F, "k16_10:" );
    PUT_LINE( F, "	LI	61680" );
    PUT_LINE( F, "	LI	4080" );
    PUT_LINE( F, "	OUX" );
    PUT_LINE( F, "	LI	65280" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k16_11" );
    PUT_LINE( F, "	SYS_EXIT	11" );
    PUT_LINE( F, "k16_11:" );
    PUT_LINE( F, "	LI	3" );
    PUT_LINE( F, "	LI	4" );
    PUT_LINE( F, "	SHL" );
    PUT_LINE( F, "	LI	48" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k16_12" );
    PUT_LINE( F, "	SYS_EXIT	12" );
    PUT_LINE( F, "k16_12:" );
    PUT_LINE( F, "	LI	5" );
    PUT_LINE( F, "	LI	3" );
    PUT_LINE( F, "	CGT" );
    PUT_LINE( F, "	BT	k16_13" );
    PUT_LINE( F, "	SYS_EXIT	13" );
    PUT_LINE( F, "k16_13:" );
    PUT_LINE( F, "	LI	3" );
    PUT_LINE( F, "	LI	5" );
    PUT_LINE( F, "	CGT" );
    PUT_LINE( F, "	BF	k16_14" );
    PUT_LINE( F, "	SYS_EXIT	14" );
    PUT_LINE( F, "k16_14:" );
    PUT_LINE( F, "	LI	3" );
    PUT_LINE( F, "	LI	5" );
    PUT_LINE( F, "	CLT" );
    PUT_LINE( F, "	BT	k16_15" );
    PUT_LINE( F, "	SYS_EXIT	15" );
    PUT_LINE( F, "k16_15:" );
    PUT_LINE( F, "	LI	5" );
    PUT_LINE( F, "	LI	5" );
    PUT_LINE( F, "	CLE" );
    PUT_LINE( F, "	BT	k16_16" );
    PUT_LINE( F, "	SYS_EXIT	16" );
    PUT_LINE( F, "k16_16:" );
    PUT_LINE( F, "	LI	5" );
    PUT_LINE( F, "	LI	5" );
    PUT_LINE( F, "	CGE" );
    PUT_LINE( F, "	BT	k16_17" );
    PUT_LINE( F, "	SYS_EXIT	17" );
    PUT_LINE( F, "k16_17:" );
    PUT_LINE( F, "	LI	5" );
    PUT_LINE( F, "	LI	5" );
    PUT_LINE( F, "	CNE" );
    PUT_LINE( F, "	BF	k16_18" );
    PUT_LINE( F, "	SYS_EXIT	18" );
    PUT_LINE( F, "k16_18:" );
    PUT_LINE( F, "	LIF	1.5" );
    PUT_LINE( F, "	LIF	2.25" );
    PUT_LINE( F, "	FADD" );
    PUT_LINE( F, "	LIF	3.75" );
    PUT_LINE( F, "	FCNE" );
    PUT_LINE( F, "	BF	k16_19" );
    PUT_LINE( F, "	SYS_EXIT	19" );
    PUT_LINE( F, "k16_19:" );
    PUT_LINE( F, "	LIF	5.5" );
    PUT_LINE( F, "	LIF	2.25" );
    PUT_LINE( F, "	FSUB" );
    PUT_LINE( F, "	LIF	3.25" );
    PUT_LINE( F, "	FCNE" );
    PUT_LINE( F, "	BF	k16_20" );
    PUT_LINE( F, "	SYS_EXIT	20" );
    PUT_LINE( F, "k16_20:" );
    PUT_LINE( F, "	LIF	1.5" );
    PUT_LINE( F, "	LIF	2.5" );
    PUT_LINE( F, "	FMUL" );
    PUT_LINE( F, "	LIF	3.75" );
    PUT_LINE( F, "	FCNE" );
    PUT_LINE( F, "	BF	k16_21" );
    PUT_LINE( F, "	SYS_EXIT	21" );
    PUT_LINE( F, "k16_21:" );
    PUT_LINE( F, "	LIF	7.5" );
    PUT_LINE( F, "	LIF	2.5" );
    PUT_LINE( F, "	FDIV" );
    PUT_LINE( F, "	LIF	3.0" );
    PUT_LINE( F, "	FCNE" );
    PUT_LINE( F, "	BF	k16_22" );
    PUT_LINE( F, "	SYS_EXIT	22" );
    PUT_LINE( F, "k16_22:" );
    PUT_LINE( F, "	LIF	2.5" );
    PUT_LINE( F, "	FNEG" );
    PUT_LINE( F, "	LIF	-2.5" );
    PUT_LINE( F, "	FCNE" );
    PUT_LINE( F, "	BF	k16_23" );
    PUT_LINE( F, "	SYS_EXIT	23" );
    PUT_LINE( F, "k16_23:" );
    PUT_LINE( F, "	LIF	1.5" );
    PUT_LINE( F, "	LIF	2.5" );
    PUT_LINE( F, "	FCLT" );
    PUT_LINE( F, "	BT	k16_24" );
    PUT_LINE( F, "	SYS_EXIT	24" );
    PUT_LINE( F, "k16_24:" );
    PUT_LINE( F, "	LIF	2.5" );
    PUT_LINE( F, "	LIF	1.5" );
    PUT_LINE( F, "	FCGT" );
    PUT_LINE( F, "	BT	k16_25" );
    PUT_LINE( F, "	SYS_EXIT	25" );
    PUT_LINE( F, "k16_25:" );
    PUT_LINE( F, "	LIF	2.5" );
    PUT_LINE( F, "	LIF	2.5" );
    PUT_LINE( F, "	FCGE" );
    PUT_LINE( F, "	BT	k16_26" );
    PUT_LINE( F, "	SYS_EXIT	26" );
    PUT_LINE( F, "k16_26:" );
    PUT_LINE( F, "	LI	7" );
    PUT_LINE( F, "	CVTIF" );
    PUT_LINE( F, "	LIF	7.0" );
    PUT_LINE( F, "	FCNE" );
    PUT_LINE( F, "	BF	k16_27" );
    PUT_LINE( F, "	SYS_EXIT	27" );
    PUT_LINE( F, "k16_27:" );
    PUT_LINE( F, "	LIF	-3.75" );
    PUT_LINE( F, "	CVTFI" );
    PUT_LINE( F, "	LI	-3" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k16_28" );
    PUT_LINE( F, "	SYS_EXIT	28" );
    PUT_LINE( F, "k16_28:" );
    PUT_LINE( F, "	LIF	3.5" );
    PUT_LINE( F, "	CVTFIR" );
    PUT_LINE( F, "	LI	4" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k16_29" );
    PUT_LINE( F, "	SYS_EXIT	29" );
    PUT_LINE( F, "k16_29:" );
    PUT_LINE( F, "	LI	7" );
    PUT_LINE( F, "	LI	2" );
    PUT_LINE( F, "	LI	3" );
    PUT_LINE( F, "	CVTIX" );
    PUT_LINE( F, "	LI	4" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k16_30" );
    PUT_LINE( F, "	SYS_EXIT	30" );
    PUT_LINE( F, "k16_30:" );
    PUT_LINE( F, "	SYS_EXIT	0" );
    PUT_LINE( F, " virtual VARzone" );
    PUT_LINE( F, "   loc_siz = $" );
    PUT_LINE( F, "  end virtual" );
    PUT_LINE( F, "end namespace" );
    CLOSE( F );

    FROM16 := IR.ELT_ID( IR.ELT_COUNT + 1 );
    RUN_P0( "TC_TEST16.FAS" );
    PASSES.P1_REACH;
    PASSES.P2_LAYOUT( FROM16, IR.ELT_ID( IR.ELT_COUNT ) );
    EMITS.P2B_ADDRESSES( FROM16, IR.ELT_ID( IR.ELT_COUNT ) );
    EMITS.P3_EMIT( FROM16, IR.ELT_ID( IR.ELT_COUNT ), "TC_TEST16.BIN" );

    CHECK( VALUE_OF( RESOLVE( "STANDARD.loc_siz" ) ) = 8,
	   "frame 0 sans variable (loc_siz 8)" );

    if OK
    then
      PUT_LINE( "PASSE calcul" );
      PUT_LINE( "TC_TEST16.BIN ecrit - oracle externe :" );
      PUT_LINE( "  fasmg TC_TEST16.FAS TC_REF16 && cmp TC_REF16 TC_TEST16.BIN" );
      PUT_LINE( "  chmod +x TC_TEST16.BIN && ./TC_TEST16.BIN ; echo $?   (attendu : 0)" );
    end if;
  end;


  --|  TEMOIN TC-ARM16 : jumeau arm64 de TC_TEST16 - le MEME programme (labels
  --|  suffixes A16), les 28 mnemoniques de calcul sous verdict d'execution
  --|  discriminant (0 = tout bon, 3..30 = etape fautive). Sur arm : CVTFIR =
  --|  fcvtns (pair), CVTIX / CVTXI par SDIV128_64_POS.

  TARGET_CPU := ARM64;
  declare
    use LEX, SYMBOLS, IR;
    OK			: BOOLEAN	:= TRUE;
    F			: FILE_TYPE;
    FROMA		: IR.ELT_ID;

    procedure CHECK ( COND :BOOLEAN; MSG :STRING )
    is
    begin
      if not COND
      then
	OK := FALSE;
	PUT_LINE( "ECHEC arm16 : " & MSG );
      end if;
    end CHECK;

  begin
    CREATE( F, OUT_FILE, "TC_ARM16.FAS" );
    PUT_LINE( F, "	include '../../src/expander/fasmg/codi_arm64.finc'" );
    PUT_LINE( F, "STANDARD = 'STANDARD'" );
    PUT_LINE( F, "namespace STANDARD" );
    PUT_LINE( F, "  virtual at 8" );
    PUT_LINE( F, "    VARzone::" );
    PUT_LINE( F, "  end virtual" );
    PUT_LINE( F, "	LINK	0, loc_siz" );
    PUT_LINE( F, "	LI	17" );
    PUT_LINE( F, "	LI	-5" );
    PUT_LINE( F, "	DIV" );
    PUT_LINE( F, "	LI	-3" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	kA16_3" );
    PUT_LINE( F, "	SYS_EXIT	3" );
    PUT_LINE( F, "kA16_3:" );
    PUT_LINE( F, "	LI	17" );
    PUT_LINE( F, "	LI	-5" );
    PUT_LINE( F, "	REMI" );
    PUT_LINE( F, "	LI	2" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	kA16_4" );
    PUT_LINE( F, "	SYS_EXIT	4" );
    PUT_LINE( F, "kA16_4:" );
    PUT_LINE( F, "	LI	17" );
    PUT_LINE( F, "	LI	-5" );
    PUT_LINE( F, "	MODI" );
    PUT_LINE( F, "	LI	-3" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	kA16_5" );
    PUT_LINE( F, "	SYS_EXIT	5" );
    PUT_LINE( F, "kA16_5:" );
    PUT_LINE( F, "	LI	-17" );
    PUT_LINE( F, "	LI	5" );
    PUT_LINE( F, "	MODI" );
    PUT_LINE( F, "	LI	3" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	kA16_6" );
    PUT_LINE( F, "	SYS_EXIT	6" );
    PUT_LINE( F, "kA16_6:" );
    PUT_LINE( F, "	LI	42" );
    PUT_LINE( F, "	NEG" );
    PUT_LINE( F, "	LI	-42" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	kA16_7" );
    PUT_LINE( F, "	SYS_EXIT	7" );
    PUT_LINE( F, "kA16_7:" );
    PUT_LINE( F, "	LI	7" );
    PUT_LINE( F, "	INC" );
    PUT_LINE( F, "	INC" );
    PUT_LINE( F, "	DEC" );
    PUT_LINE( F, "	LI	8" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	kA16_8" );
    PUT_LINE( F, "	SYS_EXIT	8" );
    PUT_LINE( F, "kA16_8:" );
    PUT_LINE( F, "	LI	-7" );
    PUT_LINE( F, "	CLAMP0" );
    PUT_LINE( F, "	LI	0" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	kA16_9" );
    PUT_LINE( F, "	SYS_EXIT	9" );
    PUT_LINE( F, "kA16_9:" );
    PUT_LINE( F, "	LI	5" );
    PUT_LINE( F, "	CLAMP0" );
    PUT_LINE( F, "	LI	5" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	kA16_10" );
    PUT_LINE( F, "	SYS_EXIT	10" );
    PUT_LINE( F, "kA16_10:" );
    PUT_LINE( F, "	LI	61680" );
    PUT_LINE( F, "	LI	4080" );
    PUT_LINE( F, "	OUX" );
    PUT_LINE( F, "	LI	65280" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	kA16_11" );
    PUT_LINE( F, "	SYS_EXIT	11" );
    PUT_LINE( F, "kA16_11:" );
    PUT_LINE( F, "	LI	3" );
    PUT_LINE( F, "	LI	4" );
    PUT_LINE( F, "	SHL" );
    PUT_LINE( F, "	LI	48" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	kA16_12" );
    PUT_LINE( F, "	SYS_EXIT	12" );
    PUT_LINE( F, "kA16_12:" );
    PUT_LINE( F, "	LI	5" );
    PUT_LINE( F, "	LI	3" );
    PUT_LINE( F, "	CGT" );
    PUT_LINE( F, "	BT	kA16_13" );
    PUT_LINE( F, "	SYS_EXIT	13" );
    PUT_LINE( F, "kA16_13:" );
    PUT_LINE( F, "	LI	3" );
    PUT_LINE( F, "	LI	5" );
    PUT_LINE( F, "	CGT" );
    PUT_LINE( F, "	BF	kA16_14" );
    PUT_LINE( F, "	SYS_EXIT	14" );
    PUT_LINE( F, "kA16_14:" );
    PUT_LINE( F, "	LI	3" );
    PUT_LINE( F, "	LI	5" );
    PUT_LINE( F, "	CLT" );
    PUT_LINE( F, "	BT	kA16_15" );
    PUT_LINE( F, "	SYS_EXIT	15" );
    PUT_LINE( F, "kA16_15:" );
    PUT_LINE( F, "	LI	5" );
    PUT_LINE( F, "	LI	5" );
    PUT_LINE( F, "	CLE" );
    PUT_LINE( F, "	BT	kA16_16" );
    PUT_LINE( F, "	SYS_EXIT	16" );
    PUT_LINE( F, "kA16_16:" );
    PUT_LINE( F, "	LI	5" );
    PUT_LINE( F, "	LI	5" );
    PUT_LINE( F, "	CGE" );
    PUT_LINE( F, "	BT	kA16_17" );
    PUT_LINE( F, "	SYS_EXIT	17" );
    PUT_LINE( F, "kA16_17:" );
    PUT_LINE( F, "	LI	5" );
    PUT_LINE( F, "	LI	5" );
    PUT_LINE( F, "	CNE" );
    PUT_LINE( F, "	BF	kA16_18" );
    PUT_LINE( F, "	SYS_EXIT	18" );
    PUT_LINE( F, "kA16_18:" );
    PUT_LINE( F, "	LIF	1.5" );
    PUT_LINE( F, "	LIF	2.25" );
    PUT_LINE( F, "	FADD" );
    PUT_LINE( F, "	LIF	3.75" );
    PUT_LINE( F, "	FCNE" );
    PUT_LINE( F, "	BF	kA16_19" );
    PUT_LINE( F, "	SYS_EXIT	19" );
    PUT_LINE( F, "kA16_19:" );
    PUT_LINE( F, "	LIF	5.5" );
    PUT_LINE( F, "	LIF	2.25" );
    PUT_LINE( F, "	FSUB" );
    PUT_LINE( F, "	LIF	3.25" );
    PUT_LINE( F, "	FCNE" );
    PUT_LINE( F, "	BF	kA16_20" );
    PUT_LINE( F, "	SYS_EXIT	20" );
    PUT_LINE( F, "kA16_20:" );
    PUT_LINE( F, "	LIF	1.5" );
    PUT_LINE( F, "	LIF	2.5" );
    PUT_LINE( F, "	FMUL" );
    PUT_LINE( F, "	LIF	3.75" );
    PUT_LINE( F, "	FCNE" );
    PUT_LINE( F, "	BF	kA16_21" );
    PUT_LINE( F, "	SYS_EXIT	21" );
    PUT_LINE( F, "kA16_21:" );
    PUT_LINE( F, "	LIF	7.5" );
    PUT_LINE( F, "	LIF	2.5" );
    PUT_LINE( F, "	FDIV" );
    PUT_LINE( F, "	LIF	3.0" );
    PUT_LINE( F, "	FCNE" );
    PUT_LINE( F, "	BF	kA16_22" );
    PUT_LINE( F, "	SYS_EXIT	22" );
    PUT_LINE( F, "kA16_22:" );
    PUT_LINE( F, "	LIF	2.5" );
    PUT_LINE( F, "	FNEG" );
    PUT_LINE( F, "	LIF	-2.5" );
    PUT_LINE( F, "	FCNE" );
    PUT_LINE( F, "	BF	kA16_23" );
    PUT_LINE( F, "	SYS_EXIT	23" );
    PUT_LINE( F, "kA16_23:" );
    PUT_LINE( F, "	LIF	1.5" );
    PUT_LINE( F, "	LIF	2.5" );
    PUT_LINE( F, "	FCLT" );
    PUT_LINE( F, "	BT	kA16_24" );
    PUT_LINE( F, "	SYS_EXIT	24" );
    PUT_LINE( F, "kA16_24:" );
    PUT_LINE( F, "	LIF	2.5" );
    PUT_LINE( F, "	LIF	1.5" );
    PUT_LINE( F, "	FCGT" );
    PUT_LINE( F, "	BT	kA16_25" );
    PUT_LINE( F, "	SYS_EXIT	25" );
    PUT_LINE( F, "kA16_25:" );
    PUT_LINE( F, "	LIF	2.5" );
    PUT_LINE( F, "	LIF	2.5" );
    PUT_LINE( F, "	FCGE" );
    PUT_LINE( F, "	BT	kA16_26" );
    PUT_LINE( F, "	SYS_EXIT	26" );
    PUT_LINE( F, "kA16_26:" );
    PUT_LINE( F, "	LI	7" );
    PUT_LINE( F, "	CVTIF" );
    PUT_LINE( F, "	LIF	7.0" );
    PUT_LINE( F, "	FCNE" );
    PUT_LINE( F, "	BF	kA16_27" );
    PUT_LINE( F, "	SYS_EXIT	27" );
    PUT_LINE( F, "kA16_27:" );
    PUT_LINE( F, "	LIF	-3.75" );
    PUT_LINE( F, "	CVTFI" );
    PUT_LINE( F, "	LI	-3" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	kA16_28" );
    PUT_LINE( F, "	SYS_EXIT	28" );
    PUT_LINE( F, "kA16_28:" );
    PUT_LINE( F, "	LIF	3.5" );
    PUT_LINE( F, "	CVTFIR" );
    PUT_LINE( F, "	LI	4" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	kA16_29" );
    PUT_LINE( F, "	SYS_EXIT	29" );
    PUT_LINE( F, "kA16_29:" );
    PUT_LINE( F, "	LI	7" );
    PUT_LINE( F, "	LI	2" );
    PUT_LINE( F, "	LI	3" );
    PUT_LINE( F, "	CVTIX" );
    PUT_LINE( F, "	LI	4" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	kA16_30" );
    PUT_LINE( F, "	SYS_EXIT	30" );
    PUT_LINE( F, "kA16_30:" );
    PUT_LINE( F, "	SYS_EXIT	0" );
    PUT_LINE( F, " virtual VARzone" );
    PUT_LINE( F, "   loc_siz = $" );
    PUT_LINE( F, "  end virtual" );
    PUT_LINE( F, "end namespace" );
    CLOSE( F );

    FROMA := IR.ELT_ID( IR.ELT_COUNT + 1 );
    RUN_P0( "TC_ARM16.FAS" );
    PASSES.P1_REACH;
    PASSES.P2_LAYOUT( FROMA, IR.ELT_ID( IR.ELT_COUNT ) );
    EMITS.P2B_ADDRESSES( FROMA, IR.ELT_ID( IR.ELT_COUNT ) );
    EMITS.P3_EMIT( FROMA, IR.ELT_ID( IR.ELT_COUNT ), "TC_ARM16.BIN" );

    CHECK( VALUE_OF( RESOLVE( "STANDARD.loc_siz" ) ) = 8,
	   "loc_siz de niveau 0 (attendu 8)" );

    if  OK  then
      PUT_LINE( "PASSE arm16" );
      PUT_LINE( "TC_ARM16.BIN ecrit - oracle externe :" );
      PUT_LINE( "  fasmg TC_ARM16.FAS TC_ARM_REF16 && cmp TC_ARM_REF16 TC_ARM16.BIN" );
      PUT_LINE( "  sur le Pi : chmod +x TC_ARM16.BIN && ./TC_ARM16.BIN ; echo $?   (attendu : 0 ; 3..30 = etape fautive)" );
    end if;
  end;


  --|  TEMOIN TEMPORAIRE BLOCS (TC-17) - le bloc d'images de _BOOLEAN
  --|  reproduit a l'identique (BEGIN_BLOC_DEF / db val, len, chaine /
  --|  END_BLOC_DEF 1, 0, 1 / LCA SIZ / SA use__info), premier
  --|  alignement INLINE du subset (bourrage NOP d'END_BLOC_DEF),
  --|  lecture par le chemin reel (use__info -> SIZ -> data_ptr a +16
  --|  -> octets d'images), BLKMOV (copie de l'image TRUE vers le
  --|  frame), CO_VAR (allocation co-pile ecrite et relue). Verdicts :
  --|  0 = tout bon ; 3..7 = etape fautive. A RETIRER avec les autres.

  TARGET_CPU := X86_64;
  declare
    use LEX;
    use SYMBOLS;
    use IR;
    OK			: BOOLEAN	:= TRUE;
    F			: FILE_TYPE;
    FROM17		: IR.ELT_ID;

    procedure CHECK ( COND :BOOLEAN; MSG :STRING )
    is
    begin
      if not COND
      then
	OK := FALSE;
	PUT_LINE( "ECHEC blocs : " & MSG );
      end if;
    end CHECK;

  begin
    CREATE( F, OUT_FILE, "TC_TEST17.FAS" );
    PUT_LINE( F, "	include '../../src/expander/fasmg/codi_x86_64.finc'" );
    PUT_LINE( F, "STANDARD = 'STANDARD'" );
    PUT_LINE( F, "namespace STANDARD" );
    PUT_LINE( F, "  virtual at 8" );
    PUT_LINE( F, "    VARzone::" );
    PUT_LINE( F, "  end virtual" );
    PUT_LINE( F, "	LINK	0, loc_siz" );
    PUT_LINE( F, "_B17 = '_B17'" );
    PUT_LINE( F, "namespace _B17" );
    PUT_LINE( F, "VAR use__info, Q" );
    PUT_LINE( F, "BEGIN_BLOC_DEF" );
    PUT_LINE( F, "db 0, 5, ""FALSE""" );
    PUT_LINE( F, "db 1, 4, ""TRUE""" );
    PUT_LINE( F, "END_BLOC_DEF 1, 0, 1" );
    PUT_LINE( F, "	; SIZ en bits !" );
    PUT_LINE( F, "	LCA	SIZ" );
    PUT_LINE( F, "	SA	0, use__info" );
    PUT_LINE( F, "end namespace" );
    PUT_LINE( F, "	VAR	BUF17_disp, 8" );
    PUT_LINE( F, "	VAR	CP17_disp, Q" );
    PUT_LINE( F, "	LA	0, _B17.use__info" );
    PUT_LINE( F, "	ULD	, 0" );
    PUT_LINE( F, "	LI	1" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k17_3" );
    PUT_LINE( F, "	SYS_EXIT	3" );
    PUT_LINE( F, "k17_3:" );
    PUT_LINE( F, "	LA	0, _B17.use__info" );
    PUT_LINE( F, "	LQ	, 16" );
    PUT_LINE( F, "	SA	0, CP17_disp" );
    PUT_LINE( F, "	ULIB	0, CP17_disp, 2" );
    PUT_LINE( F, "	LI	70" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k17_4" );
    PUT_LINE( F, "	SYS_EXIT	4" );
    PUT_LINE( F, "k17_4:" );
    PUT_LINE( F, "	LVA	0, BUF17_disp" );
    PUT_LINE( F, "	LI	4" );
    PUT_LINE( F, "	LA	0, CP17_disp" );
    PUT_LINE( F, "	LI	9" );
    PUT_LINE( F, "	ADD" );
    PUT_LINE( F, "	BLKMOV" );
    PUT_LINE( F, "	ULB	0, BUF17_disp" );
    PUT_LINE( F, "	LI	84" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k17_5" );
    PUT_LINE( F, "	SYS_EXIT	5" );
    PUT_LINE( F, "k17_5:" );
    PUT_LINE( F, "	ULB	0, BUF17_disp + 3" );
    PUT_LINE( F, "	LI	69" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k17_6" );
    PUT_LINE( F, "	SYS_EXIT	6" );
    PUT_LINE( F, "k17_6:" );
    PUT_LINE( F, "	LI	24" );
    PUT_LINE( F, "	CO_VAR" );
    PUT_LINE( F, "	SA	0, CP17_disp" );
    PUT_LINE( F, "	LI	77" );
    PUT_LINE( F, "	SIB	0, CP17_disp, 5" );
    PUT_LINE( F, "	ULIB	0, CP17_disp, 5" );
    PUT_LINE( F, "	LI	77" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k17_7" );
    PUT_LINE( F, "	SYS_EXIT	7" );
    PUT_LINE( F, "k17_7:" );
    PUT_LINE( F, "	SYS_EXIT	0" );
    PUT_LINE( F, " virtual VARzone" );
    PUT_LINE( F, "   loc_siz = $" );
    PUT_LINE( F, "  end virtual" );
    PUT_LINE( F, "end namespace" );
    CLOSE( F );

    FROM17 := IR.ELT_ID( IR.ELT_COUNT + 1 );
    RUN_P0( "TC_TEST17.FAS" );
    PASSES.P1_REACH;
    PASSES.P2_LAYOUT( FROM17, IR.ELT_ID( IR.ELT_COUNT ) );
    EMITS.P2B_ADDRESSES( FROM17, IR.ELT_ID( IR.ELT_COUNT ) );
    EMITS.P3_EMIT( FROM17, IR.ELT_ID( IR.ELT_COUNT ), "TC_TEST17.BIN" );

    CHECK( VALUE_OF( RESOLVE( "STANDARD._B17.SIZ" ) ) mod 8 = 0,
	   "SIZ aligne qword (align_q inline)" );
    CHECK( VALUE_OF( RESOLVE( "STANDARD._B17.IMAGES.data_end" ) )
	     - VALUE_OF( RESOLVE( "STANDARD._B17.IMAGES.data" ) ) = 13,
	   "treize octets d'images (7 + 6)" );
    CHECK( VALUE_OF( RESOLVE( "STANDARD.loc_siz" ) ) = 32,
	   "layout niveau 0 (use__info 8, BUF17 16, CP17 24 : loc_siz 32)" );

    if OK
    then
      PUT_LINE( "PASSE blocs" );
      PUT_LINE( "TC_TEST17.BIN ecrit - oracle externe :" );
      PUT_LINE( "  fasmg TC_TEST17.FAS TC_REF17 && cmp TC_REF17 TC_TEST17.BIN" );
      PUT_LINE( "  chmod +x TC_TEST17.BIN && ./TC_TEST17.BIN ; echo $?   (attendu : 0)" );
    end if;
  end;


  --|  TEMOIN TEMPORAIRE COMPLETION (TC-21) - la table entiere du codi
  --|  sous verdict d'execution : mots signes/non signes (LW/ULW/LIW/
  --|  ULIW/LIB/SIW), alu (OU/NON/SHR/SAR/ABS), champs de bits (UBFX/
  --|  SBFX/BFI), flottants (FABS/FEXP/FCEQ/FCLE), CVTXI, familles
  --|  BLK* et LEXCMP (trois cas 4.5.2), horloge et fichiers de bout
  --|  en bout (CREATE/WRITE/GET_POS/SET_POS/GET_SIZE/CLOSE/DELETE).
  --|  Verdicts : 0 = tout bon ; 3..33 = etape fautive. A RETIRER.
  declare
    use LEX;
    use SYMBOLS;
    use IR;
    OK			: BOOLEAN	:= TRUE;
    F			: FILE_TYPE;
    FROM21		: IR.ELT_ID;

    procedure CHECK ( COND :BOOLEAN; MSG :STRING )
    is
    begin
      if not COND
      then
	OK := FALSE;
	PUT_LINE( "ECHEC completion : " & MSG );
      end if;
    end CHECK;

  begin
    CREATE( F, OUT_FILE, "TC_TEST21.FAS" );
    PUT_LINE( F, "	include '../../src/expander/fasmg/codi_x86_64.finc'" );
    PUT_LINE( F, "STANDARD = 'STANDARD'" );
    PUT_LINE( F, "namespace STANDARD" );
    PUT_LINE( F, "  virtual at 8" );
    PUT_LINE( F, "    VARzone::" );
    PUT_LINE( F, "  end virtual" );
    PUT_LINE( F, "	LINK	0, loc_siz" );
    PUT_LINE( F, "	VAR	W21_disp, W" );
    PUT_LINE( F, "	VAR	P21_disp, Q" );
    PUT_LINE( F, "	VAR	BLA21_disp, 8" );
    PUT_LINE( F, "	VAR	BLB21_disp, 8" );
    PUT_LINE( F, "	VAR	FID21_disp, Q" );
    PUT_LINE( F, "	VAR	TS21_disp, 16" );
    PUT_LINE( F, "	STR	T21NM, 't21.tmp'" );
    PUT_LINE( F, "; ---- mots signes / non signes ----" );
    PUT_LINE( F, "	LVA	0, W21_disp" );
    PUT_LINE( F, "	SA	0, P21_disp" );
    PUT_LINE( F, "	LI	-2" );
    PUT_LINE( F, "	SW	0, W21_disp" );
    PUT_LINE( F, "	LW	0, W21_disp" );
    PUT_LINE( F, "	LI	-2" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k21_3" );
    PUT_LINE( F, "	SYS_EXIT	3" );
    PUT_LINE( F, "k21_3:" );
    PUT_LINE( F, "	ULW	0, W21_disp" );
    PUT_LINE( F, "	LI	65534" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k21_4" );
    PUT_LINE( F, "	SYS_EXIT	4" );
    PUT_LINE( F, "k21_4:" );
    PUT_LINE( F, "	LIW	0, P21_disp, 0" );
    PUT_LINE( F, "	LI	-2" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k21_5" );
    PUT_LINE( F, "	SYS_EXIT	5" );
    PUT_LINE( F, "k21_5:" );
    PUT_LINE( F, "	ULIW	0, P21_disp, 0" );
    PUT_LINE( F, "	LI	65534" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k21_6" );
    PUT_LINE( F, "	SYS_EXIT	6" );
    PUT_LINE( F, "k21_6:" );
    PUT_LINE( F, "	LI	-5" );
    PUT_LINE( F, "	SIB	0, P21_disp, 0" );
    PUT_LINE( F, "	LIB	0, P21_disp, 0" );
    PUT_LINE( F, "	LI	-5" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k21_7" );
    PUT_LINE( F, "	SYS_EXIT	7" );
    PUT_LINE( F, "k21_7:" );
    PUT_LINE( F, "	LI	-300" );
    PUT_LINE( F, "	SIW	0, P21_disp, 0" );
    PUT_LINE( F, "	LIW	0, P21_disp, 0" );
    PUT_LINE( F, "	LI	-300" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k21_8" );
    PUT_LINE( F, "	SYS_EXIT	8" );
    PUT_LINE( F, "k21_8:" );
    PUT_LINE( F, "; ---- alu ----" );
    PUT_LINE( F, "	LI	12" );
    PUT_LINE( F, "	LI	3" );
    PUT_LINE( F, "	OU" );
    PUT_LINE( F, "	LI	15" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k21_9" );
    PUT_LINE( F, "	SYS_EXIT	9" );
    PUT_LINE( F, "k21_9:" );
    PUT_LINE( F, "	LI	5" );
    PUT_LINE( F, "	NON" );
    PUT_LINE( F, "	LI	-6" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k21_10" );
    PUT_LINE( F, "	SYS_EXIT	10" );
    PUT_LINE( F, "k21_10:" );
    PUT_LINE( F, "	LI	64" );
    PUT_LINE( F, "	LI	3" );
    PUT_LINE( F, "	SHR" );
    PUT_LINE( F, "	LI	8" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k21_11" );
    PUT_LINE( F, "	SYS_EXIT	11" );
    PUT_LINE( F, "k21_11:" );
    PUT_LINE( F, "	LI	-64" );
    PUT_LINE( F, "	LI	3" );
    PUT_LINE( F, "	SAR" );
    PUT_LINE( F, "	LI	-8" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k21_12" );
    PUT_LINE( F, "	SYS_EXIT	12" );
    PUT_LINE( F, "k21_12:" );
    PUT_LINE( F, "	LI	-7" );
    PUT_LINE( F, "	ABS" );
    PUT_LINE( F, "	LI	7" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k21_13" );
    PUT_LINE( F, "	SYS_EXIT	13" );
    PUT_LINE( F, "k21_13:" );
    PUT_LINE( F, "	LI	245" );
    PUT_LINE( F, "	LI	4" );
    PUT_LINE( F, "	LI	4" );
    PUT_LINE( F, "	UBFX" );
    PUT_LINE( F, "	LI	15" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k21_14" );
    PUT_LINE( F, "	SYS_EXIT	14" );
    PUT_LINE( F, "k21_14:" );
    PUT_LINE( F, "	LI	240" );
    PUT_LINE( F, "	LI	4" );
    PUT_LINE( F, "	LI	4" );
    PUT_LINE( F, "	SBFX" );
    PUT_LINE( F, "	LI	-1" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k21_15" );
    PUT_LINE( F, "	SYS_EXIT	15" );
    PUT_LINE( F, "k21_15:" );
    PUT_LINE( F, "	LI	65535" );
    PUT_LINE( F, "	LI	0" );
    PUT_LINE( F, "	LI	4" );
    PUT_LINE( F, "	LI	4" );
    PUT_LINE( F, "	BFI" );
    PUT_LINE( F, "	LI	65295" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k21_16" );
    PUT_LINE( F, "	SYS_EXIT	16" );
    PUT_LINE( F, "k21_16:" );
    PUT_LINE( F, "; ---- flottants ----" );
    PUT_LINE( F, "	LI	-4610560118520545280" );
    PUT_LINE( F, "	FABS" );
    PUT_LINE( F, "	LI	4612811918334230528" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k21_17" );
    PUT_LINE( F, "	SYS_EXIT	17" );
    PUT_LINE( F, "k21_17:" );
    PUT_LINE( F, "	LI	4611686018427387904" );
    PUT_LINE( F, "	LI	3" );
    PUT_LINE( F, "	FEXP" );
    PUT_LINE( F, "	LI	4620693217682128896" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k21_18" );
    PUT_LINE( F, "	SYS_EXIT	18" );
    PUT_LINE( F, "k21_18:" );
    PUT_LINE( F, "	LI	7" );
    PUT_LINE( F, "	LI	1" );
    PUT_LINE( F, "	LI	2" );
    PUT_LINE( F, "	CVTXI" );
    PUT_LINE( F, "	LI	4" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k21_19" );
    PUT_LINE( F, "	SYS_EXIT	19" );
    PUT_LINE( F, "k21_19:" );
    PUT_LINE( F, "	LI	4609434218613702656" );
    PUT_LINE( F, "	LI	4609434218613702656" );
    PUT_LINE( F, "	FCEQ" );
    PUT_LINE( F, "	LI	1" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k21_20" );
    PUT_LINE( F, "	SYS_EXIT	20" );
    PUT_LINE( F, "k21_20:" );
    PUT_LINE( F, "	LI	4609434218613702656" );
    PUT_LINE( F, "	LI	4612811918334230528" );
    PUT_LINE( F, "	FCLE" );
    PUT_LINE( F, "	LI	1" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k21_21" );
    PUT_LINE( F, "	SYS_EXIT	21" );
    PUT_LINE( F, "k21_21:" );
    PUT_LINE( F, "; ---- blocs ----" );
    PUT_LINE( F, "	LI	858993459" );
    PUT_LINE( F, "	SD	0, BLA21_disp" );
    PUT_LINE( F, "	LI	252645135" );
    PUT_LINE( F, "	SD	0, BLB21_disp" );
    PUT_LINE( F, "	LVA	0, BLA21_disp" );
    PUT_LINE( F, "	LI	4" );
    PUT_LINE( F, "	LVA	0, BLB21_disp" );
    PUT_LINE( F, "	BLKAND" );
    PUT_LINE( F, "	LD	0, BLA21_disp" );
    PUT_LINE( F, "	LI	50529027" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k21_22" );
    PUT_LINE( F, "	SYS_EXIT	22" );
    PUT_LINE( F, "k21_22:" );
    PUT_LINE( F, "	LI	808464432" );
    PUT_LINE( F, "	SD	0, BLB21_disp" );
    PUT_LINE( F, "	LVA	0, BLA21_disp" );
    PUT_LINE( F, "	LI	4" );
    PUT_LINE( F, "	LVA	0, BLB21_disp" );
    PUT_LINE( F, "	BLKOU" );
    PUT_LINE( F, "	LD	0, BLA21_disp" );
    PUT_LINE( F, "	LI	858993459" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k21_23" );
    PUT_LINE( F, "	SYS_EXIT	23" );
    PUT_LINE( F, "k21_23:" );
    PUT_LINE( F, "	LVA	0, BLA21_disp" );
    PUT_LINE( F, "	LI	4" );
    PUT_LINE( F, "	LVA	0, BLB21_disp" );
    PUT_LINE( F, "	BLKOUX" );
    PUT_LINE( F, "	LD	0, BLA21_disp" );
    PUT_LINE( F, "	LI	50529027" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k21_24" );
    PUT_LINE( F, "	SYS_EXIT	24" );
    PUT_LINE( F, "k21_24:" );
    PUT_LINE( F, "	LI	65537" );
    PUT_LINE( F, "	SD	0, BLA21_disp" );
    PUT_LINE( F, "	LVA	0, BLA21_disp" );
    PUT_LINE( F, "	LI	4" );
    PUT_LINE( F, "	BLKNOT" );
    PUT_LINE( F, "	LD	0, BLA21_disp" );
    PUT_LINE( F, "	LI	16777472" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k21_25" );
    PUT_LINE( F, "	SYS_EXIT	25" );
    PUT_LINE( F, "k21_25:" );
    PUT_LINE( F, "; ---- lexicographique ----" );
    PUT_LINE( F, "	LI	4408897" );
    PUT_LINE( F, "	SD	0, BLA21_disp" );
    PUT_LINE( F, "	LI	4474433" );
    PUT_LINE( F, "	SD	0, BLB21_disp" );
    PUT_LINE( F, "	LVA	0, BLA21_disp" );
    PUT_LINE( F, "	LI	3" );
    PUT_LINE( F, "	LVA	0, BLB21_disp" );
    PUT_LINE( F, "	LI	3" );
    PUT_LINE( F, "	LEXCMP 1, 0" );
    PUT_LINE( F, "	LI	-1" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k21_26" );
    PUT_LINE( F, "	SYS_EXIT	26" );
    PUT_LINE( F, "k21_26:" );
    PUT_LINE( F, "	LVA	0, BLA21_disp" );
    PUT_LINE( F, "	LI	2" );
    PUT_LINE( F, "	LVA	0, BLB21_disp" );
    PUT_LINE( F, "	LI	3" );
    PUT_LINE( F, "	LEXCMP 1, 0" );
    PUT_LINE( F, "	LI	-1" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k21_27" );
    PUT_LINE( F, "	SYS_EXIT	27" );
    PUT_LINE( F, "k21_27:" );
    PUT_LINE( F, "	LI	4408897" );
    PUT_LINE( F, "	SD	0, BLB21_disp" );
    PUT_LINE( F, "	LVA	0, BLA21_disp" );
    PUT_LINE( F, "	LI	3" );
    PUT_LINE( F, "	LVA	0, BLB21_disp" );
    PUT_LINE( F, "	LI	3" );
    PUT_LINE( F, "	LEXCMP 1, 0" );
    PUT_LINE( F, "	LI	0" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k21_28" );
    PUT_LINE( F, "	SYS_EXIT	28" );
    PUT_LINE( F, "k21_28:" );
    PUT_LINE( F, "; ---- fichiers de bout en bout ----" );
    PUT_LINE( F, "	LI	0" );
    PUT_LINE( F, "	LCA	T21NM.data_ptr" );
    PUT_LINE( F, "	SYS_FILE_CREATE" );
    PUT_LINE( F, "	SA	0, FID21_disp" );
    PUT_LINE( F, "	LI	0" );
    PUT_LINE( F, "	LI	4" );
    PUT_LINE( F, "	LVA	0, BLA21_disp" );
    PUT_LINE( F, "	LA	0, FID21_disp" );
    PUT_LINE( F, "	SYS_FILE_WRITE" );
    PUT_LINE( F, "	LI	4" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k21_29" );
    PUT_LINE( F, "	SYS_EXIT	29" );
    PUT_LINE( F, "k21_29:" );
    PUT_LINE( F, "	LI	0" );
    PUT_LINE( F, "	LA	0, FID21_disp" );
    PUT_LINE( F, "	SYS_FILE_GET_POS" );
    PUT_LINE( F, "	LI	4" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k21_30" );
    PUT_LINE( F, "	SYS_EXIT	30" );
    PUT_LINE( F, "k21_30:" );
    PUT_LINE( F, "	LI	0" );
    PUT_LINE( F, "	LI	2" );
    PUT_LINE( F, "	LA	0, FID21_disp" );
    PUT_LINE( F, "	SYS_FILE_SET_POS" );
    PUT_LINE( F, "	LI	2" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k21_31" );
    PUT_LINE( F, "	SYS_EXIT	31" );
    PUT_LINE( F, "k21_31:" );
    PUT_LINE( F, "	LI	0" );
    PUT_LINE( F, "	LA	0, FID21_disp" );
    PUT_LINE( F, "	SYS_FILE_GET_SIZE" );
    PUT_LINE( F, "	LI	4" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k21_32" );
    PUT_LINE( F, "	SYS_EXIT	32" );
    PUT_LINE( F, "k21_32:" );
    PUT_LINE( F, "	LI	0" );
    PUT_LINE( F, "	LA	0, FID21_disp" );
    PUT_LINE( F, "	SYS_FILE_CLOSE" );
    PUT_LINE( F, "	DROP" );
    PUT_LINE( F, "	LI	0" );
    PUT_LINE( F, "	LCA	T21NM.data_ptr" );
    PUT_LINE( F, "	SYS_FILE_DELETE" );
    PUT_LINE( F, "	DROP" );
    PUT_LINE( F, "; ---- horloge ----" );
    PUT_LINE( F, "	LVA	0, TS21_disp" );
    PUT_LINE( F, "	SYS_CLOCK_GETTIME" );
    PUT_LINE( F, "	LQ	0, TS21_disp" );
    PUT_LINE( F, "	LI	1600000000" );
    PUT_LINE( F, "	CGT" );
    PUT_LINE( F, "	BT	k21_33" );
    PUT_LINE( F, "	SYS_EXIT	33" );
    PUT_LINE( F, "k21_33:" );
    PUT_LINE( F, "	SYS_EXIT	0" );
    PUT_LINE( F, " virtual VARzone" );
    PUT_LINE( F, "   loc_siz = $" );
    PUT_LINE( F, "  end virtual" );
    PUT_LINE( F, "end namespace" );
    CLOSE( F );

    FROM21 := IR.ELT_ID( IR.ELT_COUNT + 1 );
    RUN_P0( "TC_TEST21.FAS" );
    PASSES.P1_REACH;
    PASSES.P2_LAYOUT( FROM21, IR.ELT_ID( IR.ELT_COUNT ) );
    EMITS.P2B_ADDRESSES( FROM21, IR.ELT_ID( IR.ELT_COUNT ) );
    EMITS.P3_EMIT( FROM21, IR.ELT_ID( IR.ELT_COUNT ), "TC_TEST21.BIN" );

    CHECK( VALUE_OF( RESOLVE( "STANDARD.loc_siz" ) ) = 64,
	   "layout 0 (W21 8, P21 16, BLA 24, BLB 32, FID 40, TS 48 : 64)" );

    if OK
    then
      PUT_LINE( "PASSE completion" );
      PUT_LINE( "TC_TEST21.BIN ecrit - oracle externe :" );
      PUT_LINE( "  fasmg TC_TEST21.FAS TC_REF21 && cmp TC_REF21 TC_TEST21.BIN" );
      PUT_LINE( "  chmod +x TC_TEST21.BIN && ./TC_TEST21.BIN ; echo $?   (attendu : 0)" );
    end if;
  end;


  --|  TEMOIN TC-ARM21 : jumeau arm64 de TC_TEST21 - le MEME programme (labels
  --|  suffixes A21) : mots, alu, champs de bits, flottants, CVTXI, BLK*,
  --|  LEXCMP, horloge, fichiers de bout en bout. Verdict par code de sortie.

  TARGET_CPU := ARM64;
  declare
    use LEX, SYMBOLS, IR;
    OK			: BOOLEAN	:= TRUE;
    F			: FILE_TYPE;
    FROMA		: IR.ELT_ID;

    procedure CHECK ( COND :BOOLEAN; MSG :STRING )
    is
    begin
      if not COND
      then
	OK := FALSE;
	PUT_LINE( "ECHEC arm21 : " & MSG );
      end if;
    end CHECK;

  begin
    CREATE( F, OUT_FILE, "TC_ARM21.FAS" );
    PUT_LINE( F, "	include '../../src/expander/fasmg/codi_arm64.finc'" );
    PUT_LINE( F, "STANDARD = 'STANDARD'" );
    PUT_LINE( F, "namespace STANDARD" );
    PUT_LINE( F, "  virtual at 8" );
    PUT_LINE( F, "    VARzone::" );
    PUT_LINE( F, "  end virtual" );
    PUT_LINE( F, "	LINK	0, loc_siz" );
    PUT_LINE( F, "	VAR	WA21_disp, W" );
    PUT_LINE( F, "	VAR	PA21_disp, Q" );
    PUT_LINE( F, "	VAR	BLAA21_disp, 8" );
    PUT_LINE( F, "	VAR	BLBA21_disp, 8" );
    PUT_LINE( F, "	VAR	FIDA21_disp, Q" );
    PUT_LINE( F, "	VAR	TSA21_disp, 16" );
    PUT_LINE( F, "	STR	TA21NM, 't21.tmp'" );
    PUT_LINE( F, "; ---- mots signes / non signes ----" );
    PUT_LINE( F, "	LVA	0, WA21_disp" );
    PUT_LINE( F, "	SA	0, PA21_disp" );
    PUT_LINE( F, "	LI	-2" );
    PUT_LINE( F, "	SW	0, WA21_disp" );
    PUT_LINE( F, "	LW	0, WA21_disp" );
    PUT_LINE( F, "	LI	-2" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	kA21_3" );
    PUT_LINE( F, "	SYS_EXIT	3" );
    PUT_LINE( F, "kA21_3:" );
    PUT_LINE( F, "	ULW	0, WA21_disp" );
    PUT_LINE( F, "	LI	65534" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	kA21_4" );
    PUT_LINE( F, "	SYS_EXIT	4" );
    PUT_LINE( F, "kA21_4:" );
    PUT_LINE( F, "	LIW	0, PA21_disp, 0" );
    PUT_LINE( F, "	LI	-2" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	kA21_5" );
    PUT_LINE( F, "	SYS_EXIT	5" );
    PUT_LINE( F, "kA21_5:" );
    PUT_LINE( F, "	ULIW	0, PA21_disp, 0" );
    PUT_LINE( F, "	LI	65534" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	kA21_6" );
    PUT_LINE( F, "	SYS_EXIT	6" );
    PUT_LINE( F, "kA21_6:" );
    PUT_LINE( F, "	LI	-5" );
    PUT_LINE( F, "	SIB	0, PA21_disp, 0" );
    PUT_LINE( F, "	LIB	0, PA21_disp, 0" );
    PUT_LINE( F, "	LI	-5" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	kA21_7" );
    PUT_LINE( F, "	SYS_EXIT	7" );
    PUT_LINE( F, "kA21_7:" );
    PUT_LINE( F, "	LI	-300" );
    PUT_LINE( F, "	SIW	0, PA21_disp, 0" );
    PUT_LINE( F, "	LIW	0, PA21_disp, 0" );
    PUT_LINE( F, "	LI	-300" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	kA21_8" );
    PUT_LINE( F, "	SYS_EXIT	8" );
    PUT_LINE( F, "kA21_8:" );
    PUT_LINE( F, "; ---- alu ----" );
    PUT_LINE( F, "	LI	12" );
    PUT_LINE( F, "	LI	3" );
    PUT_LINE( F, "	OU" );
    PUT_LINE( F, "	LI	15" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	kA21_9" );
    PUT_LINE( F, "	SYS_EXIT	9" );
    PUT_LINE( F, "kA21_9:" );
    PUT_LINE( F, "	LI	5" );
    PUT_LINE( F, "	NON" );
    PUT_LINE( F, "	LI	-6" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	kA21_10" );
    PUT_LINE( F, "	SYS_EXIT	10" );
    PUT_LINE( F, "kA21_10:" );
    PUT_LINE( F, "	LI	64" );
    PUT_LINE( F, "	LI	3" );
    PUT_LINE( F, "	SHR" );
    PUT_LINE( F, "	LI	8" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	kA21_11" );
    PUT_LINE( F, "	SYS_EXIT	11" );
    PUT_LINE( F, "kA21_11:" );
    PUT_LINE( F, "	LI	-64" );
    PUT_LINE( F, "	LI	3" );
    PUT_LINE( F, "	SAR" );
    PUT_LINE( F, "	LI	-8" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	kA21_12" );
    PUT_LINE( F, "	SYS_EXIT	12" );
    PUT_LINE( F, "kA21_12:" );
    PUT_LINE( F, "	LI	-7" );
    PUT_LINE( F, "	ABS" );
    PUT_LINE( F, "	LI	7" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	kA21_13" );
    PUT_LINE( F, "	SYS_EXIT	13" );
    PUT_LINE( F, "kA21_13:" );
    PUT_LINE( F, "	LI	245" );
    PUT_LINE( F, "	LI	4" );
    PUT_LINE( F, "	LI	4" );
    PUT_LINE( F, "	UBFX" );
    PUT_LINE( F, "	LI	15" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	kA21_14" );
    PUT_LINE( F, "	SYS_EXIT	14" );
    PUT_LINE( F, "kA21_14:" );
    PUT_LINE( F, "	LI	240" );
    PUT_LINE( F, "	LI	4" );
    PUT_LINE( F, "	LI	4" );
    PUT_LINE( F, "	SBFX" );
    PUT_LINE( F, "	LI	-1" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	kA21_15" );
    PUT_LINE( F, "	SYS_EXIT	15" );
    PUT_LINE( F, "kA21_15:" );
    PUT_LINE( F, "	LI	65535" );
    PUT_LINE( F, "	LI	0" );
    PUT_LINE( F, "	LI	4" );
    PUT_LINE( F, "	LI	4" );
    PUT_LINE( F, "	BFI" );
    PUT_LINE( F, "	LI	65295" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	kA21_16" );
    PUT_LINE( F, "	SYS_EXIT	16" );
    PUT_LINE( F, "kA21_16:" );
    PUT_LINE( F, "; ---- flottants ----" );
    PUT_LINE( F, "	LI	-4610560118520545280" );
    PUT_LINE( F, "	FABS" );
    PUT_LINE( F, "	LI	4612811918334230528" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	kA21_17" );
    PUT_LINE( F, "	SYS_EXIT	17" );
    PUT_LINE( F, "kA21_17:" );
    PUT_LINE( F, "	LI	4611686018427387904" );
    PUT_LINE( F, "	LI	3" );
    PUT_LINE( F, "	FEXP" );
    PUT_LINE( F, "	LI	4620693217682128896" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	kA21_18" );
    PUT_LINE( F, "	SYS_EXIT	18" );
    PUT_LINE( F, "kA21_18:" );
    PUT_LINE( F, "	LI	7" );
    PUT_LINE( F, "	LI	1" );
    PUT_LINE( F, "	LI	2" );
    PUT_LINE( F, "	CVTXI" );
    PUT_LINE( F, "	LI	4" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	kA21_19" );
    PUT_LINE( F, "	SYS_EXIT	19" );
    PUT_LINE( F, "kA21_19:" );
    PUT_LINE( F, "	LI	4609434218613702656" );
    PUT_LINE( F, "	LI	4609434218613702656" );
    PUT_LINE( F, "	FCEQ" );
    PUT_LINE( F, "	LI	1" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	kA21_20" );
    PUT_LINE( F, "	SYS_EXIT	20" );
    PUT_LINE( F, "kA21_20:" );
    PUT_LINE( F, "	LI	4609434218613702656" );
    PUT_LINE( F, "	LI	4612811918334230528" );
    PUT_LINE( F, "	FCLE" );
    PUT_LINE( F, "	LI	1" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	kA21_21" );
    PUT_LINE( F, "	SYS_EXIT	21" );
    PUT_LINE( F, "kA21_21:" );
    PUT_LINE( F, "; ---- blocs ----" );
    PUT_LINE( F, "	LI	858993459" );
    PUT_LINE( F, "	SD	0, BLAA21_disp" );
    PUT_LINE( F, "	LI	252645135" );
    PUT_LINE( F, "	SD	0, BLBA21_disp" );
    PUT_LINE( F, "	LVA	0, BLAA21_disp" );
    PUT_LINE( F, "	LI	4" );
    PUT_LINE( F, "	LVA	0, BLBA21_disp" );
    PUT_LINE( F, "	BLKAND" );
    PUT_LINE( F, "	LD	0, BLAA21_disp" );
    PUT_LINE( F, "	LI	50529027" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	kA21_22" );
    PUT_LINE( F, "	SYS_EXIT	22" );
    PUT_LINE( F, "kA21_22:" );
    PUT_LINE( F, "	LI	808464432" );
    PUT_LINE( F, "	SD	0, BLBA21_disp" );
    PUT_LINE( F, "	LVA	0, BLAA21_disp" );
    PUT_LINE( F, "	LI	4" );
    PUT_LINE( F, "	LVA	0, BLBA21_disp" );
    PUT_LINE( F, "	BLKOU" );
    PUT_LINE( F, "	LD	0, BLAA21_disp" );
    PUT_LINE( F, "	LI	858993459" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	kA21_23" );
    PUT_LINE( F, "	SYS_EXIT	23" );
    PUT_LINE( F, "kA21_23:" );
    PUT_LINE( F, "	LVA	0, BLAA21_disp" );
    PUT_LINE( F, "	LI	4" );
    PUT_LINE( F, "	LVA	0, BLBA21_disp" );
    PUT_LINE( F, "	BLKOUX" );
    PUT_LINE( F, "	LD	0, BLAA21_disp" );
    PUT_LINE( F, "	LI	50529027" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	kA21_24" );
    PUT_LINE( F, "	SYS_EXIT	24" );
    PUT_LINE( F, "kA21_24:" );
    PUT_LINE( F, "	LI	65537" );
    PUT_LINE( F, "	SD	0, BLAA21_disp" );
    PUT_LINE( F, "	LVA	0, BLAA21_disp" );
    PUT_LINE( F, "	LI	4" );
    PUT_LINE( F, "	BLKNOT" );
    PUT_LINE( F, "	LD	0, BLAA21_disp" );
    PUT_LINE( F, "	LI	16777472" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	kA21_25" );
    PUT_LINE( F, "	SYS_EXIT	25" );
    PUT_LINE( F, "kA21_25:" );
    PUT_LINE( F, "; ---- lexicographique ----" );
    PUT_LINE( F, "	LI	4408897" );
    PUT_LINE( F, "	SD	0, BLAA21_disp" );
    PUT_LINE( F, "	LI	4474433" );
    PUT_LINE( F, "	SD	0, BLBA21_disp" );
    PUT_LINE( F, "	LVA	0, BLAA21_disp" );
    PUT_LINE( F, "	LI	3" );
    PUT_LINE( F, "	LVA	0, BLBA21_disp" );
    PUT_LINE( F, "	LI	3" );
    PUT_LINE( F, "	LEXCMP 1, 0" );
    PUT_LINE( F, "	LI	-1" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	kA21_26" );
    PUT_LINE( F, "	SYS_EXIT	26" );
    PUT_LINE( F, "kA21_26:" );
    PUT_LINE( F, "	LVA	0, BLAA21_disp" );
    PUT_LINE( F, "	LI	2" );
    PUT_LINE( F, "	LVA	0, BLBA21_disp" );
    PUT_LINE( F, "	LI	3" );
    PUT_LINE( F, "	LEXCMP 1, 0" );
    PUT_LINE( F, "	LI	-1" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	kA21_27" );
    PUT_LINE( F, "	SYS_EXIT	27" );
    PUT_LINE( F, "kA21_27:" );
    PUT_LINE( F, "	LI	4408897" );
    PUT_LINE( F, "	SD	0, BLBA21_disp" );
    PUT_LINE( F, "	LVA	0, BLAA21_disp" );
    PUT_LINE( F, "	LI	3" );
    PUT_LINE( F, "	LVA	0, BLBA21_disp" );
    PUT_LINE( F, "	LI	3" );
    PUT_LINE( F, "	LEXCMP 1, 0" );
    PUT_LINE( F, "	LI	0" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	kA21_28" );
    PUT_LINE( F, "	SYS_EXIT	28" );
    PUT_LINE( F, "kA21_28:" );
    PUT_LINE( F, "; ---- fichiers de bout en bout ----" );
    PUT_LINE( F, "	LI	0" );
    PUT_LINE( F, "	LCA	TA21NM.data_ptr" );
    PUT_LINE( F, "	SYS_FILE_CREATE" );
    PUT_LINE( F, "	SA	0, FIDA21_disp" );
    PUT_LINE( F, "	LI	0" );
    PUT_LINE( F, "	LI	4" );
    PUT_LINE( F, "	LVA	0, BLAA21_disp" );
    PUT_LINE( F, "	LA	0, FIDA21_disp" );
    PUT_LINE( F, "	SYS_FILE_WRITE" );
    PUT_LINE( F, "	LI	4" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	kA21_29" );
    PUT_LINE( F, "	SYS_EXIT	29" );
    PUT_LINE( F, "kA21_29:" );
    PUT_LINE( F, "	LI	0" );
    PUT_LINE( F, "	LA	0, FIDA21_disp" );
    PUT_LINE( F, "	SYS_FILE_GET_POS" );
    PUT_LINE( F, "	LI	4" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	kA21_30" );
    PUT_LINE( F, "	SYS_EXIT	30" );
    PUT_LINE( F, "kA21_30:" );
    PUT_LINE( F, "	LI	0" );
    PUT_LINE( F, "	LI	2" );
    PUT_LINE( F, "	LA	0, FIDA21_disp" );
    PUT_LINE( F, "	SYS_FILE_SET_POS" );
    PUT_LINE( F, "	LI	2" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	kA21_31" );
    PUT_LINE( F, "	SYS_EXIT	31" );
    PUT_LINE( F, "kA21_31:" );
    PUT_LINE( F, "	LI	0" );
    PUT_LINE( F, "	LA	0, FIDA21_disp" );
    PUT_LINE( F, "	SYS_FILE_GET_SIZE" );
    PUT_LINE( F, "	LI	4" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	kA21_32" );
    PUT_LINE( F, "	SYS_EXIT	32" );
    PUT_LINE( F, "kA21_32:" );
    PUT_LINE( F, "	LI	0" );
    PUT_LINE( F, "	LA	0, FIDA21_disp" );
    PUT_LINE( F, "	SYS_FILE_CLOSE" );
    PUT_LINE( F, "	DROP" );
    PUT_LINE( F, "	LI	0" );
    PUT_LINE( F, "	LCA	TA21NM.data_ptr" );
    PUT_LINE( F, "	SYS_FILE_DELETE" );
    PUT_LINE( F, "	DROP" );
    PUT_LINE( F, "; ---- horloge ----" );
    PUT_LINE( F, "	LVA	0, TSA21_disp" );
    PUT_LINE( F, "	SYS_CLOCK_GETTIME" );
    PUT_LINE( F, "	LQ	0, TSA21_disp" );
    PUT_LINE( F, "	LI	1600000000" );
    PUT_LINE( F, "	CGT" );
    PUT_LINE( F, "	BT	kA21_33" );
    PUT_LINE( F, "	SYS_EXIT	33" );
    PUT_LINE( F, "kA21_33:" );
    PUT_LINE( F, "	SYS_EXIT	0" );
    PUT_LINE( F, " virtual VARzone" );
    PUT_LINE( F, "   loc_siz = $" );
    PUT_LINE( F, "  end virtual" );
    PUT_LINE( F, "end namespace" );
    CLOSE( F );

    FROMA := IR.ELT_ID( IR.ELT_COUNT + 1 );
    RUN_P0( "TC_ARM21.FAS" );
    PASSES.P1_REACH;
    PASSES.P2_LAYOUT( FROMA, IR.ELT_ID( IR.ELT_COUNT ) );
    EMITS.P2B_ADDRESSES( FROMA, IR.ELT_ID( IR.ELT_COUNT ) );
    EMITS.P3_EMIT( FROMA, IR.ELT_ID( IR.ELT_COUNT ), "TC_ARM21.BIN" );

    CHECK( VALUE_OF( RESOLVE( "STANDARD.loc_siz" ) ) = 64,
	   "loc_siz de niveau 0 (attendu 64)" );

    if  OK  then
      PUT_LINE( "PASSE arm21" );
      PUT_LINE( "TC_ARM21.BIN ecrit - oracle externe :" );
      PUT_LINE( "  fasmg TC_ARM21.FAS TC_ARM_REF21 && cmp TC_ARM_REF21 TC_ARM21.BIN" );
      PUT_LINE( "  sur le Pi : chmod +x TC_ARM21.BIN && ./TC_ARM21.BIN ; echo $?   (attendu : 0 ; 3..33 = etape fautive ; cree puis supprime t21.tmp)" );
    end if;
  end;


  --|  TEMOIN TEMPORAIRE ENTITE UNIQUE (TC-23) - le releve ADA_COMP :
  --|  un meme nom variable ET namespace, dans les deux ordres, avec
  --|  ecritures/lectures de la variable ET de ses enfants pointes.
  --|  Verdicts : 0 = tout bon ; 3..6 = etape fautive. A RETIRER.

  TARGET_CPU := X86_64;
  declare
    use LEX;
    use SYMBOLS;
    use IR;
    OK			: BOOLEAN	:= TRUE;
    F			: FILE_TYPE;
    FROM23		: IR.ELT_ID;

    procedure CHECK ( COND :BOOLEAN; MSG :STRING )
    is
    begin
      if not COND
      then
	OK := FALSE;
	PUT_LINE( "ECHEC entite : " & MSG );
      end if;
    end CHECK;

  begin
    CREATE( F, OUT_FILE, "TC_TEST23.FAS" );
    PUT_LINE( F, "	include '../../src/expander/fasmg/codi_x86_64.finc'" );
    PUT_LINE( F, "STANDARD = 'STANDARD'" );
    PUT_LINE( F, "namespace STANDARD" );
    PUT_LINE( F, "  virtual at 8" );
    PUT_LINE( F, "    VARzone::" );
    PUT_LINE( F, "  end virtual" );
    PUT_LINE( F, "	LINK	0, loc_siz" );
    PUT_LINE( F, "; ordre 1 : namespace PUIS VAR du meme nom (le releve ADA_COMP)" );
    PUT_LINE( F, "namespace	UNI23" );
    PUT_LINE( F, "	VAR	F23_disp, D" );
    PUT_LINE( F, "end namespace" );
    PUT_LINE( F, "	VAR	UNI23, Q" );
    PUT_LINE( F, "	LI	7" );
    PUT_LINE( F, "	SA	0, UNI23" );
    PUT_LINE( F, "	LA	0, UNI23" );
    PUT_LINE( F, "	LI	7" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k23_3" );
    PUT_LINE( F, "	SYS_EXIT	3" );
    PUT_LINE( F, "k23_3:" );
    PUT_LINE( F, "	LI	5" );
    PUT_LINE( F, "	SD	0, UNI23.F23_disp" );
    PUT_LINE( F, "	LD	0, UNI23.F23_disp" );
    PUT_LINE( F, "	LI	5" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k23_4" );
    PUT_LINE( F, "	SYS_EXIT	4" );
    PUT_LINE( F, "k23_4:" );
    PUT_LINE( F, "; ordre 2 : VAR PUIS namespace du meme nom" );
    PUT_LINE( F, "	VAR	REV23_disp, Q" );
    PUT_LINE( F, "namespace	REV23_disp" );
    PUT_LINE( F, "	VAR	G23_disp, D" );
    PUT_LINE( F, "end namespace" );
    PUT_LINE( F, "	LI	9" );
    PUT_LINE( F, "	SA	0, REV23_disp" );
    PUT_LINE( F, "	LA	0, REV23_disp" );
    PUT_LINE( F, "	LI	9" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k23_5" );
    PUT_LINE( F, "	SYS_EXIT	5" );
    PUT_LINE( F, "k23_5:" );
    PUT_LINE( F, "	LI	11" );
    PUT_LINE( F, "	SD	0, REV23_disp.G23_disp" );
    PUT_LINE( F, "	LD	0, REV23_disp.G23_disp" );
    PUT_LINE( F, "	LI	11" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k23_6" );
    PUT_LINE( F, "	SYS_EXIT	6" );
    PUT_LINE( F, "k23_6:" );
    PUT_LINE( F, "	SYS_EXIT	0" );
    PUT_LINE( F, " virtual VARzone" );
    PUT_LINE( F, "   loc_siz = $" );
    PUT_LINE( F, "  end virtual" );
    PUT_LINE( F, "end namespace" );
    CLOSE( F );

    FROM23 := IR.ELT_ID( IR.ELT_COUNT + 1 );
    RUN_P0( "TC_TEST23.FAS" );
    PASSES.P1_REACH;
    PASSES.P2_LAYOUT( FROM23, IR.ELT_ID( IR.ELT_COUNT ) );
    EMITS.P2B_ADDRESSES( FROM23, IR.ELT_ID( IR.ELT_COUNT ) );
    EMITS.P3_EMIT( FROM23, IR.ELT_ID( IR.ELT_COUNT ), "TC_TEST23.BIN" );

    CHECK( VALUE_OF( RESOLVE( "STANDARD.UNI23" ) ) = 16
	   and then VALUE_OF( RESOLVE( "STANDARD.UNI23.F23_disp" ) ) = 8,
	   "unification ordre namespace-puis-VAR (offsets 16 et 8)" );
    CHECK( VALUE_OF( RESOLVE( "STANDARD.REV23_disp" ) ) = 24
	   and then VALUE_OF( RESOLVE( "STANDARD.REV23_disp.G23_disp" ) ) = 32,
	   "attachement ordre VAR-puis-namespace (offsets 24 et 32)" );

    if OK
    then
      PUT_LINE( "PASSE entite" );
      PUT_LINE( "TC_TEST23.BIN ecrit - oracle externe :" );
      PUT_LINE( "  fasmg TC_TEST23.FAS TC_REF23 && cmp TC_REF23 TC_TEST23.BIN" );
      PUT_LINE( "  chmod +x TC_TEST23.BIN && ./TC_TEST23.BIN ; echo $?   (attendu : 0)" );
    end if;
  end;


  --|  TEMOIN TEMPORAIRE REDEFINITION (TC-24) - le releve ADA_COMP :
  --|  VAR GFP24 defini, reference, REDEFINI, re-reference ; les deux
  --|  emplacements coexistent et gardent chacun leur valeur (5 et 9).
  --|  L'arbitre de la temporalite est le cmp fasmg.
  --|  Verdicts : 0 = tout bon ; 3..5 = etape fautive. A RETIRER.
  declare
    use LEX;
    use SYMBOLS;
    use IR;
    OK			: BOOLEAN	:= TRUE;
    F			: FILE_TYPE;
    FROM24		: IR.ELT_ID;

    procedure CHECK ( COND :BOOLEAN; MSG :STRING )
    is
    begin
      if not COND
      then
	OK := FALSE;
	PUT_LINE( "ECHEC redef : " & MSG );
      end if;
    end CHECK;

  begin
    CREATE( F, OUT_FILE, "TC_TEST24.FAS" );
    PUT_LINE( F, "	include '../../src/expander/fasmg/codi_x86_64.finc'" );
    PUT_LINE( F, "STANDARD = 'STANDARD'" );
    PUT_LINE( F, "namespace STANDARD" );
    PUT_LINE( F, "  virtual at 8" );
    PUT_LINE( F, "    VARzone::" );
    PUT_LINE( F, "  end virtual" );
    PUT_LINE( F, "	LINK	0, loc_siz" );
    PUT_LINE( F, "	VAR	P24A_disp, Q" );
    PUT_LINE( F, "	VAR	P24B_disp, Q" );
    PUT_LINE( F, "; premiere definition et reference AVANT redefinition" );
    PUT_LINE( F, "	VAR	GFP24_disp, Q" );
    PUT_LINE( F, "	LVA	0, GFP24_disp" );
    PUT_LINE( F, "	SA	0, P24A_disp" );
    PUT_LINE( F, "	LI	5" );
    PUT_LINE( F, "	SD	0, GFP24_disp" );
    PUT_LINE( F, "; redefinition sequentielle (name = $) et references APRES" );
    PUT_LINE( F, "	VAR	GFP24_disp, Q" );
    PUT_LINE( F, "	LVA	0, GFP24_disp" );
    PUT_LINE( F, "	SA	0, P24B_disp" );
    PUT_LINE( F, "	LI	9" );
    PUT_LINE( F, "	SD	0, GFP24_disp" );
    PUT_LINE( F, "; les deux emplacements sont DISTINCTS et gardent chacun leur valeur" );
    PUT_LINE( F, "	LA	0, P24A_disp" );
    PUT_LINE( F, "	LA	0, P24B_disp" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BF	k24_3" );
    PUT_LINE( F, "	SYS_EXIT	3" );
    PUT_LINE( F, "k24_3:" );
    PUT_LINE( F, "	LID	0, P24A_disp, 0" );
    PUT_LINE( F, "	LI	5" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k24_4" );
    PUT_LINE( F, "	SYS_EXIT	4" );
    PUT_LINE( F, "k24_4:" );
    PUT_LINE( F, "	LID	0, P24B_disp, 0" );
    PUT_LINE( F, "	LI	9" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k24_5" );
    PUT_LINE( F, "	SYS_EXIT	5" );
    PUT_LINE( F, "k24_5:" );
    PUT_LINE( F, "	SYS_EXIT	0" );
    PUT_LINE( F, " virtual VARzone" );
    PUT_LINE( F, "   loc_siz = $" );
    PUT_LINE( F, "  end virtual" );
    PUT_LINE( F, "end namespace" );
    CLOSE( F );

    FROM24 := IR.ELT_ID( IR.ELT_COUNT + 1 );
    RUN_P0( "TC_TEST24.FAS" );
    PASSES.P1_REACH;
    PASSES.P2_LAYOUT( FROM24, IR.ELT_ID( IR.ELT_COUNT ) );
    EMITS.P2B_ADDRESSES( FROM24, IR.ELT_ID( IR.ELT_COUNT ) );
    EMITS.P3_EMIT( FROM24, IR.ELT_ID( IR.ELT_COUNT ), "TC_TEST24.BIN" );

    CHECK( VALUE_OF( RESOLVE( "STANDARD.GFP24_disp" ) ) = 32,
	   "hors boucle : la redefinition la plus recente (32)" );
    SET_EPOCH( NATURAL( FROM24 ) );
    CHECK( VALUE_OF( RESOLVE( "STANDARD.GFP24_disp" ) ) = 24,
	   "a l'epoque d'avant la redefinition : l'originale (24)" );
    SET_EPOCH( NATURAL'LAST );

    if OK
    then
      PUT_LINE( "PASSE redef" );
      PUT_LINE( "TC_TEST24.BIN ecrit - oracle externe :" );
      PUT_LINE( "  fasmg TC_TEST24.FAS TC_REF24 && cmp TC_REF24 TC_TEST24.BIN" );
      PUT_LINE( "  chmod +x TC_TEST24.BIN && ./TC_TEST24.BIN ; echo $?   (attendu : 0)" );
    end if;
  end;


  --|  TEMOIN TEMPORAIRE rq (TC-25) - record manuel en zone virtual :
  --|  rq 2 avance de 16, rd 1 de 4, verifies par differences de
  --|  positions en verdicts executes. Verdicts : 0 ; 3..4. A RETIRER.
  declare
    use LEX;
    use SYMBOLS;
    use IR;
    OK			: BOOLEAN	:= TRUE;
    F			: FILE_TYPE;
    FROM25		: IR.ELT_ID;

    procedure CHECK ( COND :BOOLEAN; MSG :STRING )
    is
    begin
      if not COND
      then
	OK := FALSE;
	PUT_LINE( "ECHEC rq : " & MSG );
      end if;
    end CHECK;

  begin
    CREATE( F, OUT_FILE, "TC_TEST25.FAS" );
    PUT_LINE( F, "	include '../../src/expander/fasmg/codi_x86_64.finc'" );
    PUT_LINE( F, "STANDARD = 'STANDARD'" );
    PUT_LINE( F, "namespace STANDARD" );
    PUT_LINE( F, "  virtual at 8" );
    PUT_LINE( F, "    VARzone::" );
    PUT_LINE( F, "  end virtual" );
    PUT_LINE( F, "	LINK	0, loc_siz" );
    PUT_LINE( F, "namespace _R25" );
    PUT_LINE( F, "  virtual at 0" );
    PUT_LINE( F, "A25 = $" );
    PUT_LINE( F, "	rq 2" );
    PUT_LINE( F, "B25 = $" );
    PUT_LINE( F, "	rd 1" );
    PUT_LINE( F, "C25 = $" );
    PUT_LINE( F, "  end virtual" );
    PUT_LINE( F, "end namespace" );
    PUT_LINE( F, "	LI	16" );
    PUT_LINE( F, "	LI	STANDARD._R25.B25 - STANDARD._R25.A25" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k25_3" );
    PUT_LINE( F, "	SYS_EXIT	3" );
    PUT_LINE( F, "k25_3:" );
    PUT_LINE( F, "	LI	20" );
    PUT_LINE( F, "	LI	STANDARD._R25.C25 - STANDARD._R25.A25" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k25_4" );
    PUT_LINE( F, "	SYS_EXIT	4" );
    PUT_LINE( F, "k25_4:" );
    PUT_LINE( F, "	SYS_EXIT	0" );
    PUT_LINE( F, " virtual VARzone" );
    PUT_LINE( F, "   loc_siz = $" );
    PUT_LINE( F, "  end virtual" );
    PUT_LINE( F, "end namespace" );
    CLOSE( F );

    FROM25 := IR.ELT_ID( IR.ELT_COUNT + 1 );
    RUN_P0( "TC_TEST25.FAS" );
    PASSES.P1_REACH;
    PASSES.P2_LAYOUT( FROM25, IR.ELT_ID( IR.ELT_COUNT ) );
    EMITS.P2B_ADDRESSES( FROM25, IR.ELT_ID( IR.ELT_COUNT ) );
    EMITS.P3_EMIT( FROM25, IR.ELT_ID( IR.ELT_COUNT ), "TC_TEST25.BIN" );

    CHECK( VALUE_OF( RESOLVE( "STANDARD._R25.B25" ) ) = 16
	   and then VALUE_OF( RESOLVE( "STANDARD._R25.C25" ) ) = 20,
	   "rq 2 avance de 16, rd 1 de 4" );

    if OK
    then
      PUT_LINE( "PASSE rq" );
      PUT_LINE( "TC_TEST25.BIN ecrit - oracle externe :" );
      PUT_LINE( "  fasmg TC_TEST25.FAS TC_REF25 && cmp TC_REF25 TC_TEST25.BIN" );
      PUT_LINE( "  chmod +x TC_TEST25.BIN && ./TC_TEST25.BIN ; echo $?   (attendu : 0)" );
    end if;
  end;


end	TARGET_CODE;
	-----------
