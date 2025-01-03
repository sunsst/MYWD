cd /d %~dp0
@REM setx DST_MOD_TOOL  D:\@apps\@games\SteamLibrary\steamapps\common\Don't Starve Mod Tools
@REM setx DST_FILE  D:\±¸·Ý
python utils/copyfiles.py
python utils/makeatlas.py
python utils/makeanim.py
python utils/makanimimport.py