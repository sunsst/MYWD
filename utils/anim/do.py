
from logging import root
import os
import re
from shutil import copyfile
import subprocess
import sys
import zipfile

import os
import sys
import xml.etree.ElementTree as ET


# 默认的贴图文件，大小仅有5x5
with open(os.path.join(os.path.dirname(__file__), 'default-0.png'), 'rb') as f:
    DEFAULT_IMG = f.read()


class OnePNG:
    def __init__(self, symbol, frame) -> None:
        self.symbol = symbol
        self.frame = frame
    
    def __repr__(self) -> str:
        return self.get_dirandfile()
    
    def __hash__(self) -> int:
        return hash(self.uniquekey)
    
    def __eq__(self, value) -> bool:
        return self.uniquekey == value.uniquekey
    
    @property
    def file_name(self):
        return '{}-{}'.format(self.symbol, self.frame)
    
    @property 
    def dir_name(self):
        return self.symbol
    
    @property 
    def file_ext_name(self):
        return self.file_name+'.png'
    
    @property
    def dir_file_name(self):
        return '{}/{}'.format(self.symbol, self.file_name)
    
    @property
    def dir_file_ext_name(self):
        return '{}/{}'.format(self.symbol, self.file_ext_name)
    
    @property
    def uniquekey(self):
        return r'{}#{}'.format(self.symbol, self.frame)
    
    
    
def get_pngs(xmlsource):
    root = ET.parse(xmlsource)
    
    # 贴图查找去重
    pngs = list({OnePNG(symbol=elem.get('name'), frame=elem.get('frame')) for elem in root.findall('.//element')})
    print('共 {} 张贴图'.format(len(pngs)))
    
    # 贴图序号从零补全
    symbol_frames = dict()
    for png in pngs:
        if png.symbol not in symbol_frames:
            symbol_frames[png.symbol] = []
        symbol_frames[png.symbol].append(int(png.frame))
    for symbol, frames in symbol_frames.items():
        frames.sort()
        for i in range(frames[-1]):
            if i not in frames:
                png = OnePNG(symbol=symbol, frame=i)
                pngs.append(png)
                print('添加贴图 {}'.format(png.dir_file_ext_name))
    print('补全后共 {} 张贴图'.format(len(pngs)))
    
    pngs.sort(key=lambda png:int(png.frame))
    
    return pngs

class OneScmlProject:
    FOLDER_STR= '<folder id="{}" name="{}"></folder>'
    FILE_STR= '<file id="{}" name="{}" width="5" height="5" pivot_x="0.5" pivot_y="0.5"/>'
    OBJ_REF_STR = '<object_ref id="{}" name="{}" folder="{}" file="{}" abs_x="0" abs_y="0" abs_pivot_x="0.5" abs_pivot_y="0.5" abs_angle="0" abs_scale_x="1" abs_scale_y="1" abs_a="1" timeline="{}" key="0" z_index="{}"/>'
    TIMELINE_STR = '<timeline id="{}" name="{}"><key id="0" spin="0"> <object folder="{}" file="{}" angle="0"/> </key></timeline>'

    def __init__(self, project_dir):
        self.project_dir = project_dir
        os.makedirs(project_dir, exist_ok=True)
        
        
        self.root = ET.fromstring('<?xml version="1.0" encoding="UTF-8"?><spriter_data scml_version="1.0" generator="BrashMonkey Spriter" generator_version="b5"></spriter_data>')
        self.entityelem = ET.fromstring('<entity id="0" name="entity_000"><animation id="0" name="NewAnimation" length="1000"><mainline><key id="0"> </key></mainline></animation></entity>')
        self.mainline= self.entityelem.find('./animation/mainline/key')
        self.animation= self.entityelem.find('./animation')
        self.r = ET.ElementTree(self.root)
        self.root.append(self.entityelem)
        
        self.folder_id = -1
        self.obj_id = -1

    # 添加默认贴图实体文件
    def mk_default_png(self, png:OnePNG):
        os.makedirs(os.path.join(self.project_dir, png.dir_name), exist_ok=True)
        with open(os.path.join(self.project_dir, png.dir_file_ext_name), 'wb') as f:
            f.write(DEFAULT_IMG)

    # 添加一张图片到scml中
    def add_png(self, png:OnePNG):
        folder_elem = self.root.find('./folder[@name="{}"]'.format(png.dir_name))
        if folder_elem is None:
            self.folder_id+=1
            folder_elem = ET.fromstring(self.FOLDER_STR.format(self.folder_id, png.dir_name))
            self.root.append(folder_elem)
            
        self.obj_id+=1
        obj_id = self.obj_id
        folder_id = folder_elem.get('id')
        file_elem = ET.fromstring(self.FILE_STR.format(png.frame, png.dir_file_ext_name))
        folder_elem.append(file_elem)
        
        labelname = '{}-{}'.format(png.symbol,png.frame)
        self.mainline.append(ET.fromstring(self.OBJ_REF_STR.format(obj_id, labelname, folder_id, png.frame, obj_id, obj_id)))
        self.animation.append(ET.fromstring(self.TIMELINE_STR.format(obj_id, labelname, folder_id, png.frame)))
        
    
    # 保存
    def save(self, scml_name:str|None = None):
        if scml_name is None:
            scml_name = os.path.split(self.project_dir)[1]
        self.root.append(self.entityelem)
        ET.indent(self.root)
        self.r.write(os.path.join(self.project_dir, scml_name+'.scml'))
            
        

    def __call__(self, animxml_source:str, scml_name:str|None = None):
        pngs = get_pngs(animxml_source)
        for png in pngs:
            self.add_png(png)
            self.mk_default_png(png)
        self.save(scml_name)
            



