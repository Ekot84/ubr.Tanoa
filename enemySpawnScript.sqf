/*
    Script: Enemy Spawn Near Buildings and Roads
    Version: 0.15
    Filename: enemySpawnScript.sqf
    Author: Eko & ChatGPT
    Description: Spawns enemies near buildings or as patrols on roads with configurable spawn chance, quantity, random equipment, random skill, and player spawn distance. Includes despawning logic based on distance.
*/

// Configuration Parameters
params [
    ["_spawnChance", 0.5],                         // Probability (0-1) of spawning enemies
    ["_enemyCountRange", [1, 5]],                  // Array [minEnemies, maxEnemies] to spawn per location
    ["_minDistance", 100],                         // Minimum spawn distance from player (meters)
    ["_maxDistance", 300],                         // Maximum spawn distance from player (meters)
    ["_maxTotalEnemies", 25],                      // Maximum total number of enemies allowed at the same time
    ["_spawnCheckInterval", 120],                  // Interval in seconds to recheck and spawn enemies if under the limit
    ["_cleanupDistance", 500],                     // Distance from player at which enemies are removed
["_equipmentPool", [
    // Vanilla Arma 3 Weapons
    ["arifle_Katiba_F", ["30Rnd_65x39_caseless_green"]],       // Katiba 6.5 mm
    ["arifle_MX_F", ["30Rnd_65x39_caseless_mag"]],             // MX 6.5 mm
    ["arifle_AK12_F", ["30Rnd_762x39_Mag_F"]],                 // AK-12 7.62 mm
    ["SMG_02_F", ["30Rnd_9x21_Mag"]],                          // Sting 9 mm
    ["arifle_SPAR_01_blk_F", ["30Rnd_556x45_Stanag"]],         // SPAR-16 5.56 mm
    ["arifle_TRG21_F", ["30Rnd_556x45_Stanag"]],               // TRG-21 5.56 mm
    ["arifle_Mk20_F", ["30Rnd_556x45_Stanag"]],                // Mk20 5.56 mm
    ["arifle_CTAR_blk_F", ["30Rnd_580x42_Mag_F"]],             // CAR-95 5.8 mm
    ["arifle_ARX_blk_F", ["30Rnd_65x39_caseless_green"]],      // Type 115 6.5 mm
    ["srifle_DMR_01_F", ["10Rnd_762x54_Mag"]],                 // Rahim 7.62 mm
    ["srifle_EBR_F", ["20Rnd_762x51_Mag"]],                    // Mk18 ABR 7.62 mm
    ["LMG_Mk200_F", ["200Rnd_65x39_cased_Box"]],               // Mk200 6.5 mm
    ["LMG_Zafir_F", ["150Rnd_762x54_Box"]],                    // Zafir 7.62 mm

    // CUP Weapons
    ["CUP_arifle_AK74", ["CUP_30Rnd_545x39_AK_M"]],            // AK-74
    ["CUP_arifle_AK74M", ["CUP_30Rnd_545x39_AK_M"]],           // AK-74M
    ["CUP_arifle_AK47", ["CUP_30Rnd_762x39_AK47_M"]],          // AK-47
    ["CUP_arifle_M16A2", ["CUP_30Rnd_556x45_Stanag"]],         // M16A2
    ["CUP_arifle_M4A1", ["CUP_30Rnd_556x45_Stanag"]],          // M4A1
    ["CUP_arifle_G36A", ["CUP_30Rnd_556x45_G36"]],             // G36A
    ["CUP_arifle_FNFAL", ["CUP_20Rnd_762x51_FNFAL_M"]],        // FN FAL
    ["CUP_arifle_L85A2", ["CUP_30Rnd_556x45_Stanag"]],         // L85A2
    ["CUP_arifle_XM8_Railed", ["CUP_30Rnd_556x45_Stanag"]],    // XM8
    ["CUP_srifle_SVD", ["CUP_10Rnd_762x54_SVD_M"]],            // SVD
    ["CUP_srifle_M24_wdl", ["CUP_5Rnd_762x51_M24"]],           // M24
    ["CUP_lmg_M249", ["CUP_200Rnd_TE4_Red_Tracer_556x45_M249"]], // M249
    ["CUP_lmg_PKM", ["CUP_100Rnd_TE4_LRT4_762x54_PK_M"]],      // PKM
    ["CUP_sgun_M1014", ["CUP_8Rnd_B_Beneli_74Slug"]],          // M1014
    ["CUP_smg_MP5A5", ["CUP_30Rnd_9x19_MP5"]],                 // MP5A5
    ["CUP_smg_EVO", ["CUP_30Rnd_9x19_EVO"]],                   // EVO 3
    ["CUP_arifle_AKS74U", ["CUP_30Rnd_545x39_AK_M"]],          // AKS-74U
    ["CUP_arifle_Sa58P", ["CUP_30Rnd_Sa58_M"]],                // Sa vz. 58
    ["CUP_arifle_Mk16_STD", ["CUP_30Rnd_556x45_Stanag"]],      // Mk16 SCAR-L
    ["CUP_arifle_Mk17_STD", ["CUP_20Rnd_762x51_B_SCAR"]],      // Mk17 SCAR-H
    ["CUP_arifle_HK416", ["CUP_30Rnd_556x45_Stanag"]],         // HK416
    ["CUP_arifle_HK417_20", ["CUP_20Rnd_762x51_HK417"]],       // HK417
    ["CUP_srifle_LeeEnfield", ["CUP_10x_303_M"]],              // Lee-Enfield
    ["CUP_srifle_M14", ["CUP_20Rnd_762x51_DMR"]],              // M14
    ["CUP_lmg_L7A2", ["CUP_100Rnd_TE4_LRT4_762x51_Belt_M"]],   // L7A2
    ["CUP_lmg_M60E4", ["CUP_100Rnd_TE4_LRT4_762x51_Belt_M"]],  // M60E4
    ["CUP_lmg_Mk48", ["CUP_100Rnd_TE4_LRT4_762x51_Belt_M"]],   // Mk48
    ["CUP_sgun_Saiga12K", ["CUP_8Rnd_B_Saiga12_74Slug_M"]],    // Saiga 12K
    ["CUP_smg_UZI", ["CUP_32Rnd_9x19_UZI_M"]],                 // UZI
    ["CUP_smg_bizon", ["CUP_64Rnd_9x19_Bizon_M"]],             // PP-19 Bizon
    ["CUP_arifle_AK107", ["CUP_30Rnd_545x39_AK_M"]],           // AK-107
    ["CUP_arifle_AKS74", ["CUP_30Rnd_545x39_AK_M"]],           // AKS-74
    ["CUP_arifle_CZ805_A1", ["CUP_30Rnd_556x45_CZ805"]],       // CZ805 BREN A1
    ["CUP_arifle_CZ805_B", ["CUP_30Rnd_556x45_CZ805"]],        // CZ805 BREN B
    ["CUP_arifle_CZ805_GL", ["CUP_30Rnd_556x45_CZ805"]],       // CZ805 BREN A1 (GL)
    ["CUP_arifle_FAMAS_F1", ["CUP_25Rnd_556x45_Famas"]],       // FAMAS F1
    ["CUP_arifle_Galil_black", ["CUP_35Rnd_556x45_Galil"]],    // IMI Galil (Black)
    ["CUP_arifle_Galil_SAR_black", ["CUP_35Rnd_556x45_Galil"]],// IMI Galil SAR (Black)
    ["CUP_arifle_HK53", ["CUP_30Rnd_556x45_Stanag"]],          // HK53
    ["CUP_arifle_L85A2_G", ["CUP_30Rnd_556x45_Stanag"]],       // L85A2 (Grip)
    ["CUP_arifle_L86A2", ["CUP_30Rnd_556x45_Stanag"]],         // L86A2 LSW
    ["CUP_arifle_MG36", ["CUP_100Rnd_556x45_BetaCMag"]],       // MG36
    ["CUP_arifle_M16A4_Base", ["CUP_30Rnd_556x45_Stanag"]],    // M16A4
    ["CUP_arifle_M16A4_GL", ["CUP_30Rnd_556x45_Stanag"]],      // M16A4 (GL)
    ["CUP_arifle_M4A1_black", ["CUP_30Rnd_556x45_Stanag"]],    // M4A1 (Black)
    ["CUP_arifle_M4A1_desert", ["CUP_30Rnd_556x45_Stanag"]],   // M4A1 (Desert)
    ["CUP_arifle_M4A1_wdl", ["CUP_30Rnd_556x45_Stanag"]],      // M4A1 (Woodland)
    ["CUP_arifle_Mk16_CQC", ["CUP_30Rnd_556x45_Stanag"]],      // Mk16 SCAR-L CQC
    ["CUP_arifle_Mk16_CQC_FG", ["CUP_30Rnd_556x45_Stanag"]],   // Mk16 SCAR-L CQC (Foregrip)
    ["CUP_arifle_Mk16_CQC_SFG", ["CUP_30Rnd_556x45_Stanag"]],  // Mk16 SCAR-L CQC (Short Foregrip)
    ["CUP_arifle_Mk16_STD_FG", ["CUP_30Rnd_556x45_Stanag"]],   // Mk16 SCAR-L Standard (Foregrip)
    ["CUP_arifle_Mk16_STD_SFG", ["CUP_30Rnd_556x45_Stanag"]],  // Mk16 SCAR-L Standard (Short Foregrip)
    ["CUP_arifle_Mk16_SV", ["CUP_30Rnd_556x45_Stanag"]],       // Mk16 SCAR-L Sniper Variant
    ["CUP_arifle_Mk17_CQC", ["CUP_20Rnd_762x51_B_SCAR"]],      // Mk17 SCAR-H CQC
    ["CUP_arifle_Mk17_CQC_FG", ["CUP_20Rnd_762x51_B_SCAR"]],   // Mk17 SCAR-H CQC (Foregrip)
    ["CUP_arifle_Mk17_CQC_SFG", ["CUP_20Rnd_762x51_B_SCAR"]],  // Mk17 SCAR-H CQC (Short Foregrip)
    ["CUP_arifle_Mk17_STD", ["CUP_20Rnd_762x51_B_SCAR"]],      // Mk17 SCAR-H Standard
    ["CUP_arifle_Mk17_STD_FG", ["CUP_20Rnd_762x51_B_SCAR"]],   // Mk17 SCAR-H Standard (Foregrip)
    ["CUP_arifle_Mk17_STD_SFG", ["CUP_20Rnd_762x51_B_SCAR"]],  // Mk17 SCAR-H Standard (Short Foregrip)
    ["CUP_arifle_Mk17_SV", ["CUP_20Rnd_762x51_B_SCAR"]],       // Mk17 SCAR-H Sniper Variant
    ["CUP_arifle_Mk20", ["CUP_20Rnd_762x51_B_SCAR"]],          // Mk20 Sniper Rifle (SCAR-H DMR)
    ["CUP_arifle_QBZ95_rail", ["CUP_30Rnd_556x45_Stanag"]],    // QBZ-95 (Rail)
    ["CUP_arifle_XM8_Carbine", ["CUP_30Rnd_556x45_Stanag"]],   // XM8 Carbine
    ["CUP_arifle_XM8_Compact", ["CUP_30Rnd_556x45_Stanag"]],   // XM8 Compact
    ["CUP_arifle_XM8_Railed", ["CUP_30Rnd_556x45_Stanag"]],    // XM8 Railed
    ["CUP_arifle_XM8_SAW", ["CUP_100Rnd_556x45_BetaCMag"]],    // XM8 LMG
    ["CUP_arifle_XM8_Sniper", ["CUP_30Rnd_556x45_Stanag"]],    // XM8 Sniper Variant
    ["CUP_arifle_XM8_CarbineGL", ["CUP_30Rnd_556x45_Stanag"]], // XM8 Carbine (GL)
    ["CUP_lmg_L110A1", ["CUP_200Rnd_TE4_Red_Tracer_556x45_M249"]], // L110A1 Minimi
    ["CUP_lmg_L7A2", ["CUP_100Rnd_TE4_LRT4_762x51_Belt_M"]],   // L7A2 GPMG
    ["CUP_lmg_L110A1", ["CUP_200Rnd_TE4_Red_Tracer_556x45_M249"]], // L110A1 Minimi
    ["CUP_lmg_M249_E2", ["CUP_200Rnd_TE4_Red_Tracer_556x45_M249"]], // M249 SAW
    ["CUP_lmg_MG3", ["CUP_120Rnd_TE4_LRT4_762x51_Belt_M"]],    // MG3
    ["CUP_lmg_M60E4", ["CUP_100Rnd_TE4_LRT4_762x51_Belt_M"]],  // M60E4
    ["CUP_lmg_Mk48", ["CUP_100Rnd_TE4_LRT4_762x51_Belt_M"]],   // Mk48
    ["CUP_srifle_LeeEnfield", ["CUP_10x_303_M"]],              // Lee-Enfield No.4 Mk1
    ["CUP_srifle_M14", ["CUP_20Rnd_762x51_DMR"]],              // M14 DMR
    ["CUP_srifle_M40A3", ["CUP_5Rnd_762x51_M24"]],             // M40A3 Sniper Rifle
    ["CUP_srifle_M110", ["CUP_20Rnd_762x51_B_SCAR"]],          // M110 SASS
    ["CUP_srifle_M24_wdl", ["CUP_5Rnd_762x51_M24"]],           // M24 Woodland
    ["CUP_srifle_M24_blk", ["CUP_5Rnd_762x51_M24"]],           // M24 Black
    ["CUP_srifle_M21", ["CUP_20Rnd_762x51_DMR"]],              // M21 DMR
    ["CUP_srifle_SVD", ["CUP_10Rnd_762x54_SVD_M"]],            // Dragunov SVD
    ["CUP_srifle_VSSVintorez", ["CUP_20Rnd_9x39_SP5_VSS_M"]],  // VSS Vintorez
    ["CUP_srifle_AS50", ["CUP_5Rnd_127x99_as50_M"]],           // AS50 Sniper Rifle
    ["CUP_srifle_M107_Base", ["CUP_10Rnd_127x99_M107"]],       // M107 Anti-Material Rifle
    ["CUP_srifle_AWM_wdl", ["CUP_5Rnd_86x70_L115A1"]],         // L115A3 AWM (Woodland)
    ["CUP_srifle_AWM_blk", ["CUP_5Rnd_86x70_L115A1"]],         // L115A3 AWM (Black)
    ""                                                         // No Primary Weapon
]],
["_secondaryWeaponsPool", [
    // Vanilla Arma 3 Handguns
    ["hgun_ACPC2_F", ["9Rnd_45ACP_Mag"]],                 // ACP-C2 .45
    ["hgun_Pistol_heavy_01_F", ["11Rnd_45ACP_Mag"]],      // 4-five .45
    ["hgun_Pistol_heavy_02_F", ["6Rnd_45ACP_Cylinder"]],  // Zubr .45
    ["hgun_P07_F", ["16Rnd_9x21_Mag"]],                   // P07 9 mm
    ["hgun_Rook40_F", ["16Rnd_9x21_Mag"]],                // Rook-40 9 mm
    ["hgun_Pistol_01_F", ["10Rnd_9x21_Mag"]],             // PM 9 mm (Apex DLC)
    ["hgun_Pistol_Signal_F", ["6Rnd_GreenSignal_F"]],     // Starter Pistol (Green Signal)
    ["hgun_Pistol_Signal_F", ["6Rnd_RedSignal_F"]],       // Starter Pistol (Red Signal)

    // CUP Handguns
    ["CUP_hgun_Makarov", ["CUP_8Rnd_9x18_Makarov_M"]],    // Makarov PM
    ["CUP_hgun_Glock17", ["CUP_17Rnd_9x19_glock17"]],     // Glock 17
    ["CUP_hgun_Browning_HP", ["CUP_13Rnd_9x19_Browning_HP"]], // Browning Hi-Power
    ["CUP_hgun_CZ75", ["CUP_16Rnd_9x19_CZ75"]],           // CZ 75
    ["CUP_hgun_Colt1911", ["CUP_7Rnd_45ACP_1911"]],       // Colt 1911
    ["CUP_hgun_Compact", ["CUP_18Rnd_9x19_Phantom"]],     // CZ 75 P-07 Duty
    ["CUP_hgun_Duty", ["CUP_16Rnd_9x19_CZ75"]],           // CZ 75 Duty
    ["CUP_hgun_Phantom", ["CUP_18Rnd_9x19_Phantom"]],     // CZ 75 SP-01 Phantom
    ["CUP_hgun_TaurusTracker455", ["CUP_6Rnd_45ACP_M"]],  // Taurus Tracker .455
    ["CUP_hgun_TaurusTracker455_gold", ["CUP_6Rnd_45ACP_M"]], // Taurus Tracker .455 (Gold)
    ["CUP_hgun_SA61", ["CUP_20Rnd_B_765x17_Ball_M"]],     // Sa.61
    ["CUP_hgun_TT", ["CUP_8Rnd_762x25_TT"]],              // Tokarev TT-33
    ["CUP_hgun_PB6P9", ["CUP_8Rnd_9x18_Makarov_M"]],      // PB 6P9
    ["CUP_hgun_SA61", ["CUP_20Rnd_B_765x17_Ball_M"]],     // Sa.61 Skorpion
    ["CUP_hgun_Colt1911", ["CUP_7Rnd_45ACP_1911"]],       // Colt M1911
    ["CUP_hgun_Colt1911_dirty", ["CUP_7Rnd_45ACP_1911"]], // Colt M1911 (Dirty)
    ["CUP_hgun_Colt1911_silver", ["CUP_7Rnd_45ACP_1911"]],// Colt M1911 (Silver)
    ["CUP_hgun_Duty_M3X", ["CUP_16Rnd_9x19_CZ75"]],       // CZ 75 Duty (M3X)
    ["CUP_hgun_Glock17_blk", ["CUP_17Rnd_9x19_glock17"]], // Glock 17 (Black)
    ["CUP_hgun_Glock17_tan", ["CUP_17Rnd_9x19_glock17"]], // Glock 17 (Tan)
    ["CUP_hgun_MicroUzi", ["CUP_30Rnd_9x19_UZI"]],        // Micro Uzi
    ["CUP_hgun_MicroUzi_snds", ["CUP_30Rnd_9x19_UZI"]],   // Micro Uzi (Suppressed)
    ["CUP_hgun_P226", ["CUP_15Rnd_9x19_P226"]],           // SIG P226
    ["CUP_hgun_SA61", ["CUP_20Rnd_B_765x17_Ball_M"]],     // Sa.61 Skorpion
    ["CUP_hgun_TEC9", ["CUP_32Rnd_9x19_TEC9"]],           // TEC-9
    ["CUP_hgun_TEC9_F", ["CUP_32Rnd_9x19_TEC9"]],         // TEC-9 (Full Auto)
    ["CUP_hgun_UZI", ["CUP_32Rnd_9x19_UZI"]],             // Uzi
    ["CUP_hgun_SWM327MP", ["CUP_8Rnd_357_Magnum"]],       // Smith & Wesson M&P R8 Model 327
    ["CUP_hgun_SWM327MP_reddot", ["CUP_8Rnd_357_Magnum"]],// S&W M&P R8 Model 327 (Red Dot)
    ["CUP_hgun_SWM327MP_reddot_flash", ["CUP_8Rnd_357_Magnum"]], // S&W M&P R8 Model 327 (Red Dot & Flashlight)
    ["CUP_hgun_Deagle", ["CUP_7Rnd_50AE_Deagle"]],        // Desert Eagle
    ["CUP_hgun_Deagle_gold", ["CUP_7Rnd_50AE_Deagle"]],   // Desert Eagle (Gold)
    ["CUP_hgun_Deagle_silver", ["CUP_7Rnd_50AE_Deagle"]], // Desert Eagle (Silver)
    ["CUP_hgun_M9", ["CUP_15Rnd_9x19_M9"]],               // Beretta M9
    ["CUP_hgun_M9_snds", ["CUP_15Rnd_9x19_M9"]],          // Beretta M9 (Suppressed)
    ["CUP_hgun_MP5K", ["CUP_30Rnd_9x19_MP5"]],            // MP5K
    ["CUP_hgun_MP5SD6", ["CUP_30Rnd_9x19_MP5"]],          // MP5SD6
    ["CUP_hgun_MP5SD6", ["CUP_30Rnd_9x19_MP5"]],          // MP5SD6
    ["CUP_hgun_MP7", ["CUP_40Rnd_46x30_MP7"]],           // MP7
    ["CUP_hgun_MP7_snds", ["CUP_40Rnd_46x30_MP7"]],      // MP7 (Suppressed)
    ["CUP_hgun_MP7_Flashlight", ["CUP_40Rnd_46x30_MP7"]], // MP7 (Flashlight)
    ["CUP_hgun_SteyrMPi69", ["CUP_25Rnd_9x19_steyrMPi"]], // Steyr MPi 69
    ["CUP_hgun_Mk23", ["CUP_12Rnd_45ACP_mk23"]],         // Mk23 SOCOM
    ["CUP_hgun_Mk23_snds", ["CUP_12Rnd_45ACP_mk23"]],    // Mk23 SOCOM (Suppressed)
    ["CUP_hgun_Mk23_lam", ["CUP_12Rnd_45ACP_mk23"]],     // Mk23 SOCOM (Laser)
    ["CUP_hgun_Mk23_snds_lam", ["CUP_12Rnd_45ACP_mk23"]], // Mk23 SOCOM (Suppressed + Laser)
    ["CUP_hgun_PB6P9_snds", ["CUP_8Rnd_9x18_Makarov_M"]], // PB 6P9 (Suppressed Makarov)
    ["CUP_hgun_P226_snds", ["CUP_15Rnd_9x19_P226"]],      // SIG P226 (Suppressed)
    ["CUP_hgun_UZI_snds", ["CUP_32Rnd_9x19_UZI"]],       // UZI (Suppressed)
    ["CUP_hgun_TEC9_snds", ["CUP_32Rnd_9x19_TEC9"]],     // TEC-9 (Suppressed)
    ["CUP_hgun_TEC9_F_snds", ["CUP_32Rnd_9x19_TEC9"]],   // TEC-9 Full Auto (Suppressed)
    ["CUP_hgun_SA61_snds", ["CUP_20Rnd_B_765x17_Ball_M"]], // Sa.61 Skorpion (Suppressed)
    ["CUP_hgun_MP5A5", ["CUP_30Rnd_9x19_MP5"]],          // MP5A5
    ["CUP_hgun_MP5A5_snds", ["CUP_30Rnd_9x19_MP5"]],     // MP5A5 (Suppressed)
    ["CUP_hgun_Glock18", ["CUP_33Rnd_9x19_Glock17"]],    // Glock 18 (Full Auto)
    ["CUP_hgun_Glock18_snds", ["CUP_33Rnd_9x19_Glock17"]], // Glock 18 (Suppressed)
    ["CUP_hgun_MAC10", ["CUP_30Rnd_45ACP_MAC10_M"]],     // MAC-10
    ["CUP_hgun_MAC10_snds", ["CUP_30Rnd_45ACP_MAC10_M"]], // MAC-10 (Suppressed)
    ["CUP_hgun_FlareGun", ["CUP_1Rnd_FlareWhite_M"]],    // Flare Gun (White)
    ["CUP_hgun_FlareGun_R", ["CUP_1Rnd_FlareRed_M"]],    // Flare Gun (Red)
    ["CUP_hgun_FlareGun_G", ["CUP_1Rnd_FlareGreen_M"]],  // Flare Gun (Green)
    ["CUP_hgun_FlareGun_Y", ["CUP_1Rnd_FlareYellow_M"]],  // Flare Gun (Yellow)
    ""                                                   // No Secondary
    ]],
    ["_grenadePool", [
    // Vanilla Grenades
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

    // CUP Grenades
    "CUP_HandGrenade_RGD5",     // RGD-5 Fragmentation Grenade
    "CUP_HandGrenade_M67",      // M67 Fragmentation Grenade
    "CUP_HandGrenade_L109A1_HE",// L109A1 High-Explosive Grenade
    "CUP_HandGrenade_DM51",     // DM51 Fragmentation Grenade
    "CUP_HandGrenade_DM51A1",   // DM51A1 Fragmentation Grenade
    "CUP_HandGrenade_Type82",   // Type 82 Fragmentation Grenade
    "CUP_HandGrenade_F1",       // F1 Defensive Grenade
    "CUP_HandGrenade_RGO",      // RGO Offensive Grenade
    "CUP_HandGrenade_RGN",      // RGN Offensive Grenade
    "CUP_HandGrenade_ANM8",     // AN-M8 HC Smoke Grenade
    "CUP_HandGrenade_M18_Red",  // M18 Smoke Grenade (Red)
    "CUP_HandGrenade_M18_Green",// M18 Smoke Grenade (Green)
    "CUP_HandGrenade_M18_Yellow",// M18 Smoke Grenade (Yellow)
    "CUP_HandGrenade_M18_Purple",// M18 Smoke Grenade (Purple)
    "CUP_HandGrenade_M18_Blue", // M18 Smoke Grenade (Blue)
    "CUP_HandGrenade_M18_Orange",// M18 Smoke Grenade (Orange)
    "CUP_HandGrenade_M14",      // M14 Incendiary Grenade
    "CUP_HandGrenade_M34",       // M34 White Phosphorus Grenade
    ""                          // No nade
    ]],
    /*["_uniformPool", [
        "U_O_CombatUniform_ocamo",
        "U_B_CombatUniform_mcam",
        "U_I_CombatUniform",
        "U_BG_Guerilla2_1",
        "U_B_CTRG_Soldier_3_F"
    ]],*/
    ["_uniformPool", [
    "CUP_U_I_GUE_Flecktarn",        // Flecktarn Camo
    "CUP_U_I_GUE_2",                // Green Jacket
    "CUP_U_I_GUE_3",                // Grey Jacket
    "CUP_U_I_GUE_4",                // Black Jacket
    "CUP_U_I_GUE_5",                // Blue Jacket
    "CUP_U_I_GUE_6",                // Red Jacket
    "CUP_U_I_GUE_7",                // Yellow Jacket
    "CUP_U_I_GUE_8",                // Purple Jacket
    "CUP_U_I_GUE_9",                // Orange Jacket
    "CUP_U_I_GUE_10",               // White Jacket
    "CUP_U_O_TK_Green",             // Takistani Army (Green Fatigues)
    "CUP_U_O_TK_Ghillie_Top",       // Takistani Sniper Ghillie Top
    "CUP_U_O_TK_Officer",           // Takistani Army Officer Uniform
    "CUP_U_O_TK_MixedCamo",         // Takistani Army Mixed Camo
    "CUP_U_O_TK_Ghillie",           // Takistani Sniper Ghillie Suit
    "CUP_U_O_TK_Desert_Camo",       // Takistani Army Desert Camo
    "CUP_U_O_TK_FullCamo",          // Takistani Army Full Camo
    "CUP_U_O_TK_Kamish",            // Takistani Paramilitary Uniform
    "CUP_U_O_TK_Soldier_Sleeves",   // Takistani Soldier (Rolled Sleeves)
    "CUP_U_O_TK_SpecialForces"      // Takistani Special Forces Outfit
    ]],
["_vestPool", [
    "V_PlateCarrier1_rgr",        // Carrier Lite (Green)
    "V_PlateCarrier2_rgr",        // Carrier Rig (Green)
    "V_PlateCarrier3_rgr",        // Carrier GL Rig (Green)
    "V_PlateCarrierGL_rgr",       // Carrier GL Rig (Green)
    "V_PlateCarrierIA1_dgtl",     // GA Carrier Lite (Digi)
    "V_PlateCarrierIA2_dgtl",     // GA Carrier Rig (Digi)
    "V_PlateCarrierSpec_rgr",     // Carrier Special Rig (Green)
    "V_PlateCarrierSpec_blk",     // Carrier Special Rig (Black)
    "V_TacVest_blk",              // Tactical Vest (Black)
    "V_TacVest_brn",              // Tactical Vest (Brown)
    "V_TacVest_camo",             // Tactical Vest (Camo)
    "V_TacVest_khk",              // Tactical Vest (Khaki)
    "V_TacVest_oli",              // Tactical Vest (Olive)
    "V_TacVestIR_blk",            // Tactical Vest (Black - IR)
    "V_TacChestrig_grn_F",        // Tactical Chest Rig (Green)
    "V_TacChestrig_oli_F",        // Tactical Chest Rig (Olive)
    "V_TacChestrig_cbr_F",        // Tactical Chest Rig (Coyote)
    "V_Chestrig_khk",             // Chest Rig (Khaki)
    "V_Chestrig_rgr",             // Chest Rig (Green)
    "V_Chestrig_blk",             // Chest Rig (Black)
    "V_Chestrig_oli",             // Chest Rig (Olive)
    "V_BandollierB_khk",          // Slash Bandolier (Khaki)
    "V_BandollierB_cbr",          // Slash Bandolier (Coyote)
    "V_BandollierB_rgr",          // Slash Bandolier (Green)
    "V_BandollierB_blk",          // Slash Bandolier (Black)
    "V_BandollierB_oli",          // Slash Bandolier (Olive)
    "V_HarnessO_brn",             // LBV Harness (Brown)
    "V_HarnessOGL_brn",           // LBV Grenadier Harness (Brown)
    "V_HarnessO_gry",             // LBV Harness (Gray)
    "V_HarnessOGL_gry",           // LBV Grenadier Harness (Gray)
    "V_HarnessOSpec_brn",         // LBV Specialist Harness (Brown)
    "V_HarnessOSpec_gry",         // LBV Specialist Harness (Gray)
    "V_HarnessO_ghex_F",          // LBV Harness (Green Hex)
    "V_HarnessOGL_ghex_F",        // LBV Grenadier Harness (Green Hex)
    "V_HarnessOSpec_ghex_F",      // LBV Specialist Harness (Green Hex)
    "V_PlateCarrier1_blk",        // Carrier Lite (Black)
    "V_PlateCarrier1_tna_F",      // Carrier Lite (Tropic)
    "V_PlateCarrier2_blk",        // Carrier Rig (Black)
    "V_PlateCarrier2_tna_F",      // Carrier Rig (Tropic)
    "V_PlateCarrierGL_blk",       // Carrier GL Rig (Black)
    "V_PlateCarrierGL_tna_F",     // Carrier GL Rig (Tropic)
    "V_PlateCarrierSpec_tna_F",   // Carrier Special Rig (Tropic)
    "V_PlateCarrierSpec_mtp",     // Carrier Special Rig (MTP)
    "V_PlateCarrierSpec_ghex_F",  // Carrier Special Rig (Green Hex)
    "V_PlateCarrier1_rgr_noflag_F", // Carrier Lite (Green, No Flag)
    "V_PlateCarrier2_rgr_noflag_F", // Carrier Rig (Green, No Flag)
    "V_PlateCarrierGL_rgr_noflag_F", // Carrier GL Rig (Green, No Flag)
    "V_PlateCarrierSpec_rgr_noflag_F", // Carrier Special Rig (Green, No Flag)
    "V_Safety_yellow_F",          // Safety Vest (Yellow)
    "V_Safety_orange_F",          // Safety Vest (Orange)
    "V_Safety_blue_F",            // Safety Vest (Blue)
    "V_RebreatherB",              // Rebreather [NATO]
    "V_RebreatherIR",             // Rebreather [CSAT]
    "V_RebreatherIA",             // Rebreather [AAF]
    "V_EOD_blue_F",               // EOD Vest (Blue)
    "V_EOD_coyote_F",             // EOD Vest (Coyote)
    "V_EOD_IDAP_blue_F",          // EOD Vest (IDAP)
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
    ""                            // No Vest
    ]],
["_bagPool", [
    "B_AssaultPack_blk",           // Assault Pack (Black)
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
    "B_RadioBag_01_tropic_F",      // Radio Pack (Tropic)
    "B_TacticalPack_blk",          // Tactical Backpack (Black)
    "B_TacticalPack_mcamo",        // Tactical Backpack (MTP)
    "B_TacticalPack_ocamo",        // Tactical Backpack (Hex)
    "B_TacticalPack_oli",          // Tactical Backpack (Olive)
    "B_TacticalPack_rgr",          // Tactical Backpack (Green)
    "B_ViperHarness_blk_F",        // Viper Harness (Black)
    "B_ViperHarness_ghex_F",       // Viper Harness (Green Hex)
    "B_ViperHarness_hex_F",        // Viper Harness (Hex)
    "B_ViperHarness_khk_F",        // Viper Harness (Khaki)
    "B_ViperHarness_oli_F",        // Viper Harness (Olive)
    "B_ViperLightHarness_blk_F",   // Viper Light Harness (Black)
    "B_ViperLightHarness_ghex_F",  // Viper Light Harness (Green Hex)
    "B_ViperLightHarness_hex_F",   // Viper Light Harness (Hex)
    "B_ViperLightHarness_khk_F",   // Viper Light Harness (Khaki)
    "B_ViperLightHarness_oli_F",   // Viper Light Harness (Olive)
    ""                             // No Backpack
    ]],
    ["_headgearPool", [
    "H_HelmetSpecB",               // Enhanced Combat Helmet
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
    "H_Booniehat_dgtl",            // Booniehat [AAF]
    "H_Booniehat_dirty",           // Booniehat (Dirty)
    "H_Booniehat_eaf",             // Booniehat [LDF]
    "H_Booniehat_grn",             // Booniehat (Green)
    "H_Booniehat_indp",            // Booniehat (Khaki)
    "H_Booniehat_khk_hs",          // Booniehat (Headset)
    "H_Booniehat_mcamo",           // Booniehat (MTP)
    "H_Booniehat_ocamo",           // Booniehat (Hex)
    "H_Booniehat_tan",             // Booniehat (Tan)
    "H_Booniehat_tna_F",           // Booniehat (Tropic)
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
    ""                                 // NO hat/helmet
    ]], 
    ["_medkits", ["FirstAidKit", "Medikit"]],      // Array of medical items
    ["_skillRange", [0.2, 0.8]]                    // Array [minSkill, maxSkill] for enemy skill level
];


