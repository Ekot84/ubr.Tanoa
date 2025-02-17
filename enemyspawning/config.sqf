// Configuration Parameters
_spawnChance = 0.2;                         // Probability (0-1) of spawning enemies
_enemyCountRange = [1, 3];                  // Array [minEnemies, maxEnemies] to spawn per location
_minDistance = 100;                          // Minimum spawn distance from player (meters)
_maxDistance = 1500;                          // Maximum spawn distance from player (meters)
_maxTotalEnemies = 15;                       // Maximum total number of enemies allowed at the same time
_spawnCheckInterval = 120;                   // Interval in seconds to recheck and spawn enemies if under the limit
_cleanupDistance = 800;                      // Distance from player at which enemies are removed
_skillRange = [0.1, 0.5];                   // Skill Range
private _cooldownTime = 800;                // Cooldown time in seconds
_useAutoLoadout = false;                   // While true Generate loadouts from all mods true CFGS

// Equipment Pools
// Equipment Pools (Primary Weapons)
_equipmentPool = [
    ["", []], // Empty slot for unarmed units

    // 🔥 Standard Assault Rifles (Modern)
    /*["arifle_Katiba_F", ["30Rnd_65x39_caseless_green"]],  // Katiba 6.5 mm
    ["arifle_MX_F", ["30Rnd_65x39_caseless_mag"]],        // MX 6.5 mm
    ["arifle_MX_khk_F", ["30Rnd_65x39_caseless_khaki_mag"]], // MX Khaki (Tanoa)
    ["arifle_MX_SW_F", ["100Rnd_65x39_caseless_mag"]],    // MX SW LMG
    ["arifle_AK12_F", ["30Rnd_762x39_Mag_F"]],  // AK-12 7.62mm*/

    // 🎖️ Classic Battle Rifles (Cold War & Historic)
    ["CUP_srifle_LeeEnfield", ["CUP_10x_303_M"]], // Lee-Enfield .303
    ["CUP_srifle_Mosin_Nagant", ["CUP_5Rnd_762x54_Mosin_M"]], // Mosin-Nagant
    ["CUP_srifle_M14", ["CUP_20Rnd_762x51_DMR"]], // M14

    // 🛠️ Shotguns
    ["sgun_HunterShotgun_01_F", ["2Rnd_12Gauge_Pellets", "2Rnd_12Gauge_Slug"]],  // Hunter Shotgun (Contact DLC)
    ["sgun_HunterShotgun_01_sawedoff_F", ["2Rnd_12Gauge_Pellets", "2Rnd_12Gauge_Slug"]], // Sawed-off Hunter (Contact DLC)
    ["CUP_sgun_M1014", ["CUP_8Rnd_B_Beneli_74Slug", "CUP_8Rnd_B_Beneli_74Pellets"]],  // M1014 (CUP Mod)
    ["CUP_sgun_SPAS12", ["CUP_8Rnd_B_Saiga12_74Pellets", "CUP_8Rnd_B_Saiga12_74Slug"]] // SPAS-12 (CUP Mod)
];

// Secondary Weapons (Pistols & SMGs)
_secondaryWeaponsPool = [
    ["", []], // Empty slot for unarmed units

    // 🔫 9mm Handguns
    ["hgun_Rook40_F", ["16Rnd_9x21_Mag"]],
    ["hgun_P07_F", ["16Rnd_9x21_Mag"]],
    ["hgun_P07_khk_F", ["16Rnd_9x21_Mag"]],
    ["hgun_Pistol_01_F", ["10Rnd_9x21_Mag"]],  // PM 9mm

    // .45 ACP Handguns
    ["hgun_ACPC2_F", ["9Rnd_45ACP_Mag"]],
    ["hgun_Pistol_heavy_01_F", ["11Rnd_45ACP_Mag"]],  // 4-five
    ["hgun_Pistol_heavy_01_green_F", ["11Rnd_45ACP_Mag"]],

    // 🔄 .357 Magnum Revolver
    ["hgun_Pistol_heavy_02_F", ["6Rnd_45ACP_Cylinder"]],  // Zubr

    // 🔥 9mm Subcompact Weapons
    ["hgun_PDW2000_F", ["30Rnd_9x21_Mag"]],  // PDW-2000 (Compact SMG)

    // 🏛️ Historic Handguns
    ["CUP_hgun_Colt1911", ["CUP_7Rnd_45ACP_1911"]], // Colt M1911 (CUP)
    ["CUP_hgun_M9", ["CUP_15Rnd_9x19_M9"]], // Beretta M9 (CUP)
    ["CUP_hgun_TT", ["CUP_8Rnd_762x25_TT"]], // Tokarev TT-33
    ["CUP_hgun_Makarov", ["CUP_8Rnd_9x18_Makarov_M"]], // Makarov PMM
    ["CUP_FlareWhite_GP25_M", ["CUP_glaunch_6G30"]], // PB Suppressed Makarov
    ["CUP_hgun_Duty", ["CUP_16Rnd_9x19_cz75"]] // CZ-75 Duty
];



