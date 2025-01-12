// Function to execute the killfeed logic with parameters
fnc_showKillfeed = {
    params ["_message", "_killer", "_victim"];

    // Set parameters in the missionNamespace
    missionNamespace setVariable ["showKillfeed_message", _message];
    missionNamespace setVariable ["showKillfeed_killer", _killer];
    missionNamespace setVariable ["showKillfeed_victim", _victim];

    // Execute the killfeed script
    [] execVM "showKillfeed.sqf";
};
