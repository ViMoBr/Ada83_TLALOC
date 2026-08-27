# PATCH CODI - MACRO VAR : REPLI DE CASSE OPERANT (unites B/W/D/Q)
(20 aout 2026 - fichier : src/expander/fasmg/codi_x86_64.finc)

DEFAUT (demontre par experience minimale, fasmg g.l8vn) : le repli
actuel assigne le PARAMETRE ("sizChar = 'b'" avec sizChar substitue =
"Q = 'q'" : definit un symbole global !) puis reteste au BACKTICK -
qui rend le TEXTE d'origine ('Q') : la branche taille-nommee est prise
et "rb sizChar" reserve la VALEUR du symbole fraichement defini, soit
le code du caractere ('q' = 113 octets). Deux "VAR X, Q" allouent 248
octets au lieu de 24 (lea rbp,[rbp+0xF8] vs +0x18, releve). Le corpus
regenere emet 656 unites majuscules : tout assemblage fasmg de ces FINC
produirait des frames faux, silencieusement.

CORRECTIF : branches directes par casse, sans assignation du parametre
(les octets des unites minuscules sont INCHANGES : meme expansion).

### MODIFICATION UNIQUE - codi_x86_64.finc (sur place, auto-localisee)
ANCRE = BLOC A SUPPRIMER (texte existant, unique) :
<<<
macro			VAR	name_disp, sizChar, siz:1		; Definition d'un lieu de variable
;			-----------------------------------
  virtual VARzone
    if `sizChar = 'B'
      sizChar = 'b'
    end if
    if `sizChar = 'W'
      sizChar = 'w'
    end if
    if `sizChar = 'D'
      sizChar = 'd'
    end if
    if `sizChar = 'Q'
      sizChar = 'q'
    end if

    if `sizChar = 'b'  |  `sizChar = 'w'  |  `sizChar = 'd'  |  `sizChar = 'q'
      align_#sizChar
      name_disp = $							; displacement des data de variable
      r#sizChar siz							; reservation
    else
      align_q							; assurer l'alignement de pile dans tous les cas possibles
      name_disp = $							; displacement des data de variable
      rb sizChar
    end if
  end virtual
end macro
>>>
REMPLACER PAR :
<<<
macro			VAR	name_disp, sizChar, siz:1		; Definition d'un lieu de variable
;			-----------------------------------
  virtual VARzone
    if `sizChar = 'b' | `sizChar = 'B'
      align_b
      name_disp = $							; displacement des data de variable
      rb siz								; reservation
    else if `sizChar = 'w' | `sizChar = 'W'
      align_w
      name_disp = $
      rw siz
    else if `sizChar = 'd' | `sizChar = 'D'
      align_d
      name_disp = $
      rd siz
    else if `sizChar = 'q' | `sizChar = 'Q'
      align_q
      name_disp = $
      rq siz
    else
      align_q							; assurer l'alignement de pile dans tous les cas possibles
      name_disp = $							; displacement des data de variable
      rb sizChar
    end if
  end virtual
end macro
>>>

ORACLE : (1) l'experience minimale - un .fas a deux "VAR X, Q" et sa
copie en "q" assemblent OCTET POUR OCTET identiques (alloc 24) ;
(2) la batterie TC-04..14 entiere reste muette (unites minuscules :
expansion inchangee ; TC-14 en majuscules : desormais identique) ;
(3) plus AUCUN symbole parasite B/D/Q/W defini par les VAR.
