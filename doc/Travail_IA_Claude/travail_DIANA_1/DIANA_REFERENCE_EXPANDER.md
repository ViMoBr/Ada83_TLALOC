# GUIDE DE RÉFÉRENCE DIANA POUR L'EXPANDER TLALOC

## Vue d'ensemble

Ce document liste **exhaustivement** tous les nœuds DIANA concrets à traiter dans l'EXPANDER.
Il sert de checklist pour compléter systématiquement la génération de code FASM.

---

## 1. EXPRESSIONS (EXP) - 22 nœuds

### Littéraux et valeurs constantes
1. **numeric_literal** - Littéral numérique (entier, réel)
   - Attributs: lx_numrep, sm_exp_type, sm_value
   - Génération: Empiler la valeur constante (LCI, LCR)

2. **string_literal** - Littéral chaîne
   - Attributs: lx_symrep, sm_exp_type, sm_discrete_range
   - Génération: STR + LCA (vu dans DIS_BONJOUR)

3. **null_access** - Valeur null pour type access
   - Attributs: sm_exp_type, sm_value
   - Génération: Empiler adresse nulle (LCI 0)

4. **used_char** - Caractère énuméré utilisé
   - Attributs: lx_symrep, sm_defn, sm_exp_type, sm_value
   - Génération: Empiler valeur du caractère

### Noms et accès
5. **used_object_id** - Identificateur d'objet utilisé (variable, constante)
   - Attributs: lx_symrep, sm_defn, sm_exp_type, sm_value
   - Génération: LVA/LVV selon le contexte (adresse ou valeur)

6. **used_name_id** - Identificateur de nom générique
   - Attributs: lx_symrep, sm_defn
   - Génération: Dépend du contexte (type, package, etc.)

7. **used_op** - Opérateur utilisé
   - Attributs: lx_symrep, sm_defn
   - Génération: Appel fonction opérateur

8. **indexed** - Accès indexé (tableau[i])
   - Attributs: as_name, as_exp_s (indices), sm_exp_type
   - Génération: Calculer indices, calculer offset, LVA/LVV

9. **selected** - Sélection de composant (record.field)
   - Attributs: as_name, as_designator, sm_exp_type, sm_value
   - Génération: Calculer offset du champ, LVA/LVV

10. **slice** - Tranche de tableau (array[i..j])
    - Attributs: as_name, as_discrete_range, sm_exp_type
    - Génération: Descripteur de slice (adresse début, bornes)

11. **all** - Déréférencement (ptr.all)
    - Attributs: as_name, sm_exp_type
    - Génération: Charger adresse, déréférencer

12. **attribute** - Attribut prédéfini (T'First, X'Length, etc.)
    - Attributs: as_name, as_used_name_id, as_exp, sm_exp_type, sm_value
    - Génération: Selon attribut (First, Last, Length, Size, etc.)

### Appels et conversions
13. **function_call** - Appel de fonction
    - Attributs: as_name, as_general_assoc_s, sm_normalized_param_s, lx_prefix
    - Génération: Empiler params, CALL, récupérer résultat

14. **conversion** - Conversion de type
    - Attributs: as_exp, as_name, sm_exp_type, sm_value
    - Génération: Évaluer expr, convertir (CNVI, CNVR, etc.)

