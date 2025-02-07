### 9.4 **Dépendance des tâches - terminaison des tâches**

1. Chaque tâche _dépend_ d'au moins un maître. Un _maître_ est une construction qui est soit une tâche, une instruction block ou un sous-programme, ou un paquetage de librairie (un paquetage déclaré dans une autre unité de programme n'est pas un maître). La dépendance envers un maître est une dépendance directe dans les deux cas suivants:

2. (a) La tâche désignée par un objet tâche qui est soit l'objet, ou une sous-composante de l'objet, créé par l'évaluation d'un allocateur dépend du maître qui élabore la définition de type accès correspondante.

3. (b) La tâche désignée par tout autre objet tâche dépend du maître dont l'exécution crée l'objet tâche.

4. De plus, si une tâche dépend d'un maître donné qui est une instruction block exécutée par un autre maître, alors la tâche dépend aussi de cet autre maître, de façon indirecte; il en est de même si le maître donné est un sous-programme appelé par un autre maître, et également si le maître donné est une tâche qui dépend (directement ou indirectement) d'un autre maître. Les dépendances existent pour des objets de type privé dont la déclaration complète se fait par l'intermédiaire d'un type tâche.

5. Une tâche est dite avoir _achevé_ son exécution lorsqu'elle a fini l'exécution de la séquence d'instructions qui apparaît après le mot réservé __begin__ dans le corps correspondant. De même, un bloc ou un sous-programme est dit avoir achevé son exécution lorsqu'il a fini l'exécution de la séquence correspondante d'instructions. Pour une instruction block, l'exécution est également dite achevée lorsqu'elle atteint une instruction exit, return ou goto transférant le contrôle hors du bloc. Pour une procédure, l'exécution est aussi dite achevée lorsqu'une instruction return correspondante est atteinte. Pour une fonction, l'exécution est dite achevée après l'évaluation de l'expression résultat d'une instruction return. Finalement, l'exécution d'une tâche, instruction block, ou sous-programme est achevée si une exception est levée par l'exécution de sa séquence d'instructions et qu'il n'y a pas de traiteur d'erreur correspondant, ou, s'il y en a un, lorsqu'elle a fini l'exécution du traiteur correspondant.

6. Si une tâche n'a pas de tâche dépendante, son _terme_  a lieu lorqu'elle a achevé son exécution. Après son terme, une tâche est dite _terminée_. Si une tâche a des tâches dépendantes, son terme a lieu lorsque l'exécution de la tâche est achevée et que toutes les tâches dépendantes sont terminées. Une instruction block ou un corps de sous-programme dont l'exécution est achevée ne sont pas quittés tant que toutes leurs tâches dépendantes ne sont pas terminées.

7. Le terme d'une tâche a lieu par ailleurs si et seulement si son exécution a atteint une alternative terminate ouverte dans une instruction select (voir9.7.1), et que les conditions suivantes sont satisfaites:

8. - La tâche dépend d'un maître dont l'exécution est achevée (donc pas un paquetage de librairie).

9. - Chaque tâche qui dépend du maître considéré est ou bien terminée ou pareillement en attente sur une alternative terminate d'instruction select.

10. Lorsque les deux conditions sont satisfaites, la tâche devient terminée, avec toutes les tâches qui dépendent du maître considéré.

11. _Exemple:_<pre>
<b>declare</b>
      <b>type</b> GLOBAL <b>is access</b> RESOURCE;  --  voir 9.1
      A, B : RESOURCE;
      G    : GLOBAL;
<b>begin</b>
--  activation de A et B
      <b>declare</b>
        <b>type</b> LOCAL <b>is access</b> RESOURCE;
        X  : GLOBAL := <b>new</b> RESOURCE;
        L  : LOCAL  := <b>new</b> RESOURCE;
        C  : RESOURCE;
      <b>begin</b>
        --  activation de C
        G := X;
        ...
      <b>end</b>;  --  attend le terme de C et L.all (mais pas X.all)
<b>end</b>;     -- attend le terme de A, B et G.all 
</pre>
_Notes:_

12. Les règles données pour l'arrivée à terme impliquent que toutes les tâches qui dépendent (directement ou indirectement) d'un maître donné et qui ne sont pas déjà terminées, peuvent être terminées (collectivement) si et seulement si chacune d'entre elle attend sur une alternative terminate ouverte d'instruction select et que l'exécution du maître donné s'achève.

13. Les règles usuelles s'appliquent au programme principal. Par conséquent, la mise à terme du programme principal attend le terme de toute tâche dépendante même si le type tâche correspondant est déclaré dans un paquetage de librairie. D'un autre côté, le terme du programme principal n'attend pas le terme des tâches qui dépendent de paquetages de librairie; le langage ne définit pas si de telles tâches doivent se terminer.

14. Pour un type accès dérivé d'un autre type accès, la définition de type accès correspondante est celle du type parent; la dépendance est envers le maître qui élabore la définition de type accès parente ultime.

15. Une déclaration de renommage définit un nouveau nom pour une entité existante et donc ne crée aucune dépendance supplémentaire.

16. _Références:_ type accès 3.8, allocateur 4.8, instruction block 5.6, déclaration 3.1, désigne 3.8 9.1, exception 11, traiteur d'exception 11.2, instruction exit 5.7, fonction 6.5, instruction goto 5.9, unité de librairie 10.1, programme principal 10.1, objet 3.2, alternative ouverte 9.7.1, paquetage 7, unité de programme 6, déclaration de renommage 8.5, instruction return 5.8, attente sélective 9.7.1, séquence d'instructions 5.1, instruction 5, sous-composante 3.3, corps de sous-programme 6.3, appel de sous-programme 6.4, corps de tâche 9.1, objet tâche 9.2, alternative terminate 9.7.1