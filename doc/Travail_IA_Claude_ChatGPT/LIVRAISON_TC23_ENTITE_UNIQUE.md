# LIVRAISON TC-23 - ENTITE UNIQUE SYMBOLE/NAMESPACE (corpus ADA_COMP)
(23 aout 2026 - s'applique sur l'etat POST-TC-22.)

RELEVE (premier avalement d'ADA_COMP) : ANON_39_20_L10_D_info est a la
fois VAR (FRAME_OFFSET) et namespace dans HASH_SEARCH_L1. Semantique
fasmg : un symbole et son espace d'enfants ne font QU'UNE entite -
'namespace X' sur un X existant rouvre ses enfants, et definir X sur
un namespace existant pose classe et valeur sans perdre les enfants.
Notre SYMBOLS les traitait en declarations concurrentes. Trois volets,
les tolerances existantes (GUARD/PLAIN sur namespace, tete canonique)
restant inchangees :
- descente pointee : le critere devient 'possede des enfants'
  (UNDER /= 0, la sentinelle par defaut), plus 'est un SCOPE_NAME' ;
- ENTER_SCOPE sur un symbole value : reouverture si deja pourvu
  d'enfants, sinon attachement d'un scope neuf, CLASSE ET VALEUR
  CONSERVEES ;
- DECLARE sur un namespace pur (VALUE_SET faux) : unification - le
  symbole prend classe et valeur, garde ses enfants, VALUE_SET selon
  la regle de NEW_CELL.

## COMMIT 1 - SYMBOLS : l'entite unique

### MODIFICATION 1.1 - target_code-symbols.adb (sur place, auto-localisee)
La descente pointee accepte tout symbole pourvu d enfants.
ANCRE = BLOC A SUPPRIMER (texte existant, unique, auto-localisant) :
<<<
        if  TABLE( S ).CLASS /= SCOPE_NAME  then
	return NO_SYM;
        end if;
>>>
REMPLACER PAR :
<<<
        if  TABLE( S ).UNDER = 0  then								--| sans enfants : descente impossible
	return NO_SYM;										--| (les symboles values a enfants passent :
        end if;											--| entite unique fasmg, TC-23)
>>>

### MODIFICATION 1.2 - target_code-symbols.adb (sur place, auto-localisee)
ENTER_SCOPE : le refus final devient reouverture ou attachement.
ANCRE = BLOC A SUPPRIMER (texte existant, unique, auto-localisant) :
<<<
    else
      FAULT( "namespace sur un nom deja pris : " & NAME );
    end if;
>>>
REMPLACER PAR :
<<<
    elsif  TABLE( F ).UNDER /= 0  then								--| symbole value deja pourvu d'enfants :
      CURRENT := TABLE( F ).UNDER;									--| reouverture (entite unique fasmg)

    else											--| symbole value SANS enfants : lui attacher
      if  LAST_SCOPE = SCOPE_ID'LAST  then								--| son scope - classe et valeur CONSERVEES
	FAULT( "trop de namespaces (SCOPE_MAX) sur : " & NAME );						--| (VAR X puis namespace X : ADA_COMP, TC-23)
      end if;
      LAST_SCOPE := LAST_SCOPE + 1;
      TABLE( F ).UNDER := LAST_SCOPE;
      SCOPES( LAST_SCOPE ).PARENT := CURRENT;
      SCOPES( LAST_SCOPE ).SELF := F;
      CURRENT := LAST_SCOPE;
    end if;
>>>

### MODIFICATION 1.3 - target_code-symbols.adb (insertion pure)
DECLARE_IN : unification sur un namespace pur, apres les tolerances
GUARD/PLAIN existantes.
ANCRE (texte existant, unique) :
<<<
    if  ( CLASS = GUARD  or  CLASS = PLAIN_VALUE )  and then  TABLE( F ).CLASS = SCOPE_NAME  then			--| affectation sur un nom de namespace : toleree
      return  F;											--| sans changement (tete canonique STANDARD =
    end if;											--| 'STANDARD' apres que le scope existe — seule
>>>
SUPPRIMER : le texte de l'ancre elle-meme (repris a l'identique en tete du remplacement).
REMPLACER PAR (ancre reprise inchangee + insertion) :
<<<
    if  ( CLASS = GUARD  or  CLASS = PLAIN_VALUE )  and then  TABLE( F ).CLASS = SCOPE_NAME  then			--| affectation sur un nom de namespace : toleree
      return  F;											--| sans changement (tete canonique STANDARD =
    end if;											--| 'STANDARD' apres que le scope existe — seule

    if  TABLE( F ).CLASS = SCOPE_NAME  and then  not TABLE( F ).VALUE_SET  then					--| namespace X PUIS VAR/label X (meme nom) :
      TABLE( F ).CLASS := CLASS;									--| unification - le symbole prend classe et
      TABLE( F ).VALUE := VALUE;									--| valeur, GARDE ses enfants (UNDER) ; entite
      case  CLASS  is										--| unique fasmg (ADA_COMP, releve TC-23)
      when CODE_LABEL | CONSTANT_ADDR | SCOPE_NAME =>
	TABLE( F ).VALUE_SET := FALSE;								--| adresses : posees en P2 par SET_VALUE
      when others =>
	TABLE( F ).VALUE_SET := TRUE;									--| offsets, gardes, marques : valeur immediate
      end case;
      return  F;
    end if;
>>>

ORACLE COMMIT 1 : compilation ; rejeu integral muet (aucun temoin ni
unite du corpus actuel n'exerce l'entite unique : chemins inchanges).

## COMMIT 2 - TEMOIN TC-23 (pilote)

### MODIFICATION 2.1 - target_code.adb (insertion pure, fin du pilote)
ANCRE (texte existant, unique : fin du temoin TC-21) :
<<<
      PUT_LINE( "  chmod +x TC_TEST21.BIN && ./TC_TEST21.BIN ; echo $?   (attendu : 0)" );
    end if;
  end;
>>>
SUPPRIMER : le texte de l'ancre elle-meme (repris a l'identique en tete du remplacement).
REMPLACER PAR (ancre reprise inchangee + temoin TC-23) :
<<<
      PUT_LINE( "  chmod +x TC_TEST21.BIN && ./TC_TEST21.BIN ; echo $?   (attendu : 0)" );
    end if;
  end;

  --|  TEMOIN TEMPORAIRE ENTITE UNIQUE (TC-23) - le releve ADA_COMP :
  --|  un meme nom variable ET namespace, dans les deux ordres, avec
  --|  ecritures/lectures de la variable ET de ses enfants pointes.
  --|  Verdicts : 0 = tout bon ; 3..6 = etape fautive. A RETIRER.
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

>>>

ORACLE (quadruple) : (a) cmp TC_REF23/TC_TEST23.BIN muet - l'arbitre
de la semantique d'unification, offsets compris ; (b) fasmg accepte le
temoin (sinon l'ordre refuse par fasmg sort du modele et on resserre) ;
(c) PASSE entite, ./TC_TEST23.BIN -> 0 ; (d) batterie TC-04..21 muette,
DIS_BONJOUR / ENUM_TEST / DIRECT_IO_TEST / SEQ_IO_TEST muets, et
ADA_COMP franchit ce refus - le suivant, s'il vient, designe le
prochain motif du corpus compilateur.

DEMANDE CORPUS : pour confirmer le motif reel, l'extrait d'ADA_COMP.fas
autour de ANON_39_20_L10_D_info (la region HASH_SEARCH) serait precieux
au dossier - une vingtaine de lignes suffisent.
