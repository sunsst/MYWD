# 工具库使用方法

## pngs
默认情况下复制pngs.exe到图集目录然后执行，会在当前目录生成一个 `atlas` 文件夹输出当前文件夹下png拼接图片以及xml文件。
可以在exe文件同目录下新建 `pngs.conf.json` 然后仿照默认配置。

``` json
{
    "atlas": [
        "."
    ],
    "output": "../atlas"
}
```