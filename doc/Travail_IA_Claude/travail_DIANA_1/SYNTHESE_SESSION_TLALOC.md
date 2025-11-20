# SESSION DE TRAVAIL TLALOC - SYNTHÈSE

**Date**: 20 novembre 2025
**Objectif**: Compléter l'EXPANDER du compilateur Ada 83 TLALOC

---

## CE QUI A ÉTÉ RÉALISÉ

### 1. Compréhension du système TLALOC

#### Architecture globale
```
Source Ada 83 (.adb)
    ↓
[PAR_PHASE] → DIANA partiel (parsing)
    ↓
[LIB_PHASE] → DIANA + bibliothèque (WITH)
    ↓
[SEM_PHASE] → DIANA sémantique complet
    ↓
[EXPANDER] → .FINC (macros LLIR)
    ↓
.fas (wrapper + includes)
    ↓
[fasmg + codi_x86_64.finc] → Assemblage
    ↓
Exécutable ELF x86-64
```

#### Machine à pile LLIR
- Pile croissante vers adresses hautes (inhabituel !)
- Co-pile pour variables dynamiques
- Display de frame pointers (R15)
- Macros: PRO, ELB, LCA, LVA, LVV, STV, CALL, RTD, UNLINK, etc.

#### Exemple analysé: DIS_BONJOUR
```ada
with TEXT_IO; use TEXT_IO;
procedure DIS_BONJOUR is
begin
  PUT(" Bonjour ");
end DIS_BONJOUR;
```

Génère:
```fasm
include 'TEXT_IO.FINC'
PRO DIS_BONJOUR_L1
ELB 1
begin:
  STR STR_L1, ' Bonjour '
  LCA STR_L1.data_ptr
  CALL STANDARD.TEXT_IO., PUT_L56
ret_lbl:
  UNLINK 1
  RTD
excep:
endPRO
```

### 2. Analyse exhaustive de la spécification DIANA

#### Fichiers analysés
- `diana_CLASS_.txt` : Hiérarchie des classes (231 types)
- `diana_NODES.txt` : Nœuds et attributs (231 nœuds)
- `extraction_DIANA_idl.txt` : Spécification IDL complète

