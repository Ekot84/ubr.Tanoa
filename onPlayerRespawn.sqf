[] execVM "arcadeHealth.sqf";

        // Add MP event handler to track kills
        player addMPEventHandler ["MPKilled", {
        params ["_unit", "_killer", "_instigator", "_useEffects"];

        if (isNull _unit) exitWith { diag_log "[AI Spawner] Kill event handler triggered with null unit."; };
        if (isNull _killer) then { diag_log "[AI Spawner] Killer is null, likely an environmental death."; };

        // Get sides and names
        private _sideDeadUnit = side group _unit;
        private _sideKiller = if (isNull _killer) then {"Unknown"} else {side group _killer};
        private _deadUnitName = name _unit; // Directly fetch the name set by setName
        private _killerName = if (isNull _killer) then {"Environment"} else {name _killer};

        // Log kill event
        diag_log format ["[AI Spawner] Enemy killed: %1 %2 by %3 %4", _sideDeadUnit, _deadUnitName, _sideKiller, _killerName];
    }];
    
    player addEventHandler ["Respawn", {
    params ["_unit", "_corpse"];
    
    private _loadout = _corpse getVariable ["savedLoadout", []];
    if (count _loadout > 0) then {
        _unit setUnitLoadout _loadout;
    };
}];
