--| VP_GEN : generique bibliotheque temoin pour VISEL_TEST.
--| Calque minimal de SEQUENTIAL_IO : un formel prive, un enumere
--| declare dans la partie visible du generique (l'instance en recoit
--| une copie, LRM 12.3 — cas SEQ_IO.IN_FILE), et une constante de
--| controle non littérale.
--| Pas de corps (declarations pures).

generic

  type ELEM is private;

package VP_GEN is

  type MODE is ( M_IN, M_OUT );

  NIL : constant INTEGER := 7;

end VP_GEN;

--| VP_PACK : paquetage bibliotheque temoin pour VISEL_TEST.
--| Partie visible : un enumere (littéraux = cibles du bug) et une
--| constante (controle : declaration NON littérale, meme prefixe).

package VP_PACK is

  type COLOR is ( RED, GREEN, BLUE );

  CONST : constant INTEGER := 42;

end VP_PACK;

--| VISEL_TEST — temoin de la divergence bootstrap T1/T2
--| « NOT VISIBLE BY SELECTION » sur littéraux d'enumeration.
--|
--| ORACLE (compile par T1, TLALOC-gnat) :
--|   compilation SANS faute, execution :
--|     RESULTAT :  12 OK,   0 ECHECS
--|     VISEL_TEST PASSE
--|
--| ORACLE (compile par T2, etat du 11 aout 2026) :
--|   fautes « NOT VISIBLE BY SELECTION » attendues sur les lignes des
--|   sections S1..S6 ; les sections S7/S8 (controles) doivent passer.
--|   Le MOTIF des sections en faute discrimine le chemin mecompile :
--|     S1  litteral selecte, paquetage ordinaire      (cas PRENAME.DEBUG)
--|     S2  litteral selecte en CHOIX de case          (cas PRENAME.COUNT)
--|     S3  litteral selecte via RENOMMAGE             (cas DA.LX_SRCPOS)
--|     S4  litteral selecte via INSTANCE de generique (cas SEQ_IO.IN_FILE)
--|     S5  litteral selecte AVEC use deja en portee   (cas fix_pre l.611)
--|     S6  litteral selecte en actual d'appel SURCHARGE — cascade
--|         « DESACCORD DE TYPE » attendue sur l'appel (cas OPEN, cas D)
--|     S7  controle : declaration NON littérale, memes prefixes
--|     S8  controle : litteral en nom SIMPLE sous use (pas de selection)
--|
--| Une construction par ligne : le numero de ligne des fautes T2
--| identifie la variante.

with TEXT_IO;	use TEXT_IO;
with VP_PACK;
with VP_GEN;

procedure VISEL_TEST is

  NB_OK	: INTEGER := 0;
  NB_KO	: INTEGER := 0;

  package RP	renames VP_PACK;			--| renommage de paquetage (cas DA)

  package INST	is new VP_GEN( INTEGER );		--| instance locale (cas SEQ_IO)

  C	: VP_PACK.COLOR;
  M	: INST.MODE;

  LAST	: INTEGER := 0;

  procedure ASSERT( OK : BOOLEAN; MSG : STRING ) is
  begin
    if  OK  then
      NB_OK := NB_OK + 1;
    else
      NB_KO := NB_KO + 1;
      PUT_LINE( "ECHEC : " & MSG );
    end if;
  end ASSERT;

  procedure TAKE( X : VP_PACK.COLOR ) is		--| surcharge : la resolution de
  begin							--| l'appel exige le littéral
    LAST := 1;						--| (meme situation que OPEN)
  end TAKE;

  procedure TAKE( X : INST.MODE ) is
  begin
    LAST := 2;
  end TAKE;

begin

  --| S1 : littéral selecte, paquetage bibliotheque ordinaire
  C := VP_PACK.RED;
  ASSERT( VP_PACK.COLOR'POS( C ) = 0, "S1 VP_PACK.RED" );

  --| S2 : littéral selecte en choix de case (expression statique)
  C := VP_PACK.GREEN;
  case  C  is
    when VP_PACK.GREEN	=> ASSERT( TRUE,  "S2" );
    when others		=> ASSERT( FALSE, "S2 mauvaise branche" );
  end case;

  --| S3 : littéral selecte a travers un renommage de paquetage
  C := RP.BLUE;
  ASSERT( VP_PACK.COLOR'POS( C ) = 2, "S3 RP.BLUE" );

  --| S4 : littéral selecte a travers une instance de generique
  M := INST.M_OUT;
  ASSERT( INST.MODE'POS( M ) = 1, "S4 INST.M_OUT" );
  M := INST.M_IN;
  ASSERT( INST.MODE'POS( M ) = 0, "S4 INST.M_IN" );

  --| S5 : littéral selecte alors qu'un use est DEJA en portee
  declare
    use VP_PACK;
  begin
    C := VP_PACK.RED;
    ASSERT( COLOR'POS( C ) = 0, "S5 selection sous use" );
  end;

  --| S6 : littéral selecte en actual d'un appel surcharge
  TAKE( VP_PACK.RED );
  ASSERT( LAST = 1, "S6 TAKE COLOR" );
  TAKE( INST.M_IN );
  ASSERT( LAST = 2, "S6 TAKE MODE" );

  --| S7 : CONTROLE — declaration non littérale, memes trois prefixes
  ASSERT( VP_PACK.CONST = 42, "S7 VP_PACK.CONST" );
  ASSERT( RP.CONST     = 42, "S7 RP.CONST" );
  ASSERT( INST.NIL     =  7, "S7 INST.NIL" );

  --| S8 : CONTROLE — littéral en nom simple rendu visible par use
  declare
    use VP_PACK;
  begin
    C := BLUE;
    ASSERT( COLOR'POS( C ) = 2, "S8 nom simple sous use" );
  end;

  PUT_LINE( "RESULTAT : " & INTEGER'IMAGE( NB_OK ) & " OK, "
	& INTEGER'IMAGE( NB_KO ) & " ECHECS" );
  if  NB_KO = 0  then
    PUT_LINE( "VISEL_TEST PASSE" );
  else
    PUT_LINE( "VISEL_TEST ECHOUE" );
  end if;

end VISEL_TEST;
