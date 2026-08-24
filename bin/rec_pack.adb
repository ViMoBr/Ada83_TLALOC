------------------------------------------------------------------------------------------------------------------------
-- REC_PACK (corps) -- l'elab_spec de CE corps re-emet le bloc info des records : c'etait la troncature d'origine.
-- Les indexations de L.BDY passent par le prefixe RECORD-PARAMETRE (CODE_SELECTED param + CODE_INDEXED direct).
------------------------------------------------------------------------------------------------------------------------
package body REC_PACK is

		---
  procedure	SET	( L : in out LIGNE;  S : STRING )
  is		---
  begin
    for I in 1 .. S'LENGTH loop
      L.BDY( I ) := S( I );					-- ecriture composant indexe (destination) + lecture formel STRING
    end loop;
    L.LEN := S'LENGTH;
  end	SET;
	---

		----
  procedure	POSE	( L : in out LIGNE;  I : POSITIVE;  C : CHARACTER )
  is		----
  begin
    L.BDY( I ) := C;
  end	POSE;
	----

		---
  function	GET	( L : LIGNE;  I : POSITIVE )	return CHARACTER
  is		---
  begin
    return L.BDY( I );						-- lecture composant indexe (source) -- le chemin corrige
  end	GET;
	---

end REC_PACK;
