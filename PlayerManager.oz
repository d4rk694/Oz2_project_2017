
functor
import
   Player051Random
   %Player002AI
   %Player005Custom
   %Player053Human
export
   playerGenerator:PlayerGenerator
define
   PlayerGenerator
in
   fun{PlayerGenerator Kind Color ID}
      case Kind
         of random then {Player051Random.portPlayer Color ID}
         %[] player002ai then {Player002AI.portPlayer Color ID}
      end
   end
end