#### Outil créé
**diana_analyzer.py** - Analyseur Python qui:
- Parse la hiérarchie complète des classes DIANA
- Identifie tous les nœuds concrets (feuilles de l'arbre)
- Génère des squelettes de code pour chaque catégorie
- Produit des statistiques de couverture

#### Résultats quantifiés
```
Total nodes: 231

Par catégorie:
- EXP (Expressions)     : 22 nœuds concrets
- STM (Statements)      : 21 nœuds concrets
- DECL (Déclarations)   : 19 nœuds concrets
- TYPE_DEF (Définitions): 16 nœuds concrets
- TYPE_SPEC (Types)     : 17 nœuds concrets
- NAME (Noms)           : 10 nœuds concrets
- CONSTRAINT            :  7 nœuds concrets
```

### 3. Documentation créée

#### Fichiers générés

1. **DIANA_REFERENCE_EXPANDER.md** (Guide de référence)
   - Liste exhaustive des 231 nœuds DIANA
   - Détails sur chaque nœud (attributs, usage, génération)
   - Classification par catégories
   - Stratégie de développement

2. **PLAN_ACTION_EXPANDER.md** (Plan d'action)
   - Méthodologie de développement systématique
   - Priorisation des nœuds (3 niveaux)
   - Workflow pour chaque nœud
   - Estimation: 150-200 heures

3. **skeleton_*.txt** (7 fichiers)
   - Squelettes de code Ada pour chaque catégorie
   - Case statements complets avec tous les nœuds
   - Commentaires sur les attributs

4. **diana_analyzer.py** (Outil d'analyse)
   - Parse spécification DIANA
   - Génère hiérarchies
   - Identifie nœuds concrets
   - Crée squelettes

---

## PROBLÉMATIQUE IDENTIFIÉE

### Le problème
L'EXPANDER actuel (5,971 lignes) a des **"trous"** dans la couverture des nœuds DIANA.

### Cause racine
Développement **empirique** ("au fil de l'eau"):
1. Créer un petit programme test
2. Compiler avec option "P" pour dumper DIANA
3. Ajouter le handler manquant dans l'EXPANDER
4. Recommencer

**Conséquence**: Couverture incomplète et non systématique.

### Solution proposée
Approche **méthodique et exhaustive**:
1. Analyse complète de la spec DIANA ✓
2. Identification de TOUS les nœuds à traiter ✓
3. Audit de l'existant (À FAIRE)
4. Matrice de couverture (À FAIRE)
5. Implémentation systématique par priorité (À FAIRE)

---

## PROCHAINES ÉTAPES

### Étape immédiate: Audit de l'EXPANDER existant

#### Fichiers à analyser
```
src/expander/
├── expander.adb              (1,415 lignes)
├── expander-utils.adb          (420 lignes)
├── expander-structures.adb     (434 lignes)
├── expander-instructions.adb   (945 lignes)
├── expander-expressions.adb  (1,054 lignes)
└── expander-declarations.adb (1,703 lignes)
```

#### Objectifs
1. Identifier les case/when existants
2. Lister les nœuds déjà traités
3. Comprendre les patterns de génération
4. Créer la matrice de couverture

#### Méthode
Parser les fichiers .adb pour extraire:
- Tous les `when node_name =>` dans les case statements
- La structure de chaque handler
- Les macros LLIR générées

### Ensuite: Développement itératif

#### Pour chaque nœud manquant (priorité HAUTE d'abord):

1. **Créer programme test**
   ```ada
   -- Minimal test case
   ```

2. **Dumper DIANA**
   ```bash
   ./a83.sh project test.adb P
   ```

3. **Analyser structure**
   - Identifier attributs
   - Comprendre sous-arbres

4. **Spécifier code cible**
   ```fasm
   ; LLIR/FASM attendu
   ```

5. **Implémenter handler**
   ```ada
   when node_name =>
     -- Code handler
   ```

6. **Tester**
   - Compiler
   - Assembler
   - Exécuter
   - Valider

---

## RESSOURCES DISPONIBLES

### Documentation projet
- `/mnt/project/doc_mise_en_place.md`
- `/mnt/project/structure_TLALOC_compiler.md`
- `/mnt/project/RESUME_ANALYSE_TLALOC.txt`
- `/mnt/project/diana_CLASS_.txt`
- `/mnt/project/diana_NODES.txt`
- `/mnt/project/extraction_DIANA_idl.txt`

### Code source
- GitHub: https://github.com/ViMoBr/Ada83_TLALOC
- Framagit: https://framagit.org/VMo/ada-83-compiler-tools

### Documentation Ada 83
- Wiki: https://ada83.org/wiki/
- Standard: MIL-STD-1815A-1983

### Fichiers générés (session actuelle)
- `/home/claude/DIANA_REFERENCE_EXPANDER.md`
- `/home/claude/PLAN_ACTION_EXPANDER.md`
- `/home/claude/diana_analyzer.py`
- `/home/claude/skeleton_*.txt` (7 fichiers)

### Exemples analysés
- `/mnt/user-data/uploads/dis_bonjour.adb`
- `/mnt/user-data/uploads/DIS_BONJOUR.FINC`
- `/mnt/user-data/uploads/DIS_BONJOUR.fas`
- `/mnt/user-data/uploads/codi_x86_64.finc`

---

## CONCEPTS CLÉS DIANA

### Préfixes d'attributs
- **as_** : Abstract Syntax (arbre syntaxique source)
- **lx_** : Lexical (position source, symboles)
- **sm_** : Semantic (infos ajoutées par SEM_PHASE)
- **cd_** : Code generation (pour EXPANDER)
- **xd_** : eXtended (liens externes, library)

### Classes principales
```
ALL_SOURCE
├─ ALL_DECL (déclarations, items)
├─ SEQUENCES (listes: exp_s, stm_s, etc.)
├─ DEF_NAME (définitions de noms)
├─ TYPE_DEF (définitions de types)
├─ TYPE_SPEC (types résolus)
├─ EXP (expressions)
├─ STM (statements)
├─ CONSTRAINT (contraintes)
└─ ... (24 branches au total)
```

### Hiérarchie expressions (exemple)
```
EXP
├─ NAME
│  ├─ DESIGNATOR
│  │  ├─ USED_NAME (used_op, used_name_id)
│  │  └─ USED_OBJECT (used_char, used_object_id)
│  └─ NAME_EXP
│     ├─ indexed
│     ├─ slice
│     ├─ NAME_VAL (attribute, selected, function_call)
│     └─ all
└─ EXP_EXP
   ├─ AGG_EXP (aggregate, string_literal)
   ├─ EXP_VAL (numeric_literal, null_access, ...)
   ├─ qualified_allocator
   └─ subtype_allocator
```

---

## MACROS LLIR PRINCIPALES

### Gestion procédures
- **PRO** label : Début de procédure
- **endPRO** : Fin de procédure
- **ELB** level : Élaboration body
- **LINK** level, size : Créer frame
- **UNLINK** level : Détruire frame
- **RTD** : Return
- **RTFV** : Return function value

### Pile et données
- **LCA** addr : Load Constant Address
- **LCI** value : Load Constant Integer
- **LCR** value : Load Constant Real
- **LVA** var : Load Variable Address
- **LVV** var : Load Variable Value
- **STV** : Store to Variable
- **STR** label, "text" : String constant

### Contrôle de flux
- **CALL** name : Appel procédure/fonction
- **JMP** label : Jump inconditionnel
- **JZ** label : Jump if zero
- **JNZ** label : Jump if not zero

### Arithmétique
- **ADD_I**, **SUB_I**, **MUL_I**, **DIV_I** : Entiers
- **ADD_R**, **SUB_R**, **MUL_R**, **DIV_R** : Réels
- **CMP_EQ**, **CMP_LT**, **CMP_GT**, etc. : Comparaisons

### Système
- **SYS_EXIT** : Sortie programme
- **SYS_PUT_INT**, **SYS_PUT_STR**, etc. : I/O

---

## PATTERNS DE GÉNÉRATION FASM

### Procédure simple
```fasm
PRO nom_proc_L1
  ELB 1
  begin:
    ; corps
  ret_lbl:
    UNLINK 1
    RTD
  excep:
endPRO
```

### Appel de procédure
```fasm
; Empiler paramètres
LVA param1
; ...
CALL namespace.package., proc_name_L123
```

### String literal
```fasm
STR STR_L1, ' texte '
LCA STR_L1.data_ptr
; Utiliser l'adresse
```

### Variable locale
```fasm
; Dans le prologue
ELB 1
; Allocation implicite selon déclarations

; Accès
LVV var_name  ; Charger valeur
LVA var_name  ; Charger adresse
```

---

## STATISTIQUES TLALOC

### Répartition du code (34,344 lignes)
- SEM_PHASE: 22,193 lignes (64.6%)
- EXPANDER: 5,971 lignes (17.4%)
- IDL: 2,123 lignes (6.2%)
- PAR_PHASE: 1,924 lignes (5.6%)
- LIB_PHASE: 1,230 lignes (3.6%)
- Autres: 902 lignes (2.6%)

### EXPANDER détaillé
- declarations.adb: 1,703 lignes
- expander.adb: 1,415 lignes
- expressions.adb: 1,054 lignes
- instructions.adb: 945 lignes
- structures.adb: 434 lignes
- utils.adb: 420 lignes

---

## RECOMMANDATIONS

### Court terme (cette semaine)
1. ✅ Comprendre l'architecture TLALOC
2. ✅ Analyser la spec DIANA
3. ⏳ Lire le code EXPANDER existant
4. ⏳ Créer la matrice de couverture
5. ⏳ Implémenter 2-3 nœuds prioritaires

### Moyen terme (ce mois)
1. Compléter tous les nœuds priorité HAUTE
2. Tests de régression
3. Documentation patterns

### Long terme (prochain mois)
1. Compléter priorité MOYENNE
2. Compléter priorité BASSE
3. Suite de tests exhaustive

---

## NOTES IMPORTANTES

### Spécificités Ada 83
- Pas de child packages (Ada 95+)
- Pas de protected types
- Tâches avec rendez-vous (accept/entry)
- Génériques avec instanciation explicite

### Spécificités TLALOC
- Pile croissante (inhabituel)
- Co-pile pour tailles dynamiques
- Display de 32 frame pointers
- Pas de registres pour variables (tout sur pile)

### Pièges potentiels
- Gestion des labels (unicité)
- Ordonnancement des déclarations
- Calcul des offsets (alignement)
- Types non contraints (descripteurs)
- Génériques (expansion à l'instanciation)

---

## CONCLUSION

La session a permis de:

1. **Comprendre** l'architecture complète TLALOC
2. **Analyser** exhaustivement la spécification DIANA (231 nœuds)
3. **Identifier** le problème de couverture de l'EXPANDER
4. **Créer** une méthodologie systématique
5. **Générer** les outils et documentation nécessaires

**État d'avancement**: ~20% (analyse et préparation)

**Prochaine action immédiate**: Analyser le code existant de l'EXPANDER pour établir la matrice de couverture et commencer l'implémentation des nœuds manquants prioritaires.

**Estimation temps restant**: 150-200 heures de développement

---

Fin de la synthèse de session.
