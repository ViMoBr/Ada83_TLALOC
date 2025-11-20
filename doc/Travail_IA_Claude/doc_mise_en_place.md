# TLALOC - Document de mise en place initiale

**Date** : 18 novembre 2025
**Objectif** : Préservation du patrimoine informatique Ada 83

## Contexte du projet

### Ressources publiques existantes
1. **Dépôt GitHub** : https://github.com/ViMoBr/Ada83_TLALOC
   - Code source du compilateur Ada 83 expérimental
   - Développement : Linux Ubuntu 24.04, GNAT 13.3.0, FASM (g.kd3c), x86-64

2. **Dépôt Framagit** : https://framagit.org/VMo/ada-83-compiler-tools
   - Copie miroir du projet

3. **Wiki** : https://ada83.org/wiki/index.php?title=Welcome_to_Ada_83_Memory
   - Documentation et mémoire du langage Ada 83 (MIL-STD-1815A-1983)
   - Propulsé par MediaWiki

## Architecture du compilateur TLALOC

### Programme principal
- **ada_comp.adb** : point d'entrée
  - Parsing des arguments : PROJECT_PATH, source, option
  - Orchestration des phases de compilation

### Phases de compilation
1. **PAR_PHASE** : Analyse syntaxique (parsing)
2. **LIB_PHASE** : Gestion de la bibliothèque
3. **SEM_PHASE** : Analyse sémantique
4. **EXPANDER** : Génération de code assembleur FASM
5. **ERR_PHASE** : Gestion des erreurs
6. **WRITE_LIB** : Écriture de la bibliothèque

### Options de compilation
- **S/s** : Arrêt après parsing
- **L/l** : Arrêt après phase bibliothèque
- **M/m** : Arrêt après analyse sémantique
- **C** : Génération code (sans écriture lib)
- **W/w** : Compilation complète avec écriture bibliothèque
- **U/P/A** : Affichage DIANA (représentation interne)

### Workflow de compilation
```
a83.sh → ada_comp → génération .fas → fasmg → exécutable ELF
```

## Modules principaux identifiés

### IDL (Interface Definition Language)
- Fonctions : PAR_PHASE, LIB_PHASE, SEM_PHASE, ERR_PHASE, WRITE_LIB, PRETTY_DIANA
- Gère les chemins : PROJECT_PATH, LIB_PATH, DEFAULT_LIB_PATH
- fournit les fonctions d'accès au réseau/graphe DIANA

### EXPANDER
- Génération du code assembleur FASM
- Appelé depuis ada_comp selon l'option

## Organisation du projet Claude

### Stratégie retenue (Option 3 hybride)
1. **Projet Claude** :
   - Documents de synthèse
   - Architecture et notes de travail
   - Fichiers sources clés uploadés

2. **GitHub** :
   - Code source complet (référence publique)
   - Accès via liens `raw.githubusercontent.com`

3. **Wiki ada83.org** :
   - Documentation publique
   - Contexte historique et patrimonial

### Accès aux ressources externes

#### GitHub
- ✅ Lecture des fichiers via liens `raw.githubusercontent.com`
- ❌ Navigation d'arborescence bloquée
- **Solution** : Fournir des liens raw directs

#### Wiki ada83.org
- ✅ Lecture des pages avec URL explicite
- ❌ Navigation automatique des hyperliens bloquée
- **Solution** : Fournir des URLs directes des pages clés

## Prochaines étapes

1. **Créer le Projet Claude "TLALOC Ada 83 compiler and language memory"**
2. **Uploader ce document** comme référence initiale
3. **Créer un document de structure modulaire** :
   - Graphe des dépendances entre packages
   - Liste des fichiers sources avec liens raw
   - Rôle de chaque module
4. **Organiser les conversations thématiques** :
   - Analyse du code source
   - Documentation/wiki
   - Outils annexes
   - Stratégie globale

## Notes importantes

- **Ada 83 uniquement** : Pas d'Ada 95+ (pas de child packages)
- **Structuration modulaire** : Forte mais pas trop compliquée
- **Objectif patrimonial** : Préservation d'un langage historique
- **MIL-STD-1815A-1983** : Standard de référence (~270 pages)

---

**TODO** : Fournir la liste complète des packages et leurs dépendances
