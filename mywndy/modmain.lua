Assets = {
    Asset("ATLAS", "images/wendy_skilltree_bg.xml"),
    Asset("ATLAS", "images/my_icon.xml")
}

modimport("languages/chs")
modimport("modscripts/skilltree_mywd")

print("MYWD:!!", Assets)
for index, value in ipairs(Assets) do
    print("MYWD!!:", value)
end
