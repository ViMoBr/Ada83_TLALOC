= 10 **Structure de programme et problèmes de compilation**

1. La structure globale des programmes et les possibilités de compilation séparée sont décrites dans ce chapitre. Un programme est une collection d'une ou plusieurs unités de compilation soumises à un compilateur en une ou plusieurs compilations. Chaque unité de compilation définit la compilation séparée d'une construction qui peut être une déclaration ou un corps de sous-programme, une déclaration ou un corps de package, une déclaration ou un corps génériques, ou une instantiation générique. Sinon cette construction peut être une sous-unité, auquel cas elle inclut le corps d'un sous-programme, d'un package, d'une unité tâche, ou unité générique déclarée dans une autre unité de compilation. 

2. _Références_: compilation 10.1, unité de compilation 10.1, corps générique 12.2, déclaration générique 12.1, instantiation générique 12.3, corps de package 7.1, déclaration de package 7.1, corps de sous-programme 6.3, déclaration de sous-programme 6.1, sous-unité 10.2, corps de tâche 9.1, unité tâche 9

### 10.1 **Unités de compilation - unités de librairie** ###

1. Le texte d'un programme peut être soumis au compilateur en une ou plusieurs compilations. Chaque compilation est une succession d'unités de compilation.

2. ---
> compilation ::= {compilation_unit}
>
> compilation_unit ::=  
>>      context_clause library_unit | context_clause secondary unit
>
> library_unit ::=  
>>         subprogram_declaration  |  package declaration
>>      |  generic_declaration     |  generic_instantiation
>>      |  subprogram_body
>
> secondary_unit ::= library_unit_body  |  subunit
>
> library_unit_body ::=  subprogram_body  |  package_body
>
> ---

3. Les unités de compilation d'un programme sont dites appartenir à une _librairie programme_. Une unité de compilation définit soit une unité de librairie soit une unité secondaire. Une unité secondaire est ou bien le corps propre séparément compilé d'une unité de librairie, ou bien une sous-unité d'une autre unité de compilation. L'indicatif d'un sous-programme séparément compilé (qu'il soit une unité de librairie ou une sous-unité) doit être un identificateur. Au sein d'un librairie programme les noms simples de toutes les unités de librairie doivent être des identificateurs distincts.

4. L'effet de compiler une unité de librairie est de définir (ou redéfinir) cette unité comme appartenant à la librairie programme. Pour les règles de visibilité, chaque unité de librairie agit comme une déclaration qui se produit immédiatement dans le package STANDARD.

5. L'effet de compiler une unité secondaire est de définir le corps d'une unité de librairie, ou dans le cas d'une sous-unité, de définir le corps propre d'une unité de programme déclarée dans une autre unité de compilation. 

6. Un corps de sous-programme fourni dans une unité de compilation est interprété comme une unité secondaire si la librairie programme contient déjà une unité de librairie qui est un sous-programme avec le même nom ; il est sinon interprété à la fois comme unité de librairie et comme le corps d'unité de librairie correspondant ( c'est à dire, comme une unité secondaire).

7. Les unités de compilation d'une compilation sont compilées dans l'ordre donné. Un pragma qui s'applique à l'ensemble de la compilation doit apparaître avant la première unité de compilation de cette compilation.

8. Un sous-programme qui est une unité de librairie peut être utilisé comme _programme principal_ au sens usuel. Chaque programme principal agit comme s'il était appelé par une tâche envionnementale ; les moyens par lesquels cette exécution est initiée ne sont pas prescrits par la définition du langage. Une implémentation peut imposer certaines exigences sur les paramètres et sur le résultat, s'il y en a, d'un programme principal (ces exigences doivent être décrites dans l'Annexe F). Dans tous les cas, chaque implémentation doit permettre, au moins, des programmes principaux qui sont des procédures sans paramètres, et chaque programme principal doit être un sous-programme qui soit une unité de librairie.

_Notes:_

