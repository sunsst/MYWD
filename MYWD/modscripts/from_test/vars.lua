--------------------------------------------------------------------------------------------------------------------
-- MYWD:下面代码复制粘贴自测试服代码不要动，等更新了可以删了
UPGRADETYPES.GRAVESTONE = "gravestone"

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


STRINGS.SKILLTREE.WENDY = {
    WENDY_SISTURN_1_TITLE = "Blessed Sisturn I",
    WENDY_SISTURN_1_DESC = "The chilling aura of death preserves the petals placed in the sisturn longer.",
    WENDY_SISTURN_2_TITLE = "Blessed Sisturn II",
    WENDY_SISTURN_2_DESC =
    "Wendy's resistance to scary things is increased, and she grants some of that confidence to others nearby.",
    WENDY_SISTURN_3_TITLE = "Blessed Sisturn III",
    WENDY_SISTURN_3_DESC =
    "Wendy learns a unique propety of Lune Tree Blossms, thining the veil between worlds.\nAbigail's presence becomes stronger, giving her more resistance to the Giants of the Constant like the rest of the surviors.",


    WENDY_GHOSTCOMMAND_1_TITLE = "Team Spirit I",
    WENDY_GHOSTCOMMAND_1_DESC =
    "Wendy can remind Abigail she's a ghost, able to be unseen by her enemies to escape bad situations.",
    WENDY_GHOSTCOMMAND_2_TITLE = "Team Spirit II",
    WENDY_GHOSTCOMMAND_2_DESC = "Abigail can dash to anywhere Wendy needs reinforcement.",
    WENDY_GHOSTCOMMAND_3_TITLE = "Team Spirit III",
    WENDY_GHOSTCOMMAND_3_DESC = "Abigail can use her powers as a spooky ghost to scare and haunt things.",
    WENDY_GHOSTCOMMAND_HAUNT_TITLE = "Team Spirit IV",
    WENDY_GHOSTCOMMAND_HAUNT_DESC = "Wendy can suggest things for Abigail to haunt.",

    WENDY_SMALLGHOST_1_TITLE = "Pipspook Quest I",
    WENDY_SMALLGHOST_1_DESC = "Pipspook lost toys aren't quite so far away.",
    WENDY_SMALLGHOST_2_TITLE = "Pipspook Quest II",
    WENDY_SMALLGHOST_2_DESC = "Pipspooks remember more lost toys to find.",
    WENDY_SMALLGHOST_3_TITLE = "Pipspook Quest III",
    WENDY_SMALLGHOST_3_DESC = "Pipspooks produce more Mourning Glories.",

    WENDY_GHOSTFLOWER_BUTTERFLY_TITLE = "Mourning Glory I",
    WENDY_GHOSTFLOWER_BUTTERFLY_DESC = "Begin the journey of revival with Butterflies.",
    WENDY_GHOSTFLOWER_HAT_TITLE = "Mourning Glory II",
    WENDY_GHOSTFLOWER_HAT_DESC =
    "Surround yourself in ghostly nature and taste the power of the elixirs even if not fully.",
    WENDY_GHOSTFLOWER_GRAVE_TITLE = "Mourning Glory III",
    WENDY_GHOSTFLOWER_GRAVE_DESC = "You can bring back friends, but only if they've entered the Constant it seems.",

    WENDY_GRAVESTONE_1_TITLE = "Grave Beautification",
    WENDY_GRAVESTONE_1_DESC =
    "Wendy can adorn graves with flowers to delight their resident spirits.\nWendy can relocate graves to bring lonely spirits together.\nEvil Flowers no longer hold fear for Wendy.",
    WENDY_MAKEGRAVEMOUNDS_TITLE = "Gravestones By Wendy",
    WENDY_MAKEGRAVEMOUNDS_DESC = "Wendy can put to rest the spirits of skeletons with a gravestone.",

    WENDY_POTION_CONTAINER_TITLE = "Picnic Casket",
    WENDY_POTION_CONTAINER_DESC = "Wendy can craft a Basket to carry all of Abigail's Elixirs.",
    WENDY_POTION_REVIVE_TITLE = "Ghastly Experience",
    WENDY_POTION_REVIVE_DESC =
    "Wendy learns to brew a new Ghostly Elixir which helps Abigail quickly remember her potential.",
    WENDY_POTION_DURATION_TITLE = "Strong Brew",
    WENDY_POTION_DURATION_DESC = "Elixirs with one day duration will now last two.",
    WENDY_POTION_YIELD_TITLE = "Extra Yield",
    WENDY_POTION_YIELD_DESC = "Sometimes, Wendy is able to squeeze extra Elixirs out of the same ingredients.",

    WENDY_AVENGING_GHOST_TITLE = "Vengeful Ghost",
    WENDY_AVENGING_GHOST_DESC =
    "When Wendy or her friends are killed, their spirit is vengeful and able to wreak havoc on the living world for a short time.",

    WENDY_SHADOW_LOCK_1_DESC = "Defeat the Fuelweaver",
    WENDY_SHADOW_LOCK_2_DESC = "Have no other allegiance",

    WENDY_SHADOW_1_TITLE = "Shadow Sisterhood I",
    WENDY_SHADOW_1_DESC = "Abigail attunes with the shadows and earns some Planar Defense.",
    WENDY_SHADOW_2_TITLE = "Shadow Sisterhood II",
    WENDY_SHADOW_2_DESC =
    "Wendy can craft a Super Elixir infused with shadow magic that increases Abigail's Vex damage.\nSuper Elixirs work in parallel to regular Elixirs.",
    WENDY_SHADOW_3_TITLE = "Shadow Sisterhood III",
    WENDY_SHADOW_3_DESC =
    "Dark Magic is released whenever Wendy uses the Murder action filling Abigail with more power for a short time.",

    WENDY_LUNAR_LOCK_1_DESC = "Defeat the Celestial Champion",
    WENDY_LUNAR_LOCK_2_DESC = "Have no other allegiance",

    WENDY_LUNAR_1_TITLE = "Lunar Sisterhood I",
    WENDY_LUNAR_1_DESC = "Abigail attunes with lunar energies and earns some Planar Defense.",
    WENDY_LUNAR_2_TITLE = "Lunar Sisterhood II",
    WENDY_LUNAR_2_DESC =
    "Wendy can craft a Super Elixir infused with lunar energy that gives Abigail a boost of Planar Damage for its duration.\nSuper Elixirs work in parallel to regular Elixirs.",
    WENDY_LUNAR_3_TITLE = "Lunar Sisterhood III",
    WENDY_LUNAR_3_DESC =
    "Wendy can use the Moon Dial during a full moon to fill Abigail with lunar energy, turning her into a Gestalt. The Moon Dial can restore her ghost status during a new moon.",
}

