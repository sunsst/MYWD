TUNING.MYWD = {
    GHOSTLYELIXIR_MOON_DAMAGE = 9.99,
    GHOSTLYELIXIR_MOON_DEFENSE = 999,
    GHOSTLYELIXIR_MOON_DURATION = TUNING.TOTAL_DAY_TIME,



    -- ABIGAIL_MOON_IMPACT_ATTACK = 9.99,
    -- ABIGAIL_MOON_IMPACT_SPEED = 20,
    ABIGAIL_MOON_IMPACT_DISTANCE = 8,
    ABIGAIL_MOON_IMPACT_DURATUION = 0.5,
    ABIGAIL_MOON_IMPACT_GUARD_RANGE = 16,
    ABIGAIL_MOON_IMPACT_SLEEP = 1.5,
    ABIGAIL_MOON_IMPACT_WALK_TIMEOUT = 0.01,
}


--------------------------------------------------------------------------------------------------------------------
-- MYWD:下面代码复制粘贴自测试服代码不要动，等更新了可以删了
local total_day_time = TUNING.TOTAL_DAY_TIME
local seg_time = TUNING.SEG_TIME
local wilson_health = TUNING.WILSON_HEALTH

-- Wendy Skill Tree
TUNING.ABIGAIL_GESTALT_DAMAGE =
{
    day = 100,
    dusk = 150,
    night = 250,
}

TUNING.ABIGAIL_SHADOW_PLANAR_DAMAGE =
{
    day = 15,
    dusk = 20,
    night = 40,
}

TUNING.ABIGAIL_GESTALT_HIDE_THRESHOLD = 0.25

TUNING.WENDYSKILL_COMMAND_COOLDOWN = 4
TUNING.WENDYSKILL_ESCAPE_TIME = 1.5
TUNING.WENDYSKILL_DASHATTACK_VELOCITY = 14.0
TUNING.WENDYSKILL_DASHATTACK_HITRATE = 0.5

TUNING.WENDYSKILL_SMALLGHOST_EXTRACHANCE = 0.10
TUNING.WENDYSKILL_GRAVESTONE_DECORATECOUNT = 3
TUNING.WENDYSKILL_GRAVESTONE_DECORATETIME = 6 * total_day_time
TUNING.WENDYSKILL_GRAVESTONE_GHOSTCOUNT = 4
TUNING.WENDYSKILL_GRAVESTONE_EVILFLOWERCOUNT = 3
TUNING.WENDYSKILL_GRAVEGHOST_DEADTIME = total_day_time
TUNING.WENDYSKILL_GRAVEGHOST_AURARADIUS = 2.5

TUNING.WENDYSKILL_SISTURN_SANITY_MODIFYER = 0.75
TUNING.WENDY_SISTURN_PETAL_PRESRVE = 0.5

TUNING.GHOSTLYELIXIR_PLAYER_SLOWREGEN_HEALING = 1
TUNING.GHOSTLYELIXIR_PLAYER_SLOWREGEN_TICK_TIME = 1
TUNING.GHOSTLYELIXIR_PLAYER_SLOWREGEN_DURATION = 20 -- 20 hp

TUNING.GHOSTLYELIXIR_PLAYER_FASTREGEN_HEALING = 5
TUNING.GHOSTLYELIXIR_PLAYER_FASTREGEN_TICK_TIME = 1
TUNING.GHOSTLYELIXIR_PLAYER_FASTREGEN_DURATION = 20 -- 100 hp

TUNING.GHOSTLYELIXIR_PLAYER_DAMAGE_DURATION = total_day_time

TUNING.GHOSTLYELIXIR_PLAYER_SPEED_LOCO_MULT = 1.75
TUNING.GHOSTLYELIXIR_PLAYER_SPEED_DURATION = total_day_time
TUNING.GHOSTLYELIXIR_PLAYER_SPEED_PLAYER_GHOST_DURATION = 3

TUNING.GHOSTLYELIXIR_PLAYER_SHIELD_DURATION = seg_time * 4
TUNING.GHOSTLYELIXIR_PLAYER_SHIELD_REDUCTION = 50

TUNING.GHOSTLYELIXIR_PLAYER_RETALIATION_DAMAGE = 20
TUNING.GHOSTLYELIXIR_PLAYER_RETALIATION_DURATION = total_day_time

TUNING.GHOSTLYELIXIR_PLAYER_REVIVE_DURATION = 0.3

TUNING.GHOSTLYELIXIR_PLAYER_DRIP_FX_DELAY = seg_time / 2


-- WENDY
TUNING.GHOST_HUNT =
{
    TOY_COUNT =
    {
        MIN = 3,
        MAX = 5,
        WENDYSKILL_ADDITION = 3,
    },
    TOY_DIST =
    {
        BASE = 125,
        WENDY_UPGRADE_BASE = 75,
        RADIUS = 20,
        VARIANCE = 5,
    },
    TOY_FADE =
    {
        IN = 5.5,
        OUT = 6.5,
    },
    PICKUP_DSQ = 4,
    HINT_OFFSET = 3,
    MINIMUM_HINT_DIST = 40,
    MAXIMUM_HINT_DIST = 180,
}

TUNING.UNIQUE_SMALLGHOST_DISTANCE = 50

