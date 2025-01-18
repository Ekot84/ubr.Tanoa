[] execVM "compassHUD.sqf";
//[] execVM "healthBar.sqf"; // Add the health bar
[] execVM "arcadeHealth.sqf"; // Optional: Arcade health system
[] execVM "healthbartest.sqf";
//[] execVM "kill_death_counter.sqf";
//[] execVM "killTicker.sqf";
[] execVM "staminaRegen.sqf";

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


diag_log "Initializing EntityKilled Debugging...";

// Ekos temp grejer

/*[] execVM "dumpUniformsToFile.sqf";
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
}];*/

// END EKOS TEMP

