// healthbartest.sqf (Now includes Top 3 Player Leaderboard & HUD Updates with Kill Counter and Health Bar Fixes)

// **Wait for the player to initialize**
waitUntil { !isNull player && { alive player } };
diag_log "Player initialized.";

// **Display the HUD**
cutRsc ["RscDisplayHUD", "PLAIN"];
sleep 0.5; // Ensure UI loads before retrieving controls

// **Initialize Ammo Used Counter**
private _ammoKey = format ["ammoUsed_%1", getPlayerUID player]; // Unique per-player key

// **Get the display and retry if necessary**
private _display = uiNamespace getVariable ["RscDisplayHUD", displayNull];
private _attempts = 0;
while { isNull _display && _attempts < 5 } do {
    diag_log "HUD: Retrying display retrieval...";
    sleep 1;
    _display = uiNamespace getVariable ["RscDisplayHUD", displayNull];
    _attempts = _attempts + 1;
};

if (isNull _display) exitWith {
    diag_log "FATAL ERROR: HUD display could not be initialized. Aborting HUD script.";
};

// **Retrieve UI controls and ensure validity**
private _uiElements = [
    ["_healthBarFg", 1002],
    ["_healthText", 1003],
    ["_killCounter", 2000],
    ["_softVehicleCounter", 2001],
    ["_armorCounter", 2002],
    ["_airCounter", 2003],
    ["_deathCounter", 2004],
    ["_totalScoreCtrl", 2005],
    ["_ammoCounter", 2006],
    ["_hitCounter", 2007],
    ["_ammoHitRatio", 2008], 
    ["_top1", 2010],
    ["_top2", 2011],
    ["_top3", 2012], 
    ["_top1_2", 2013],
    ["_top2_2", 2014], 
    ["_top3_2", 2015] 
];

private _uiMap = createHashMap;
{
    private _ctrl = _display displayCtrl (_x select 1);
    if (!isNull _ctrl) then {
        _uiMap set [_x select 0, _ctrl];
    } else {
        diag_log format ["HUD: ERROR - UI Element %1 (ID: %2) not found!", _x select 0, _x select 1];
    };
} forEach _uiElements;

// **Store UI Map in uiNamespace so it is accessible inside spawn**
uiNamespace setVariable ["HUD_UI_Map", _uiMap];

if (count _uiMap == 0) exitWith {
    diag_log "FATAL ERROR: No valid UI elements found. Aborting HUD script.";
};

