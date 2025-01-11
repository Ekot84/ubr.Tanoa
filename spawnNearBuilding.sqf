// Parameters
private _spawnRadius = 1000; // Radius to trigger spawning (1 km)
private _despawnRadius = 2000; // Radius to remove the enemy (2 km)
private _unitClass = "O_Soldier_F"; // Enemy unit type
private _groupSide = east; // Side of the AI (e.g., east, west, independent)
private _checkInterval = 10; // Interval to check player distance (in seconds)
private _spawnChance = 1; // Percent chance to spawn (0.0 to 1.0; 1.0 = 100%)

// Enemy spawn count range (min, max)
private _enemyCountRange = [1, 5];

// Skill ranges (0 = lowest, 1 = highest)
private _skillRanges = [
    ["aimingAccuracy", 0.3, 0.7],
    ["spotDistance", 0.5, 1.0],
    ["courage", 0.4, 0.9],
    ["reloadSpeed", 0.5, 1.0]
];

// Arrays for random equipment
private _weapons = ["arifle_Katiba_F", "arifle_MX_F", "SMG_02_F", "srifle_DMR_06_olive_F"];
private _uniforms = ["U_O_CombatUniform_ocamo", "U_O_SpecopsUniform_ocamo", "U_O_GhillieSuit"];
private _vests = ["V_TacVest_khk", "V_PlateCarrier2_rgr", "V_Chestrig_rgr"];
private _backpacks = ["B_FieldPack_oli", "B_Carryall_ocamo"];
private _headgear = ["H_HelmetSpecO_ocamo", "H_Booniehat_khk"];
private _items = ["FirstAidKit", "Chemlight_green", "SmokeShell"];

// Track spawned enemies
private _spawnedGroups = [];

// Player position update for server (client-side only)
if (hasInterface) then {
    [] spawn {
        while {true} do {
            sleep 1;
            publicVariableServer "playerPosition"; // Send player position to server
        };
    };
};

// Server-side AI management
if (isServer) then {
    "playerPosition" addPublicVariableEventHandler {
        params ["_name", "_position"];

        // Validate if the player is within the spawn radius
        private _playerPos = _position;
        private _nearestBuilding = nearestObject [_playerPos, "House"];
        if (isNull _nearestBuilding) exitWith { diag_log "No nearby building for AI spawn."; };

        private _buildingPos = getPosATL _nearestBuilding;
        private _distanceToBuilding = _playerPos distance _buildingPos;

        // Handle spawning
        if (_distanceToBuilding <= _spawnRadius) then {
            // Check for spawn chance
            if (random 1 > _spawnChance) exitWith { diag_log "AI spawn skipped due to chance."; };

            // Spawn AI group
            private _enemyCount = floor (_enemyCountRange select 0 + random (_enemyCountRange select 1));
            private _group = createGroup _groupSide;
            private _spawnedEnemies = [];

            for "_i" from 1 to _enemyCount do {
                private _enemyPos = _buildingPos getPos [random 20, random 360];
                private _enemy = _group createUnit [_unitClass, _enemyPos, [], 0, "FORM"];

                if (!isNull _enemy) then {
                    // Assign random skills
                    {
                        private _skill = _x select 0;
                        private _min = _x select 1;
                        private _max = _x select 2;
                        _enemy setSkill [_skill, _min + random (_max - _min)];
                    } forEach _skillRanges;

                    // Equip the enemy
                    _enemy forceAddUniform selectRandom _uniforms;
                    _enemy addVest selectRandom _vests;
                    _enemy addBackpack selectRandom _backpacks;
                    _enemy addHeadgear selectRandom _headgear;
                    _enemy addWeapon selectRandom _weapons;
                    _enemy addItemToBackpack selectRandom _items;

                    // Add compatible magazines
                    private _mags = _enemy call BIS_fnc_compatibleMagazines;
                    if (count _mags > 0) then {
                        _enemy addMagazine (_mags select 0);
                    };

                    // Track spawned enemy
                    _spawnedEnemies pushBack _enemy;
                };
            };

            _spawnedGroups pushBack [_group, _buildingPos];

            diag_log format ["Spawned %1 enemies at %2.", _enemyCount, _buildingPos];
        };

        // Handle despawning
        {
            params ["_group", "_groupPos"];
            private _distance = _playerPos distance _groupPos;
            if (_distance > _despawnRadius) then {
                {
                    deleteVehicle _x;
                } forEach units (_group select 0);
                deleteGroup (_group select 0);
                _spawnedGroups deleteAt (_spawnedGroups find _group);
                diag_log format ["Despawning group at %1 (too far).", _groupPos];
            };
        } forEach _spawnedGroups;
    };
};
