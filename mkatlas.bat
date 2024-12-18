	
cd /d %~dp0

utils\pngs.exe

for %%i in ("MYWD\images\*.xml") do move %%i %%i.a

@REM 把mod工具加到path里，比如我的路径："D:\@apps\@games\SteamLibrary\steamapps\common\Don't Starve Mod Tools\mod_tools"
cmd /c autocompiler

for %%i in ("MYWD\images\*.xml") do move %%i.a %%i
for %%i in ("MYWD\images\*.png") do del %%i

@REM for /r "MYWD\exported" %%i in ("*.zip") do del %%i