// **Spawn Loop for Continuous Updates**
[] spawn {
    while {true} do {
        private _uiMapLocal = uiNamespace getVariable ["HUD_UI_Map", createHashMap];

        // Ensure UI map exists
        if (count _uiMapLocal == 0) then {
            diag_log "HUD: ERROR - UI Map is still empty. Skipping update.";
            sleep 1;
            continue;
        };

        // **Update Health Bar**
        private _health = 1 - damage player;
        if (!isNull (_uiMapLocal get "_healthText")) then {
            (_uiMapLocal get "_healthText") ctrlSetText format ["%1%%", round(_health * 100)];
        };
        if (!isNull (_uiMapLocal get "_healthBarFg")) then {
            if (_health < 0.3) then {
                (_uiMapLocal get "_healthBarFg") ctrlSetBackgroundColor [1, 0, 0, 1];
            } else {
                (_uiMapLocal get "_healthBarFg") ctrlSetBackgroundColor [0, 0.6, 0, 1];
            };
        };

        // **Update Kill & Death Counters using getPlayerScores**
        private _scores = getPlayerScores player;
        if (count _scores >= 6) then {
            (_uiMapLocal get "_killCounter") ctrlSetText format ["Infantry Kills: %1", _scores select 0];
            (_uiMapLocal get "_softVehicleCounter") ctrlSetText format ["Soft Kills: %1", _scores select 1];
            (_uiMapLocal get "_armorCounter") ctrlSetText format ["Armor Kills: %1", _scores select 2];
            (_uiMapLocal get "_airCounter") ctrlSetText format ["Air Kills: %1", _scores select 3];
            (_uiMapLocal get "_deathCounter") ctrlSetText format ["Deaths: %1", _scores select 4];
            (_uiMapLocal get "_totalScoreCtrl") ctrlSetText format ["Total Kills: %1", _scores select 5];
        } else {
            diag_log "HUD: ERROR - Score data unavailable!";
        };

        // **Update Top 3 Player Leaderboard**
        private _players = allPlayers select {isPlayer _x};
        private _scoresList = [];

        {
            private _scoreData = getPlayerScores _x;
            if (count _scoreData >= 6) then {
                private _totalScore = _scoreData select 5;
                private _maxDistance = round (_x getVariable ["MaxKillDistance", 0]);

                // **Retrieve Ammo Used & Hits for each player**
                private _ammoKey = format ["ammoUsed_%1", getPlayerUID _x]; 
                private _hitsKey = format ["totalHits_%1", getPlayerUID _x]; 

                private _ammoUsed = _x getVariable [_ammoKey, 0]; // Default to 0
                private _totalHits = _x getVariable [_hitsKey, 0]; // Default to 0

                // **Calculate Hit Ratio Safely (Avoid Division by Zero)**
                private _hitRatio = if (_ammoUsed > 0) then {
                    (_totalHits / _ammoUsed) * 100
                } else {
                    0
                };

                // **Store all relevant data**
                _scoresList pushBack [_x, _totalScore, _maxDistance, _ammoUsed, _totalHits, round _hitRatio];
            };
        } forEach _players;

        _scoresList sort false;

        // **Initialize Top 3 Leaderboard Entries**
        private _top1 = "1st: -";
        private _top2 = "2nd: -";
        private _top3 = "3rd: -";

        private _top1_2 = "Ammo: -, Hits: -, Acc: -";
        private _top2_2 = "Ammo: -, Hits: -, Acc: -";
        private _top3_2 = "Ammo: -, Hits: -, Acc: -";

        if (count _scoresList > 0) then { 
            _top1 = format ["1st: %1 - %2 | %3m", 
                name (_scoresList select 0 select 0), _scoresList select 0 select 1, _scoresList select 0 select 2]; 
            _top1_2 = format ["Amo: %1 | Hit: %2 | Acc: %3%%",
                _scoresList select 0 select 3, _scoresList select 0 select 4, _scoresList select 0 select 5];
        };
        if (count _scoresList > 1) then { 
            _top2 = format ["2nd: %1 - %2 | %3m",  
                name (_scoresList select 1 select 0), _scoresList select 1 select 1, _scoresList select 1 select 2]; 
            _top2_2 = format ["Amo: %1 | Hit: %2 | Acc: %3%%",
                _scoresList select 1 select 3, _scoresList select 1 select 4, _scoresList select 1 select 5];
        };
        if (count _scoresList > 2) then { 
            _top3 = format ["3rd: %1 - %2 | %3m",  
                name (_scoresList select 2 select 0), _scoresList select 2 select 1, _scoresList select 2 select 2]; 
            _top3_2 = format ["Amo: %1 | Hit: %2 | Acc: %3%%",
                _scoresList select 2 select 3, _scoresList select 2 select 4, _scoresList select 2 select 5];
        };

        (_uiMapLocal get "_top1") ctrlSetText _top1;
        (_uiMapLocal get "_top2") ctrlSetText _top2;
        (_uiMapLocal get "_top3") ctrlSetText _top3;

        (_uiMapLocal get "_top1_2") ctrlSetText _top1_2;
        (_uiMapLocal get "_top2_2") ctrlSetText _top2_2;
        (_uiMapLocal get "_top3_2") ctrlSetText _top3_2;

        //diag_log format ["Updated Leaderboard: %1 | %2 | %3", _top1, _top2, _top3];
        //diag_log format ["Updated Leaderboard Stats: %1 | %2 | %3", _top1_2, _top2_2, _top3_2];

        
        // **Update Ammo Used Counter**
        private _ammoKey = format ["ammoUsed_%1", getPlayerUID player]; // Ensure the unique variable
        private _ammoUsed = player getVariable [_ammoKey, 0]; // Ensure it returns 0 if undefined
        if (!isNull (_uiMapLocal get "_ammoCounter")) then {
            (_uiMapLocal get "_ammoCounter") ctrlSetText format ["Ammo Used: %1", _ammoUsed];
        } else {
            diag_log "HUD: ERROR - Ammo Used UI element not found!";
        };
        
        // **Update Total Hits Counter**
        private _hitsKey = format ["totalHits_%1", getPlayerUID player]; // Unique per-player key
        private _totalHits = player getVariable [_hitsKey, 0]; // Ensure it returns 0 if undefined
        if (!isNil "_totalHits" && { _totalHits isEqualType 0 }) then {
            if (!isNull (_uiMapLocal get "_hitCounter")) then {
                (_uiMapLocal get "_hitCounter") ctrlSetText format ["Total Hits: %1", _totalHits];
            } else {
                diag_log "HUD: ERROR - Hit Counter UI element not found!";
            };
        } else {
            diag_log format ["HUD: ERROR - Invalid totalHits value for %1 (Value: %2)", name player, _totalHits];
        };
        
        // **Retrieve Ammo Used & Total Hits**
        private _ammoKey = format ["ammoUsed_%1", getPlayerUID player]; 
        private _hitsKey = format ["totalHits_%1", getPlayerUID player]; 

        private _ammoUsed = player getVariable [_ammoKey, 0]; // Default to 0
        private _totalHits = player getVariable [_hitsKey, 0]; // Default to 0

        // **Calculate Hit Ratio Safely (Avoid Division by Zero)**
        private _hitRatio = if (_ammoUsed > 0) then {
            (_totalHits / _ammoUsed) * 100
        } else {
            0
        };

        // **Update Hit Ratio Counter in UI**
        if (!isNull (_uiMapLocal get "_ammoHitRatio")) then {
            (_uiMapLocal get "_ammoHitRatio") ctrlSetText format ["Hit Accuracy: %1%%", round _hitRatio];
        } else {
            diag_log "HUD: ERROR - Hit Ratio UI element not found!";
        };
        
        sleep 1;
    };
};
