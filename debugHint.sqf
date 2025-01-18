if (hasInterface) then {
    [] spawn {
        while {true} do {
            private _scores = getPlayerScores player;

            if (typeName _scores == "ARRAY") then {
                private _count = count _scores;
                
                // Debug log to see how many elements are in _scores
                diag_log format ["[DEBUG] getPlayerScores returned: %1 (Length: %2)", _scores, _count];

                // Ensure there are at least 6 elements before accessing index 5
                if (_count >= 6) then {
                    private _msg = format [
                        "🔹 Scoreboard 🔹\nInfantry Kills: %1\nSoft Vehicle Kills: %2\nArmor Kills: %3\nAir Kills: %4\nDeaths: %5\nTotal Score: %6",
                        _scores select 0,  // Kills Infantry
                        _scores select 1,  // Kills Soft Vehicles
                        _scores select 2,  // Kills Armor
                        _scores select 3,  // Kills Air
                        _scores select 4,  // Deaths
                        _scores select 5   // Total Score
                    ];
                    hintSilent _msg;
                } else {
                    hintSilent format ["⚠️ Score data incomplete! Only %1 values found.", _count];
                    diag_log format ["[WARNING] Score array does not have enough elements! Found: %1", _scores];
                };
            } else {
                hintSilent "⚠️ Score data unavailable!";
                diag_log format ["[ERROR] Invalid score data type! getPlayerScores returned: %1", _scores];
            };

            sleep 5;  // Update every 5 seconds
        };
    };
};

