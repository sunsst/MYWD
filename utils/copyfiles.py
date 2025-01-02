import os
from os.path import join


MYWD = os.path.normpath(join(os.path.dirname(__file__), "../MYWD"))
MYWD_RES = os.path.normpath(join(os.path.dirname(__file__), "../MYWD_RES"))
if 'DST_FILE' in os.environ:
    DST_FILE = os.path.normpath(os.environ['DST_FILE'].strip('"'))
else:
    DST_FILE = None


def copy_files():

    os.makedirs(MYWD, exist_ok=True)
    os.makedirs(MYWD_RES, exist_ok=True)
    os.makedirs(join(MYWD, 'modscripts'), exist_ok=True)
    os.makedirs(join(MYWD, 'scripts'), exist_ok=True)
    os.makedirs(join(MYWD, 'images'), exist_ok=True)
    os.makedirs(join(MYWD, 'anim'), exist_ok=True)
    os.makedirs(join(MYWD_RES, 'atlas'), exist_ok=True)
    os.makedirs(join(MYWD_RES, 'scml'), exist_ok=True)

    if DST_FILE is None:
        print('未设置环境变量 DST_FILE，放弃复制文件')
        return

    copys = {
        "scripts": {
            "原版脚本": [],
            "测试服脚本": [],
        },
        "anim": {
            "原版动画": [],
            "测试服动画": [],
        }
    }

    mv = {
        # "dst": "src"
    }

    for dest_dir, v in copys.items():
        for src_dir, files in v.items():
            if not os.path.exists(join(DST_FILE,  src_dir)):
                print('不存在 {} 放弃复制文件'.format(join(DST_FILE,  src_dir)))

            for file in files:
                os.makedirs(os.path.dirname(
                    join(MYWD,  dest_dir, file)), exist_ok=True)
                with open(join(DST_FILE,  src_dir, dest_dir, file), 'br') as fr:
                    with open(join(MYWD,  dest_dir, file), 'bw') as fw:
                        if dest_dir == "scripts":
                            fw.write(
                                '---@diagnostic disable: undefined-global, need-check-nil, undefined-field, undefined-field, redundant-parameter\n'.encode())
                        fw.write(fr.read())

    for dst, src in mv.items():
        os.makedirs(os.path.dirname(join(MYWD, dst)))
        os.rename(join(MYWD, src), join(MYWD, dst))


if __name__ == "__main__":
    copy_files()