9. Un programme simple peut être constitué d'une seule unité de compilation. Une compilation peut n'avoir aucune unité de compilation ; par exemple, son texte peut être constitué de pragmas.

10. L'indicatif d'une fonction de librairie ne peut pas être un symbole opérateur, mais une déclaration de renommage est autorisée à renommer une fonction de librairie comme un opérateur. Deux sous-programmes de librairie doivent avoir des noms simples distincts et donc ne peuvent pas se surcharger mutuellement. Cependant, des déclarations de renommage peuvent définir des noms surchargés pour de tels sous-programmes, et un sous-programme localement déclaré peut surcharger un sous-programme de librairie. Le nom étendu STANDARD.L peut être utilisé pour une unité de librairie L (à moins que le nom STANDARD soit caché) puisque les unités de librairie agissent comme des déclarations qui apparaissent immédiatement dans le package STANDARD.

11. _Références_: allow 1.6, clause de contexte 10.1.1, déclaration 3.1, indicatif 6.1, environnement 10.4, déclaration générique 12.1, instantiation générique 12.3, dissimulation 8.3, identificateur 2.3, unité de librairie 10.5, déclaration locale 8.1, must 1.6, name 4.1, apparaît immédiatement dans 8.1, opérateur 4.5, symbole opérateur 6.1, surcharge 6.6 8.7, corps de package 7.1, déclaration de package 7.1, paramètre d'un sous-programme 6.2, pragma 2.8, procédure 6.1, unité de programme 6, corps propre 3.9, déclaration de renommage 8.5, nom simple 4.1, package standard 8.6, sous-programme 6, corps de sous-programme 6.3, déclaration de sous-programme 6.1, sous-unité 10.2, tâche 9, visibilité 8.3

### 10.1.1 **Clauses de contexte - clauses "with"** ###

1. Une clause de contexte est utilisée pour préciser les unités de librairie dont les noms sont nécessaires dans une unité de compilation.

