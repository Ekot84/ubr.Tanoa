// Configurable variables
private _spawnChance = 70;             // Percent chance for AI spawning in a town
private _minSkill = 0.2;               // Minimum AI skill level
private _maxSkill = 0.8;               // Maximum AI skill level
private _minEnemies = 3;               // Minimum number of enemies per spawn
private _maxEnemies = 8;               // Maximum number of enemies per spawn
private _cleanupDistance = 2000;       // Distance to remove inactive zones
private _checkInterval = 30;           // Time in seconds between spawn/cleanup checks
private _fallbackMultiplier = 2;       // Multiplier for fallback radius
private _minSpawnDistance = 100;       // Minimum distance from players for AI spawning
private _maxSpawnDistance = 1000;      // Maximum distance from players for AI spawning

// Random equipment settings
private _primaryWeapons = [
    "arifle_Katiba_F", "arifle_MX_F", "arifle_AKM_F", "arifle_CTAR_blk_F"
];
private _attachments = [
    "optic_ACO", "optic_Hamr", "optic_Arco", "muzzle_snds_H", "bipod_01_F_blk"
];
private _uniforms = [
    "U_O_CombatUniform_ocamo", "U_O_GhillieSuit", "U_O_SpecopsUniform_ocamo"
];
private _vests = [
    "V_TacVest_blk", "V_PlateCarrier1_rgr", "V_BandollierB_khk"
];
private _headgear = [
    "H_HelmetO_ocamo", "H_HelmetSpecO_blk", "H_Bandanna_khk"
];

// Variables for managing towns
private _towns = [];
private _activeZones = [];

// Function to log messages with consistent prefix
private _log = {
    params ["_message"];
    diag_log format ["[AI Spawn System] %1", _message];
};

// Detect towns and create zones
private _detectTowns = {
    private _buildings = nearestObjects [[0, 0, 0], ["House"], 20000]; // Search entire map
    private _checkedPositions = [];
    private _zones = [];

    {
        private _pos = getPos _x;
        if (!(_checkedPositions findIf {(_pos distance _x) < 100}) != -1) then {
            private _nearbyBuildings = nearestObjects [_pos, ["House"], 300];
            _checkedPositions append ([_nearbyBuildings apply {getPos _x}]);
            _zones pushBack [_pos, count _nearbyBuildings];
        };
    } forEach _buildings;

    diag_log format ["[AI Spawn System] Detected %1 towns.", count _zones];
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

// Spawn AI in a zone (updated to include distance logic)
private _spawnAIInZone = {
    params ["_zone"];
    private ["_center", "_buildingCount"] = _zone;
    private _radius = _buildingCount * 10; // Scale radius by building count
    private _buildings = nearestObjects [_center, ["House"], _radius];

    // Check spawn chance
    if (random 100 > _spawnChance) exitWith {
        diag_log format ["[AI Spawn System] Spawn skipped in zone at %1.", _center];
    };

    diag_log format ["[AI Spawn System] Spawning AI in zone at %1.", _center];

    // Spawn AI near random buildings
    private _group = createGroup east;
    {
        private _buildingPos = getPos _x;

        // Ensure spawn is within player range
        private _validBuilding = allPlayers findIf {
            private _dist = _x distance _buildingPos;
            (_dist >= _minSpawnDistance) && (_dist <= _maxSpawnDistance)
        } != -1;

        if (_validBuilding) then {
            // Random enemy count
            private _enemyCount = floor (_minEnemies + random (_maxEnemies - _minEnemies + 1));
            for "_i" from 1 to _enemyCount do {
                private _unitType = selectRandom ["O_Soldier_F", "O_Soldier_LAT_F", "O_Sniper_F"];
                private _aiUnit = _group createUnit [_unitType, _buildingPos, [], 0, "FORM"];

                // Set random skill
                private _skillLevel = _minSkill + random (_maxSkill - _minSkill);
                _skillLevel = _skillLevel min 1 max 0; // Clamp skill level between 0 and 1
                _aiUnit setSkill ["aimingAccuracy", _skillLevel];
                _aiUnit setSkill ["aimingSpeed", _skillLevel];
                _aiUnit setSkill ["spotDistance", _skillLevel];
                _aiUnit setSkill ["spotTime", _skillLevel];
                _aiUnit setSkill ["courage", _skillLevel];

                // Assign random equipment
                _aiUnit forceAddUniform (selectRandom _uniforms);
                _aiUnit addVest (selectRandom _vests);
                _aiUnit addHeadgear (selectRandom _headgear);
                _aiUnit addWeapon (selectRandom _primaryWeapons);

                if (random 100 < 50) then {
                    _aiUnit addPrimaryWeaponItem (selectRandom _attachments);
                };
            };
        };
    } forEach _buildings;

    // Track active zone
    _activeZones pushBack [_zone, _group];
};

// Cleanup inactive zones
private _cleanupZones = {
    _activeZones = _activeZones select {
        params ["_zone", "_group"];
        private _center = _zone select 0;
        private _radius = (_zone select 1) * 10;

        // Check if players are nearby
        if ((allPlayers findIf {(_x distance _center) < _radius}) == -1) then {
            {
                if (alive _x) then { deleteVehicle _x; };
            } forEach units _group;

            deleteGroup _group;
            diag_log format ["[AI Spawn System] Cleaned up zone at %1.", _center];
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
        {
            if ((_x call _checkPlayerNearZone) && !(_x in _activeZones)) then {
                _x call _spawnAIInZone;
            };
        } forEach _zones;

        call _cleanupZones;

        sleep _checkInterval;
    };
};
