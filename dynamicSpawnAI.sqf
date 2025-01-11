// Parameters
private _spawnChance = 0.2; // 20% chance to spawn AI
private _spawnRadius = 1000; // 1 km spawn radius
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

    // Add EventHandler to track kills
    _unit addEventHandler ["Killed", {
        params ["_killed", "_killer"];
        
        // Check if the killer is a player
        if (!isNull _killer && {_killer isKindOf "CAManBase"} && {_killer == player}) then {
            // Increment player's kill count
            player setVariable ["playerKills", (player getVariable ["playerKills", 0]) + 1, true];
            
            // Debug log
            diag_log format ["Player %1 killed AI %2.", name player, _killed];
        };
    }];
};

// Optional: Assign a patrol task to the AI
[_group, _spawnPos, 300] call BIS_fnc_taskPatrol;

// Log the spawn
diag_log format ["AI group spawned at %1 with %2 units.", _spawnPos, _aiCount];

// Return the group
_group
