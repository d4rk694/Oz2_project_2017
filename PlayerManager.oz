
functor
import
   Player051Random
   Player051BasicAI
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
         [] basicAi then {Player051BasicAI.portPlayer Color ID}
      end
   end
end