// Create global variables to track state
private _processedBuildings = []; // Stores buildings with cooldowns
private _processedRoads = [];     // Stores roads with cooldowns
private _cooldownTime = 300;      // Cooldown time in seconds
private _activeEnemies = [];      // Tracks currently active enemies


private _spawnEnemies = {
    params ["_location", "_type"];

    // Check current enemy count
    if (count _activeEnemies >= _maxTotalEnemies) exitWith {
        diag_log format ["[AI Spawner] Maximum enemy limit (%1) reached. Skipping %2 at %3.", _maxTotalEnemies, _type, getPos _location];
    };

    // Skip if the location has already been processed
    private _currentTime = time;
    private _processedLocations = if (_type == "building") then {_processedBuildings} else {_processedRoads};

    private _foundLocation = _processedLocations select { _x select 0 == _location };

    // Ensure _foundLocation is valid before accessing its elements
    if ((count _foundLocation > 0) && { _currentTime - (_foundLocation select 0 select 1) < _cooldownTime }) exitWith {
        diag_log format ["[AI Spawner] Skipped %1 at %2 due to cooldown.", _type, getPos _location];
    };

    // Remove expired cooldowns
    if (_type == "building") then {
        _processedBuildings = _processedBuildings select { _currentTime - (_x select 1) < _cooldownTime };
    } else {
        _processedRoads = _processedRoads select { _currentTime - (_x select 1) < _cooldownTime };
    };

    // Random chance to spawn
    if (random 1 > _spawnChance) exitWith {};

    // Add location to the processed list
    if (_type == "building") then {
        _processedBuildings pushBack [_location, _currentTime];
    } else {
        _processedRoads pushBack [_location, _currentTime];
    };

    // Determine number of enemies to spawn
    private _minEnemies = _enemyCountRange select 0;
    private _maxEnemies = _enemyCountRange select 1;
    private _enemyCount = floor (random (_maxEnemies - _minEnemies + 1)) + _minEnemies;

    diag_log format ["[AI Spawner] Spawning %1 enemies near %2 at %3", _enemyCount, _type, getPos _location];

    for "_i" from 1 to _enemyCount do {
        // Randomize spawn position near location
        private _spawnPos = _location getPos [random 10, random 360];

        // Ensure spawn distance from player
        if (player distance _spawnPos < _minDistance) exitWith {};

        // Get nearest town name
        private _nearestTown = "UnknownArea";
        private _locationName = nearestLocations [_spawnPos, ["NameCity", "NameVillage", "NameLocal"], 1000];
        if (count _locationName > 0) then {
            _nearestTown = text (_locationName select 0);
        };

        // Maintain global counter for unique names
        if (isNil "ENEMY_COUNTER") then { ENEMY_COUNTER = 0; };
        ENEMY_COUNTER = ENEMY_COUNTER + 1;

        // Create enemy unit
        private _enemy = createGroup east createUnit [
            "O_G_Soldier_F",  // Example unit class
            _spawnPos,
            [],
            0.5,
            "FORM"
        ];

        // Assign a unique name to the enemy
        private _enemyName = format ["%1_%2", _nearestTown, ENEMY_COUNTER];
        _enemy setName _enemyName;

        diag_log format ["[AI Spawner] Spawned enemy %1 at position %2", _enemyName, _spawnPos];

        // Add MP event handler to track kills
        _enemy addMPEventHandler ["MPKilled", {
        params ["_unit", "_killer", "_instigator", "_useEffects"];

        if (isNull _unit) exitWith { diag_log "[AI Spawner] Kill event handler triggered with null unit."; };
        if (isNull _killer) then { diag_log "[AI Spawner] Killer is null, likely an environmental death."; };

        // Get sides and names
        private _sideDeadUnit = side group _unit;
        private _sideKiller = if (isNull _killer) then {"Unknown"} else {side group _killer};
        private _deadUnitName = name _unit; // Directly fetch the name set by setName
        private _killerName = if (isNull _killer) then {"Environment"} else {name _killer};

        // Log kill event
        diag_log format ["[AI Spawner] Enemy killed: %1 %2 by %3 %4", _sideDeadUnit, _deadUnitName, _sideKiller, _killerName];

        // Check and delete group if empty
        private _group = group _unit;
        if (!isNull _group && {count units _group == 0}) then {
            deleteGroup _group;
            diag_log format ["[AI Spawner] Group %1 deleted as it was empty.", _group];
        };

        if (isPlayer _killer) then {
            private _distance = _killer distance _unit;
            private _currentMax = _killer getVariable ["MaxKillDistance", 0];

            if (_distance > _currentMax) then {
                _killer setVariable ["MaxKillDistance", _distance, true];
            };

            diag_log format ["HUD: %1 killed %2 at %3m", name _killer, name _unit, _distance];
        };   
    }];

_activeEnemies pushBack _enemy;

// Define fallback Arma 3 stock gear
private _fallbackUniform = "U_B_CombatUniform_mcam";
private _fallbackVest = "V_PlateCarrier1_rgr";
private _fallbackBackpack = "B_AssaultPack_mcamo";
private _fallbackHeadgear = "H_HelmetB";
private _fallbackPrimary = "arifle_MX_F";
private _fallbackSecondary = "hgun_P07_F";
private _fallbackMagazines = ["30Rnd_65x39_caseless_mag"];
private _fallbackGrenade = "HandGrenade";

// Apply uniform
private _uniform = selectRandom _uniformPool;
if (!isNil "_uniform" && {isClass (configFile >> "CfgWeapons" >> _uniform)}) then {
    _enemy forceAddUniform _uniform;
} else {
    diag_log format ["WARNING: Invalid uniform %1, using fallback %2", _uniform, _fallbackUniform];
    _enemy forceAddUniform _fallbackUniform;
};

// Apply vest
private _vest = selectRandom _vestPool;
if (!isNil "_vest" && {isClass (configFile >> "CfgWeapons" >> _vest)}) then {
    _enemy addVest _vest;
} else {
    diag_log format ["WARNING: Invalid vest %1, using fallback %2", _vest, _fallbackVest];
    _enemy addVest _fallbackVest;
};

// Apply backpack
private _backpack = selectRandom _bagPool;
if (!isNil "_backpack" && {isClass (configFile >> "CfgVehicles" >> _backpack)}) then {
    _enemy addBackpack _backpack;
} else {
    diag_log format ["WARNING: Invalid backpack %1, using fallback %2", _backpack, _fallbackBackpack];
    _enemy addBackpack _fallbackBackpack;
};

// Apply headgear
private _headgear = selectRandom _headgearPool;
if (!isNil "_headgear" && {isClass (configFile >> "CfgWeapons" >> _headgear)}) then {
    _enemy addHeadgear _headgear;
} else {
    diag_log format ["WARNING: Invalid headgear %1, using fallback %2", _headgear, _fallbackHeadgear];
    _enemy addHeadgear _fallbackHeadgear;
};

// Select primary weapon and magazines
private _equipment = selectRandom _equipmentPool;
if (!isNil "_equipment" && {typeName _equipment == "ARRAY"} && {count _equipment > 1}) then {
    private _weapon = _equipment select 0;
    private _magazines = _equipment select 1;

    if (!isNil "_weapon" && {isClass (configFile >> "CfgWeapons" >> _weapon)}) then {
        _enemy addWeapon _weapon;
    } else {
        diag_log format ["WARNING: Invalid weapon %1, using fallback %2", _weapon, _fallbackPrimary];
        _enemy addWeapon _fallbackPrimary;
        _magazines = _fallbackMagazines;  // Assign fallback magazines
    };

    {
        if (!isNil "_x" && {isClass (configFile >> "CfgMagazines" >> _x)}) then {
            _enemy addMagazine _x;
        } else {
            diag_log format ["WARNING: Invalid magazine %1, using fallback %2", _x, _fallbackMagazines select 0];
            _enemy addMagazine (_fallbackMagazines select 0);
        };
    } forEach _magazines;
};


// Randomize secondary weapon loadout
private _secondary = selectRandom _secondaryWeaponsPool;
if (!isNil "_secondary" && {typeName _secondary == "ARRAY"} && {count _secondary > 1}) then {
    private _weapon = _secondary select 0;
    private _magazines = _secondary select 1;

    if (!isNil "_weapon" && {isClass (configFile >> "CfgWeapons" >> _weapon)}) then {
        _enemy addWeapon _weapon;
    } else {
        diag_log format ["WARNING: Invalid secondary weapon %1, using fallback %2", _weapon, _fallbackSecondary];
        _enemy addWeapon _fallbackSecondary;
        _magazines = _fallbackMagazines; // Use fallback ammo
    };

    {
        if (!isNil "_x" && {isClass (configFile >> "CfgMagazines" >> _x)}) then {
            _enemy addMagazine _x;
        } else {
            diag_log format ["WARNING: Invalid secondary magazine %1, using fallback %2", _x, _fallbackMagazines select 0];
            _enemy addMagazine (_fallbackMagazines select 0);
        };
    } forEach _magazines;
};


// Assign grenades
private _grenadeCount = floor (random 3) + 1; // Randomize grenade count (1-3)
for "_i" from 1 to _grenadeCount do {
    private _grenade = selectRandom _grenadePool;
    if (isClass (configFile >> "CfgMagazines" >> _grenade)) then {
        _enemy addMagazine _grenade;
    } else {
        diag_log format ["WARNING: Invalid grenade %1, using fallback %2", _grenade, _fallbackGrenade];
        _enemy addMagazine _fallbackGrenade;
    };
};


        _enemy addItem selectRandom _medkits;

        // Randomize skill level
        private _minSkill = _skillRange select 0;
        private _maxSkill = _skillRange select 1;
        private _skill = random (_maxSkill - _minSkill) + _minSkill;
        _enemy setSkill _skill;

        // ** Add Movement Logic for the Enemy **
        _enemy spawn {
            private _unit = _this;
            while {alive _unit} do {
                sleep selectRandom [15, 30]; // Random wait between moves (15 to 30 seconds)
                private _newPos = position _unit getPos [random 50 + 10, random 360]; // New random position within 50m
                _unit doMove _newPos;
            };
        };
    };
};