_grenadePool = [
    "HandGrenade",              // M67 Fragmentation Grenade
    "MiniGrenade",              // RGO Fragmentation Grenade
    "SmokeShell",               // Smoke Grenade (White)
    "SmokeShellRed",            // Smoke Grenade (Red)
    "SmokeShellGreen",          // Smoke Grenade (Green)
    "SmokeShellYellow",         // Smoke Grenade (Yellow)
    "SmokeShellPurple",         // Smoke Grenade (Purple)
    "SmokeShellBlue",           // Smoke Grenade (Blue)
    "SmokeShellOrange",         // Smoke Grenade (Orange)
    "Chemlight_green",          // Chemlight (Green)
    "Chemlight_red",            // Chemlight (Red)
    "Chemlight_blue",           // Chemlight (Blue)
    "Chemlight_yellow",         // Chemlight (Yellow)
    "B_IR_Grenade",             // IR Grenade
    "O_IR_Grenade",             // IR Grenade (OPFOR)
    "I_IR_Grenade",             // IR Grenade (INDFOR)
    "UGL_FlareWhite_F",         // 40mm Flare (White)
    "UGL_FlareRed_F",           // 40mm Flare (Red)
    "UGL_FlareGreen_F",         // 40mm Flare (Green)
    "UGL_FlareYellow_F",        // 40mm Flare (Yellow)
    "UGL_FlareCIR_F",           // 40mm Flare (IR)
    "1Rnd_Smoke_Grenade_shell", // 40mm Smoke Grenade (White)
    "1Rnd_SmokeRed_Grenade_shell",    // 40mm Smoke Grenade (Red)
    "1Rnd_SmokeGreen_Grenade_shell",  // 40mm Smoke Grenade (Green)
    "1Rnd_SmokeYellow_Grenade_shell", // 40mm Smoke Grenade (Yellow)
    "1Rnd_SmokePurple_Grenade_shell", // 40mm Smoke Grenade (Purple)
    "1Rnd_SmokeBlue_Grenade_shell",   // 40mm Smoke Grenade (Blue)
    "1Rnd_SmokeOrange_Grenade_shell", // 40mm Smoke Grenade (Orange)
    "1Rnd_HE_Grenade_shell",    // 40mm HE Grenade
    "3Rnd_HE_Grenade_shell",    // 3x 40mm HE Grenades
    "3Rnd_Smoke_Grenade_shell", // 3x 40mm Smoke Grenades (White)
    "3Rnd_SmokeRed_Grenade_shell",    // 3x 40mm Smoke Grenades (Red)
    "3Rnd_SmokeGreen_Grenade_shell",  // 3x 40mm Smoke Grenades (Green)
    "3Rnd_SmokeYellow_Grenade_shell", // 3x 40mm Smoke Grenades (Yellow)
    "3Rnd_SmokePurple_Grenade_shell", // 3x 40mm Smoke Grenades (Purple)
    "3Rnd_SmokeBlue_Grenade_shell",   // 3x 40mm Smoke Grenades (Blue)
    "3Rnd_SmokeOrange_Grenade_shell", // 3x 40mm Smoke Grenades (Orange)
    ""                          // No nade
];

