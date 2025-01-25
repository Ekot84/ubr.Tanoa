[] execVM "compassHUD.sqf";
[] execVM "arcadeHealth.sqf"; // Optional: Arcade health system
[] execVM "healthbartest.sqf";
//[] execVM "kill_death_counter.sqf";
[] execVM "spawn_boats.sqf";
[] execVM "staminaRegen.sqf";
[] execVM "hitTracking.sqf"; // Loads hit tracking system
//[] execVM "simpleTracking.sqf";
// Sep. EnemySpawnscript
[] spawn {
    execVM "enemyspawning\enemySpawnScript.sqf";
};

//[] execVM "enemySpawnScript.sqf"; // Old enemySpawnScript
[] execVM "globalCleanup.sqf";
//[] execVM "leaderboard.sqf";  // Runs the leaderboard script

[] execVM "supplyCrate.sqf";
// Loot Manager
//[] execVM "SCCLoot\lootInit.sqf";

if (isServer) then {
    execVM "server_ammo_tracker.sqf"; // Runs on server
};

if (hasInterface) then {
    execVM "ammo_tracker.sqf"; // Runs on client
};

diag_log "Initializing EntityKilled Debugging...";

// Ekos temp DEBUG
/*
[] execVM "dumpUniformsToFile.sqf";
[] execVM "debugHint.sqf";
player setAnimSpeedCoef 2.5;
player enableStamina false;
player enableFatigue false;
player allowDamage false;

// Add an action to the player
// Ensure the variable is initialized
if (isNil "godModeActive") then { godModeActive = false; };

// Add an action to the player
godModeAction = player addAction ["Toggle God Mode", {
    params ["_target", "_caller", "_actionId", "_arguments"];
    
    // Ensure the variable is properly defined
    if (isNil "godModeActive") then { godModeActive = false; };

    // Toggle God Mode
    if (godModeActive) then {
        _caller allowDamage true;
        godModeActive = false;
        hint "God Mode Disabled";
    } else {
        _caller allowDamage false;
        godModeActive = true;
        hint "God Mode Enabled";
    };
}];

// END EKOS TEMP
player addAction ["Log AI Hit Parts", {
    private _unit = cursorTarget; // The AI unit you are aiming at

    if (isNull _unit || {side _unit == west}) exitWith {
        hint "Aim at an AI unit to log hit parts!";
    };

    private _hitPoints = getAllHitPointsDamage _unit;

    diag_log format ["[HitTracking] All hit points for %1: %2", typeOf _unit, _hitPoints];

    hint format ["Logged hit points for AI: %1\nCheck RPT logs.", typeOf _unit];
}];
*/
