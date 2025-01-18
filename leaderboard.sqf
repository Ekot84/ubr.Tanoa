diag_log "LDRBRD: Waiting for player to initialize...";

// Wait for the player to fully load
waitUntil { !isNull player && { alive player } };
diag_log "LDRBRD: Player initialized.";

// Display the Leaderboard UI within the Health Bar HUD
["RscDisplayHUD", "PLAIN", 1] call BIS_fnc_rscLayer;

sleep 0.5; // Give UI time to load

// Check if the HUD layer exists
private _layers = allCutLayers;
if (!("RscDisplayHUD" in _layers)) then {
    diag_log "LDRBRD: ERROR - HUD UI layer does not exist!";
};

// Get the UI display and verify it's loaded
private _display = uiNamespace getVariable ["RscDisplayHUD", displayNull];
private _leaderboardCtrl = objNull;
if (isNull _display) then {
    diag_log "LDRBRD: ERROR - HUD UI display not found!";
} else {
    diag_log "LDRBRD: HUD UI display loaded successfully!";
    _leaderboardCtrl = _display displayCtrl 1004;
};

[] spawn {
    while {true} do {
        diag_log "LDRBRD: Updating leaderboard...";

        private _players = allPlayers select {isPlayer _x};
        private _scores = [];

        diag_log format ["LDRBRD: Found %1 players", count _players];

        {
            private _scoreData = getPlayerScores _x;
            private _kills = 0;
            private _deaths = 0;
            private _score = 0;

            if (count _scoreData == 3) then {
                _kills = _scoreData select 0;
                _deaths = _scoreData select 1;
                _score = _scoreData select 2;
            };

            diag_log format ["LDRBRD: %1 - Kills: %2, Deaths: %3, Score: %4", name _x, _kills, _deaths, _score];

            _scores pushBack [_x, _kills, _deaths, _score];

            private _rewardedKills = _x getVariable ["RewardedKills", 0];

            if (_kills >= 10 && _rewardedKills < 10) then {
                _x addItem "Medikit";
                _x addWeapon "hgun_P07_F";
                _x setVariable ["RewardedKills", _kills, true];

                diag_log format ["LDRBRD: %1 received reward for 10+ kills", name _x];
            };
        } forEach _players;

        _scores sort false;

        private _leaderboard = "<t size='1.2' color='#FFD700'>🏆 LEADERBOARD 🏆</t><br/><br/>";
        {
            private _playerName = name (_x select 0);
            private _playerKills = _x select 1;
            private _playerDeaths = _x select 2;
            private _playerScore = _x select 3;
            _leaderboard = _leaderboard + format[
                "<t size='1'>%1 | Kills: %2 | Deaths: %3 | Score: %4</t><br/>",
                _playerName, _playerKills, _playerDeaths, _playerScore
            ];
        } forEach (_scores select [0, (count _scores) min 10]); // Show top 10 players

        // 🎯 Update LeaderboardText within the HUD and adjust SafeZone positioning
        _display = uiNamespace getVariable ["RscDisplayHUD", displayNull];
        if (!isNull _display) then {
            private _leaderboardCtrl = _display displayCtrl 1004;
            if (!isNull _leaderboardCtrl) then {
                _leaderboardCtrl ctrlSetStructuredText parseText _leaderboard;
                _leaderboardCtrl ctrlSetPosition [safeZoneX + 0.05, safeZoneY + (safeZoneH / 2), 0.3, 0.6];
                _leaderboardCtrl ctrlCommit 0;
                diag_log "LDRBRD: Leaderboard UI updated successfully!";
            } else {
                diag_log "LDRBRD: ERROR - LeaderboardText control not found!";
            };
        } else {
            diag_log "LDRBRD: ERROR - HUD display not found!";
        };

        sleep 10;
    };
};
