functor
import
    OS
export
   isTurnByTurn:IsTurnByTurn
   nRow:NRow
   nColumn:NColumn
   map:Map
   nbPlayer:NbPlayer
   players:Players
   colors:Colors
   thinkMin:ThinkMin
   thinkMax:ThinkMax
   turnSurface:TurnSurface
   maxDamage:MaxDamage
   missile:Missile
   mine:Mine
   sonar:Sonar
   drone:Drone
   minDistanceMine:MinDistanceMine
   maxDistanceMine:MaxDistanceMine
   minDistanceMissile:MinDistanceMissile
   maxDistanceMissile:MaxDistanceMissile
define
   IsTurnByTurn
   NRow
   NColumn
   Map
   NbPlayer
   Players
   Colors
   ThinkMin
   ThinkMax
   TurnSurface
   MaxDamage
   Missile
   Mine
   Sonar
   Drone
   MinDistanceMine
   MaxDistanceMine
   MinDistanceMissile
   MaxDistanceMissile

   GenerateList
   GenerateMap
   GetRandomElem
   GetElementInList
in

%%%% Style of game %%%%

   IsTurnByTurn = true

%%%% Description of the map %%%%

  NRow = 10
  NColumn = 10

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

  fun{GenerateList L I}
    if I == 0 then
      L
    else
      {GenerateList {GetRandomElem [0 0 0 0 0 1] 6}|L I-1}
    end
  end

  fun{GenerateMap L Nr Nc}
    if Nr == 0 then
      L
    else
      {GenerateList nil Nc}|{GenerateMap L Nr-1 Nc}
    end
  end

  /*Map = [0 0 0 0 0 0 0 0 0 0]|
   [0 0 0 0 0 0 0 0 0 0]|
   [0 0 0 1 1 0 0 0 0 0]|
   [0 0 1 1 0 0 1 0 0 0]|
   [0 0 0 0 0 0 0 0 0 0]|
   [0 0 0 0 0 0 0 0 0 0]|
   [0 0 0 1 0 0 1 1 0 0]|
   [0 0 1 1 0 0 1 0 0 0]|
   [0 0 0 0 0 0 0 0 0 0]|
   [0 0 0 0 0 0 0 0 0 0]|nil*/

  Map={GenerateMap nil NRow NColumn}

   /*NRow = 10
   NColumn = 10

   Map = [[0 0 0 0 0 0 0 0 0 0]
	  [0 0 0 0 0 0 0 0 0 0]
	  [0 0 0 1 1 0 0 0 0 0]
	  [0 0 1 1 0 0 1 0 0 0]
	  [0 0 0 0 0 0 0 0 0 0]
	  [0 0 0 0 0 0 0 0 0 0]
	  [0 0 0 1 0 0 1 1 0 0]
	  [0 0 1 1 0 0 1 0 0 0]
	  [0 0 0 0 0 0 0 0 0 0]
	  [0 0 0 0 0 0 0 0 0 0]]*/


  /*NRow = 5
  NColumn = 5


  Map = [
    [0 0 0 0 0 ]
 	  [0 0 0 0 0 ]
 	  [0 0 1 0 0 ]
 	  [0 0 0 0 0 ]
 	  [0 0 0 0 0 ]]*/

    /*NRow = 7
    NColumn = 7
    Map = [
      [0 0 0 0 0 1 0]
      [0 1 1 0 0 1 0]
      [0 0 1 0 0 0 0]
      [0 0 0 0 0 1 1]
      [0 0 1 0 0 1 1]
      [1 0 0 0 0 0 0]
      [1 1 0 0 1 0 0]]*/

%%%% Players description %%%%

   NbPlayer = 3
   Players = [basicAI basicAI basicAI random]
   %To use the different colors of the player on the game, please do not user another colors
   Colors = [red blue green yellow white black]

%%%% Thinking parameters (only in simultaneous) %%%%

   ThinkMin = 750
   ThinkMax = 3000

%%%% Surface time/turns %%%%

   TurnSurface = 3

%%%% Life %%%%

   MaxDamage = 4

%%%% Number of load for each item %%%%

   Missile = 2
   Mine = 2
   Sonar = 2
   Drone = 2
%%%% Distances of placement %%%%

   MinDistanceMine = 1
   MaxDistanceMine = 2
   MinDistanceMissile = 2
   MaxDistanceMissile = 4



end
