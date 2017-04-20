
functor
import
	Input
  System
	OS
export
   portPlayer:StartPlayer
define
	StartPlayer
  TreatStream
in
  fun{StartPlayer Color ID}
  Stream
	Port
	in
        {NewPort Stream Port}
        thread
        {TreatStream Stream Color ID}
        end
        Port
end

proc{TreatStream Stream Color Idnum } % has as many parameters as you want
    case Stream

    of nil then skip

    [] initPosition(?ID ?Position)|T then
		ID = id(id:Idnum color:Color name:'Player002')
    Position = pt(x:({OS.rand}mod 10)+1 y:({OS.rand}mod 10)+1)
    end
end
end
