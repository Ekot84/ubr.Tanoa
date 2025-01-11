// Parameters
private _spawnRadius = 1000; // Radius to trigger spawning (1 km)
private _despawnRadius = 2000; // Radius to remove the enemy (2 km)
private _unitClass = "O_Soldier_F"; // Enemy unit type
private _groupSide = east; // Side of the AI
private _checkInterval = 10; // Interval to check player distance (in seconds)
private _spawnChance = 1; // Percent chance to spawn (0.0 to 1.0)

// Enemy spawn count range (min, max)
private _enemyCountRange = [1, 5];

// Skill ranges
private _skillRanges = [
    ["aimingAccuracy", 0.3, 0.7],
    ["spotDistance", 0.5, 1.0]
];

// Random equipment arrays
private _weapons = ["arifle_Katiba_F", "arifle_MX_F"];
private _uniforms = ["U_O_CombatUniform_ocamo", "U_O_SpecopsUniform_ocamo"];
private _vests = ["V_TacVest_khk", "V_PlateCarrier2_rgr"];
private _items = ["FirstAidKit", "SmokeShell"];

// Track spawned groups
private _spawnedGroups = [];

// Client-side: Update player position
if (hasInterface) then {
    [] spawn {
        while {true} do {
            sleep 1;
            playerPosition = getPosATL player; // Update global variable
            publicVariableServer "playerPosition"; // Send to server
        };
    };
};

// Server-side: Handle AI spawning
if (isServer) then {
    "playerPosition" addPublicVariableEventHandler {
        params ["_name", "_position"];

        // Validate position data
        if (count _position != 3) exitWith {
            diag_log "Invalid player position received.";
        };

        private _playerPos = _position;
        private _nearestBuilding = nearestObject [_playerPos, "House"];

        if (isNull _nearestBuilding) exitWith {
            diag_log "No nearby building for AI spawn.";
        };

        private _buildingPos = getPosATL _nearestBuilding;
        private _distanceToBuilding = _playerPos distance _buildingPos;

        // Spawn logic
        if (_distanceToBuilding <= _spawnRadius) then {
            if (random 1 > _spawnChance) exitWith { diag_log "Spawn skipped due to chance."; };

            private _group = createGroup _groupSide;
            private _spawnedEnemies = [];

            for "_i" from 1 to (_enemyCountRange select 0 + random (_enemyCountRange select 1)) do {
                private _enemyPos = _buildingPos getPos [random 10, random 360];
                private _enemy = _group createUnit [_unitClass, _enemyPos, [], 0, "FORM"];

                if (!isNull _enemy) then {
                    // Assign skills
                    {
                        private _skill = _x select 0;
                        private _min = _x select 1;
                        private _max = _x select 2;
                        _enemy setSkill [_skill, _min + random (_max - _min)];
                    } forEach _skillRanges;

                    // Equip enemy
                    _enemy forceAddUniform selectRandom _uniforms;
                    _enemy addVest selectRandom _vests;
                    _enemy addWeapon selectRandom _weapons;
                    _enemy addItemToBackpack selectRandom _items;

                    _spawnedEnemies pushBack _enemy;
                };
            };

            _spawnedGroups pushBack [_group, _buildingPos];
            diag_log format ["Spawned %1 enemies at %2.", count _spawnedEnemies, _buildingPos];
        };

        // Handle despawning
        {
            params ["_group", "_groupPos"];
            if (_playerPos distance _groupPos > _despawnRadius) then {
                {
                    if (!isNull _x) then { deleteVehicle _x; };
                } forEach units (_group select 0);
                deleteGroup (_group select 0);
                _spawnedGroups deleteAt (_spawnedGroups find _group);
                diag_log format ["Despawning group at %1.", _groupPos];
            };
        } forEach _spawnedGroups;
    };
};
