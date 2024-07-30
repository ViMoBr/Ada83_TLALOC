1. Les moyens normaux de communication de valeurs entre tâches sont les appels d'entrée et les instructions accept.

2. Si deux tâches lisent ou mettent à jour une variable _partagée_ (c'est à dire une variable accessible par les deux), alors aucune d'entre elles ne peut supposer quoi que ce soit quant à l'ordre dans lequel l'autre fait ses opérations,sauf aux points où elles se synchronisent. Deux tâches sont synchonisées au début et à la fin de leurs rendez-vous. Au début et à la fin de son activation, une tâche est synchronisée avec la tâche qui cause cette activation. Une tâche qui a achevé son exécution est synchronisée avec n'importe quelle autre tâche.

3. pour les actions d'un programme qui utilise des variables partagées, les hypothèses suivantes peuvent toujours être faites:
4.  - Si entre deux points de synchronisation d'une tâche, cette tâche lit une variable partagée dont le type est un type scalaire ou un type accès, alors la variable n'est pas mise à jour par aucune autre tâche en tout temps entre ces deux points.
5.  - Si entre deux points de synchronisation d'une tâche, cette tâche met à jour une variable partagée dont le type est un type scalaire ou un type accès, alors la variable n'est ni lue ni mise à jour par aucune autre tâche en tout temps entre ces deux points.

6. L'exécution du programme est erronée si l'une ou l'autre de ces hypothèses est violée.

7. Si une tâche donnée lit la valeur d'une variable partagée, les hypothèses précédentes permettent à une implantation de conserver des copies locales de la valeur (par exemple dans des registres, ou dans une autre forme de stockage temporaire); aussi longtemps  que la tâche donnée n'atteint pas un point de synchronisation ni ne met à jour la valeur de la variable partagée, les hypothèses ci-dessus impliquent que, pour la tâche donnée, lire une copie locale est équivalent à lire la variable elle-même.

8. De même, si une tâche donnée met à jour la valeur d'une variable partagée, les hypothèses ci-dessus permettent à une implantation de conserver une copie locale de la valeur, et de différer le stockage effectif de la copie locale dans la variable partagée jusqu'à un point de synchronisation, étant entendu que toute lecture ou mise à jour ultérieure de la variable par la tâche donnée est traitée comme une lecture ou mise à jour de la copie locale. D'un autre côté, une implantation n'est pas autorisée à introduire un stockage, à moins que celui-ci soit exécuté dans l'ordre canonique (voir 11.6).

9. Le pragma SHARED peut être utilisé pour spécifier que toute lecture ou mise à jour d'une variable est un point de synchronisation pour cette variable; c'est à dire que les hypothèses ci-dessus sont toujours valables pour cette variable (mais pas nécessairement pour d'autres). La forme de ce pragma est comme suit:
<pre><b>pragma</b> SHARED(<i>variable</i>_simple_name);</pre>
10. Ce pragma n'est autorisé que pour une variable déclarée par une déclaration d'objet et dont le type est un type scalaire ou un type accès; la déclaration de variable et le pragma doivent tous deux se trouver (dans cet ordre) immédiatement dans la même partie déclarative ou la spécification de paquetage; le pragma doit apparaître avant toute occurrence du nom de la variable, autre que dans une clause d'adresse.

11. Une implantation doit restreindre les objets pour lesquels le pragma SHARED est autorisé aux objets pour lesquels chaque lecture ou mise à jour directe est réalisée comme une opération indivisible.

12. _Références:_ instruction accept 9.5, activation 9.3, affectation 5.2, ordre canonique 11.6, partie déclarative 3.9, instruction appel d'entrée 9.5, erroné 1.6, global 8.1, spécification de paquetage 7.1, pragma 2.8, lire une valeur 6.2, rendez-vous 9.5, nom simple 3.1, 4.1, tâche 9, type 3.3, mise à jour de valeur 6.2, variable 3.2.1