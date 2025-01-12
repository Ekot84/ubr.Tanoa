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

// Variables for managing zones
private _spawnedZones = [];            // Stores active zones as [position, group, timestamp]
private _cooldownZones = [];           // Stores cooldown zones as [position, cooldownEndTime]

// Function to log messages
private _log = {
    params ["_message"];
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
        diag_log format ["Generated position: %1", _randomPos];
        _randomPos
    } else {
        diag_log "Generated position is on water. Skipping.";
        []
    };
};

// Function to clean up inactive zones
private _cleanupZones = {
    _spawnedZones = _spawnedZones select {
        params ["_zone"];
        private _group = _zone select 1;
        private _zonePos = _zone select 0;

        if (isNull _group) exitWith { false };

        // Remove if no players nearby
        if ((allPlayers findIf {(_x distance _zonePos) < _cleanupDistance}) == -1) then {
            {
                if (alive _x) then { deleteVehicle _x; };
            } forEach units _group;
            deleteGroup _group;

            diag_log format ["Cleaned up zone at %1", _zonePos];
            false
        } else {
            true
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

// Main server loop
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

                    // Ensure valid spawn area
                    if ((count _nearBuildings > 0 || count _nearRoads > 0)) then {
                        diag_log format ["Valid spawn location found at %1", _spawnPos];

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

                        // Track zone and add cooldown
                        _spawnedZones pushBack [_spawnPos, _group, diag_tickTime];
                        _cooldownZones pushBack [_spawnPos, diag_tickTime + _cooldownTime];
                        diag_log format ["Spawned %1 enemies at %2", _enemyCount, _spawnPos];
                    } else {
                        diag_log "No valid spawn location found.";
                    };
                } else {
                    diag_log "Skipping spawn due to cooldown or invalid position.";
                };
            };
        } forEach allPlayers;

        // Clean up inactive zones
        call _cleanupZones;

        sleep _checkInterval;
    };
};
