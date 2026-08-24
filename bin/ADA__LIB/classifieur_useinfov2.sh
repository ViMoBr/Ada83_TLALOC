#!/bin/bash
# classe_use_info.sh -- classe chaque 'La ..., STANDARD._STRING.use__info' en MORT (dead store,
# __u re-ecrit dans les 25 lignes qui suivent) ou VIVANT (le doublet garde le patron).
for f in *.FINC ; do
  grep -n "STANDARD\._STRING\.use__info" "$f" | while IFS=: read -r ln _ ; do
    tgt=$(sed -n "$((ln+1))p" "$f" | sed -n 's/.*Sa[[:space:]]*[0-9]*,[[:space:]]*\([A-Za-z0-9_.]*__u\).*/\1/p')

    if [ -z "$tgt" ] ; then
      echo "$f:$ln: ??? (pas de Sa __u juste apres -- lecteur ou forme inattendue) :"
      sed -n "$((ln-3)),$((ln+3))p" "$f" | sed 's/^/    /'
      continue
    fi

    seg=$(awk -v s=$((ln+2)) 'NR>=s { if (NR>s && (/var elab/ || /^begin:/ || /^PRO\t/ || /^if defined /)) exit; print }' "$f")
    if printf '%s\n' "$seg" | grep -q "Sa[[:space:]]*[0-9]*,[[:space:]]*$tgt" ; then
      echo "$f:$ln: MORT  ($tgt re-ecrit avant la fin de son elaboration -- classe B, benin)"

    else
      echo "$f:$ln: VIVANT ($tgt garde le patron) :"
      sed -n "$((ln-8)),$((ln+4))p" "$f" | sed 's/^/    /'
    fi

  done
done
