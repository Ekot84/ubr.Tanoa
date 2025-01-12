// Add MPKilled Event Handler Script with centralized killfeed
[] spawn {
    while {true} do {
        // Iterate over all players
        {
            if (isPlayer _x && {isNil {_x getVariable "MPKilledHandlerAssigned"}}) then {
                // Add MPKilled event handler if it's not already assigned
                _x addMPEventHandler ["MPKilled", {
                    params ["_unit", "_killer", "_instigator"];
                    // Example logic for killfeed
                    if (!isNull _killer) then {
                        // Format the message for killfeed
                        private _message = format ["%1 was killed by %2", name _unit, name _killer];
                    } else {
                        _message = format ["%1 died.", name _unit];
                    };
                    
                    // Call the centralized killfeed function to display the message
                    [_message] remoteExec ["execVM", 0, "showKillfeed.sqf"]; // Use 0 to target all clients
                }];
                
                // Mark the player as having the handler assigned
                _x setVariable ["MPKilledHandlerAssigned", true];
            };
        } forEach allPlayers;

        sleep 5; // Check every 5 seconds for new players or respawns
    };
};
