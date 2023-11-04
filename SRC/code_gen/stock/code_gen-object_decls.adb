   WITH TEXT_IO, CG_1, CG_EXPR;
   USE  TEXT_IO, CG_1, CG_EXPR;
    SEPARATE ( CODE_GEN )
    --|----------------------------------------------------------------------------------------------
    --|	OBJECT_DECLS
    --|----------------------------------------------------------------------------------------------
    PACKAGE BODY OBJECT_DECLS IS
    
      --|-------------------------------------------------------------------------------------------
      --|
       PROCEDURE COMPILE_VC_NAME_INTEGER ( VC_NAME :TREE ) IS
      BEGIN
         ALIGN ( INTG_AL );
         DECLARE
            LVL		: LEVEL_TYPE	:= CG_1.LEVEL;
            OFS		: OFFSET_TYPE	:= - CG_1.OFFSET_ACT;
            CPU		: COMP_UNIT_NBR	:= CG_1.CUR_COMP_UNIT;
            INIT_EXP	: TREE	:= D ( SM_INIT_EXP, VC_NAME );
         BEGIN
            DI ( CD_LEVEL, VC_NAME, LVL );
            DI ( CD_OFFSET, VC_NAME, OFS );
            DI ( CD_COMP_UNIT, VC_NAME, CPU );
            DB ( CD_COMPILED, VC_NAME, TRUE );
            INC_OFFSET ( INTG_SIZE );
            IF INIT_EXP /= TREE_VOID THEN
               COMPILE_EXPRESSION ( INIT_EXP );
               GEN_STORE ( I, CPU, LVL, OFS,
                  "STORE " & PRINT_NAME ( D (LX_SYMREP, VC_NAME ) ) & " INIT EXPRESSION VALUE" );
            END IF;
         END;
      END COMPILE_VC_NAME_INTEGER;
      --|-------------------------------------------------------------------------------------------
      --|
       PROCEDURE COMPILE_VC_NAME_BOOL_CHAR ( VC_NAME :TREE; CT :CODE_TYPE; SIZ, ALI :NATURAL ) IS
      BEGIN
         ALIGN ( ALI );
         DECLARE
            LVL		: LEVEL_TYPE	:= CG_1.LEVEL;
            OFS		: OFFSET_TYPE	:= - CG_1.OFFSET_ACT;
            CPU		: COMP_UNIT_NBR	:= CG_1.CUR_COMP_UNIT;
            INIT_EXP	: TREE	:= D ( SM_INIT_EXP, VC_NAME );
         BEGIN
            DI ( CD_LEVEL, VC_NAME, LVL );
            DI ( CD_OFFSET, VC_NAME, OFS );
            DI ( CD_COMP_UNIT, VC_NAME, CPU );
            DB ( CD_COMPILED, VC_NAME, TRUE );
            INC_OFFSET ( SIZ );
            IF INIT_EXP /= TREE_VOID THEN
               COMPILE_EXPRESSION ( INIT_EXP );
            END IF;
            GEN_STORE ( CT, CPU, LVL, OFS,
               "STORE " & PRINT_NAME ( D (LX_SYMREP, VC_NAME ) ) & " INIT EXPRESSION VALUE" );
         END;
      END COMPILE_VC_NAME_BOOL_CHAR;
      --|-------------------------------------------------------------------------------------------
      --|
       PROCEDURE COMPILE_VC_NAME_ENUMERATION ( VC_NAME, TYPE_SPEC :TREE ) IS
         TYPE_SOURCE_NAME	: TREE	:= D ( XD_SOURCE_NAME, TYPE_SPEC );
         TYPE_SYMREP	: TREE	:= D ( LX_SYMREP, TYPE_SOURCE_NAME );
         NAME		: CONSTANT STRING	:= PRINT_NAME ( TYPE_SYMREP );
      BEGIN
         IF NAME = "BOOLEAN" THEN
            COMPILE_VC_NAME_BOOL_CHAR ( VC_NAME, B, BOOL_SIZE, BOOL_AL );
         ELSIF NAME = "CHARACTER" THEN
            COMPILE_VC_NAME_BOOL_CHAR ( VC_NAME, C, CHAR_SIZE, CHAR_AL );
         ELSE
            COMPILE_VC_NAME_INTEGER ( VC_NAME );
         END IF;
      END COMPILE_VC_NAME_ENUMERATION;
      --|-------------------------------------------------------------------------------------------
      --|
       PROCEDURE COMPILE_ACCESS_VAR ( VAR_ID, TYPE_SPEC :TREE ) IS
      BEGIN
         ALIGN ( ADDR_AL );
         DECLARE
            LVL	: LEVEL_TYPE	:= CG_1.LEVEL;
            OFS	: OFFSET_TYPE	:= - CG_1.OFFSET_ACT;
            CPU	: COMP_UNIT_NBR	:= CG_1.CUR_COMP_UNIT;
         BEGIN
            DI ( CD_LEVEL, VAR_ID, LVL );
            DI ( CD_OFFSET, VAR_ID, OFS );
            DI ( CD_COMP_UNIT, VAR_ID, CPU );
            DB ( CD_COMPILED, VAR_ID, TRUE );
            INC_OFFSET ( ADDR_SIZE );
            DECLARE
               INIT_EXP	: TREE	:= D ( SM_INIT_EXP, VAR_ID );
            BEGIN
               IF INIT_EXP = TREE_VOID THEN
                  GEN_1_I ( CONST, A, -1, "NULL INIT FOR " & PRINT_NAME ( D (LX_SYMREP, VAR_ID ) ) );
               ELSE
                  NULL;
               -- GET_NODE(SM_OBJ_DEF, ND_ALLOCATOR);
               -- LOAD_TYPE_SIZE ( ND_ALLOCATOR.C_ALLOCATOR^.AS_EXP_CONSTRAINED );
               -- GEN_1_I ( OALO, LVL - LEVELOFTYPE ( SM_OBJ_TYPE ) );
               END IF;
            END;
            GEN_STORE ( A, CPU, LVL, OFS,
               "STORE " & PRINT_NAME ( D (LX_SYMREP, VAR_ID ) ) & " INIT EXPRESSION VALUE" );
         END;
      END COMPILE_ACCESS_VAR;
      --|-------------------------------------------------------------------------------------------
      --|	PROCEDURE COMPILE_ARRAY_VAR
       PROCEDURE COMPILE_ARRAY_VAR ( VC_NAME, TYPE_SPEC :TREE ) IS
         DESCR_PTR	: OFFSET_TYPE;
      BEGIN
         ALIGN ( ADDR_AL );
         DECLARE
            LVL		: LEVEL_TYPE	:= CG_1.LEVEL;
            VALUE_PTR	: OFFSET_TYPE	:= - CG_1.OFFSET_ACT;
            CPU		: COMP_UNIT_NBR	:= CG_1.CUR_COMP_UNIT;
         BEGIN
            DI ( CD_LEVEL, VC_NAME, LVL );
            DI ( CD_OFFSET, VC_NAME, VALUE_PTR );
            DI ( CD_COMP_UNIT, VC_NAME, CPU );
            DB ( CD_COMPILED, VC_NAME, TRUE );
            INC_OFFSET ( ADDR_SIZE );
            ALIGN ( ADDR_AL );
            DESCR_PTR := - CG_1.OFFSET_ACT;
            INC_OFFSET ( ADDR_SIZE );
            
            IF DB ( CD_COMPILED, TYPE_SPEC ) THEN
               GEN_LOAD_ADDR ( DI ( CD_COMP_UNIT, TYPE_SPEC ) , DI ( CD_LEVEL, TYPE_SPEC ), DI ( CD_OFFSET, TYPE_SPEC ) );
               GEN_0 ( DPL, A, "DUPLICATE " & PRINT_NAME ( D (LX_SYMREP, VC_NAME ) ) & " ARRAY DESCRIPTOR ADDRESS" );
               GEN_STORE ( A, CG_1.CUR_COMP_UNIT, CG_1.LEVEL, DESCR_PTR, "STORE DESCRIPTOR ADDRESS" );
               GEN_1_I ( IND, I, 0, "INDEXED LOAD ARRAY SIZE FROM DESCRIPTOR ADDRESS" );
               GEN_1_I ( ALLOC, 0, "ALLOCATE ARRAY" );
               GEN_STORE ( A, CG_1.CUR_COMP_UNIT, CG_1.LEVEL, VALUE_PTR, "STORE ALLOCATED ARRAY ADDRESS" );
            ELSE
               PUT_LINE ( "!!! CG_DECL.COMPILE_ARRAY_VAR : TYPE_SPEC NON COMPILE" );
               RAISE PROGRAM_ERROR;
            END IF;
         END;
      END COMPILE_ARRAY_VAR;
      --|-------------------------------------------------------------------------------------------
      --|	PROCEDURE COMPILE_RECORD_VAR
       PROCEDURE COMPILE_RECORD_VAR ( VC_NAME, TYPE_SPEC :TREE ) IS
         INIT_EXP	: TREE	:= D ( SM_INIT_EXP, VC_NAME );
      BEGIN
         
         ALIGN ( RECORD_AL );
         DECLARE
            LVL	: LEVEL_TYPE	:= CG_1.LEVEL;
            OFS	: OFFSET_TYPE	:= - CG_1.OFFSET_ACT;
            CPU	: COMP_UNIT_NBR	:= CG_1.CUR_COMP_UNIT;
         BEGIN
            DI ( CD_LEVEL, VC_NAME, LVL );
            DI ( CD_OFFSET, VC_NAME, OFS );
            DI ( CD_COMP_UNIT, VC_NAME, CPU );
            DB ( CD_COMPILED, VC_NAME, TRUE );
         
            IF INIT_EXP.TY = DN_AGGREGATE THEN
               DECLARE
                  GENERAL_ASSOC_SEQ	: SEQ_TYPE	:= LIST ( D ( SM_NORMALIZED_COMP_S, INIT_EXP ) );
                  COMP_EXP	: TREE;
               BEGIN
                  WHILE NOT IS_EMPTY ( GENERAL_ASSOC_SEQ ) LOOP
                     POP ( GENERAL_ASSOC_SEQ, COMP_EXP );
                    
                     COMPILE_EXPRESSION ( COMP_EXP );
                     GEN_STORE ( CT, CPU, LVL, OFS + FIELD_OFS,
                        "STORE " & PRINT_NAME ( D (LX_SYMREP, VC_NAME ) ) & " FIELD INIT EXPRESSION VALUE" );
                  	 
                  END LOOP;
               END;
            END IF;
         END;
      END COMPILE_RECORD_VAR;
      --|-------------------------------------------------------------------------------------------
      --|	PROCEDURE COMPILE_VC_NAME
       PROCEDURE COMPILE_VC_NAME ( VC_NAME, TYPE_SPEC :TREE ) IS
      BEGIN
         CASE TYPE_SPEC.TY IS
            WHEN DN_INTEGER =>
               COMPILE_VC_NAME_INTEGER ( VC_NAME );
               
            WHEN DN_ENUMERATION =>
               COMPILE_VC_NAME_ENUMERATION ( VC_NAME, TYPE_SPEC );
               
            WHEN DN_ACCESS =>
               COMPILE_ACCESS_VAR ( VC_NAME, TYPE_SPEC );
               
            WHEN DN_CONSTRAINED_ARRAY =>
               COMPILE_ARRAY_VAR ( VC_NAME, TYPE_SPEC);
         
            WHEN DN_RECORD =>
               COMPILE_RECORD_VAR ( VC_NAME, TYPE_SPEC);
               
            WHEN OTHERS =>
               PUT_LINE ( "!!! CG_DECL.COMPILE_VC_NAME, TYPE_SPEC.TY = " & NODE_NAME'IMAGE ( TYPE_SPEC.TY ) );
               RAISE PROGRAM_ERROR;
         END CASE;
      END COMPILE_VC_NAME;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
       PROCEDURE COMPILE_OBJECT_DECL ( OBJECT_DECL :TREE ) IS		--| VARIABLE_DECL OU CONSTANT_DECL
         SRC_NAME_SEQ	: SEQ_TYPE	:= LIST ( D ( AS_SOURCE_NAME_S, OBJECT_DECL ) );
         SRC_NAME		: TREE;
      BEGIN
         WHILE NOT IS_EMPTY ( SRC_NAME_SEQ ) LOOP
            POP ( SRC_NAME_SEQ, SRC_NAME );
            COMPILE_VC_NAME ( SRC_NAME, D ( SM_OBJ_TYPE, SRC_NAME ) );
         END LOOP;
      END COMPILE_OBJECT_DECL;
   
   
   
   
   
      --|-------------------------------------------------------------------------------------------
      --|	PROCEDURE COMPILE_ENUMERATION_DEF
       PROCEDURE COMPILE_ENUMERATION_DEF ( ENUMERATION_DEF :TREE ) IS
         ENUM_LITERAL_S	: TREE	:= D ( AS_ENUM_LITERAL_S, ENUMERATION_DEF );
         LITERAL_SEQ	: SEQ_TYPE	:= LIST ( ENUM_LITERAL_S );
         LITERAL		: TREE;
      BEGIN
         WHILE NOT IS_EMPTY ( LITERAL_SEQ ) LOOP			--| TANT QU'IL Y A DES ÉLÉMENTS
            POP ( LITERAL_SEQ, LITERAL );			--| EN EXTRAIRE UN
         END LOOP;
         DI ( CD_LAST, ENUM_LITERAL_S, DI ( SM_REP, LITERAL ) );		--| STOCKER LA VALEUR DU DERNIER ÉLÉMENT
      END;
      --|-------------------------------------------------------------------------------------------
      --|	PROCEDURE COMPILE_INTEGER_DEF
       PROCEDURE COMPILE_INTEGER_DEF ( INTEGER_DEF, INTEGER_SPEC :TREE ) IS
         LOWER	: OFFSET_TYPE;				--| LIEU DE LA BORNE BASSE
         UPPER	: OFFSET_TYPE;				--| LIEU DE LA BORNE HAUTE
         INT_RANGE	: TREE	:= D ( AS_CONSTRAINT, INTEGER_DEF );		--| ETENDUE DU TYPE ENTIER
      BEGIN
         ALIGN( INTG_AL );				--| ALIGNER LE SOMMET DE PILE POUR UN ENTIER
         LOWER := - CG_1.OFFSET_ACT;				--| LIEU DE LA BORNE BASSE
         INC_OFFSET ( INTG_SIZE );				--| ALLER AU LIEU LIBRE SUIVANT L'ENTIER
         UPPER := - CG_1.OFFSET_ACT;				--| LIEU DE LA BORNE HAUTE
         INC_OFFSET ( INTG_SIZE );				--| ALLER AU LIEU LIBRE SUIVANT L'ENTIER
      
         DI ( CD_OFFSET, INTEGER_SPEC, LOWER );			--| LIEU DES BORNES
         DI ( CD_LEVEL, INTEGER_SPEC, CG_1.LEVEL );			--| NIVEAU STATIQUE DE LA DÉFINITION
         DI ( CD_COMP_UNIT, INTEGER_SPEC, CUR_COMP_UNIT );			--| UNITÉ PARENTE
         DB ( CD_COMPILED, INTEGER_SPEC, TRUE );			--| DÉFINITION TRAITÉE
      
         CG_EXPR.COMPILE_EXPRESSION ( D ( AS_EXP1, INT_RANGE ) );		--| GÉNÉRER LE CODE DE CALCUL DE L'EXPRESSION DE BORNE BASSE
         CG_1.GEN_STORE ( I, CG_1.CUR_COMP_UNIT, CG_1.LEVEL, LOWER, "STORE LOWER INTEGER BOUND" );	--| STOCKER LE RÉSULTAT DANS LA BORNE BASSE
         CG_EXPR.COMPILE_EXPRESSION ( D ( AS_EXP2, INT_RANGE ) );		--| PAREIL POUR LA BORNE HAUTE
         CG_1.GEN_STORE ( I, CG_1.CUR_COMP_UNIT, CG_1.LEVEL, UPPER, "STORE UPPER INTEGER BOUND" );
      END COMPILE_INTEGER_DEF;
      --|-------------------------------------------------------------------------------------------
      --|	PROCEDURE COMPILE_CONSTRAINED_ARRAY_DEF
       PROCEDURE COMPILE_CONSTRAINED_ARRAY_DEF ( TYPE_DEF, TYPE_SPEC :TREE ) IS
         DIMENSIONS_NBR	: NATURAL	:= 0;
         SUBTYPE_INDICATION	: TREE	:= D ( AS_SUBTYPE_INDICATION, TYPE_DEF );--| SOUS TYPE DE L'ÉLÉMENT
         USED_NAME_ID	: TREE	:= D ( AS_NAME, SUBTYPE_INDICATION );
         COMP_TYPE_ID	: TREE	:= D ( SM_DEFN, USED_NAME_ID );
         COMP_TYPE		: TREE	:= D ( SM_TYPE_SPEC, COMP_TYPE_ID );	--| TYPE_SPEC DU TYPE D'ÉLÉMENT
         INDEX_CONSTRAINT	: TREE	:= D ( AS_CONSTRAINT, TYPE_DEF );	--| LA CONTRAINTE DE DÉFINITION DU TYPE TABLEAU
         DISCRETE_RANGE_S	: TREE	:= D ( AS_DISCRETE_RANGE_S, INDEX_CONSTRAINT );
         DISCRETE_RANGE_SEQ	: SEQ_TYPE	:= LIST ( DISCRETE_RANGE_S );	--| LA SÉQUENCE DES INDIÇAGES
         
      --|-------------------------------------------------------------------------------------------
      --|	PROCEDURE INSTALL_ARRAY_DIMENSION
          PROCEDURE INSTALL_ARRAY_DIMENSION ( DISCRETE_RANGE_SEQ :IN OUT SEQ_TYPE ) IS
            IDXFAC, FIRST, LAST	: OFFSET_TYPE;
            DISCRETE_RANGE	: TREE;
         BEGIN
            DIMENSIONS_NBR := DIMENSIONS_NBR + 1;			--| UNE DIMENSION DE PLUS
            ALIGN ( INTG_AL );				--| ALIGNER LE LIEU POUR UN ENTIER
            IDXFAC := - OFFSET_ACT;				--| LIEU DU FACTEUR DE L'INDICE (POUR PASSER D'UN ÉLÉMENT AU SUIVANT)
            FIRST := IDXFAC - INTG_SIZE;			--| LIEU DE L'INDICE BAS
            LAST := FIRST - INTG_SIZE;				--| LIEU DE L'INDICE HAUT
            INC_OFFSET ( 3*INTG_SIZE );				--| MONTER LE LIEU LIBRE À 3 ENTIERS PLUS LOIN
            
            POP ( DISCRETE_RANGE_SEQ, DISCRETE_RANGE );			--| EXTRAIRE L'INDIÇAGE DE CETTE DIMENSION
            IF IS_EMPTY( DISCRETE_RANGE_SEQ ) THEN			--| C'ÉTAIT LE DERNIER INDIÇAGE (INDICE "RAPIDE")
               CG_EXPR.LOAD_TYPE_SIZE ( COMP_TYPE );			--| EMPILER LA TAILLE DE L'ÉLÉMENT
               GEN_0 ( DPL, I, "DUPLICATE INDEX FACTOR" );			--| GÉNÉRER UNE DUPLICATION DE CETTE TAILLE
               CG_1.GEN_STORE ( I, 0, CG_1.LEVEL, IDXFAC, "STORE INDEX FACTOR" );	--| LA STOCKER COMME FACTEUR DE PASSAGE D'UN ÉLÉMENT AU SUIVANT POUR CETTE DIMENSION
            ELSE					--| C'EST UN INDIÇAGE INTERMÉDIAIRE
               INSTALL_ARRAY_DIMENSION ( DISCRETE_RANGE_SEQ );		--| TRAITER LA DIMENSION SUIVANTE
               GEN_0 ( DPL, I, "DUPLICATE INDEX FACTOR" );			--| DUPLIQUER LE FACTEUR DE PASSAGE
               CG_1.GEN_STORE ( I, 0, CG_1.LEVEL, IDXFAC, "STORE INDEX FACTOR" );	--| LE STOCKER DANS LE DESCRIPTEUR DU TABLEAU
            END IF;
            
            IF DISCRETE_RANGE.TY = DN_DISCRETE_SUBTYPE THEN
               DECLARE
                  SUBTYPE_INDICATION	: TREE	:= D ( AS_SUBTYPE_INDICATION, DISCRETE_RANGE );
               BEGIN
                  DISCRETE_RANGE := D ( AS_CONSTRAINT, SUBTYPE_INDICATION );
                  IF DISCRETE_RANGE.TY = DN_VOID THEN
                     DECLARE
                        USED_NAME_ID	: TREE	:= D ( AS_NAME, SUBTYPE_INDICATION );
                        DEF_NAME	: TREE	:= D ( SM_DEFN, USED_NAME_ID );
                        TYPE_SPEC	: TREE	:= D ( SM_TYPE_SPEC, DEF_NAME );
                     BEGIN
                        DISCRETE_RANGE := D ( SM_RANGE, TYPE_SPEC );
                     END;
                  END IF;
               END;
            END IF;
         
            IF DISCRETE_RANGE.TY = DN_RANGE_ATTRIBUTE THEN
               DECLARE
                  TYPE_SPEC	: TREE	:= D ( SM_TYPE_SPEC, DISCRETE_RANGE );
               BEGIN
                  DISCRETE_RANGE := D ( SM_RANGE, TYPE_SPEC );
               END;
            END IF;
            
            IF DISCRETE_RANGE.TY = DN_RANGE THEN
               CG_EXPR.COMPILE_EXPRESSION ( D ( AS_EXP1, DISCRETE_RANGE ) );		--| GÉNÉRER LE CALCUL DE L'INDICE BAS
               CG_1.GEN_STORE ( I, CG_1.CUR_COMP_UNIT, CG_1.LEVEL, FIRST, "STORE FIRST" );	--| LE STOCKER DANS LE DESCRIPTEUR
               CG_EXPR.COMPILE_EXPRESSION ( D ( AS_EXP2, DISCRETE_RANGE ) );		--| PAREIL POUR L'INDICE HAUT
               CG_1.GEN_STORE ( I, 0, CG_1.LEVEL, LAST, "STORE LAST" );
               CG_1.GEN_LOAD_ADDR ( 0, LEVEL, FIRST, "LOAD @FIRST" );		--| GÉNÉRER L'EMPILAGE DE L'ADRESSE DE LA SECTION DU DESCRIPTEUR POUR LA DIMENSION
               GEN_CSP ( LEN, "CALCULATE LENGTH" );			--| PROCÉDURE DE CALCUL DU LENGTH(DIM)
               GEN_0 ( MUL, I, "NEXT INDEX FACTOR = LEN * PREVIOUS FACTOR" );				--| LAISSER LE FACTEUR DE PASSAGE (LENGHTH*FACTEUR PRÉCÉDENT) SUR LA PILE
            ELSIF DISCRETE_RANGE.TY = DN_RANGE_ATTRIBUTE THEN
               NULL;
               NULL;
            ELSE
            -- DN_RANGE_ATTRIBUTE
            -- DN_DISCRETE_SUBTYPE
               PUT_LINE ( "!!! COMPILE_TYPE_ARRAY_DIMENSION : DISCRETE_RANGE.TY ILLICITE " & NODE_NAME'IMAGE ( DISCRETE_RANGE.TY ) );
               RAISE PROGRAM_ERROR;
            END IF;
         END INSTALL_ARRAY_DIMENSION;
         
      BEGIN
         ALIGN ( INTG_AL );				--| ALIGNER LE LIEU LIBRE POUR UN ENTIER
         DI ( CD_LEVEL, TYPE_SPEC, CG_1.LEVEL );			--| STOCKER LE NIVEAU STATIQUE
         DI ( CD_COMP_UNIT, TYPE_SPEC, CUR_COMP_UNIT );			--| STOCKER L'UNITÉ COURANTE
         DB ( CD_COMPILED, TYPE_SPEC, TRUE );			--| MARQUER COMME TRAITÉ
         DECLARE
            OFFSET		: INTEGER	:= - CG_1.OFFSET_ACT;
         BEGIN
            DI ( CD_OFFSET, TYPE_SPEC, OFFSET );			--| STOCKER LE LIEU DU NOMBRE DE DIMENSIONS
            INC_OFFSET ( INTG_SIZE );				--| MONTER AU LIEU LIBRE SUIVANT L'ENTIER
            INSTALL_ARRAY_DIMENSION ( DISCRETE_RANGE_SEQ );			--| METTRE EN PLACE LES FACTEURS D'INDEXATION ET LES LIMITES D'INDICE
            CG_1.GEN_STORE ( I, CG_1.CUR_COMP_UNIT, CG_1.LEVEL, OFFSET,
               "STORE ARRAY SIZE (LAST INDEX FACTOR)" );		--| GÉNÉRER LE STOCKAGE EN PILE DU NOMBRE DE DIMENSIONS
            DI ( CD_DIMENSIONS, TYPE_SPEC, DIMENSIONS_NBR );		--| STOCKER AUSSI DANS LE TYPE_SPEC
         END;
      END COMPILE_CONSTRAINED_ARRAY_DEF;
      --|-------------------------------------------------------------------------------------------
      --|	 PROCEDURE COMPILE_ACCESS_DEF
       PROCEDURE COMPILE_ACCESS_DEF ( ACCESS_DEF, ACCESS_SPEC :TREE ) IS
         POINTED_TYPE_SPEC	: TREE	:= D ( SM_DESIG_TYPE, ACCESS_SPEC );
         CONTRAINT		: BOOLEAN	:= (POINTED_TYPE_SPEC.TY IN CLASS_CONSTRAINED);
      BEGIN
         DB ( CD_CONSTRAINED, ACCESS_SPEC, CONTRAINT );
      
         IF CONTRAINT THEN
            DI ( CD_LEVEL, ACCESS_SPEC, CG_1.LEVEL );			--| STOCKER LE NIVEAU STATIQUE DE LA DÉFINITION
            ALIGN ( INTG_AL );				--| ALIGNER LE LIEU LIBRE POUR UN ENTIER
            DECLARE
               OFFSET	: OFFSET_TYPE	:= CG_1.OFFSET_ACT;
            BEGIN
               DI ( CD_OFFSET, ACCESS_SPEC, OFFSET );			--| STOCKER LE LIEU
               INC_OFFSET ( INTG_SIZE );			--| MONTER AU LIEU SUIVANT L'ENTIER
               CG_EXPR.LOAD_TYPE_SIZE ( POINTED_TYPE_SPEC );		--| GÉNÉRER LE CHARGEMENT DE LA TAILLE DU TYPE POINTÉ
               CG_1.GEN_STORE ( I, 0, CG_1.LEVEL, OFFSET, "STORE POINTERD TYPE SIZE" );			--| LA STOCKER DANS LE LIEU RÉSERVÉ
            END;
         END IF;
      END;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|	PROCEDURE COMPILE_TYPE_DECL
       PROCEDURE COMPILE_TYPE_DECL ( TYPE_DECL :TREE ) IS
         TYPE_DEF	: TREE	:= D ( AS_TYPE_DEF, TYPE_DECL );
         TYPE_ID	: TREE	:= D ( AS_SOURCE_NAME, TYPE_DECL );
         TYPE_SPEC	: TREE	:= D ( SM_TYPE_SPEC, TYPE_ID );
      BEGIN
         IF CG_1.CUR_COMP_UNIT /= 1 THEN			--| PAS LE STANDARD
            CASE TYPE_DEF.TY IS
            
               WHEN DN_ENUMERATION_DEF =>
                  COMPILE_ENUMERATION_DEF ( TYPE_DEF );
                  
               WHEN DN_INTEGER_DEF =>				--| TYPE TRUC IS RANGE 1..10*U;
                  COMPILE_INTEGER_DEF ( TYPE_DEF, TYPE_SPEC );
            
               WHEN DN_FLOAT_DEF =>
                  NULL;
            
               WHEN DN_FIXED_DEF =>
                  NULL;
            
               WHEN DN_CONSTRAINED_ARRAY_DEF =>
                  COMPILE_CONSTRAINED_ARRAY_DEF ( TYPE_DEF, TYPE_SPEC );
                  
               WHEN DN_RECORD_DEF =>
                  NULL;
            
               WHEN DN_ACCESS_DEF =>
                  COMPILE_ACCESS_DEF ( TYPE_DEF, TYPE_SPEC );
                  
               WHEN DN_DERIVED_DEF =>
                  NULL;
                  
               WHEN OTHERS =>
               -- DN_SUBTYPE_INDICATION
               -- DN_L_PRIVATE_DEF
               -- DN_PRIVATE_DEF
               -- DN_UNCONSTRAINED_ARRAY_DEF
                  PUT_LINE ( "!!! COMPILE_TYPE_DECL : TYPE_SPEC.TY ILLICITE " & NODE_NAME'IMAGE ( TYPE_SPEC.TY ) );
                  RAISE PROGRAM_ERROR;
            END CASE;
         END IF;
      END COMPILE_TYPE_DECL;
   
   --|----------------------------------------------------------------------------------------------
   END OBJECT_DECLS;
