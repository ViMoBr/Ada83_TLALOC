# DOCUMENTATION TLALOC EXPANDER - README

Session de travail du 20 novembre 2025

## CONTENU DU PACKAGE

Ce package contient l'analyse complète de la spécification DIANA et les outils pour compléter systématiquement l'EXPANDER du compilateur TLALOC.

---

## FICHIERS PRINCIPAUX

### 1. SYNTHESE_SESSION_TLALOC.md ⭐ **COMMENCER ICI**
**Synthèse complète de la session de travail**
- Vue d'ensemble de l'architecture TLALOC
- Résumé de l'analyse DIANA
- Problématique identifiée et solution proposée
- Prochaines étapes
- Ressources disponibles

→ **Lire ce fichier en premier pour comprendre le contexte global**

---

### 2. DIANA_REFERENCE_EXPANDER.md 📚 **GUIDE DE RÉFÉRENCE**
**Guide exhaustif des nœuds DIANA à traiter**
- 22 nœuds EXP (expressions)
- 21 nœuds STM (statements)
- 19 nœuds DECL (déclarations)
- 16 nœuds TYPE_DEF (définitions de types)
- 17 nœuds TYPE_SPEC (spécifications de types)
- 10 nœuds NAME (noms)
- 7 nœuds CONSTRAINT (contraintes)

**Pour chaque nœud:**
- Description
- Attributs DIANA
- Génération FASM attendue
- Exemples

→ **Utiliser comme référence pendant le développement**

---

### 3. PLAN_ACTION_EXPANDER.md 🎯 **PLAN D'ACTION**
**Méthodologie détaillée pour compléter l'EXPANDER**
- 7 étapes structurées
- Workflow pour chaque nœud
- Priorisation (3 niveaux)
- Estimation: 150-200 heures
- Outils d'aide au développement

→ **Suivre ce plan pour implémenter systématiquement**

---

## OUTILS

### 4. diana_analyzer.py 🔧 **ANALYSEUR PYTHON**
**Outil d'analyse de la spécification DIANA**

**Fonctionnalités:**
- Parse diana_CLASS_.txt et diana_NODES.txt
- Construit la hiérarchie complète des classes
- Identifie tous les nœuds concrets (231 au total)
- Génère des squelettes de code Ada
- Produit des statistiques de couverture

**Usage:**
```bash
python3 diana_analyzer.py
```

**Sorties:**
- Statistiques sur la console
- Squelettes générés (skeleton_*.txt)
- Hiérarchies des classes

→ **Exécuter pour régénérer l'analyse si besoin**

---

## SQUELETTES DE CODE

### 5-11. skeleton_*.txt (7 fichiers) 📝
**Squelettes de code Ada pour chaque catégorie**

- `skeleton_exp.txt` - Expressions (22 nœuds)
- `skeleton_stm.txt` - Statements (21 nœuds)
- `skeleton_decl.txt` - Déclarations (19 nœuds)
- `skeleton_type_def.txt` - Définitions types (16 nœuds)
- `skeleton_type_spec.txt` - Spécifications types (17 nœuds)
- `skeleton_name.txt` - Noms (10 nœuds)
- `skeleton_constraint.txt` - Contraintes (7 nœuds)

**Format:**
```ada
procedure Process_XXX (Node : DIANA.Node) is
  Node_Class : constant DIANA.Class := Get_Class(Node);
begin
  case Node_Class is
    when node_name =>
      -- TODO: Handle node_name
      -- Attribute: attr1 : type1
      -- Attribute: attr2 : type2
      null; -- TODO: Implement
    ...
  end case;
end Process_XXX;
```

→ **Copier/coller dans l'EXPANDER comme base**

---

## UTILISATION RECOMMANDÉE

### Étape 1: Comprendre le contexte
1. Lire `SYNTHESE_SESSION_TLALOC.md`
2. Parcourir `DIANA_REFERENCE_EXPANDER.md`

### Étape 2: Analyser l'existant
1. Lire les fichiers expander*.adb du projet TLALOC
2. Noter les nœuds déjà traités
3. Créer la matrice de couverture (voir PLAN_ACTION)

### Étape 3: Développer systématiquement
Pour chaque nœud manquant (selon priorité):

1. **Référence**: Consulter `DIANA_REFERENCE_EXPANDER.md` pour le nœud
2. **Squelette**: Copier le case branch depuis `skeleton_*.txt`
3. **Test**: Créer mini-programme Ada 83 test
4. **DIANA**: Dumper avec option "P"
5. **Code**: Spécifier le FASM attendu
6. **Implémenter**: Compléter le handler dans l'EXPANDER
7. **Valider**: Compiler, assembler, tester

### Étape 4: Suivre la progression
- Utiliser PLAN_ACTION comme checklist
- Mettre à jour la matrice de couverture
- Tests de régression réguliers

