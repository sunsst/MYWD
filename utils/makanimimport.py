import os
from os.path import join
import subprocess

MYWD = os.path.normpath(join(os.path.dirname(__file__), "../MYWD"))
MYWD_RES = os.path.normpath(join(os.path.dirname(__file__), "../MYWD_RES"))

ANIM_DIR = os.path.normpath(join(MYWD, 'anim'))
IMG_DIR = os.path.normpath(join(MYWD, 'images'))


def make_anim_import():
    sb_anim = ['"anim/{}",'.format(anim_name)
               for anim_name in os.listdir(ANIM_DIR) if anim_name.endswith('.zip')]
    sb_img = ['"images/{}",'.format(img_name)
              for img_name in os.listdir(IMG_DIR) if img_name.endswith('.xml')]
    t = 'ANIM_IMPORT = {{\n{}\n}}\nIMAGE_IMPORT = {{\n{}\n}}\n'.format(
        '\n'.join(sb_anim), '\n'.join(sb_img))
    with open(join(MYWD, 'modscripts', 'testutil', 'anim_import.lua'), 'w', encoding='utf-8') as f:
        f.write(t)


make_anim_import()
