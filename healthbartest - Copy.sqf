// Debug log
diag_log "Starting HUD script...";

// Wait for the player to initialize
waitUntil { !isNull player && { alive player } };
diag_log "Player initialized.";

// Display the HUD
cutRsc ["RscDisplayHUD", "PLAIN"];

// Get the display and controls
private _display = uiNamespace getVariable ["RscDisplayHUD", displayNull];
if (isNull _display) then {
    diag_log "Error: HUD display not found.";
};

// Retrieve controls
private _healthBarFg = _display displayCtrl 1002;
private _healthText = _display displayCtrl 1003;

// Initialize counters
private _kills = 0;
private _deaths = 0;

// Update loop
while { true } do {
    // Update health bar and text
    private _health = 1 - damage player;
    private _width = 0.075 * safezoneW * _health; // Scale foreground width dynamically
    _healthBarFg ctrlSetPosition [0.03 * safezoneW + safezoneX, 0.8 * safezoneH + safezoneY, _width, 0.01 * safezoneH];
    _healthBarFg ctrlCommit 0;
    _healthText ctrlSetText format ["%1%%", round(_health * 100)];

    // Change bar color based on health level
    if (_health < 0.3) then {
        _healthBarFg ctrlSetBackgroundColor [1, 0, 0, 1]; // Red for low health
    } else {
        _healthBarFg ctrlSetBackgroundColor [0, 0.6, 0, 1]; // Darker green otherwise
    };

    sleep 0.1;
};

// Event Handlers for Kills and Deaths
player addEventHandler ["Killed", {
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
}];
