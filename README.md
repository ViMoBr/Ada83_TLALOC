# Ada-83-compiler-tools

## Reconstituer un compilateur Ada® norme ANSI/MIL-STD-1815A-1983

## Motivation du projet

Au moment de son apparition, le langage Ada, aujourd'hui "Ada 83", fut une vraie innovation et constituait un univers de programmation spécial contraignant son utilisateur à produire du logiciel bien conçu, tout en offrant à ce même utilisateur une palette de structures et de services logiciels inégalés sous une syntaxe remarquablement naturelle.
Les révisions ultérieures du langage aboutissant d'abord à Ada 95 puis 2005 et 2012 constituent-elles des progrès ? A titre personnel je ne le crois pas. L'introduction de la programmation objet et ses pointeurs omniprésents, ses types estampillés, la complication de la structure possible des programmes avec les paquets fils apportent une fausse impression de richesse alors que se multiplient simultanément les opportunités de faire des noeuds dans le système logiciel.
La plupart des programmes n'ont pas de bénéfice à tirer des mécanismes d'héritage et de structures d'enregistrement extensibles. Les idées qui sous-tendent ces fonctionnalités proviennent de systèmes à usage spécifique, et ce n'est qu'avec artifice qu'on les applique à tous les programmes ; souvent au détriment de la compréhensibilité de ceux-ci.
Quant à la syntaxe des révisions modernes du langage, il est clair que nombre de formules d'expression n'ont aucun sens immédiat et exigent une connaissance approfondie de certaines situations créées par la complexification des versions Ada ultérieures. De Ada 95 à Ada 2012, les révisions ont permis à de nombreux ingénieurs de travailler, mais comme de nombreux système logiciels, les développements empâtent et finalement dégradent la netteté du système d'origine et parfois même la philosophie.

Il apparaît dès lors souhaitable que reste accessible un langage Ada conforme à la définition d'origine Ada 83. Comment peut-on conserver un environnement juste utilisant le langage originel ? Gnat, le compilateur libre le plus utilisé possède une option -gnat83 qui compile en principe une version originelle du langage, mais l'ensemble du système de compilation adapté aux révisions alourdit considérablement l'implantation, et s'il s'agit de ne compiler que la version Ada 83, il serait préférable de n'avoir que le strict nécessaire.
Reconstituer un compilateur Ada 83 pur écrit dans le même langage et librement accessible est à mon avis un projet utile. Mais de quels éléments de code source disposons nous pour mener ce projet de sorte que tout ne soit pas à réécrire et réinventer ex nihilo ?

## Eléments de source accessibles

Ada 83 étant un langage dont l'implantation est assez complexe, il n'existe que très peu de systèmes de compilation disponibles sous forme de code source.

### Le projet Ada NYU
Il existe encore une spécification SETL interprétable produite avant 1990 dans le cadre du Ada project mené au Courant Institute de la New York University. Celle-ci a été conservée par certains passionnés, mais, en elle même, elle est aujourd'hui de peu d'utilité bien que j'aie pu la recompiler avec le Gnu-SETL.

### Ada/Ed-C
La spécification SETL a été traduite en langage C (traduction qui a d'ailleurs fait l'objet d'une collaboration et de thèses en 1986 entre l'Ecole Nationale Supérieure de Télécommunications ENST et l'équipe NYUADA). Ce travail a donné le système Ada/Ed. Les sources C sont toujours accessibles et recompilables moyennant quelques interventions. Cependant, la structure du logiciel C traduit du SETL est un peu difficile à appréhender. Le compilateur produit du code interprété par une machine virtuelle. La représentation intermédiaire résultant des analyses syntaxique et sémantique est particulière et diffère de la représentation DIANA. Ces sources en langage C sont quand même une source d'inspiration, en particulier pour la machine virtuelle et le support d'exécution (runtime), système qui peut être comparé au A-code polonais.

### Les thèses de Pologne
En 1990, au sein du projet ada/IIPS de l'Institut d'informatique de Gliwice, quatre thèses sous la direction de Przemyslaw Szmal ont été écrites par  M.Ciernak (traducteur DIANA vers A-code, 6000 lignes de source en Pascal), M.Chlopek (Ada linker, 42 pages de source Pascal), D.Glowaki (runtime, 37 fichiers source en C), A.Wierzinska ( traduction A-code en assembleur Intel 386, pas de source). Le travail de M.Ciernak est particulièrement intéressant parce qu'il utilise la représentation intermédiaire DIANA pour générer le A-code.

### Le traducteur front-end Ada-DIANA de Peregrine Systems
Il eût été souhaitable que fut produit un compilateur Ada 83 en Ada 83. Malheureusement aucun tel source ne fut rendu accessible.
Le seul système qui s'en approchait, à notre connaissance, fut le prototype de traducteur Ada 83 vers DIANA produit par Peregrine Systems vers 1988 sous la direction de Bill Easton. Ce système était fourni dans une suite logicielle composée des deux CD-ROMs de Walnut Creek. Il est apparemment peu connu bien qu'il ait des qualités intéressantes.
Il s'agit d'un traducteur de source Ada 83 en représentation intermédiaire DIANA structuré en phases bien distinctes et opérant sur un système de pages et de pointeurs page/offset qui permettait à l'époque d'économiser sur la mémoire vive en déportant au maximum les données sur support secondaire. Il venait avec un système complet de générateur d'analyse LALR(1) et utilisait de trois façons différente un IDL (Interface Definition Language) pour générer les structures de gestion de l'IDL LALR, de l'IDL DIANA et de l'IDL lui même. Le système d'origine apparaissait d'ailleurs compliqué du fait de ce triple usage.

C'est ce système que nous avons repris ici et largement modifié pour en mieux faire ressortir la structure en profitant de la disponibilité de Gnat. Notre espoir étant que ce prototype, qui est doté de caractéristiques intéressantes, puisse servir de base à un compilateur Ada 83 comparable à Ada-Ed, mais de maintenance facilitée par l'usage d'Ada 83 pour sa programmation.
Il s'agirait donc en grande partie de reprendre le travail de M.Ciernak et de ses collègues polonais, tout en s'inspirant du travail de JP.Rosen et P.Kruchten sur Ada/Ed-C pour reconstituer un compilateur à la norme ANSI/MIL-STD_1815A-1983.

## Commencer par ici

- [Introduction](https://framagit.org/VMo/ada-83-compiler-tools/DOC/introduction.md) 
