/*
    Script: Enemy Spawn Near Buildings
    Filename: enemySpawnScript.sqf
    Author: Eko & ChatGPT
    Description: Spawns enemies near buildings with configurable spawn chance, quantity, random equipment, random skill, and player spawn distance. Includes despawning logic based on distance.
*/

// Configuration Parameters
params [
    ["_spawnChance", 0.5],                         // Probability (0-1) of spawning enemies near a building
    ["_enemyCountRange", [1, 5]],                  // Array [minEnemies, maxEnemies] to spawn per building
    ["_minDistance", 100],                         // Minimum spawn distance from player (meters)
    ["_maxDistance", 300],                         // Maximum spawn distance from player (meters)
    ["_maxTotalEnemies", 25],                      // Maximum total number of enemies allowed at the same time
    ["_spawnCheckInterval", 120],                  // Interval in seconds to recheck and spawn enemies if under the limit
    ["_cleanupDistance", 500],                     // Distance from player at which enemies are removed
    ["_equipmentPool", [                           // Array of equipment loadouts
        ["arifle_Katiba_F", ["30Rnd_65x39_caseless_green"]],
        ["arifle_MX_F", ["30Rnd_65x39_caseless_mag"]],
        ["arifle_AK12_F", ["30Rnd_762x39_Mag_F"]],
        ["SMG_02_F", ["30Rnd_9x21_Mag"]],
        ["arifle_SPAR_01_blk_F", ["30Rnd_556x45_Stanag"]]
    ]],
    ["_uniformPool", [
        "U_O_CombatUniform_ocamo",
        "U_B_CombatUniform_mcam",
        "U_I_CombatUniform",
        "U_BG_Guerilla2_1",
        "U_B_CTRG_Soldier_3_F"
    ]],
    ["_vestPool", [
        "V_PlateCarrier1_rgr",
        "V_PlateCarrier2_rgr",
        "V_TacVest_blk",
        "V_Chestrig_khk",
        "V_BandollierB_khk"
    ]],
    ["_bagPool", [
        "B_AssaultPack_khk",
        "B_FieldPack_blk",
        "B_TacticalPack_oli",
        "B_Carryall_ocamo",
        "B_Kitbag_rgr"
    ]],
    ["_headgearPool", [
        "H_HelmetSpecB",
        "H_HelmetB_light",
        "H_Booniehat_khk",
        "H_Bandanna_khk",
        "H_Cap_blk"
    ]],
    ["_medkits", ["FirstAidKit", "Medikit"]],      // Array of medical items
    ["_skillRange", [0.2, 0.8]]                    // Array [minSkill, maxSkill] for enemy skill level
];

// Create a global set to track processed buildings
private _processedBuildings = []; // Stores buildings with cooldowns
private _cooldownTime = 300; // Cooldown time in seconds
private _activeEnemies = []; // Tracks currently active enemies

// Function to spawn enemies near a building
private _spawnEnemies = {
    params ["_building"];

    // Skip if the building has already been processed
    private _currentTime = time;
    private _foundBuilding = _processedBuildings select { _x select 0 == _building };
    if (!isNil "_foundBuilding" && { _currentTime - (_foundBuilding select 0 select 1) < _cooldownTime }) exitWith {
        diag_log format ["[AI Spawner] Skipped building at %1 due to cooldown.", getPos _building];
    };

    // Remove expired cooldowns
    _processedBuildings = _processedBuildings select { _currentTime - (_x select 1) < _cooldownTime };

    // Check current enemy count
    if (count _activeEnemies >= _maxTotalEnemies) exitWith {
        diag_log format ["[AI Spawner] Maximum enemy limit (%1) reached. Skipping building at %2.", _maxTotalEnemies, getPos _building];
    };

    // Random chance to spawn
    if (random 1 > _spawnChance) exitWith {};

    // Add building to the processed list only if enemies are successfully spawned
    _processedBuildings pushBack [_building, _currentTime];

    // Determine number of enemies to spawn
    private _minEnemies = _enemyCountRange select 0;
    private _maxEnemies = _enemyCountRange select 1;
    private _enemyCount = floor (random (_maxEnemies - _minEnemies + 1)) + _minEnemies;
    diag_log format ["[AI Spawner] Spawning %1 enemies near building at %2", _enemyCount, getPos _building];

    for "_i" from 1 to _enemyCount do {
        // Randomize spawn position near building
        private _spawnPos = _building getPos [random 10, random 360];
        
        // Ensure spawn distance from player
        if (player distance _spawnPos < _minDistance) exitWith {};

        // Randomize enemy loadout
        private _equipment = selectRandom _equipmentPool;
        private _uniform = selectRandom _uniformPool;
        private _vest = selectRandom _vestPool;
        private _bag = selectRandom _bagPool;
        private _headgear = selectRandom _headgearPool;
        private _medkit = selectRandom _medkits;

        // Create enemy unit
        private _enemy = createGroup east createUnit [
            "O_G_Soldier_F",  // Example unit class
            _spawnPos,
            [],
            0.5,
            "FORM"
        ];
        _activeEnemies pushBack _enemy;
        diag_log format ["[AI Spawner] Spawned enemy %1 at position %2", typeOf _enemy, _spawnPos];

        // Apply uniform, vest, bag, headgear, and loadout
        _enemy forceAddUniform _uniform;
        _enemy addVest _vest;
        _enemy addBackpack _bag;
        _enemy addHeadgear _headgear;

        if (!isNil "_equipment") then {
            _enemy addWeapon (_equipment select 0);
            {_enemy addMagazine _x} forEach (_equipment select 1);
        };

        _enemy addItem _medkit;

        // Randomize skill level
        private _minSkill = _skillRange select 0;
        private _maxSkill = _skillRange select 1;
        private _skill = random (_maxSkill - _minSkill) + _minSkill;
        _enemy setSkill _skill;
    };
};

// Function to get buildings within range
private _getBuildings = {
    private _playerPos = getPosATL player;
    nearestObjects [_playerPos, ["House"], _maxDistance]
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
                _remainingEnemies pushBack _x; // Keep enemies within the range
            };
        } forEach _activeEnemies;
        _activeEnemies = _remainingEnemies; // Update the active enemies list

        // Recheck for spawns
        private _buildings = _getBuildings call _getBuildings;
        diag_log format ["[AI Spawner] Found %1 buildings within range.", count _buildings];

        if (count _buildings > 0) then {
            {
                [_x] call _spawnEnemies;
            } forEach _buildings;
        };

        diag_log "[AI Spawner] Rechecking for spawns.";
        sleep _spawnCheckInterval;
    };
};

_spawnLoop call _spawnLoop;