2.  <pre> context_clause ::= {with_clause {use_clause}

     with_clause ::=
          <b>with</b> <i>unit</i>_simple_name {, <i>unit</i>_simple_name}
    </pre>

3. Les noms qui apparaîssent dans une clause de contexte doivent être les noms simples d'unités de librairie. Le nom simple de n'importe quelle unité de librairie est permis dans une clause "with". Les seuls noms permis dans une clause "use" d'une clause de contexte sont les noms simples de packages de librairie mentionnés dans les clauses "with" précédentes de la clause de contexte. Un nom simple déclaré par une déclaration de renommage n'est pas permis dans une clause de contexte.

4. Les clauses "with" et les clauses "use" de la clause de contexte d'une unité de librairie _s'appliquent_ à cette unité de librairie ainsi qu'à l'unité secondaire qui définit le corps correspondant (que cette clause soit répétée ou non pour cette unité). De même, les clauses "with" et les clauses "use" de la clause de contexte d'une unité de compilation _s'appliquent_ à cette unité ainsi qu'à ses sous-unités, s'il y en a.

5. Si une unité de librairie est nommée par une clause "with" qui s'applique à une unité de compilation, alors cette unité de librairie est directement visible au sein de l'unité de compilation, sauf là où elle est cachée ; l'unité de librairie est visible comme si elle était déclarée immédiatement dans le paquetage STANDARD (voir 8.6).

6. Les dépendances entre les unités de compilation sont définies par les clauses "with" ; c'est-à-dire qu'une unité de compilation qui mentionne d'autres unités de librairie dans ses clauses "with" dépend de ces unités de librairie. Ces dépendances entre unités sont prises en compte pour déterminer l'ordre permis de compilation (et de recompilation) des unités de compilation, comme expliqué à la section 10.3, et pour déterminer l'ordre permis d'élaboration des unités de compilation, comme expliqué à la section 10.5.

_Notes:_

7. Une unité de librairie nommée par une clause "with" d'une unité de compilation est visible (sauf là où elle est cachée) dans l'unité de compilation et peut donc être utilisée comme unité de programme correspondante. Ainsi, à l'intérieur de l'unité de compilation, le nom d'un paquetage de librairie peut être donné dans les clauses "use" et peut être utilisé pour former des noms étendus ; un sous-programme de librairie peut être appelé ; et des instances d'une unité générique de librairie peuvent être déclarées.

8. Les règles données pour les clauses "with" sont telles que le même effet est obtenu, que le nom d'une unité de libriaire soit mentionné une ou plusieurs fois par les clauses "with" applicables, ou même à l'intérieur d'une clause "with" donnée.

_Exemple 1 : Un programme principal :_

9. Voici un exemple de programme principal constitué d'une seule unité de compilation : une procédure pour imprimer les racines réelles d'une équation quadratique. Le package prédéfini TEXT_IO et un package REAL_OPERATIONS défini par l'utilisateur (contenant la définition du type REAL et des packages REAL_IO et REAL_FUNCTIONS) sont supposés être déjà présents dans la librairie programme. De tels packages peuvent être utilisés par d'autres programmes principaux.

10. <pre> <b>with</b> TEXT_IO, REAL_OPERATIONS; <b>use</b> REAL_OPERATIONS;
     <b>procedure</b> QUADRATIC_EQUATION <b>is</b>

       A, B, C, D : REAL;
       <b>use</b>  REAL_IO,          --  achieves direct visibility of GET and PUT for REAL
            TEXT_IO,          --  achieves direct visibility of PUT for strings and of NEW_LINE
            REAL_FUNCTIONS;   --  achieves direct visibility of SQRT
     <b>begin</b>
       GET(A); GET(B); GET(C);
       D := B**2 - 4.0*A*C;
       <b>if</b> D < 0.0 <b>then</b>
         PUT("Imaginary Roots.");
       <b>else</b>
         PUT("Real Roots : X1 = ");
         PUT((-B - SQRT(D))/2.0*A)); PUT(" X2 = ");
         PUT((-B + SQRT(D))/2.0*A));
       <b>end if</b>;
       NEW_LINE;
     <b>end</b> QUADRATIC_EQUATION;
   </pre>

_Notes sur l'exemple :_ 

11. Les clauses "with" d'une unité de compilation ne doivent mentionner que les noms des sous-programmes et paquets de la librairie dont la visibilité est effectivement nécessaire au sein de l'unité. Elles n'ont pas besoin (et ne devraient pas) mentionner d'autres unités de librairie qui sont utilisées à leur tour par certaines des unités nommées dans les clauses "with" sauf si ces autres unités de bibliothèque sont également utilisées directement par l'unité de compilation courante. Par exemple, le corps du package REAL_OPERATIONS peut avoir besoin d'opérations élémentaires fournies par d'autres packages. Ces derniers paquets ne doivent pas être nommés par la clause "with" de QUADRATIC_EQUATION puisque ces opérations élémentaires ne sont pas directement appelées dans son corps.                                              

12. _Références :_ allow 1.6, unité de compilation 10.1, visibilité directe 8.3,
élaboration 3.9, corps générique 12.2, unité générique 12.1, masquage 8.3, instance
12.3, unité de bibliothèque 10.1, programme principal 10.1, doit 1.6, nom 4.1, package 7,
corps du package 7.1, déclaration du package 7.1, procédure 6.1, unité de programme 6,
unité secondaire 10.1, nom simple 4.1, package prédéfini standard 8.6,
corps du sous-programme 6.3, déclaration du sous-programme 6.1, sous-unité 10.2, type 3.3,
clause d'utilisation 8.4, visibilité 8.3


### 10.1.2  **Examples of Compilation Units** ###

1. Une unité de compilation peut être divisée en un certain nombre d'unités de compilation. Par exemple, considérons le programme suivant.

