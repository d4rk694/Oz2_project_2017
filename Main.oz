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
    info(turnLeftSurface:_ )
  end

  fun{StateModification State Value Result} NewStatePlayer in
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
      {Send Players.Idnum move(ID Position Direction)}
      {Send PortWindow movePlayer(ID Position)}
      if(Direction == surface) then
        {Send PortWindow surface(ID)}
        {Broadcast ID saySurface(ID)}
        RetVal = true
      else
        {Broadcast ID sayMove(ID Direction)}
        RetVal = false
      end
      RetVal
  end

  proc{ChargeItem Idnum} ID KindItem in
    {Send Players.Idnum chargeItem(?ID ?KindItem)}
    thread
      {Wait KindItem}
      if ID \= nil then
        {Broadcast ID sayCharge(ID KindItem)}
      end
    end
  end

  proc{FireItem Idnum} ID FireItem in
    {Send Players.Idnum fireItem(?ID ?FireItem)}
    thread
      {Wait FireItem}
      if ID \= nil then
        case FireItem
        of nil then
         {System.showInfo 'No Item Fired'}
        [] mine(P) then
          {Send PortWindow putMine(ID P)}
          {Broadcast ID sayMinePlaced(ID)}
        [] missile(P) then
          for I in 1..Input.nbPlayer do
            thread
              local Message in
                {Send Players.I sayMissileExplode(ID P Message)}
                {Wait Message}
                case Message
                of nil then
                  skip
                [] sayDeath(PlayerId) then
                  if PlayerId \= nil then
                    {System.showInfo '[INFO]'# ID.name #' killed '#PlayerId.name#' with a missile'}
                    {Send PortWindow removePlayer(PlayerId)}
                  end
                [] sayDamageTaken(PlayerId DamageTaken LifeLeft) then
                  if PlayerId \= nil then
                    {System.showInfo '[INFO]'#PlayerId.name#' has lost '#DamageTaken #' with a missile by '#ID.name#', [LIFELEFT = '#LifeLeft#']'}
                    {Send PortWindow lifeUpdate(PlayerId LifeLeft)}
                  end
                end
                {Broadcast ID Message}
              end
            end
          end
          local P1 P2 P3 P4 in
            P1=pt(x:P.x+1 y:P.y)
            P2=pt(x:P.x-1 y:P.y)
            P3=pt(x:P.x y:P.y+1)
            P4=pt(x:P.x y:P.y-1)

            {Send PortWindow missile(ID P)}
            {Delay 750}
            {Send PortWindow removeMine(ID P)}
            {Send PortWindow explosion(ID P)}
            %Send mini explosion to adjacents points
            {Send PortWindow explosion2(ID P1)}
            {Send PortWindow explosion2(ID P2)}
            {Send PortWindow explosion2(ID P3)}
            {Send PortWindow explosion2(ID P4)}
            {Delay 750}
            {Send PortWindow removeMine(ID P)}
            {Send PortWindow removeMine(ID P1)}
            {Send PortWindow removeMine(ID P2)}
            {Send PortWindow removeMine(ID P3)}
            {Send PortWindow removeMine(ID P4)}
          end
        %  {System.showInfo '                         MISSILE REMOVED'}
        [] sonar then

          for I in 1..Input.nbPlayer do
            thread
              local Answer IDPlayer in
                {Send Players.I sayPassingSonar(IDPlayer Answer)}
                {Wait Answer}
                if IDPlayer \= nil andthen IDPlayer.id \= ID.id then
                  {Send Players.Idnum sayAnswerSonar(IDPlayer Answer)}
                end
              end
            end
          end

        [] drone(row:X) then
          if ID \= nil then
            {System.showInfo '[INFO] '#ID.name #' sent a Drone on row '#X}
            for I in 1..Input.nbPlayer do
              thread
                local Answer IDPlayer in
                  {Send Players.I sayPassingDrone(FireItem IDPlayer Answer)}
                  {Wait Answer}
                  if IDPlayer \= nil andthen IDPlayer.id \= ID.id then
                    {Send Players.Idnum sayAnswerDrone(FireItem IDPlayer Answer)}
                  end
                end
              end
            end
          end
        [] drone(column:Y) then
          if ID \= nil then
            {System.showInfo '[INFO] '#ID.name #' sent a Drone on column '#Y}
            for I in 1..Input.nbPlayer do
              thread
                local Answer IDPlayer in
                  {Send Players.I sayPassingDrone(FireItem IDPlayer Answer)}
                  {Wait Answer}
                  if IDPlayer \= nil andthen IDPlayer.id \= ID.id then
                    {Send Players.Idnum sayAnswerDrone(FireItem IDPlayer Answer)}
                  end
                end
              end
            end
          end
        else
         {System.showInfo 'Not an item recognized'}
        end
        %{System.showInfo '### FIRED : MOTHAFUCKER!!!!!!'}
      end % case FireItem
    end
  end


  proc{Broadcast ID Message }
    for I in 1..Input.nbPlayer do
      if ID == nil orelse I == ID.id then
        skip
      else
        {Send Players.I Message}
      end
    end
  end

  proc{BlowMine Idnum} ID Mine in
    {Send Players.Idnum fireMine(?ID ?Mine)}

    thread
      {Wait Mine}
      {Send PortWindow removeMine(ID Mine.1)}
      {Send PortWindow explosion(ID Mine.1)}

      /*local P P1 P2 P3 P4 in
        P = Mine.1
        P1=pt(x:P.x+1 y:P.y)
        P2=pt(x:P.x-1 y:P.y)
        P3=pt(x:P.x y:P.y+1)
        P4=pt(x:P.x y:P.y-1)

        {Send PortWindow removeMine(ID P)}
        {Send PortWindow explosion(ID P)}
        %Send mini explosion to adjacents points
        {Send PortWindow explosion2(ID P1)}
        {Send PortWindow explosion2(ID P2)}
        {Send PortWindow explosion2(ID P3)}
        {Send PortWindow explosion2(ID P4)}
        {Delay 750}
        {Send PortWindow removeMine(ID P)}
        {Send PortWindow removeMine(ID P1)}
        {Send PortWindow removeMine(ID P2)}
        {Send PortWindow removeMine(ID P3)}
        {Send PortWindow removeMine(ID P4)}
      end*/

      for I in 1..Input.nbPlayer do
        thread
          local Message in
            {Send Players.I sayMineExplode(ID Mine.1 Message)}
            {Wait Message}
            case Message
            of nil then
              skip
            [] sayDeath(PlayerId) then
              if PlayerId \= nil andthen ID \= nil then
                {System.showInfo '[INFO]'# ID.name #' killed '#PlayerId.name#' with a mine '}
                {Send PortWindow removePlayer(PlayerId)}
              end

            [] sayDamageTaken(PlayerId DamageTaken LifeLeft) then
              if PlayerId \= nil andthen ID \= nil  then
                {System.showInfo '[INFO]'#PlayerId.name#' has lost '#DamageTaken #' with a mine by '#ID.name#', [LIFELEFT = '#LifeLeft#']'}
                {Send PortWindow lifeUpdate(PlayerId LifeLeft)}
              end
            end
            {Broadcast ID Message}
          end
        end
      end
      {Delay 1000}
      {Send PortWindow removeMine(ID Mine.1)}
      if ID \= nil then
        {System.showInfo '[INFO] '#ID.name#' blowed a mine at position : X:' #Mine.1.x #' Y:'#Mine.1.y}
      end
    end
    skip
  end

  proc{StartTurnByTurn State N} NewState  in %State foreach player State(1:(Surfaceturn:0 )
    %foreach players
    NewState = {MakeTuple statePlayers Input.nbPlayer}
    for J in 1..N do
      local TurnToSurface in
        {Delay Input.thinkMin}
        {System.showInfo '[DEBUG] Turn start for player '#J}

        % 1.
        if State.J.turnLeftSurface == 0 then
          % 2.
          {Send Players.J dive}
          % 3. The broadcast (5.) is done in the proc MovePlayers
          if {MovePlayers J} then
            % 4.
            TurnToSurface=Input.turnSurface - 1
            %We go derectly to 9. by skiping the else statement
          else
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
          NewState.J={StateModification State.J turnLeftSurface (State.J.turnLeftSurface - 1)}
        else
          NewState.J={StateModification State.J turnLeftSurface TurnToSurface}
        end
      end %end local
    end %end foreach player

    {StartTurnByTurn NewState N}
  end

  proc {StartSimultaneous PlayerNum} WaitingTime in
    {System.showInfo '[DEBUG] Start simultaneous for player '#PlayerNum}
    WaitingTime = ({OS.rand} mod (Input.thinkMax - Input.thinkMin)) + Input.thinkMin %to Simulate Thinking betweed Input.thinkMin & Input.thinkMax
    % 1. send dive Message
    {Send Players.PlayerNum dive}
    % 2. delay Thinking
    {Delay WaitingTime}
    % 3. choose direction
    if {MovePlayers PlayerNum} then % 5. broadcast direction done in MovePlayers
      % 4. if direction == surface , delay and go back 1.
      {Delay (Input.turnSurface * 1000)}
    else
      % 6. delay Thinking
      {Delay WaitingTime}
      % 7 charge Item and broadcast if ready
      {ChargeItem PlayerNum}
      % 8 delay Thinking
      {Delay WaitingTime}
      % 9 fire item and broadcast
      {FireItem PlayerNum}
      % 10 delay Thinking
      {Delay WaitingTime}
      % 11. explose mine and broadcast
      {BlowMine PlayerNum}
    end
    % 12. go back 1.
    {StartSimultaneous PlayerNum}
  end

  fun{CountDead L}
     case L of nil then
        0
     []H|T then
        if {IsDet H} then
  	 {CountDead T} + 1
        else
  	 {CountDead T}
        end
     end
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
	end

  for I in 1..Input.nbPlayer do
    {InitPositionPlayers I}
  end

  if(Input.isTurnByTurn) then
    {StartTurnByTurn PlayersState Input.nbPlayer}
  else
    for I in 1..Input.nbPlayer do
      thread
        {StartSimultaneous I}
      end
    end
  end
end
