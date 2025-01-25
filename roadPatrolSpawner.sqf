/*
    Script: Road Patrol Spawner
    Description:
    Spawns walking AI patrols on roads with randomized numbers.
    - Patrols spawn at random distances from players.
    - They prioritize road movement.
    - They despawn if too far from players.
    - Uses a cooldown between min-max times to prevent instant respawns.
    - Equips AI units with randomized loadouts.
*/

// CONFIGURATION (Ensure Variables Exist)
missionNamespace setVariable ["RoadPatrolMinSpawnTime", 240];  // Min cooldown (Debug)
missionNamespace setVariable ["RoadPatrolMaxSpawnTime", 900];  // Max cooldown (Debug)
missionNamespace setVariable ["RoadPatrolMaxActive", 4];      // Max patrols at once

missionNamespace setVariable ["RoadPatrolMinPatrolSize", 2];  // Min patrol size
missionNamespace setVariable ["RoadPatrolMaxPatrolSize", 10]; // Max patrol size
missionNamespace setVariable ["RoadPatrolSpawnDistanceMin", 500];  // Min spawn distance
missionNamespace setVariable ["RoadPatrolSpawnDistanceMax", 1500]; // Max spawn distance
missionNamespace setVariable ["RoadPatrolDespawnDistance", 2000];  // Despawn distance

missionNamespace setVariable ["RoadPatrolActivePatrols", []];  // Tracks active patrols

diag_log "[ROAD PATROL] Initializing patrol spawner...";




// FUNCTION: Equip AI with randomized gear
EquipUnitRandomly = {
    params ["_unit"];
    
    // Loadout NOT TIERED YET
    #include "roadSpwnConfig.sqf"
    
    private _primary = selectRandom _equipmentPool;
    private _secondary = selectRandom _secondaryWeaponsPool;
    private _vest = selectRandom _vestPool;
    private _uniform = selectRandom _uniformPool;
    private _backpack = selectRandom _bagPool;
    private _headgear = selectRandom _headgearPool;
    private _grenades = selectRandom _grenadePool;

    if (!isNil "_primary" && {count _primary > 0 && _primary select 0 != ""}) then {
        _unit addWeapon (_primary select 0);
        {_unit addMagazine _x} forEach (_primary select 1);
    };

    if (!isNil "_secondary" && {count _secondary > 0 && _secondary select 0 != ""}) then {
        _unit addWeapon (_secondary select 0);
        {_unit addMagazine _x} forEach (_secondary select 1);
    };

    if (!isNil "_vest" && {_vest != ""}) then { _unit addVest _vest; };
    if (!isNil "_uniform" && {_uniform != ""}) then { _unit forceAddUniform _uniform; };
    if (!isNil "_backpack" && {_backpack != ""}) then { _unit addBackpack _backpack; };
    if (!isNil "_headgear" && {_headgear != ""}) then { _unit addHeadgear _headgear; };
    if (!isNil "_grenades" && {_grenades != ""}) then { _unit addMagazine _grenades; };

    diag_log format ["[ROAD PATROL] Unit %1 equipped with: Primary=%2, Secondary=%3, Uniform=%4, Vest=%5, Backpack=%6, Headgear=%7, Grenade=%8", _unit, _primary select 0, _secondary select 0, _uniform, _vest, _backpack, _headgear, _grenades];
};

// FUNCTION: Finds a valid spawn location away from players
GetSpawnLocation = {
    private _spawnLocation = [];
    private _validSpawn = false;
    private _attempts = 0;

    while {!_validSpawn && _attempts < 10} do {
        private _player = selectRandom allPlayers;
        private _randomDir = random 360;
        private _spawnDistMin = missionNamespace getVariable "RoadPatrolSpawnDistanceMin";
        private _spawnDistMax = missionNamespace getVariable "RoadPatrolSpawnDistanceMax";

        private _randomDist = random [_spawnDistMin, (_spawnDistMin + _spawnDistMax) / 2, _spawnDistMax];
        private _spawnPos = _player getPos [_randomDist, _randomDir];

        diag_log format ["[ROAD PATROL DEBUG] Attempt #%1 - Checking for roads near %2", _attempts + 1, _spawnPos];

        // Look for roads near the position
        private _roadCandidates = nearestTerrainObjects [_spawnPos, ["ROAD", "MAIN ROAD", "TRAIL"], 150, false];

        if (count _roadCandidates > 0) then {
            private _nearestRoad = _roadCandidates select 0;
            _spawnLocation = getPos _nearestRoad;
            _validSpawn = true;
            diag_log format ["[ROAD PATROL DEBUG] Found valid road at %1", _spawnLocation];
        } else {
            diag_log format ["[ROAD PATROL DEBUG] No road found near %1. Retrying...", _spawnPos];
        };

        _attempts = _attempts + 1;
    };

    if (!_validSpawn) then {
        diag_log "[ROAD PATROL] ERROR: No valid road found after multiple attempts.";
    };

    _spawnLocation
};