-- Wendy
STRINGS.NAMES.GHOSTFLOWER = "Mourning Glory"
STRINGS.NAMES.SMALLGHOST = "Pipspook"
STRINGS.NAMES.GHOSTLYELIXIR_SLOWREGEN = "Revenant Restorative"
STRINGS.NAMES.GHOSTLYELIXIR_FASTREGEN = "Spectral Cure-All"
STRINGS.NAMES.GHOSTLYELIXIR_SHIELD = "Unyielding Draught"
STRINGS.NAMES.GHOSTLYELIXIR_ATTACK = "Nightshade Nostrum"
STRINGS.NAMES.GHOSTLYELIXIR_SPEED = "Vigor Mortis"
STRINGS.NAMES.GHOSTLYELIXIR_RETALIATION = "Distilled Vengeance"
STRINGS.NAMES.GHOSTLYELIXIR_REVIVE = "Ghastly Experience"
STRINGS.NAMES.SISTURN = "Sisturn"



STRINGS.NAMES.GHOSTLYELIXIR_LUNAR = "Luminous Wrath"
STRINGS.NAMES.GHOSTLYELIXIR_SHADOW = "Cursed Vexation"
STRINGS.NAMES.GRAVEGUARD_GHOST = "Bigspook"
STRINGS.NAMES.DUG_GRAVESTONE = "Headstone"
STRINGS.NAMES.WENDY_RECIPE_GRAVESTONE = "Headstone"
STRINGS.NAMES.SLINGSHOTMODKIT = "Slingshot Field Kit"
STRINGS.NAMES.SLINGSHOT_BAND_PIGSKIN = "Pig Skin Slingshot Band"
STRINGS.NAMES.SLINGSHOT_BAND_TENTACLE = "Flailing Slingshot Band"
STRINGS.NAMES.SLINGSHOT_BAND_MIMIC = "Possessed Slingshot Band"
STRINGS.NAMES.SLINGSHOT_FRAME_BONE = "Bony Slingshot Frame"
STRINGS.NAMES.SLINGSHOT_FRAME_GEMS = "Thulecite Slingshot Frame"
STRINGS.NAMES.SLINGSHOT_FRAME_WAGPUNK_0 = "Scrappy Slingshot Frame"
STRINGS.NAMES.SLINGSHOT_FRAME_WAGPUNK = "Scrappier Slingshot Frame"
STRINGS.NAMES.SLINGSHOT_HANDLE_STICKY = "Slingshot Sticky Grip"
STRINGS.NAMES.SLINGSHOT_HANDLE_JELLY = "Slingshot Jelly Grip"
STRINGS.NAMES.SLINGSHOT_HANDLE_SILK = "Slingshot Grip Tape"
STRINGS.NAMES.SLINGSHOT_HANDLE_VOIDCLOTH = "Slingshot Void Wrap"
STRINGS.NAMES.WOBY_BADGE_STATION = "Woby Training Station"
STRINGS.NAMES.ELIXIR_CONTAINER = "Picnic Casket"
STRINGS.NAMES.GHOSTFLOWERHAT = "Wraith's Wreath"
STRINGS.NAMES.WENDY_RESURRECTIONGRAVE = "Perennial Altar"
STRINGS.NAMES.WENDY_RESURRECTIONGRAVE_NAMED = "{name}'s Perennial Altar"

