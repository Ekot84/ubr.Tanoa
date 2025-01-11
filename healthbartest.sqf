// Log to RPT for debugging
diag_log "Starting health bar script...";

// Ensure the player is initialized
waitUntil { !isNull player && { alive player } };
diag_log "Player initialized.";

// Display the health bar
diag_log "Displaying health bar...";
cutRsc ["RscDisplayHealthBar", "PLAIN"];

// Get the display and controls
private _display = uiNamespace getVariable ["RscDisplayHealthBar", displayNull];
if (isNull _display) then {
    diag_log "Warning: Health bar display not found.";
};

// Retrieve controls
private _healthLabel = _display displayCtrl 1000;
private _healthBarBg = _display displayCtrl 1001;
private _healthBarFg = _display displayCtrl 1002;
private _healthText = _display displayCtrl 1003;

// Debugging: Log control positions if found
if (!isNull _healthBarBg && !isNull _healthBarFg && !isNull _healthText) then {
    diag_log format [
        "Control Positions:\nLabel: %1\nBackground: %2\nForeground: %3\nText: %4",
        ctrlPosition _healthLabel,
        ctrlPosition _healthBarBg,
        ctrlPosition _healthBarFg,
        ctrlPosition _healthText
    ];
} else {
    diag_log "Warning: One or more health bar controls not found.";
};

// Update loop
while { true } do {
    if (!isNull _healthBarFg && !isNull _healthText) then {
        private _health = 1 - damage player; // Calculate health percentage
        private _width = 0.075 * safezoneW * _health; // Scale foreground width dynamically

        // Update health bar and text
        _healthBarFg ctrlSetPosition [0.03 * safezoneW + safezoneX, 0.8 * safezoneH + safezoneY, _width, 0.01 * safezoneH];
        _healthBarFg ctrlCommit 0;
        _healthText ctrlSetText format ["%1%%", round(_health * 100)];

        // Change bar color based on health level
        if (_health < 0.3) then {
            _healthBarFg ctrlSetBackgroundColor [1, 0, 0, 1]; // Red for low health
        } else {
            _healthBarFg ctrlSetBackgroundColor [0, 0.6, 0, 1]; // Darker green otherwise
        };

        //diag_log format ["Health: %1%% | Bar Width: %2", round(_health * 100), _width];
    };

    sleep 0.1; // Refresh rate
};
