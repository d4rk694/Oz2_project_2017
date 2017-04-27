functor
import
    GUI
    Input
    PlayerManager

    System
    OS
define
	PortWindow

	Players
  PlayersState
  Round

	fun{GetElementInList L I}
	   case L of H|T then
	      if I == 1 then
		      H
	      else
		      {GetElementInList T I-1}
	      end
	   end
	end

  fun{GenerateInitialState}
    info(turnLeftSurface:_)
  end

  fun{StateModification State Value Result} NewStatePlayer in


    {System.showInfo 'Creating state'}
    NewStatePlayer={GenerateInitialState}

    if Value == turnLeftSurface then
      NewStatePlayer.turnLeftSurface = Result
    else
      NewStatePlayer.turnLeftSurface = State.turnLeftSurface
    end


    NewStatePlayer
  end

  proc{InitPositionPlayers Idnum} ID Position in
      {Send Players.Idnum initPosition(ID Position)}
      {Send PortWindow initPlayer(ID Position)}
  end

  fun{MovePlayers Idnum} ID Position Direction RetVal in
      %{System.showInfo '     Player'#Idnum #' : Moving'}
      {Send Players.Idnum move(ID Position Direction)}
      {Send PortWindow movePlayer(ID Position)}
      if(Direction == surface) then
      %  {System.showInfo '     Player'#Idnum #' : Moved to surface'}
        {Send PortWindow surface(ID)}
        RetVal = true
      else
      %{System.showInfo '     Player'#Idnum #' : Moved to '#Direction}
        RetVal = false
      end
      %TODO broadcast to all players
      RetVal
  end

  %TODO broadcast
  proc{ChargeItem Idnum} ID KindItem in
    %{System.showInfo 'Ask ChargeItem'}
    {Send Players.Idnum chargeItem(?ID ?KindItem)}
    thread
      %TODO broadcast
      {Wait KindItem}
    %  {System.showInfo '###'#KindItem}
    end
    %If KindItem CHarged => broadcast
  end

  %TODO broadcast
  proc{FireItem Idnum} ID FireItem in
      %  {System.showInfo 'Ask FireItem'}
    {Send Players.Idnum fireItem(?ID ?FireItem)}
    %  {System.showInfo 'Asked FireItem!'}

    thread
      %TODO broadcast
      {Wait FireItem}
      case FireItem
      of nil then
       {System.showInfo 'No Item Fired'}
      [] mine(P) then
        {Send PortWindow putMine(ID P)}

      [] missile(P) then
        {System.showInfo '                         MISSILE'}
        {Send PortWindow explosion(ID P)}
        {Delay 2000}
        {Send PortWindow removeMine(ID P)}
        {System.showInfo '                         MISSILE REMOVED'}
      [] sonar then
        {System.showInfo 'Sonar Launche by '#ID.name}
      [] drone(row:X) then
        {System.showInfo 'Drone Launched on row '#X#' by '#ID.name}
      [] drone(column:Y) then
        {System.showInfo 'Drone Launched on column '#Y#' by '#ID.name}
      else
       {System.showInfo 'COucou X'}
      end
      {System.showInfo '### FIRED : MOTHAFUCKER!!!!!!'}
    end
    %If KindItem binded => broadcast
  end

  %TODO broadcast
  proc{BlowMine Idnum} ID Mine in
    {Send Players.Idnum fireMine(?ID ?Mine)}

    thread
      {Wait Mine}
      {System.showInfo 'Mine explosed at position : X:' #Mine.x #' Y:'#Mine.y}
    end
    skip
  end

  proc{StartTurnByTurn State} NewState  in %State foreach player State(1:(Surfaceturn:0 )
    %foreach players
    NewState = {MakeTuple statePlayers Input.nbPlayer}
    for J in 1..Input.nbPlayer do
      local TurnToSurface in
        {Delay Input.thinkMin}
        {System.showInfo 'turn for player '#J}
        %  {MovePlayers J}

        %check if submarine is under the surface
          %if first round or previous rounds the player is at the surface => send Dive

        % 1.
        if State.J.turnLeftSurface == 0 then
    %      {System.showInfo '   Player'#J #' : He can play'}
          % 2.
          {Send Players.J dive}
          % 3. The broadcast (5.) is done in the proc MovePlayers
          if {MovePlayers J} then
            % 4. TODO Change in the state the value of the turnLeftSurface
            %{System.showInfo 'Surface for '#Input.turnSurface #' lap'}
            TurnToSurface=Input.turnSurface - 1
            %We go derectly to 9. by skiping the else statement
          else
            %{System.showInfo '      Player'#J #' : Continue to play after moving'}
            % 6.
            {ChargeItem J}

            % 7.
            {FireItem J}

            % 8.
            {BlowMine J}
            TurnToSurface=State.J.turnLeftSurface
          end
        end

        % 9. Ending turn by decreasing the turnLeftSurface if > 0
        if State.J.turnLeftSurface > 0 then
          %{System.showInfo 'Change State to skip some turn'}
          NewState.J={StateModification State.J turnLeftSurface (State.J.turnLeftSurface - 1)}
      else
          %{System.showInfo 'Create new state'}
          NewState.J={StateModification State.J turnLeftSurface TurnToSurface}
        end

    %    {System.showInfo '   || turnLeftSurface : '# NewState.J.turnLeftSurface}
      end %end local
    end %end foreach player

    {StartTurnByTurn NewState}
  end


in
  Round = 1
	PortWindow = {GUI.portWindow}

	{Send PortWindow buildWindow}

	Players={MakeTuple players Input.nbPlayer}
  PlayersState={MakeTuple statePlayers Input.nbPlayer}
	for I in 1..Input.nbPlayer do
		Players.I={PlayerManager.playerGenerator {GetElementInList Input.players I} {GetElementInList Input.colors I} I}
    PlayersState.I={GenerateInitialState}
    PlayersState.I.turnLeftSurface = 0
  %  {System.showInfo 'TurnSurface for players '# PlayersState.I.turnLeftSurface}
	end

  for I in 1..Input.nbPlayer do
    {InitPositionPlayers I}
  end

  if(Input.isTurnByTurn) then
    {StartTurnByTurn PlayersState}
  else
    {System.showInfo 'simultaneous game not implemented yet!'}
    skip
  end

end