class CompleteProject:
    def __init__(self, scml_source:str):
        self.scml_path = scml_source
        self.dom = ET.parse(self.scml_path)
        self.root = self.dom.getroot()
    
    LAYER_FORMAT = '{}_{:0>3d}'
    
    def check_layername(self, animxml_source:str):
        animxml_et = ET.parse(animxml_source)
        # 搜索每个动画
        for else_anim in animxml_et.findall('anim'):
            bank_name = else_anim.get('root')
            anim_name = else_anim.get('name')
            frames= else_anim.findall('frame')
            self_anim = self.root.find('entity[@name="{}"]/animation[@name="{}"]'.format(bank_name, anim_name))
            self_frames = self_anim.findall('./mainline/key'.format(bank_name, anim_name))
            
            if len(self_frames)-1!=len(frames):
                raise Exception('动画 @{}/{} 的帧数非预期 {}+1!={}'.format(bank_name, anim_name, len(frames), len(self_frames)))
            
            # 用时间线的id做索引
            timelinemap={}
            # 用layername做索引
            namemap = {}
            
            # 搜索每一帧
            for i, self_frame in enumerate(self_frames):
                else_frame = frames[i if i<len(frames) else i-1]
                self_elems = self_frame.findall('object_ref')
                else_elems = else_frame.findall('element')
                
                if len(self_elems)!=len(else_elems):
                    raise Exception('帧 @{}/{}:{} 的元素个数不一致 {}!={}'.format(len(self_elems), len(else_elems)))
                
                # 搜索每一个元素
                for i, self_obj_elem in enumerate(self_elems):
                    else_elem = else_elems[i]
                    layer_name = else_elem.get('layername')
                    self_timeline_id = self_obj_elem.get('timeline')
                    
                    if self_timeline_id not in timelinemap:
                        if layer_name not in namemap:
                            namemap[layer_name] = -1
                        namemap[layer_name]+=1
                        if namemap[layer_name]==0:
                            layer_name_unique = layer_name
                        else:
                            layer_name_unique = self.LAYER_FORMAT.format(layer_name, namemap[layer_name])
                        timelinemap[self_timeline_id] = (layer_name, layer_name_unique)
                        
                        self_anim.find('./timeline[@id="{}"]'.format(self_timeline_id)).set('name', layer_name_unique)
                    self_obj_elem.set('name', layer_name)
        
    
    @staticmethod
    def cpfile(src:str, dst:str):
        with open(src, 'rb') as srcf:
            with open(dst, 'wb') as dstf:
                dstf.write(srcf.read())
    @staticmethod
    def gid(elem):
        return -1 if elem is None else int(elem.get('id'))
    @staticmethod
    def newid(root, elemname):
        return str(CompleteProject.gid(root.find('./{}[last()]'.format(elemname)))+1)
    
    def mk_file(self, folder, file):
        dir_elem =  self.root.find('folder[@name="{}"]'.format(folder))
        if dir_elem is None:
            dir_elem = ET.Element('folder',{
                'id': self.newid(self.root, 'folder'),
                'name': folder
            })
            self.root.append(dir_elem)
        file_elem = dir_elem.find('file[@name="{}"]'.format(file))
        if file_elem is None:
            file_elem = ET.Element('file', {
                'id': self.newid(self.root, 'file'),
                'name': file
            })
            dir_elem.append(file_elem)
        return file_elem
        
       
    def merge(self, elsescml_source:str):
        else_dir_path = os.path.dirname(elsescml_source)
        self_dir_path = os.path.dirname(self.scml_path)
        else_scml_dom = ET.parse(elsescml_source)
        else_scml = else_scml_dom.getroot()
        for file_elem in else_scml.findall('folder/file'):
            file_path = file_elem.get("name")
            self_file_path = os.path.join(self_dir_path, file_path)
            else_file_path = os.path.join(else_dir_path, file_path)
            
            e =self.root.find('folder/file[@name="{}"]'.format(file_path))
            if e is None:
                print('警告：复制了一个新文件 {}'.format(else_file_path))
                os.makedirs(os.path.dirname(self_file_path), exist_ok=True)
                e=self.mk_file(os.path.dirname(file_path), file_path)
            self.cpfile(else_file_path,self_file_path)
            e.set('width', file_elem.get('width'))
            e.set('height', file_elem.get('height'))
            e.set('pivot_x', file_elem.get('pivot_x'))
            e.set('pivot_y', file_elem.get('pivot_y'))
            
    
    # 保存
    def save(self, backup_suffix=None):
        copyfile(self.scml_path, self.scml_path+backup_suffix)
        ET.indent(self.dom)
        self.dom.write(self.scml_path)
            
                        
    
                        
                        
                        
    
