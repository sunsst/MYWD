-- 第一层是动画(.scml)文件名 build
-- 第二层是动画分组名 bank
-- 第三层是动画名 anim
-- 不想用的可以不删直接注释掉就行
-- 其他文件你不用动，就动这个文件就行
-- 每次改了动画给图集加了图片，在启动游戏之前就运行一次 "编译资源文件.bat"
MYWD_ANIMS = {
    ["mywd_ghostly_elixirs"]={
        ["mywd_ghostly_elixirs"]={
            "mywd_moon"
        }
    },
    ["ghost_abigail_build"] = {
        ["ghost"] = {
            "idle",
            "run_start",
            "run",
            "run_stop",
            "angry",
            "appear",
            "dissipate",
            "hit",
            "shy",
            "attack_loop",
            "attack_pre",
            "attack_pst",
            "dance",
            "flower_change",
            "idle_custom",
            "idlexxx",
        }
    },
}
