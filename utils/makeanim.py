import os
from os.path import join
import subprocess

MYWD = os.path.normpath(join(os.path.dirname(__file__), "../MYWD"))
MYWD_RES = os.path.normpath(join(os.path.dirname(__file__), "../MYWD_RES"))
EXPORT_DIR = MYWD
SCML_DIR = os.path.normpath(join(MYWD_RES, 'scml'))

if 'DST_MOD_TOOL' in os.environ:
    DST_MOD_TOOL = os.path.normpath(os.environ['DST_MOD_TOOL'].strip('"'))
    DST_MOD_TOOL_TL = os.path.normpath(
        join(DST_MOD_TOOL, 'mod_tools'))
    if os.path.exists(DST_MOD_TOOL_TL):
        os.environ['PATH'] = os.pathsep.join(
            [DST_MOD_TOOL_TL, os.environ['PATH']])
    else:
        DST_MOD_TOOL = None
else:
    DST_MOD_TOOL = None


def make_anim():
    if DST_MOD_TOOL is None:
        print('未设置环境变量 DST_MOD_TOOL，放弃编译动画')
        return
    exe = join(DST_MOD_TOOL_TL, 'scml.exe')
    for scml_dir in os.listdir(SCML_DIR):
        if os.path.isdir(join(SCML_DIR, scml_dir)):
            for scml_file in os.listdir(join(SCML_DIR, scml_dir)):
                if scml_file.endswith('.scml'):
                    subprocess.run(
                        [exe, join(SCML_DIR, scml_dir, scml_file), EXPORT_DIR])
                    print(
                        '√ 编译动画: "anim/{}"'.format(scml_file.removesuffix('.scml')+'.zip'))


if __name__ == '__main__':
    make_anim()
