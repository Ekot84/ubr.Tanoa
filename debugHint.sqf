if (hasInterface) then {
    [] spawn {
        while {true} do {
            private _scores = getPlayerScores player;

            if (typeName _scores == "ARRAY" && {count _scores >= 5}) then {
                // Trim to only use the first 5 elements (ignore total score)
                _scores resize 5;

                private _msg = format [
                    "🔹 Scoreboard 🔹\nInfantry Kills: %1\nSoft Vehicle Kills: %2\nArmor Kills: %3\nAir Kills: %4\nDeaths: %5",
                    _scores select 0,  // Kills Infantry
                    _scores select 1,  // Kills Soft Vehicles
                    _scores select 2,  // Kills Armor
                    _scores select 3,  // Kills Air
                    _scores select 4   // Deaths
                ];
                hintSilent _msg;
            } else {
                hintSilent "⚠️ Score data unavailable!";
                diag_log format ["[DEBUG] Score data unavailable! getPlayerScores returned: %1", _scores];
            };

            sleep 5;  // Update every 5 seconds
        };
    };
};
