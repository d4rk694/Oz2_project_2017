
functor
import
	Input
  System
	OS
export
   portPlayer:StartPlayer
define
	GenerateMove
	GetNewPosition
	StateModification
	GenerateItem
	CheckCounterItemUpdated
	GetItemReady
	PositionToFire

	StartPlayer
  TreatStream
	Dive

in

%Il faut vérifier que la position ne dépasse pas la map, ne dépasse pas la distance max, ne pas sur une île (fais chier)
fun{PositionToFire Item CurrentPosition} ReturnValue Distance Direction in

	Direction = {OS.rand mod 4}

	case Item of mine then
	Distance = ({OS.rand mod Input.maxDistanceMine})+1


	[] missile then
	Distance = ({OS.rand mod Input.maxDistanceMissile})+1


	[] drone then %pas sûr si le type de retour est correct. Est ce qu'il ne manque pas ':' ?
	if (Direction == 0) then %north || south
		ReturnValue = CurrentPosition.x
	end

	if(Direction == 2) then
		ReturnValue = CurrentPosition.x
	end
	ReturnValue = CurrentPosition.y

	[] sonar then
	ReturnValue = sonar

	end%case
	ReturnValue
end%fun

fun{GetItemReady State}
	nil
end

fun{CheckCounterItemUpdated State Item} ReturnValue in
	case Item of mine then
	if(State.counterMine == Input.mine) then ReturnValue = mine end
	[] missile then
	if(State.counterMissile == Input.missile) then ReturnValue = missile end
	[] sonar then
	if(State.counterSonar == Input.sonar) then ReturnValue = sonar end
	[] drone then
	if(State.counterDrone == Input.drone) then ReturnValue = drone end
	end
	ReturnValue
end

fun{GenerateItem} RandomValue ReturnValue in
RandomValue = {OS.rand mod 4}
case randomValue of 0 then
	ReturnValue = mine
	[] 1 then
	ReturnValue = missile
	 [] 2 then
	ReturnValue = sonar
	 [] 3 then
	ReturnValue = drone
	 end%case
	 ReturnValue
end

fun{GenerateMove CurrentPosition}
 Move
 Direction
in
 Move = ({OS.rand} mod 4)
 case Move of 0 then
		if(CurrentPosition.x-1 == 0) then
 			Direction = {GenerateMove CurrentPosition}
		else
 			Direction = north
		end
		Direction
 [] 1 then
		if(CurrentPosition.y+1 == (Input.nColumn)+1) then
 			Direction = {GenerateMove CurrentPosition}
		else
			Direction = east
		end
		Direction
 [] 2 then
		if(CurrentPosition.x+1 == (Input.nRow)+1) then
 			Direction =  {GenerateMove CurrentPosition}
		else
 			Direction = south
		end
		Direction
 [] 3 then
		if(CurrentPosition.y-1 == 0) then
 			Direction = {GenerateMove CurrentPosition}
		else
 			Direction = west
		end %else
		Direction
 end %case
end %fun

fun {GetNewPosition Direction CurrentPosition}
Position
in
	case Direction of north then
	Position = pt(x:CurrentPosition.x-1 y:CurrentPosition.y)
	[] east then
	Position = pt(x:CurrentPosition.x y:CurrentPosition.y+1)
	[] south then
	Position = pt(x:CurrentPosition.x+1 y:CurrentPosition.y)
	[] west then
	Position = pt(x:CurrentPosition.x y:CurrentPosition.y-1)
	end %case
Position
end %fun

