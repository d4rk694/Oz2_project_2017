
functor
import
	Input
  System
	OS
export
   portPlayer:StartPlayer
define

	fun{GenerateInitialState}
		state(idPlayer:_ lives:_ isAlive:_ currentPosition:_ counterMine:_ counterMissile:_ counterDrone:_ counterSonar: _ path:_ isUnderSurface:_ listMine:_ nbrMinePlaced:_ closestEnemyPos:_)
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
		if (X == 0 orelse X > (Input.nRow +1) orelse Y == 0 orelse Y > (Input.nColumn +1 )) then
			no
		else
			List={GetElementInList Map X}
			Point={GetElementInList List Y}
			case Point of 1 then
				no
			[] 0 then
				yes
			else
				no
			end
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

	fun{GenerateDirection State Map}
		P
 		Direction
		in
		P = State.currentPosition

		%WORK but bloked when he arrive on the possition
		if State.closestEnemyPos \= nil then
			if (State.currentPosition.x >= State.closestEnemyPos.x ) andthen ({CanMoveTo P.x-1 P.y Map} == yes andthen {FindPointInList State.path pt(x:P.x-1 y:P.y)} == no) then
				Direction = north
			elseif (State.currentPosition.y =< State.closestEnemyPos.y ) andthen ({CanMoveTo P.x P.y+1 Map} == yes andthen {FindPointInList State.path pt(x:P.x y:P.y+1)} == no) then
				Direction = east
			elseif (State.currentPosition.x =< State.closestEnemyPos.x ) andthen ({CanMoveTo P.x+1 P.y Map} == yes andthen {FindPointInList State.path pt(x:P.x+1 y:P.y)} == no) then
				Direction = south
			elseif (State.currentPosition.y >= State.closestEnemyPos.y ) andthen ({CanMoveTo P.x P.y-1 Map} == yes andthen {FindPointInList State.path pt(x:P.x y:P.y-1)} == no) then
				Direction = west
			else
				Direction = surface
			end
		else

			if ({CanMoveTo P.x-1 P.y Map} == yes andthen {FindPointInList State.path pt(x:P.x-1 y:P.y)} == no) then
				Direction = north
			elseif ({CanMoveTo P.x P.y+1 Map} == yes andthen {FindPointInList State.path pt(x:P.x y:P.y+1)} == no) then
				Direction = east
			elseif ({CanMoveTo P.x+1 P.y Map} == yes andthen {FindPointInList State.path pt(x:P.x+1 y:P.y)} == no) then
				Direction = south
			elseif ({CanMoveTo P.x P.y-1 Map} == yes andthen {FindPointInList State.path pt(x:P.x y:P.y-1)} == no) then
				Direction = west
			else
				Direction = surface
			end
		end

	 	Direction
	end

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
	fun{StateModification State Value Result} NewState PositionMine in
		NewState = {GenerateInitialState}


		if Value == 'initPath' then
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

		if Value == 'updateLife' then
			NewState.lives = Result
		else
			NewState.lives = State.lives
		end

		if NewState.lives > 0 then
			NewState.isAlive = true
			NewState.idPlayer = State.idPlayer
		else
			NewState.isAlive = false
			NewState.idPlayer = nil
			%{System.showInfo '[DEAD] '#State.idPlayer.name#' at position : '#State.currentPosition.x#'-'#State.currentPosition.y}

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
				NewState.counterDrone = State.counterDrone+1
			else
				NewState.counterDrone = State.counterDrone
			end

			if Result == sonar then
				NewState.counterSonar = State.counterSonar+1
			else
				NewState.counterSonar = State.counterSonar
			end
		else
			if Value == 'removeItem' then
				if Result == mine then
					NewState.counterMine = State.counterMine-Input.mine
				else
					NewState.counterMine = State.counterMine
				end

				if Result == missile then
					NewState.counterMissile = State.counterMissile-Input.missile
				else
					NewState.counterMissile = State.counterMissile
				end

				if Result == drone then
					NewState.counterDrone = State.counterDrone-Input.drone
				else
					NewState.counterDrone = State.counterDrone
				end

				if Result == sonar then
					NewState.counterSonar = State.counterSonar-Input.sonar
				else
					NewState.counterSonar = State.counterSonar
				end
			else
				NewState.counterMine = State.counterMine
				NewState.counterMissile = State.counterMissile
				NewState.counterSonar = State.counterSonar
				NewState.counterDrone = State.counterDrone
			end
		end

		if Value == 'fireMine' then
			NewState.listMine = Result|State.listMine
			NewState.nbrMinePlaced = State.nbrMinePlaced + 1
		else
			if Value == 'blowMine' then
					NewState.nbrMinePlaced = State.nbrMinePlaced - 1
					NewState.listMine = Result
			else
				NewState.nbrMinePlaced = State.nbrMinePlaced
				NewState.listMine = State.listMine
			end
		end

		if Value == 'dive' then
			NewState.isUnderSurface = Result
		else
			NewState.isUnderSurface = State.isUnderSurface
		end

		if Value == 'changeEnemy' then
			NewState.closestEnemyPos = Result
		else
			NewState.closestEnemyPos = State.closestEnemyPos
		end
		NewState
	end

	%TODO change the list when postion sonar in state received
	fun{GenerateItem State} List Value Charged in
		if State.closestEnemyPos \= nil then
			% 50% missile and 25% mine 25% sonar
			List = [missile missile mine sonar]
			Value = {GetRandomElem List 3}
		else
			% 30% sonar, missile, mine and 10% drone
			List = [mine mine mine missile missile missile sonar sonar sonar drone]
			Value = {GetRandomElem List 10}
			%List = [sonar sonar sonar]
			%Value = {GetRandomElem List 3}
		end

		case Value of mine then
				if(State.counterMine+1 >= Input.mine) then Charged = true end
			[] missile then
				if(State.counterMissile+1 >= Input.missile) then Charged = true end
			[] sonar then
				if(State.counterSonar+1 >= Input.sonar) then Charged = true end
			[] drone then
				if(State.counterDrone+1 >= Input.drone) then Charged = true end
			else
			Charged = false
		end

		if {IsDet Charged} == false then
			Charged = false
		end
		info(item:Value isCharged:Charged)
	end

	fun{GetItemReady State} P D in
		if State.closestEnemyPos \= nil then
			D = {DistanceFrom State.closestEnemyPos State.currentPosition}
			if D >= Input.minDistanceMissile andthen D =< Input.maxDistanceMissile andthen State.counterMissile >= Input.missile then
				% Missile can touch the point & it's ready
				info(item:missile val:missile(State.closestEnemyPos) firedOnPos:true)
			elseif (State.counterMine >= Input.mine) then
				%Place a mine if ready
				P={PositionToFire State.currentPosition 0 Input.minDistanceMine Input.maxDistanceMine nil}
				info(item:mine val:mine(P) firedOnPos:false)
			else
				info(item:nil val:nil firedOnPos:false)
			end
		else
			if (State.counterSonar >= Input.sonar) then
				info(item:sonar val:sonar firedOnPos:false)
			elseif(State.counterMissile >= Input.missile) then
				P={PositionToFire State.currentPosition 0 Input.minDistanceMissile Input.maxDistanceMissile nil}
				info(item:missile val:missile(P) firedOnPos:false)
			elseif (State.counterMine >= Input.mine) then
				P={PositionToFire State.currentPosition 0 Input.minDistanceMine Input.maxDistanceMine nil}
				info(item:mine val:mine(P) firedOnPos:false)
			elseif (State.counterDrone >= Input.drone) then
				if ({OS.rand} mod 2) == 1 then
					%row x
					info(item:drone val:drone(row:({OS.rand} mod Input.nRow +1)) firedOnPos:false)
				else
					%column y
					info(item:drone val:drone(column:({OS.rand} mod Input.nColumn +1)) firedOnPos:false)
				end
			else
				info(item:nil val:nil firedOnPos:false)
			end%end check counter
		end%end else 1st if
		%info(item:nil val:nil)
	end
	%TODO distance the closed position of an enemy in state
	fun{PositionToFire CurrentP N Min Max Path} ReturnValue List Direction P in
		List = [north south east west]
		Direction = {GetRandomElem List 4}
		P = {GetNewPosition Direction CurrentP}

		if ({FindPointInList Path P} == yes orelse {CanMoveTo P.x P.y Input.map} == no) then
			ReturnValue = {PositionToFire CurrentP N Min Max Path}
		else
			if N < Min then
				ReturnValue = {PositionToFire P N+1 Max Min P|Path}
			elseif N >= Min andthen N < Max then
				if ({OS.rand} mod 2) == 1 then
					ReturnValue = P
				else
					ReturnValue = {PositionToFire P N+1 Max Min P|Path}
				end
			else
					ReturnValue = P
			end
		end

		ReturnValue
	end%fun

	proc{PrintPath L}
		case L
			of nil then
				skip
			[] H|T then
			{System.showInfo '[DEBUG] Path : pt(x:'#H.x#' y:'#H.y#')'}
		end
		skip
	end

	fun{RemoveElementFrom L E}
		case L
		of nil then
		 	nil
		[] H|T then
			if H == E then
				T
			else
			H|{RemoveElementFrom T E}
			end
		end
	end


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
				State.idPlayer = id(id:ID color:Color name:'Player'#ID#'-IA')
				State.lives = Input.maxDamage
        {TreatStream Stream  State}
        end
        Port
end %fun

%TODO
	proc{TreatStream Stream State} % has as many parameters as you want
	    case Stream

	    of nil then skip

	    [] initPosition(?ID ?Position)|T then NewState in
				%{System.showInfo 'initPosition'}
				ID = State.idPlayer
				State.currentPosition = {InitPos Input.map}
				State.counterMine = 0
				State.counterDrone = 0
				State.counterSonar = 0
				State.counterMissile = 0
				State.isUnderSurface = false
				Position = State.currentPosition
				State.listMine = nil|nil
				State.nbrMinePlaced = 1
				State.closestEnemyPos = nil
				NewState = {StateModification State 'initPath' Position}

		    {TreatStream T NewState}

			[]move(?ID ?Position ?Direction)|T then NewState Pos in
				%{System.showInfo 'move()'}
				ID = State.idPlayer
				Direction = {GenerateDirection State Input.map}
				Pos = {GetNewPosition Direction State.currentPosition}
				if Direction == surface then
					NewState = {StateModification State 'initPath' Pos}
				else
					NewState = {StateModification State 'position' Pos}
				end
				Position = NewState.currentPosition
				{TreatStream T NewState}

			[] dive|T then NewState in
			%	{System.showInfo 'dive()'}
				Dive = true
				NewState = {StateModification State 'dive' true}
				{TreatStream T NewState}

			[] chargeItem(?ID ?KindItem)|T then NewItemTuple NewState in
				%{System.showInfo 'chargeItem()'}
				ID = State.idPlayer
				NewItemTuple = {GenerateItem State}
				NewState = {StateModification State 'chargeItem' NewItemTuple.item}
				if(NewItemTuple.isCharged) then
						KindItem = NewItemTuple.item
				end
				%{System.showInfo '   | Charged :  Mine : '#NewState.counterMine#'  Missile : '#NewState.counterMissile#'  Drone : '#NewState.counterDrone#' Sonar'#NewState.counterSonar}
				{TreatStream T NewState}

			[] fireItem(?ID ?FireItem)|T then ItemReady NewState NewState2 NewState3 Position in
				%{System.showInfo 'fireItem()'}
				ID = State.idPlayer
				ItemReady = {GetItemReady State}
				if ItemReady.val \= nil then
					FireItem = ItemReady.val
				end
				if ItemReady.item == mine then
					NewState2 = {StateModification State 'fireMine' ItemReady.val}
				else
					NewState2 = {StateModification State nil nil}
				end
				NewState = {StateModification NewState2 'removeItem' ItemReady.item}
				if ItemReady.firedOnPos then
					NewState3 = {StateModification NewState2 'changeEnemy' nil}
				else
					NewState3 = {StateModification NewState2 nil nil}
				end

				{TreatStream T NewState3}

			[]fireMine(?ID ?Mine)|T then NewState CurrentM L in
				%{System.showInfo 'fireMine()'}
				CurrentM = {GetRandomElem State.listMine State.nbrMinePlaced}
				ID = State.idPlayer
				if CurrentM \= nil then
					L = {RemoveElementFrom State.listMine CurrentM}
					NewState = {StateModification State 'blowMine' L}
					Mine = CurrentM
				else
					NewState = {StateModification State nil nil}
				end
				{TreatStream T NewState}

			[]isSurface(?ID ?Answer)|T then NewState in
				ID = State.idPlayer
				Answer = State.underSurface
				{TreatStream T State}

			[]sayMove(ID Direction)|T then NewState in
				if ID \= nil andthen State.idPlayer \= nil then
					{System.showInfo '[RADIO#'#State.idPlayer.id#'] '#ID.name#' has moved to '#Direction}
				end
				{TreatStream T State}

			[]saySurface(ID)|T then NewState in
				if ID \= nil andthen State.idPlayer \= nil then
					{System.showInfo '[RADIO#'#State.idPlayer.id#'] '#ID.name#' has made surface'}
				end
				{TreatStream T State}

			[]sayCharge(ID KindItem)|T then NewState in
				if ID \= nil andthen State.idPlayer \= nil then
					{System.showInfo '[RADIO#'#State.idPlayer.id#'] '#ID.name#' has Charged a '#KindItem}
				end
				{TreatStream T State}

			[]sayMinePlaced(ID)|T then NewState in
				if ID \= nil andthen State.idPlayer \= nil then
					{System.showInfo '[RADIO#'#State.idPlayer.id#'] '#ID.name#' has planted a mine'}
				end
				{TreatStream T State}

				%TODO Check correct
			[]sayMissileExplode(ID Position ?Message)|T then NewState Distance Damage LifeLeft in
				if ID \= nil andthen State.idPlayer \= nil then
					{System.showInfo '[RADIO#'#State.idPlayer.id#'] '#ID.name#' launched a missile at the coordonate '#Position.x#'-'#Position.y}
				end
				Distance = {DistanceFrom Position State.currentPosition}
				if Distance == 0 then
					Damage = 2
				elseif Distance == 1 then
					Damage = 1
				else
					Damage = 0
				end
				LifeLeft = (State.lives - Damage)
				if LifeLeft > 0 then
					Message = sayDamageTaken(State.idPlayer Damage LifeLeft)
				else %submarine Destroyed
					Message = sayDeath(State.idPlayer)
				end
				NewState = {StateModification State updateLife LifeLeft}
				{TreatStream T NewState}

			[]sayMineExplode(ID Position ?Message)|T then NewState Distance Damage LifeLeft in
				if ID \= nil andthen State.idPlayer \= nil then
					{System.showInfo '[RADIO#'#State.idPlayer.id#'] '#ID.name#' blow a mine at the coordonate '#Position.x#'-'#Position.y}
				end
				Distance = {DistanceFrom Position State.currentPosition}
				if Distance == 0 then
					Damage = 2
				elseif Distance == 1 then
					Damage = 1
				else
					Damage = 0
				end
				LifeLeft = (State.lives - Damage)
				if LifeLeft > 0 then
					Message = sayDamageTaken(State.idPlayer Damage LifeLeft)
				else %submarine Destroyed
					Message = sayDeath(State.idPlayer)
				end
				NewState = {StateModification State updateLife LifeLeft}
				{TreatStream T NewState}

			[]sayPassingDrone(Drone ?ID ?Answer)|T then NewState in

				ID = State.idPlayer
				case Drone
				of drone(row:X) then
					if X == State.currentPosition.x then
						Answer = true
					else
						Answer = false
					end
				[] drone(column:Y) then
					if Y == State.currentPosition.y then
						Answer = true
					else
						Answer = false
					end
				else
					Answer = false
				end
				{TreatStream T State}

			[]sayAnswerDrone(Drone ID Answer)|T then NewState in
				if ID \= nil andthen State.idPlayer \= nil then
					if Answer then
						case Drone
						of drone(row:X) then
							{System.showInfo '[RADIO] '#ID.name#' is on the row '#X}
						[] drone(column:Y) then
							{System.showInfo '[RADIO] '#ID.name#' is on the column '#Y}
						else
							{System.showInfo 'Problem Drone'}
						end
					else
						{System.showInfo '[RADIO] '#ID.name#' isn\'t on the range of the drone'}
					end
				end

				{TreatStream T State}

				%TODO

			[]sayPassingSonar(?ID ?Answer)|T then NewState P in
				if ({OS.rand } mod 2)  == 0 then
					%X correct
					P = pt(x:_ y:_)
					P.x = State.currentPosition.x
					P.y= ({OS.rand} mod Input.nColumn)+1
				else
					%Y correct
					P = pt(x:_ y:_)
					P.y = State.currentPosition.y
					P.x= ({OS.rand} mod Input.nRow)+1
				end
				ID = State.idPlayer
				Answer = P
				{TreatStream T State}

			[]sayAnswerSonar(ID Answer)|T then NewState in
				if ID \= nil andthen State.idPlayer \= nil then
					{System.showInfo '[RADIO#'#State.idPlayer.id#'] '#ID.name #' has been detected at position '#Answer.x #'-'#Answer.y#' by the sonar'}

					NewState = {StateModification State changeEnemy Answer}
				end
				{TreatStream T NewState}


			[]sayDeath(ID)|T then NewState in
				if ID \= nil andthen State.idPlayer \= nil then
					{System.showInfo '[RADIO#'#State.idPlayer.id#'] '#ID.name#' is dead'}
				end
				{TreatStream T State}

			[]sayDamageTaken(ID Damage LifeLeft)|T then NewState in
				if ID \= nil andthen State.idPlayer \= nil then
					{System.showInfo '[RADIO#'#State.idPlayer.id#'] '#ID.name#' has taken ' #Damage#' damage(s) [LIFELEFT = '#LifeLeft#']'}
				end
				{TreatStream T State}

			[] _|T then NewState in
				NewState = {StateModification State nil nil}
	    	{TreatStream T NewState}
		end %case
	end %proc
end
