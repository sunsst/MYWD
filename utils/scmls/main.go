package main

import (
	"errors"
	"io"
	"os"
	"path/filepath"
	"regexp"
	"strconv"

	"github.com/beevik/etree"
)

const ENTITYPATH = "/spriter_data/entity"
const FOLDERPATH = "/spriter_data/folder"
const FILEPATH = FOLDERPATH + "/file"
const ANIMPATH = ENTITYPATH + "/animation"
const OBJPATH = ANIMPATH + "/timeline/key/object"

func atoi(n string) int {
	d, err := strconv.Atoi(n)
	if err != nil {
		panic(err)
	}
	return d
}

func MakeDomFromFile(fpath string) (*ScmlFile, error) {
	var sf ScmlFile
	sf.dom = etree.NewDocument()
	sf.fpath = filepath.Clean(fpath)
	return &sf, sf.dom.ReadFromFile(fpath)
}

type ScmlFile struct {
	dom     *etree.Document
	fpath   string
	fmap    map[string][]string
	fnewmap map[string][]string
	elemMap map[string]*etree.Element
	i       int

	idmap map[string][2]string
}

func (sf *ScmlFile) GetLastId(elemPath string) int {
	var t = sf.dom.FindElements(elemPath)
	v := t[len(t)-1].SelectAttr("id")
	if v != nil {
		return atoi(v.Value)
	} else {
		return 0
	}
}

func (sf *ScmlFile) AddID(elemPath string, n int) {
	sf.AddAttr(elemPath, "id", n)
}
func (sf *ScmlFile) AddAttr(elemPath string, attr string, n int) {
	for _, elem := range sf.dom.FindElements(elemPath) {
		id := elem.SelectAttr(attr)
		id.Value = strconv.Itoa(atoi(id.Value) + n)
	}
}

func (sf *ScmlFile) Merge(elsesf *ScmlFile) {
	folder_count := sf.GetLastId(FOLDERPATH) + 1
	anim_count := sf.GetLastId(ANIMPATH) + 1
	elsesf.AddID(FOLDERPATH, folder_count)
	elsesf.AddID(ANIMPATH, anim_count)
	elsesf.AddAttr(OBJPATH, "folder", folder_count)

	entity := sf.dom.FindElement(ENTITYPATH)

	for _, e := range elsesf.dom.FindElements(FOLDERPATH) {
		entity.Parent().InsertChildAt(entity.Index(), e)
	}
	for _, e := range elsesf.dom.FindElements(ANIMPATH) {
		entity.AddChild(e)
	}
}

var reg = regexp.MustCompile(`(.+?)/(.+?)(?:[-_]([0-9]+))?.png`)

func (sf *ScmlFile) CheckFile(elem *etree.Element) {
	res := reg.FindStringSubmatch(elem.SelectAttr("name").Value)
	if res == nil {
		panic(errors.New("无法解析"))
	}
	entityElem := sf.dom.FindElement(ENTITYPATH)

	fname := res[2]
	if _, ok := sf.fmap[fname]; !ok {
		sf.fmap[fname] = make([]string, 0)
		sf.fnewmap[fname] = make([]string, 0)
		telem := sf.dom.CreateElement("folder")

		telem.CreateAttr("id", strconv.Itoa(sf.i))
		telem.CreateAttr("name", fname)

		entityElem.Parent().InsertChildAt(entityElem.Index(), telem)
		sf.elemMap[fname] = telem
		sf.i++
	}

	newid := [2]string{
		sf.elemMap[fname].SelectAttr("id").Value,
		strconv.Itoa(len(sf.elemMap[fname].Child)),
	}
	sf.idmap[elem.Parent().SelectAttr("id").Value+"√"+elem.SelectAttr("id").Value] = newid

	if len(elem.Parent().ChildElements()) == 1 {
		elem.Parent().Parent().RemoveChildAt(elem.Parent().Index())
	}

	newname := fname + "/" + fname + "-" + strconv.Itoa(len(sf.fmap[fname])+1) + ".png"
	sf.fnewmap[fname] = append(sf.fnewmap[fname], newname)
	elem.SelectAttr("id").Value = newid[1]
	elem.SelectAttr("name").Value = newname

	sf.fmap[fname] = append(sf.fmap[fname], res[0])
	sf.elemMap[fname].AddChild(elem)

}

func copyFile(dst string, src string) (err error) {
	dstf, err := os.Create(dst)
	if err != nil {
		return
	}
	defer dstf.Close()

	srcf, err := os.Open(src)
	if err != nil {
		return
	}
	defer srcf.Close()

	_, err = io.Copy(dstf, srcf)
	return
}

func (sf *ScmlFile) CheckFiles() (err error) {
	sf.fmap = map[string][]string{}
	sf.elemMap = make(map[string]*etree.Element)
	sf.fnewmap = map[string][]string{}
	sf.idmap = map[string][2]string{}
	sf.i = 0

	for _, f := range sf.dom.FindElements(FILEPATH) {
		sf.CheckFile(f)
	}

	dir_root := filepath.Dir(sf.fpath)
	dir_ok := filepath.Join(dir_root, "正确的文件夹")
	for dir_name, files := range sf.fmap {
		sub_dir := filepath.Join(dir_ok, dir_name)
		os.MkdirAll(sub_dir, 0666)
		for i, fp := range files {
			err := copyFile(filepath.Join(dir_ok, sf.fnewmap[dir_name][i]), filepath.Join(dir_root, fp))
			if err != nil {
				return err
			}
		}
	}

	for _, e := range sf.dom.FindElements(OBJPATH) {
		a1 := e.SelectAttr("folder")
		a2 := e.SelectAttr("file")
		newid := sf.idmap[a1.Value+"√"+a2.Value]
		a1.Value = newid[0]
		a2.Value = newid[1]
	}
	return
}

func (sf *ScmlFile) Output() error {
	os.MkdirAll(filepath.Join(filepath.Dir(sf.fpath), "正确的文件夹"), 0666)
	return sf.dom.WriteToFile(filepath.Join(filepath.Dir(sf.fpath), "正确的文件夹", filepath.Base(sf.fpath)))
}

func main() {
	// var a, err = MakeDomFromFile(`T:\新建文件夹\mywd_abigail\mywd_abigail.scml`)
	// if err != nil {
	// 	panic(err)
	// }
	// err = a.CheckFiles()
	// if err != nil {
	// 	panic(err)
	// }

	// err = a.Output()
	// if err != nil {
	// 	panic(err)
	// }
	// b, err := MakeDomFromFile(`T:\ktools-4.4.4\zzzz\ghost_abigail_build.scml`)
	// if err != nil {
	// 	panic(err)
	// }
	// a.Merge(b)
	// err = a.Output()
	// if err != nil {
	// 	panic(err)
	// }
}
