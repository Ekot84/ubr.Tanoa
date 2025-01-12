// Add MPKilled Event Handler Script
[] spawn {
    while {true} do {
        // Iterate over all players
        {
            if (isPlayer _x && {!(_x getVariable ["MPKilledHandlerAssigned", false])}) then {
                // Add MPKilled event handler
                _x addEventHandler ["MPKilled", {
                    params ["_unit", "_killer", "_instigator"];
                    // Example logic: Display a message when killed
                    if (!isNull _killer) then {
                        systemChat format ["%1 was killed by %2", name _unit, name _killer];
                    } else {
                        systemChat format ["%1 died.", name _unit];
                    };
                }];

                // Mark the player as assigned
                _x setVariable ["MPKilledHandlerAssigned", true];
            };
        } forEach allPlayers;

        sleep 5; // Check every 5 seconds for new players or respawns
    };
};
