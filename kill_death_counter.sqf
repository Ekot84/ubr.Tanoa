diag_log "HUD: Waiting for player to initialize...";

// **Wait until player and HUD are initialized**
waitUntil { !isNull player && { alive player } };
diag_log "HUD: Player initialized.";

// **Ensure HUD Layer Exists**
["RscDisplayHUD", "PLAIN", 1] call BIS_fnc_rscLayer;
sleep 0.5; // Give UI time to load

// **Ensure HUD is initialized**
private _display = displayNull;
private _attempts = 0;
while {isNull _display && _attempts < 10} do {
    _display = uiNamespace getVariable ["RscDisplayHUD", displayNull];
    _attempts = _attempts + 1;
    if (isNull _display) then {
        diag_log format ["HUD: Attempt %1 - Waiting for HUD display to be initialized...", _attempts];
        sleep 1;
    };
};

// **Final check before proceeding**
if (isNull _display) exitWith {
    diag_log "HUD: ERROR - HUD UI display not found after forced reload!";
};

// **Retrieve UI controls**
private _killCounter = _display displayCtrl 2000;
private _softVehicleCounter = _display displayCtrl 2001;
private _armorCounter = _display displayCtrl 2002;
private _airCounter = _display displayCtrl 2003;
private _deathCounter = _display displayCtrl 2004;
private _totalScore = _display displayCtrl 2005;

// **Check if all UI elements are valid**
private _missingElements = [];
if (isNull _killCounter) then { _missingElements pushBack "KillCounter (2000)"; };
if (isNull _softVehicleCounter) then { _missingElements pushBack "SoftVehicleCounter (2001)"; };
if (isNull _armorCounter) then { _missingElements pushBack "ArmorCounter (2002)"; };
if (isNull _airCounter) then { _missingElements pushBack "AirCounter (2003)"; };
if (isNull _deathCounter) then { _missingElements pushBack "DeathCounter (2004)"; };
if (isNull _totalScore) then { _missingElements pushBack "TotalScore (2005)"; };

// **If there are missing elements, log them and exit**
if (count _missingElements > 0) exitWith {
    diag_log format ["HUD: ERROR - The following UI elements were not found: %1", _missingElements];
};

// **Debug Log: UI Elements Assigned Successfully**
diag_log "HUD: All UI elements found! Starting HUD update...";

// **Loop to Continuously Update HUD**
[] spawn {
    while {true} do {
        diag_log "HUD: Updating UI elements...";

        private _scores = getPlayerScores player;

        if (count _scores >= 6) then {
            // **Split array into individual variables**
            private _killsInfantry = _scores select 0;
            private _killsSoft = _scores select 1;
            private _killsArmor = _scores select 2;
            private _killsAir = _scores select 3;
            private _deaths = _scores select 4;
            private _totalScore = _scores select 5;

            diag_log format ["HUD: Splitted Scores -> Infantry: %1 | Soft: %2 | Armor: %3 | Air: %4 | Deaths: %5 | Total: %6",
                _killsInfantry, _killsSoft, _killsArmor, _killsAir, _deaths, _totalScore];

            // **Ensure `_killCounter` is not null before updating UI**
            if (!isNull _killCounter) then {
                _killCounter ctrlSetText format ["Infantry Kills: %1", _killsInfantry];
            } else {
                diag_log "HUD: ERROR - _killCounter is NULL!";
            };

            if (!isNull _softVehicleCounter) then {
                _softVehicleCounter ctrlSetText format ["Soft Kills: %1", _killsSoft];
            };
            if (!isNull _armorCounter) then {
                _armorCounter ctrlSetText format ["Armor Kills: %1", _killsArmor];
            };
            if (!isNull _airCounter) then {
                _airCounter ctrlSetText format ["Air Kills: %1", _killsAir];
            };
            if (!isNull _deathCounter) then {
                _deathCounter ctrlSetText format ["Deaths: %1", _deaths];
            };
            if (!isNull _totalScore) then {
                _totalScore ctrlSetText format ["Total Kills: %1", _totalScore];
            };

            // **Debug Log**
            diag_log format ["HUD: Updated UI -> Infantry: %1 | Soft: %2 | Armor: %3 | Air: %4 | Deaths: %5 | Total: %6",
                _killsInfantry, _killsSoft, _killsArmor, _killsAir, _deaths, _totalScore];
        } else {
            diag_log "HUD: ERROR - Score data unavailable or incomplete!";
        };

        sleep 5; // Refresh every 5 seconds
    };
};
