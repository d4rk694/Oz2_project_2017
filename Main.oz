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
	Test
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

  proc{MovePlayers Idnum} ID Position Direction in
      {Send Players.Idnum move(ID Position Direction)}
      {System.showInfo Idnum #' moved to '#Direction}
      {Send PortWindow movePlayer(ID Position)}
  end


  proc{StartTurnByTurn State} %State foreach player State(1:(Surfaceturn:0 lives:4) 2:  ... Input.nbPlayers)
  %only for debug
  for I in 1..10 do
    %foreach players
    for J in 1..Input.nbPlayer do
      {Delay 500}
      {System.showInfo 'turn '# I #'for player '#J}
      {MovePlayers J}

      %check if submarine is under the surface
        %if first round or previous rounds the player is at the surface => send Dive

        %Ask direction to move
        %if direction !surface
          %broadcast the direction to everyone

          %charge an item
          %if item totaly charged
            %broadcast the item to everyone

          %Fire an item
          %if it has fired an item
            %broadcast to everyones

          %Blow a mine
          %if the mine has blowned
            %broadcast to everyone
        %else (at surface)
          %broadcast that player is at the surface and stay the number of Input.TurnSurface before playing again

      %else at the surface

    end %end foreach player
  end %end for 1..10

      skip
  end


in
  Round = 1
	PortWindow = {GUI.portWindow}

  {System.showInfo 'Hello world'}

	{Send PortWindow buildWindow}

	Players={MakeTuple players Input.nbPlayer}
	for I in 1..Input.nbPlayer do
		Players.I={PlayerManager.playerGenerator {GetElementInList Input.players I} {GetElementInList Input.colors I} I}
	end

  for I in 1..Input.nbPlayer do
    {InitPositionPlayers I}
  end
  if(Input.isTurnByTurn) then
    {StartTurnByTurn nil}
  else
    {System.showInfo 'simultaneous game not implemented yet!'}
    skip
  end

end
