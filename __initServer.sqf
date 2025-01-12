// Configurable variables remain the same...
private _spawnChance = 100;
private _minSkill = 0.2;
private _maxSkill = 0.8;
private _minEnemies = 3;
private _maxEnemies = 8;
private _cleanupDistance = 2000;
private _checkInterval = 30;
private _minSpawnDistance = 100;
private _maxSpawnDistance = 1000;

// Global variable to hold zones
if (isNil "AI_Spawn_Zones") then {
    AI_Spawn_Zones = [];
};

// Ensure _activeZones is defined globally
if (isNil "AI_Spawn_ActiveZones") then {
    AI_Spawn_ActiveZones = [];
};

// Function to log messages
private _log = {
    params ["_message"];
    diag_log format ["[AI Spawn System] %1", _message];
};

// Function to detect towns and create zones
private _detectTowns = {
    private _zones = [];

    {
        private _location = _x;
        private _pos = locationPosition _location;
        private _nearbyBuildings = nearestObjects [_pos, ["House"], 300];
        private _townName = text _location;

        // Validate building array before adding
        if (!(_nearbyBuildings isEqualType [] && {count _nearbyBuildings > 0})) then {
            diag_log format ["[AI Spawn System] Skipping location %1 with invalid buildings.", _townName];
        } else {
            _zones pushBack [_nearbyBuildings, count _nearbyBuildings, _townName];
            diag_log format ["[AI Spawn System] Zone added: %1, Buildings: %2, Town: %3", _pos, count _nearbyBuildings, _townName];
        };
    } forEach nearestLocations [[0, 0, 0], ["NameCity", "NameCityCapital", "NameVillage"], worldSize];

    if (count _zones == 0) then {
        diag_log "[AI Spawn System] Error: No valid zones detected!";
    };

    _zones
};

// Function to check if any player is within spawn range of a zone
private _checkPlayerNearZone = {
    params ["_zone"];
    private _buildings = _zone select 0;

    // Ensure valid building array
    if (!(_buildings isEqualType [] && {count _buildings > 0})) exitWith {
        diag_log "[AI Spawn System] Error: Invalid or empty building array in zone.";
        false
    };

    // Check if any player is near the buildings
    _buildings findIf {
        private _building = _x;
        if (isNull _building) exitWith {false};
        private _buildingPos = getPosATL _building;
        allPlayers findIf {
            private _playerPos = getPosATL _x;
            private _dist = _playerPos distance _buildingPos;
            (_dist >= _minSpawnDistance) && (_dist <= _maxSpawnDistance)
        } != -1;
    } != -1;
};

// Function to spawn AI dynamically in a town zone
private _spawnAIInZone = {
    params ["_zone"];
    private _buildings = _zone select 0;
    private _townName = _zone select 2;

    if (random 100 > _spawnChance) exitWith {
        diag_log format ["[AI Spawn System] Spawn skipped for town: %1.", _townName];
    };

    private _group = createGroup east;

    {
        private _building = _x;
        private _buildingPositions = [];

        for "_i" from 0 to 1000 do {
            private _pos = _building buildingPos _i;
            if (_pos isEqualTo [0, 0, 0]) exitWith {};
            _buildingPositions pushBack _pos;
        };

        {
            private _pos = _x;
            private _unitType = selectRandom ["O_Soldier_F", "O_Soldier_LAT_F", "O_Sniper_F"];
            private _aiUnit = _group createUnit [_unitType, _pos, [], 0, "FORM"];

            private _skillLevel = _minSkill + random (_maxSkill - _minSkill);
            _aiUnit setSkill ["aimingAccuracy", _skillLevel];
            _aiUnit setSkill ["spotDistance", _skillLevel];
            _aiUnit setSkill ["courage", _skillLevel];
        } forEach _buildingPositions;
    } forEach _buildings;

    AI_Spawn_ActiveZones pushBack [_zone, _group];
    diag_log format ["[AI Spawn System] Spawned AI in town: %1.", _townName];
};

// Function to clean up inactive zones
private _cleanupZones = {
    AI_Spawn_ActiveZones = AI_Spawn_ActiveZones select {
        params ["_zone", "_group"];
        private _buildings = _zone select 0;

        if (!(_buildings isEqualType [] && {count _buildings > 0})) exitWith {
            diag_log "[AI Spawn System] Error: Skipping invalid zone during cleanup.";
            false;
        };

        if (_buildings findIf {
            private _building = _x;
            if (isNull _building) exitWith {false};
            allPlayers findIf {(_x distance _building) < _cleanupDistance} != -1;
        } == -1) then {
            {
                if (alive _x) then { deleteVehicle _x; };
            } forEach units _group;

            deleteGroup _group;
            diag_log format ["[AI Spawn System] Cleaned up zone in town: %1.", _zone select 2];
            false;
        } else {
            true;
        };
    };
};

// Main server loop
if (isServer) then {
    ["Starting AI spawn system..."] call _log;

    private _zones = call _detectTowns;

    while {true} do {
        {
            if ((_x call _checkPlayerNearZone) && !(_x in (AI_Spawn_ActiveZones apply {_x select 0}))) then {
                _x call _spawnAIInZone;
            };
        } forEach _zones;

        call _cleanupZones;

        sleep _checkInterval;
    };
};
