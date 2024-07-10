### 9.9 **Attributs de tâches et d'entrées** ###

1. Pour un objet tâche ou une valeur T les attributs suivants sont définis:

2. ```T'CALLABLE``` Fournit la valeur faux lorsque l'exécution de la tâche désignée par T est soit achevée, soit terminée, ou quand la tâche est anormale. Fournit la valeur vrai sinon. La valeur de cet attribut est du type prédéfini BOOLEAN.

3. ```T'TERMINATED``` Rend la valeur vrai si la tâche désignée par T est terminée. Rend la valeur faux sinon. La valeur de cet attribut est du type prédéfini BOOLEAN.

4. De plus, les attributs de représentation STORAGE_SIZE, SIZE, et ADDRESS sont définis pour un objet tâche ou un type tâche (voir 13.7.2).

5. L'attribut COUNT est défini pour une entrée E d'une unité tâche T. L'entrée peut être une entrée unique ou une entrée de famille (dans les deux cas le nom de l'entrée unique ou familiale peut être un nom simple ou expansé). Cet attribut n'est permis que dans le corps de T, à l'exclusion de toute unité de programme elle même interne au corps de T.

6. ```E'COUNT``` Fournit le nombre d'appels d'entrée mis en file d'attente sur l'entrée E (si l'attribut est évalué par l'exécution d'une instruction accept pour l'entrée E, le compte n'inclut pas la tâche appelante). La valeur de cet attribut est du type _universal_integer_.

      _Note:_

7. les algorithmes utilisant l'attribut E'COUNT devraient prendre des précautions pour permettre l'augmentation de la valeur de cet attribut lors d'appels entrants, et sa diminution, par exemple avec les appels d'entrée temporisés.

8. _Références:_ tâche anormale 9.10, instruction accept 9.5, attribut 4.1.4, type booléen 3.5.3, tâche achevée 9.4, désigne 9.1, entrée 9.5, valeur booléenne faux 3.5.3, file d'appels d'entrée 9.5, unité de stockage 13.7, tâche 9. objet tâche 9.2, type tâche 9.1, tâche terminée 9.4, appel d'entrée temporisé 9.7.3, valeur booléenne vrai 3.5.3, type universal_integer 3.5.4