Oz Project
==========

Type
----
\<id\> ::= null | id(id:\<idNum\> color:\<color\>) name:Name)
\<idNum\> ::= 1 | 2 | ... | Input.nbPlayer
\<color\> ::= red | blue | green | yellow | white | black
| c(\<colorNum\> \<colorNum\> \<colorNum\>)
\<colorNum\> ::= 0 | 1 | ... | 255
\<position\> ::= pt(x:\<row\> y:\<column\>)
\<row\> ::= 1 | 2 | ... | Input.nRow
\<column\> ::= 1 | 2 | ... | Input.nColumn
\<carddirection\> ::= east | north | south | west
\<direction\> ::= \<carddirection\> | surface
\<item\> ::= null | mine | missile | sonar | drone
\<fireitem\> ::= null | mine(\<position\>) | missile(\<position\>) | \<drone\> | sonar
\<drone\> ::= drone(row \<x\>) | drone(column \<y\>)
\<mine\> ::= null | \<position\>
