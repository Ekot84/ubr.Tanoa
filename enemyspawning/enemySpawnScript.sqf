/*
    Script: Enemy Spawn Near Buildings and Roads
    Version: 0.15
    Filename: enemySpawnScript.sqf
    Author: Eko & ChatGPT
    Description: Spawns enemies near buildings or as patrols on roads with configurable spawn chance, quantity, random equipment, random skill, and player spawn distance. Includes despawning logic based on distance.
*/

#include "config.sqf"

// Create global variables to track state
private _processedBuildings = []; // Stores buildings with cooldowns
private _processedRoads = [];     // Stores roads with cooldowns
//private _cooldownTime = 300;      // Cooldown time in seconds
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

/*if (isServer) then {
    _enemy addMPEventHandler ["MPKilled", {
        params ["_unit", "_killer", "_instigator", "_useEffects"];

        if (isNull _unit) exitWith { diag_log "[AI Spawner] Kill event handler triggered with null unit."; };
        if (isNull _instigator) then { diag_log "[AI Spawner] Instigator is null, likely an environmental death."; };

        // Get sides and names
        private _sideDeadUnit = side group _unit;
        private _sideKiller = if (isNull _instigator) then {"Unknown"} else {side group _instigator};
        private _deadUnitName = name _unit; 
        private _killerName = if (isNull _instigator) then {"Environment"} else {name _instigator};

        // Log kill event
        diag_log format ["[AI Spawner] Enemy killed: %1 (%2) by %3 (%4)", _sideDeadUnit, _deadUnitName, _sideKiller, _killerName];

if (!isNull _killer && {isPlayer _killer}) then {
    private _scoreUpdate = [0, 0, 0, 0, 0];  // Default: No change

    switch (true) do {
        case (_unit isKindOf "Man"): { _scoreUpdate set [0, 1]; };  // Infantry Kill
        case (_unit isKindOf "Car" || _unit isKindOf "Motorcycle"): { _scoreUpdate set [1, 1]; };  // Soft Kill
        case (_unit isKindOf "Tank" || _unit isKindOf "APC"): { _scoreUpdate set [2, 1]; };  // Armor Kill
        case (_unit isKindOf "Air"): { _scoreUpdate set [3, 1]; };  // Air Kill
    };

    [_killer, _scoreUpdate] remoteExec ["addPlayerScores", 2];  // Apply correct kill score
    diag_log format ["[AI Spawner] %1 received score update %2 for killing %3", _killerName, _scoreUpdate, _deadUnitName];

    // Verify score update after 1 second
    [_killer] spawn {
        params ["_killer"];
        sleep 1;
        private _updatedScores = getPlayerScores _killer;
        diag_log format ["[DEBUG] Verified Scores for %1: %2", name _killer, _updatedScores];
    };
};

if (!isNull _unit && {isPlayer _unit}) then {
    [_unit, [0, 0, 0, 0, 1]] remoteExec ["addPlayerScores", 2];  // +1 Death only
    diag_log format ["[AI Spawner] %1 registered a death (+1)", _deadUnitName];

    // Verify score update after 1 second
    [_unit] spawn {
        params ["_unit"];
        sleep 1;
        private _updatedScores = getPlayerScores _unit;
        diag_log format ["[DEBUG] Verified Death Score for %1: %2", name _unit, _updatedScores];
    };
};


        // **Handle Teamkills (Executed on Server)**
        if (!isNull _instigator && {side group _instigator isEqualTo side group _unit} && { !(_unit isEqualTo _instigator) }) then {
            [_instigator, [-1, 0, 1, 0, 0]] remoteExec ["addPlayerScores", 2];  // -1 Kill, +1 Teamkill
            diag_log format ["[AI Spawner] %1 committed a TEAMKILL on %2 (-1 point, +1 teamkill)", name _instigator, _deadUnitName];
        };

        // **Delete group if empty**
        private _group = group _unit;
        if (!isNull _group && {count units _group == 0}) then {
            deleteGroup _group;
            diag_log format ["[AI Spawner] Group %1 deleted as it was empty.", _group];
        };
    }];
};
*/


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

