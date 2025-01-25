// **Predefined valid hit parts based on `getAllHitPointsDamage` output**
private _validHitParts = [
    "hitface", "hitneck", "hithead", "hitpelvis", "hitabdomen", "hitdiaphragm",
    "hitchest", "hitbody", "hitarms", "hithands", "hitlegs", "incapacitated",
    "face_hub", "neck", "head", "pelvis", "spine1", "spine2", "spine3", 
    "body", "arms", "hand_l", "hand_r", "leg_l", "leg_r"
];

// **Function to Attach "HandleDamage" to AI When They Spawn**
fnc_attachDamageTracker = {
    params ["_unit"];

    diag_log format ["[DEBUG] fnc_attachDamageTracker CALLED for: %1", name _unit];

    if (!local _unit) exitWith {
        diag_log format ["[HitTracking] SKIPPED: %1 (not local)", name _unit];
    };

    if (_unit getVariable ["hasDamageTrackingEH", false]) exitWith {
        diag_log format ["[HitTracking] ALREADY HAS EVENT: %1", name _unit];
    };

    _unit addEventHandler ["HandleDamage", {
        params ["_unit", "_hitPart", "_damage", "_shooter", "_projectile"];

        diag_log format ["[HitTracking] EVENT FIRED: %1 hit %2 on AI: %3 with %4", name _shooter, _hitPart, name _unit, _projectile];

        if (_hitPart == "" || isNil "_hitPart") exitWith {
            diag_log format ["[HitTracking] WARNING: Ignored empty hit part on AI: %1", name _unit];
            _damage;
        };

        if (_unit isEqualTo _shooter) exitWith { _damage; };
        if (isNil "_projectile" || {_projectile isEqualTo ""}) exitWith { _damage; };
        if (isNull _shooter || !isPlayer _shooter) exitWith { _damage; };

        // **Ensure `_hitData` is initialized**
        private _hitData = _shooter getVariable ["hitStats", createHashMap];

        // **Use Player UID to store totalHits globally**
        private _hitsKey = format ["totalHits_%1", getPlayerUID _shooter];
        private _currentTotalHits = _shooter getVariable [_hitsKey, 0]; // **Ensure Default Value is 0**

        // **Validate `totalHits` before updating**
        if (isNil "_currentTotalHits" || {!(_currentTotalHits isEqualType 0)}) then {
            diag_log format ["[HitTracking] WARNING: totalHits was invalid for %1 (Resetting)", name _shooter];
            _currentTotalHits = 0;
        };

        // **Ensure `totalHits` is a number and not `NaN`**
        if (_currentTotalHits != _currentTotalHits) then {
            diag_log format ["[HitTracking] WARNING: totalHits was NaN! Resetting for %1", name _shooter];
            _currentTotalHits = 0;
        };

        // **Track unique bullets**
        private _lastBulletTime = _shooter getVariable ["lastBulletTime", -1];
        private _currentTime = diag_tickTime;

        if ((_currentTime - _lastBulletTime) > 0.05) then {
            _shooter setVariable ["lastBulletTime", _currentTime, false];

            // **Increment `totalHits` and store globally**
            _currentTotalHits = _currentTotalHits + 1;
            _shooter setVariable [_hitsKey, _currentTotalHits, true];

            diag_log format ["[HitTracking] UPDATED TOTAL HITS: %1 now has %2 total hits!", name _shooter, _currentTotalHits];
        };

        // **Track each unique hit part separately**
        _hitData set [_hitPart, (_hitData getOrDefault [_hitPart, 0]) + 1];

        _shooter setVariable ["hitStats", _hitData, true];

        diag_log format ["[HitTracking] CONFIRMED: %1 hit %2 on AI: %3. Total Hits: %4", name _shooter, _hitPart, name _unit, _shooter getVariable [_hitsKey, 0]]; // **Fixed getVariable Call**

        _damage;
    }];

    _unit setVariable ["hasDamageTrackingEH", true, true];

    diag_log format ["[HitTracking] HandleDamage event handler added for AI: %1", name _unit];
};


// **Loop to continuously attach event handlers to new AI**
if (hasInterface) then {
    [] spawn {
        while {true} do {
            {
                if (!(_x getVariable ["hasDamageTrackingEH", false])) then {
                    [_x] call fnc_attachDamageTracker;
                };
            } forEach (allUnits select { side _x == east && alive _x });

            sleep 5;  // Check every 5 seconds for new AI
        };
    };
};

// **CLEANUP PROJECTILE TRACKING**
[] spawn {
    while {true} do {
        {
            private _projectileHits = _x getVariable ["trackedProjectiles", createHashMap];
            _x setVariable ["trackedProjectiles", createHashMap, false]; // Reset tracked bullets
        } forEach allPlayers;
        sleep 2; // Clears bullet tracking every 2 seconds
    };
};
