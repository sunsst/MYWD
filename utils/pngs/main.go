package main

import (
	"encoding/json"
	"fmt"
	"image"
	"image/draw"
	"image/png"
	"os"
	"path/filepath"
	"sort"
	"strings"
)

const DISTANCE = 10
const GROW = 512

var BASEDIR = filepath.Dir(os.Args[0])
var CONFP = filepath.Join(BASEDIR, "pngs.conf.json")

type psize struct {
	At     image.Point
	Name   string
	Width  int
	Height int
}

type psizearr []*psize

func (arr psizearr) Len() int {
	return len(arr)
}

func (arr psizearr) Less(i, j int) bool {
	return arr[i].Width*arr[i].Height < arr[j].Width*arr[i].Height
}

func (arr psizearr) Swap(i, j int) {
	arr[i], arr[j] = arr[j], arr[i]
}

func readPng(p string) (mg image.Image, err error) {
	f, err := os.Open(p)
	if err != nil {
		return
	}
	defer f.Close()

	mg, err = png.Decode(f)
	if err != nil {
		return
	}
	return
}

type PngFS struct {
	pngs map[string]psizearr
}

func (pf *PngFS) GetFiles(p string) (err error) {
	fs, err := os.ReadDir(p)
	if err != nil {
		return
	}
	name, err := filepath.Abs(p)
	if err != nil {
		return
	}

	if pf.pngs[name] != nil {
		return
	}

	pfs := make([]*psize, 0)
	i := 0
	for _, f := range fs {
		if strings.ToLower(filepath.Ext(f.Name())) != ".png" {
			continue
		}
		pfs = append(pfs, &psize{
			Name: filepath.Base(f.Name()),
		})
		i++
	}

	pf.pngs[name] = pfs
	return
}

func (pf *PngFS) GetSize() {
	for p, arr := range pf.pngs {
		for _, psize := range arr {
			var mg image.Image
			mg, err := readPng(filepath.Join(p, psize.Name))
			if err != nil {
				delete(pf.pngs, p)
				fmt.Printf("× 校验图集[%s]:%v", p, err)
				return
			}
			psize.Width = mg.Bounds().Dx()
			psize.Height = mg.Bounds().Dy()
		}
		//
	}
}

func (pf *PngFS) SortFS() {
	for _, arr := range pf.pngs {
		sort.Sort(arr)
	}
}