// Check if auto loadout is enabled
if (_useAutoLoadout) then {
    // Fetch all weapons dynamically from mods
    private _allWeapons = ("true" configClasses (configFile >> "CfgWeapons")) apply {configName _x};
    private _primaryWeapons = _allWeapons select {getNumber (configFile >> "CfgWeapons" >> _x >> "type") == 1 && {getNumber (configFile >> "CfgWeapons" >> _x >> "scope") >= 2}}; // Rifles
    private _secondaryWeapons = _allWeapons select {getNumber (configFile >> "CfgWeapons" >> _x >> "type") == 2 && {getNumber (configFile >> "CfgWeapons" >> _x >> "scope") >= 2}}; // Handguns

    private _allMagazines = ("true" configClasses (configFile >> "CfgMagazines")) apply {configName _x};
// Fetch all throwable grenades used by 'Throw' weapon
private _grenades = [];
private _allMagazines = ("true" configClasses (configFile >> "CfgMagazines")) apply {configName _x};

{
    private _ammo = getText (configFile >> "CfgMagazines" >> _x >> "ammo");
    private _weapon = if (_ammo != "") then { getText (configFile >> "CfgAmmo" >> _ammo >> "weapon") } else { "" };
    
    if (_weapon == "Throw" && {isClass (configFile >> "CfgMagazines" >> _x)} && {!(_x find "CUP_" > -1)}) then {
        _grenades pushBack _x;
    };
} forEach _allMagazines;

// Debugging output to check filtered grenades
diag_log format ["Filtered valid grenades (excluding CUP): %1", _grenades];

// Ensure we have at least one valid grenade, fallback if necessary
if (count _grenades == 0) then {
    diag_log "WARNING: No valid grenades found! Using default HandGrenade.";
    _grenades pushBack "HandGrenade";
};


    private _allGear = ("true" configClasses (configFile >> "CfgWeapons")) apply {configName _x};
    private _allBackpacks = ("true" configClasses (configFile >> "CfgVehicles")) apply {configName _x};

    private _vests = _allGear select {getNumber (configFile >> "CfgWeapons" >> _x >> "type") == 701 && {getNumber (configFile >> "CfgWeapons" >> _x >> "scope") >= 2}}; // Vests
    private _headgear = _allGear select {getNumber (configFile >> "CfgWeapons" >> _x >> "type") == 605 && {getNumber (configFile >> "CfgWeapons" >> _x >> "scope") >= 2}}; // Helmets
    private _backpacks = _allBackpacks select {getNumber (configFile >> "CfgVehicles" >> _x >> "scope") >= 2}; // Backpacks

    // Select and equip primary weapon
    private _weapon = selectRandom _primaryWeapons;
    if (isClass (configFile >> "CfgWeapons" >> _weapon)) then {
        _enemy addWeapon _weapon;
        private _magazines = getArray (configFile >> "CfgWeapons" >> _weapon >> "magazines");
        if (count _magazines > 0) then {
        private _shuffledMags = _magazines call BIS_fnc_arrayShuffle;
        { _enemy addMagazine _x; } forEach (_shuffledMags select [0, (count _shuffledMags) min 3]);
    }
    };

    // Select and equip secondary weapon
    private _secondary = selectRandom _secondaryWeapons;
    if (isClass (configFile >> "CfgWeapons" >> _secondary)) then {
        _enemy addWeapon _secondary;
        private _secondaryMagazines = getArray (configFile >> "CfgWeapons" >> _secondary >> "magazines");
        if (count _secondaryMagazines > 0) then {
        private _shuffledSecMags = _secondaryMagazines call BIS_fnc_arrayShuffle;
        { _enemy addMagazine _x; } forEach (_shuffledSecMags select [0, (count _shuffledSecMags) min 2]);
    }
    };

    // Apply vest
    private _vest = if (count _vests > 0) then { selectRandom _vests } else { "" };
    if (_vest != "" && {isClass (configFile >> "CfgWeapons" >> _vest)}) then {
        _enemy addVest _vest;
    } else {
        diag_log format ["WARNING: Invalid auto-generated vest %1, using fallback %2", _vest, _fallbackVest];
        _enemy addVest _fallbackVest;
    };

    // Apply backpack
    private _backpack = if (count _backpacks > 0) then { selectRandom _backpacks } else { "" };
    if (_backpack != "" && {isClass (configFile >> "CfgVehicles" >> _backpack)}) then {
        _enemy addBackpack _backpack;
    } else {
        diag_log format ["WARNING: Invalid auto-generated backpack %1, using fallback %2", _backpack, _fallbackBackpack];
        _enemy addBackpack _fallbackBackpack;
    };

    // Apply headgear
    private _helmet = if (count _headgear > 0) then { selectRandom _headgear } else { "" };
    if (_helmet != "" && {isClass (configFile >> "CfgWeapons" >> _helmet)}) then {
        _enemy addHeadgear _helmet;
    } else {
        diag_log format ["WARNING: Invalid auto-generated helmet %1, using fallback %2", _helmet, _fallbackHeadgear];
        _enemy addHeadgear _fallbackHeadgear;
    };

// Assign grenades
private _grenadeCount = 1 + floor (random 3); // Random grenade count (1-3)

for "_i" from 1 to _grenadeCount do {
    private _grenade = selectRandom _grenades;
    
    if (!isNil "_grenade" && {_grenade != "" && isClass (configFile >> "CfgMagazines" >> _grenade)}) then {
        _enemy addMagazine _grenade;
    } else {
        diag_log format ["WARNING: Invalid grenade %1, using fallback %2", _grenade, _fallbackGrenade];
        _enemy addMagazine _fallbackGrenade;
    };
};

    
} else {
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
            _magazines = _fallbackMagazines;
        };

        { if (isClass (configFile >> "CfgMagazines" >> _x)) then { _enemy addMagazine _x; } else {
            diag_log format ["WARNING: Invalid magazine %1, using fallback %2", _x, _fallbackMagazines select 0];
            _enemy addMagazine (_fallbackMagazines select 0);
        }; } forEach _magazines;
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
