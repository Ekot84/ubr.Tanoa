// Add MPKilled Event Handler for Players with Join-In-Progress Support
[] spawn {
    while {true} do {
        // Iterate over all players
        {
            if (isPlayer _x && {isNil {_x getVariable "MPKilledHandlerAssigned"}}) then {
                // Add MPKilled event handler to the player
                ["MPKilled", {
                    params ["_unit", "_killer", "_instigator", "_useEffects"];
                    
                    // Format the killfeed message
                    private _message = if (!isNull _killer) then {
                        format ["<t color='#00FF00'>%1</t> was killed by <t color='#FF0000'>%2</t>", name _unit, name _killer]
                    } else {
                        format ["<t color='#00FF00'>%1</t> died.", name _unit]
                    };
                    
                    // Call the centralized killfeed function to display the message
                    [_message, _killer, _unit] remoteExec ["execVM", 0, "showKillfeed.sqf"];
                }] call CBA_fnc_addEventHandler;

                // Mark the player as having the handler assigned
                _x setVariable ["MPKilledHandlerAssigned", true];
            };
        } forEach allPlayers;

        sleep 5; // Check every 5 seconds for new players or respawns
    };
};
