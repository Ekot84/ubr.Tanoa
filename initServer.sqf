// Configurable variables remain the same...
private _spawnChance = 100;             // Percent chance for AI spawning in a town
private _minSkill = 0.2;               // Minimum AI skill level
private _maxSkill = 0.8;               // Maximum AI skill level
private _minEnemies = 3;               // Minimum number of enemies per spawn
private _maxEnemies = 8;               // Maximum number of enemies per spawn
private _cleanupDistance = 2000;       // Distance to remove inactive zones
private _checkInterval = 30;           // Time in seconds between spawn/cleanup checks
private _minSpawnDistance = 100;       // Minimum distance from players for AI spawning
private _maxSpawnDistance = 1000;      // Maximum distance from players for AI spawning

// Variables for managing towns
private _towns = [];
private _activeZones = [];

// Function to log messages with consistent prefix
private _log = {
    params ["_message"];
    diag_log format ["[AI Spawn System] %1", _message];
};

// Function to detect towns
private _detectTowns = {
    private _checkedPositions = [];
    private _zones = [];

    // Detect zones around building clusters
    {
        private _pos = getPos _x;

        // Ensure _pos is valid
        if (!(_pos isEqualType [] && {count _pos == 3})) then {
            diag_log format ["[DEBUG] Skipping invalid position: %1", _pos];
            false
        };

        if ((_checkedPositions findIf {(_x distance _pos) < 150}) == -1) then {
            private _nearbyBuildings = nearestObjects [_pos, ["House"], 300];
            private _nearestLocation = nearestLocation [_pos, "nameCity"];
            private _townName = if (!isNull _nearestLocation) then { text _nearestLocation } else { "Unknown" };

            if (count _nearbyBuildings > 0) then {
                // Calculate a valid center position from nearby buildings
                private _center = [0, 0, 0];
                {
                    private _bPos = getPos _x;
                    _center = [
                        (_center select 0) + (_bPos select 0),
                        (_center select 1) + (_bPos select 1),
                        0 // We set Z to 0 for consistency
                    ];
                } forEach _nearbyBuildings;
                _center = [
                    (_center select 0) / (count _nearbyBuildings),
                    (_center select 1) / (count _nearbyBuildings),
                    0
                ];

                if (!(_center isEqualType [] && {count _center == 3})) then {
                    diag_log format ["[DEBUG] Invalid center position calculated: %1", _center];
                    false
                } else {
                    _checkedPositions append _nearbyBuildings;
                    _zones pushBack [_center, count _nearbyBuildings, _townName];
                    diag_log format ["[DEBUG] Added zone: %1, Buildings: %2, Town: %3", _center, count _nearbyBuildings, _townName];
                };
            } else {
                diag_log format ["[DEBUG] Skipped zone with no buildings at %1", _pos];
            };
        };
    } forEach nearestObjects [[0, 0, 0], ["House"], 20000];

    diag_log format ["[AI Spawn System] Detected %1 zones.", count _zones];
    _zones
};

// Function to check if any player is within spawn range of a zone
private _checkPlayerNearZone = {
    params ["_zone"];
    private _center = _zone select 0;
    private _radius = (_zone select 1) * 10;

    // Ensure _center is a valid position
    if (!(_center isEqualType [] && {count _center == 3})) exitWith {
        diag_log "[AI Spawn System] Error: Invalid _center position in zone.";
        false
    };

    // Check if players are within the defined spawn distance
    allPlayers findIf {
        private _playerPos = getPos _x;
        if (!(_playerPos isEqualType [] && {count _playerPos == 3})) exitWith {
            diag_log "[AI Spawn System] Error: Invalid player position.";
            false
        };
        private _dist = _playerPos distance _center;
        (_dist >= _minSpawnDistance) && (_dist <= (_radius min _maxSpawnDistance))
    } != -1;
};

// Function to spawn AI dynamically in a town zone
private _spawnAIInZone = {
    params ["_zone"];
    
    // Validate zone structure
    if (!(_zone isEqualType [] && {count _zone == 3})) exitWith {
        diag_log "[AI Spawn System] Error: Invalid zone structure.";
        false
    };

    private _center = _zone select 0;
    if (!(_center isEqualType [] && {count _center == 3})) exitWith {
        diag_log format ["[AI Spawn System] Error: Invalid _center position: %1", _center];
        false
    };

    private _buildingCount = _zone select 1;
    private _townName = _zone select 2;

    if (random 100 > _spawnChance) exitWith {
        diag_log format ["[AI Spawn System] Spawn skipped for town: %1.", _townName];
    };

    private _nearBuildings = nearestObjects [_center, ["House"], _buildingCount * 10];
    private _group = createGroup east;

    {
        private _building = _x;

        // Get building positions
        private _buildingPositions = [];
        for "_i" from 0 to 1000 do {
            private _pos = _building buildingPos _i;
            if (_pos isEqualTo [0, 0, 0]) exitWith {};
            _buildingPositions pushBack _pos;
        };

        // Spawn AI at positions
        {
            private _pos = _x;
            private _unitType = selectRandom ["O_Soldier_F", "O_Soldier_LAT_F", "O_Sniper_F"];
            private _aiUnit = _group createUnit [_unitType, _pos, [], 0, "FORM"];

            // Set AI attributes
            private _skillLevel = _minSkill + random (_maxSkill - _minSkill);
            _aiUnit setSkill ["aimingAccuracy", _skillLevel];
            _aiUnit setSkill ["spotDistance", _skillLevel];
            _aiUnit setSkill ["courage", _skillLevel];
        } forEach _buildingPositions;
    } forEach _nearBuildings;

    _activeZones pushBack [_zone, _group];
    diag_log format ["[AI Spawn System] Spawned AI in town: %1.", _townName];
};

// Function to clean up inactive zones
private _cleanupZones = {
    _activeZones = _activeZones select {
        params ["_zone", "_group"];
        private _center = _zone select 0;
        if ((allPlayers findIf {(_x distance _center) < _cleanupDistance}) == -1) then {
            {
                if (alive _x) then { deleteVehicle _x; };
            } forEach units _group;
            deleteGroup _group;
            diag_log format ["[AI Spawn System] Cleaned up zone in town: %1.", _zone select 2];
            false
        } else {
            true
        };
    };
};

// Main server loop
if (isServer) then {
    ["Starting AI spawn system..."] call _log;

    private _zones = call _detectTowns;

    while {true} do {
        // Process zones for spawning and cleanup
        {
            if ((_x call _checkPlayerNearZone) && !(_x in _activeZones)) then {
                _x call _spawnAIInZone;
            };
        } forEach _zones;

        // Ensure `_cleanupZones` is called properly
        call _cleanupZones;

        sleep _checkInterval;
    };
};
