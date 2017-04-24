@echo off

set /p compile=Do you want to recompile the game?(Y/N):
if /i %compile%==y goto compilation
if /i %compile%==n goto launch

:compilation
del *.ozf
ozc -c *.oz

set /p compile=Do you want to lauch the game?(Y/N):
if /i %compile%==y goto launch
if /i %compile%==n goto stop

:launch
ozengine Main.ozf


:stop
exit
