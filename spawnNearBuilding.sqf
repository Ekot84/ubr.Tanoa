// Parameters
private _spawnRadius = 1000; // Radius to trigger spawning (1 km)
private _despawnRadius = 2000; // Radius to remove the enemy (2 km)
private _buildingSearchRadius = 50; // Radius to find nearby buildings
private _unitClass = "O_Soldier_F"; // Enemy unit type
private _groupSide = east; // Side of the AI (e.g., east, west, independent)
private _checkInterval = 10; // Interval to check player distance (in seconds)
private _spawnChance = 1; // Percent chance to spawn (0.0 to 1.0; 1.0 = 100%)

// Enemy spawn count range (min, max)
private _enemyCountRange = [1, 5]; // Minimum and maximum number of enemies to spawn

// Skill ranges (0 = lowest, 1 = highest)
private _skillRanges = [
    ["aimingAccuracy", 0.3, 0.7], // Minimum and maximum for aiming accuracy
    ["aimingShake", 0.2, 0.6],    // Minimum and maximum for aiming shake
    ["aimingSpeed", 0.4, 0.8],    // Minimum and maximum for aiming speed
    ["spotDistance", 0.5, 1.0],   // Minimum and maximum for spotting distance
    ["spotTime", 0.3, 0.7],       // Minimum and maximum for spotting time
    ["courage", 0.4, 0.9],        // Minimum and maximum for courage
    ["reloadSpeed", 0.5, 1.0],    // Minimum and maximum for reload speed
    ["commanding", 0.2, 0.6]      // Minimum and maximum for commanding
];

// Arrays for random equipment
private _weapons = [
    "arifle_Katiba_F",
    "arifle_MX_F",
    "SMG_02_F",
    "srifle_DMR_06_olive_F"
];

private _uniforms = [
    "U_O_CombatUniform_ocamo",
    "U_O_SpecopsUniform_ocamo",
    "U_O_GhillieSuit",
    "U_O_OfficerUniform_ocamo"
];

private _vests = [
    "V_TacVest_khk",
    "V_PlateCarrier2_rgr",
    "V_Chestrig_rgr",
    "V_BandollierB_khk"
];

private _backpacks = [
    "B_FieldPack_oli",
    "B_AssaultPack_khk",
    "B_Carryall_ocamo",
    "B_Kitbag_rgr"
];

private _headgear = [
    "H_HelmetSpecO_ocamo",
    "H_MilCap_oucamo",
    "H_Booniehat_khk",
    "H_Beret_ocamo"
];

private _items = [
    "FirstAidKit",
    "Chemlight_green",
    "Chemlight_red",
    "SmokeShell"
];

// Track whether the enemies have spawned
private _spawned = false;
private _enemies = [];

// Start monitoring loop
while {true} do {
    sleep _checkInterval; // Check periodically

    // Check if player is in a helicopter
    if (vehicle player != player && {typeOf (vehicle player) find "Helicopter" != -1}) then {
        diag_log "Player is in a helicopter. Skipping enemy spawn check.";
        continue;
    };

    // Get player position and nearest building
    private _playerPos = getPosATL player;
    private _nearestBuilding = nearestObject [_playerPos, "House"];

    if (isNull _nearestBuilding) then {
        diag_log "No building found nearby.";
        continue;
    };

    // Get position of the nearest building
    private _buildingPos = getPosATL _nearestBuilding;
    private _distanceToBuilding = _playerPos distance _buildingPos;

    // Handle spawning
    if (!_spawned && _distanceToBuilding <= _spawnRadius) then {
        // Add a chance to spawn
        if (random 1 <= _spawnChance) then {
            diag_log format ["Spawning enemies near building at %1", _buildingPos];

            // Determine the number of enemies to spawn
            private _minCount = _enemyCountRange select 0;
            private _maxCount = _enemyCountRange select 1;
            private _enemyCount = floor (_minCount + random (_maxCount - _minCount + 1));

            // Create enemies
            private _group = createGroup _groupSide;
            for "_i" from 1 to _enemyCount do {
                private _enemyPos = _buildingPos getPos [random 10, random 360];
                private _enemy = _group createUnit [_unitClass, _enemyPos, [], 0, "FORM"];

                // Assign random skill levels for difficulty
                if (!isNull _enemy) then {
                    {
                        private _skill = _x select 0;   // Skill type
                        private _min = _x select 1;    // Minimum value
                        private _max = _x select 2;    // Maximum value
                        _enemy setSkill [_skill, _min + random (_max - _min)];
                    } forEach _skillRanges;

                    // Randomize equipment
                    _enemy forceAddUniform selectRandom _uniforms;
                    _enemy addVest selectRandom _vests;
                    _enemy addBackpack selectRandom _backpacks;
                    _enemy addHeadgear selectRandom _headgear;
                    _enemy addWeapon selectRandom _weapons;

                    // Add items to backpack
                    _enemy addItemToBackpack selectRandom _items;

                    // Ammo for the weapon
                    private _compatibleMagazines = currentWeapon _enemy call BIS_fnc_compatibleMagazines;
                    if (count _compatibleMagazines > 0) then {
                        _enemy addMagazine (_compatibleMagazines select 0);
                    };

                    // Add patrol behavior
                    private _waypointCount = floor random 3 + 2; // Random 2–4 waypoints
                    for "_j" from 1 to _waypointCount do {
                        private _patrolPos = _buildingPos getPos [10 + random 10, random 360];
                        private _wp = _group addWaypoint [_patrolPos, 0];
                        _wp setWaypointType "MOVE";
                        _wp setWaypointSpeed "NORMAL";
                        _wp setWaypointBehaviour "AWARE";
                    };

                    // Add the enemy to the tracking array
                    _enemies pushBack _enemy;
                };
            };

            _spawned = true;
        } else {
            diag_log "Spawn skipped due to chance.";
        };
    };

    // Handle despawning
    if (_spawned && _distanceToBuilding > _despawnRadius) then {
        diag_log format ["Removing enemies near %1", _buildingPos];

        // Delete all spawned enemies
        {
            if (!isNull _x) then {
                deleteVehicle _x;
            };
        } forEach _enemies;

        _enemies = [];
        _spawned = false;
    };
};
