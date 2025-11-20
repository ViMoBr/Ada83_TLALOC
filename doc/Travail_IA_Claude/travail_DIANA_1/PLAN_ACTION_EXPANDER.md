# PLAN D'ACTION: Complétion de l'EXPANDER TLALOC

## Résumé de la situation

**Problème**: L'EXPANDER du compilateur TLALOC est incomplet. Il y a des "trous" dans la génération de code FASM pour certains nœuds DIANA.

**Cause**: Développement empirique ("au fil de l'eau") plutôt que systématique.

**Solution**: Approche méthodique basée sur l'analyse exhaustive de la spécification DIANA.

---

## Étape 1: AUDIT DE L'EXISTANT ✓ (EN COURS)

### Ce qui a été fait
- [x] Analyse de la spécification DIANA complète
- [x] Identification de tous les nœuds concrets (231 au total)
- [x] Classification par catégories (EXP, STM, DECL, etc.)
- [x] Génération de squelettes de code

### Résultats
```
EXP         : 22 nœuds concrets
STM         : 21 nœuds concrets
DECL        : 19 nœuds concrets
TYPE_DEF    : 16 nœuds concrets
TYPE_SPEC   : 17 nœuds concrets
NAME        : 10 nœuds concrets (subset de EXP)
CONSTRAINT  :  7 nœuds concrets
```

---

## Étape 2: LECTURE DU CODE EXISTANT (PROCHAINE ÉTAPE)

### Objectif
Comprendre ce qui est déjà implémenté dans l'EXPANDER actuel.

### Fichiers à analyser
```
src/expander/
├── expander.adb           (1,415 lignes) - Procédure principale
├── expander-utils.adb       (420 lignes) - Utilitaires
├── expander-structures.adb  (434 lignes) - Génération structures
├── expander-instructions.adb (945 lignes) - Génération instructions
├── expander-expressions.adb (1,054 lignes) - Génération expressions
└── expander-declarations.adb (1,703 lignes) - Génération déclarations
```

### Méthode
1. Identifier les case/when existants pour chaque type de nœud
2. Noter les nœuds traités vs non traités
3. Comprendre les patterns de génération LLIR
4. Documenter les conventions (nommage labels, gestion pile, etc.)

### Outil proposé
Créer un script Python pour parser les fichiers Ada et extraire:
- Tous les `when nom_noeud =>` dans les case statements
- La structure de chaque handler
- Les macros LLIR générées

---

## Étape 3: MATRICE DE COUVERTURE

### Format proposé

| Nœud DIANA | Catégorie | Implémenté | Fichier | Ligne | Priorité | Notes |
|------------|-----------|------------|---------|-------|----------|-------|
| numeric_literal | EXP | ✓ | expressions.adb | 245 | HAUTE | OK |
| string_literal | EXP | ✓ | expressions.adb | 312 | HAUTE | OK |
| aggregate | EXP | ✗ | - | - | HAUTE | TODO |
| procedure_call | STM | ✓ | instructions.adb | 123 | HAUTE | OK |
| if | STM | ✗ | - | - | HAUTE | TODO |
| ... | ... | ... | ... | ... | ... | ... |

### Outil
Script Python pour générer automatiquement cette matrice en comparant:
- Liste exhaustive des nœuds DIANA
- Case statements dans les fichiers .adb de l'EXPANDER

---

## Étape 4: PRIORISATION DES MANQUES

### Niveau 1: CRITIQUE (requis pour programmes de base)
Sans ces nœuds, impossible de compiler des programmes simples.

**Expressions:**
- [ ] numeric_literal (probablement ✓)
- [ ] used_object_id (variable access)
- [ ] function_call / procedure_call (probablement ✓)
- [ ] Opérateurs arithmétiques de base (+, -, *, /)

**Statements:**
- [ ] assign (X := Y)
- [ ] if / then / else
- [ ] loop (for, while)
- [ ] return

**Déclarations:**
- [ ] variable_decl
- [ ] constant_decl
- [ ] subprog_entry_decl (procédure/fonction)

### Niveau 2: IMPORTANT (programmes courants)
Nécessaires pour la plupart des programmes réels.

**Expressions:**
- [ ] indexed (array access)
- [ ] selected (record access)
- [ ] aggregate (construction record/array)
- [ ] conversion
- [ ] short_circuit (and then, or else)

**Statements:**
- [ ] case
- [ ] exit
- [ ] goto

**Types:**
- [ ] record_def
- [ ] constrained_array_def
- [ ] unconstrained_array_def
- [ ] enumeration_def

### Niveau 3: AVANCÉ (fonctionnalités complètes Ada 83)
Pour compatibilité complète du langage.

**Concurrence:**
- [ ] task_decl
- [ ] accept
- [ ] delay
- [ ] selective_wait
- [ ] entry_call

**Génériques:**
- [ ] generic_decl
- [ ] instantiation

**Exceptions:**
- [ ] exception_decl
- [ ] raise
- [ ] handlers

**Avancé:**
- [ ] access_def (pointeurs)
- [ ] qualified_allocator (new)
- [ ] Attributs (X'First, X'Last, etc.)

---

## Étape 5: MÉTHODOLOGIE DE DÉVELOPPEMENT

### Pour chaque nœud manquant:

#### A. Préparation
1. Créer un mini-programme Ada 83 test
   ```ada
   -- test_if.adb
   procedure Test_If is
     X : Integer;
   begin
     if X > 0 then
       X := 1;
     else
       X := 0;
     end if;
   end Test_If;
   ```

