if (!hasInterface) exitWith {}; // Only runs on clients

waitUntil { !isNull player && { alive player } };

private _ammoKey = format ["ammoUsed_%1", getPlayerUID player]; // Unique variable per player
player setVariable [_ammoKey, 0, true]; // Ensure it's initialized correctly

// **Event Handler: Tracks Each Bullet Used**
player addEventHandler ["FiredMan", {
    params ["_unit", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_projectile"];

    if (!isNil "_ammo") then {
        private _ammoKey = format ["ammoUsed_%1", getPlayerUID _unit]; // Unique key
        private _ammoUsed = _unit getVariable [_ammoKey, 0];

        if (isNil "_ammoUsed" || {typeName _ammoUsed != "SCALAR"}) then {
            _ammoUsed = 0; // Prevent NaN issues
        };

        _ammoUsed = _ammoUsed + 1; // **Only count ONE bullet per shot**
        _unit setVariable [_ammoKey, _ammoUsed, true]; // Sync to server
        publicVariableServer _ammoKey; // Send to server for persistence

        //diag_log format ["[DEBUG] %1 fired: %2 | Total Bullets Used: %3", name _unit, _ammo, _ammoUsed];
    };
}];
