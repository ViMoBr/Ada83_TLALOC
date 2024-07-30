### 9.7 __Instructions select__ ###

1. Il y a trois formes d'instruction select. L'une fournit une attente sélective pour une ou plusieurs alternatives. Les deux autres fournissent des appels d'entrée conditionnels et temporisés.

2. <pre>
  select_statement ::= selective_wait
        | conditional_entry_call | timed_entry_call
</pre>

3. _Références_: attente sélective 9.7.1, appel d'entrée conditionnel 9.7.2, appel d'entrée temporisé 9.7.3

### 9.7.1 __Attentes sélectives__ ###

1. Cette forme de l'instruction select permet une combinaison d'attente et de sélection d'une ou plusieurs alternatives. La sélection peut dépendre de conditions associées avec chaque alternative de l'attente sélective.

2. <pre>
  selective_wait ::=
        <b>select</b>
          select_alternative
       {<b>or</b>
          select_alternative }
       [<b>else</b>
          sequence_of_statements]
        <b>end select</b>;<br>
  select_alternative ::=
       [ <b>when</b> condition => ]
          selective_wait_alternative<br>
  selective_wait_alternative ::= accept_alternative
       | delay_alternative | terminate_alternative<br>
  accept_alternative ::= accept_statement {sequence_of_statements}<br>
  delay_alternative ::= delay_statement {sequence_of_statements}<br>
terminate_alternative ::= <b>terminate</b>;
</pre>

3. Une attente sélective doit contenir au moins une alternative accept. En plus, une attente sélective peut contenir ou bien une (et une seule) alternative terminate, ou une ou plus alternatives delay, ou une partie else; ces trois possibilités étant mutuellement exclusives.

4. Une alternative select est dite _ouverte_ si elle ne commence pas par __when__ et une condition, ou si la condition est vraie. Elle est _fermée_ sinon.

5. Pour l'exécution d'une attente sélective, toutes conditions spécifiées après __when__ sont évaluées dans un ordre non défini par le langage; ainsi sont déterminées les alternatives ouvertes. Pour une alternative delay ouverte, l'expression delay est aussi évaluée. De même, pour une alternative accept pour une entrée de famille, l'indice d'entrée est aussi évalué. La sélection et l'exécution d'une alternative ouverte, ou de la partie else, achève l'exécution de l'attente sélective; les règles de cette sélection suivent.

6. Les alternatives accept sont considérées en premier. La sélection d'une telle alternative se fait immédiatement si un rendez-vous correspondant est possible, c'est à dire qu'il y a un appel d'entrée correspondant émis par une autre tâche et en attente d'acceptation. Si plusieurs alternatives peuvent ainsi être sélectionnées, l'une d'entre elles est choisie arbitrairement (c'est à dire que le langage ne dit pas laquelle). Quand une telle alternative est choisie, l'instruction accept correspondante et les possibles instructions suivantes sont exécutées. Si aucun rendez-vous n'est immédiatement possible et qu'il n'y a pas de partie else, la tâche attend qu'une alternative ouverte puisse être choisie.

7. La sélection des autres formes d'alternative ou d'une partie else se fait comme suit:

8.   - Une alternative delay ouverte sera choisie si aucune alternative accept ne peut être choisie avant que le délai soit écoulé (immédiatement pour un délai nul ou négatif en l'absence d'appel d'entrée en file d'attente); toutes instructions subséquentes de l'alternative sont alors exécutées. Si plusieurs alternatives delay peuvent ainsi être choisies (c'est à dire ont le même délai), l'une d'elle est choisie arbitrairement.

9.   - La partie else est choisie et ses instructions sont exécutées si aucune alternative accept ne peut être immédiatement choisie, en particulier si toutes les alternatives sont fermées.

10.   - Une alternative terminate ouverte est choisie si les conditions de la section 9.4 sont satisfaites. Une conséquence des autres règles est qu'une alternative terminate ne peut être choisie alors qu'il y a un appel d'entrée en file pour une entrée de la tâche.

11. L'exception PROGRAM_ERROR est levée si toutes les alternatives sont fermées et qu'il n'y a pas de partie else.

12. _Exemples d'instruction select:_
<pre>
    <b>select</b>
      <b>accept</b> DRIVER_AWAKE_SIGNAL;
    <b>or</b>
      <b>delay</b> 30*SECONDES;
      STOPPER_LE_TRAIN;
  <b>end select</b>
</pre>

13. _Exemple d'un corps de tâche avec une instruction select:_
<pre>
  <b>task body</b> RESOURCE <b>is</b>
      BUSY : BOOLEAN := FALSE;
  <b>begin</b>
      <b>loop</b>
        <b>select</b>
          <b>when not</b> BUSY =>
            <b>accept</b> SEIZE <b>do</b>
              BUSY :=TRUE;
            <b>end</b>;
        <b>or</b>
          <b>terminate</b>;
        <b>end select</b>;
      <b>end loop</b>;
  <b>end</b> RESOURCE;
</pre>

14. Une attente sélective est autorisée à avoir plusieurs alternatives delay ouvertes. Une attente sélective est autorisée à avoir plusieurs alternatives accept ouvertes pour la même entrée.