func merge(atlaspath string, pngs psizearr) (mg *image.RGBA64, err error) {
	mg = image.NewRGBA64(image.Rect(0, 0, GROW, GROW))

	at := image.Point{DISTANCE, DISTANCE}
	nextrowat := image.Point{DISTANCE, DISTANCE}

	var tsize func(rct image.Rectangle, src *psize) image.Rectangle
	tsize = func(rct image.Rectangle, src *psize) image.Rectangle {
		ok := true

		// 向下扩大
		if at.Y+src.Height >= rct.Max.Y {
			rct.Max.Y += GROW
			ok = false
		}

		// 先换行再扩大
		if at.X+src.Width >= rct.Max.X {
			if at.X == DISTANCE {
				rct.Max.X += GROW
			} else {
				at = nextrowat
				nextrowat = image.Point{DISTANCE, DISTANCE}
			}
			ok = false
		}
		if !ok {
			return tsize(rct, src)
		} else {
			// 调整下一行的位置
			if at.Y+src.Height+DISTANCE > nextrowat.Y {
				nextrowat.Y = at.Y + src.Height + DISTANCE
			}
			return rct
		}
	}

	for _, psize := range pngs {
		newrct := tsize(mg.Rect, psize)
		if !newrct.Eq(mg.Rect) {
			newimg := image.NewRGBA64(newrct)
			draw.Draw(newimg, newimg.Rect, mg, mg.Rect.Min, draw.Src)
			mg = newimg
		}

		var m image.Image
		m, err = readPng(filepath.Join(atlaspath, psize.Name))
		if err != nil {
			return
		}
		draw.Draw(mg, image.Rectangle{
			at,
			mg.Rect.Max,
		}, m, image.Point{0, 0}, draw.Src)
		psize.At = at
		at.X += DISTANCE + psize.Width
	}
	return
}
func makexml(atlasname string, pngs psizearr, rect image.Rectangle) *strings.Builder {
	var sb strings.Builder
	sb.WriteString(`<Atlas><Texture filename="` + atlasname + `.tex" /><Elements>`)
	defer sb.WriteString(`</Elements></Atlas>`)

	for _, png := range pngs {
		var s = fmt.Sprintf(`<Element name="%s" u1="%.12f" u2="%.12f" v1="%.12f" v2="%.12f"/>`,
			png.Name[:len(png.Name)-4]+".tex",
			float64(png.At.X)/float64(rect.Dx()),
			float64(png.At.X+png.Width)/float64(rect.Dx()),
			float64(rect.Dy()-png.At.Y-png.Height)/float64(rect.Dy()),
			float64(rect.Dy()-png.At.Y)/float64(rect.Dy()),
		)
		sb.WriteString(s)
	}
	return &sb
}
func (pf *PngFS) Merge(outdir string) {
	for p, arr := range pf.pngs {
		atlasName := filepath.Base(p)
		pngoutp := filepath.Join(outdir, atlasName+".png")
		xmloutp := filepath.Join(outdir, atlasName+".xml")

		mg, err := merge(p, arr)
		if err != nil {
			fmt.Printf("× 拼接图集[%s]: %v\n", pngoutp, err)
		}

		sb := makexml(atlasName, arr, mg.Rect)

		f, err := os.Create(pngoutp)
		if err != nil {
			fmt.Printf("× 生成图集[%s]: %v\n", pngoutp, err)
			continue
		}
		defer f.Close()

		xmlf, err := os.Create(xmloutp)
		if err != nil {
			fmt.Printf("× 生成图集XML[%s]: %v\n", xmloutp, err)
			continue
		}
		defer xmlf.Close()

		err = png.Encode(f, mg)
		if err != nil {
			fmt.Printf("× 编码图集[%s]: %v\n", pngoutp, err)
			continue
		}
		fmt.Printf("√ 导出图集[%s]\n", pngoutp)

		_, err = xmlf.WriteString(sb.String())
		if err != nil {
			fmt.Printf("× 写入图集XML[%s]: %v\n", xmloutp, err)
			continue
		}
		fmt.Printf("√ 导出图集XML[%s]\n", xmloutp)
	}
}

type config struct {
	Atlas  []string `json:"atlas"`
	Output string   `json:"output"`
}

func (c *config) Resolve() {
	var f = func(p string) string {
		if !filepath.IsAbs(p) {
			return filepath.Join(BASEDIR, p)
		} else {
			return p
		}
	}
	c.Output = f(c.Output)
	for i, ap := range c.Atlas {
		c.Atlas[i] = f(ap)
	}
}

func ReadConfig() *config {
	var confp = filepath.Join(BASEDIR, "pngs.conf.json")

	d, err := os.ReadFile(confp)
	if err != nil {
		return nil
	}
	var conf config
	err = json.Unmarshal(d, &conf)
	if err != nil {
		return nil
	}
	return &conf
}

var defaultConfig = config{
	Atlas:  []string{"."},
	Output: "./atlas",
}

var debugConfig = config{
	Atlas:  []string{"../../doc/img", "../../MYWD/images/icon"},
	Output: "../atlas",
}

func main() {
	conf := ReadConfig()
	if conf == nil {
		if os.Getenv("DEBUG") != "" {
			conf = &defaultConfig
		} else {
			conf = &debugConfig
		}
	}
	conf.Resolve()

	if err := os.MkdirAll(conf.Output, 0666); err != nil {
		fmt.Printf("× 导出文件夹不存在且无法创建[%s]", conf.Output)
		return
	}

	var pfs PngFS = PngFS{
		pngs: make(map[string]psizearr),
	}
	for _, p := range conf.Atlas {
		err := pfs.GetFiles(p)
		if err != nil {
			fmt.Printf("× 图片搜索[%s]: %v", p, err)
			continue
		}

	}

	pfs.GetSize()
	pfs.SortFS()
	pfs.Merge(conf.Output)
}
