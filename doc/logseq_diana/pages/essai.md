# DIANA – Référence Ada 83 (exemple fonctionnel – 15 nœuds clés)

tags:: #DIANA #Ada83 #reference
- ## Sommaire rapide
  [[root]] → [[user_root]] → [[compilation]] → [[compilation_unit]] → [[package_decl]]  
  [[type_decl]] → [[record_def]] → [[comp_list]]  
  [[subprogram_body]] → [[block_body]] → [[stm_s]]  
  [[pragma]] · [[with]] · [[name_s]] · [[exp_s]]
  
  ---
- ### root
  collapse:: true
- xd_high_page:: [[num_val]]
- xd_user_root:: [[user_root]]
- xd_source_list:: [[sourceline]]
- xd_err_count:: [[num_val]]
- spare_1:: [[void]]
- ### user_root
  collapse:: true
- xd_sourcename:: [[txtrep]]
- xd_structure:: [[compilation]]
- xd_timestamp:: [[Integer]]
- ### compilation
  collapse:: true
- as_compltn_unit_s:: [[compltn_unit_s]]
- lx_srcpos:: [[Source_Position]]
- ### compltn_unit_s
  collapse:: true
- as_list:: [[compilation_unit]]
- ### compilation_unit
  collapse:: true
  | Champ                | Type                     |
  |----------------------|--------------------------|
  | as_context_elem_s    | [[context_elem_s]]       |
  | as_all_decl          | [[ALL_DECL]]             |
  | as_pragma_s          | [[pragma_s]]             |
  | as_with_list         | [[trans_with]]           |
  | xd_parent            | [[compilation_unit]]     |
  | xd_lib_name          | [[symbol_rep]]           |
- ### package_decl
  collapse:: true
- as_source_name:: [[SOURCE_NAME]]
- as_header:: [[HEADER]] → [[package_spec]]
- as_unit_kind:: [[UNIT_KIND]]
- ### type_decl
  collapse:: true
- as_source_name:: [[SOURCE_NAME]]
- as_type_def:: [[TYPE_DEF]] → [[record_def]], [[enumeration_def]], etc.
- ### record_def
  collapse:: true
- as_comp_list:: [[comp_list]]
- ### comp_list
  collapse:: true
- as_decl_s:: [[decl_s]]
- as_variant_part:: [[variant_part]]
- as_pragma_s:: [[pragma_s]]
- ### subprogram_body
  collapse:: true
- as_body:: [[BODY]] → [[block_body]]
- as_header:: [[HEADER]]
- ### block_body
  collapse:: true
- as_stm_s:: [[stm_s]]
- as_item_s:: [[item_s]]
- ### stm_s
  collapse:: true
- as_list:: [[STM_ELEM]] → [[if]], [[loop]], [[assign]], etc.
- ### pragma
  collapse:: true
- as_used_name_id:: [[used_name_id]]
- as_general_assoc_s:: [[general_assoc_s]]
- ### name_s
  collapse:: true
- as_list:: [[NAME]] → [[selected]], [[indexed]], [[function_call]], etc.
- ### exp_s
  collapse:: true
- as_list:: [[EXP]] → [[aggregate]], [[function_call]], [[qualified]], etc.
- ## Types de base (utilisés partout)
- ### num_val
  Type numérique simple – aucun champ
- ### void
  Type vide
- ### txtrep
  Représentation texte
- ### Integer
  Type entier (alias num_val dans certains contextes)
- ### Source_Position
  Position source (ligne/colonne)
- ### symbol_rep
  Nom symbolique interne
- ### ALL_DECL
  Super-classe de toutes les déclarations
- ### TYPE_DEF
  Super-classe de toutes les définitions de type
- ## Test magique : tous les nœuds de ce fichier en table dynamique
  {{query page.tags #DIANA}}
- ## Graphe
  Ouvre le graphe (⌥+G sur Mac / Alt+G sur Windows/Linux) → tu vois déjà un beau réseau DIANA en 2 clics.