# BLOCS À COLLER — session du 12 août 2026 (piège n° 148 + point fixe T3)

Chaque bloc est autonome. L'emplacement d'insertion est indiqué en tête de
bloc ; le contenu à coller est entre les lignes `----8<----`.

=============================================================================
## BLOC 1 — PIEGES.md, à la suite du n° 147 (fin de fichier)
=============================================================================

----8<-------------------------------------------------------------------

148. ** double empilement de l'@data pour un préfixe
NOM ÉTENDU ** dans CODE_INDEXED, un préfixe DN_SELECTED déclenchait
CODE_SELECTED( IS_SOURCE => FALSE ) qui empilait l'adresse de la table,
puis la queue commune (ARRAY_DEFN /= DN_COMPONENT_ID) la RE-empilait :
pour PKG.ARR( I ) — désignateur DN_VARIABLE_ID — fuite de pile +1 par
référence. Bénigne aux frontières d'instruction (résorbée), LÉTALE quand
elle naît dans un bloc de paramètres : le quadmot parasite s'intercale
entre le lieu-résultat et l'actuel, le callé lit -result__ofs = @table
NUE, son SIq corrompt [table+0] en silence (inscriptible, pas de faute)
et le BLKMOV d'info de CODE_RETURN vise [table+8] = petit champ de
l'élément 1 -> stos sur 0x1, segfault dans l'ÉPILOGUE DU CALLÉ alors que
la faute est au SITE D'APPEL. Symptôme : les 6 segfaults du bootstrap T2
(lex, idl-lib_phase, idl-err_phase, expander-expressions,
expander-declarations, ada_comp + types_decls collatéral) = exactement
les unités contenant goto/étiquette, car les seuls PKG.ARR(I).champ du
compilateur passés en actuels vivent dans CODE_GOTO/CODE_LABELED
(CODI.GOTO_LABELS(E).LBL, CODI.GOTO_PENDING(TOP).LBL_G -> LABEL_STR).
Diagnostic différentiel : PAS la co-pile (signature n° 109 absente :
ici stos de BLKMOV, pas mov [r14],r13 à l'ELB) ; le paramètre LBL était
LU JUSTE (tranche 2..3 en pile) -> un seul quadmot parasite, entre
result__ofs et l'actuel. Empreinte FINC irréfutable : deux
`La n, ...ARR_disp` CONSÉCUTIFS IDENTIQUES avant l'indexation.
Correctif : garde sur le pré-empilement — seul le COMPOSANT (R.A(N))
pré-empile, même prédicat que la queue commune :
`D( SM_DEFN, D( AS_DESIGNATOR, NAME ) ).TY = DN_COMPONENT_ID` ;
tout autre désignateur (variable, constante, paramètre de nom étendu)
est servi par la queue (REGIONS_PATH absolu, checks via ARR__u,
IS_PARAM). Chemin DN_COMPONENT_ID inchangé à l'octet près. Vérifié :
les 6 unités passent, 63 FINC T2 identiques aux FINC T1. Gardien :
GOTO_SELARG_TEST (forme exacte PKG.T(I).LBL en actuel d'une fonction
STRING sous concaténation + goto arrière + goto avant ; rouge
reproductible avec le T1 d'avant-commit) et l'oracle suprême du point
fixe (diff des 63 FINC). Leçons : (a) une fuite de pile se cherche AU
SITE D'APPEL, pas dans le callé — jumelle du n° 113 (result__ofs) et
cousine du n° 141 (collisions ANON, l'audit recommandé pointait un cran
trop haut) ; (b) un crash « dans » une routine ultra-exercée innocente
la routine et accuse la forme de l'appel. À recenser : grep de
l'empreinte double-La sur TOUS les FINC régénérés (aucune occurrence
attendue) ; CODE_SLICE préfixe DN_SELECTED (structure différente, pas
de queue ré-empilante — vérifier au FINC qu'aucun PKG.ARR(A..B) ne
produit le motif).

----8<-------------------------------------------------------------------

=============================================================================
## BLOC 2 — PIEGES.md ou ETAT_PILIERS.md (section jalons), l'événement
=============================================================================

----8<-------------------------------------------------------------------

JALON — POINT FIXE DU BOOTSTRAP, 12 août 2026, 13h20.
T1 (compilé gnat) -> 63 FINC -> T2 (fasmg). T2 recompile les 63 unités :
FINC(T2) IDENTIQUES à FINC(T1), octet pour octet, checks ON. fasmg
produit T3 = T2. TLALOC est auto-hébergé et idempotent. Le diff des
63 FINC entre deux générations devient l'ORACLE DE NON-RÉGRESSION
SUPRÊME : tout remaniement futur (mark/release co-pile, scission
d'expander-expressions, optimiseur) doit le laisser vide ou justifier
chaque ligne du diff.

----8<-------------------------------------------------------------------

=============================================================================
## BLOC 3 — ETAT_PILIERS.md, nouvelle ligne du tableau des piliers
##          (ou remplacement de la ligne BOOTSTRAP si elle existe)
=============================================================================

----8<-------------------------------------------------------------------

|BOOTSTRAP AUTO-HÉBERGEMENT|POINT FIXE ATTEINT (12/08/2026, 13h20). Chaîne : T1 (gnat) -> 63 FINC -> fasmg -> T2 ; T2 recompile les 63 sources (option W, checks ON) -> FINC identiques à ceux de T1 -> fasmg -> T3 = T2. Dernier verrou : piège n° 148 (CODE_INDEXED, double empilement de l'@data pour un préfixe nom étendu PKG.ARR(I) ; fuite +1 létale dans un bloc de paramètres ; les 6 segfaults résiduels — lex, idl-lib_phase, idl-err_phase, expander-expressions, expander-declarations, ada_comp — étaient exactement les unités à goto/étiquette, un seul commit les a tous levés). Diagnostic différentiel co-pile écarté (signature n° 109 absente) ; plafond co-pile 1 Go (n° 147) suffisant pour la passe complète. Gardiens : GOTO_SELARG_TEST + diff des 63 FINC (oracle suprême, à rejouer après tout remaniement). Chantiers ouverts, désormais NON urgents : récupération saine de la co-pile (n° 147), scission d'expander-expressions, fossiles dormants (n° 145).|

----8<-------------------------------------------------------------------

=============================================================================
## BLOC 4 — JOURNAL, entrée du jour
=============================================================================

----8<-------------------------------------------------------------------

## 12 août 2026 — Les 6 derniers segfaults, un seul bug ; POINT FIXE à 13h20

Session gdb + lecture systématique sur le segfault de T2 compilant
lex.adb (rapport seg_fault_T2_lex.md). Démarche et verdicts :

1. Co-pile ÉCARTÉE en dix minutes par signature (n° 109 : faute au
   mov [r14],r13 du prochain ELB ; ici stos d'un BLKMOV dans l'épilogue
   de LABEL_STR, rdi=1). Le callé LABEL_STR innocenté : exercé par
   toutes les unités vertes.
2. Fil conducteur trouvé : CODE_GOTO/CODE_LABELED ne s'exécutent que si
   l'unité compilée contient goto/étiquette. Les 6 unités en échec sont
   EXACTEMENT celles-là (vérifié sur les 2 du projet, confirmé par grep
   sur les 4 autres). Un bug, pas six.
3. Décodage du crash : le paramètre LBL était lu juste (tranche 2..3 en
   pile) -> UN quadmot parasite entre le lieu-résultat et l'actuel ->
   -result__ofs du callé visait une @table nue ; SIq corrompait
   [table+0] en silence, BLKMOV fautait sur [table+8]=1.
4. Coupable : CODE_INDEXED, double empilement de l'@data pour un préfixe
   nom étendu (CODE_SELECTED PUIS la queue commune). Empreinte FINC :
   deux `La ...GOTO_LABELS_disp` consécutifs identiques — vérifiée AVANT
   correctif, disparue APRÈS. Piste n° 141 (collisions ANON) écartée en
   chemin : l'audit recommandé pointait PREPARE_ARRAY_RESULT_PLACE, le
   trou était un cran plus bas, dans le préfixe de l'actuel.
5. Correctif : garde DN_COMPONENT_ID sur le pré-empilement (même
   prédicat que la queue commune ; chemin R.A(N) inchangé à l'octet).
   Livraison ancrée LIVRAISON_FIX_INDEXED_NOM_ETENDU.md, commit unique.
6. VERDICT : les 6 unités passent. Passe complète : 63 FINC produits par
   T2, contrôlés IDENTIQUES à ceux de T1. fasmg -> T3 = T2 à 13h20.
   **POINT FIXE DU BOOTSTRAP ATTEINT.** Consigné : piège n° 148, jalon
   ETAT_PILIERS, témoin GOTO_SELARG_TEST au filet.

Leçon de méthode (au piège) : un crash dans une routine ultra-exercée
innocente la routine et accuse la FORME de l'appel ; une fuite de pile
se cherche au site d'appel. Et : la table PIEGES a payé deux fois dans
la même session (n° 109 pour écarter, n° 141 pour orienter).

----8<-------------------------------------------------------------------

=============================================================================
## BLOC 5 — ORACLES_TESTS.md, nouveau témoin
=============================================================================

----8<-------------------------------------------------------------------

## GOTO_SELARG_TEST — gardien du piège n° 148 (préfixe nom étendu indexé)

Source : tests/goto_selarg_test.adb (livré avec le commit n° 148).
Forme exacte du bug : table de records au niveau paquetage, index
runtime, champ scalaire passé en actuel d'une fonction à résultat
STRING, appel en opérande de concaténation ; plus un goto arrière et un
goto avant (exercent CODE_GOTO/CODE_LABELED du compilateur HÔTE quand ce
témoin sert de source compilée).

Verdict attendu (exécution du binaire, checks ON) :
	tour 1 -> L32
	tour 2 -> L32
	fin -> L12

Rouge de référence : reproductible en recompilant le témoin avec le T1
d'AVANT le commit n° 148 (segfault à l'exécution sur le premier
PUT_LINE : BLKMOV, rdi = valeur du champ à [T(1)+8]).

Oracle FINC associé (sans exécution) : sur le FINC du témoin,
	grep -n -B1 "T_disp"
ne doit montrer AUCUNE paire de `La` consécutifs identiques.

Oracle suprême du dépôt (rappel, hérite de cette session) : diff des
63 FINC entre la génération T1 et la génération T2 = VIDE. À rejouer
après tout remaniement de l'expander.

----8<-------------------------------------------------------------------

=============================================================================
## BLOC 6 — INDEX_DEPOT_TLALOC.md, section des tests (table des témoins)
=============================================================================

----8<-------------------------------------------------------------------

| `goto_selarg_test.adb` | Gardien du piège n° 148 — PKG.ARR(I).champ en actuel + goto avant/arrière ; rouge de référence avec le T1 d'avant-commit |

----8<-------------------------------------------------------------------

=============================================================================
## BLOC 7 — INDEX_DEPOT_TLALOC.md, section racine ou documentation
##          (référencer la livraison si elle est archivée au dépôt)
=============================================================================

----8<-------------------------------------------------------------------

| `LIVRAISON_FIX_INDEXED_NOM_ETENDU.md` | Livraison ancrée du commit n° 148 (correctif CODE_INDEXED + oracle + témoin) — archive de la session point fixe du 12/08/2026 |

----8<-------------------------------------------------------------------

=============================================================================
## Notes de collage
=============================================================================

- Bloc 1 : la numérotation suit le n° 147 (dernier consigné). Le corps
  suit le gabarit des n° 146/147 (mécanisme, symptôme, diagnostic,
  correctif, gardien, leçons, à recenser), largeur ~72 colonnes.
- Bloc 2 : si ETAT_PILIERS a une section « jalons », le mettre là ;
  sinon en tête de PIEGES.md ou du journal, au choix — l'important est
  que la date et l'oracle suprême soient consignés une fois.
- Bloc 5 : si le rouge n'a pas été capturé en pratique (le correctif est
  parti directement au point fixe), la formulation « reproductible avec
  le T1 d'avant-commit » reste exacte — noter le hash du commit
  précédent à côté pour que la reproduction reste à un checkout près.
- Deux recensements restent ouverts après collage (repris dans le n° 148,
  champ « À recenser ») : le grep d'empreinte double-La sur tous les
  FINC, et l'audit CODE_SLICE préfixe DN_SELECTED. Dix minutes à deux,
  à faire à froid.
