// Parameters
private _spawnChance = 0.99; // 20% chance to spawn AI
private _spawnRadius = 1000; // 1 km spawn radius
private _cleanupDistance = 2000; // Distance threshold for cleanup
private _enemyCountRange = [1, 8]; // Configurable range for number of AI to spawn (min, max)
private _groupSide = east; // Side of the AI (e.g., east, west, independent)

// Random equipment arrays
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

// Check if the player is in a helicopter
if (vehicle player != player && {typeOf (vehicle player) find "Helicopter" != -1}) exitWith {
    diag_log "Road AI spawn skipped because the player is in a helicopter.";
};

// Decide if AI should spawn based on chance
if (random 1 > _spawnChance) exitWith {
    diag_log "Road AI spawn skipped due to low probability.";
};

// Find a random position around the player within the spawn radius
private _playerPos = getPosATL player;
private _spawnPos = [_playerPos, _spawnRadius, _spawnRadius * 1.5, 1, 0, 20, 0] call BIS_fnc_findSafePos;

// Validate the spawn position (ensure it’s not too close to the player)
if (_spawnPos distance _playerPos < 800) exitWith {
    diag_log "Road Spawn position too close to player, skipping.";
};

// Determine the number of enemies to spawn
private _minCount = _enemyCountRange select 0;
private _maxCount = _enemyCountRange select 1;
private _enemyCount = floor (_minCount + random (_maxCount - _minCount + 1));

// Create a group and spawn units
private _group = createGroup _groupSide;
for "_i" from 1 to _enemyCount do {
    private _unit = _group createUnit ["O_Soldier_F", _spawnPos, [], 0, "FORM"]; // Use desired faction

    // Assign random equipment
    if (!isNull _unit) then {
        // Randomize uniform, vest, backpack, and headgear
        _unit forceAddUniform selectRandom _uniforms;
        _unit addVest selectRandom _vests;
        _unit addBackpack selectRandom _backpacks;
        _unit addHeadgear selectRandom _headgear;

        // Assign random weapon
        _unit addWeapon selectRandom _weapons;

        // Add random items to backpack
        _unit addItemToBackpack selectRandom _items;

        // Assign compatible magazines
        private _compatibleMagazines = currentWeapon _unit call BIS_fnc_compatibleMagazines;
        if (count _compatibleMagazines > 0) then {
            _unit addMagazine (_compatibleMagazines select 0);
        };

        // Assign random skill
        _unit setSkill random 0.5; // Adjust skill level as needed
    };
};

// Optional: Assign a patrol task to the AI
[_group, _spawnPos, 300] call BIS_fnc_taskPatrol;

// Log the spawn
diag_log format ["Road AI group spawned at %1 with %2 units.", _spawnPos, _enemyCount];

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
            diag_log format ["Road AI group at %1 removed (player too far).", _spawnPos];
            breakOut "Cleanup"; // Exit the loop once the group is removed
        };
    };
};