// FUNCTION: Spawns a patrol at a given location
SpawnPatrol = {
    params ["_spawnPos", "_patrolSize"];
    private _group = createGroup east;

    for "_i" from 1 to _patrolSize do {
        private _unit = _group createUnit ["O_G_Soldier_F", _spawnPos, [], 0, "FORM"];
        _unit setSkill (random [0.3, 0.5, 0.7]);
        [_unit] call EquipUnitRandomly; // ✅ Equip unit with random gear
    };
};

if (isServer) then {
    _unit addMPEventHandler ["MPKilled", {
        params ["_unit", "_killer", "_instigator", "_useEffects"];

        if (isNull _unit) exitWith { diag_log "[AI Spawner] Kill event handler triggered with null unit."; };
        if (isNull _instigator) then { diag_log "[AI Spawner] Instigator is null, likely an environmental death."; };

        // Get sides and names
        private _sideDeadUnit = side group _unit;
        private _sideKiller = if (isNull _instigator) then {"Unknown"} else {side group _instigator};
        private _deadUnitName = name _unit; 
        private _killerName = if (isNull _instigator) then {"Environment"} else {name _instigator};

        // Log kill event
        diag_log format ["[Patrol Spawner] Enemy killed: %1 (%2) by %3 (%4)", _sideDeadUnit, _deadUnitName, _sideKiller, _killerName];

        if (isPlayer _killer) then {
            private _distance = _killer distance _unit;
            private _currentMax = _killer getVariable ["MaxKillDistance", 0];

            if (_distance > _currentMax) then {
                _killer setVariable ["MaxKillDistance", _distance, true];
            };

            diag_log format ["HUD: %1 killed %2 at %3m", name _killer, name _unit, _distance];
        };
        
/*if (!isNull _killer && {isPlayer _killer}) then {
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
};*/

/*if (!isNull _unit && {isPlayer _unit}) then {
    [_unit, [0, 0, 0, 0, 1]] remoteExec ["addPlayerScores", 2];  // +1 Death only
    diag_log format ["[AI Spawner] %1 registered a death (+1)", _deadUnitName];

    // Verify score update after 1 second
    [_unit] spawn {
        params ["_unit"];
        sleep 1;
        private _updatedScores = getPlayerScores _unit;
        diag_log format ["[DEBUG] Verified Death Score for %1: %2", name _unit, _updatedScores];
    };
};*/


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

// MAIN SPAWN LOOP
[] spawn {
    while {true} do {
        diag_log "[ROAD PATROL] Waiting for next spawn window...";
        waitUntil {time >= missionNamespace getVariable ["RoadPatrolSpawnTime", time]};

        diag_log "[ROAD PATROL] Checking patrol spawn conditions...";
        if (count (missionNamespace getVariable "RoadPatrolActivePatrols") < missionNamespace getVariable "RoadPatrolMaxActive") then {
            diag_log "[ROAD PATROL] Attempting to find a valid spawn location...";
            private _spawnPos = call GetSpawnLocation;
            if (count _spawnPos > 0) then {
                diag_log format ["[ROAD PATROL] Found valid spawn position at %1", _spawnPos];
                
                private _minPatrolSize = missionNamespace getVariable ["RoadPatrolMinPatrolSize", 2];
                private _maxPatrolSize = missionNamespace getVariable ["RoadPatrolMaxPatrolSize", 10];
                if (!(_minPatrolSize isEqualType 0) || !(_maxPatrolSize isEqualType 0)) then {
                diag_log "[ROAD PATROL ERROR] Patrol size variables are not numbers!";
                };
                private _patrolSize = round (random [_minPatrolSize, (_minPatrolSize + _maxPatrolSize) / 2, _maxPatrolSize]);
                
                [_spawnPos, _patrolSize] call SpawnPatrol;
            } else {
                diag_log "[ROAD PATROL] No valid spawn position found after multiple attempts.";
            };
        };
        missionNamespace setVariable ["RoadPatrolSpawnTime", time + random [30, 60, 90]];
    };
};
