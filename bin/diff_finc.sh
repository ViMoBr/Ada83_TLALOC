#!/bin/bash
#-----------------------------------------------------------------------------------------------------------------------
# diff_finc.sh -- ORACLE DE POINT FIXE : comparer les FINC produits par T1
# et par T2, tels qu'ils sont deja en place.
#
#   T1 (ada_comp, lance par ./a83.sh depuis /bin)          -> FINC dans /bin/ADA__LIB
#   T2 (ADA_COMP, lance par ./T2.sh depuis /bin/ADA__LIB)  -> FINC dans /bin/ADA__LIB/ADA__LIB
#
# A LANCER DEPUIS /bin :   ./diff_finc.sh
#
# Principe : on parcourt les FINC du cote T2 (la bibliotheque imbriquee =
# exactement la campagne bootstrappee) et on compare chacun a son homonyme
# cote T1. Identite attendue a la fin de ligne pres (piege n 131 : CRLF).
# Toute divergence = miscompilation latente de T2, MEME si la compilation
# "passe" (lecon du n 145).
# Les FINC presents cote T1 seulement (p.ex. la compilation du compilateur
# lui-meme) sont comptes a part, pour information.
#-----------------------------------------------------------------------------------------------------------------------

LIB_T1=./ADA__LIB
LIB_T2=./ADA__LIB/ADA__LIB
OUT=./diff_finc
REPORT="$OUT/RAPPORT.txt"

rm -rf "$OUT" ; mkdir -p "$OUT"
: > "$REPORT"

NB_ID=0 ; NB_DIFF=0 ; NB_MANQ=0

shopt -s nullglob

for F2 in "$LIB_T2"/*.FINC "$LIB_T2"/*.finc ; do
  F=$(basename "$F2")
  F1="$LIB_T1/$F"

  if [ ! -f "$F1" ] ; then
    echo "$F : MANQUANT cote T1"                                    | tee -a "$REPORT"
    NB_MANQ=$((NB_MANQ+1)) ; continue
  fi

  if diff <(tr -d '\r' < "$F1") <(tr -d '\r' < "$F2") > "$OUT/last.diff" 2>&1 ; then
    echo "$F : IDENTIQUE"                                           | tee -a "$REPORT"
    NB_ID=$((NB_ID+1))
  else
    echo "$F : DIVERGENT ($(grep -c '^[<>]' "$OUT/last.diff") lignes)" | tee -a "$REPORT"
    echo "  premieres lignes :"                                     >> "$REPORT"
    head -30 "$OUT/last.diff" | sed 's/^/  /'                       >> "$REPORT"
    cp "$OUT/last.diff" "$OUT/$F.diff"                              # diff complet conserve
    NB_DIFF=$((NB_DIFF+1))
  fi
done

# ---- information : FINC presents cote T1 seulement (hors campagne T2) ----
NB_T1_SEUL=0
for F1 in "$LIB_T1"/*.FINC "$LIB_T1"/*.finc ; do
  F=$(basename "$F1")
  if [ ! -f "$LIB_T2/$F" ] ; then
    NB_T1_SEUL=$((NB_T1_SEUL+1))
    echo "(info) $F : cote T1 seulement"                            >> "$REPORT"
  fi
done

echo "------------------------------------------------------------"  | tee -a "$REPORT"
echo "BILAN : $NB_ID identiques, $NB_DIFF divergents, $NB_MANQ manquants cote T1 ($NB_T1_SEUL cote T1 seulement, hors campagne)" | tee -a "$REPORT"
if [ "$NB_DIFF" = 0 ] && [ "$NB_MANQ" = 0 ] && [ "$NB_ID" -gt 0 ] ; then
  echo "POINT FIXE PREDEFINIS : ATTEINT"                             | tee -a "$REPORT"
else
  echo "POINT FIXE PREDEFINIS : NON ATTEINT -- diffs complets dans $OUT/" | tee -a "$REPORT"
fi
