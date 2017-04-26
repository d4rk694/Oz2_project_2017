
functor
import
	Input
  System
	OS
export
   portPlayer:StartPlayer
define

	fun{GenerateInitialState}
		state(idPlayer:_ currentPosition:_ counterMine:0 counterMissile:0 counterDrone:0 counterSonar: 0 path:_ underSurface:false)
	end
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

	fun{FindPointInList L I}
			case L of nil then
 				no
			[] H|T then
				if I == H then
					yes
				else
					{FindPointInList T I}
				end
		 	end
	end

	fun{CanMoveTo X Y Map} List Point in
		List={GetElementInList Map X}
		Point={GetElementInList List Y}
		case Point of 1 then
			no
		[] 0 then
			yes
		end
	end

	fun{InitPos Map} P Value in
		P = pt(x:({OS.rand}mod 10)+1 y:({OS.rand}mod 10)+1)
		if({CanMoveTo P.x P.y Map} == no) then
			Value = {InitPos Map}
		else
			Value = P
		end

		Value
	end

	%TODO Check Path
	fun{GenerateDirection State Map}
		P
 		Move
 		Direction
		ListDirection
		in
		%Big list to have only 11% chance to go on the surface
		ListDirection = [north south east west surface north south east west north south east west north south east west surface]
		Move = {GetRandomElem ListDirection 18}
		{System.showInfo '  |   GenerateDirection '#State.idPlayer.name}
		case Move of north then
			P = pt(x:State.currentPosition.x-1 y:State.currentPosition.y)
				if (P.x == 0 orelse {CanMoveTo P.x P.y Map} == no orelse {FindPointInList State.path P} == yes) then
					Direction = {GenerateDirection State Map}
				else
				Direction = north
			end
		[] surface then
			 Direction = surface
 	 	[] east then
	 		P = pt(x:State.currentPosition.x y:State.currentPosition.y+1)
			if(P.y == (Input.nColumn)+1 orelse {CanMoveTo P.x P.y Map} == no orelse {FindPointInList State.path P} == yes) then
				Direction = {GenerateDirection State Map}
			else
				Direction = east
			end
		[] south then
	 		P = pt(x:State.currentPosition.x+1 y:State.currentPosition.y)
			if(P.x == (Input.nRow)+1 orelse {CanMoveTo P.x P.y Map} == no orelse {FindPointInList State.path P} == yes) then
				Direction = {GenerateDirection State Map}
			else
				Direction = south
			end
		[] west then
	 		P = pt(x:State.currentPosition.x y:State.currentPosition.y-1)
			if(P.y == 0 orelse {CanMoveTo P.x P.y Map} == no orelse {FindPointInList State.path P} == yes) then
				Direction = {GenerateDirection State Map}
			else
				Direction = west
			end %else
	 end %case
	 Direction
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
		[] surface then
		Position = CurrentPosition
		end %case
		Position
	end %fun

	%Create a new state based on the previous one
	%Param Value = the attribute to update with the value of Result
	fun{StateModification State Value Result} NewState in
		NewState = {GenerateInitialState}

		NewState.idPlayer = State.idPlayer

		if Value == 'initPath' then
			{System.showInfo 'initPath'}
			NewState.currentPosition = Result
			NewState.path = Result|nil
		else
			if Value == 'position' then
				NewState.currentPosition = Result
				NewState.path = Result|State.path
			else
				NewState.currentPosition = State.currentPosition
				NewState.path = State.path
			end
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

		if Result == dive then
			NewState.underSurface = Result
		else
			NewState.underSurface = State.underSurface
		end
		NewState
	end

	%TODO test with value +1
	fun{GenerateItem State} List Value Charged in
		List = [mine missile sonar drone]
		Value = {GetRandomElem List 4}

		case Value of mine then
				if(State.counterMine == Input.mine) then Charged = true end
			[] missile then
				if(State.counterMissile == Input.missile) then Charged = true end
			[] sonar then
				if(State.counterSonar == Input.sonar) then Charged = true end
			[] drone then
				if(State.counterDrone == Input.drone) then Charged = true end
		end

		if Charged == nil then Charged = false end

		tuple(item:Value isCharged:Charged)
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
				State = {GenerateInitialState}
				State.idPlayer = id(id:ID color:Color name:'Player'#ID)
        {TreatStream Stream  State}
        end
        Port
end %fun

%TODO
	proc{TreatStream Stream State} % has as many parameters as you want
	    case Stream

	    of nil then skip

	    [] initPosition(?ID ?Position)|T then NewState in
				{System.showInfo 'initPosition'}
				ID = State.idPlayer
				State.currentPosition = {InitPos Input.map}
				Position = State.currentPosition
				NewState = {StateModification State initPath Position}

		    {TreatStream T NewState}

			[]move(?ID ?Position ?Direction)|T then NewState Pos in
				{System.showInfo 'move'}

				ID = State.idPlayer
				Direction = {GenerateDirection State Input.map}
				Pos = {GetNewPosition Direction State.currentPosition}
				if Direction == surface then
					NewState = {StateModification State initPath Pos}
				else
					NewState = {StateModification State position Pos}
				end
				Position = NewState.currentPosition
				{TreatStream T NewState}

			%TODO dive in state
			[] dive|T then NewState in
				{System.showInfo 'dive'}
				Dive = true
				NewState = {StateModification State dive true}
				{TreatStream T NewState}

			%TODO update the state.item
			[] chargeItem(?ID ?KindItem)|T then NewItem NewState in
				/*ID = State.idPlayer
				NewItem = {GenerateItem State}
				NewState = {StateModification State 'chargeItem' NewItem.item}

				if(NewItem.isCharged) then
					KindItem = NewItem.item
				end*/
				NewState = {StateModification State nil nil}
				{TreatStream T NewState}

			[]fireItem(?ID ?KindItem)|T then ItemReady NewState Position in
				/*ID = State.idPlayer
				ItemReady = {GetItemReady State} %Méthode à créer !
				if ItemReady == nil then
					%ne rien faire
				else
					NewState = {StateModification State 'fireItem' ItemReady}
					KindItem = {PositionToFire ItemReady State.currentPosition}
				end
				KindItem=mine(pt:(x:1 y:1))*/
				NewState = {StateModification State nil nil}
				{TreatStream T NewState}

			[]fireMine(?ID ?Mine)|T then NewState in
				NewState = {StateModification State nil nil}
				{TreatStream T NewState}

			[]isSurface(?ID ?Answer)|T then NewState in
				NewState = {StateModification State nil nil}
				{TreatStream T NewState}

			[]sayMove(ID Direction)|T then NewState in
				NewState = {StateModification State nil nil}
				{TreatStream T NewState}

			[]saySurface(ID)|T then NewState in
				NewState = {StateModification State nil nil}
				{TreatStream T NewState}

			[]sayCharge(ID KindItem)|T then NewState in
				NewState = {StateModification State nil nil}
				{TreatStream T NewState}

			[]sayMinePlaced(ID)|T then NewState in
				NewState = {StateModification State nil nil}
				{TreatStream T NewState}

			[]sayMissileExplode(ID Position ?Message)|T then NewState in
				NewState = {StateModification State nil nil}
				{TreatStream T NewState}

			[]sayMineExplode(ID Position ?Message)|T then NewState in
				NewState = {StateModification State nil nil}
				{TreatStream T NewState}

			[]sayPassingDrone(Drone ?ID ?Answer)|T then NewState in
				NewState = {StateModification State nil nil}
				{TreatStream T NewState}

			[]sayAnswerDrone(Drone ID Answer)|T then NewState in
				NewState = {StateModification State nil nil}
				{TreatStream T NewState}

			[]sayPassingSonar(?ID ?Answer)|T then NewState in
				NewState = {StateModification State nil nil}
				{TreatStream T NewState}

			[]sayAnswerSonar(ID Answer)|T then NewState in
				NewState = {StateModification State nil nil}
				{TreatStream T NewState}

			[]sayDeath(ID)|T then NewState in
				NewState = {StateModification State nil nil}
				{TreatStream T NewState}

			[]sayDamageTaken(ID Damage LifeLeft)|T then NewState in
				NewState = {StateModification State nil nil}
				{TreatStream T NewState}

			[] _|T then NewState in
				NewState = {StateModification State nil nil}
	    	{TreatStream T NewState}
		end %case
	end %proc
end