15. _Références_: accept statement 9.5, condition 5.3, déclaration 3.1, expression delay 9.6, instruction delay 9.6, duration 9.6, entrée 9.5, appel d'entrée 9.5, indice d'entrée 9.5, exception program_error 11.1, appel d'entrée en file 9.5, rendez-vous 9.5, instruction select 9.7, sequence d'instructions 5.1, tâche 9

### 9.7.2 __Appels d'entrée conditionnels__ ###

1. Un appel d'entrée conditionnel est un appel d'entrée qui est annulé si un rendez-vous n'est pas immédiatement possible.

2. <pre>
  conditional_entry_call ::=
      <b>select</b>
          entry_call_statement
        [ sequence_of_statements]
      <b>else</b>
          sequence_of_statements
      <b>end select</b>;
</pre>

3. Pour l'exécution d'un appel d'entrée conditionnel, le nom de l'entrée est d'abord évalué. Ceci est suivi par toute évaluation requise des paramètres effectifs comme dans le cas d'un appel de sous-programme (voir 6.4).

4. L'appel d'entrée est annulé si l'exécution de la tâche appelée n'a pas atteint un point où elle est prête à accepter l'appel (c'est à dire une instruction accept pour l'entrée correspondante, ou une instruction select avec une alternative ouverte pour l'entrée), ou s'il y a des appels antérieurs en file d'attente pour l'entrée. Si la tâche appelée a atteint une instruction accept, l'appel d'entrée est annulé si une alternative accept pour l'entrée n'est pas sélectionnée.

5. Si l'appel d'entrée est annulé, les instructions de la partie else sont exécutés. Sinon, le rendez-vous a lieu, et la séquence d'instructions optionnelle après l'appel d'entrée est ensuite exécutée.

6. L'exécution d'un appel d'entrée conditionnel lève l'exception TASKING_ERROR si la tâche appelée a déjà fini de s'exécuter (voir 9.10 pour le cas où une tâche devient anormale).

7. <pre><b>procedure</b> SPIN ( R : RESOURCE ) <b>is</b>
  <b>begin</b>
      <b>loop</b>
        <b>select</b>
          R.SEIZE;
          <b>return</b>;
        <b>else</b>;
            <b>null</b>;   -- attente active
        <b>end select</b>;
      <b>end loop</b>;
  <b>end</b> RESOURCE;
</pre>

8. _Références_: tâche anormale 9.10, instruction accept 9.5, partie paramètre effectif 6.4, tâche finie 9.4, instruction appel d'entrée 9.5, famille d'entrées 9.5, indice d'entrée9.5, évaluation 4.5, expression 4.4, alternative ouverte 9.7.1, appel d'entrée en file d'attente 9.5, rendez-vous 9.5, instruction select 9.7, séquence d'instructions 5.1, tâche 9, exception tasking_error 11.1

### 9.7.3 __Appels d'entrée temporisés__ ###

1. Un appel d'entrée temporisé est un appel d'entrée qui est annulé si un rendez-vous n'est pas amorcé dans un délai fixé.

2. <pre>
  timed_entry_call ::=
      <b>select</b>
          entry_call_statement
        [ sequence_of_statements]
      <b>or</b>
          delay_alternative
      <b>end select</b>;
</pre>

3. Pour l'exécution d'un appel d'entrée temporisé, le nom de l'entrée est d'abord évalué. Ceci est suivi par toute évaluation requise des paramètres effectifs comme dans le cas d'un appel de sous-programme (voir 6.4). l'expression du delai est ensuite évaluée, puis l'appel d'entrée est effectué.

4. Si un rendez-vous peut être amorcé dans la durée spécifiée (ou immédiatement, comme pour un appel d'entrée conditionnel, pour un délai nul ou négatif), il est effectué et la séquence optionnelle d'instructions suivant l'appel d'entrée est ensuite exécutée. Dans le cas contraire, l'appel d'entrée est annulé lorsque le délai spécifié est expiré, et la séquence optionnelle d'instructions de l'alternative delai est exécutée.

5. L'exécution d'un appel d'entrée temporisé lève l'exception TASKING_ERROR si la tâche appelée a fini de s'exécuter avant d'accepter l'appel (voir aussi 9.10 pour le cas où la tâche appelée devient anormale).

6. _Exemple:_
<pre>
    <b>select</b>
      CONTROLLER.REQUEST ( MEDIUM )( SOME_ITEM );
    <b>or</b>
      <b>delay</b> 45.0;
      --  contrôleur trop occupé, essayer autre chose;
  <b>end select</b>
</pre>

7. _Références_: tâche anormale 9.10, instruction accept 9.5, partie paramètre effectif 6.4, tâche finie 9.4, appel d'entrée conditionnel 9.7.2, expression delay 9.6, instruction delay 9.6, duration 9.6 instruction appel d'entrée 9.5, famille d'entrée 9.5, indice d'entrée 9.5, évaluation 4.5, expression 4.4, rendez-vous 9.5, séquence d'instructions 5.1, tâche 9, exception tasking_error 11.1
