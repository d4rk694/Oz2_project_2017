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


  proc{InitPositionPlayers Idnum} ID Position in
      {Send Players.Idnum initPosition(ID Position)}
      {Send PortWindow initPlayer(ID Position)}
  end

  fun{MovePlayers Idnum} ID Position Direction RetVal in
      {System.showInfo '     Player'#Idnum #' : Moving'}
      {Send Players.Idnum move(ID Position Direction)}
      {Send PortWindow movePlayer(ID Position)}
      if(Direction == surface) then
        {System.showInfo '     Player'#Idnum #' : Moved to surface'}
        {Send PortWindow surface(ID)}
        RetVal = true
      else
      {System.showInfo '     Player'#Idnum #' : Moved to '#Direction}
        RetVal = false
      end
      RetVal
  end

  %TODO
  proc{ChargeItem Idnum} ID KindItem in
    {Send Players.Idnum chargeItem(?ID ?KindItem)}
    %If KindItem CHarged => broadcast
  end

  %TODO
  proc{FireItem Idnum} ID KindItem in
    {Send Players.Idnum fireItem(?ID ?KindItem)}
    %If KindItem binded => broadcast
  end

  proc{BlowMine Idnum}
    skip
  end

  proc{StartTurnByTurn State} %State foreach player State(1:(Surfaceturn:0 lives:4 map:[[1 1 0 2 ]]) 2:  ... Input.nbPlayers)
    %foreach players
    for J in 1..Input.nbPlayer do
      {Delay Input.thinkMin}
      {System.showInfo 'turn for player '#J}
      %  {MovePlayers J}

      %check if submarine is under the surface
        %if first round or previous rounds the player is at the surface => send Dive

      % 1.
      if State.J.turnLeftSurface == 0 then
        {System.showInfo '   Player'#J #' : He can play'}
        % 2.
        {Send Players.J dive}
        % 3. The broadcast (5.) is done in the proc MovePlayers
        if {MovePlayers J} then
          % 4. TODO Change in the state the value of the turnLeftSurface
          {System.showInfo 'Surface for '#Input.turnSurface #' lap'}


          %We go derectly to 9. by skiping the else statement
        else
        {System.showInfo '      Player'#J #' : Continue to play after moving'}
          % 6.
          {ChargeItem J}

          % 7.
          {FireItem J}

          % 8.
          {BlowMine J}
        end
      end
      % 9. Ending turn by decreasing the turnLeftSurface if > 0
    end %end foreach player
    {StartTurnByTurn State}
  end


in
  Round = 1
	PortWindow = {GUI.portWindow}

	{Send PortWindow buildWindow}

	Players={MakeTuple players Input.nbPlayer}
  PlayersState={MakeTuple statePlayers Input.nbPlayer}
	for I in 1..Input.nbPlayer do
		Players.I={PlayerManager.playerGenerator {GetElementInList Input.players I} {GetElementInList Input.colors I} I}
    PlayersState.I=info(surface:false turnLeftSurface:0)
    {System.showInfo 'TurnSurface for players '# PlayersState.I.turnLeftSurface}
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