TUNING.ABIGAIL_SPEED = 5
TUNING.ABIGAIL_HEALTH = wilson_health * 4
TUNING.ABIGAIL_HEALTH_LEVEL1 = wilson_health * 1
TUNING.ABIGAIL_HEALTH_LEVEL2 = wilson_health * 2
TUNING.ABIGAIL_HEALTH_LEVEL3 = wilson_health * 4
TUNING.ABIGAIL_FORCEFIELD_ABSORPTION = 1.0
TUNING.ABIGAIL_DAMAGE_PER_SECOND = 20 -- deprecated
TUNING.ABIGAIL_DAMAGE =
{
    day = 15,
    dusk = 25,
    night = 40,
}
TUNING.ABIGAIL_VEX_DURATION = 2
TUNING.ABIGAIL_VEX_DAMAGE_MOD = 1.1
TUNING.ABIGAIL_VEX_GHOSTLYFRIEND_DAMAGE_MOD = 1.4

TUNING.ABIGAIL_SHADOW_VEX_DAMAGE_MOD = 1.3
TUNING.ABIGAIL_SHADOW_VEX_GHOSTLYFRIEND_DAMAGE_MOD = 1.6

TUNING.ABIGAIL_DMG_PERIOD = 1.5
TUNING.ABIGAIL_DMG_PLAYER_PERCENT = 0.25
TUNING.ABIGAIL_FLOWER_DECAY_TIME = total_day_time * 3

TUNING.ABIGAIL_BOND_LEVELUP_TIME = total_day_time * 1
TUNING.ABIGAIL_BOND_LEVELUP_TIME_MULT = 4
TUNING.ABIGAIL_MAX_STAGE = 3

TUNING.ABIGAIL_LIGHTING =
{
    { l = 0.0, r = 0.0 },
    { l = 0.1, r = 0.3, i = 0.7, f = 0.5 },
    { l = 0.5, r = 0.7, i = 0.6, f = 0.6 },
}

TUNING.ABIGAIL_FLOWER_PROX_DIST = 6 * 6
TUNING.ABIGAIL_COMBAT_TARGET_DISTANCE = 15

TUNING.ABIGAIL_DEFENSIVE_MIN_FOLLOW = 1
TUNING.ABIGAIL_DEFENSIVE_MAX_FOLLOW = 5
TUNING.ABIGAIL_DEFENSIVE_MED_FOLLOW = 3

TUNING.ABIGAIL_GESTALT_DEFENSIVE_MAX_FOLLOW = 15

TUNING.ABIGAIL_AGGRESSIVE_MIN_FOLLOW = 3
TUNING.ABIGAIL_AGGRESSIVE_MAX_FOLLOW = 10
TUNING.ABIGAIL_AGGRESSIVE_MED_FOLLOW = 6

TUNING.ABIGAIL_DEFENSIVE_MAX_CHASE_TIME = 3
TUNING.ABIGAIL_AGGRESSIVE_MAX_CHASE_TIME = 6

TUNING.GHOSTLYELIXIR_SLOWREGEN_HEALING = 2
TUNING.GHOSTLYELIXIR_SLOWREGEN_TICK_TIME = 1
TUNING.GHOSTLYELIXIR_SLOWREGEN_DURATION = total_day_time -- 960 hp

TUNING.GHOSTLYELIXIR_FASTREGEN_HEALING = 20
TUNING.GHOSTLYELIXIR_FASTREGEN_TICK_TIME = 1
TUNING.GHOSTLYELIXIR_FASTREGEN_DURATION = seg_time -- 600 hp

TUNING.GHOSTLYELIXIR_DAMAGE_DURATION = total_day_time

TUNING.GHOSTLYELIXIR_SPEED_LOCO_MULT = 1.75
TUNING.GHOSTLYELIXIR_SPEED_DURATION = total_day_time
TUNING.GHOSTLYELIXIR_SPEED_PLAYER_GHOST_DURATION = 3

TUNING.GHOSTLYELIXIR_SHIELD_DURATION = total_day_time

TUNING.GHOSTLYELIXIR_RETALIATION_DAMAGE = 20
TUNING.GHOSTLYELIXIR_RETALIATION_DURATION = total_day_time

TUNING.GHOSTLYELIXIR_REVIVE_DURATION = 2

TUNING.GHOSTLYELIXIR_DRIP_FX_DELAY = seg_time / 2

TUNING.SKILLS.WENDY = {
    ALLEGIANCE_SHADOW_RESIST = 0.9,
    ALLEGIANCE_VS_LUNAR_BONUS = 1.1,
    ALLEGIANCE_LUNAR_RESIST = 0.9,
    ALLEGIANCE_VS_SHADOW_BONUS = 1.1,

    POTION_DURATION_MOD = 1,

    GHOST_PLANARDEFENSE = 15,

    SISTURN_3_MAX_HEALTH_BOOST = 300,

    MURDER_BUFF_DURATION = 8,
    MURDER_BUFF_MULTIPLIER = 2,
    MURDER_DEFENSE_BUFF = 15,

    LUNARELIXIR_DURATION = 4 * seg_time,
    LUNARELIXIR_DAMAGEBONUS = 10,
    LUNARELIXIR_DAMAGEBONUS_GESTALT = 100,

    SHADOWELIXIR_DURATION = total_day_time,
    ABIGAIL_GESTALT_VEX_MULT = 3,
}
