// Parameters
private _spawnRadius = 1000; // Radius to trigger spawning (1 km)
private _despawnRadius = 2000; // Radius to remove the enemy (2 km)
private _buildingSearchRadius = 50; // Radius to find nearby buildings
private _unitClass = "O_Soldier_F"; // Enemy unit type
private _groupSide = east; // Side of the AI (e.g., east, west, independent)
private _checkInterval = 10; // Interval to check player distance (in seconds)
private _spawnChance = 1; // Percent chance to spawn (0.0 to 1.0; 1.0 = 100%)

// Track whether the enemy has spawned
private _spawned = false;
private _enemy = objNull;

// Start monitoring loop
while {true} do {
    sleep _checkInterval; // Check periodically

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
            diag_log format ["Spawning enemy near building at %1", _buildingPos];

            // Create the enemy near the building
            private _group = createGroup _groupSide;
            _enemy = _group createUnit [_unitClass, _buildingPos, [], 0, "FORM"];
            _enemy setSkill random 0.5; // Adjust AI skill

            _spawned = true;
        } else {
            diag_log "Spawn skipped due to chance.";
        };
    };

    // Handle despawning
    if (_spawned && _distanceToBuilding > _despawnRadius) then {
        diag_log format ["Removing enemy at %1", getPosATL _enemy];

        if (!isNull _enemy) then {
            deleteVehicle _enemy;
        };
        _spawned = false;
    };
};
