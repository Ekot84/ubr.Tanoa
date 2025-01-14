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
["_equipmentPool", [                           // Array of equipment loadouts
        ["arifle_Katiba_F", ["30Rnd_65x39_caseless_green"]],
        ["arifle_MX_F", ["30Rnd_65x39_caseless_mag"]],
        ["arifle_AK12_F", ["30Rnd_762x39_Mag_F"]],
        ["SMG_02_F", ["30Rnd_9x21_Mag"]],
        ["arifle_SPAR_01_blk_F", ["30Rnd_556x45_Stanag"]]
    ]],
    ["_secondaryWeaponsPool", [                // Array of secondary weapon loadouts
        ["hgun_ACPC2_F", ["9Rnd_45ACP_Mag"]],
        ["hgun_Pistol_heavy_01_F", ["11Rnd_45ACP_Mag"]],
        ["CUP_hgun_Makarov", ["CUP_8Rnd_9x18_Makarov_M"]],
        ["CUP_hgun_Glock17", ["CUP_17Rnd_9x19_glock17"]]
    ]],
    ["_grenadePool", [                         // Array of grenade types
        // Vanilla grenades
        "HandGrenade",              // Explosive grenade
        "MiniGrenade",              // Smaller explosive grenade
        "SmokeShell",               // White smoke grenade
        "SmokeShellRed",            // Red smoke grenade
        "SmokeShellGreen",          // Green smoke grenade
        "Chemlight_green"//,          // Green chemlight (throwable light source)

        // CUP grenades (if applicable)
        //"CUP_HandGrenade_RGD5",     // RGD-5 grenade
        //"CUP_HandGrenade_M67",      // M67 grenade
        //"CUP_HandGrenade_L109A1_HE" // L109A1 grenade
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
    }];

        _activeEnemies pushBack _enemy;

        // Apply uniform, vest, bag, headgear, and loadout
        _enemy forceAddUniform selectRandom _uniformPool;
        _enemy addVest selectRandom _vestPool;
        _enemy addBackpack selectRandom _bagPool;
        _enemy addHeadgear selectRandom _headgearPool;

        private _equipment = selectRandom _equipmentPool;
        if (!isNil "_equipment") then {
            _enemy addWeapon (_equipment select 0);
            {_enemy addMagazine _x} forEach (_equipment select 1);
        };

        // Randomize secondary weapon loadout
        private _secondary = selectRandom _secondaryWeaponsPool;
        if (!isNil "_secondary") then {
            _enemy addWeapon (_secondary select 0);
            {_enemy addMagazine _x} forEach (_secondary select 1);
        };

        // Assign grenades
        private _grenadeCount = floor (random 3) + 1; // Randomize grenade count (1-3)
        for "_i" from 1 to _grenadeCount do {
            private _grenade = selectRandom _grenadePool;
            _enemy addMagazine _grenade;
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
