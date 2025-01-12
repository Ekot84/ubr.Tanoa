/*
    Script: Enemy Spawn Near Buildings and Roads
    Version: 0.21
    Filename: enemySpawnScript.sqf
    Author: Eko & ChatGPT
    Description: Spawns enemies near buildings or as patrols on roads with configurable spawn chance, quantity, random equipment, random skill, and player spawn distance. Includes despawning logic based on distance and MP event handling for kills and hits.
*/

// Configuration Parameters
params [
    ["_spawnChance", 0.5],                         // Probability (0-1) of spawning enemies
    ["_enemyCountRange", [1, 5]],                  // Array [minEnemies, maxEnemies] to spawn per location
    ["_minDistance", 100],                         // Minimum spawn distance from player (meters)
    ["_maxDistance", 1300],                         // Maximum spawn distance from player (meters)
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

// Create global variables to track state
private _processedBuildings = [];
private _processedRoads = [];
private _cooldownTime = 300;      // Cooldown time in seconds
private _activeEnemies = [];      // Tracks currently active enemies
private _maxScanDistance = 1500;

// Function to get buildings within range
private _getBuildings = nearestobjects [getPosATL player, ["House",  "Building"], 15000];

// Function to get roads within range
private _getRoads = {
    private _playerPos = getPosATL player;
    nearestTerrainObjects [_playerPos, ["ROAD"], 15000]
};

// Debug: Test nearest terrain objects for all types
diag_log "[Debug] Testing nearestTerrainObjects for all types...";
private _testObjects = nearestobjects [getPosATL player, ["House",  "Building"], 15000];
private _objectTypes = _testObjects apply {typeOf _x};
diag_log format ["[Debug] Found object types near player: %1", _objectTypes];

// Ensure _getBuildings is initialized and tested
private _testBuildings = [];
if (!isNil "_getBuildings") then {
    diag_log "[Debug] Testing _getBuildings with nearestTerrainObjects...";
    _testBuildings = _getBuildings call {};
    if (isNil "_testBuildings" || {_testBuildings isEqualTo []}) then {
        diag_log "[Debug] _getBuildings returned no results.";
        _testBuildings = []; // Ensure it's initialized to an empty array
    } else {
        diag_log format ["[Debug] _getBuildings returned: %1", _testBuildings];
    };
} else {
    diag_log "[Error] _getBuildings is not defined!";
    _testBuildings = []; // Fallback to an empty array
};

// Ensure _getRoads is initialized and tested
private _testRoads = [];
if (!isNil "_getRoads") then {
    diag_log "[Debug] Testing _getRoads with nearestTerrainObjects...";
    _testRoads = _getRoads call {};
    if (isNil "_testRoads" || {_testRoads isEqualTo []}) then {
        diag_log "[Debug] _getRoads returned no results.";
        _testRoads = []; // Ensure it's initialized to an empty array
    } else {
        diag_log format ["[Debug] _getRoads returned: %1", _testRoads];
    };
} else {
    diag_log "[Error] _getRoads is not defined!";
    _testRoads = []; // Fallback to an empty array
};

// Count buildings and roads for debugging
private _buildingCount = count _testBuildings;
private _roadCount = count _testRoads;

diag_log format ["[Debug] Found %1 buildings.", _buildingCount];
diag_log format ["[Debug] Found %1 roads.", _roadCount];

// Spawn enemies if objects are found
if (_buildingCount > 0) then {
    {[_x, "building"] call _spawnEnemies;} forEach _testBuildings;
};

if (_roadCount > 0) then {
    {[_x, "road"] call _spawnEnemies;} forEach _testRoads;
};


// Ensure _getRoads is initialized and test
private _testRoads = [];
if (!isNil "_getRoads") then {
    diag_log "[Debug] Testing _getRoads...";
    _testRoads = _getRoads call {};
    if (isNil "_testRoads" || {_testRoads isEqualTo []}) then {
        diag_log "[Debug] _getRoads returned no results.";
        _testRoads = []; // Ensure it's initialized to an empty array
    } else {
        diag_log format ["[Debug] _getRoads returned: %1", _testRoads];
    };
} else {
    diag_log "[Error] _getRoads is not defined!";
};

// Count buildings and roads for debugging
private _buildingCount = count _testBuildings;
private _roadCount = count _testRoads;

diag_log format ["[Debug] Found %1 buildings.", _buildingCount];
diag_log format ["[Debug] Found %1 roads.", _roadCount];

// Proceed with spawning if objects are found
if (_buildingCount > 0) then {
    {[_x, "building"] call _spawnEnemies;} forEach _testBuildings;
};

if (_roadCount > 0) then {
    {[_x, "road"] call _spawnEnemies;} forEach _testRoads;
};


// Function to spawn enemies near a building or road
private _spawnEnemies = {
    params ["_location", "_type"];

    // Skip if the location has already been processed
    private _currentTime = time;
    private _processedLocations = if (_type == "building") then {_processedBuildings} else {_processedRoads};

    private _foundLocation = _processedLocations select { _x select 0 == _location };
    if (!isNil "_foundLocation" && { _currentTime - (_foundLocation select 1) < _cooldownTime }) exitWith {
        diag_log format ["[AI Spawner] Skipped %1 at %2 due to cooldown.", _type, getPos _location];
    };

    // Remove expired cooldowns
    if (_type == "building") then {
        _processedBuildings = _processedBuildings select { _currentTime - (_x select 1) < _cooldownTime };
    } else {
        _processedRoads = _processedRoads select { _currentTime - (_x select 1) < _cooldownTime };
    };

    // Check current enemy count
    if (count _activeEnemies >= _maxTotalEnemies) exitWith {
        diag_log format ["[AI Spawner] Maximum enemy limit (%1) reached. Skipping %2 at %3.", _maxTotalEnemies, _type, getPos _location];
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
        private _spawnPos = _location getPos [random 10, random 360];
        if (player distance _spawnPos < _minDistance) exitWith {};

        private _equipment = selectRandom _equipmentPool;
        private _uniform = selectRandom _uniformPool;
        private _vest = selectRandom _vestPool;
        private _bag = selectRandom _bagPool;
        private _headgear = selectRandom _headgearPool;
        private _medkit = selectRandom _medkits;

        private _enemy = createGroup east createUnit [
            "O_G_Soldier_F", _spawnPos, [], 0.5, "FORM"
        ];

        _activeEnemies pushBack _enemy;

        _enemy forceAddUniform _uniform;
        _enemy addVest _vest;
        _enemy addBackpack _bag;
        _enemy addHeadgear _headgear;

        if (!isNil "_equipment") then {
            _enemy addWeapon (_equipment select 0);
            {_enemy addMagazine _x} forEach (_equipment select 1);
        };

        _enemy addItem _medkit;

        private _minSkill = _skillRange select 0;
        private _maxSkill = _skillRange select 1;
        private _skill = random (_maxSkill - _minSkill) + _minSkill;
        _enemy setSkill _skill;
    };
};

// Main Execution
private _spawnLoop = {
    while {true} do {
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

        // Buildings
        diag_log format ["[Debug] Is _getBuildings defined: %1", isNil "_getBuildings"];
        diag_log "[Debug] Testing _getBuildings...";
        private _buildings = _getBuildings call {};
        if (isNil "_buildings" || {_buildings isEqualTo []}) then {
            diag_log "[Debug] No buildings found.";
            _buildings = [];
        };
        private _buildingCount = count _buildings;
        diag_log format ["[Debug] Found %1 buildings.", _buildingCount];
        if (_buildingCount > 0) then {
            {[_x, "building"] call _spawnEnemies;} forEach _buildings;
        };

        // Roads
        diag_log format ["[Debug] Is _getRoads defined: %1", isNil "_getRoads"];
        diag_log "[Debug] Testing _getRoads...";
        private _roads = _getRoads call {};
        if (isNil "_roads" || {_roads isEqualTo []}) then {
            diag_log "[Debug] No roads found.";
            _roads = [];
        };
        private _roadCount = count _roads;
        diag_log format ["[Debug] Found %1 roads.", _roadCount];
        if (_roadCount > 0) then {
            {[_x, "road"] call _spawnEnemies;} forEach _roads;
        };

        diag_log "[AI Spawner] Rechecking for spawns.";
        sleep _spawnCheckInterval;
    };
};

// Call the spawn loop
_spawnLoop call _spawnLoop;
