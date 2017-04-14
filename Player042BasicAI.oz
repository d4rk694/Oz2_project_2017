functor
import
  Input
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
      {TreatStream Stream <p1> <p2> ...}
    end
    Port
  end

  proc{TreatStream Stream <p1> <p2> ...} % has as many parameters as you want
    %Stream = list? (port object = same as list?)
    %why multiple param?
    case H|T of Stream then
      case initPosition(ID Position) of H then
        %bind ID
        %select the position (If IA it's hardcoded) %check if the position is water
      [] move(ID Position Direction) then
        %bind ID
        %bind the new Position
        %bind the Direction from the old one
      [] dive() then
        %the player can dive again
      [] chargeItem(ID KindItem) then
        %bind ID
        %increase by 1 one of it's item.
          %if the number of load is reached => bind KindItem (see instruction.pdf)
      [] ... then
      %do the same for all type of message
      else
        skip
      end

    {TreatStream T <p1> <p2> ...}
    end
    ...
  end
end
