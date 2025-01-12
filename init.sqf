[] execVM "compassHUD.sqf";
//[] execVM "healthBar.sqf"; // Add the health bar
[] execVM "arcadeHealth.sqf"; // Optional: Arcade health system
[] execVM "healthbartest.sqf";
[] execVM "kill_death_counter.sqf";
[] execVM "killTicker.sqf";
[] execVM "staminaRegen.sqf";
[] execVM "enemySpawnScript.sqf";

diag_log "Initializing EntityKilled Debugging...";

// Add the event handler
["EntityKilled", {
    params ["_killed", "_killer", "_instigator"];

    // Debugging: Log raw event data
    diag_log format ["EntityKilled Event Triggered! Killed: %1, Killer: %2, Instigator: %3", _killed, _killer, _instigator];

    // Display a hint for testing
    private _killedName = if (isNil "_killed") then {"Unknown"} else {name _killed};
    private _killerName = if (isNil "_killer") then {"Unknown"} else {name _killer};
    hint format ["%1 killed %2", _killerName, _killedName];
}] call CBA_fnc_addEventHandler;

