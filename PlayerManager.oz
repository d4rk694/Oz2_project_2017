
functor
import
   Player001AI
   Player002AI
   %Player005Custom
   %Player053Human
export
   playerGenerator:PlayerGenerator
define
   PlayerGenerator
in
   fun{PlayerGenerator Kind Color ID}
      case Kind
         of basicAI then {Player001AI.portPlayer Color ID}
         [] player002ai then {Player002AI.portPlayer Color ID}
      end
   end
end