_uniformPool = [
    "U_C_Mechanic_01_F",  
    "U_C_Man_casual_6_sick_F",                // Black Jacket
    "U_BG_Guerilla3_2",                // Red Jacket
    "U_BG_Guerilla3_1",                // Yellow Jacket
    "U_BG_Guerilla1_1",                // Purple Jacket
    "U_C_Poor_1",                // Orange Jacket
    "U_C_Uniform_Farmer_01_F",
    "U_I_L_Uniform_01_tshirt_skull_F",
    "U_IG_Guerilla3_2",
    "U_IG_Guerilla3_1"
];

_vestPool = [
    "V_Press_F",                  // Press Vest
    "V_Rangemaster_belt",         // Rangemaster Belt
    "V_LegStrapBag_black_F",      // Leg Strap Bag (Black)
    "V_LegStrapBag_coyote_F",     // Leg Strap Bag (Coyote)
    "V_LegStrapBag_olive_F",      // Leg Strap Bag (Olive)
    "V_SmershVest_01_F",          // Kipchak
    "V_SmershVest_01_radio_F",    // Kipchak (Radio)
    "V_SmershVest_01_radio_tan_F", // Kipchak (Tan, Radio)
    "V_SmershVest_01_tan_F",      // Kipchak (Tan)
    "V_DeckCrew_yellow_F",        // Deck Crew Vest (Yellow)
    "V_DeckCrew_blue_F",          // Deck Crew Vest (Blue)
    "V_DeckCrew_red_F",           // Deck Crew Vest (Red)
    "V_DeckCrew_green_F",         // Deck Crew Vest (Green)
    "V_DeckCrew_white_F",         // Deck Crew Vest (White)
    "V_DeckCrew_brown_F",         // Deck Crew Vest (Brown)
    "V_DeckCrew_violet_F",        // Deck Crew Vest (Violet)
    "V_Safety_yellow_F",          // Safety Vest (Yellow)
    "V_Safety_orange_F",          // Safety Vest (Orange)
    "V_Safety_blue_F",            // Safety Vest (Blue)
    "V_DeckCrew_yellow_F",        // Deck Crew Vest (Yellow)
    "V_DeckCrew_blue_F",          // Deck Crew Vest (Blue)
    "V_DeckCrew_red_F",           // Deck Crew Vest (Red)
    "V_DeckCrew_green_F",         // Deck Crew Vest (Green)
    "V_DeckCrew_white_F",         // Deck Crew Vest (White)
    "V_DeckCrew_brown_F",         // Deck Crew Vest (Brown)
    "V_DeckCrew_violet_F",        // Deck Crew Vest (Violet)
    "V_Safety_yellow_F",          // Safety Vest (Yellow)
    "V_Safety_orange_F",          // Safety Vest (Orange)
    "V_Safety_blue_F",            // Safety Vest (Blue)
    ""                            // No Vest   
];

