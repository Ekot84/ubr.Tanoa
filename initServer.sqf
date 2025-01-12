// Configurable variables
private _spawnChance = 70;             // Percent chance for AI spawning in a town
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

// Detect towns and create zones with names
private _detectTowns = {
    private _checkedPositions = [];
    private _zones = [];

    // Detect zones around building clusters
    {
        private _pos = getPos _x;
        if ((_checkedPositions findIf {(_x distance _pos) < 150}) == -1) then {
            private _nearbyBuildings = nearestObjects [_pos, ["House"], 300];
            
            // Use nearestLocation with array syntax
            private _nearestLocation = nearestLocation [_pos, "nameCity"];
            private _townName = if (!isNull _nearestLocation) then { text _nearestLocation } else { "Unknown" };

            _checkedPositions append _nearbyBuildings;
            _zones pushBack [_pos, count _nearbyBuildings, _townName];
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

    // Check if players are within the defined spawn distance
    allPlayers findIf {
        private _dist = _x distance _center;
        (_dist >= _minSpawnDistance) && (_dist <= _radius min _maxSpawnDistance)
    } != -1;
};

// Spawn AI dynamically in a town zone
private _spawnAIInZone = {
    params ["_zone"];
    private _center = _zone select 0;
    private _buildingCount = _zone select 1;
    private _townName = _zone select 2;

    if (random 100 > _spawnChance) exitWith {
        diag_log format ["[AI Spawn System] Spawn skipped for town: %1.", _townName];
    };

    private _nearBuildings = nearestObjects [_center, ["House"], _buildingCount * 10];
    private _group = createGroup east;

    {
        private _buildingPos = getPos _x;
        private _aiCount = round (_minEnemies + random (_maxEnemies - _minEnemies));

        for "_i" from 1 to _aiCount do {
            private _unitType = selectRandom ["O_Soldier_F", "O_Soldier_LAT_F", "O_Sniper_F"];
            private _aiPos = _buildingPos getPos [random 10, random 360]; // Random offset near the building
            private _aiUnit = _group createUnit [_unitType, _aiPos, [], 0, "FORM"];

            // Set AI attributes
            private _skillLevel = _minSkill + random (_maxSkill - _minSkill);
            _skillLevel = _skillLevel min 1 max 0; // Clamp between 0 and 1
            _aiUnit setSkill ["aimingAccuracy", _skillLevel];
            _aiUnit setSkill ["spotDistance", _skillLevel];
            _aiUnit setSkill ["courage", _skillLevel];
        };
    } forEach _nearBuildings;

    _activeZones pushBack [_zone, _group];
    diag_log format ["[AI Spawn System] Spawned %1 AI in town: %2.", _aiCount, _townName];
};


// Cleanup inactive zones
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

        call _cleanupZones;

        sleep _checkInterval;
    };
};
