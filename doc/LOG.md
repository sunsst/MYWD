## 2024年12月9日

### 技能树背景图
素材中的大小是851x755像素。游戏中存在resize代码调整到600x460，但实际大小似乎并没有变化。
背景图必须提前注册：`self.bg_tree = self.root:AddChild(Image(GetSkilltreeBG(self.target.."_background.tex"), self.target.."_background.tex"))`
![](img\skilltree2.png)
``` xml
<Atlas>
    <Texture filename="skilltree2.tex" />
    <Elements>
        <Element name="wormwood_background.tex" u1="0.416259765625" u2="0.831787109375"
            v1="0.631103515625" v2="0.999755859375" />
        <Element name="background.tex" u1="0.000244140625" u2="0.413330078125" v1="0.267822265625"
            v2="0.630615234375" />
        <Element name="wilson_background.tex" u1="0.000244140625" u2="0.415771484375"
            v1="0.631103515625" v2="0.999755859375" />
        <!-- u1v1 u2v2 分别对应图片的左下角与右上角坐标，数值是比率，原点在左下角 -->
    </Elements>
</Atlas>
```


### 技能树图标
素材中的大小是64x64像素。在游戏面板其宽高为30x30，该单位并非像素不会受窗口放大影响。
技能点按钮的坐标系原点在背景图中心点偏下的位置。
以威尔逊为参考：
- 一级火炬寿命的横坐标靠左在 x-214。
- 月光创新者的横坐标最靠右在 x228。
- 火炬两字靠上在 y206。
- 靠下的位置可以直接使用 y0，刚好位于说明框的上方一点点。
- 背景图片的中心点约在 x0y75 的位置
- 位于原点图标向上移动75点，可使按钮底部可差不多对齐背景图片的中心横轴
- 位于原点图标向下移动155点，可使按钮底部可差不多对齐背景图片的底部

前面提到的resize 600x460，其高度刚好等于(155+75)*2，所以可以判定设置的位置采用是这个宽高，所以在ps上：
1. 以 851x755 画布绘制背景图。
2. 缩小到 600x460 像素，用于摆放按钮。
2. 使用矩形模拟按钮，按钮的大小调整到 30 像素，将按钮的中点设置在中下侧。
3. 在x300、y230、y305的位置分别放上一条参考线，其中交叉点靠上的是画布中心靠下的是面板的中心。
4. 将按钮摆好后，选择按钮的中心到中下，并记录xy坐标。
5. 将记录的坐标x-300,305-y

![](img\捕获.png)
![](img\捕获1.png)
![](img\skilltree_icons.png)

## 2024年12月10日

### 技能树数据结构解析
``` lua
local ORDERS =
{
    { "torch",      { -214 + 18, 176 + 30 } },
    { "alchemy",    { -62, 176 + 30 } },
    { "beard",      { 66 + 18, 176 + 30 } },
    { "allegiance", { 204, 176 + 30 } },
}
```
这是技能树每条路线/每个体系的数据。

第一个字段是这个体系的标识符。
第二个字段是这个体系的标题位置。

技能树体系不会对技能树按钮的摆放产生任何影响。
技能树体系的实际显示效果只有那个标题，下面的方框是背景图的效果。
体系标题的字符串必须注册在指定位置：`panel.title   = self:AddChild(Text(HEADERFONT, 18, STRINGS.SKILLTREE.PANELS[string.upper(panel.name)],
        UICOLOURS.GOLD))`。

***如果某个体系没有被按钮引用会引发异常，报错信息：[string "scripts/widgets/redux/skilltreebuilder.lua"]:---: attempt to index local 'panel' (a nil value)***


``` lua
local skills =
{
    wilson_alchemy_1 = {
        title = STRINGS.SKILLTREE.WILSON.WILSON_ALCHEMY_1_TITLE,
        desc = STRINGS.SKILLTREE.WILSON.WILSON_ALCHEMY_1_DESC,
        icon = "wilson_alchemy_1",
        pos = { -62, 176 },
        --pos = {1,0},
        group = "alchemy",
        tags = { "alchemy" },
        root = true,
        connects = {
            "wilson_alchemy_2",
            "wilson_alchemy_3",
            "wilson_alchemy_4",
        },
    },
    wilson_allegiance_lock_1 = {
        desc = STRINGS.SKILLTREE.WILSON.WILSON_ALLEGIANCE_LOCK_1_DESC,
        pos = { 204 + 2, 176 },
        --pos = {0.5,0},
        group = "allegiance",
        tags = { "allegiance", "lock" },
        root = true,
        lock_open = function(prefabname, activatedskills, readonly)
            return SkillTreeFns.CountSkills(prefabname, activatedskills) >= 12
        end,
        connects = {
            "wilson_allegiance_shadow",
        },
    },
}
```
这是技能树每个技能/每个按钮的数据。

每个按钮的键是它的标识符。
如果是第一个按钮需要设置 `root` 字段。
锁按钮需要设置一个判断方法。
在字段 `connects` 设置下一个按钮的标识符。
在字段 `group` 设置体系标识符。
在字段 `tags` 设置体系标识符，如果是特殊按钮需要额外标签，比如锁按钮需要`"lock"`。


![](img\捕获2.PNG)

### 代码笔记
#### 资源
使用 `Asset(type, path)` 包装资源路径。类型支持`"ATLAS"`、`ANIM`。在modmain.lua文件声明`Assets`引入资源。


### 组件与预制件

工厂(预制件 `Prefab`) 对象(实体 `Entity`) 装饰器(组件 `Component`)。
部分组件虽然暴露给lua使用但其在底层用c代码实现，所以无法查看源码。
用了 `local` 函数少折腾，浪费时间，老老实实自己写吧。

在modmain.lua文件声明`PrefabFiles`引入预制件路径。

添加组件：`inst:AddComponent("xxx")`
移除组件：`inst:RemoveComponent("xxx")`
判断是否有组件：`inst.components.xxx == nil`

``` lua
-- 比较常用的初始化方式
local name = "ghostlyelixir_dream"

local assets = {
    Asset("ANIM", "anim/ghostlyelixir_dream.zip"),
    Asset("IMAGE", "images/ghostlyelixir_dream.tex"),
    Asset("ATLAS", "images/ghostlyelixir_dream.xml")
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBuild(name)
    inst.AnimState:SetBank(name)
    inst.AnimState:PlayAnimation("default", true)

    MakeInventoryFloatable(inst)


    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")
    inst:AddComponent("stackable")
    inst.components.inventoryitem.atlasname = "images/ghostlyelixir_dream.xml"

    inst:AddComponent("ghostlyelixir")

    return inst
end

return Prefab(name, fn, assets, prefabs)
```



### 标签
查找标签:`inst:HasTag("tag")`
添加标签:`inst:AddTag("tag")`

``` lua
"abigail"
-- 阿比盖尔的专属标签
```

### 记录
``` lua
"elixir_buff"
-- 灵体草药buff的标志
```