fun{StateModification State Value Result} NewState in
%State=state(idPlayer:id(id:ID color:Color name:'Player001') currentPosition:_ counterMine:0 counterMissile:0 couterDrone:0 counterSonar: 0)
	 case Value of 'position' then
	 NewState = state(idPlayer:State.idPlayer currentPosition:Result counterMine:State.counterMine
		 counterMissile:State.counterMissile couterDrone:State.couterDrone counterSonar: State.counterSonar)

		 [] 'chargeItem' then
		 case Result of mine then
		 NewState = state(idPlayer:State.idPlayer currentPosition:Result counterMine:State.counterMine+1
			 counterMissile:State.counterMissile couterDrone:State.couterDrone counterSonar: State.counterSonar)
			 [] missile then
			 NewState = state(idPlayer:State.idPlayer currentPosition:Result counterMine:State.counterMine
				counterMissile:State.counterMissile+1 couterDrone:State.couterDrone counterSonar: State.counterSonar)
				[] drone then
 			 NewState = state(idPlayer:State.idPlayer currentPosition:Result counterMine:State.counterMine
 				counterMissile:State.counterMissile couterDrone:State.couterDrone+1 counterSonar: State.counterSonar)
				[] sonar then
			 NewState = state(idPlayer:State.idPlayer currentPosition:Result counterMine:State.counterMine
				counterMissile:State.counterMissile couterDrone:State.couterDrone counterSonar: State.counterSonar+1)
				end%case

	 end%case
	 NewState
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  fun{StartPlayer Color ID}
  Stream
	Port
	State
	in
        {NewPort Stream Port}
        thread
				State=state(idPlayer:id(id:ID color:Color name:'Player001') currentPosition:_ counterMine:0 counterMissile:0 couterDrone:0 counterSonar: 0)
        {TreatStream Stream  State}
        end
        Port
end %fun

proc{TreatStream Stream State} % has as many parameters as you want
    case Stream

    of nil then skip

    [] initPosition(?ID ?Position)|T then NewState in
		ID = State.idPlayer
		State.currentPosition = pt(x:({OS.rand}mod 10)+1 y:({OS.rand}mod 10)+1)
		Position = State.currentPosition
    {TreatStream T State}

		[]move(?ID ?Position ?Direction)|T then NewState in
		ID = State.idPlayer
		Direction = {GenerateMove State.currentPosition}
		NewState = {StateModification State 'position' {GetNewPosition Direction State.currentPosition}}
		Position = NewState.currentPosition
		{TreatStream T NewState}

		[] dive|T then NewState in
		Dive = true
		{TreatStream T NewState}

		[] chargeItem(?ID ?KindItem)|T then NewItem NewState in
		ID = State.idPlayer
		NewItem = {GenerateItem}
		NewState = {StateModification State 'chargeItem' NewItem}
		KindItem = {CheckCounterItemUpdated State NewItem}
		{TreatStream T NewState}

		[]fireItem(?ID ?KindItem)|T then ItemReady NewState Position in
		ID = State.idPlayer
		ItemReady = {GetItemReady State} %Méthode à créer !
%		if ItemReady == nil then
			%ne rien faire
%		else
%			NewState = {StateModification State 'fireItem' ItemReady}
%			KindItem = {PositionToFire ItemReady State.currentPosition}
%		end
%		KindItem=mine(pt:(x:1 y:1))
		{TreatStream T NewState}

		[]fireMine(?ID ?Mine)|T then NewState in
		{TreatStream T NewState}

		[]isSurface(?ID ?Answer)|T then NewState in
		{TreatStream T NewState}

		[]sayMove(ID Direction)|T then NewState in
		{TreatStream T NewState}

		[]saySurface(ID)|T then NewState in
		{TreatStream T NewState}

		[]sayCharge(ID KindItem)|T then NewState in
		{TreatStream T NewState}

		[]sayMinePlaced(ID)|T then NewState in
		{TreatStream T NewState}

		[]sayMissileExplode(ID Position ?Message)|T then NewState in
		{TreatStream T NewState}

		[]sayMineExplode(ID Position ?Message)|T then NewState in
		{TreatStream T NewState}

		[]sayPassingDrone(Drone ?ID ?Answer)|T then NewState in
		{TreatStream T NewState}

		[]sayAnswerDrone(Drone ID Answer)|T then NewState in
		{TreatStream T NewState}

		[]sayPassingSonar(?ID ?Answer)|T then NewState in
		{TreatStream T NewState}

		[]sayAnswerSonar(ID Answer)|T then NewState in
		{TreatStream T NewState}

		[]sayDeath(ID)|T then NewState in
		{TreatStream T NewState}

		[]sayDamageTaken(ID Damage LifeLeft)|T then NewState in
		{TreatStream T NewState}

		[] _|T then NewState in
    {TreatStream T NewState}
		end %case
end %proc
end
