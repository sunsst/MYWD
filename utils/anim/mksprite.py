import math
import stat
from tkinter import FALSE
from xml.dom.minidom import Element
import xml.etree.ElementTree as ET
from typing import Callable

class TransformArgs:
    def __init__(self, sx:float=1, ry:float=0, rx:float=0, sy:float=1, tx:float=0, ty:float=0, isinv=False):
        self.sx = sx
        self.ry = ry
        self.rx = rx
        self.sy = sy
        self.tx = tx
        self.ty = ty
        self.isinv = isinv   
         
    def get_angle(self):
        return math.asin(self.rx/sy)
        
    @property
    def inv(self):
        v = 1/(self.sx*self.sy - self.rx*self.ry)
        return TransformArgs(self.sy*v, self.ry*-1*v, self.rx*-1*v, self.sx*v, self.tx*-1, self.ty*-1, not self.isinv)
    
    def __str__(self):
        return '{{{}, {}, {}, {}, {}, {}}}'.format(self.sx, self.ry, self.rx, self.sy, self.tx, self.ty, ', !' if self.isinv else '')
    
class Vec2:
    def __init__(self, x:float, y:float):
        self.x= x
        self.y= y
    
    def add(self, x, y):
        self.x +=x
        self.y+=y
        return self
    
    def cp(self):
        return Vec2(self.x, self.y)

        
    
    def to(self, args:TransformArgs):
        # sx rx tx
        # ry sy ty
        # a b
        # c d
        
        # x
        # y
        if args.isinv:
            self.add(args.tx, args.ty)
            
        x= self.x
        y=self.y
        
        self.x = x*args.sx + y*args.rx
        self.y = x*args.ry + y*args.sy
        
        if not args.isinv:
            self.add(args.tx, args.ty)
        return self
    
    def do(self, f:Callable[[float],float]):
        self.x= f(self.x)
        self.y = f(self.y)
        return self
        
    def __str__(self):
        return '({}, {})'.format(self.x, self.y)
    





def gid(elem):
    return -1 if elem is None else int(elem.get('id'))

def newid(root, elemname):
    return str(gid(root.find('./{}[last()]'.format(elemname)))+1)

def findtime(root, elemname, time):
    if float(time) <=0.001:
        return root.find('./{}[not(@time)]'.format(elemname))
    else:
        return root.find('./{}[@time="{}"]'.format(elemname, time))

def settimeattr(elem, time):
    if float(time)>=0.001:
        elem.set('time', str(time))

def gettimeattr(elem):
    return '0' if elem.get('time') is None else elem.get('time')

class ScmlWriter:
    SCML_XML_STRING = '<?xml version="1.0" encoding="UTF-8"?><spriter_data scml_version="1.0" generator="BrashMonkey Spriter" generator_version="b5"></spriter_data>'
    
    DEFAULT_FRAMERATE = 30
    def __init__(self):
        self.dom = ET.ElementTree(ET.fromstring(self.SCML_XML_STRING))
        self.root = self.dom.getroot()
        self.namespace = set()
    
        
    def add_bank(self, name):
        if name not in self.namespace:
            bank_elem = ET.Element('entity', {
                'id': newid(self.root, 'entity'),
                'name': name
            })
            self.root.append(bank_elem)
            self.namespace.add(name)
    
    def get_bank(self, name) :
        return self.root.find(('./entity[@name="{}"]'.format(name)))
    

    
    def add_anim(self, bank, name, length):
        k = '{}@{}'.format(bank,name)
        if k not in self.namespace:
            bank_elem=self.get_bank(bank)
            anim_elem = ET.Element('animation',{
                'id': newid(bank_elem,'animation'),
                'name': name,
                'length': str(length)
            })
            anim_elem.append(ET.Element('mainline'))
            bank_elem.append(anim_elem)
            self.namespace.add(k)
    
    def get_anim(self, bank, name):
        return self.get_bank(bank).find(('./animation[@name="{}"]'.format(name)))
    
    def get_layer_and_frame(self, bank, anim, layer_name, frame_time):
        anim_elem = self.get_anim(bank, anim)
        timeline_elem = anim_elem.find('./timeline[@name="{}"]'.format(layer_name))
        frame_elem = findtime(anim_elem, 'mainline/key', frame_time)
        if timeline_elem is None:
            timeline_elem = ET.Element('timeline', {
                'id':newid(anim_elem, 'timeline'),
                'name': layer_name
            })
            anim_elem.append(timeline_elem)
        if frame_elem is None:
            frame_elem = ET.Element('key', {
                'id': newid(anim_elem, 'mainline/key'),
            })
            settimeattr(frame_elem, frame_time)
            anim_elem.find('mainline').append(frame_elem)
        return timeline_elem, frame_elem
    
    def add_layer_and_frame(self, bank, anim, layer_name, frame_time, z_index, folderid, fileid, x, y, angle = 0, other_attr:dict={}):
        k='{}@{}@{}@{}'.format(bank, anim, layer_name, frame_time)
        if k in self.namespace:
            return
        timeline_elem, frame_elem = self.get_layer_and_frame(bank, anim, layer_name, frame_time)
        
        key_elem = ET.Element('key', {
            'id': newid(timeline_elem, 'key'),
            'spin': '0'
        })
        settimeattr(key_elem, frame_time)
        obj_elem = ET.Element('object', {
            'folder': str(folderid),
            'file': str(fileid),
            'x': str(x),
            'y':str(y),
            'angle':str(angle)
        })
        for kk,vv in other_attr.items():
            obj_elem.set(kk ,str(vv))
        obj_ref_elem = ET.Element('object_ref', {
            'id': newid(frame_elem, 'object_ref'),
            'timeline': timeline_elem.get('id'),
            'key': key_elem.get('id'),
            'z_index': str(z_index)
        })
        key_elem.append(obj_elem)
        timeline_elem.append(key_elem)
        frame_elem.append(obj_ref_elem)
        self.namespace.add(k)
        
        
        
        
        

            
            
            
class AnimParser:
    def __init__(self, animxml_source, buildxml_source):
        self.scml = ScmlWriter()     
        self.animxml = ET.parse(animxml_source)
        self.buildxml = ET.parse(buildxml_source)
    
        
        
        
            
            
        
        

p= r"T:/新建文件夹 (2)/a.scml"

# sw= ScmlWriter()
# sw.add_bank('asd')
# sw.add_bank('123')
# sw.add_anim('asd', '动画', 123)
# sw.add_anim('asd', 'gg', 123)
# sw.add_layer_and_frame('asd', 'gg', 't1', 6, 99,11,12,1,2,3,{'k':'fdffd'})
# sw.add_layer_and_frame('asd', 'gg', 't1', 88, 99,11,12,1,2,3,{'k':'fdffd'})
# ET.indent(sw.dom)
# sw.dom.write(p)

args= TransformArgs(sx=40,sy=20)

arg2 = TransformArgs(34.641014, -20.000000, 10.000000, 17.320507)

a=Vec2(33,33)
a.to(args)
a.to(arg2)
a.to(arg2.inv)
a.to(args.inv)
print(a)
    
    