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
        with open( os.path.join(self.project_dir, scml_name+'.scml'), 'wb') as f:
            self.root.append(self.entityelem)
            ET.indent(self.root)
            f.write(ET.tostring(self.root))
        

    def __call__(self, animxml_source:str, scml_name:str|None = None):
        pngs = get_pngs(animxml_source)
        for png in pngs:
            self.add_png(png)
            self.mk_default_png(png)
        self.save(scml_name)
            


    


# OneScmlProject(arg2)(arg1)
# 参数1是输入的动画xml文件
# 参数2是输出的文件夹
OneScmlProject(sys.argv[2])(sys.argv[1])
        
    
        
    
    
        
        
            
    
    