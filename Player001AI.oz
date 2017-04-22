
functor
import
	Input
  System
	OS
export
   portPlayer:StartPlayer
define

	%Get a random element From Result, where N is Max index to choose
	fun{GetRandomElem Result N} I in
		I = ({OS.rand} mod N) + 1
		{GetElementInList Result I}
	end
	%Get the I th element of L
	fun{GetElementInList L I}
		case L of H|T then
    	if I == 1 then
    		H
      else
	      {GetElementInList T I-1}
      end
		[] nil then
			nil
   	end
	end

%TODO Check Island
	fun{GenerateDirection CurrentPosition}
 		Move
 		Direction
		ListDirection
		in
		ListDirection = [north south east west surface]
		Move = {GetRandomElem ListDirection 5}

		case Move of north then
			if(CurrentPosition.x-1 == 0  ) then
				Direction = {GenerateDirection CurrentPosition}
			else
				Direction = north
			end
		[] surface then
			 Direction = surface
	 [] east then
			if(CurrentPosition.y+1 == (Input.nColumn)+1) then
				Direction = {GenerateDirection CurrentPosition}
			else
				Direction = east
			end
	 [] south then
			if(CurrentPosition.x+1 == (Input.nRow)+1) then
				Direction =  {GenerateDirection CurrentPosition}
			else
				Direction = south
			end
	 [] west then
			if(CurrentPosition.y-1 == 0) then
				Direction = {GenerateDirection CurrentPosition}
			else
				Direction = west
			end %else

	 end %case
	 Direction
	end %fun

	%TODO
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
		[] surface then
		Position = CurrentPosition
		end %case
		Position
	end %fun

	%Create a new state based on the previous one
	%Param Value = the attribute to update with the value of Result
	fun{StateModification State Value Result} NewState in
		NewState = state(idPlayer:State.idPlayer currentPosition:_ counterMine:_ counterMissile:_ couterDrone:_ counterSonar:_)

		if Value == 'position' then
			NewState.currentPosition = Result
		else
			NewState.currentPosition = State.currentPosition
		end

		if Value == 'chargeItem' then
			if Result == mine then
				NewState.counterMine = State.counterMine+1
			else
				NewState.counterMine = State.counterMine
			end

			if Result == missile then
				NewState.counterMissile = State.counterMissile+1
			else
				NewState.counterMissile = State.counterMissile
			end

			if Result == drone then
				NewState.couterDrone = State.couterDrone+1
			else
				NewState.couterDrone = State.couterDrone
			end
			if Result == sonar then
				NewState.counterSonar = State.counterSonar+1
			else
				NewState.counterSonar = State.counterSonar
			end
		else
			NewState.counterMine = State.counterMine
			NewState.counterMissile = State.counterMissile
			NewState.counterSonar = State.counterSonar
			NewState.counterDrone = State.counterDrone
		end
		NewState
	end

	%TODO
	fun{GenerateItem} List Value in
		List = [mine missile sonar drone]
		Value = {GetRandomElem List 4}
		Value
	end

	%TODO
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

	%TODO
	fun{GetItemReady State}
		nil
	end

	%TODO
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

	fun{DistanceFrom P1 P2}
		{Abs P1.x - P2.x} + {Abs P1.y - P2.y}
	end

	StartPlayer
  TreatStream
	Dive

in

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

%TODO
	proc{TreatStream Stream State} % has as many parameters as you want
	    case Stream

	    of nil then skip

	    [] initPosition(?ID ?Position)|T then NewState in
				ID = State.idPlayer
				State.currentPosition = pt(x:({OS.rand}mod 10)+1 y:({OS.rand}mod 10)+1)
				Position = State.currentPosition
		    {TreatStream T State}

			[]move(?ID ?Position ?Direction)|T then NewState Pos in
				ID = State.idPlayer
				Direction = {GenerateDirection State.currentPosition}
				Pos = {GetNewPosition Direction State.currentPosition}
				NewState = {StateModification State position Pos}
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
				%		{TreatStream T NewState}

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
