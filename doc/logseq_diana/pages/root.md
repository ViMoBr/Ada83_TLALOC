# root
| Champ | Type |
|-------|------|
| xd_high_page | [[num_val]] |
[[user_root]]  (lien vers une autre page)
- # Référence complète des nœuds DIANA – Ada 83
  *Fichier unique – 231 nœuds – liens internes cliquables dans Obsidian/Typora/etc.*
- ## Sommaire
- [Racine & types de base](#racine)
- [Context & unités](#context)
- [Déclarations](#déclarations)
- [Types et contraintes](#types)
- [Statements](#statements)
- [Expressions](#expressions)
- [Type_Spec & Def_Name](#type_spec)
  
  <a name="racine"></a>
- ## Racine & types de base
  
  <details><summary><strong>root</strong> → nœud racine</summary>
  
  | Champ            | Type                     |
  |------------------|--------------------------|
  | xd_high_page     | [[#num_val\|num_val]]        |
  | xd_user_root     | [[#user_root\|user_root]]    |
  | xd_source_list   | [[#sourceline\|sourceline]]  |
  | xd_err_count     | [[#num_val\|num_val]]        |
  | spare_1          | [[#void\|void]]              |
  
  </details>
  
  <details><summary><strong>num_val</strong></summary>
  Type numérique simple – aucun champ
  </details>
  
  <details><summary><strong>void</strong></summary>
  Type vide – aucun champ
  </details>
  
  <details><summary><strong>sourceline</strong></summary>
  
  | Champ          | Type                   |
  |----------------|------------------------|
  | xd_number      | [[#num_val\|num_val]]      |
  | xd_error_list  | [[#error\|error]]          |
  
  </details>
  
  <details><summary><strong>error</strong></summary>
  
  | Champ     | Type                        |
  |-----------|-----------------------------|
  | xd_srcpos | [[#Source_Position\|Source_Position]] |
  | xd_text   | [[#txtrep\|txtrep]]              |
  
  </details>
  
  <details><summary><strong>txtrep</strong></summary>
  Représentation texte – aucun champ
  </details>
  
  <details><summary><strong>user_root</strong></summary>
  
  | Champ          | Type                     |
  |----------------|--------------------------|
  | xd_sourcename  | [[#txtrep\|txtrep]]          |
  | xd_grammar     | [[#void\|void]]              |
  | xd_statelist   | [[#void\|void]]              |
  | xd_structure   | [[#compilation\|compilation]]|
  | xd_timestamp   | [[#Integer\|Integer]]        |
  | spare_3        | [[#void\|void]]              |
  </details>