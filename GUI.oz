functor
import
   QTk at 'x-oz://system/wp/QTk.ozf'
   Input
   OS
export
   portWindow:StartWindow
define

   StartWindow
   TreatStream

   RemoveItem
   RemovePath
   RemovePlayer

   Map = Input.map

   NRow = Input.nRow
   NColumn = Input.nColumn


   DrawSubmarine
   MoveSubmarine
   DrawMine
   RemoveMine
   DrawExplosion
   DrawPath
   DrawMissile
   GetPicture


   BuildWindow

   Label
   Squares
   DrawMap

   StateModification

   UpdateLife

   MainURL={OS.getCWD}
   Img_map = {QTk.newImage photo(url:MainURL#"/inc/map.gif")}
   Img_Wall   = {QTk.newImage photo(url:MainURL#"/inc/wall.gif")}

   Img_Submarine_red = {QTk.newImage photo(url:MainURL#"/inc/submarine_red.gif")}
   Img_Submarine_blue = {QTk.newImage photo(url:MainURL#"/inc/submarine_blue.gif")}
   Img_Submarine_yellow = {QTk.newImage photo(url:MainURL#"/inc/submarine_yellow.gif")}
   Img_Submarine_white = {QTk.newImage photo(url:MainURL#"/inc/submarine_white.gif")}
   Img_Submarine_green = {QTk.newImage photo(url:MainURL#"/inc/submarine_green.gif")}
   Img_Submarine_black = {QTk.newImage photo(url:MainURL#"/inc/submarine_black.gif")}

   Img_Missile_red = {QTk.newImage photo(url:MainURL#"/inc/nuke_red.gif")}
   Img_Missile_blue = {QTk.newImage photo(url:MainURL#"/inc/nuke_blue.gif")}
   Img_Missile_yellow = {QTk.newImage photo(url:MainURL#"/inc/nuke_yellow.gif")}
   Img_Missile_white = {QTk.newImage photo(url:MainURL#"/inc/nuke_white.gif")}
   Img_Missile_green = {QTk.newImage photo(url:MainURL#"/inc/nuke_green.gif")}
   Img_Missile_black = {QTk.newImage photo(url:MainURL#"/inc/nuke_black.gif")}

   Img_Mine   = {QTk.newImage photo(url:MainURL#"/inc/mine.gif")}
   Img_explosion   = {QTk.newImage photo(url:MainURL#"/inc/explosion.gif")}

in

%%%%% Build the initial window and set it up (call only once)

  fun{GetPicture Pict Color}
    case Color
      of red then
        case Pict
          of submarine then
          Img_Submarine_red
          [] nuke then
          Img_Missile_red
        end
      [] blue then
        case Pict
          of submarine then
          Img_Submarine_blue
          [] nuke then
          Img_Missile_blue
        end
      [] white then
        case Pict
          of submarine then
          Img_Submarine_white
          [] nuke then
          Img_Missile_white
        end
      [] black then
        case Pict
          of submarine then
          Img_Submarine_black
          [] nuke then
          Img_Missile_black
        end
      [] yellow then
        case Pict
          of submarine then
          Img_Submarine_yellow
          [] nuke then
          Img_Missile_yellow
        end
      [] green then
        case Pict
          of submarine then
          Img_Submarine_green
          [] nuke then
          Img_Submarine_green
        end
    end
  end

   fun{BuildWindow}
      Grid GridScore Toolbar Desc DescScore Window
   in
      Toolbar=lr(glue:we tbbutton(text:"Quit" glue:w action:toplevel#close))
      Desc=grid(handle:Grid height:500 width:500)
      DescScore=grid(handle:GridScore height:100 width:500)
      Window={QTk.build td(Toolbar Desc DescScore)}

      {Window show}

      % configure rows and set headers
      {Grid rowconfigure(1 minsize:50 weight:0 pad:5)}
      for N in 1..NRow do
    {Grid rowconfigure(N+1 minsize:50 weight:0 pad:5)}
    {Grid configure({Label N} row:N+1 column:1 sticky:wesn)}
      end
      % configure columns and set headers
      {Grid columnconfigure(1 minsize:50 weight:0 pad:5)}
      for N in 1..NColumn do
    {Grid columnconfigure(N+1 minsize:50 weight:0 pad:5)}
    {Grid configure({Label N} row:1 column:N+1 sticky:wesn)}
      end
      % configure scoreboard
      {GridScore rowconfigure(1 minsize:50 weight:0 pad:5)}
      for N in 1..(Input.nbPlayer) do
    {GridScore columnconfigure(N minsize:50 weight:0 pad:5)}
      end

      {DrawMap Grid}

      handle(grid:Grid score:GridScore)
   end


%%%%% Squares of water and island
   /*Squares = square(0:label(text:"" width:1 height:1 bg:c(102 102 255))
          1:label(text:"" borderwidth:5 relief:raised width:1 height:1 bg:c(153 76 0))
         )*/
   Squares = square(
          0:label(text:"" width:1 height:1 bg:c(120 197 249) )
            %1:label(text:"" borderwidth:5 relief:raised width:1 height:1 bg:c(76 68 50) image:Img_map)
            1:label(text:"" borderwidth:5 relief:raised width:1 height:1  image:Img_map)
         )

%%%%% Labels for rows and columns
   fun{Label V}
      label(text:V borderwidth:5 relief:raised bg:c(153 76 0) ipadx:5 ipady:5)% image:Img_Wall)
   end

%%%%% Function to draw the map
   proc{DrawMap Grid}
      proc{DrawColumn Column M N}
    case Column
    of nil then skip
    [] T|End then
       {Grid configure(Squares.T row:M+1 column:N+1 sticky:wesn)}
       {DrawColumn End M N+1}
    end
      end
      proc{DrawRow Row M}
    case Row
    of nil then skip
    [] T|End then
       {DrawColumn T M 1}
       {DrawRow End M+1}
    end
      end
   in
      {DrawRow Map 1}
   end

%%%%% Init the submarine
   fun{DrawSubmarine Grid ID Position}
      Handle HandlePath HandleScore X Y Id Color LabelSub LabelScore Img
   in
      pt(x:X y:Y) = Position
      id(id:Id color:Color name:_) = ID
      %LabelSub = label(text:"P"#ID.id handle:Handle borderwidth:5 relief:raised bg:Color ipadx:5 ipady:5 image:Img_Submarine)
      Img={GetPicture submarine ID.color}
      LabelSub = label(text:"P"#ID.id handle:Handle borderwidth:5 bg:c(120 197 249) ipadx:5 ipady:5 image:Img)
      LabelScore = label(text:Input.maxDamage borderwidth:5 handle:HandleScore relief:solid bg:Color ipadx:5 ipady:5)
      HandlePath = {DrawPath Grid Color X Y}
      {Grid.grid configure(LabelSub row:X+1 column:Y+1 sticky:wesn)}
      {Grid.score configure(LabelScore row:1 column:Id sticky:wesn)}
      {HandlePath 'raise'()}
      {Handle 'raise'()}
      guiPlayer(id:ID score:HandleScore submarine:Handle mines:nil path:HandlePath|nil)
   end


   fun{MoveSubmarine Position}
      fun{$ Grid State}
    ID HandleScore Handle Mine Path NewPath X Y
      in
    guiPlayer(id:ID score:HandleScore submarine:Handle mines:Mine path:Path) = State
    pt(x:X y:Y) = Position
    NewPath = {DrawPath Grid ID.color X Y}
    {Grid.grid remove(Handle)}
    {Grid.grid configure(Handle row:X+1 column:Y+1 sticky:wesn)}
    {NewPath 'raise'()}
    {Handle 'raise'()}
    guiPlayer(id:ID score:HandleScore submarine:Handle mines:Mine path:NewPath|Path)
      end
   end


   fun{DrawMine Position}
      fun{$ Grid State}
    ID HandleScore Handle Mine Path LabelMine HandleMine X Y
      in
    guiPlayer(id:ID score:HandleScore submarine:Handle mines:Mine path:Path) = State
    pt(x:X y:Y) = Position
    %    LabelMine = label(text:"M" handle:HandleMine borderwidth:5 relief:raised bg:ID.color ipadx:5 ipady:5 image:Img_Mine)
    LabelMine = label(text:"M" handle:HandleMine bg:c(120 197 249) ipadx:5 ipady:5 image:Img_Mine)

    {Grid.grid configure(LabelMine row:X+1 column:Y+1)}
    {HandleMine 'raise'()}
    {Handle 'raise'()}
    guiPlayer(id:ID score:HandleScore submarine:Handle mines:mine(HandleMine Position)|Mine path:Path)
      end
   end

   local
      fun{RmMine Grid Position List}
    case List
    of nil then nil
    [] H|T then
       if (H.2 == Position) then
          {RemoveItem Grid H.1}
          T
       else
          H|{RmMine Grid Position T}
       end
    end
      end
   in
      fun{RemoveMine Position}
    fun{$ Grid State}
       ID HandleScore Handle Mine Path NewMine
    in
       guiPlayer(id:ID score:HandleScore submarine:Handle mines:Mine path:Path) = State
       NewMine = {RmMine Grid Position Mine}
       guiPlayer(id:ID score:HandleScore submarine:Handle mines:NewMine path:Path)
    end
      end
   end

   fun{DrawExplosion Position}
      fun{$ Grid State}
    ID HandleScore Handle Mine Path LabelMine HandleMine X Y
      in
    guiPlayer(id:ID score:HandleScore submarine:Handle mines:Mine path:Path) = State
    pt(x:X y:Y) = Position
    %    LabelMine = label(text:"M" handle:HandleMine borderwidth:5 relief:raised bg:ID.color ipadx:5 ipady:5 image:Img_explosion)
    LabelMine = label(text:"M" handle:HandleMine bg:c(120 197 249) ipadx:5 ipady:5 image:Img_explosion)

    {Grid.grid configure(LabelMine row:X+1 column:Y+1)}
    {HandleMine 'raise'()}
    {Handle 'raise'()}
    guiPlayer(id:ID score:HandleScore submarine:Handle mines:mine(HandleMine Position)|Mine path:Path)
      end
   end

   fun{DrawMissile Position}
      fun{$ Grid State}
    ID HandleScore Handle Mine Path LabelMine HandleMine X Y Img
      in
    guiPlayer(id:ID score:HandleScore submarine:Handle mines:Mine path:Path) = State
    pt(x:X y:Y) = Position
    %    LabelMine = label(text:"M" handle:HandleMine borderwidth:5 relief:raised bg:ID.color ipadx:5 ipady:5 image:Img_Mine)
    Img={GetPicture nuke ID.color}

    LabelMine = label(text:"M" handle:HandleMine bg:c(120 197 249) ipadx:5 ipady:5 image:Img)

    {Grid.grid configure(LabelMine row:X+1 column:Y+1)}
    {HandleMine 'raise'()}
    {Handle 'raise'()}
    guiPlayer(id:ID score:HandleScore submarine:Handle mines:mine(HandleMine Position)|Mine path:Path)
      end
   end

   fun{DrawPath Grid Color X Y}
      Handle LabelPath
   in
      LabelPath = label(text:"" handle:Handle bg:Color)
      {Grid.grid configure(LabelPath row:X+1 column:Y+1)}
      Handle
   end

   proc{RemoveItem Grid Handle}
      {Grid.grid forget(Handle)}
   end


   fun{RemovePath Grid State}
      ID HandleScore Handle Mine Path
   in
      guiPlayer(id:ID score:HandleScore submarine:Handle mines:Mine path:Path) = State
      for H in Path.2 do
    {RemoveItem Grid H}
      end
      guiPlayer(id:ID score:HandleScore submarine:Handle mines:Mine path:Path.1|nil)
   end

   fun{UpdateLife Life}
      fun{$ Grid State}
    HandleScore
      in
    guiPlayer(id:_ score:HandleScore submarine:_ mines:_ path:_) = State
    {HandleScore set(Life)}
    State
      end
   end


   fun{StateModification Grid WantedID State Fun}
      case State
      of nil then nil
      [] guiPlayer(id:ID score:_ submarine:_ mines:_ path:_)|Next then
    if (ID == WantedID) then
       {Fun Grid State.1}|Next
    else
       State.1|{StateModification Grid WantedID Next Fun}
    end
      end
   end


   fun{RemovePlayer Grid WantedID State}
      case State
      of nil then nil
      [] guiPlayer(id:ID score:HandleScore submarine:Handle mines:M path:P)|Next then
    {HandleScore set(0)}
    if (ID == WantedID) then
       for H in P do
          {RemoveItem Grid H}
       end
       for H in M do
          {RemoveItem Grid H.1}
       end
       {RemoveItem Grid Handle}
       Next
    else
       State.1|{RemovePlayer Grid WantedID Next}
    end
      end
   end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   fun{StartWindow}
      Stream
      Port
   in
      {NewPort Stream Port}
      thread
    {TreatStream Stream nil nil}
      end
      Port
   end

   proc{TreatStream Stream Grid State}
      case Stream
      of nil then skip
      [] buildWindow|T then NewGrid in
    NewGrid = {BuildWindow}
    {TreatStream T NewGrid State}
      [] initPlayer(ID Position)|T then NewState in
    NewState = {DrawSubmarine Grid ID Position}
    {TreatStream T Grid NewState|State}
      [] movePlayer(ID Position)|T then
    {TreatStream T Grid {StateModification Grid ID State {MoveSubmarine Position}}}
      [] lifeUpdate(ID Life)|T then
    {TreatStream T Grid {StateModification Grid ID State {UpdateLife Life}}}
    {TreatStream T Grid State}
      [] putMine(ID Position)|T then
    {TreatStream T Grid {StateModification Grid ID State {DrawMine Position}}}
      [] removeMine(ID Position)|T then
    {TreatStream T Grid {StateModification Grid ID State {RemoveMine Position}}}
      [] surface(ID)|T then
    {TreatStream T Grid {StateModification Grid ID State RemovePath}}
      [] removePlayer(ID)|T then
    {TreatStream T Grid {RemovePlayer Grid ID State}}
      [] explosion(ID Position)|T then
    %{TreatStream T Grid State}
    {TreatStream T Grid {StateModification Grid ID State {DrawExplosion Position}}}
      [] missile(ID Position)|T then
    %{TreatStream T Grid State}
    {TreatStream T Grid {StateModification Grid ID State {DrawMissile Position}}}
      [] drone(ID Drone)|T then
    {TreatStream T Grid State}
      [] sonar(ID)|T then
    {TreatStream T Grid State}
      [] _|T then
    {TreatStream T Grid State}
      end
   end




end
