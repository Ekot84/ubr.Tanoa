//[_this] execVM "spawn_ammo_crate.sqf";

_unit = _this select 0;
_crateCooldown = 600; // 10 minutes (600 seconds)
_crateActionText = "Request Ammo Crate"; // Text for action
_crateSpawnDistance = 3; // Crate appears 3m in front of unit

if (isNull _unit) exitWith {};

// Function: Adds the crate spawn action
private _addCrateAction = {
    private _actionID = _unit addAction [_crateActionText, {
        params ["_target", "_caller", "_actionId", "_arguments"];

        // Spawn crate in front of player
        private _pos = _caller getPos [ _crateSpawnDistance, getDir _caller ];
        private _crate = createVehicle ["Box_NATO_Ammo_F", _pos, [], 0, "CAN_COLLIDE"];

        // Remove action after use
        _caller removeAction _actionId;

        // Restart cooldown
        _caller setVariable ["ammoCrateAvailable", false];
        [_caller] spawn {
            params ["_unit"];
            sleep _crateCooldown; // Wait 10 minutes
            
            // Notify player that the ammo crate is ready
            if (isPlayer _unit) then {
                _unit sideChat "Ammo Crate is available!";
                hint "⚡ Ammo Crate Ready! Request it from the action menu.";
                playSound "Hint"; // Plays a notification sound
            };

            _unit setVariable ["ammoCrateAvailable", true];
            [_unit] call _addCrateAction; // Re-add the action
        };
    }];

    _unit setVariable ["ammoCrateActionID", _actionID];
};

// Initial cooldown before first crate request
[_unit] spawn {
    params ["_unit"];
    sleep _crateCooldown;

    // Notify the player when the crate is first available
    if (isPlayer _unit) then {
        _unit sideChat "Ammo Crate is available!";
        hint "⚡ Ammo Crate Ready! Request it from the action menu.";
        playSound "Hint";
    };

    _unit setVariable ["ammoCrateAvailable", true];
    [_unit] call _addCrateAction;
};