class Tools:
    def __init__(self, *, dsttool_dir, ktool_dir, work_dir, scml_name):
        self.dsttool_dir = dsttool_dir
        self.ktool_dir = ktool_dir
        self.scml_path = os.path.join(dsttool_dir, './mod_tools/scml.exe')
        self.work_dir = work_dir
        self.scml_name = scml_name
        self.tmp_dir = os.path.join(self.work_dir, 'tmp')
        os.makedirs(self.tmp_dir, exist_ok=True)
    
    
    @staticmethod
    def cmd(*args, cwd=None):
        a = [os.path.normpath(arg) for arg in args]
        return subprocess.run(a,stdout= sys.stdout,cwd=cwd, env= os.environ.copy())
    
    
    def dstpyexe(self, py, *args):
        return self.cmd(os.path.join(self.dsttool_dir, './mod_tools/buildtools/windows/Python27/python.exe'), py, *args)
    

    
    @property
    def animbin(self):
        return os.path.join(self.work_dir, 'anim.bin')

    @property
    def animxml(self):
        return self.animbin+'.xml'
    
    @property
    def atdir(self):
        return os.path.dirname(__file__)
    
    def rebuildpy(self, animbin):
        return self.dstpyexe(os.path.join(self.atdir, 'rebuild.py'), animbin)
    
    @property
    def complete_anim_dir(self):
        return os.path.join(self.tmp_dir, self.scml_name)
    
    def allpng(self, animxml_path, project_dir):
        OneScmlProject(project_dir)(animxml_path)
    
    @property
    def complete_anim_scml(self):
        return os.path.join(self.complete_anim_dir, os.path.split(self.complete_anim_dir)[1]+'.scml')
    
    
    @property
    def anim_out_basedir(self):
        return self.tmp_dir
        
    def scmlexe(self, scml_path, anim_out_basedir):
        return self.cmd(os.path.join(self.dsttool_dir, './mod_tools/scml.exe'),
               scml_path,
               anim_out_basedir, cwd=os.path.join(self.dsttool_dir, 'mod_tools'))  
        

    @property
    def complete_res_dir(self):
        return os.path.join(self.anim_out_basedir, 'anim')
    
    @property
    def complete_res_zip(self):
        return os.path.join(self.complete_res_dir,self.scml_name+ '.zip')
    
    def unzip(self, zip_file, out_dir):
        with zipfile.ZipFile(zip_file) as z:
            z.extractall(out_dir)
    
    
    @property
    def complete_res_build(self):
        return os.path.join(self.complete_res_dir, 'build.bin')
    
    
    def kraneexe(self, animbin, buildbin, outdir):
        self.cmd(os.path.join(self.ktool_dir, 'krane.exe'), animbin, buildbin, '', outdir)
    
    @property
    def anim_scml_dir(self):
        return os.path.join(self.work_dir, self.scml_name)
    
    @property
    def anim_scml(self):
        return os.path.join(self.anim_scml_dir, self.scml_name+'.scml')
        
    def rename_layername(self, anim_scml, animxml):
        if not os.path.exists(anim_scml+'.layerbck'):
            cp= CompleteProject(anim_scml)
            cp.check_layername(animxml)
            cp.save('.layerbck')
    
    def merge(self, anim_scml, else_scml):
        cp = CompleteProject(anim_scml)
        cp.merge(else_scml)
        cp.save('.b')
    
    def __call__(self, merge_file=None, build=False):
        if merge_file is not  None:
            self.merge(self.anim_scml, merge_file)
        elif build:
            self.rebuildpy(self.animbin)
            self.allpng(self.animxml, self.complete_anim_dir)
            self.scmlexe(self.complete_anim_scml, self.anim_out_basedir)
            self.unzip(self.complete_res_zip, self.complete_res_dir)
            self.kraneexe(self.animbin, self.complete_res_build, self.anim_scml_dir)
            self.rename_layername(self.anim_scml, self.animxml)
        

t=Tools(dsttool_dir="D:/@apps/@games/SteamLibrary/steamapps/common/Don't Starve Mod Tools",
    ktool_dir="T:/ktools",
    work_dir='T:/workd',
    scml_name='test')

t(build=True)
t(merge_file="T:/新建文件夹/zzzz/wendy.scml")

        
        
    
    
    
        
        

        