2. Compiler avec TLALOC option "M" (stop après sémantique)
   ```bash
   ./a83.sh /path/to/project test_if.adb M
   ```

3. Dumper le DIANA avec option "P"
   ```bash
   ./a83.sh /path/to/project test_if.adb P
   ```

#### B. Analyse DIANA
4. Étudier la structure DIANA produite
   - Identifier le nœud cible (ex: `if`)
   - Noter tous ses attributs
   - Comprendre les sous-arbres (conditions, branches)

5. Faire un schéma de la structure
   ```
   if (node)
     └─ as_test_clause_elem_s: test_clause_elem_s
         └─ cond_clause
             ├─ as_exp: EXP (condition)
             └─ as_stm_s: stm_s (then branch)
     └─ as_stm_s: stm_s (else branch)
   ```

#### C. Spécification du code cible
6. Définir le code LLIR/FASM à générer
   ```fasm
   ; Code pour if X > 0 then ... else ... end if
   
   ; Évaluer condition
   LVV X          ; Charger valeur de X
   LCI 0          ; Charger constante 0
   CMP_GT         ; Comparer >
   
   ; Test et branchements
   JZ else_L123   ; Si faux, aller à else
   
   ; Then branch
   LCI 1
   LVA X
   STV            ; X := 1
   JMP endif_L123
   
   ; Else branch
   else_L123:
   LCI 0
   LVA X
   STV            ; X := 0
   
   endif_L123:
   ; Suite du code
   ```

#### D. Implémentation
7. Localiser le bon fichier dans l'EXPANDER
   - Statements → expander-instructions.adb
   - Expressions → expander-expressions.adb
   - Déclarations → expander-declarations.adb
   - Structures → expander-structures.adb

8. Ajouter le case branch
   ```ada
   when if =>
     -- Traiter le nœud if
     declare
       Test_Clauses : constant Node := Get_As_Test_Clause_Elem_S(N);
       Else_Part : constant Node := Get_As_Stm_S(N);
       Else_Label : constant String := New_Label;
       Endif_Label : constant String := New_Label;
     begin
       -- Générer code pour chaque clause
       Process_Test_Clauses(Test_Clauses, Else_Label);
       
       -- Branche else
       Emit(Else_Label & ":");
       Process_Statements(Else_Part);
       
       -- Fin du if
       Emit(Endif_Label & ":");
     end;
   ```

#### E. Test et validation
9. Compiler le programme test avec l'EXPANDER modifié
   ```bash
   ./a83.sh /path/to/project test_if.adb C
   ```

10. Vérifier le fichier .FINC généré
    - Instructions correctes ?
    - Labels cohérents ?
    - Pas d'erreur FASM ?

11. Assembler et tester l'exécutable
    ```bash
    fasmg test_if.fas test_if
    ./test_if
    echo $?  # Vérifier code retour
    ```

12. Tests de régression
    - Vérifier que DIS_BONJOUR fonctionne toujours
    - Vérifier autres programmes existants

---

## Étape 6: OUTILS D'AIDE AU DÉVELOPPEMENT

### A. Script d'analyse de couverture

```python
# coverage_checker.py
# Compare nœuds DIANA vs implémentation EXPANDER
```

### B. Générateur de tests

```python
# test_generator.py
# Génère automatiquement des mini-programmes test pour chaque nœud
```

### C. Comparateur DIANA

```python
# diana_diff.py
# Compare deux dumps DIANA pour voir les différences
```

### D. Validateur FASM

```python
# fasm_validator.py
# Vérifie la syntaxe FASM générée
```

---

## Étape 7: DOCUMENTATION

### À créer au fur et à mesure
1. **Catalogue des patterns LLIR**
   - Pour chaque type de nœud, le pattern de génération
   - Exemples commentés

2. **Guide du développeur EXPANDER**
   - Comment ajouter un nouveau handler
   - Conventions de nommage
   - Gestion des labels
   - Gestion de la pile

3. **Tests de référence**
   - Suite de programmes Ada 83 couvrant tous les nœuds
   - Résultats attendus

---

## PROCHAINES ACTIONS IMMÉDIATES

### Action 1: Lire expander-expressions.adb
**Objectif**: Comprendre comment string_literal est traité (déjà vu dans DIS_BONJOUR)

### Action 2: Lire expander-instructions.adb
**Objectif**: Comprendre comment procedure_call est traité

### Action 3: Créer la matrice de couverture
**Objectif**: Savoir exactement ce qui manque

### Action 4: Implémenter le premier nœud manquant prioritaire
**Objectif**: Valider la méthodologie

---

## ESTIMATION

### Effort par nœud
- Nœud simple (ex: null_stm): 10 minutes
- Nœud moyen (ex: assign): 30 minutes
- Nœud complexe (ex: aggregate): 2 heures

### Total estimé
- Niveau 1 (15 nœuds × 30 min): ~7-8 heures
- Niveau 2 (25 nœuds × 1 heure): ~25 heures
- Niveau 3 (30 nœuds × 2 heures): ~60 heures

**Total: ~90-100 heures de développement**

Avec documentation, tests, debugging: **150-200 heures**

---

## CONCLUSION

Nous avons maintenant:
1. ✓ Une liste exhaustive de tous les nœuds DIANA à traiter
2. ✓ Une classification et priorisation
3. ✓ Une méthodologie de développement systématique
4. ✓ Des outils d'analyse

**Prochaine étape**: Analyser le code existant de l'EXPANDER pour établir la matrice de couverture.

Voulez-vous que je procède à l'analyse des fichiers expander*.adb ?