STRINGS.RECIPE_DESC.GHOSTLYELIXIR_SLOWREGEN = "Time heals all wounds."
STRINGS.RECIPE_DESC.GHOSTLYELIXIR_FASTREGEN = "A potent cure for grave injuries."
STRINGS.RECIPE_DESC.GHOSTLYELIXIR_SHIELD = "Shield your sister from harm."
STRINGS.RECIPE_DESC.GHOSTLYELIXIR_ATTACK = "Call upon the power of darkness."
STRINGS.RECIPE_DESC.GHOSTLYELIXIR_SPEED = "Give your soul a little boo-st."
STRINGS.RECIPE_DESC.GHOSTLYELIXIR_RETALIATION = "Give foes a taste of their own medicine."
STRINGS.RECIPE_DESC.GHOSTLYELIXIR_REVIVE = "Reminds Abigail of all she can be."
STRINGS.RECIPE_DESC.SISTURN = "A place to rest your weary soul."
STRINGS.RECIPE_DESC.PETALS = "Purify your petals."
STRINGS.RECIPE_DESC.PETALS_EVIL = "Stain your petals."
STRINGS.RECIPE_DESC.GHOSTLYELIXIR_LUNAR = "Abigail will pack an outerplanar punch."
STRINGS.RECIPE_DESC.GHOSTLYELIXIR_SHADOW = "As if a ghost attack wasn't vexing enough."
STRINGS.RECIPE_DESC.WENDY_RECIPE_GRAVESTONE = "No one deserves an unmarked grave."
STRINGS.RECIPE_DESC.WOBY_BADGE_STATION = "Train your Pinetree Pooch!"
STRINGS.RECIPE_DESC.SLINGSHOTMODKIT = "Slingshotting is serious business."
STRINGS.RECIPE_DESC.SLINGSHOT_BAND_PIGSKIN = "Sling farther!"
STRINGS.RECIPE_DESC.SLINGSHOT_BAND_TENTACLE = "Sling farther-er!"
STRINGS.RECIPE_DESC.SLINGSHOT_FRAME_BONE = "More ammo? Yes please!"
STRINGS.RECIPE_DESC.SLINGSHOT_FRAME_GEMS = "A little bit of this, and a little bit of that!"
STRINGS.RECIPE_DESC.SLINGSHOT_FRAME_WAGPUNK_0 = "Ya think you're some sorta big shot now, huh?"
STRINGS.RECIPE_DESC.SLINGSHOT_FRAME_WAGPUNK = "Embrace your ammo hoarding tendencies!"
STRINGS.RECIPE_DESC.SLINGSHOT_HANDLE_STICKY = "Get attached to your slingshot."
STRINGS.RECIPE_DESC.SLINGSHOT_HANDLE_JELLY = "The stickiest grip yet!"
STRINGS.RECIPE_DESC.SLINGSHOT_HANDLE_SILK = "Sling faster!"
STRINGS.RECIPE_DESC.SLINGSHOT_HANDLE_VOIDCLOTH = "Sling faster-er!"
STRINGS.RECIPE_DESC.WORTOX_REVIVER = "Soul revival of a single ghostly friend. May bring others closer."
STRINGS.RECIPE_DESC.WORTOX_NABBAG = "Stuff it and swing it!"
STRINGS.RECIPE_DESC.WORTOX_SOULJAR = "Why let them be free when you can stuff them all into a jar?"
STRINGS.RECIPE_DESC.ELIXIR_CONTAINER = "For carrying all of Abigail's snacks."
STRINGS.RECIPE_DESC.GHOSTFLOWERHAT = "Think like a ghost, drink like a ghost."
STRINGS.RECIPE_DESC.BUTTERFLY = "Help them relive their glory."
STRINGS.RECIPE_DESC.WENDY_RESURRECTIONGRAVE = "Death is but an inconvenience."
