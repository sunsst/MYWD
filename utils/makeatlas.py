import os
import subprocess
from PIL import Image
from os.path import join, dirname

# 两个图片之间的空间
SPACE = 5

MYWD = os.path.normpath(join(os.path.dirname(__file__), "../MYWD"))
MYWD_RES = os.path.normpath(join(os.path.dirname(__file__), "../MYWD_RES"))
EXPORT_DIR = os.path.normpath(join(MYWD, 'images'))
ATLAS_DIR = os.path.normpath(join(MYWD_RES, 'atlas'))

if 'DST_MOD_TOOL' in os.environ:
    DST_MOD_TOOL = os.path.normpath(os.environ['DST_MOD_TOOL'].strip('"'))
    DST_MOD_TOOL_BIN = os.path.normpath(
        join(DST_MOD_TOOL, 'mod_tools'))
    if os.path.exists(DST_MOD_TOOL_BIN):
        os.environ['PATH'] = os.pathsep.join(
            [DST_MOD_TOOL_BIN, os.environ['PATH']])
    else:
        DST_MOD_TOOL = None
else:
    DST_MOD_TOOL = None


def make_atlas():
    if DST_MOD_TOOL is None:
        print('未设置环境变量 DST_MOD_TOOL，放弃编译图集')
        return

    # 生成.tex文件
    exe = join(DST_MOD_TOOL_BIN, 'png.exe')

    def compiler_tex(tex_name, png_name):
        subprocess.run([exe, join(EXPORT_DIR, png_name),
                       join(EXPORT_DIR, tex_name)])

    class PNG:
        def __init__(self,  img_data, png_name):
            self.img_data = img_data
            self.png_name = png_name
            self.width = img_data.width
            self.height = img_data.height
            self.x: float = 0
            self.y: float = 0

    class Atlas:
        def __init__(self, atlas_name, atlas_dir_path):
            self.atlas_name = atlas_name
            self.atlas_dir_path = atlas_dir_path
            self.imgs_filename = [fname for fname in os.listdir(
                atlas_dir_path) if fname.endswith('.png')]

            self.imgs_data = [PNG(Image.open(join(self.atlas_dir_path, fname)), fname)
                              for fname in self.imgs_filename]
            self.imgs_data.sort(key=lambda x: x.width * x.height)

        def merge(self, exportdir):
            max_w = 0
            max_h = 0
            off_x = SPACE
            off_y = SPACE
            for png in self.imgs_data:
                m_w = off_x+png.width+SPACE
                m_h = off_y+png.height+SPACE
                if m_w > 2*m_h:
                    # 当前图片的宽度大于两倍的高度时，换行
                    off_x = SPACE
                    off_y = max_h
                    m_w = off_x+png.width+SPACE
                    m_h = off_y+png.height+SPACE
                elif m_h > 2*m_w:
                    # 当前图片的高度大于两倍的宽度时，换列
                    off_y = SPACE
                    off_x = max_w
                    m_w = off_x+png.width+SPACE
                    m_h = off_y+png.height+SPACE

                if m_w > max_w:
                    max_w = m_w
                if m_h > max_h:
                    max_h = m_h

                png.x = off_x
                png.y = off_y
                off_x = m_w
                # print("Image: {0:<20} x: {1:<5} y: {2:<5} width: {3:<5} height: {4:<5}".format(
                #     png.png_name, png.x, png.y, png.width, png.height))

            # 可能是因为小数点精度的原因，必须对齐512
            max_w += 512-max_w % 512
            max_h += 512-max_h % 512

            w = Image.new('RGBA', (max_w, max_h))
            for png in self.imgs_data:
                w.paste(png.img_data, (png.x, png.y))

            max_h = float(max_h)
            max_w = float(max_w)
            sb = []
            sb.append(
                '<Atlas><Texture filename="{}.tex" /><Elements>'.format(self.atlas_name))
            for png in self.imgs_data:
                px, py = float(png.x), float(png.y)
                pw, ph = float(png.width), float(png.height)
                u1 = px/max_w
                u2 = (px+pw)/max_w
                v1 = (max_h-py-ph)/max_h
                v2 = (max_h-py)/max_h
                s = '<Element name="{}.tex" u1="{}" u2="{}" v1="{}" v2="{}"/>'.format(png.png_name.removesuffix('.png'),
                                                                                      u1, u2, v1, v2)
                sb.append(s)
            sb.append('</Elements></Atlas>')

            w.save(join(exportdir, self.atlas_name+'.png'))

            def mk_xml():
                with open(join(exportdir, self.atlas_name+'.xml'), 'w', encoding='utf-8') as f:
                    f.write('\n'.join(sb))
            return mk_xml

    if DST_MOD_TOOL is None:
        print('未设置环境变量 DST_MOD_TOOL，放弃生成.tex文件')
        return

    # 遍历所有的图集文件夹，生成图集
    for atlas_name in os.listdir(ATLAS_DIR):
        atlas_dir_path = join(ATLAS_DIR, atlas_name)
        if os.path.isdir(atlas_dir_path):
            if not atlas_name.isascii():
                print('× 不要用中文命名图集: "images/{}.xml"'.format(atlas_name))
                continue

            atlas = Atlas(atlas_name, atlas_dir_path)
            mk_xml = atlas.merge(EXPORT_DIR)
            compiler_tex(atlas_name+'.tex', atlas_name+'.png')
            os.remove(join(EXPORT_DIR, atlas_name+'.xml'))
            if os.path.isfile(join(EXPORT_DIR, atlas_name+'.png.bck')):
                os.remove(join(EXPORT_DIR, atlas_name+'.png.bck'))
            os.renames(join(EXPORT_DIR, atlas_name+'.png'),
                       join(EXPORT_DIR, atlas_name+'.png.bck'))
            mk_xml()
            print('√ 生成图集: "images/{}.xml"'.format(atlas_name))


if __name__ == "__main__":
    make_atlas()
