// Add MPKilled Event Handler for Players with Join-In-Progress Support
[] spawn {
    while {true} do {
        {
            if (isPlayer _x && {isNil {_x getVariable "MPKilledHandlerAssigned"}}) then {
                // Add MPKilled event handler for players
                _x addMPEventHandler ["MPKilled", {
                    params ["_unit", "_killer", "_instigator", "_useEffects"];

                    // Helper function to get side color
                    private _getSideColor = {
                        params ["_unit"];
                        switch (side _unit) do {
                            case west: { "#007BFF" };       // BLUFOR (Blue)
                            case east: { "#FF0000" };       // OPFOR (Red)
                            case resistance: { "#00FF00" }; // INDEPENDENT (Green)
                            case civilian: { "#FFFF00" };   // CIVILIAN (Yellow)
                            default { "#FFFFFF" };          // Default (White)
                        };
                    };

                    // Determine colors for killer and victim
                    private _killerColor = if (!isNull _killer) then { [_killer] call _getSideColor } else { "#FFFFFF" };
                    private _victimColor = if (!isNull _unit) then { [_unit] call _getSideColor } else { "#FFFFFF" };

                    // Format the killfeed message
                    private _message = if (!isNull _killer) then {
                        format ["<t color='%1'>%2</t> was killed by <t color='%3'>%4</t>", _victimColor, name _unit, _killerColor, name _killer]
                    } else {
                        format ["<t color='%1'>%2</t> died.", _victimColor, name _unit];
                    };

                    // Call the killfeed function on all clients
                    ["fnc_showKillfeed", [_message, _killer, _unit]] remoteExec ["call", 0];
                }];

                // Mark the player as having the handler assigned
                _x setVariable ["MPKilledHandlerAssigned", true];
            };
        } forEach allPlayers;

        sleep 5; // Recheck every 5 seconds for new players
    };
};