15. **qualified** - Expression qualifiée (Type'(expr))
    - Attributs: as_exp, as_name, sm_exp_type, sm_value
    - Génération: Vérifier type, évaluer expr

### Opérations
16. **short_circuit** - Court-circuit (and then, or else)
    - Attributs: as_exp1, as_short_circuit_op, as_exp2, sm_exp_type
    - Génération: Évaluer exp1, test conditionnel, éventuellement exp2

17. **range_membership** - Test d'appartenance (X in A..B)
    - Attributs: as_exp, as_membership_op, as_range, sm_exp_type
    - Génération: Évaluer expr, tester bornes, empiler booléen

18. **type_membership** - Test de type (X in Type)
    - Attributs: as_exp, as_membership_op, as_name, sm_exp_type
    - Génération: Vérifier contrainte de type

### Agrégats et allocations
19. **aggregate** - Agrégat (record/array)
    - Attributs: as_general_assoc_s, sm_exp_type, sm_discrete_range, sm_normalized_comp_s
    - Génération: Construire structure avec composants

20. **qualified_allocator** - Allocation qualifiée (new Type'(value))
    - Attributs: as_qualified, sm_exp_type
    - Génération: Allouer mémoire, initialiser, empiler adresse

21. **subtype_allocator** - Allocation de sous-type (new Type)
    - Attributs: as_subtype_indication, sm_exp_type, sm_desig_type
    - Génération: Allouer mémoire, empiler adresse

### Parenthèses
22. **parenthesized** - Expression parenthésée
    - Attributs: as_exp, sm_exp_type, sm_value
    - Génération: Évaluer sous-expression (transparent)

---

## 2. STATEMENTS (STM) - 21 nœuds

### Contrôle de flux basique
1. **null_stm** - Instruction vide
   - Génération: Rien (ou NOP si debug)

2. **assign** - Affectation (X := E)
   - Attributs: as_name, as_exp
   - Génération: Évaluer expr, stocker dans variable (STV)

3. **return** - Retour de fonction/procédure
   - Attributs: as_exp (optionnel)
   - Génération: Évaluer expr si présente, RTD/RTFV

4. **exit** - Sortie de boucle
   - Attributs: as_name, as_exp, sm_stm
   - Génération: Test condition, JMP vers après boucle

5. **goto** - Saut inconditionnel
   - Attributs: as_name
   - Génération: JMP vers label

### Structures conditionnelles
6. **if** - Instruction if
   - Attributs: as_test_clause_elem_s, as_stm_s (else)
   - Génération: Évaluer condition, JZ, branches then/else

7. **case** - Instruction case
   - Attributs: as_exp, as_alternative_s
   - Génération: Évaluer expr, table de sauts/tests successifs

### Boucles
8. **loop** - Boucle
   - Attributs: as_source_name, as_iteration, as_stm_s, cd_after_loop
   - Génération: Label début, corps, test, JMP début, label fin

### Appels
9. **procedure_call** - Appel de procédure
   - Attributs: as_name, as_general_assoc_s, sm_normalized_param_s
   - Génération: Empiler params, CALL (vu dans DIS_BONJOUR)

10. **function_call** - (aussi dans EXP) - Appel de fonction
    - Même que dans expressions

11. **entry_call** - Appel d'entrée de tâche
    - Attributs: as_name, as_general_assoc_s, sm_normalized_param_s
    - Génération: Similaire à procedure_call + synchronisation

### Blocs et labels
12. **labeled** - Statement étiqueté
    - Attributs: as_source_name_s, as_pragma_s, as_stm
    - Génération: Label + statement

13. **block** - Bloc déclaratif
    - Attributs: as_source_name, as_block_body
    - Génération: LINK, déclarations, stms, UNLINK

### Exceptions
14. **raise** - Lever une exception
    - Attributs: as_name
    - Génération: JMP vers handler

15. **code** - Machine code insertion
    - Attributs: as_name, as_exp
    - Génération: Code assembleur inline

### Tâches (concurrence)
16. **accept** - Accepter rendez-vous
    - Attributs: as_name, as_param_s, as_stm_s
    - Génération: Synchronisation + exécution

17. **delay** - Délai temporel
    - Attributs: as_exp
    - Génération: Appel système temporisation

18. **selective_wait** - Attente sélective
    - Attributs: as_test_clause_elem_s, as_stm_s
    - Génération: Table alternatives + sélection

19. **terminate** - Terminaison de tâche
    - Génération: Sortie tâche

20. **cond_entry** - Appel entrée conditionnel
    - Attributs: as_stm_s1, as_stm_s2
    - Génération: Test + appel ou alternative

21. **timed_entry** - Appel entrée temporisé
    - Attributs: as_stm_s1, as_stm_s2
    - Génération: Timeout + alternatives

22. **abort** - Avorter tâche
    - Attributs: as_name_s
    - Génération: Arrêt forcé tâches

---

## 3. DÉCLARATIONS (DECL) - 19 nœuds

### Variables et constantes
1. **variable_decl** - Déclaration variable
   - Attributs: as_source_name_s, as_exp (init), as_type_def
   - Génération: Réserver espace, initialiser si expr présente

2. **constant_decl** - Déclaration constante
   - Attributs: as_source_name_s, as_exp, as_type_def
   - Génération: Calculer valeur, stocker en constante/zone données

3. **number_decl** - Déclaration nombre (constante numérique)
   - Attributs: as_source_name_s, as_exp
   - Génération: Évaluer expr à la compilation, remplacer par valeur

4. **deferred_constant_decl** - Constante différée (partie privée)
   - Attributs: as_source_name_s, as_name
   - Génération: Réserver référence, compléter dans body

### Types
5. **type_decl** - Déclaration type
   - Attributs: as_source_name, as_dscrmt_decl_s, as_type_def
   - Génération: Enregistrer info type, calculer taille/alignement

6. **subtype_decl** - Déclaration sous-type
   - Attributs: as_source_name, as_subtype_indication
   - Génération: Enregistrer contrainte sur type de base

### Unités de compilation
7. **subprog_entry_decl** - Déclaration sous-programme/entrée
   - Attributs: as_source_name, as_header, as_unit_kind
   - Génération: Enregistrer signature, générer PRO/endPRO si body

8. **package_decl** - Déclaration package
   - Attributs: as_source_name, as_header, as_unit_kind
   - Génération: Élaboration spec, zone variables package

9. **generic_decl** - Déclaration générique
   - Attributs: as_source_name, as_header, as_item_s
   - Génération: Template, instanciation à la demande

10. **task_decl** - Déclaration tâche
    - Attributs: as_source_name, as_decl_s
    - Génération: Structure tâche, mécanismes synchronisation

### Exceptions
11. **exception_decl** - Déclaration exception
    - Attributs: as_source_name_s
    - Génération: Enregistrer ID exception, handlers

### Renommages et use
12. **renames_obj_decl** - Renommage objet
    - Attributs: as_source_name, as_name, as_type_mark_name
    - Génération: Alias vers objet existant

13. **renames_exc_decl** - Renommage exception
    - Attributs: as_source_name, as_name
    - Génération: Alias vers exception

14. **use** - Clause use
    - Attributs: as_name_s
    - Génération: Rendre visible (compilation, pas runtime)

15. **pragma** - Pragma
    - Attributs: as_used_name_id, as_general_assoc_s
    - Génération: Selon pragma (certains affectent génération)

### Représentation
16. **record_rep** - Représentation record
    - Attributs: as_name, as_alignment_clause, as_comp_rep_s
    - Génération: Forcer layout mémoire

17. **length_enum_rep** - Représentation énumération
    - Attributs: as_name, as_exp
    - Génération: Spécifier taille enum

18. **address** - Clause d'adresse
    - Attributs: as_name, as_exp
    - Génération: Placer variable à adresse fixe

### Divers
19. **null_comp_decl** - Composant null (record sans champs)
    - Génération: Structure vide

---

## 4. DÉFINITIONS DE TYPES (TYPE_DEF) - 16 nœuds

### Types scalaires
1. **enumeration_def** - Type énuméré
   - Attributs: as_enum_literal_s
   - Génération: Table des valeurs, calcul taille

2. **integer_def** - Type entier
   - Attributs: as_constraint
   - Génération: Taille selon contrainte (8/16/32/64 bits)

3. **float_def** - Type flottant
   - Attributs: as_constraint
   - Génération: Float/Double selon précision

4. **fixed_def** - Type point fixe
   - Attributs: as_constraint
   - Génération: Représentation fixe avec delta

### Types composites
5. **constrained_array_def** - Tableau contraint
   - Attributs: as_subtype_indication, as_constraint
   - Génération: Taille statique, calcul layout

6. **unconstrained_array_def** - Tableau non contraint
   - Attributs: as_subtype_indication, as_index_s
   - Génération: Descripteur (bounds + data), taille dynamique

7. **record_def** - Type record
   - Attributs: as_comp_list
   - Génération: Layout composants, calcul offsets, alignement

### Types access
8. **access_def** - Type pointeur
   - Attributs: as_subtype_indication
   - Génération: Pointeur 64 bits, gestion collection

### Types dérivés
9. **derived_def** - Type dérivé
   - Attributs: as_subtype_indication, xd_derived_subprog_list
   - Génération: Hériter représentation, dériver opérations

### Types privés
10. **private_def** - Type privé
    - Génération: Type opaque (complété dans body)

11. **l_private_def** - Type privé limité
    - Génération: Type opaque sans affectation

### Types formels (génériques)
12. **formal_dscrt_def** - Type discret formel
    - Génération: Paramètre de template

13. **formal_integer_def** - Type entier formel
    - Génération: Paramètre de template

14. **formal_fixed_def** - Type fixe formel
    - Génération: Paramètre de template

15. **formal_float_def** - Type flottant formel
    - Génération: Paramètre de template

### Sous-types
16. **subtype_indication** - Indication de sous-type
    - Attributs: as_constraint, as_name
    - Génération: Contrainte sur type parent

---

## 5. SPÉCIFICATIONS DE TYPES (TYPE_SPEC) - 17 nœuds

Ces nœuds représentent des types **résolus** après analyse sémantique.
Ils contiennent les informations de layout, taille, alignement calculées.

### Types scalaires résolus
1. **Integer** - Type entier résolu
   - Attributs: sm_base_type, sm_range, cd_impl_size, cd_offset
   - Utilisation: Génération code arithmétique entière

2. **enumeration** - Type énuméré résolu
   - Attributs: sm_base_type, sm_range, sm_literal_s, cd_impl_size
   - Utilisation: Accès valeurs littéraux

3. **float** - Type flottant résolu
   - Attributs: sm_base_type, sm_range, sm_accuracy, cd_impl_size
   - Utilisation: Arithmétique flottante

4. **fixed** - Type fixe résolu
   - Attributs: sm_base_type, sm_range, sm_accuracy, cd_impl_small, cd_impl_size
   - Utilisation: Arithmétique point fixe

### Types composites résolus
5. **array** - Tableau non contraint résolu
   - Attributs: sm_base_type, sm_index_s, sm_comp_type, sm_size, sm_is_packed
   - Utilisation: Calcul indices, accès éléments

6. **constrained_array** - Tableau contraint résolu
   - Attributs: sm_base_type, sm_index_subtype_s, cd_impl_size, cd_alignment, cd_dimensions
   - Utilisation: Accès direct éléments

7. **record** - Record résolu
   - Attributs: sm_base_type, sm_discriminant_s, sm_comp_list, sm_representation, cd_impl_size, cd_alignment
   - Utilisation: Accès champs par offset

8. **constrained_record** - Record contraint résolu
   - Attributs: sm_base_type, sm_normalized_dscrmt_s, cd_impl_size, cd_alignment
   - Utilisation: Layout fixe

### Types access résolus
9. **access** - Pointeur non contraint résolu
   - Attributs: sm_base_type, sm_desig_type, sm_storage_size, sm_master, cd_constrained
   - Utilisation: Déréférencement, allocation

10. **constrained_access** - Pointeur contraint résolu
    - Attributs: sm_base_type, sm_desig_type, cd_impl_size, cd_alignment
    - Utilisation: Déréférencement

### Types privés résolus
11. **private** - Type privé résolu
    - Attributs: sm_discriminant_s, sm_type_spec (type complet)
    - Utilisation: Accès type sous-jacent

12. **l_private** - Type privé limité résolu
    - Attributs: sm_discriminant_s, sm_type_spec
    - Utilisation: Accès type, pas de copie

### Types incomplets
13. **incomplete** - Type incomplet
    - Attributs: sm_discriminant_s, xd_full_type_spec
    - Utilisation: Pointeur vers type complet

### Types tâches
14. **task_spec** - Spécification tâche résolue
    - Attributs: sm_decl_s, sm_body, sm_address, sm_size, sm_storage_size
    - Utilisation: Création tâche, synchronisation

### Types universels
15. **universal_integer** - Entier universel
    - Utilisation: Constantes entières non typées

16. **universal_real** - Réel universel
    - Utilisation: Constantes réelles non typées

17. **universal_fixed** - Fixe universel
    - Utilisation: Constantes fixes non typées

---

## 6. NOMS (NAME) - 10 nœuds

Subset de EXP, tous les nœuds NAME peuvent aussi apparaître comme expressions.
Voir section EXP ci-dessus pour les détails.

---

## 7. CONTRAINTES (CONSTRAINT) - 7 nœuds

1. **range** - Contrainte de plage (A..B)
   - Attributs: as_exp1, as_exp2, sm_type_spec
   - Utilisation: Vérifier bornes, calcul taille

2. **range_attribute** - Plage par attribut (T'Range)
   - Attributs: as_name, as_used_name_id, as_exp, sm_type_spec
   - Utilisation: Récupérer bornes du type

3. **discrete_subtype** - Sous-type discret
   - Attributs: as_subtype_indication
   - Utilisation: Contrainte d'indice

4. **index_constraint** - Contrainte d'indices
   - Attributs: as_discrete_range_s
   - Utilisation: Fixer dimensions tableau

5. **dscrmt_constraint** - Contrainte de discriminants
   - Attributs: as_general_assoc_s
   - Utilisation: Fixer discriminants record

6. **float_constraint** - Contrainte flottant
   - Attributs: as_exp (digits), as_range, sm_type_spec
   - Utilisation: Précision flottante

7. **fixed_constraint** - Contrainte fixe
   - Attributs: as_exp (delta), as_range, sm_type_spec
   - Utilisation: Précision point fixe

---

## STRATÉGIE DE DÉVELOPPEMENT

### Phase 1: Vérification de la couverture actuelle
1. Lire les fichiers expander*.adb existants
2. Identifier les nœuds **déjà traités**
3. Créer une matrice de couverture (nœud -> implémenté oui/non)

### Phase 2: Priorisation des nœuds manquants
1. **Priorité HAUTE**: Nœuds pour programmes simples
   - variable_decl, constant_decl, assign
   - if, loop (for/while)
   - Arithmétique de base (numeric_literal, opérateurs)
   
2. **Priorité MOYENNE**: Structures de données
   - record, array (constrained)
   - indexed, selected
   - aggregate
   
3. **Priorité BASSE**: Fonctionnalités avancées
   - Tâches (accept, delay, etc.)
   - Génériques (instantiation)
   - Exceptions avancées

### Phase 3: Implémentation systématique
Pour chaque nœud manquant:
1. Créer un petit programme Ada 83 test
2. Compiler avec option "P" pour dumper DIANA
3. Analyser la structure DIANA produite
4. Implémenter le handler dans l'EXPANDER
5. Tester la génération FASM
6. Valider l'exécution

### Phase 4: Tests de régression
1. Suite de tests couvrant tous les nœuds
2. Vérification que code existant fonctionne toujours
3. Documentation des patterns de génération

---

## ANNEXE: Préfixes des attributs DIANA

- **as_** : Abstract Syntax (arbre syntaxique)
- **lx_** : Lexical (infos lexicales: position, symboles)
- **sm_** : Semantic (infos sémantiques ajoutées)
- **cd_** : Code generation (infos pour génération code)
- **xd_** : eXtended (infos étendues, liens externes)

---

Fin du document de référence.
