### 9.3 **Exécution de tâche - activation de tâche**

1. Un corps de tâche définit l'exécution de toute tâche désignée par un objet du type tâche correspondant. La partie initiale de cette exécution est appelée _activation_ de l'objet tâche, et celle aussi de la tâche désignée; cela consiste en l'élaboration de la partie déclarative, si elle existe, du corps de tâche. l'exécution de différentes tâches, en particulier leur activation, procède en parallèle.

2. Si une déclaration d'objet qui déclare un objet tâche est présente immédiatement dans une partie déclarative, alors l'activation de l'objet tâche commence après l'élaboration de la partie déclarative (c'est à dire après passage du mot clé __begin__ suivant la partie déclarative); de même si une telle déclaration est présente dans une spécification de paquetage, l'activation démarre après l'élaboration de la partie déclarative du corps de paquetage. Pareillement pour l'activation d'un objet tâche qui est une sous-composante d'un objet déclaré immédiatement dans une partie déclarative ou une spécification de paquetage. La première instruction suivant la partie déclarative n'est exécutée qu'après conclusion de l'activation de ces objets tâches.

3. Dans l'éventualité d'une exception levée par l'activation de l'une de ces tâches, la dite tâche devient achevée (voir 9.4); les autres tâches ne sont pas directement affectées. Si donc l'une de ces tâches s'achève durant son activation, l'exception TASKING_ERROR est levée à la conclusion de l'activation de toutes ces tâches (qu'elle réussisse ou non); l'exception est levée au lieu qui est immédiatement avant la première instruction suivant la partie déclarative (immédiatement après le mot réservé __begin__). Dans le cas où plusieurs tâches s'achèveraient durant leur activation, l'exception TASKING_ERROR n'est levée qu'une seule fois.

4. Si une exception est levée par l'élaboration de la partie déclarative ou de la spécification de paquetage, alors toute tâche créée (directement ou indirectement) par cette élaboration et qui n'est pas encore activée devient terminée et n'est donc jamais activée (voir la section 9.4 pour la définition d'une tâche terminée).

5. Pour les règles ci-dessus, dans tout corps de paquetage sans instruction, une instruction null est supposée présente. Pour tout paquetage sans corps, un corps implicite contenant une seule instruction null est supposé présent. Si un paquetage sans corps est déclaré immédiatement dans une unité de programme ou une instruction block, le corps de paquetage implicite est situé à la fin de la partie déclarative de l'unité de programme ou du bloc; s'il y a plusieurs paquetages dans ce cas, l'ordre des corps implicites n'est pas défini.

6. Un objet tâche qui est l'objet, ou la sous-composante d'un objet, créé par évaluation d'un allocateur est activé par cette évaluation.  L'activation débute après toute initialisation pour l'objet créé par l'allocateur; si plusieurs sous-composantes sont des objets tâches, ils sont activés en parallèle. La valeur accès désignant un tel objet est retournée par l'allocateur seulement après la conclusion de ces activations.

7. Dans l'éventualité d'une exception levée par l'activation de l'une de ces tâches, la dite tâche devient achevée; les autres tâches ne sont pas directement affectées. Si donc l'une de ces tâches s'achève durant son activation, l'exception TASKING_ERROR est levée à la conclusion de l'activation de toutes ces tâches (qu'elle réussisse ou non); l'exception est levée au lieu où l'allocateur est évalué. Dans le cas où plusieurs tâches s'achèveraient durant leur activation, l'exception TASKING_ERROR n'est levée qu'une seule fois.

8. Si une exception est levée par l'initialisation de l'objet créé par un allocateur (donc avant le début de l'activation), toute tâche désignée par une sous-composante  de cet objet devient terminée et n'est donc jamais activée.

9. _Exemple:_
<pre>
<b>procedure</b> P <b>is</b>
      A, B : RESOURCE;  -- élabore les objets tâches A et B
      C    : RESOURCE;  -- élabore l'objet tâche C
<b>begin</b>
  --  les tâches A, B, C sont activées en parallèle avant la première intruction
<b>end</b>;
</pre>
_Notes:_
10. Une entrée de tâche peut être appelée avant que la tâche soit activée. Si plusieurs tâches sont activées en parallèle, l'exécution de n'importe laquelle de ces tâches n'est pas obligée d'attendre la fin de l'activation des autres tâches. Une tâche peut s'achever durant son activation soit à cause d'une exception, soit parce qu'elle est avortée (voir 9.10).

11. _Références:_ allocator 4.8, tâche achevée 9.4, partie déclarative 3.9, élaboration 3.9, entrée 9.5, exception 11, traitement d'une exception 11.4, corps de paquetage 7.1, exécution parallèle 9, instruction 5, sous-composante 3.3, corps de tâche 9.1, objet tâche 9.2, mise à terme de tâche 9.4, type tâche 9.1, exception tasking_error 11.1