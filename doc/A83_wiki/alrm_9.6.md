### 9.6 **Instruction delay, durée, temps**

1. L'exécution d'une instruction delay évalue l'expression simple et suspend la progression de la tâche qui exécute l'instruction delay, pour au moins la durée spécifiée par la valeur résultante.

2. <pre> delay_statement ::= <b>delay</b> simple_expression;
</pre>

3. L'expression simple doit être du type virgule fixe prédéfini DURATION; sa valeur est exprimée en secondes; une instruction delay avec une valeur négative est équivalente à une instruction delay avec valeur nulle.

4. Toute réalisation du type DURATION doit permettre la représentation de durées (positives ou négatives) au moins jusqu'à 86400 secondes (une journée); la durée représentable la plus petite, DURATION'SMALL, ne doit pas dépasser 20 millisecondes (à chaque fois que possible, une valeur n'excédant pas 50 microsecondes devrait être choisie). Notez que DURATION'SMALL ne correspond pas nécessairement au cycle horloge de base, le nombre nommé SYSTEM.TICK (voir 13.7).

5. La définition du type TIME est fournie dans le paquetage de librairie standard CALENDAR. La fonction CLOCK retourne la valeur courante de TIME au moment où elle est appelée. Les fonctions YEAR, MONTH, DAY, et SECONDS retournent les valeurs correspondantes pour une valeur donnée de type TIME. La procedure SPLIT retourne les quatre valeurs correspondantes. Inversement, la fonction TIME_OF combine un nombre d'années, un nombre de jours, et une durée, dans une valeur de type TIME. Les opérateurs "+" et "-" pour l'addition et la soustraction des temps et des durées et les opérateurs relationnels pour les temps, ont la signification usuelle.

6. L'exception TIME_ERROR est levée par la fonction TIME_OF si les paramètres effectifs ne forment pas une date convenable. Cette exception est également levée par les opérateurs "+" et "-" si, pour les opérandes donnés, ces opérateurs ne peuvent retourner une date dont le nombre d'années soit dans l'étendue du sous type correspondant, ou si l'opérateur "-" ne peut retourner un résultat qui soit dans l'étendue du type DURATION.

7. <pre>
<b>package</b> CALENDAR <b>is</b><br>
      <b>type</b> TIME <b>is private</b>;<br>
      <b>subtype</b> YEAR_NUMBER   <b>is</b> INTEGER <b>range</b> 1901..2099;
      <b>subtype</b> MONTH_NUMBER  <b>is</b> INTEGER <b>range</b> 1..12;
      <b>subtype</b> DAY_NUMBER    <b>is</b> INTEGER <b>range</b> 1..31;<br>
      <b>subtype</b> DAY_DURATION  <b>is</b> DURATION <b>range</b> 0.0 .. 86_400.0;<br>
      <b>function</b>  CLOCK <b>return</b> TIME;<br>
      <b>function</b>  YEAR    ( DATE : TIME )  <b>return</b> YEAR_NUMBER;
      <b>function</b>  MONTH   ( DATE : TIME )  <b>return</b> MONTH_NUMBER;
      <b>function</b>  DAY     ( DATE : TIME )  <b>return</b> DAY_NUMBER;
      <b>function</b>  SECONDS ( DATE : TIME )  <b>return</b> DAY_DURATION;<br>
      <b>procedure</b> SPLIT   ( DATE    : TIME;
                          YEAR    : <b>out</b> YEAR_NUMBER;
                          MONTH   : <b>out</b> MONTH_NUMBER;
                          DAY     : <b>out</b> DAY_NUMBER;
                          SECONDS : <b>out</b> DAY_DURATION );<br>
      <b>function</b>  TIME_OF ( YEAR    : YEAR_NUMBER;
                          MONTH   : MONTH_NUMBER;
                          DAY     : DAY_NUMBER;
                          SECONDS : DAY_DURATION := 0.0 ) <b>return</b> TIME;<br>
      <b>function</b>  "+"   ( LEFT : TIME;     RIGHT : DURATION )  <b>return</b> TIME;
      <b>function</b>  "+"   ( LEFT : DURATION; RIGHT : TIME )      <b>return</b> TIME;
      <b>function</b>  "-"   ( LEFT : TIME;     RIGHT : DURATION )  <b>return</b> TIME;
      <b>function</b>  "-"   ( LEFT : TIME;     RIGHT : TIME )      <b>return</b> DURATION;<br>
      <b>function</b>  "<<b></b>"   ( LEFT, RIGHT : TIME )  <b>return</b> BOOLEAN;
      <b>function</b>  "<="  ( LEFT, RIGHT : TIME )  <b>return</b> BOOLEAN;
      <b>function</b>  ">"   ( LEFT, RIGHT : TIME )  <b>return</b> BOOLEAN;
      <b>function</b>  ">="  ( LEFT, RIGHT : TIME )  <b>return</b> BOOLEAN;<br>
      TIME_ERROR  : <b>exception</b>;<br>
<b>private</b><br>
--  dépendant de la réalisation<br>
<b>end</b>;
</pre>

8. <pre>
<b>delay</b> 3.0;  -- delai de 3 secondes <br>
<b>declare</b>
      <b>use</b> CALENDAR;
-- INTERVAL est une constante globale de type DURATION
      NEXT_TIME : TIME := CLOCK + INTERVAL;
<b>begin</b>
      <b>loop</b>
        <b>delay</b> NEXT_TIME - CLOCK;
-- actions
        NEXT_TIME := NEXT_TIME + INTERVAL;
      <b>end loop</b>;
<b>end</b>;
</pre>

9. Le second exemple provoque la répétition de la boucle tous les INTERVAL secondes en moyenne.Cet intervalle entre deux itérations n'est qu'approché. Cependant, il n'y aura pas de dérive cumulative tant que la durée de chaque itération sera (sufisamment) inférieure à INTERVAL.

10. _Références_: opérateur addition 4.5, duration C, type virgule fixe 3.5.9, appel de fonction 6.4, unité de librairie 10.1, opérateur 4.5, paquetage 7, type privé 7.4, opérateur relationnel 4.5, expression simple 4.4, instruction 5, tâche 9, type 3.3