### 9.5 **Entrées, appels d'entrée et instructions accept**

1. Les appels d'entrée et les instructions accept sont les principaux moyens de synchronisation des tâches, et de communication de valeurs entre tâches. Une déclaration d'entrée ressemble à une déclaration de sous-programme et n'est autorisée que dans une spécification de tâche. Les actions à effectuer quand une entrée est appelée sont spécifiées par les instructions accept correspondantes.

2. <pre>entry_declaration ::=
      <b>entry</b> identifier [(discrete_range)] [formal_part];<br>
entry_call_statement ::= <i>entry</i>_name [actual_parameter_part];<br>
accept_statement ::=
      <b>accept</b> <i>entry</i>_simple_name [(entry_index)] [formal_part] [<b>do</b>
         sequence_of_statements
      <b>end</b> [<i>entry</i>_simple_name]];<br>
entry_index ::= expression
</pre>

3. Une déclaration d'entrée qui inclut une étendue discrète (voir 3.6.1) déclare une _famille_ d'entrées distinctes ayant la même partie formelle (s'il y en a une); C'est à dire une telle entrée pour chaque valeur de l'étendue discrète. Le terme d'_entrée unique_ est utilisé dans la définition de toute règle s'appliquant à une entrée autre que celle d'une famille. La tâche désignée par un objet de type tâche possède les entrées déclarées dans la spécification du type tâche.

4. Dans le corps d'une tâche, chacune de ses entrées uniques ou familles d'entrées peut être nommée par le nom simple correspondant. Le nom d'une entrée de famille a la forme d'une composante indicée, le nom simple de famille étant suivi par l'indice entre parenthèses; le type de cet indice doit être le même que celui de l'étendue discrète dans la déclaration correspondante de la famille d'entrées. En dehors du corps d'une tâche, le nom d'entrée a la forme d'une composante sélectionnée, dont le préfixe dénote l'objet tâche, et dont le sélecteur est le nom simple d'une des entrées uniques ou d'une famille d'entrées.

5. Une entrée unique surcharge un sous-programme, un littéral énuméré, ou une autre entrée unique si ils ont le même identificateur. La surcharge n'est pas définie pour les familles d'entrées. Une entrée unique ou une entrée de famille peuvent être renommées comme une procédure ainsi qu'expliqué en 8.5.

6. Les modes de paramétrage définis pour les paramètres de la partie formelle d'une déclaration d'entrée sont les mêmes que pour une déclaration de sous-programme et ont la même signification (voir 6.2). La syntaxe d'une instruction d'appel d'entrée est semblable à celle de l'instruction d'appel de procédure, et les règles d'association des paramètres sont les mêmes que pour les appels de sous-programme.

7. Une instruction accept spécifie les actions à effectuer à l'appel de l'entrée nommée (qui peut être une entrée d'une famille). La partie formelle de l'instruction accept doit se conformer à la partie formelle donnée dans la déclaration de l'entrée unique ou de la famille d'entrées nommée par l'instruction accept (voir la section 6.3.1 pour les règles de conformation). Si un nom simple apparaît à la fin d'une instruction accept, il doit répéter celui donné au début.

8. Une instruction accept pour une entrée d'une tâche donnée n'est permise que dans le corps de tâche correspondant; en excluant l'intérieur du corps de toute unité de programme elle même intérieure au corps de tâche; et excluant l'intérieur d'une autre instruction accept pour la même entrée ou une entrée de la même famille. (Une conséquence de cette règle est qu'une tâche ne peut exécuter d'instruction accept que pour ses propres entrées). Un corps de tâche peut contenir plus d'une instruction accept pour la même entrée.

9. Pour l'élaboration d'une déclaration d'entrée, l'étendue discrète, si elle existe, est évaluée et la partie formelle, s'il y en a une, est ensuite élaborée comme pour une déclaration de sous-programme.

10. L'exécution d'une instruction accept commence par l'évaluation de l'indice d'entrée (dans le cas d'une entrée de famille). L'exécution d'une instruction appel d'entrée commence avec l'évaluation du nom d'entrée; suivie par toute évaluation requise pour les paramètres effectifs de la même facçon que pour un appel de sous-programme (voir 6.4). L'exécution subséquente d'une instruction accept et de l'instruction d'appel d'entrée correspondante sont synchronisés.

11. Si une entrée donnée est appelée par une seule tâche,il y a deux possibilités:
12.  - Si la tâche appelante émet un appel d'entrée avant que l'instruction accept correspondante ne soit atteinte par la tâche à qui appartient l'entrée, l'exécution de la tâche appelante est _suspendue_.

13.  - Si une tâche atteint une instruction accept avant tout appel de cette entrée, l'exécution de la tâche est suspendue jusqu'à ce qu'un appel soit reçu.

14. Lorsqu'une entrée a été appelée et qu'une instruction accept correspondante a été atteinte, la séquence des instructions, s'il y en a une, de l'instruction accept est exécutée par la tâche appelée (cependant la tâche appelante reste suspendue). Cette interaction est appelée un _rendez-vous_. Après cela, la tâche appelante et la tâche propriétaire de l'entrée poursuivent leur exécution en parallèle.

15. Si plusieurs tâches appellent la même entrée avant qu'une instruction accept correspondante soit atteinte, les appels sont mis en file d'attente; il y a une seule file associée avec chaque entrée. Chaque exécution d'une instruction accept retire un appel de la file. Les appels sont traités dans l'ordre d'arrivée.

16. La tentative d'appeler une entrée dont la tâche a achevé son exécution lève l'exception TASKING_ERROR au lieu de l'appel, dans la tâche appelante; de même cette exception est levée au niveau de l'appel si la tâche appelée achève son exécution avant d'accepter l'appel (voir aussi 9.10 pour le cas où la tâche appelée devient anormale). L'exception CONSTRAINT_ERROR est levée si l'indice de l'entrée d'une famille est hors de l'étendue discrète spécifiée.

17. _Exemples de déclarations d'entrée:_
<pre>
<b>entry</b> READ ( V : <b>out</b> ITEM );
<b>entry</b> SEIZE;
<b>entry</b> REQUEST (LEVEL)( D : ITEM );   -- une famille d'entrées
</pre>

18. _Exemples d'appels d'entrée:_
<pre>
CONTROL.RELEASE;                        -- voir 9.2 et 9.1
PRODUCER_CONSUMER.WRITE ( E );          -- voir 9.1
POOL(5).READ ( NEXT_CHAR );             -- voir 9.2 et 9.1
CONTROLLER.REQUEST (LOW)( SOME_ITEM );   -- voir 9.1
</pre>

19. _Exemples d'instructions accept:_
<pre>
<b>accept</b> SEIZE;<br>
<b>accept</b> READ ( V : <b>out</b> ITEM ) <b>do</b>
      V := LOCAL_ITEM;
<b>end</b> READ;<br>
<b>accept</b> REQUEST (LOW)( D : ITEM ) <b>do</b>
      ...
<b>end</b> REQUEST;
</pre>

Notes:

20. La partie formelle donnée dans une instruction accept n'est pas élaborée; elle est seulement utilisée pour identifier l'entrée correspondante.

21. Une instruction accept peut appeler des sous-programmes qui émettent des appels d'entrée. Une instruction accept n'a pas nécessairement une séquence d'instructions même si l'entrée correspondante a des paramètres. De même, elle peut avoir une séquence d'instructions même si l'entrée n'a pas de paramètre. La séquence d'instructions d'une instruction accept peut inclure des instructions return. Une tâche peut appeler l'une de ses propres entrées, mais s'auto verrouillera. Le langage permet des appels conditionnels et temporisés (voir 9.7.2 et 9.7.3). Les règles du langage assurent qu'une tâche ne peut être que dans une seule file d'entrée à un temps donné.

22. Si les bornes de l'étendue discrète d'une famille d'entrées sont des littéraux entiers, l'indice (dans un nom d'entrée ou une instruction accept) doit être du type prédéfini INTEGER (voir 3.6.1).

23. _Références_: tâche anormale 9.10, partie paramètres effectifs 6.4, tâche achevée 9.4, appel d'entrée conditionnel 9.7.2, règles de conformation 6.3.1, exception constraint_error 11.1, désignation 9.1, étendue discrète 3.6.1, élaboration 3.1 3.9, littéral énuméré 3.5.1, évaluation 4.5, expression 4.4, partie formelle 6.1, identificateur 2.3, composante indicée 4.1.1, type entier 3.5.4, nom 4.1, objet 3.2, surcharge 6.6 8.7, exécution parallèle 9, préfixe 4.1, procédure 6, appel de procédure 6.4, déclaration de renommage 8.5, instruction return 5.8, champ 8.2, composante choisie 4.1.3, sélecteur 4.1.3, séquence d'instructions 5.1, expression simple 4.4, nom simple 4.1, sous-programme 6, corps de sous-programme 6.3, déclaration de sous-programme 6.1, tâche 9, corps de tâche 9.1, spécification de tâche 9.1, exception tasking_error 11.1, appel d'entrée temporisé 9.7.3