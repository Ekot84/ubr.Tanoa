if (hasInterface) then {
    player addEventHandler ["Respawn", {
        player setCustomAimCoef 0.5; // Reduce sway on respawn
    }];
    player setCustomAimCoef 0.5; // Apply reduction at start
};

[] spawn {
    while {true} do {
        // Delay between spawn checks (e.g., 60 seconds)
        sleep 60;

        // Call the AI spawn script
        [] execVM "dynamicSpawnAI.sqf";
    };
};
// Keybind for jump (spacebar in this example)
[] spawn {
    waitUntil {alive player};
    while {true} do {
        if (inputAction "Jump" > 0) then {
            [] execVM "jumpScript.sqf";
            sleep 1; // Prevent spamming
        };
        sleep 0.01; // Check frequently for key press
    };
};
[] execVM "spawnNearBuilding.sqf";
