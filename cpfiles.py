

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
]    
      
anims:list[str] = [
    "anim/spell_icons_wendy.zip"
]

atlas_files:list[str] = [
]

lua_files:list[str] = [
]
    
# for root , dirs, files in os.walk(os.path.join(cwd,"MYWD/scripts")):
#     for f in files:
#         if f.endswith(".lua") :
#             fname = os.path.relpath(os.path.join(root, f), os.path.join(cwd,"MYWD"))
#             print('"{}",'.format(fname).replace('\\','/'))


# 复制代码文件
for fname in lua_files:
    with open(os.path.join(scripts_dir, "scripts", fname), 'r',encoding="utf-8") as f:
        fn=os.path.join(cwd,"MYWD/scripts", fname)
        os.makedirs(os.path.dirname(fn), exist_ok=True)
        with open(fn,'w', encoding='utf-8') as wf:
            wf.write("---@diagnostic disable: undefined-global, need-check-nil, undefined-field, undefined-field, redundant-parameter\n")
            wf.write(f.read())
            
            
            
            
# 查询动画资源
  
reg = re.compile(r'(?<=Asset\("ANIM", ")(.*?)(?="\))')

for fname in anims_sesarch_files:
    with open(os.path.join(scripts_dir,"scripts/prefabs", fname+'.lua'),'r', encoding="utf-8") as f:
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
        