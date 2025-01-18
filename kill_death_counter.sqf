// Debug log
diag_log "Starting Kill/Death Counter script...";

// Wait for the player to initialize
waitUntil { !isNull player && { alive player } };
diag_log "Player initialized.";

// Display the HUD
cutRsc ["RscDisplayHUD", "PLAIN"];

// Get the display and controls
private _display = uiNamespace getVariable ["RscDisplayHUD", displayNull];
if (isNull _display) then {
    diag_log "Error: Kill/Death counter display not found.";
};

// Retrieve controls
private _killCounter = _display displayCtrl 2000;
private _deathCounter = _display displayCtrl 2001;

// Initialize counters
private _kills = 0;
private _deaths = 0;

// Monitor events
/*player addEventHandler ["Killed", {
    _deaths = _deaths + 1;
    _deathCounter ctrlSetText format ["Deaths: %1", _deaths];
    diag_log format ["Player died. Deaths: %1", _deaths];
}];

addMissionEventHandler ["EntityKilled", {
    params ["_killed", "_killer"];
    if (_killer == player && {side _killer == side player}) then {
        _kills = _kills + 1;
        _killCounter ctrlSetText format ["Kills: %1", _kills];
        diag_log format ["Player killed an enemy. Kills: %1", _kills];
    };
}];*/

// Debug log to verify script running
diag_log "Kill/Death Counter script running.";
