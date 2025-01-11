// Parameters
private _spawnChance = 0.2; // 20% chance to spawn AI
private _spawnRadius = 1000; // 1 km spawn radius
private _cleanupDistance = 2000; // Distance threshold for cleanup
private _aiCount = 5; // Number of AI to spawn
private _groupSide = east; // Side of the AI (e.g., east, west, independent)

// Decide if AI should spawn based on chance
if (random 1 > _spawnChance) exitWith {
    diag_log "AI spawn skipped due to low probability.";
};

// Find a random position around the player within the spawn radius
private _playerPos = getPosATL player;
private _spawnPos = [_playerPos, _spawnRadius, _spawnRadius * 1.5, 1, 0, 20, 0] call BIS_fnc_findSafePos;

// Validate the spawn position (ensure it’s not too close to the player)
if (_spawnPos distance _playerPos < 800) exitWith {
    diag_log "Spawn position too close to player, skipping.";
};

// Create a group and spawn units
private _group = createGroup _groupSide;
for "_i" from 1 to _aiCount do {
    private _unit = _group createUnit ["O_Soldier_F", _spawnPos, [], 0, "FORM"]; // Use desired faction
    _unit setSkill random 0.5; // Random skill level (adjust as needed)
};

// Optional: Assign a patrol task to the AI
[_group, _spawnPos, 300] call BIS_fnc_taskPatrol;

// Log the spawn
diag_log format ["AI group spawned at %1 with %2 units.", _spawnPos, _aiCount];

// Start cleanup loop
[_group, _spawnPos, _cleanupDistance] spawn {
    params ["_group", "_spawnPos", "_cleanupDistance"];
    
    while {true} do {
        sleep 10; // Check every 10 seconds

        // Get player distance from the spawn position
        private _distance = player distance _spawnPos;

        // Delete the group if the player is too far
        if (_distance > _cleanupDistance) then {
            {
                deleteVehicle _x; // Delete each unit in the group
            } forEach units _group;
            deleteGroup _group; // Delete the group itself
            diag_log format ["AI group at %1 removed (player too far).", _spawnPos];
            breakOut "Cleanup"; // Exit the loop once the group is removed
        };
    };
};
