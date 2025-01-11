if (hasInterface) then {
    player addEventHandler ["Respawn", {
        player setCustomAimCoef 0.5; // Reduce sway on respawn
    }];
    player setCustomAimCoef 0.5; // Apply reduction at start
};