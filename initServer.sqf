// Configurable variables
private _minSpawnDistance = 100;       // Minimum distance from players
private _maxSpawnDistance = 1000;      // Maximum distance from players
private _spawnChance = 99;             // Percentile chance for AI spawning
private _spawnedZones = [];            // Tracks zones with active AI
private _maxActiveZones = 5;           // Maximum number of active zones
private _cleanupDistance = 2000;       // Distance for cleaning up AI
private _checkInterval = 30;           // Interval in seconds to check for spawn/cleanup

// Enemy count settings
private _minEnemies = 3;               // Minimum number of enemies per spawn
private _maxEnemies = 8;               // Maximum number of enemies per spawn

// Enemy skill range settings
private _minSkill = 0.1;               // Minimum skill level
private _maxSkill = 0.8;               // Maximum skill level

// Equipment arrays
private _primaryWeapons = [
    "arifle_Katiba_F", 
    "arifle_TRG21_F", 
    "arifle_MX_F", 
    "arifle_AKM_F", 
    "arifle_AKS_F", 
    "arifle_CTAR_blk_F"
];
private _secondaryWeapons = [
    "hgun_Pistol_heavy_01_F", 
    "hgun_ACPC2_F", 
    "hgun_Rook40_F", 
    "hgun_PDW2000_F"
];
private _backpacks = [
    "B_FieldPack_cbr", 
    "B_AssaultPack_rgr", 
    "B_TacticalPack_blk", 
    "B_Carryall_khk"
];
private _attachments = [
    "optic_ACO", 
    "optic_Hamr", 
    "optic_Arco", 
    "muzzle_snds_H", 
    "bipod_01_F_blk", 
    "acc_pointer_IR", 
    "optic_DMS"
];
private _grenades = [
    "HandGrenade", 
    "MiniGrenade", 
    "SmokeShell", 
    "SmokeShellRed", 
    "SmokeShellBlue", 
    "SmokeShellYellow"
];
private _uniforms = [
    "U_O_CombatUniform_ocamo", 
    "U_O_GhillieSuit", 
    "U_O_SpecopsUniform_ocamo", 
    "U_I_C_Soldier_Bandit_5_F", 
    "U_I_CombatUniform"
];
private _vests = [
    "V_TacVest_blk", 
    "V_PlateCarrier1_rgr", 
    "V_PlateCarrier2_rgr", 
    "V_BandollierB_khk", 
    "V_Chestrig_blk"
];
private _headgear = [
    "H_HelmetO_ocamo", 
    "H_HelmetSpecO_blk", 
    "H_Bandanna_khk", 
    "H_Watchcap_blk", 
    "H_ShemagOpen_tan"
];

// Function to log messages
private _log = {
    params ["_message"];
    diag_log format ["[AI Spawn System] %1", _message];
};

// Function to get a random position within a range from a player
private _getRandomPosition = {
    params ["_center", "_minDist", "_maxDist"];

    // Validate _center as a valid position
    if (!(_center isEqualType [] && {count _center == 3})) exitWith {
        diag_log "[AI Spawn System] Error: Invalid _center position. Exiting function.";
        [];
    };

    // Validate distance range
    if (_maxDist <= _minDist) exitWith {
        diag_log "[AI Spawn System] Error: Invalid distance range (_minDist >= _maxDist). Exiting function.";
        [];
    };

    // Generate random angle and distance
    private _angle = random 360; // Angle in degrees
    private _distance = _minDist + random (_maxDist - _minDist);

    // Validate distance
    if (_distance <= 0) exitWith {
        diag_log "[AI Spawn System] Error: Invalid _distance calculated (<= 0). Exiting function.";
        [];
    };

    // Use getPos to calculate a random position around _center
    private _randomPos = _center getPos [_distance, _angle];

    // Validate generated position
    if (!(_randomPos isEqualType [] && {count _randomPos == 3})) exitWith {
        diag_log format ["[AI Spawn System] Error: Invalid position generated: %1. Exiting function.", _randomPos];
        [];
    };

    // Log result
    diag_log format ["[AI Spawn System] Generated position: Center=%1, MinDist=%2, MaxDist=%3, FinalPos=%4", _center, _minDist, _maxDist, _randomPos];

    _randomPos
};

