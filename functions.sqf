// Wrapper function for killfeed
fnc_showKillfeed = {
    params ["_message", "_killer", "_victim"];

    diag_log format ["[Killfeed] Message: %1 | Killer: %2 | Victim: %3", _message, name _killer, name _victim];

    // Store parameters in missionNamespace
    missionNamespace setVariable ["showKillfeed_message", _message];
    missionNamespace setVariable ["showKillfeed_killer", _killer];
    missionNamespace setVariable ["showKillfeed_victim", _victim];

    // Execute the killfeed script
    [] execVM "showKillfeed.sqf";
};
