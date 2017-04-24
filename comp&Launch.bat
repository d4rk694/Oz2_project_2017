@echo off

:loop
echo Choose an option.
echo 1: delete ozf
echo 2: recompile oz files
echo 3: launch the game
echo 4: exit the program
set /p compile=What do you want to do?
cls
if /i %compile%==1 goto delete
if /i %compile%==2 goto compilation
if /i %compile%==3 goto launch
if /i %compile%==4 goto stop


:delete
del *.ozf
goto loop

:compilation
ozc -c *.oz
goto loop

:launch
ozengine Main.ozf
goto loop

:stop
exit