---

## STATISTIQUES DIANA

```
Total: 231 nœuds DIANA

Catégories principales:
  EXP (Expressions)         : 22 nœuds concrets
  STM (Statements)          : 21 nœuds concrets
  DECL (Déclarations)       : 19 nœuds concrets
  TYPE_DEF (Définitions)    : 16 nœuds concrets
  TYPE_SPEC (Types résolus) : 17 nœuds concrets
  NAME (Noms)               : 10 nœuds concrets
  CONSTRAINT (Contraintes)  :  7 nœuds concrets

Hiérarchie:
  ALL_SOURCE (racine)
  ├─ ALL_DECL (24 branches)
  ├─ SEQUENCES (23 types de listes)
  ├─ DEF_NAME (6 branches)
  ├─ TYPE_DEF (10 branches)
  └─ ... (20 autres branches principales)
```

---

## PRIORISATION DES NŒUDS

### Priorité HAUTE (requis pour programmes de base)
- numeric_literal, string_literal
- used_object_id
- procedure_call, function_call
- assign, if, loop, return
- variable_decl, constant_decl

### Priorité MOYENNE (programmes courants)
- indexed, selected, aggregate
- case, exit, goto
- record_def, array_def
- conversion, short_circuit

### Priorité BASSE (fonctionnalités avancées)
- Tâches (accept, delay, entry_call)
- Génériques (instantiation)
- Exceptions avancées
- Pointeurs (access, allocators)

---

## RESSOURCES EXTERNES

### Code source TLALOC
- GitHub: https://github.com/ViMoBr/Ada83_TLALOC
- Framagit: https://framagit.org/VMo/ada-83-compiler-tools

### Documentation
- Wiki Ada 83: https://ada83.org/wiki/
- Standard: MIL-STD-1815A-1983

### Fichiers projet
- `/mnt/project/diana_CLASS_.txt` - Hiérarchie classes
- `/mnt/project/diana_NODES.txt` - Nœuds et attributs
- `/mnt/project/extraction_DIANA_idl.txt` - Spec IDL complète

---

## CONCEPTS CLÉS

### Préfixes attributs DIANA
- `as_` : Abstract Syntax (arbre source)
- `lx_` : Lexical (position, symboles)
- `sm_` : Semantic (infos ajoutées)
- `cd_` : Code generation (pour EXPANDER)
- `xd_` : eXtended (liens externes)

### Macros LLIR principales
- PRO/endPRO : Délimitation procédure
- ELB : Élaboration body
- LINK/UNLINK : Gestion frame
- LCA, LCI, LCR : Load constants
- LVA, LVV : Load variable address/value
- STV : Store to variable
- CALL, RTD : Appel et retour
- JMP, JZ, JNZ : Sauts

---

## AIDE ET SUPPORT

### En cas de problème
1. Consulter `DIANA_REFERENCE_EXPANDER.md` pour détails nœud
2. Vérifier `PLAN_ACTION_EXPANDER.md` pour méthodologie
3. Relancer `diana_analyzer.py` pour régénérer l'analyse
4. Comparer avec exemple DIS_BONJOUR (dans uploads/)

### Pour contribuer
1. Suivre la méthodologie du PLAN_ACTION
2. Documenter les patterns de génération découverts
3. Ajouter tests de régression
4. Mettre à jour la matrice de couverture

---

## ESTIMATION GLOBALE

### Analyse et préparation ✅ (réalisé)
- Compréhension architecture: 2 heures
- Analyse DIANA: 3 heures
- Création outils et docs: 3 heures
**Total: ~8 heures (20%)**

### Développement 🚧 (à faire)
- Audit code existant: 4 heures
- Matrice de couverture: 2 heures
- Implémentation nœuds:
  - Niveau 1 (15 nœuds): 7-8 heures
  - Niveau 2 (25 nœuds): 25 heures
  - Niveau 3 (30 nœuds): 60 heures
**Total: ~100 heures (65%)**

### Tests et documentation 📝 (à faire)
- Suite de tests: 20 heures
- Documentation patterns: 10 heures
- Validation finale: 10 heures
**Total: ~40 heures (15%)**

### TOTAL PROJET: ~150 heures

---

## CHANGELOG

### Version 1.0 (20 novembre 2025)
- Analyse complète spécification DIANA
- Création diana_analyzer.py
- Génération de tous les squelettes
- Documentation exhaustive
- Plan d'action détaillé

---

## LICENCE

Ce travail est dérivé du projet TLALOC:
- GitHub: https://github.com/ViMoBr/Ada83_TLALOC
- Licence: À vérifier sur le dépôt

Documentation générée par Claude (Anthropic) en collaboration avec Vincent Morin.

---

Fin du README.
