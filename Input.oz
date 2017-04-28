functor
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
in

%%%% Style of game %%%%

   IsTurnByTurn = true

%%%% Description of the map %%%%




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

    NRow = 7
    NColumn = 7
    Map = [
      [0 0 0 0 0 1 0]
      [0 1 1 0 0 1 0]
      [0 0 1 0 0 0 0]
      [0 0 0 0 0 1 1]
      [0 0 1 0 0 1 1]
      [1 0 0 0 0 0 0]
      [1 1 0 0 1 0 0]]

%%%% Players description %%%%

   NbPlayer = 2
   Players = [random basicAI random random]
   Colors = [red blue green yellow white black]

%%%% Thinking parameters (only in simultaneous) %%%%

   ThinkMin = 750
   ThinkMax = 3000

%%%% Surface time/turns %%%%

   TurnSurface = 3

%%%% Life %%%%

   MaxDamage = 2

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
