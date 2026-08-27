# ERRATUM TC-10 - CONTOURNEMENT BUG TLALOC (constante d'enumere dynamique en actuel)
(19 aout 2026 - s'applique sur l'etat post-TC-10, commit 1)

DIAGNOSTIC (trace FINC de l'utilisateur, TARGET_CODE-LEX.FINC) :
l'expander evalue les actuels de droite a gauche ; LIF 0.0 (FVAL) passe,
Lq de L1INT (constante LONG_INTEGER dynamique) passe, LVA de L1TXT
(constante record SLICE dynamique) passe ; le raise idl.adb:432 survient
sur L1TAG : CONSTANTE DE TYPE ENUMERE INITIALISEE DYNAMIQUEMENT
(constant IR.OPERAND_TAG := TAGS(1)), utilisee comme actuel. Le message
"L ATTRIBUT SM_VALUE DU NOEUD [DN_USED_OBJECT_ID] N EST PAS UN ENTIER"
montre que l'expander suppose STATIQUE toute constante de type discret
et veut emettre SM_VALUE en litteral. C'est legal en Ada 83 (une
constante n'est pas necessairement statique) : bug TLALOC, meme famille
que le SM_DEFN absent (temoin selfun_test.adb, commentaire du pilote).
Temoin de bissection minimal fourni a part : enumcst_test.adb (trois
cas : litteral statique OK, VARIABLE dynamique a verifier, CONSTANTE
dynamique = plantage attendu).

CONTOURNEMENT (celui-ci, pas un autre) : le corpus impose de toute facon
lvl ENTIER (LVL_STR = image d'entier partout dans types_decls, TC-03
compris). On durcit donc le refus bruyant (TAGS(1) doit etre INT_OP) et
on appelle ADD_OP avec le LITTERAL IR.INT_OP - forme deja eprouvee par
TLALOC (TC-08/09 : IR.ADD_OP( IR.NAME_OP, ... ) compile et assemble).
La constante L1TAG disparait. Les octets produits sont INCHANGES (le tag
transmis etait deja INT_OP sur tout le corpus).

### MODIFICATION E.1 - target_code-lex.adb (branche USEINFO : garde durcie) (sur place, auto-localisee)
ANCRE = BLOC A SUPPRIMER (texte existant, unique, auto-localisant) :
<<<
      if NOPS < 3							--| reduit a lvl, nom - le layout de P2 ; (2) la
	 or else  TAGS( 2 ) /= IR.NAME_OP				--| charge (ops 3.., rejoints par ", ") re-parsee
      then								--| en element ordinaire ; (3) "Sa lvl, nom__u"
	FAULT( "forme USEINFO inattendue (lvl, nom, charge)" );		--| synthetise. EMITS n'a rien a apprendre.
>>>
REMPLACER PAR :
<<<
      if NOPS < 3							--| reduit a lvl, nom - le layout de P2 ; (2) la
	 or else  TAGS( 1 ) /= IR.INT_OP				--| charge (ops 3.., rejoints par ", ") re-parsee
	 or else  TAGS( 2 ) /= IR.NAME_OP				--| en element ordinaire ; (3) "Sa lvl, nom__u"
      then								--| synthetise. EMITS n'a rien a apprendre.
	FAULT( "forme USEINFO inattendue (lvl entier, nom, charge)" );
>>>

### MODIFICATION E.2 - target_code-lex.adb (branche USEINFO : suppression de L1TAG) (sur place, auto-localisee)
Constante d'enumere dynamique : la declaration seule compile, mais son
usage en actuel plante TLALOC (idl.adb:432). Elle devient inutile.
ANCRE = BLOC A SUPPRIMER (texte existant, unique, auto-localisant) :
<<<
	L1TAG		: constant IR.OPERAND_TAG := TAGS( 1 );
	L1TXT		: constant SLICE	  := TXTS( 1 );
>>>
REMPLACER PAR :
<<<
	L1TXT		: constant SLICE	  := TXTS( 1 );
>>>

### MODIFICATION E.3 - target_code-lex.adb (branche USEINFO : appel ADD_OP du Sa) (sur place, auto-localisee)
ANCRE = BLOC A SUPPRIMER (texte existant, unique, auto-localisant) :
<<<
	IR.ADD_OP( L1TAG, L1TXT, L1INT, 0.0 );
>>>
REMPLACER PAR :
<<<
	IR.ADD_OP( IR.INT_OP, L1TXT, L1INT, 0.0 );			--| litteral INT_OP : contournement TLALOC
									--| (constante d'enumere dynamique en actuel =
									--| raise idl.adb:432, SM_VALUE non entier ;
									--| temoin de bissection : enumcst_test.adb) ;
									--| le corpus garantit lvl entier (garde ci-dessus)
>>>

ORACLE ERRATUM : recompilation TLALOC de target_code-lex.adb SANS
plantage ; rejeu complet - tous les PASSE dont "PASSE useinfo" ; les
sept cmp TC-04..10 muets (octets inchanges : le tag transmis etait deja
INT_OP) ; executions conformes.

CLOTURE : PIEGES - "TLALOC : constante de type discret initialisee
dynamiquement, utilisee en actuel -> idl.adb:432 (SM_VALUE suppose
entier). Contournement : litteral d'enumeration ou variable. Temoin :
enumcst_test.adb." Le jour ou le bug est corrige dans l'expander,
l'erratum peut etre defait (re-generaliser L1TAG) - noter au JOURNAL.