// Function to get roads within range
private _getRoads = {
    private _playerPos = getPosATL player;
    nearestTerrainObjects [_playerPos, ["ROAD", "POWER LINES", "BUSSTOP", "MAIN ROAD", "TRAIL", "WALL"], _maxDistance]
};

// Function to get buildings within range
private _getBuildings = {
    private _playerPos = getPosATL player;
    //nearestObjects [_playerPos, ["House", "Building"], _maxDistance]
    nearestTerrainObjects [_playerPos, ["BUILDING", "BUNKER", "CHAPEL", "CHURCH", "FORTRESS", "FUELSTATION", "HOSPITAL", "HOUSE", "RUIN", "SHIPWRECK", "TOURISM", "TRANSMITTER", "VIEW-TOWER",  "WATERTOWER"], _maxDistance]
};

// Main Execution
private _spawnLoop = {
    while {true} do {
        // Clean up enemies outside the cleanup distance
        private _remainingEnemies = [];
        {
            if (player distance _x > _cleanupDistance) then {
                deleteVehicle _x;
                diag_log format ["[AI Spawner] Deleted enemy %1 as it left the cleanup range.", _x];
            } else {
                _remainingEnemies pushBack _x;
            };
        } forEach _activeEnemies;
        _activeEnemies = _remainingEnemies;

        // Recheck for buildings
        private _buildings = _getBuildings call _getBuildings;
        if (count _buildings > 0) then {
            {[_x, "building"] call _spawnEnemies;} forEach _buildings;
        };

        // Recheck for roads
        private _roads = _getRoads call _getRoads;
        if (count _roads > 0) then {
            {[_x, "road"] call _spawnEnemies;} forEach _roads;
        };

        diag_log "[AI Spawner] Rechecking for spawns.";
        sleep _spawnCheckInterval;
    };
};

_spawnLoop call _spawnLoop;
