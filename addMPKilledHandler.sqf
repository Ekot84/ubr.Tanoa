// Add MPKilled Event Handler for Players with Join-In-Progress Support
[] spawn {
    while {true} do {
        {
            if (isPlayer _x && {isNil {_x getVariable "MPKilledHandlerAssigned"}}) then {
                // Add MPKilled event handler for players
                _x addMPEventHandler ["MPKilled", {
                    params ["_unit", "_killer", "_instigator", "_useEffects"];

                    // Format the killfeed message
                    private _message = if (!isNull _killer) then {
                        format ["<t color='#00FF00'>%1</t> was killed by <t color='#FF0000'>%2</t>", name _unit, name _killer]
                    } else {
                        format ["<t color='#00FF00'>%1</t> died.", name _unit];
                    };

                    // Call the wrapper function for the killfeed
                    ["fnc_showKillfeed", [_message, _killer, _unit]] remoteExec ["call", 0];
                }];

                // Mark as assigned
                _x setVariable ["MPKilledHandlerAssigned", true];
            };
        } forEach allPlayers;

        sleep 5; // Recheck every 5 seconds
    };
};
