

import os
import re

cwd= "D:/Code/MYWD/"
anim_dir = "D:/备份/测试服动画"
scripts_dir = "D:/备份/测试服脚本"
atlas_dir = "D:/备份/测试服图片"

os.makedirs(os.path.join(cwd,"MYWD/anim"),exist_ok=True)


anims_sesarch_files = [
    "wendy",
    "abigail",
    "abigail_flower",
    "sisturn",
    "gravestone",
    "ghostly_elixirs",
    "elixir_container",
    "wendy_recipe_gravestone",
    "wendy_resurrectiongrave"
]    
      
anims:list[str] = [
    "anim/ui_elixir_container_3x3.zip",
    "anim/hat_ghostflower.zip",
    "anim/abigail_vial_fx.zip",
    "anim/planar_resist_fx.zip",
    "anim/wortox_teleport_reviver_fx.zip",
    "anim/slingshotammo.zip",
    "anim/abigail_shield.zip",
    "anim/slingshotammo.zip",
    "anim/wendy_sanityaura_buff_fx.zip",
    "anim/abigail_rising_twinkles.zip",
    "anim/abigail_meta5_fx.zip",
    "anim/slingshotammo_purebrilliance_mark_fx.zip",
    "anim/spell_icons_wendy.zip"
]

atlas_files = [
    "images/inventoryimages3.xml",
    "images/skilltree_icons.xml",
    "images/skilltree4.xml",
    "images/inventoryimages2.xml",
    "images/inventoryimages1.xml",
    "images/hud2.xml"
]

lua_files = [
    "fx.lua",
    "components/upgradeable.lua",
    "components/gravedigger.lua",
    "components/gravediggable.lua",
    "components/ghostgestalter.lua",
    "components/ghostbabysitter.lua",
    "brains/graveguard_ghostbrain.lua",
    "brains/ghostbrain.lua",
    "stategraphs/SGghost.lua",
    "prefabs/wendy_resurrectiongrave.lua",
    "prefabs/wendy_recipe_gravestone.lua",
    "prefabs/ghostvision_buff.lua",

    "brains/abigailbrain.lua",
    "brains/smallghostbrain.lua",
    "brains/wilsonbrain.lua",
    "components/ghostlyelixir.lua",
    "components/sanityauraadjuster.lua",
    "components/ghostlybond.lua",
    "prefabs/abigail.lua",
    "prefabs/abigail_flower.lua",
    "prefabs/elixir_container.lua",
    "prefabs/ghost.lua",
    "prefabs/ghostcommand_defs.lua",
    "prefabs/ghostly_elixirs.lua",
    "prefabs/gravestone.lua",
    "prefabs/hats.lua",
    "prefabs/petals.lua",
    "prefabs/reticuleaoe.lua",
    "prefabs/sisturn.lua",
    "prefabs/skilltree_wendy.lua",
    "prefabs/smallghost.lua",
    "prefabs/wendy.lua",
    "stategraphs/SGabigail.lua",
    "stategraphs/SGsmallghost.lua",
    "stategraphs/SGwilson.lua",
    "stategraphs/SGwilson_client.lua",
]
    
# for root , dirs, files in os.walk(os.path.join(cwd,"MYWD/scripts")):
#     for f in files:
#         if f.endswith(".lua") :
#             fname = os.path.relpath(os.path.join(root, f), os.path.join(cwd,"MYWD"))
#             print('"{}",'.format(fname).replace('\\','/'))


for fname in lua_files:
    with open(os.path.join(scripts_dir, "scripts", fname), 'r',encoding="utf-8") as f:
        fn=os.path.join(cwd,"MYWD/scripts", fname)
        os.makedirs(os.path.dirname(fn), exist_ok=True)
        with open(fn,'w', encoding='utf-8') as wf:
            wf.write("---@diagnostic disable: undefined-global, need-check-nil, undefined-field, undefined-field, redundant-parameter\n")
            wf.write(f.read())
            
            
            
            
            
  
reg = re.compile(r'(?<=Asset\("ANIM", ")(.*?)(?="\))')

for fname in anims_sesarch_files:
    with open(os.path.join(cwd, "MYWD/scripts/prefabs", fname+'.lua'),'r', encoding="utf-8") as f:
        ftext = f.read()
    for m in reg.finditer(ftext):
        anims.append(m.group(1))

for anim_fname in anims :
    # print(anim_fname)
    with open(os.path.join(anim_dir, anim_fname), 'rb') as f :
        with open(os.path.join(cwd,"MYWD",anim_fname), 'wb') as wf:
            wf.write(f.read())


for atlas in atlas_files:
    with open(os.path.join(atlas_dir, atlas), 'rb') as f:
        with open(os.path.join(cwd,"MYWD",atlas), 'wb') as wf:
            wf.write(f.read())
    atlasa = atlas[:-4]+".tex"
    with open(os.path.join(atlas_dir, atlasa), 'rb') as f:
        with open(os.path.join(cwd,"MYWD",atlasa), 'wb') as wf:
            wf.write(f.read())
        