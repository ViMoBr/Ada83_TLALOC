### 9.10 **Instructions abort**

1. Une instruction abort fait qu'une ou plusieurs tâches deviennent anormales, ce qui empêche tout rendez-vous ultérieur avec de telles tâches.

2. <pre> abort_statement ::= <b>abort</b> <i>task</i>_name {, <i>task</i>_name};</pre>

3. La détermination du type de chaque nom de tâche  vient de ce que le type de chaque nom est un type tâche.

4. Pour l'exécution d'une instruction abort, les noms de tâches donnés sont évalués dans un ordre non défini par le langage. Chaque tâche nommée devient alors anormale à moins qu'elle ne soit déjà terminée; de même toute tâche qui dépend d'une tâche nommée devient anormale à moins d'être déjà terminée.

5. Toute tâche anormale dont l'exécution est suspendue sur une instruction accept, une instruction select, ou une instruction delay devient achevée; toute tâche anormale dont l'exécution est suspendue sur un appel d'entrée, et qui n'est pas encore dans un rendez-vous correspondant, devient achevée et est enlevée de la file d'entrée; toute tâche anormale qui n'a pas encore commencé son activation devient achevée (et donc aussi terminée). Ceci achève l'exécution de l'instruction abort.

6. L'achèvement de toute autre tâche anormale n'est pas tenu de se produire avant l'achèvement de l'instruction abort. Il doit se produire au plus tard lorsque la tâche atteint un point de synchronisation qui est l'un des suivants: la fin de son activation; un endroit où elle cause l'activation d'une autre tâche; un appel d'entrée; le début d'une instruction accept; une instruction select; une instruction delay; un traiteur d'exception; ou une instruction abort. Si une tâche qui appelle une entrée devient anormale pendant le rendez-vous, sa mise à terme ne se produit pas avant la fin du rendez-vous (voir 11.5).

7. L'appel d'une entrée de tâche anormale lève l'exception TASKING_ERROR au lieu de l'appel. De même, l'exception TASKING_ERROR est levée pour toute tâche qui a appelé une entrée d'une tâche anormale, si l'appel est encore en file ou si le rendez-vous n'est pas encore fini (que l'appel d'entrée soit une instruction d'appel d'entrée, ou  un appel d'entrée conditionnel ou temporisé); l'exception est levée pas plus tard que l'achèvement de la tâche anormale. La valeur de l'attribut CALLABLE est à faux pour toute tâche qui est anormale (ou achevée).

8. Si l'achèvement anormal d'une tâche se produit pendant que la tâche met à jour une variable, alors la valeur de la variable est non définie.

9. _Exemple:_
<pre><b>abort</b> USER, TERMINAL.__all__, POOL(3);</pre>
_Notes:_
10. Une instruction abort ne devrait être utilisée que dans des situations très graves exigeant une mise à terme iconditionnelle. Une tâche peut avorte toute autre tâche, y compris elle même.

11. _Références:_ anormale en rendez-vous 11.5, instruction accept 9.5, activation 9.3, attribut 4.1.4, callable (attribut prédéfini) 9.9, appel d'entrée conditionnel 9.7.2, instruction delay 9.6, tâche dépendante 9.4, instruction appel d'entrée 9.5, évaluation d'un nom 4.1, traiteur d'exception 11.2, valeur booléenne faux 3.5.3, nom 4.1, file d'appels d'entrée 9.5, rendez-vous 9.5, instruction select9.7, instruction 5, tâche 9, exception tasking_error 11.1, tâche terminée 9.4, appel d'entrée temporisé 9.7.3