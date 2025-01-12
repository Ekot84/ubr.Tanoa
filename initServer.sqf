// Configurable variables
private _spawnChance = 70;             // Percent chance for AI spawning
private _minSkill = 0.2;               // Minimum AI skill level
private _maxSkill = 0.8;               // Maximum AI skill level
private _minEnemies = 3;               // Minimum number of enemies per spawn
private _maxEnemies = 8;               // Maximum number of enemies per spawn
private _cleanupDistance = 2000;       // Distance to remove inactive zones
private _checkInterval = 30;           // Time in seconds between spawn/cleanup checks
private _minSpawnDistance = 100;       // Minimum spawn distance from players
private _maxSpawnDistance = 1000;      // Maximum spawn distance from players
private _fallbackMultiplier = 2;       // Multiplier for fallback radius
private _cooldownTime = 600;           // Cooldown time in seconds for spawn zones

// Ensure _spawnedZones is initialized
if (isNil "spawnedZones") then {
    spawnedZones = [];
};

// Variables for managing zones
if (isNil "_spawnedZones") then { _spawnedZones = []; }; // Ensure initialized
if (isNil "_cooldownZones") then { _cooldownZones = []; }; // Ensure initialized


// Function to log messages with consistent prefix
private _log = {
    params ["_message"];
    if (isNil "_message") exitWith { diag_log "[AI Spawn System] Error: Log message is undefined."; };
    diag_log format ["[AI Spawn System] %1", _message];
};

// Function to generate a random spawn position
private _getRandomPosition = {
    params ["_center", "_minDist", "_maxDist"];

    // Generate random angle and distance
    private _angle = random 360;
    private _distance = _minDist + random (_maxDist - _minDist);
    private _randomPos = _center getPos [_distance, _angle];

    // Validate terrain
    if (!(surfaceIsWater _randomPos)) then {
        [format ["Generated position: %1", _randomPos]] call _log;
        _randomPos
    } else {
        ["Generated position is on water. Skipping."] call _log;
        []
    };
};

// Function to clean up inactive zones
private _cleanupZones = {
    if (isNil "spawnedZones" || {count spawnedZones == 0}) exitWith {
        ["No zones available for cleanup."] call _log;
    };

    spawnedZones = spawnedZones select {
        params ["_zone"];

        // Validate _zone structure
        if (isNil "_zone" || {count _zone < 2}) exitWith {
            diag_log "[AI Spawn System] Error: Invalid or undefined zone structure.";
            false
        };

        private _zonePos = _zone select 0;
        private _group = _zone select 1;

        if (isNull _group || {count _zonePos != 3}) exitWith {
            diag_log "[AI Spawn System] Warning: Invalid group or position in zone.";
            false
        };

        // Check if no players are nearby
        if ((allPlayers findIf {(_x distance _zonePos) < _cleanupDistance}) == -1) then {
            // Delete all units in the group
            {
                if (alive _x) then { deleteVehicle _x; };
            } forEach units _group;

            deleteGroup _group; // Delete the group
            ["Cleaned up zone at " + str _zonePos] call _log;
            false // Remove this zone from the list
        } else {
            true // Keep the zone in the list
        };
    };
};


// Function to check cooldowns
private _isOnCooldown = {
    params ["_pos"];
    _cooldownZones findIf {
        params ["_cooldownPos", "_cooldownEnd"];
        (_cooldownPos distance _pos) < _minSpawnDistance && diag_tickTime < _cooldownEnd
    } != -1
};

// Main server-side loop
if (isServer) then {
    ["Starting AI spawn system..."] call _log;

    while {true} do {
        ["Scanning for spawn opportunities..."] call _log;

        {
            private _player = _x;
            private _playerPos = getPos _player;

            // Check for spawn chance
            if (random 100 < _spawnChance) then {
                private _spawnPos = [_playerPos, _minSpawnDistance, _maxSpawnDistance] call _getRandomPosition;

                if (!(_spawnPos isEqualTo []) && !(_spawnPos call _isOnCooldown)) then {
                    private _nearBuildings = nearestObjects [_spawnPos, ["House", "Building", "Church", "Castle"], 100];
                    private _nearRoads = nearestObjects [_spawnPos, ["Road", "Path"], 100];

                    if ((count _nearBuildings > 0 || count _nearRoads > 0)) then {
                        ["Valid spawn location found at " + str _spawnPos] call _log;

                        // Create group
                        private _group = createGroup east;

                        // Spawn enemies
                        private _enemyCount = floor (_minEnemies + random (_maxEnemies - _minEnemies + 1));
                        for "_i" from 1 to _enemyCount do {
                            private _unitType = selectRandom ["O_Soldier_F", "O_Soldier_LAT_F", "O_Sniper_F"];
                            private _aiUnit = _group createUnit [_unitType, _spawnPos, [], 0, "FORM"];

                            // Set AI skill
                            private _skillLevel = _minSkill + random (_maxSkill - _minSkill);
                            _aiUnit setSkill ["aimingAccuracy", _skillLevel];
                            _aiUnit setSkill ["aimingSpeed", _skillLevel];
                            _aiUnit setSkill ["spotDistance", _skillLevel];
                            _aiUnit setSkill ["spotTime", _skillLevel];
                            _aiUnit setSkill ["courage", _skillLevel];
                        };

                        // Track zone
                        _spawnedZones pushBack [_spawnPos, _group, diag_tickTime];
                        _cooldownZones pushBack [_spawnPos, diag_tickTime + _cooldownTime];
                        ["Spawned " + str _enemyCount + " enemies at " + str _spawnPos] call _log;
                    } else {
                        ["No valid spawn location found."] call _log;
                    };
                } else {
                    ["Skipping spawn due to cooldown or invalid position."] call _log;
                };
            };
        } forEach allPlayers;

        // Clean up inactive zones
        call _cleanupZones;

        sleep _checkInterval;
    };
};
