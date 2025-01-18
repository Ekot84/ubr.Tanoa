// Debug log
diag_log "Starting HUD script...";

// **Wait for the player to initialize**
waitUntil { !isNull player && { alive player } };
diag_log "Player initialized.";

// **Display the HUD**
cutRsc ["RscDisplayHUD", "PLAIN"];

// **Get the display**
private _display = uiNamespace getVariable ["RscDisplayHUD", displayNull];
if (isNull _display) exitWith {
    diag_log "Error: HUD display not found.";
};

// **Retrieve UI controls**
private _healthBarFg = _display displayCtrl 1002;
private _healthText = _display displayCtrl 1003;
private _killCounter = _display displayCtrl 2000;
private _softVehicleCounter = _display displayCtrl 2001;
private _armorCounter = _display displayCtrl 2002;
private _airCounter = _display displayCtrl 2003;
private _deathCounter = _display displayCtrl 2004;
private _totalScoreCtrl = _display displayCtrl 2005; // ✅ Renamed to avoid conflict

// **Ensure UI elements exist**
private _missingElements = [];
if (isNull _killCounter) then { _missingElements pushBack "KillCounter (2000)"; };
if (isNull _softVehicleCounter) then { _missingElements pushBack "SoftVehicleCounter (2001)"; };
if (isNull _armorCounter) then { _missingElements pushBack "ArmorCounter (2002)"; };
if (isNull _airCounter) then { _missingElements pushBack "AirCounter (2003)"; };
if (isNull _deathCounter) then { _missingElements pushBack "DeathCounter (2004)"; };
if (isNull _totalScoreCtrl) then { _missingElements pushBack "TotalScore (2005)"; };

if (count _missingElements > 0) exitWith {
    diag_log format ["HUD: ERROR - Missing UI elements: %1", _missingElements];
};

// **Initialize counters**
private _kills = 0;
private _deaths = 0;

// **Start update loop**
while {true} do {
    // **Update Health Bar**
    private _health = 1 - damage player;
    private _width = 0.075 * safezoneW * _health; // Scale foreground width dynamically
    _healthBarFg ctrlSetPosition [0.03 * safezoneW + safezoneX, 0.8 * safezoneH + safezoneY, _width, 0.01 * safezoneH];
    _healthBarFg ctrlCommit 0;
    _healthText ctrlSetText format ["%1%%", round(_health * 100)];

    // **Change health bar color based on health level**
    if (_health < 0.3) then {
        _healthBarFg ctrlSetBackgroundColor [1, 0, 0, 1]; // Red for low health
    } else {
        _healthBarFg ctrlSetBackgroundColor [0, 0.6, 0, 1]; // Green otherwise
    };

    // **Update Kill & Death Counters using getPlayerScores**
    private _scores = getPlayerScores player;

    if (count _scores >= 6) then {
        private _killsInfantry = _scores select 0;
        private _killsSoft = _scores select 1;
        private _killsArmor = _scores select 2;
        private _killsAir = _scores select 3;
        private _deaths = _scores select 4;
        private _totalScore = _scores select 5; // ✅ This is now just a number, NOT a control!

        // **Update HUD UI**
        _killCounter ctrlSetText format ["Infantry Kills: %1", _killsInfantry];
        _softVehicleCounter ctrlSetText format ["Soft Kills: %1", _killsSoft];
        _armorCounter ctrlSetText format ["Armor Kills: %1", _killsArmor];
        _airCounter ctrlSetText format ["Air Kills: %1", _killsAir];
        _deathCounter ctrlSetText format ["Deaths: %1", _deaths];
        _totalScoreCtrl ctrlSetText format ["Total Kills: %1", _totalScore]; // ✅ Now using `_totalScoreCtrl`

        // **Debug Log**
        diag_log format ["HUD: Updated UI -> Infantry: %1 | Soft: %2 | Armor: %3 | Air: %4 | Deaths: %5 | Total: %6",
            _killsInfantry, _killsSoft, _killsArmor, _killsAir, _deaths, _totalScore];
    } else {
        diag_log "HUD: ERROR - Score data unavailable!";
    };

    sleep 1; // **Refresh every second for better responsiveness**
};

// **Event Handlers for Kills and Deaths**
player addEventHandler ["Killed", {
    _deaths = _deaths + 1;
    _deathCounter ctrlSetText format ["Deaths: %1", _deaths];
    diag_log format ["Player died. Deaths: %1", _deaths];
}];

addMissionEventHandler ["EntityKilled", {
    params ["_killed", "_killer"];
    if (_killer == player) then {
        _kills = _kills + 1;
        _killCounter ctrlSetText format ["Kills: %1", _kills];
        diag_log format ["Player killed an enemy. Kills: %1", _kills];
    };
}];
