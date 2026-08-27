# LIVRAISON TC-21 - COMPLETION DE EMITS : LE CODI ENTIER (26 mnemoniques)
(23 aout 2026 - s'applique sur VOS sources du 23 aout, reperes 'a faire'.)

Chaque commentaire '-- X a faire' est REMPLACE par l'entree transcrite du
codi ; les groupes contigus d'un bloc. BLKOU et BLKOUX sont groupes avec
BLKAND (une entree, opcode selectionne). S'ajoutent E_FETCH_W (48 0F BF)
et E_FETCH_WU (0F B7), et le temoin TC-21 en queue de pilote (commit 2).
LEXCMP : 96 + paire de charges (siz 1/2 : signe 8, non signe 6 ; siz 4 :
6/4 ; siz 8 : 6) ; sauts relatifs internes parametres par cette taille.
Apres application il ne reste AUCUN 'a faire' dans EMITS.

## COMMIT 1 - EMITS : helpers mot + 26 entrees

### MODIFICATION 1.0 - target_code-emits.adb (insertion pure : helpers mot)
ANCRE (texte existant, unique) :
<<<
end	E_FETCH_DU;
>>>
SUPPRIMER : le texte de l'ancre elle-meme (repris a l'identique en tete du remplacement).
REMPLACER PAR (ancre reprise inchangee + insertion) :
<<<
end	E_FETCH_DU;
	----------

			---------
  procedure		E_FETCH_W		( D :SYMBOLS.VALUE_TYPE )					--| movsx rax, word [rax+d]
  is			---------
  begin
    B( 16#48# ); B( 16#0F# ); B( 16#BF# );
    E_MODRM_DISP( 16#00#, 16#40#, 16#80#, D );
  end	E_FETCH_W;
	---------

			----------
  procedure		E_FETCH_WU	( D :SYMBOLS.VALUE_TYPE )					--| movzx rax, word [rax+d]
  is			----------
  begin
    B( 16#48# ); B( 16#0F# ); B( 16#B7# );
    E_MODRM_DISP( 16#00#, 16#40#, 16#80#, D );
  end	E_FETCH_WU;
>>>

### MODIFICATION 1.1 - target_code-emits.adb (sur place : LW SIZE_OF)
ANCRE = BLOC A SUPPRIMER (texte existant, unique, auto-localisant) :
<<<
-- LW  a faire

    elsif  M = "LD"  then return S_BASE( OPV( E, 1, -1 ) ) + S_DISP( OPV( E, 2, 0 ), 3 ) + 8;
>>>
REMPLACER PAR :
<<<
    elsif  M = "LW"  then return S_BASE( OPV( E, 1, -1 ) ) + S_DISP( OPV( E, 2, 0 ), 4 ) + 8;

    elsif  M = "LD"  then return S_BASE( OPV( E, 1, -1 ) ) + S_DISP( OPV( E, 2, 0 ), 3 ) + 8;
>>>

### MODIFICATION 1.2 - target_code-emits.adb (sur place : ULIW SIZE_OF)
ANCRE = BLOC A SUPPRIMER (texte existant, unique, auto-localisant) :
<<<
-- ULIW a faire
>>>
REMPLACER PAR :
<<<
    elsif  M = "ULIW"  then return S_BASE( OPV( E, 1, -1 ) ) + S_DISP( OPV( E, 2, 0 ), 3 )
						+ S_DISP( OPV( E, 3, 0 ), 4 ) + 8;
>>>

### MODIFICATION 1.3 - target_code-emits.adb (sur place : LIB/LIW SIZE_OF)
ANCRE = BLOC A SUPPRIMER (texte existant, unique, auto-localisant) :
<<<
-- LIB a faire
-- LIW a faire

    elsif  M = "LID"  then return S_BASE( OPV( E, 1, -1 ) ) + S_DISP( OPV( E, 2, 0 ), 3 )
>>>
REMPLACER PAR :
<<<
    elsif  M = "LIB"  then return S_BASE( OPV( E, 1, -1 ) ) + S_DISP( OPV( E, 2, 0 ), 3 )
						+ S_DISP( OPV( E, 3, 0 ), 4 ) + 8;

    elsif  M = "LIW"  then return S_BASE( OPV( E, 1, -1 ) ) + S_DISP( OPV( E, 2, 0 ), 3 )
						+ S_DISP( OPV( E, 3, 0 ), 4 ) + 8;

    elsif  M = "LID"  then return S_BASE( OPV( E, 1, -1 ) ) + S_DISP( OPV( E, 2, 0 ), 3 )
>>>

### MODIFICATION 1.4 - target_code-emits.adb (sur place : SIW SIZE_OF)
ANCRE = BLOC A SUPPRIMER (texte existant, unique, auto-localisant) :
<<<
-- SIW a faire
>>>
REMPLACER PAR :
<<<
    elsif  M = "SIW"  then
      return 8 + S_BASE( OPV( E, 1, -1 ) ) + S_DISP( OPV( E, 2, 0 ), 3 )
	     + S_DISP( OPV( E, 3, 0 ), 3 );
>>>

### MODIFICATION 1.5 - target_code-emits.adb (sur place : OU/NON SIZE_OF)
NOTE : les deux commentaires vivent AU MILIEU du elsif multi-lignes du
groupe des operations a 12 octets - OU rejoint ce groupe (POP_RAX + op
qword [rbp], rax, meme gabarit), NON (4 : not qword [rbp]) devient une
entree separee.
ANCRE = BLOC A SUPPRIMER (texte existant, unique, auto-localisant) :
<<<
    elsif M = "ET"

-- OU a faire
-- NON a faire

	or  M = "OUX"  or  M = "SHL" then return  12;
>>>
REMPLACER PAR :
<<<
    elsif M = "ET"
	or  M = "OU"
	or  M = "OUX"  or  M = "SHL" then return  12;

    elsif  M = "NON"  then return 4;								--| not qword [rbp]
>>>

### MODIFICATION 1.6 - target_code-emits.adb (sur place : SHR SIZE_OF)
ANCRE = BLOC A SUPPRIMER (texte existant, unique, auto-localisant) :
<<<
-- SHR a faire

		-----------------------------------------
>>>
REMPLACER PAR :
<<<
    elsif  M = "SHR"  then return 12;								--| POP_RCX + shr qword [rbp], cl

		-----------------------------------------
>>>

### MODIFICATION 1.7 - target_code-emits.adb (sur place : UBFX/SBFX/BFI SIZE_OF)
ANCRE = BLOC A SUPPRIMER (texte existant, unique, auto-localisant) :
<<<
-- UBFX a faire
-- SBFX a faire
-- BFI a faire
		-------------------------------------------------------------
>>>
REMPLACER PAR :
<<<
    elsif  M = "UBFX"  then return 42;								--| champ non signe (val, LSB, Width empiles)

    elsif  M = "SBFX"  then return 39;								--| champ signe (shl puis sar)

    elsif  M = "BFI"  then return 56;								--| insertion de champ (old, val, LSB, Width)
		-------------------------------------------------------------
>>>

### MODIFICATION 1.8 - target_code-emits.adb (sur place : ABS SIZE_OF)
ANCRE = BLOC A SUPPRIMER (texte existant, unique, auto-localisant) :
<<<
-- ABS a faire

    elsif  M = "CLAMP0"  then return  15;
>>>
REMPLACER PAR :
<<<
    elsif  M = "ABS"  then return 16;								--| (x xor allsign) - allsign

    elsif  M = "CLAMP0"  then return  15;
>>>

### MODIFICATION 1.9 - target_code-emits.adb (sur place : SAR SIZE_OF)
ANCRE = BLOC A SUPPRIMER (texte existant, unique, auto-localisant) :
<<<
    elsif  M = "MODI"  then return  48;

-- SAR a faire
>>>
REMPLACER PAR :
<<<
    elsif  M = "MODI"  then return  48;

    elsif  M = "SAR"  then return 12;								--| POP_RCX + sar qword [rbp], cl
>>>

### MODIFICATION 1.10 - target_code-emits.adb (sur place : FABS/FEXP SIZE_OF)
ANCRE = BLOC A SUPPRIMER (texte existant, unique, auto-localisant) :
<<<
    elsif  M = "FNEG"  then return 4;

-- FABS a faire
-- FEXP a faire
>>>
REMPLACER PAR :
<<<
    elsif  M = "FNEG"  then return 4;

    elsif  M = "FABS"  then return 4;								--| and byte [rbp+7], 7F (signe IEEE)

    elsif  M = "FEXP"  then return 47;								--| A ** N entier (boucle mulsd)
>>>

### MODIFICATION 1.11 - target_code-emits.adb (sur place : CVTXI SIZE_OF)
ANCRE = BLOC A SUPPRIMER (texte existant, unique, auto-localisant) :
<<<
-- CVTXI a faire


				-----------------------
>>>
REMPLACER PAR :
<<<
    elsif  M = "CVTXI"  then return 70;								--| X*NUMER/DENOM arrondi au plus pres


				-----------------------
>>>

### MODIFICATION 1.12 - target_code-emits.adb (sur place : FCEQ SIZE_OF)
ANCRE = BLOC A SUPPRIMER (texte existant, unique, auto-localisant) :
<<<
-- FCEQ a faire

    elsif  M = "FCNE"  then return  28;
>>>
REMPLACER PAR :
<<<
    elsif  M = "FCEQ"  then return 28;								--| ucomisd + sete, NaN exclu (setnp)

    elsif  M = "FCNE"  then return  28;
>>>

### MODIFICATION 1.13 - target_code-emits.adb (sur place : FCLE SIZE_OF)
ANCRE = BLOC A SUPPRIMER (texte existant, unique, auto-localisant) :
<<<
    then return  22;

-- FCLE a faire
>>>
REMPLACER PAR :
<<<
    then return  22;

    elsif  M = "FCLE"  then return 22;								--| ucomisd inverse + setae
>>>

### MODIFICATION 1.14 - target_code-emits.adb (sur place : BLKAND/BLKOU/BLKOUX/BLKNOT SIZE_OF)
ANCRE = BLOC A SUPPRIMER (texte existant, unique, auto-localisant) :
<<<
-- BLKAND  a faire
-- BLKOU a faire
-- BLKOUX a faire
-- BLKNOT a faire
>>>
REMPLACER PAR :
<<<
    elsif  M = "BLKAND"  or else  M = "BLKOU"  or else  M = "BLKOUX"  then
      return 41;											--| BLK_OP_OCTET (and 20 / or 08 / xor 30)

    elsif  M = "BLKNOT"  then return 29;								--| xor byte 1 (NON booleen par octet)
>>>

### MODIFICATION 1.15 - target_code-emits.adb (sur place : LEXCMP SIZE_OF)
ANCRE = BLOC A SUPPRIMER (texte existant, unique, auto-localisant) :
<<<
    elsif  M = "BLKCMP"  then return  45;

-- LEXCMP a faire
>>>
REMPLACER PAR :
<<<
    elsif  M = "BLKCMP"  then return  45;

    elsif  M = "LEXCMP"  then									--| 96 + paire de charges normalisees
      declare
        SIZC	:constant SYMBOLS.VALUE_TYPE	:= OPV( E, 1, 8 );
        SGN	:constant SYMBOLS.VALUE_TYPE	:= OPV( E, 2, 0 );
      begin
        if  SIZC = 1  or else  SIZC = 2  then
	if  SGN = 1  then  return 104;  end if;
	return 102;
        elsif  SIZC = 4  then
	if  SGN = 1  then  return 102;  end if;
	return 100;
        elsif  SIZC = 8  then
	return 102;
        end if;
        FAULT( "LEXCMP : taille de composant non supportee" );
        return 0;
      end;
>>>

### MODIFICATION 1.16 - target_code-emits.adb (sur place : SYS_CLOCK_GETTIME SIZE_OF)
ANCRE = BLOC A SUPPRIMER (texte existant, unique, auto-localisant) :
<<<
-- SYS_CLOCK_GETTIME a faire

    elsif  M = "SYS_PUT_CHAR"  then return  18;
>>>
REMPLACER PAR :
<<<
    elsif  M = "SYS_CLOCK_GETTIME"  then return 19;							--| clock_gettime(REALTIME, @timespec)

    elsif  M = "SYS_PUT_CHAR"  then return  18;
>>>

### MODIFICATION 1.17 - target_code-emits.adb (sur place : SYS_FILE_GET_POS/SYS_FILE_GET_SIZE SIZE_OF)
ANCRE = BLOC A SUPPRIMER (texte existant, unique, auto-localisant) :
<<<
-- SYS_FILE_GET_POS a faire
-- SYS_FILE_GET_SIZE a faire

    elsif  M = "SYS_FILE_READ"  or else  M = "SYS_FILE_WRITE"  then return  33;
>>>
REMPLACER PAR :
<<<
    elsif  M = "SYS_FILE_GET_POS"  then return 23;							--| lseek(SEEK_CUR, 0) - resultat sur [rbp]

    elsif  M = "SYS_FILE_GET_SIZE"  then return 51;							--| lseek END puis SET (position preservee)

    elsif  M = "SYS_FILE_READ"  or else  M = "SYS_FILE_WRITE"  then return  33;
>>>

### MODIFICATION 1.18 - target_code-emits.adb (sur place : ULW ENCODE)
ANCRE = BLOC A SUPPRIMER (texte existant, unique, auto-localisant) :
<<<
-- ULW  a faire
>>>
REMPLACER PAR :
<<<
    elsif  M = "ULW"  then
      E_BASE( OPV( E, 1, -1 ) );
      E_FETCH_WU( OPV( E, 2, 0 ) );
      E_PUSH_RAX;
>>>

### MODIFICATION 1.19 - target_code-emits.adb (sur place : LW ENCODE)
ANCRE = BLOC A SUPPRIMER (texte existant, unique, auto-localisant) :
<<<
-- LW  a faire

    elsif  M = "LD"  then
      E_BASE( OPV( E, 1, -1 ) );
>>>
REMPLACER PAR :
<<<
    elsif  M = "LW"  then
      E_BASE( OPV( E, 1, -1 ) );
      E_FETCH_W( OPV( E, 2, 0 ) );
      E_PUSH_RAX;

    elsif  M = "LD"  then
      E_BASE( OPV( E, 1, -1 ) );
>>>

### MODIFICATION 1.20 - target_code-emits.adb (sur place : ULIW ENCODE)
ANCRE = BLOC A SUPPRIMER (texte existant, unique, auto-localisant) :
<<<
-- ULIW  a faire
>>>
REMPLACER PAR :
<<<
    elsif  M = "ULIW"  then
      E_IBASE( OPV( E, 1, -1 ), OPV( E, 2, 0 ) );
      E_FETCH_WU( OPV( E, 3, 0 ) );
      E_PUSH_RAX;
>>>

### MODIFICATION 1.21 - target_code-emits.adb (sur place : LIB/LIW ENCODE)
ANCRE = BLOC A SUPPRIMER (texte existant, unique, auto-localisant) :
<<<
-- LIB a faire
-- LIW a faire

    elsif M = "LID"
>>>
REMPLACER PAR :
<<<
    elsif  M = "LIB"  then
      E_IBASE( OPV( E, 1, -1 ), OPV( E, 2, 0 ) );
      E_FETCH_B( OPV( E, 3, 0 ) );
      E_PUSH_RAX;

    elsif  M = "LIW"  then
      E_IBASE( OPV( E, 1, -1 ), OPV( E, 2, 0 ) );
      E_FETCH_W( OPV( E, 3, 0 ) );
      E_PUSH_RAX;

    elsif M = "LID"
>>>

### MODIFICATION 1.22 - target_code-emits.adb (sur place : SIW ENCODE)
ANCRE = BLOC A SUPPRIMER (texte existant, unique, auto-localisant) :
<<<
-- SIW  a faire
>>>
REMPLACER PAR :
<<<
    elsif  M = "SIW"  then
      E_POP_RBX;
      E_IBASE( OPV( E, 1, -1 ), OPV( E, 2, 0 ) );
      E_STORE_W( OPV( E, 3, 0 ) );
>>>

### MODIFICATION 1.23 - target_code-emits.adb (sur place : OU/NON ENCODE)
ANCRE = BLOC A SUPPRIMER (texte existant, unique, auto-localisant) :
<<<
-- OU  a faire
-- NON  a faire
>>>
REMPLACER PAR :
<<<
    elsif  M = "OU"  then									--| ou logique
      E_POP_RAX;
      B( 16#48# ); B( 16#09# ); B( 16#45# ); B( 16#00# );		--| or qword [rbp], rax

    elsif  M = "NON"  then									--| non bit a bit
      B( 16#48# ); B( 16#F7# ); B( 16#55# ); B( 16#00# );		--| not qword [rbp]
>>>

### MODIFICATION 1.24 - target_code-emits.adb (sur place : SHR ENCODE)
ANCRE = BLOC A SUPPRIMER (texte existant, unique, auto-localisant) :
<<<
-- SHR a faire


		-----------------------------------------
>>>
REMPLACER PAR :
<<<
    elsif  M = "SHR"  then									--| decalage droit logique
      E_POP_RCX;
      B( 16#48# ); B( 16#D3# ); B( 16#6D# ); B( 16#00# );		--| shr qword [rbp], cl


		-----------------------------------------
>>>

### MODIFICATION 1.25 - target_code-emits.adb (sur place : UBFX/SBFX/BFI ENCODE)
ANCRE = BLOC A SUPPRIMER (texte existant, unique, auto-localisant) :
<<<
-- UBFX a faire
-- SBFX a faire
-- BFI a faire

		-------------------------------------------------------------
>>>
REMPLACER PAR :
<<<
    elsif  M = "UBFX"  then									--| extraction de champ non signe
      E_POP_RDX;											--| Width
      E_POP_RCX;											--| LSB
      B( 16#48# ); B( 16#8B# ); B( 16#45# ); B( 16#00# );		--| mov rax, [rbp]
      B( 16#48# ); B( 16#D3# ); B( 16#E8# );			--| shr rax, cl
      B( 16#48# ); B( 16#89# ); B( 16#D1# );			--| mov rcx, rdx
      B( 16#6A# ); B( 16#01# ); B( 16#5A# );			--| rdx := 1
      B( 16#48# ); B( 16#D3# ); B( 16#E2# );			--| shl rdx, cl
      B( 16#48# ); B( 16#FF# ); B( 16#CA# );			--| dec rdx (masque)
      B( 16#48# ); B( 16#21# ); B( 16#D0# );			--| and rax, rdx
      B( 16#48# ); B( 16#89# ); B( 16#45# ); B( 16#00# );		--| mov [rbp], rax

    elsif  M = "SBFX"  then									--| extraction de champ signe
      E_POP_RDX;											--| Width
      E_POP_RCX;											--| LSB
      B( 16#48# ); B( 16#8B# ); B( 16#45# ); B( 16#00# );		--| mov rax, [rbp]
      B( 16#48# ); B( 16#D3# ); B( 16#E8# );			--| shr rax, cl
      B( 16#6A# ); B( 16#40# ); B( 16#59# );			--| rcx := 64
      B( 16#48# ); B( 16#29# ); B( 16#D1# );			--| sub rcx, rdx (64 - Width)
      B( 16#48# ); B( 16#D3# ); B( 16#E0# );			--| shl rax, cl
      B( 16#48# ); B( 16#D3# ); B( 16#F8# );			--| sar rax, cl (extension)
      B( 16#48# ); B( 16#89# ); B( 16#45# ); B( 16#00# );		--| mov [rbp], rax

    elsif  M = "BFI"  then									--| insertion de champ dans [rbp]
      E_POP_RCX;											--| Width
      E_POP_RDX;											--| LSB
      E_POP_RAX;											--| valeur a inserer
      B( 16#6A# ); B( 16#01# ); B( 16#5B# );			--| rbx := 1
      B( 16#48# ); B( 16#D3# ); B( 16#E3# );			--| shl rbx, cl
      B( 16#48# ); B( 16#FF# ); B( 16#CB# );			--| dec rbx (masque)
      B( 16#48# ); B( 16#21# ); B( 16#D8# );			--| and rax, rbx
      B( 16#48# ); B( 16#89# ); B( 16#D1# );			--| mov rcx, rdx (LSB)
      B( 16#48# ); B( 16#D3# ); B( 16#E0# );			--| shl rax, cl
      B( 16#48# ); B( 16#D3# ); B( 16#E3# );			--| shl rbx, cl
      B( 16#48# ); B( 16#F7# ); B( 16#D3# );			--| not rbx
      B( 16#48# ); B( 16#21# ); B( 16#5D# ); B( 16#00# );		--| and [rbp], rbx (nettoyer)
      B( 16#48# ); B( 16#09# ); B( 16#45# ); B( 16#00# );		--| or [rbp], rax (inserer)

		-------------------------------------------------------------
>>>

### MODIFICATION 1.26 - target_code-emits.adb (sur place : ABS ENCODE)
ANCRE = BLOC A SUPPRIMER (texte existant, unique, auto-localisant) :
<<<
-- ABS a faire

    elsif  M = "CLAMP0"  then										--| sommet := max(0, sommet)
>>>
REMPLACER PAR :
<<<
    elsif  M = "ABS"  then									--| valeur absolue entiere
      B( 16#48# ); B( 16#8B# ); B( 16#45# ); B( 16#00# );		--| mov rax, [rbp]
      B( 16#48# ); B( 16#C1# ); B( 16#F8# ); B( 16#3F# );		--| sar rax, 63 (allsign)
      B( 16#48# ); B( 16#31# ); B( 16#45# ); B( 16#00# );		--| xor [rbp], rax
      B( 16#48# ); B( 16#29# ); B( 16#45# ); B( 16#00# );		--| sub [rbp], rax

    elsif  M = "CLAMP0"  then										--| sommet := max(0, sommet)
>>>

### MODIFICATION 1.27 - target_code-emits.adb (sur place : SAR ENCODE)
ANCRE = BLOC A SUPPRIMER (texte existant, unique, auto-localisant) :
<<<
      E_PUSH_RAX;

-- SAR a faire
>>>
REMPLACER PAR :
<<<
      E_PUSH_RAX;

    elsif  M = "SAR"  then									--| decalage droit arithmetique
      E_POP_RCX;
      B( 16#48# ); B( 16#D3# ); B( 16#7D# ); B( 16#00# );		--| sar qword [rbp], cl
>>>

### MODIFICATION 1.28 - target_code-emits.adb (sur place : FABS/FEXP ENCODE)
ANCRE = BLOC A SUPPRIMER (texte existant, unique, auto-localisant) :
<<<
      B( 16#80# ); B( 16#75# ); B( 16#07# ); B( 16#80# );

-- FABS a faire
-- FEXP a faire
>>>
REMPLACER PAR :
<<<
      B( 16#80# ); B( 16#75# ); B( 16#07# ); B( 16#80# );

    elsif  M = "FABS"  then									--| bit 63 a zero (signe IEEE 754)
      B( 16#80# ); B( 16#65# ); B( 16#07# ); B( 16#7F# );		--| and byte [rbp+7], 7F

    elsif  M = "FEXP"  then									--| A ** N (N entier positif depile)
      E_POP_RCX;
      B( 16#F2# ); B( 16#0F# ); B( 16#10# ); B( 16#45# ); B( 16#00# );	--| movsd xmm0, [rbp] (base)
      B( 16#48# ); B( 16#B8# ); B( 16#00# ); B( 16#00# ); B( 16#00# ); B( 16#00# ); B( 16#00# ); B( 16#00# ); B( 16#F0# ); B( 16#3F# );	--| movabs rax, 1.0
      B( 16#66# ); B( 16#48# ); B( 16#0F# ); B( 16#6E# ); B( 16#C8# );	--| movq xmm1, rax (accumulateur)
      B( 16#48# ); B( 16#85# ); B( 16#C9# );			--| test rcx, rcx
      B( 16#74# ); B( 16#09# );				--| jz +9 (N = 0 : resultat 1.0)
      B( 16#F2# ); B( 16#0F# ); B( 16#59# ); B( 16#C8# );		--| mulsd xmm1, xmm0
      B( 16#48# ); B( 16#FF# ); B( 16#C9# );			--| dec rcx
      B( 16#75# ); B( 16#F7# );				--| jnz -9
      B( 16#F2# ); B( 16#0F# ); B( 16#11# ); B( 16#4D# ); B( 16#00# );	--| movsd [rbp], xmm1
>>>

### MODIFICATION 1.29 - target_code-emits.adb (sur place : CVTXI ENCODE)
ANCRE = BLOC A SUPPRIMER (texte existant, unique, auto-localisant) :
<<<
-- CVTXI a faire

				-----------------------
>>>
REMPLACER PAR :
<<<
    elsif  M = "CVTXI"  then									--| X * NUMER / DENOM, arrondi au plus pres
      E_POP_RBX;											--| DENOM
      E_POP_RCX;											--| NUMER
      E_POP_RAX;											--| X
      B( 16#48# ); B( 16#F7# ); B( 16#E9# );			--| imul rcx
      B( 16#48# ); B( 16#F7# ); B( 16#FB# );			--| idiv rbx
      B( 16#48# ); B( 16#89# ); B( 16#D1# );			--| mov rcx, rdx
      B( 16#48# ); B( 16#C1# ); B( 16#F9# ); B( 16#3F# );		--| sar rcx, 63
      B( 16#48# ); B( 16#31# ); B( 16#CA# );			--| xor rdx, rcx (|reste|)
      B( 16#48# ); B( 16#29# ); B( 16#CA# );			--| sub rdx, rcx
      B( 16#48# ); B( 16#D1# ); B( 16#EB# );			--| shr rbx, 1
      B( 16#48# ); B( 16#83# ); B( 16#D3# ); B( 16#00# );		--| adc rbx, 0 (demi-DENOM arrondi)
      B( 16#48# ); B( 16#39# ); B( 16#DA# );			--| cmp rdx, rbx
      B( 16#72# ); B( 16#07# );				--| jb +7 (pas d arrondi)
      B( 16#48# ); B( 16#83# ); B( 16#C9# ); B( 16#01# );		--| or rcx, 1 (signe du quotient)
      B( 16#48# ); B( 16#01# ); B( 16#C8# );			--| add rax, rcx
      E_PUSH_RAX;

				-----------------------
>>>

### MODIFICATION 1.30 - target_code-emits.adb (sur place : FCEQ ENCODE)
ANCRE = BLOC A SUPPRIMER (texte existant, unique, auto-localisant) :
<<<
-- FCEQ a faire

    elsif  M = "FCNE"  then										--| A /= B flottant (NaN -> vrai)
>>>
REMPLACER PAR :
<<<
    elsif  M = "FCEQ"  then									--| egalite flottante (NaN exclu)
      B( 16#F2# ); B( 16#0F# ); B( 16#10# ); B( 16#4D# ); B( 16#00# );	--| movsd xmm1, [rbp] (B)
      B( 16#48# ); B( 16#8D# ); B( 16#6D# ); B( 16#F8# );		--| DROP
      B( 16#F2# ); B( 16#0F# ); B( 16#10# ); B( 16#45# ); B( 16#00# );	--| movsd xmm0, [rbp] (A)
      B( 16#66# ); B( 16#0F# ); B( 16#2E# ); B( 16#C1# );		--| ucomisd xmm0, xmm1
      B( 16#0F# ); B( 16#94# ); B( 16#45# ); B( 16#00# );		--| sete [rbp]
      B( 16#0F# ); B( 16#9B# ); B( 16#C0# );			--| setnp al (pas NaN)
      B( 16#20# ); B( 16#45# ); B( 16#00# );			--| and [rbp], al

    elsif  M = "FCNE"  then										--| A /= B flottant (NaN -> vrai)
>>>

### MODIFICATION 1.31 - target_code-emits.adb (sur place : FCLE ENCODE)
ANCRE = BLOC A SUPPRIMER (texte existant, unique, auto-localisant) :
<<<
      B( 16#0F# ); B( 16#97# ); B( 16#45# ); B( 16#00# );

-- FCLE a faire
>>>
REMPLACER PAR :
<<<
      B( 16#0F# ); B( 16#97# ); B( 16#45# ); B( 16#00# );

    elsif  M = "FCLE"  then									--| A <= B flottant
      B( 16#F2# ); B( 16#0F# ); B( 16#10# ); B( 16#4D# ); B( 16#00# );	--| movsd xmm1, [rbp] (B)
      B( 16#48# ); B( 16#8D# ); B( 16#6D# ); B( 16#F8# );		--| DROP
      B( 16#F2# ); B( 16#0F# ); B( 16#10# ); B( 16#45# ); B( 16#00# );	--| movsd xmm0, [rbp] (A)
      B( 16#66# ); B( 16#0F# ); B( 16#2E# ); B( 16#C8# );		--| ucomisd xmm1, xmm0 (inverse)
      B( 16#0F# ); B( 16#93# ); B( 16#45# ); B( 16#00# );		--| setae [rbp]
>>>

### MODIFICATION 1.32 - target_code-emits.adb (sur place : BLKAND/BLKOU/BLKOUX/BLKNOT ENCODE)
ANCRE = BLOC A SUPPRIMER (texte existant, unique, auto-localisant) :
<<<
-- BLKAND a faire
-- BLKOU a faire
-- BLKOUX a faire
-- BLKNOT a faire
>>>
REMPLACER PAR :
<<<
    elsif  M = "BLKAND"  or else  M = "BLKOU"  or else  M = "BLKOUX"  then				--| [DST] op= [SRC] octet a octet
      declare
        OPC		:INTEGER := 16#20#;								--| and
      begin
        if  M = "BLKOU"  then  OPC := 16#08#;  end if;							--| or
        if  M = "BLKOUX"  then  OPC := 16#30#;  end if;							--| xor
        E_POP_RSI;											--| @SRC
        E_POP_RCX;											--| LEN
        E_POP_RDI;											--| @DST
        B( 16#48# ); B( 16#85# ); B( 16#C9# );			--| test rcx, rcx
        B( 16#74# ); B( 16#0C# );				--| jz fin (LEN = 0)
        B( 16#8A# ); B( 16#06# );				--| mov al, [rsi]
        B( OPC ); B( 16#07# );										--| op [rdi], al
        B( 16#48# ); B( 16#FF# ); B( 16#C6# );			--| inc rsi
        B( 16#48# ); B( 16#FF# ); B( 16#C7# );			--| inc rdi
        B( 16#E2# ); B( 16#F4# );				--| loop
      end;

    elsif  M = "BLKNOT"  then									--| NON booleen par octet (xor 1)
      E_POP_RCX;											--| LEN
      E_POP_RDI;											--| @DST
      B( 16#48# ); B( 16#85# ); B( 16#C9# );			--| test rcx, rcx
      B( 16#74# ); B( 16#08# );				--| jz fin
      B( 16#80# ); B( 16#37# ); B( 16#01# );			--| xor byte [rdi], 1
      B( 16#48# ); B( 16#FF# ); B( 16#C7# );			--| inc rdi
      B( 16#E2# ); B( 16#F8# );				--| loop
>>>

### MODIFICATION 1.33 - target_code-emits.adb (sur place : LEXCMP ENCODE)
ANCRE = BLOC A SUPPRIMER (texte existant, unique, auto-localisant) :
<<<
      E_PUSH_RAX;

-- LEXCMP a faire
>>>
REMPLACER PAR :
<<<
      E_PUSH_RAX;

    elsif  M = "LEXCMP"  then									--| comparaison lexicographique (LRM 4.5.2)
      declare
        SIZC	:constant SYMBOLS.VALUE_TYPE	:= OPV( E, 1, 8 );
        SGN	:constant SYMBOLS.VALUE_TYPE	:= OPV( E, 2, 0 );
        F		:INTEGER := 6;								--| taille de la paire de charges
      begin
        if  ( SIZC = 1  or else  SIZC = 2 )  and then  SGN = 1  then
	F := 8;
        elsif  SIZC = 4  then
	F := 4;
	if  SGN = 1  then  F := 6;  end if;
        end if;
        E_POP_RDX;										--| LEN_D
        E_POP_RSI;										--| @D
        E_POP_RCX;										--| LEN_G
        E_POP_RDI;										--| @G
        B( 16#48# ); B( 16#85# ); B( 16#C9# );			--| boucle : test rcx, rcx
        B( 16#74# ); B( 28 + F );								--| jz epuise
        B( 16#48# ); B( 16#85# ); B( 16#D2# );			--| test rdx, rdx
        B( 16#74# ); B( 23 + F );								--| jz epuise
        if  SIZC = 1  then
	if  SGN = 1  then
	  B( 16#48# ); B( 16#0F# ); B( 16#BE# ); B( 16#07# ); B( 16#48# ); B( 16#0F# ); B( 16#BE# ); B( 16#1E# );	--| movsx octets
	else
	  B( 16#0F# ); B( 16#B6# ); B( 16#07# ); B( 16#0F# ); B( 16#B6# ); B( 16#1E# );		--| movzx octets
	end if;
        elsif  SIZC = 2  then
	if  SGN = 1  then
	  B( 16#48# ); B( 16#0F# ); B( 16#BF# ); B( 16#07# ); B( 16#48# ); B( 16#0F# ); B( 16#BF# ); B( 16#1E# );	--| movsx mots
	else
	  B( 16#0F# ); B( 16#B7# ); B( 16#07# ); B( 16#0F# ); B( 16#B7# ); B( 16#1E# );		--| movzx mots
	end if;
        elsif  SIZC = 4  then
	if  SGN = 1  then
	  B( 16#48# ); B( 16#63# ); B( 16#07# ); B( 16#48# ); B( 16#63# ); B( 16#1E# );		--| movsxd dwords
	else
	  B( 16#8B# ); B( 16#07# ); B( 16#8B# ); B( 16#1E# );			--| mov dwords (zero-etend)
	end if;
        else
	B( 16#48# ); B( 16#8B# ); B( 16#07# ); B( 16#48# ); B( 16#8B# ); B( 16#1E# );		--| mov qwords
        end if;
        B( 16#48# ); B( 16#39# ); B( 16#D8# );			--| cmp rax, rbx (signee, normalisee)
        B( 16#75# ); B( 16#1E# );				--| jne differe
        B( 16#48# ); B( 16#83# ); B( 16#C7# ); B( INTEGER( SIZC ) );				--| add rdi, siz
        B( 16#48# ); B( 16#83# ); B( 16#C6# ); B( INTEGER( SIZC ) );				--| add rsi, siz
        B( 16#48# ); B( 16#83# ); B( 16#E9# ); B( INTEGER( SIZC ) );				--| sub rcx, siz
        B( 16#48# ); B( 16#83# ); B( 16#EA# ); B( INTEGER( SIZC ) );				--| sub rdx, siz
        B( 16#EB# ); B( 256 - 33 - F );								--| jmp boucle
        B( 16#48# ); B( 16#29# ); B( 16#D1# );			--| epuise : sub rcx, rdx (prefixe commun)
        B( 16#74# ); B( 16#0B# );				--| jz egal
        B( 16#78# ); B( 16#0D# );				--| js moins
        B( 16#6A# ); B( 16#01# ); B( 16#58# );			--| plus : rax := +1
        B( 16#EB# ); B( 16#0B# );				--| jmp empile
        B( 16#7C# ); B( 16#06# );				--| differe : jl moins
        B( 16#EB# ); B( 16#F7# );				--| jmp plus
        B( 16#31# ); B( 16#C0# );				--| egal : rax := 0
        B( 16#EB# ); B( 16#03# );				--| jmp empile
        B( 16#6A# ); B( 16#FF# ); B( 16#58# );			--| moins : rax := -1
        E_PUSH_RAX;										--| empile : -1 / 0 / +1
      end;
>>>

### MODIFICATION 1.34 - target_code-emits.adb (sur place : SYS_CLOCK_GETTIME ENCODE)
ANCRE = BLOC A SUPPRIMER (texte existant, unique, auto-localisant) :
<<<
-- SYS_CLOCK_GETTIME a faire

    elsif  M = "SYS_PUT_CHAR"  then									--| caractere au sommet, ecrit sur stdout, DROP
>>>
REMPLACER PAR :
<<<
    elsif  M = "SYS_CLOCK_GETTIME"  then							--| clock_gettime(REALTIME, @timespec)
      E_POP_RSI;
      B( 16#48# ); B( 16#31# ); B( 16#FF# );			--| xor rdi, rdi (CLOCK_REALTIME)
      B( 16#68# ); B( 16#E4# ); B( 16#00# ); B( 16#00# ); B( 16#00# );	--| push 228
      B( 16#58# );					--| pop rax
      B( 16#0F# ); B( 16#05# );				--| syscall

    elsif  M = "SYS_PUT_CHAR"  then									--| caractere au sommet, ecrit sur stdout, DROP
>>>

### MODIFICATION 1.35 - target_code-emits.adb (sur place : SYS_FILE_GET_POS/SYS_FILE_GET_SIZE ENCODE)
ANCRE = BLOC A SUPPRIMER (texte existant, unique, auto-localisant) :
<<<
-- SYS_FILE_GET_POS a faire
-- SYS_FILE_GET_SIZE a faire

    elsif  M = "SYS_FILE_READ"  then									--| read(fd, tampon, longueur) - resultat sur [rbp]
>>>
REMPLACER PAR :
<<<
    elsif  M = "SYS_FILE_GET_POS"  then							--| lseek(fd, 0, SEEK_CUR)
      E_POP_RDI;
      B( 16#48# ); B( 16#31# ); B( 16#F6# );			--| xor rsi, rsi
      B( 16#6A# ); B( 16#01# ); B( 16#5A# );			--| rdx := 1 (SEEK_CUR)
      B( 16#6A# ); B( 16#08# ); B( 16#58# );			--| rax := 8 (lseek)
      B( 16#0F# ); B( 16#05# );				--| syscall
      B( 16#48# ); B( 16#89# ); B( 16#45# ); B( 16#00# );		--| mov [rbp], rax (lieu result)

    elsif  M = "SYS_FILE_GET_SIZE"  then							--| taille, position preservee
      E_POP_RDI;
      B( 16#48# ); B( 16#31# ); B( 16#F6# );			--| xor rsi, rsi
      B( 16#6A# ); B( 16#01# ); B( 16#5A# );			--| SEEK_CUR
      B( 16#6A# ); B( 16#08# ); B( 16#58# ); B( 16#0F# ); B( 16#05# );	--| lseek : position courante
      B( 16#49# ); B( 16#89# ); B( 16#C0# );			--| mov r8, rax
      B( 16#48# ); B( 16#31# ); B( 16#F6# );			--| xor rsi, rsi
      B( 16#6A# ); B( 16#02# ); B( 16#5A# );			--| SEEK_END
      B( 16#6A# ); B( 16#08# ); B( 16#58# ); B( 16#0F# ); B( 16#05# );	--| lseek : taille
      B( 16#49# ); B( 16#89# ); B( 16#C1# );			--| mov r9, rax
      B( 16#4C# ); B( 16#89# ); B( 16#C6# );			--| mov rsi, r8
      B( 16#48# ); B( 16#31# ); B( 16#D2# );			--| xor rdx, rdx (SEEK_SET)
      B( 16#6A# ); B( 16#08# ); B( 16#58# ); B( 16#0F# ); B( 16#05# );	--| lseek : restauration
      B( 16#4C# ); B( 16#89# ); B( 16#4D# ); B( 16#00# );		--| mov [rbp], r9 (lieu result)

    elsif  M = "SYS_FILE_READ"  then									--| read(fd, tampon, longueur) - resultat sur [rbp]
>>>

### MODIFICATION 1.37 - target_code-emits.adb (sur place : ULW SIZE_OF, correctif)
NOTE : faute LATENTE de la table existante, debusquee par l'oracle
unitaire fasmg (delta d'octets par mnemonique isole) : FETCH_WORD_U du
codi est movzx RAX (REX 48 0F B7, quatre octets d'opcode), pas trois.
ENUM_TEST n'exerce jamais ULW - la faute dormait.
ANCRE = BLOC A SUPPRIMER (texte existant, unique, auto-localisant) :
<<<
    elsif  M = "ULW"  then return S_BASE( OPV( E, 1, -1 ) ) + S_DISP( OPV( E, 2, 0 ), 3 ) + 8;
>>>
REMPLACER PAR :
<<<
    elsif  M = "ULW"  then return S_BASE( OPV( E, 1, -1 ) ) + S_DISP( OPV( E, 2, 0 ), 4 ) + 8;
>>>

## COMMIT 2 - TEMOIN TC-21 (pilote)

### MODIFICATION 2.1 - target_code.adb (insertion pure, fin du pilote)
ANCRE (texte existant, unique : fin du temoin TC-17) :
<<<
      PUT_LINE( "  chmod +x TC_TEST17.BIN && ./TC_TEST17.BIN ; echo $?   (attendu : 0)" );
    end if;
  end;
>>>
SUPPRIMER : le texte de l'ancre elle-meme (repris a l'identique en tete du remplacement).
REMPLACER PAR (ancre reprise inchangee + temoin TC-21) :
<<<
      PUT_LINE( "  chmod +x TC_TEST17.BIN && ./TC_TEST17.BIN ; echo $?   (attendu : 0)" );
    end if;
  end;

  --|  TEMOIN TEMPORAIRE COMPLETION (TC-21) - la table entiere du codi
  --|  sous verdict d'execution : mots signes/non signes (LW/ULW/LIW/
  --|  ULIW/LIB/SIW), alu (OU/NON/SHR/SAR/ABS), champs de bits (UBFX/
  --|  SBFX/BFI), flottants (FABS/FEXP/FCEQ/FCLE), CVTXI, familles
  --|  BLK* et LEXCMP (trois cas 4.5.2), horloge et fichiers de bout
  --|  en bout (CREATE/WRITE/GET_POS/SET_POS/GET_SIZE/CLOSE/DELETE).
  --|  Verdicts : 0 = tout bon ; 3..33 = etape fautive. A RETIRER.
  declare
    use LEX;
    use SYMBOLS;
    use IR;
    OK			: BOOLEAN	:= TRUE;
    F			: FILE_TYPE;
    FROM21		: IR.ELT_ID;

    procedure CHECK ( COND :BOOLEAN; MSG :STRING )
    is
    begin
      if not COND
      then
	OK := FALSE;
	PUT_LINE( "ECHEC completion : " & MSG );
      end if;
    end CHECK;

  begin
    CREATE( F, OUT_FILE, "TC_TEST21.FAS" );
    PUT_LINE( F, "	include '../../src/expander/fasmg/codi_x86_64.finc'" );
    PUT_LINE( F, "STANDARD = 'STANDARD'" );
    PUT_LINE( F, "namespace STANDARD" );
    PUT_LINE( F, "  virtual at 8" );
    PUT_LINE( F, "    VARzone::" );
    PUT_LINE( F, "  end virtual" );
    PUT_LINE( F, "	LINK	0, loc_siz" );
    PUT_LINE( F, "	VAR	W21_disp, W" );
    PUT_LINE( F, "	VAR	P21_disp, Q" );
    PUT_LINE( F, "	VAR	BLA21_disp, 8" );
    PUT_LINE( F, "	VAR	BLB21_disp, 8" );
    PUT_LINE( F, "	VAR	FID21_disp, Q" );
    PUT_LINE( F, "	VAR	TS21_disp, 16" );
    PUT_LINE( F, "	STR	T21NM, 't21.tmp'" );
    PUT_LINE( F, "; ---- mots signes / non signes ----" );
    PUT_LINE( F, "	LVA	0, W21_disp" );
    PUT_LINE( F, "	SA	0, P21_disp" );
    PUT_LINE( F, "	LI	-2" );
    PUT_LINE( F, "	SW	0, W21_disp" );
    PUT_LINE( F, "	LW	0, W21_disp" );
    PUT_LINE( F, "	LI	-2" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k21_3" );
    PUT_LINE( F, "	SYS_EXIT	3" );
    PUT_LINE( F, "k21_3:" );
    PUT_LINE( F, "	ULW	0, W21_disp" );
    PUT_LINE( F, "	LI	65534" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k21_4" );
    PUT_LINE( F, "	SYS_EXIT	4" );
    PUT_LINE( F, "k21_4:" );
    PUT_LINE( F, "	LIW	0, P21_disp, 0" );
    PUT_LINE( F, "	LI	-2" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k21_5" );
    PUT_LINE( F, "	SYS_EXIT	5" );
    PUT_LINE( F, "k21_5:" );
    PUT_LINE( F, "	ULIW	0, P21_disp, 0" );
    PUT_LINE( F, "	LI	65534" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k21_6" );
    PUT_LINE( F, "	SYS_EXIT	6" );
    PUT_LINE( F, "k21_6:" );
    PUT_LINE( F, "	LI	-5" );
    PUT_LINE( F, "	SIB	0, P21_disp, 0" );
    PUT_LINE( F, "	LIB	0, P21_disp, 0" );
    PUT_LINE( F, "	LI	-5" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k21_7" );
    PUT_LINE( F, "	SYS_EXIT	7" );
    PUT_LINE( F, "k21_7:" );
    PUT_LINE( F, "	LI	-300" );
    PUT_LINE( F, "	SIW	0, P21_disp, 0" );
    PUT_LINE( F, "	LIW	0, P21_disp, 0" );
    PUT_LINE( F, "	LI	-300" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k21_8" );
    PUT_LINE( F, "	SYS_EXIT	8" );
    PUT_LINE( F, "k21_8:" );
    PUT_LINE( F, "; ---- alu ----" );
    PUT_LINE( F, "	LI	12" );
    PUT_LINE( F, "	LI	3" );
    PUT_LINE( F, "	OU" );
    PUT_LINE( F, "	LI	15" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k21_9" );
    PUT_LINE( F, "	SYS_EXIT	9" );
    PUT_LINE( F, "k21_9:" );
    PUT_LINE( F, "	LI	5" );
    PUT_LINE( F, "	NON" );
    PUT_LINE( F, "	LI	-6" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k21_10" );
    PUT_LINE( F, "	SYS_EXIT	10" );
    PUT_LINE( F, "k21_10:" );
    PUT_LINE( F, "	LI	64" );
    PUT_LINE( F, "	LI	3" );
    PUT_LINE( F, "	SHR" );
    PUT_LINE( F, "	LI	8" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k21_11" );
    PUT_LINE( F, "	SYS_EXIT	11" );
    PUT_LINE( F, "k21_11:" );
    PUT_LINE( F, "	LI	-64" );
    PUT_LINE( F, "	LI	3" );
    PUT_LINE( F, "	SAR" );
    PUT_LINE( F, "	LI	-8" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k21_12" );
    PUT_LINE( F, "	SYS_EXIT	12" );
    PUT_LINE( F, "k21_12:" );
    PUT_LINE( F, "	LI	-7" );
    PUT_LINE( F, "	ABS" );
    PUT_LINE( F, "	LI	7" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k21_13" );
    PUT_LINE( F, "	SYS_EXIT	13" );
    PUT_LINE( F, "k21_13:" );
    PUT_LINE( F, "	LI	245" );
    PUT_LINE( F, "	LI	4" );
    PUT_LINE( F, "	LI	4" );
    PUT_LINE( F, "	UBFX" );
    PUT_LINE( F, "	LI	15" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k21_14" );
    PUT_LINE( F, "	SYS_EXIT	14" );
    PUT_LINE( F, "k21_14:" );
    PUT_LINE( F, "	LI	240" );
    PUT_LINE( F, "	LI	4" );
    PUT_LINE( F, "	LI	4" );
    PUT_LINE( F, "	SBFX" );
    PUT_LINE( F, "	LI	-1" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k21_15" );
    PUT_LINE( F, "	SYS_EXIT	15" );
    PUT_LINE( F, "k21_15:" );
    PUT_LINE( F, "	LI	65535" );
    PUT_LINE( F, "	LI	0" );
    PUT_LINE( F, "	LI	4" );
    PUT_LINE( F, "	LI	4" );
    PUT_LINE( F, "	BFI" );
    PUT_LINE( F, "	LI	65295" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k21_16" );
    PUT_LINE( F, "	SYS_EXIT	16" );
    PUT_LINE( F, "k21_16:" );
    PUT_LINE( F, "; ---- flottants ----" );
    PUT_LINE( F, "	LI	-4610560118520545280" );
    PUT_LINE( F, "	FABS" );
    PUT_LINE( F, "	LI	4612811918334230528" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k21_17" );
    PUT_LINE( F, "	SYS_EXIT	17" );
    PUT_LINE( F, "k21_17:" );
    PUT_LINE( F, "	LI	4611686018427387904" );
    PUT_LINE( F, "	LI	3" );
    PUT_LINE( F, "	FEXP" );
    PUT_LINE( F, "	LI	4620693217682128896" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k21_18" );
    PUT_LINE( F, "	SYS_EXIT	18" );
    PUT_LINE( F, "k21_18:" );
    PUT_LINE( F, "	LI	7" );
    PUT_LINE( F, "	LI	1" );
    PUT_LINE( F, "	LI	2" );
    PUT_LINE( F, "	CVTXI" );
    PUT_LINE( F, "	LI	4" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k21_19" );
    PUT_LINE( F, "	SYS_EXIT	19" );
    PUT_LINE( F, "k21_19:" );
    PUT_LINE( F, "	LI	4609434218613702656" );
    PUT_LINE( F, "	LI	4609434218613702656" );
    PUT_LINE( F, "	FCEQ" );
    PUT_LINE( F, "	LI	1" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k21_20" );
    PUT_LINE( F, "	SYS_EXIT	20" );
    PUT_LINE( F, "k21_20:" );
    PUT_LINE( F, "	LI	4609434218613702656" );
    PUT_LINE( F, "	LI	4612811918334230528" );
    PUT_LINE( F, "	FCLE" );
    PUT_LINE( F, "	LI	1" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k21_21" );
    PUT_LINE( F, "	SYS_EXIT	21" );
    PUT_LINE( F, "k21_21:" );
    PUT_LINE( F, "; ---- blocs ----" );
    PUT_LINE( F, "	LI	858993459" );
    PUT_LINE( F, "	SD	0, BLA21_disp" );
    PUT_LINE( F, "	LI	252645135" );
    PUT_LINE( F, "	SD	0, BLB21_disp" );
    PUT_LINE( F, "	LVA	0, BLA21_disp" );
    PUT_LINE( F, "	LI	4" );
    PUT_LINE( F, "	LVA	0, BLB21_disp" );
    PUT_LINE( F, "	BLKAND" );
    PUT_LINE( F, "	LD	0, BLA21_disp" );
    PUT_LINE( F, "	LI	50529027" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k21_22" );
    PUT_LINE( F, "	SYS_EXIT	22" );
    PUT_LINE( F, "k21_22:" );
    PUT_LINE( F, "	LI	808464432" );
    PUT_LINE( F, "	SD	0, BLB21_disp" );
    PUT_LINE( F, "	LVA	0, BLA21_disp" );
    PUT_LINE( F, "	LI	4" );
    PUT_LINE( F, "	LVA	0, BLB21_disp" );
    PUT_LINE( F, "	BLKOU" );
    PUT_LINE( F, "	LD	0, BLA21_disp" );
    PUT_LINE( F, "	LI	858993459" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k21_23" );
    PUT_LINE( F, "	SYS_EXIT	23" );
    PUT_LINE( F, "k21_23:" );
    PUT_LINE( F, "	LVA	0, BLA21_disp" );
    PUT_LINE( F, "	LI	4" );
    PUT_LINE( F, "	LVA	0, BLB21_disp" );
    PUT_LINE( F, "	BLKOUX" );
    PUT_LINE( F, "	LD	0, BLA21_disp" );
    PUT_LINE( F, "	LI	50529027" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k21_24" );
    PUT_LINE( F, "	SYS_EXIT	24" );
    PUT_LINE( F, "k21_24:" );
    PUT_LINE( F, "	LI	65537" );
    PUT_LINE( F, "	SD	0, BLA21_disp" );
    PUT_LINE( F, "	LVA	0, BLA21_disp" );
    PUT_LINE( F, "	LI	4" );
    PUT_LINE( F, "	BLKNOT" );
    PUT_LINE( F, "	LD	0, BLA21_disp" );
    PUT_LINE( F, "	LI	16777472" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k21_25" );
    PUT_LINE( F, "	SYS_EXIT	25" );
    PUT_LINE( F, "k21_25:" );
    PUT_LINE( F, "; ---- lexicographique ----" );
    PUT_LINE( F, "	LI	4408897" );
    PUT_LINE( F, "	SD	0, BLA21_disp" );
    PUT_LINE( F, "	LI	4474433" );
    PUT_LINE( F, "	SD	0, BLB21_disp" );
    PUT_LINE( F, "	LVA	0, BLA21_disp" );
    PUT_LINE( F, "	LI	3" );
    PUT_LINE( F, "	LVA	0, BLB21_disp" );
    PUT_LINE( F, "	LI	3" );
    PUT_LINE( F, "	LEXCMP 1, 0" );
    PUT_LINE( F, "	LI	-1" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k21_26" );
    PUT_LINE( F, "	SYS_EXIT	26" );
    PUT_LINE( F, "k21_26:" );
    PUT_LINE( F, "	LVA	0, BLA21_disp" );
    PUT_LINE( F, "	LI	2" );
    PUT_LINE( F, "	LVA	0, BLB21_disp" );
    PUT_LINE( F, "	LI	3" );
    PUT_LINE( F, "	LEXCMP 1, 0" );
    PUT_LINE( F, "	LI	-1" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k21_27" );
    PUT_LINE( F, "	SYS_EXIT	27" );
    PUT_LINE( F, "k21_27:" );
    PUT_LINE( F, "	LI	4408897" );
    PUT_LINE( F, "	SD	0, BLB21_disp" );
    PUT_LINE( F, "	LVA	0, BLA21_disp" );
    PUT_LINE( F, "	LI	3" );
    PUT_LINE( F, "	LVA	0, BLB21_disp" );
    PUT_LINE( F, "	LI	3" );
    PUT_LINE( F, "	LEXCMP 1, 0" );
    PUT_LINE( F, "	LI	0" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k21_28" );
    PUT_LINE( F, "	SYS_EXIT	28" );
    PUT_LINE( F, "k21_28:" );
    PUT_LINE( F, "; ---- fichiers de bout en bout ----" );
    PUT_LINE( F, "	LI	0" );
    PUT_LINE( F, "	LCA	T21NM.data_ptr" );
    PUT_LINE( F, "	SYS_FILE_CREATE" );
    PUT_LINE( F, "	SA	0, FID21_disp" );
    PUT_LINE( F, "	LI	0" );
    PUT_LINE( F, "	LI	4" );
    PUT_LINE( F, "	LVA	0, BLA21_disp" );
    PUT_LINE( F, "	LA	0, FID21_disp" );
    PUT_LINE( F, "	SYS_FILE_WRITE" );
    PUT_LINE( F, "	LI	4" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k21_29" );
    PUT_LINE( F, "	SYS_EXIT	29" );
    PUT_LINE( F, "k21_29:" );
    PUT_LINE( F, "	LI	0" );
    PUT_LINE( F, "	LA	0, FID21_disp" );
    PUT_LINE( F, "	SYS_FILE_GET_POS" );
    PUT_LINE( F, "	LI	4" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k21_30" );
    PUT_LINE( F, "	SYS_EXIT	30" );
    PUT_LINE( F, "k21_30:" );
    PUT_LINE( F, "	LI	0" );
    PUT_LINE( F, "	LI	2" );
    PUT_LINE( F, "	LA	0, FID21_disp" );
    PUT_LINE( F, "	SYS_FILE_SET_POS" );
    PUT_LINE( F, "	LI	2" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k21_31" );
    PUT_LINE( F, "	SYS_EXIT	31" );
    PUT_LINE( F, "k21_31:" );
    PUT_LINE( F, "	LI	0" );
    PUT_LINE( F, "	LA	0, FID21_disp" );
    PUT_LINE( F, "	SYS_FILE_GET_SIZE" );
    PUT_LINE( F, "	LI	4" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k21_32" );
    PUT_LINE( F, "	SYS_EXIT	32" );
    PUT_LINE( F, "k21_32:" );
    PUT_LINE( F, "	LI	0" );
    PUT_LINE( F, "	LA	0, FID21_disp" );
    PUT_LINE( F, "	SYS_FILE_CLOSE" );
    PUT_LINE( F, "	DROP" );
    PUT_LINE( F, "	LI	0" );
    PUT_LINE( F, "	LCA	T21NM.data_ptr" );
    PUT_LINE( F, "	SYS_FILE_DELETE" );
    PUT_LINE( F, "	DROP" );
    PUT_LINE( F, "; ---- horloge ----" );
    PUT_LINE( F, "	LVA	0, TS21_disp" );
    PUT_LINE( F, "	SYS_CLOCK_GETTIME" );
    PUT_LINE( F, "	LQ	0, TS21_disp" );
    PUT_LINE( F, "	LI	1600000000" );
    PUT_LINE( F, "	CGT" );
    PUT_LINE( F, "	BT	k21_33" );
    PUT_LINE( F, "	SYS_EXIT	33" );
    PUT_LINE( F, "k21_33:" );
    PUT_LINE( F, "	SYS_EXIT	0" );
    PUT_LINE( F, " virtual VARzone" );
    PUT_LINE( F, "   loc_siz = $" );
    PUT_LINE( F, "  end virtual" );
    PUT_LINE( F, "end namespace" );
    CLOSE( F );

    FROM21 := IR.ELT_ID( IR.ELT_COUNT + 1 );
    RUN_P0( "TC_TEST21.FAS" );
    PASSES.P1_REACH;
    PASSES.P2_LAYOUT( FROM21, IR.ELT_ID( IR.ELT_COUNT ) );
    EMITS.P2B_ADDRESSES( FROM21, IR.ELT_ID( IR.ELT_COUNT ) );
    EMITS.P3_EMIT( FROM21, IR.ELT_ID( IR.ELT_COUNT ), "TC_TEST21.BIN" );

    CHECK( VALUE_OF( RESOLVE( "STANDARD.loc_siz" ) ) = 64,
	   "layout 0 (W21 8, P21 16, BLA 24, BLB 32, FID 40, TS 48 : 64)" );

    if OK
    then
      PUT_LINE( "PASSE completion" );
      PUT_LINE( "TC_TEST21.BIN ecrit - oracle externe :" );
      PUT_LINE( "  fasmg TC_TEST21.FAS TC_REF21 && cmp TC_REF21 TC_TEST21.BIN" );
      PUT_LINE( "  chmod +x TC_TEST21.BIN && ./TC_TEST21.BIN ; echo $?   (attendu : 0)" );
    end if;
  end;

>>>

ORACLE (quadruple) : (a) cmp TC_REF21/TC_TEST21.BIN muet ; (b) fasmg
accepte TC_TEST21.FAS ; (c) PASSE completion, ./TC_TEST21.BIN -> 0
(3..33 = etape fautive) ; (d) rejeu des temoins anterieurs muet ;
DIS_BONJOUR et ENUM_TEST toujours identiques a fasmg et executables.
Apres cette tranche, EMITS couvre le codi entier : le refus 'hors
tranche' ne peut plus se declencher que sur un codi ETENDU - il reste
en place comme filet pour les evolutions futures.
