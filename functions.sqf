// Wrapper function for killfeed
fnc_showKillfeed = {
    params ["_message", "_killer", "_victim"];

    // Log for debugging
    diag_log format ["[Killfeed] Message: %1 | Killer: %2 | Victim: %3", _message, name _killer, name _victim];

    // Execute killfeed logic (e.g., update UI)
    [] execVM "showKillfeed.sqf";
};
