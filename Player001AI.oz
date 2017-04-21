
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
	Dive
in
  fun{StartPlayer Color ID}
  Stream
	Port
	in
        {NewPort Stream Port}
        thread
        {TreatStream Stream Color ID nil}
        end
        Port
end

proc{TreatStream Stream Color IDnum CurrentPosition} % has as many parameters as you want
    case Stream

    of nil then skip

    [] initPosition(?ID ?Position)|T then
		ID = id(id:IDnum color:Color name:'Player001')
    %Position = pt(x:({OS.rand}mod 10)+1 y:({OS.rand}mod 10)+1)
		Position = pt(x:({OS.rand}mod 10)+1 y:({OS.rand}mod 10)+1)
    {TreatStream T Color ID Position}

		[]move(?ID ?Position ?Direction)|T then
		ID = IDnum
		Position = pt(x:CurrentPosition.x+1 y:CurrentPosition.y)
		Direction = east
		{TreatStream T Color ID Position}

		[] dive|T then
		{System.showInfo 'JE DIVE OKLM'}
		{TreatStream T Color IDnum CurrentPosition}

		[] _|T then
    {TreatStream T Color IDnum CurrentPosition}
		end
end


end
