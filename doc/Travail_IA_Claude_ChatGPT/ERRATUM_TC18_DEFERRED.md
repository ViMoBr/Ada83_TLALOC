# ERRATUM TC-18 - DO_DEFERRED : LES DIFFERES DES CORPS MORTS (E5)
(21 aout 2026 - s'applique sur l'etat post-TC-18)

DIAGNOSTIC (byte-diff integral de DIS_BONJOUR, sandbox) : 22520 octets
contre 22488 chez fasmg - 32 octets d'ecart, la taille exacte d'un bloc
STR VIDE. Analyse structurelle des zones differees : 22 blocs contre
21, le surnumeraire est le STR vide de RET_STR_L57 - porte par un corps
de sous-programme JAMAIS ATTEINT, que la garde du fasmg saute
entierement. P2, P2B et P3 filtrent par ACTIVE(E) ; DO_DEFERRED, lui,
iterait la table des differes (remplie a P0, avant que la portee ne
soit connue) SANS ce filtre : le differe du corps mort fuyait.

(Cette livraison est une INSERTION PURE ; l'ancre et sa reprise citent
un commentaire existant contenant un tiret cadratin - seule entorse a
la regle ASCII, imposee par la citation exacte.)

## COMMIT UNIQUE - EMITS : filtre ACTIVE dans DO_DEFERRED

### MODIFICATION 1.1 - target_code-emits.adb (insertion pure)
ANCRE (texte existant, unique) :
<<<
	if E < FROM  or else  E > TO
	then											--| liste GLOBALE, plage locale : les differes des
	  null;											--| temoins precedents ne fuient plus ici (fuite
												--| 'Bonjour' vue au byte-diff, cmp octet 97 —
												--| emise DERNIERE : meme la fuite etait LIFO)
>>>
SUPPRIMER : le texte de l'ancre elle-meme (repris a l'identique en tete du remplacement).
REMPLACER PAR (ancre reprise inchangee + insertion) :
<<<
	if E < FROM  or else  E > TO
	then											--| liste GLOBALE, plage locale : les differes des
	  null;											--| temoins precedents ne fuient plus ici (fuite
												--| 'Bonjour' vue au byte-diff, cmp octet 97 —
												--| emise DERNIERE : meme la fuite etait LIFO)
	elsif not PASSES.ACTIVE( E )
	then											--| differe d'un CORPS MORT (paresse n 110) :
	  null;											--| fasmg le saute avec sa garde, nous aussi
												--| (STR vide de RET_STR_L57, 32 octets, releve
												--| du byte-diff integral du 21 aout)
>>>

ORACLE (quadruple) : compilation ; rejeu TC-04..17 entier (douze cmp
muets - aucun temoin n'a de differe mort : octets inchanges) ;
l'avalement rend 21 blocs differes et LE CMP INTEGRAL MUET ;
executions conformes.
