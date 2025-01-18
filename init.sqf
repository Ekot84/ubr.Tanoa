[] execVM "compassHUD.sqf";
//[] execVM "healthBar.sqf"; // Add the health bar
[] execVM "arcadeHealth.sqf"; // Optional: Arcade health system
[] execVM "healthbartest.sqf";
[] execVM "kill_death_counter.sqf";
//[] execVM "killTicker.sqf";
[] execVM "staminaRegen.sqf";
[] execVM "debugHint.sqf";

// Sep. EnemySpawnscript
[] spawn {
    execVM "enemyspawning\enemySpawnScript.sqf";
};

//[] execVM "enemySpawnScript.sqf"; // Old enemySpawnScript
[] execVM "globalCleanup.sqf";
[] execVM "leaderboard.sqf";  // Runs the leaderboard script


// Loot Manager
[] execVM "SCCLoot\lootInit.sqf";


diag_log "Initializing EntityKilled Debugging...";

// Add the event handler
/*["EntityKilled", {
    params ["_killed", "_killer", "_instigator"];

    // Debugging: Log raw event data
    diag_log format ["EntityKilled Event Triggered! Killed: %1, Killer: %2, Instigator: %3", _killed, _killer, _instigator];

    // Display a hint for testing
    private _killedName = if (isNil "_killed") then {"Unknown"} else {name _killed};
    private _killerName = if (isNil "_killer") then {"Unknown"} else {name _killer};
    hint format ["%1 killed %2", _killerName, _killedName];
}] call CBA_fnc_addEventHandler;*/
// Add eventhandler for player
/*player addMPEventHandler ["MPKilled", {
    params ["_unit", "_killer", "_instigator", "_useEffects"];

    if (isNull _unit) exitWith { diag_log "[INIT_EH] Kill event handler triggered with null unit."; };
    if (isNull _killer) then { diag_log "[INIT_EH] Killer is null, likely an environmental death."; };

    // Get sides and names
    private _sideDeadUnit = side group _unit;
    private _sideKiller = if (isNull _killer) then {"Unknown"} else {side group _killer};
    private _deadUnitName = name _unit; // Directly fetch the name set by setName
    private _killerName = if (isNull _killer) then {"Environment"} else {name _killer};

    // Log kill event
    diag_log format ["[INIT_EH] Enemy killed: %1 %2 by %3 %4", _sideDeadUnit, _deadUnitName, _sideKiller, _killerName];
}];
*/