_bagPool = [
    /*"B_AssaultPack_blk",           // Assault Pack (Black)
    "B_AssaultPack_cbr",           // Assault Pack (Coyote)
    "B_AssaultPack_dgtl",          // Assault Pack (Digital)
    "B_AssaultPack_eaf_F",         // Assault Pack (Geometric)
    "B_AssaultPack_khk",           // Assault Pack (Khaki)
    "B_AssaultPack_mcamo",         // Assault Pack (MTP)
    "B_AssaultPack_ocamo",         // Assault Pack (Hex)
    "B_AssaultPack_rgr",           // Assault Pack (Green)
    "B_AssaultPack_sgg",           // Assault Pack (Sage)
    "B_AssaultPack_tna_F",         // Assault Pack (Tropic)
    "B_Bergen_mcamo_F",            // Bergen Backpack (MTP)
    "B_Bergen_dgtl_F",             // Bergen Backpack (Digital)
    "B_Bergen_hex_F",              // Bergen Backpack (Hex)
    "B_Bergen_tna_F",              // Bergen Backpack (Tropic)
    "B_Carryall_cbr",              // Carryall Backpack (Coyote)
    "B_Carryall_eaf_F",            // Carryall Backpack (Geometric)
    "B_Carryall_ghex_F",           // Carryall Backpack (Green Hex)
    "B_Carryall_khk",              // Carryall Backpack (Khaki)
    "B_Carryall_mcamo",            // Carryall Backpack (MTP)
    "B_Carryall_ocamo",            // Carryall Backpack (Hex)
    "B_Carryall_oli",              // Carryall Backpack (Olive)
    "B_Carryall_tna_F",            // Carryall Backpack (Tropic)
    "B_FieldPack_blk",             // Field Pack (Black)
    "B_FieldPack_cbr",             // Field Pack (Coyote)
    "B_FieldPack_ocamo",           // Field Pack (Hex)
    "B_FieldPack_oli",             // Field Pack (Olive)
    "B_FieldPack_green_F",         // Field Pack (Green)
    "B_FieldPack_taiga_F",         // Field Pack (Taiga)
    "B_Kitbag_cbr",                // Kitbag (Coyote)
    "B_Kitbag_mcamo",              // Kitbag (MTP)
    "B_Kitbag_rgr",                // Kitbag (Green)
    "B_Kitbag_sgg",                // Kitbag (Sage)
    "B_Kitbag_tan",                // Kitbag (Tan)
    "B_LegStrapBag_black_F",       // Leg Strap Bag (Black)
    "B_LegStrapBag_coyote_F",      // Leg Strap Bag (Coyote)
    "B_LegStrapBag_olive_F",       // Leg Strap Bag (Olive)
    "B_Messenger_Black_F",         // Messenger Bag (Black)
    "B_Messenger_Coyote_F",        // Messenger Bag (Coyote)
    "B_Messenger_Gray_F",          // Messenger Bag (Gray)
    "B_Messenger_Olive_F",         // Messenger Bag (Olive)
    "B_RadioBag_01_black_F",       // Radio Pack (Black)
    "B_RadioBag_01_digi_F",        // Radio Pack (Digital)
    "B_RadioBag_01_eaf_F",         // Radio Pack (Geometric)
    "B_RadioBag_01_ghex_F",        // Radio Pack (Green Hex)
    "B_RadioBag_01_mtp_F",         // Radio Pack (MTP)
    "B_TacticalPack_blk",          // Tactical Backpack (Black)
    "B_TacticalPack_mcamo",        // Tactical Backpack (MTP)
    "B_TacticalPack_ocamo",        // Tactical Backpack (Hex)
    "B_TacticalPack_oli",          // Tactical Backpack (Olive)
    "B_TacticalPack_rgr",          // Tactical Backpack (Green)
    "B_RadioBag_01_tropic_F",      // Radio Pack (Tropic)
    "B_ViperHarness_blk_F",        // Viper Harness (Black)
    "B_ViperHarness_ghex_F",       // Viper Harness (Green Hex)
    "B_ViperHarness_hex_F",        // Viper Harness (Hex)
    "B_ViperHarness_khk_F",        // Viper Harness (Khaki)
    "B_ViperHarness_oli_F",        // Viper Harness (Olive)
    "B_ViperLightHarness_blk_F",   // Viper Light Harness (Black)
    "B_ViperLightHarness_ghex_F",  // Viper Light Harness (Green Hex)
    "B_ViperLightHarness_hex_F",   // Viper Light Harness (Hex)
    "B_ViperLightHarness_khk_F",   // Viper Light Harness (Khaki)
    "B_ViperLightHarness_oli_F",   // Viper Light Harness (Olive)*/
    ""                             // No Backpack    
];
_headgearPool = [
   /* "H_HelmetSpecB",               // Enhanced Combat Helmet
    "H_HelmetB_light",             // Light Combat Helmet
    "H_Booniehat_khk",             // Booniehat (Khaki)
    "H_Bandanna_khk",              // Bandana (Khaki)
    "H_Cap_blk",                   // Cap (Black)
    "H_HelmetB",                   // Combat Helmet
    "H_HelmetB_camo",              // Combat Helmet (Camo)
    "H_HelmetB_paint",             // Combat Helmet (Paint)
    "H_HelmetB_plain_blk",         // Combat Helmet (Black)
    "H_HelmetB_sand",              // Combat Helmet (Sand)
    "H_HelmetCrew_B",              // Crew Helmet [NATO]
    "H_HelmetCrew_I",              // Crew Helmet [AAF]
    "H_HelmetCrew_O",              // Crew Helmet [CSAT]
    "H_HelmetIA",                  // Modular Helmet [AAF]
    "H_HelmetIA_camo",             // Modular Helmet (Camo) [AAF]
    "H_HelmetIA_net",              // Modular Helmet (Net) [AAF]
    "H_HelmetLeaderO_ocamo",       // Defender Helmet (Hex) [CSAT]
    "H_HelmetLeaderO_oucamo",      // Defender Helmet (Urban) [CSAT]
    "H_HelmetO_ocamo",             // Protector Helmet (Hex) [CSAT]
    "H_HelmetO_oucamo",            // Protector Helmet (Urban) [CSAT]
    "H_HelmetSpecO_blk",           // Assassin Helmet (Black) [CSAT]
    "H_HelmetSpecO_ocamo",         // Assassin Helmet (Hex) [CSAT]
    "H_MilCap_blue",               // Military Cap (Blue)
    "H_MilCap_dgtl",               // Military Cap (Digital)
    "H_MilCap_mcamo",              // Military Cap (MTP)
    "H_MilCap_ocamo",              // Military Cap (Hex)
    "H_MilCap_oucamo",             // Military Cap (Urban)
    "H_MilCap_rucamo",             // Military Cap (Russia)
    "H_MilCap_tna_F",              // Military Cap (Tropic)
    "H_PilotHelmetFighter_B",      // Pilot Helmet [NATO]
    "H_PilotHelmetFighter_I",      // Pilot Helmet [AAF]
    "H_PilotHelmetFighter_O",      // Pilot Helmet [CSAT]
    "H_PilotHelmetHeli_B",         // Helicopter Pilot Helmet [NATO]
    "H_PilotHelmetHeli_I",         // Helicopter Pilot Helmet [AAF]
    "H_PilotHelmetHeli_O",         // Helicopter Pilot Helmet [CSAT]
    "H_CrewHelmetHeli_B",          // Helicopter Crew Helmet [NATO]
    "H_CrewHelmetHeli_I",          // Helicopter Crew Helmet [AAF]
    "H_CrewHelmetHeli_O",          // Helicopter Crew Helmet [CSAT]
    "H_Helmet_Skate",              // Skate Helmet
    "H_Beret_02",                  // Beret [NATO]
    "H_Beret_blk",                 // Beret (Black)
    "H_Beret_blk_POLICE",          // Beret (Police)
    "H_Beret_brn_SF",              // Beret (SAS)
    "H_Beret_Colonel",             // Beret [NATO] (Colonel)
    "H_Beret_CSAT_01_F",           // Beret (Red) [CSAT]
    "H_Beret_EAF_01_F",            // Beret [LDF]
    "H_Beret_gen_F",               // Beret (Gendarmerie)
    "H_Beret_grn",                 // Beret (Green)
    "H_Beret_grn_SF",              // Beret (SF)
    "H_Beret_ocamo",               // Beret [CSAT]
    "H_Beret_red",                 // Beret (Red)
    "H_HelmetAggressor_F",         // Aggressor Helmet
    "H_HelmetB_Enh_tna_F",         // Enhanced Combat Helmet (Tropic)
    "H_HelmetCrew_O_ghex_F",       // Crew Helmet (Green Hex)
    "H_HelmetHBK_chops_F",         // Heavy Helmet (Chops)
    "H_HelmetHBK_F",               // Heavy Helmet
    "H_HelmetHBK_headset_F",       // Heavy Helmet (Headset)
    "H_HelmetHBK_chops_F",         // Heavy Helmet (Chops)
    "H_HelmetO_ViperSP_hex_F",     // Viper Special Purpose Helmet (Hex)
    "H_HelmetO_ViperSP_ghex_F",    // Viper Special Purpose Helmet (Green Hex)
    "H_HelmetSpecO_ghex_F",        // Assassin Helmet (Green Hex)
    "H_HelmetLeaderO_ghex_F",      // Defender Helmet (Green Hex)
    "H_Booniehat_dgtl",            // Booniehat [AAF]
    "H_Booniehat_dirty",           // Booniehat (Dirty)
    "H_Booniehat_eaf",             // Booniehat [LDF]
    "H_Booniehat_grn",             // Booniehat (Green)
    "H_Booniehat_indp",            // Booniehat (Khaki)
    "H_Booniehat_khk_hs",          // Booniehat (Headset)
    "H_Booniehat_mcamo",           // Booniehat (MTP)
    "H_Booniehat_ocamo",           // Booniehat (Hex)
    "H_Booniehat_tan",             // Booniehat (Tan)
    "H_Booniehat_tna_F", */          // Booniehat (Tropic)
    "H_Cap_blk_CMMG",              // Cap (Black, CMMG)
    "H_Cap_blk_ION",               // Cap (Black, ION)
    "H_Cap_blk_Raven",             // Cap (Black, Raven)
    "H_Cap_blu",                   // Cap (Blue)
    "H_Cap_brn_SPECOPS",           // Cap (Brown, Specops)
    "H_Cap_grn",                   // Cap (Green)
    "H_Cap_headphones",            // Cap (Headphones)
    "H_Cap_khaki_specops_UK",      // Cap (Khaki
    "H_Cap_oli",                   // Cap (Olive)
    "H_Cap_oli_hs",                // Cap (Olive, Headset)
    "H_Cap_press",                 // Cap (Press)
    "H_Cap_red",                   // Cap (Red)
    "H_Cap_surfer",                // Cap (Surfer)
    "H_Cap_tan",                   // Cap (Tan)
    "H_Cap_tan_specops_US",        // Cap (Tan, SpecOps US)
    "H_Cap_usblack",               // Cap (US Black)
    "H_Hat_blue",                  // Hat (Blue)
    "H_Hat_brown",                 // Hat (Brown)
    "H_Hat_checker",               // Hat (Checker)
    "H_Hat_camo",                  // Hat (Camo)
    "H_Hat_grey",                  // Hat (Grey)
    "H_Hat_tan",                   // Hat (Tan)
    "H_StrawHat",                  // Straw Hat
    "H_StrawHat_dark",             // Straw Hat (Dark)
    "H_TurbanO_blk",               // Turban (Black)
    "H_TurbanO_tan",               // Turban (Tan)
    "H_Watchcap_blk",              // Beanie (Black)
    "H_Watchcap_camo",             // Beanie (Camo)
    "H_Watchcap_khk",              // Beanie (Khaki)
    "H_Watchcap_sgg",              // Beanie (Sage)
    "H_MilCap_ghex_F",             // Military Cap (Green Hex)
    "H_Booniehat_ghex_F",          // Booniehat (Green Hex)
    "H_Cap_ghex_F",                // Cap (Green Hex)
    "H_Hat_Safari_sand_F",         // Safari Hat (Sand)
    "H_Hat_Safari_olive_F",        // Safari Hat (Olive)
    "H_Tank_black_F",              // Tanker Helmet (Black)
    "H_Tank_green_F",              // Tanker Helmet (Green)
    "H_Tank_rust_F",               // Tanker Helmet (Rust)
    "H_Construction_basic_red_F",  // Construction Helmet (Red)
    "H_Construction_basic_yellow_F", // Construction Helmet (Yellow)
    "H_Construction_basic_orange_F", // Construction Helmet (Orange)
    "H_Construction_basic_vrana_F",  // Construction Helmet (Vrana)
    "H_Construction_basic_white_F",  // Construction Helmet (White)
    "H_Construction_basic_blue_F",   // Construction Helmet (Blue)
    "H_Construction_earprot_red_F",  // Construction Helmet (Red, Ear Protection)
    "H_Construction_earprot_yellow_F", // Construction Helmet (Yellow, Ear Protection)
    "H_Construction_earprot_orange_F", // Construction Helmet (Orange, Ear Protection)
    "H_Construction_earprot_vrana_F",  // Construction Helmet (Vrana, Ear Protection)
    "H_Construction_earprot_white_F",  // Construction Helmet (White, Ear Protection)
    "H_Construction_earprot_blue_F",   // Construction Helmet (Blue, Ear Protection)
    "H_Construction_headset_red_F",    // Construction Helmet (Red, Headset)
    "H_Construction_headset_yellow_F", // Construction Helmet (Yellow, Headset)
    "H_Construction_headset_orange_F", // Construction Helmet (Orange, Headset)
    "H_Construction_headset_vrana_F",  // Construction Helmet (Vrana, Headset)
    "H_Construction_headset_white_F",  // Construction Helmet (White, Headset)
    "H_Construction_headset_blue_F",    // Construction Helmet (Blue, Headset)
    "H_Booniehat_khk",             // Booniehat (Khaki)
    "H_Bandanna_khk",              // Bandana (Khaki)
    "H_Cap_blk_CMMG",              // Cap (Black, CMMG)
    "H_Cap_blk_ION",               // Cap (Black, ION)
    "H_Cap_blk_Raven",             // Cap (Black, Raven)
    "H_Cap_blu",                   // Cap (Blue)
    "H_Cap_brn_SPECOPS",           // Cap (Brown, Specops)
    "H_Cap_grn",                   // Cap (Green)
    "H_Cap_headphones",            // Cap (Headphones)
    "H_Cap_khaki_specops_UK",      // Cap (Khaki
    "H_Cap_oli",                   // Cap (Olive)
    "H_Cap_oli_hs",                // Cap (Olive, Headset)
    "H_Cap_press",                 // Cap (Press)
    "H_Cap_red",                   // Cap (Red)
    "H_Cap_surfer",                // Cap (Surfer)
    "H_Cap_tan",                   // Cap (Tan)
    "H_Cap_tan_specops_US",        // Cap (Tan, SpecOps US)
    "H_Cap_usblack",               // Cap (US Black)
    "H_Hat_blue",                  // Hat (Blue)
    "H_Hat_brown",                 // Hat (Brown)
    "H_Hat_checker",               // Hat (Checker)
    "H_Hat_camo",                  // Hat (Camo)
    "H_Hat_grey",                  // Hat (Grey)
    "H_Hat_tan",                   // Hat (Tan)
    "H_StrawHat",                  // Straw Hat
    "H_StrawHat_dark",             // Straw Hat (Dark)
    "H_TurbanO_blk",               // Turban (Black)
    "H_TurbanO_tan",               // Turban (Tan)
    "H_Watchcap_blk",              // Beanie (Black)
    "H_Watchcap_camo",             // Beanie (Camo)
    "H_Watchcap_khk",              // Beanie (Khaki)
    "H_Watchcap_sgg",              // Beanie (Sage)
    "H_Helmet_Skate",              // Skate Helmet
    "H_Bandanna_blu",              // Bandana (Blue)
    "H_Bandanna_camo",             // Bandana (Woodland)
    "H_Bandanna_cbr",              // Bandana (Coyote)
    "H_Bandanna_gry",              // Bandana (Grey)
    "H_Bandanna_khk_hs",           // Bandana (Headset)
    "H_Bandanna_mcamo",            // Bandana (MTP)
    "H_Bandanna_sand",             // Bandana (Sand)
    "H_Bandanna_sgg",              // Bandana (Sage)
    "H_Bandanna_surfer",           // Bandana (Surfer)
    "H_Bandanna_surfer_blk",       // Bandana (Surfer, Black)
    "H_Bandanna_surfer_grn",       // Bandana (Surfer, Green)
    "H_BandMask_blk",              // Bandana Mask (Black)
    "H_BandMask_demon",            // Bandana Mask (Demon)
    "H_BandMask_khk",              // Bandana Mask (Khaki)
    "H_BandMask_reaper",           // Bandana Mask (Reaper)
    ""    
];

_medkits = ["FirstAidKit", "Medikit"];