// Main server-side loop for AI management
if (isServer) then {
    ["Starting AI spawn system..."] call _log;

    while {true} do {
        ["Scanning for AI spawn opportunities..."] call _log;

        {
            private _player = _x;
            private _playerPos = getPos _player;

            // Check if spawning should occur
            if (random 100 < _spawnChance && {count _spawnedZones < _maxActiveZones}) then {
                // Generate random position around the player
                private _spawnPos = [_playerPos, _minSpawnDistance, _maxSpawnDistance] call _getRandomPosition;

                // Validate _spawnPos
                if (!(_spawnPos isEqualTo [])) then {
                    private _nearBuildings = nearestObjects [_spawnPos, ["House"], 50];
                    private _nearRoads = nearestObjects [_spawnPos, ["Road"], 50];

                    diag_log format [
                        "[AI Spawn System] Found %1 buildings and %2 roads near position %3",
                        count _nearBuildings, count _nearRoads, _spawnPos
                    ];

                    if ((count _nearBuildings > 0 || count _nearRoads > 0)) then {
                        // Mark zone as spawned
                        _spawnedZones pushBack _spawnPos;
                        ["New spawn zone created. Total active zones: " + str (count _spawnedZones)] call _log;

                        // Spawn AI
                        private _group = createGroup east;
                        private _enemyCount = floor (_minEnemies + random (_maxEnemies - _minEnemies + 1));
                        diag_log format ["[AI Spawn System] Spawning %1 enemies.", _enemyCount];
                        for "_i" from 1 to _enemyCount do {
                            private _unitType = selectRandom ["O_Soldier_F", "O_Soldier_LAT_F", "O_Sniper_F"];
                            private _aiUnit = _group createUnit [_unitType, _spawnPos, [], 0, "FORM"];

                            // Synchronize group ownership in multiplayer
                            _group setGroupOwner 2; // Assign group ownership to the server

                            // Randomize skill
                            private _skillLevel = _minSkill + random (_maxSkill - _minSkill);
                            _aiUnit setSkill ["aimingAccuracy", _skillLevel];
                            _aiUnit setSkill ["aimingSpeed", _skillLevel];
                            _aiUnit setSkill ["spotDistance", _skillLevel];
                            _aiUnit setSkill ["spotTime", _skillLevel];
                            _aiUnit setSkill ["courage", _skillLevel];

                            // Assign random clothing and equipment
                            _aiUnit forceAddUniform (selectRandom _uniforms);
                            _aiUnit addVest (selectRandom _vests);
                            _aiUnit addHeadgear (selectRandom _headgear);

                            removeAllWeapons _aiUnit;
                            private _primaryWeapon = selectRandom _primaryWeapons;
                            _aiUnit addWeapon _primaryWeapon;

                            // Add random attachments
                            if (random 100 < 50) then {
                                _aiUnit addPrimaryWeaponItem (selectRandom _attachments);
                            };

                            if (random 100 < 30) then {
                                _aiUnit addWeapon (selectRandom _secondaryWeapons);
                            };

                            _aiUnit addMagazines [_primaryWeapon, 5 + floor random 3];
                            _aiUnit addItemToUniform (selectRandom _grenades);

                            if (random 100 < 30) then {
                                _aiUnit addBackpack (selectRandom _backpacks);
                                _aiUnit addItemToBackpack (selectRandom _grenades);
                            };

                            private _movePos = [_spawnPos, 0, 20] call BIS_fnc_relPos;
                            _aiUnit doMove _movePos;
                        };
                    } else {
                        ["No suitable spawn location found."] call _log;
                    };
                };
            };
        } forEach allPlayers;

// Cleanup zones where no players are nearby
{
    private _zone = _x;
    private _group = _zone select 1; // Assuming _spawnedZones stores [position, group]

    // Validate group
    if (isNull _group) exitWith {
        diag_log "[AI Spawn System] Skipping invalid group in zone.";
    };

    // Check if no players are nearby
    if ((allPlayers findIf {(_x distance (_zone select 0)) < _cleanupDistance}) == -1) then {
        // Delete all units in the group
        {
            if (alive _x) then {
                deleteVehicle _x;
            };
        } forEach units _group;

        // Delete the group
        deleteGroup _group;

        // Remove zone from active zones
        _spawnedZones = _spawnedZones - [_zone];
        diag_log format ["[AI Spawn System] Zone cleaned up. Remaining active zones: %1", count _spawnedZones];
    };
} forEach _spawnedZones;
