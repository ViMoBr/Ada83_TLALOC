### 9.8 **Priorités** ###

1. Chaque tâche peut avoir (c'est optionnel) une priorité, qui est une valeur du sous-type PRIORITY (du type INTEGER) déclaré dans le paquetage de librairie prédéfini SYSTEM (voir 13.7). Une valeur basse indique un degré moindre d'urgence; l'étendue des priorités est définie par l'installation. Une priorité est associée avec une tâche si un pragma

      __pragma__ PRIORITY (_static__expression).

2. apparaît dans la spécification de tâche correspondante; la priorité est donnée par la valeur de l'expression. Une priorité est associée avec le programme principal si un tel pragma apparaît dans sa partie déclarative la plus extérieure. Un seul pragma au plus peut apparaître dans la spécification d'une tâche donnée ou pour un sous-programme qui est une unité de librairie, et ce sont les seuls endroits autorisés pour ce pragma. Un pragma PRIORITY n'a pas d'effet s'il est présent dans un sous-programme autre que le programme principal.

3. La spécification d'une priorité est une indication donnée pour aider l'installation dans l'allocation des ressources processeur aux tâches parallèles lorsqu'il y a plus de tâches éligibles à l'exécution que n'en peuvent supporter les ressources de traitement disponibles. L'effet des priorités sur la planification est définie par la règle suivante:

4. Si deux tâches avec des priorités différentes sont toutes deux éligibles à l'exécution et pourraient raisonnablement être exécutées avec les mêmes processeurs physiques et les mêmes autres ressources de traitement, alors il ne peut se faire que la tâche de plus faible priorité s'exécute alors que celle de plus haute priorité ne le fasse pas.

5. Pour des tâches de même priorité, l'ordre de planification n'est pas défini par le langage. Pour des tâches sans priorité explicite, les règles de planification ne sont pas définies, sauf quand de telles tâches sont engagées dans des rendez-vous. Si les priorités de deux tâches engagées dans un rendez-vous sont définies, le rendez-vous est exécuté avec la plus haute des deux priorités. Si une seule des deux priorités est définie, le rendez-vous est exécuté avec au moins cette priorité. Si aucune des deux priorités n'est définie, la priorité du rendez-vous n'est pas définie.

_Notes:_

6. La priorité d'une tâche est statique et donc fixée. Cependant, durant un rendez-vous la priorité n'est pas nécessairement statique puisqu'elle dépend de la priorité de la tâche appelant l'entrée. Les priorités ne devraient être utilisées  que pour indiquer des degrés d'urgence relative; elle ne devraient pas être utilisées pour la synchronisation de tâches.

7. _Références:_ partie déclarative 3.9, instruction appel d'entrée 9.5, type entier 3.5.4, programme principal 10.1, paquetage system 13.7, pragma 2.8, rendez-vous 9.5, expression statique 4.9, sous-type 3.3, tâche 9, spécification de tâche 9.1