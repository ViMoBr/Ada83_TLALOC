# LIVRAISON — segfaults T2 lot goto (lex.adb & 5 frères)

Format : une modification = ANCRE (texte existant unique, inchangé, sert de repère
juste AVANT le bloc visé) + SUPPRIMER (bloc exact, octet pour octet) + REMPLACER.
Tabulations réelles préservées dans les blocs.

---------------------------------------------------------------------------
## COMMIT 1 — CODE_INDEXED : double empilement de l'@data pour un préfixe
##            NOM ÉTENDU (PKG.ARR(I)) — fuite de pile +1, fatale dans un
##            bloc de paramètres (result__ofs décalé, BLKMOV de CODE_RETURN
##            à travers [@table+8])
---------------------------------------------------------------------------

### MODIFICATION 1.1 — expander-expressions.adb

#### ANCRE (unique, inchangée — fin du bloc NAME_DN_ALL, juste au-dessus)
```
      end				NAME_DN_ALL;
```

#### SUPPRIMER (bloc exact, ~7 lignes sous l'ancre)
```
    if  NAME.TY = DN_SELECTED  then
      CODE_SELECTED( NAME, IS_SOURCE=> FALSE );
      NAME := D( AS_DESIGNATOR, NAME );
    end if;
```

#### REMPLACER PAR
```
    if  NAME.TY = DN_SELECTED  then
			--| n 148 (segfaults T2 lot goto : lex, lib_phase, err_phase,
			--| expressions, declarations, ada_comp -- 12/08) : DOUBLE
			--| EMPILEMENT de l'@data pour un prefixe NOM ETENDU PKG.ARR(I).
			--| CODE_SELECTED empilait l'adresse de la table, puis la queue
			--| commune (ARRAY_DEFN /= DN_COMPONENT_ID) la RE-empilait --
			--| fuite +1 par reference, resorbee aux frontieres d'instruction
			--| SAUF quand elle nait dans un bloc de parametres : le calle
			--| lisait -result__ofs = @table nue, SIq corrompait [table+0]
			--| en silence et le BLKMOV d'info de CODE_RETURN visait
			--| [table+8] (petit champ de l'element 1) -- stos sur 0x1.
			--| Empreinte FINC : deux "La n, ...ARR_disp" CONSECUTIFS.
			--| Seul le COMPOSANT (R.A(N)) doit pre-empiler l'adresse --
			--| meme predicat que la queue commune : DN_COMPONENT_ID.
      if  D( SM_DEFN, D( AS_DESIGNATOR, NAME ) ).TY = DN_COMPONENT_ID  then
	CODE_SELECTED( NAME, IS_SOURCE=> FALSE );
      end if;
      NAME := D( AS_DESIGNATOR, NAME );
    end if;
```

### ORACLE DU COMMIT 1

O1 — Empreinte AVANT (juge de paix du diagnostic, sans recompiler) :
	grep -n -B1 "GOTO_LABELS_disp" <expander-instructions .finc courant>
    montre deux `La` consécutifs identiques dans CODE_GOTO_L136 (idem
    GOTO_PENDING_disp, idem CODE_LABELED). APRÈS régénération par T1
    corrigé : un seul `La` par référence.

O2 — Reconstruire T1 (gnat), régénérer les FINC, réassembler T2', puis :
	./T2 ./ ../../src/par_phase/lex.adb W
    passe sans segfault. Puis passe complète : les 6 unités passent, et
    expander-declarations-types_decls repasse (ancêtre compilé).

O3 — Non-régression composants : REC_ARR_TEST (tests 30 et 37 — R.A(N),
    tranches de composant) reste vert : le chemin DN_COMPONENT_ID est
    inchangé à l'octet près.

O4 — Diff FINC des unités déjà vertes : vide SAUF aux sites PKG.ARR(I)
    (un `La` en moins par référence) — diff attendu, à archiver comme
    référence du commit.

O5 — Témoin neuf GOTO_SELARG_TEST (annexe A) : rouge capturé avec T1
    COURANT (le binaire du témoin segfaulte à l'exécution sur l'appel
    F( PKG.T(I).LBL ) en concaténation), vert avec T1 corrigé.
    Gardien à inscrire au piège n 148.

O6 — Filet + ACVC verts, checks ON.

### À RECENSER AU MÊME LOT (famille, hors commit)

- CODE_SLICE, branche préfixe DN_SELECTED (l. ~1160) : structure
  différente (pas de queue commune ré-empilante) — vérifier au FINC
  qu'aucun PKG.ARR(A..B) ne produit le motif double-La.
- Grep systématique de l'empreinte sur TOUS les FINC régénérés :
	grep -n -B1 "_disp$" *.finc | awk 'motif deux La consécutifs identiques'
  (aucune occurrence attendue après correctif).
- PIEGES.md : consigner n 148 après capture du rouge (O5), avec
  l'empreinte FINC et la leçon : une fuite de pile est bénigne aux
  frontières d'instruction et létale dans un bloc de paramètres —
  chercher les fuites AU SITE D'APPEL, pas dans le callé (jumelle du
  n 140).

---------------------------------------------------------------------------
## ANNEXE A — Témoin GOTO_SELARG_TEST (fichier NEUF : goto_selarg_test.adb)
---------------------------------------------------------------------------
Reproduit la forme exacte du crash : table de records au niveau paquetage,
index runtime, champ scalaire passé en actuel d'une fonction à résultat
STRING, appel en opérande de concaténation, plus un goto arrière et un
goto avant pour exercer CODE_GOTO/CODE_LABELED du T2 qui le compilera.

```
with TEXT_IO;  use TEXT_IO;

procedure GOTO_SELARG_TEST  is

  package PKG  is
    type REC  is record
		    ID  : INTEGER;		-- occupe [elem+0]
		    LBL : INTEGER;		-- lu a [elem+8] par le bug
		  end record;
    T   : array( 1 .. 4 ) of REC;
    TOP : INTEGER := 3;
  end PKG;

  function  LSTR ( N : INTEGER )  return STRING  is
    S : constant STRING := INTEGER'IMAGE( N );
  begin
    return 'L' & S( S'FIRST + 1 .. S'LAST );
  end LSTR;

  I : INTEGER := 0;

begin
  for K in PKG.T'RANGE  loop
    PKG.T( K ) := ( ID => K, LBL => 10 * K + 2 );
  end loop;

<<ARRIERE>>				-- CODE_LABELED du compilateur hote
  I := I + 1;

  -- la forme fautive : PKG.ARR( index runtime ).champ en actuel,
  -- appel en operande de "&"
  PUT_LINE( "tour" & INTEGER'IMAGE( I ) & " -> " & LSTR( PKG.T( PKG.TOP ).LBL ) );

  if  I < 2  then
    goto ARRIERE;			-- CODE_GOTO arriere du compilateur hote
  end if;

  if  I = 2  then
    goto AVANT;				-- CODE_GOTO avant
  end if;

  PUT_LINE( "jamais atteint" );

<<AVANT>>
  PUT_LINE( "fin -> " & LSTR( PKG.T( 1 ).LBL ) );
end GOTO_SELARG_TEST;
```

Verdict attendu (T1 corrigé, exécution du binaire) :
	tour 1 -> L32
	tour 1 -> ... (tour 2 -> L32)
	fin -> L12
Avec T1 courant : segfault à l'exécution sur le premier PUT_LINE
(BLKMOV, rdi = valeur du champ [T(1)+8]).