2. <pre> <b>procedure</b> PROCESSOR <b>is</b> 

      SMALL : <b>constant</b> := 20;
      TOTAL : INTEGER  := 0; 

      <b>package</b> STOCK <b>is</b>
        LIMIT : <b>constant</b> := 1 
        TABLE : <b>array</b> (1 .. LIMIT) <b>of</b> INTEGER;   
        <b>procedure</b> RESTART;
      <b>end</b> STOCK; 

      <b>package body</b> STOCK <b>is</b>
        <b>procedure</b> RESTART <b>is</b>
        <b>begin</b>
          <b>for</b> N <b>in</b> 1 .. LIMIT <b>loop</b>
            TABLE(N) := N;
          <b>end loop</b>;
        <b>end</b>;
      <b>begin</b>
        RESTART;
      <b>end</b> STOCK; 

      <b>procedure</b> UPDATE(X : INTEGER) <b>is</b>
        <b>use</b> STOCK;
      <b>begin</b>
          ...
        TABLE(X) := TABLE(X) + SMALL;
          ...
      <b>end</b> UPDATE; 

    <b>begin</b>
       ...
       STOCK.RESTART;  -- reinitializes TABLE
       ...
    <b>end</b> PROCESSOR; 
   </pre> 

3. Les trois unités de compilation suivantes définissent un programme avec un effet equivalent à l'exemple ci-dessus (les lignes tiretées entre unités de compilation servent à rappeler au lecteur que ces unités ne forment pas nécessairement des textes contigus).

4. _Exemple 2 : Plusieurs unités de compilation :_  

5.   <pre><b>package</b> STOCK <b>is</b>
       LIMIT : <b>constant</b> := 1 
       TABLE : <b>array</b> (1 .. LIMIT) <b>of</b> INTEGER;
       <b>procedure</b> RESTART;
     <b>end</b> STOCK; 

     ------------------------------------------------- 
     </pre>
6.   <pre><b>package body</b> STOCK <b>is</b>
       <b>procedure</b> RESTART <b>is</b>
       <b>begin</b>
         <b>for</b> N <b>in</b> 1 .. LIMIT <b>loop</b>
           TABLE(N) := N;
         <b>end loop</b>;
       <b>end</b>;
     <b>begin</b>
       RESTART;
     <b>end</b> STOCK; 

     ------------------------------------------------- 
     </pre>
7.   <pre><b>with</b> STOCK;
     <b>procedure</b> PROCESSOR <b>is</b> 
       SMALL : <b>constant</b> := 20;
       TOTAL : INTEGER  := 0; 

       <b>procedure</b> UPDATE(X : INTEGER) <b>is</b>
          <b>use</b> STOCK;
       <b>begin</b>
          ...
          TABLE(X) := TABLE(X) + SMALL;
          ...
       <b>end</b> UPDATE;
     <b>begin</b>
       ...
       STOCK.RESTART;  --  reinitializes TABLE
       ...
     <b>end</b> PROCESSOR;  
     </pre> 
8. Notez que dans cette dernière version, le paquet STOCK n'a aucune visibilité des identifiants extérieurs autres que les identifiants prédéfinis (du paquet
STANDARD). En particulier, STOCK n'utilise aucun identifiant déclaré dans PROCESSOR tel que SMALL ou TOTAL ; sinon STOCK n'aurait pas pu être extrait de PROCESSOR de la manière ci-dessus. La procédure PROCESSOR, en revanche, dépend de STOCK et mentionne ce package dans une clause "with".  Cela permet les occurrences internes de STOCK dans le nom développé STOCK.RESTART et dans la clause use. 

9. Ces trois unités de compilation peuvent être soumises dans une ou plusieurs compilations. Par exemple, il est possible de soumettre la spécification du paquet et le corps de package ensemble et dans cet ordre en une seule compilation.  
  
10. _Références :_ unité de compilation 10.1, déclaration 3.1, identifiant 2.3,
pacakge 7, corps de package 7.1, spécification de package 7.1, programme 10,
package standard 8.6, clause "use" 8.4, visibilité 8.3, clause "with" 10.1.1

### 10.2  **Sous-unités d'Unités de Compilation** ###


