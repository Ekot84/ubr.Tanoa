// Ensure _this is an array or directly use the unit
private _unit = if (typeName _this == "OBJECT") then { _this } else { if (count _this > 0) then { _this select 0 } else { objNull }; };

// Validate _unit before proceeding
if (isNull _unit) exitWith { systemChat "ERROR: _unit is null! Script terminated."; };

// Debug Variables
private _crateCooldown = 300; // Cooldown before crate action can be used again
private _crateActionText = "Request Squad Ammo Crate"; // Text for the action
private _crateSpawnDistance = 3; // Distance from unit where the crate spawns
private _crateClass = "Box_NATO_Ammo_F"; // Class of the ammo crate

// **Function: Adds the squad-based crate spawn action**
_addCrateAction = {
    params ["_unit", "_crateCooldown", "_crateActionText", "_crateSpawnDistance", "_crateClass"];

    if (isNull _unit) exitWith { systemChat "ERROR: Cannot add action to a null unit!"; };

    private _actionID = _unit addAction [_crateActionText, {
        params ["_target", "_caller", "_actionId", "_arguments"];

        // Extract necessary variables from _arguments
        _arguments params ["_crateCooldown", "_crateActionText", "_crateSpawnDistance", "_crateClass", "_addCrateAction"];

        systemChat "DEBUG: Squad Crate spawn action activated!";

        // **Calculate a position in front of the player**
        private _direction = getDir _caller;
        private _pos = _caller getPos [_crateSpawnDistance, _direction];

        // Ensure it's slightly above ground to prevent clipping
        _pos set [2, (_pos select 2) + 0.5];

        systemChat format ["DEBUG: Crate should spawn at: %1", _pos];

        // **Check for Valid Position Before Spawning**
        if (_pos isEqualTo [0,0,0] || _pos isEqualTo []) exitWith {
            systemChat "ERROR: Invalid crate spawn position!";
        };

        // **Spawn an empty crate**
        private _crate = createVehicle [_crateClass, _pos, [], 0, "CAN_COLLIDE"];

        if (isNull _crate) exitWith { systemChat "ERROR: Crate failed to spawn!"; };

        systemChat format ["SUCCESS: Squad Crate spawned at %1", getPos _crate];

        // Make crate editable in Zeus
        _crate setVariable ["BIS_fnc_arsenal_data", nil, true];

        // **Remove action after use**
        _caller removeAction _actionId;

        // **Start cooldown before allowing another crate**
        [{
            params ["_unit", "_crateCooldown", "_crateActionText", "_crateSpawnDistance", "_crateClass", "_addCrateAction"];
            systemChat "DEBUG: Crate cooldown finished!";
            [_unit, _crateCooldown, _crateActionText, _crateSpawnDistance, _crateClass] call _addCrateAction;
        }, [_caller, _crateCooldown, _crateActionText, _crateSpawnDistance, _crateClass, _addCrateAction], _crateCooldown] call CBA_fnc_waitAndExecute;

    }, [_crateCooldown, _crateActionText, _crateSpawnDistance, _crateClass, _addCrateAction]]; // **Pass parameters correctly**
};

// **Execute the function and pass all required variables**
[_unit, _crateCooldown, _crateActionText, _crateSpawnDistance, _crateClass] call _addCrateAction;
