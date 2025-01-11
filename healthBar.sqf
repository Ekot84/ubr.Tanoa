// healthbar.sqf

// Wait until the player is ready
waitUntil { !isNull player && { alive player } };

// Create the health bar display
private _display = findDisplay 46;

// Background for the health bar
private _healthBarBg = _display ctrlCreate ["RscText", -1];
_healthBarBg ctrlSetPosition [safeZoneX + 0.4, safeZoneY + safeZoneH - 0.1, safeZoneW * 0.2, 0.03];
_healthBarBg ctrlSetBackgroundColor [0, 0, 0, 0.7];
_healthBarBg ctrlCommit 0;

// Foreground for the health bar
private _healthBar = _display ctrlCreate ["RscText", -1];
_healthBar ctrlSetPosition [safeZoneX + 0.4, safeZoneY + safeZoneH - 0.1, safeZoneW * 0.2, 0.03];
_healthBar ctrlSetBackgroundColor [0, 1, 0, 1]; // Green
_healthBar ctrlCommit 0;

// Health bar update loop
while { true } do {
    private _damage = damage player;
    private _width = safeZoneW * 0.2 * (1 - _damage); // Scale width based on health

    _healthBar ctrlSetPosition [safeZoneX + 0.4, safeZoneY + safeZoneH - 0.1, _width, 0.03];

    // Change color based on health
    if (_damage > 0.7) then {
        _healthBar ctrlSetBackgroundColor [1, 0, 0, 1]; // Red
    } else {
        _healthBar ctrlSetBackgroundColor [0, 1, 0, 1]; // Green
    };

    sleep 0.1; // Refresh rate
};
