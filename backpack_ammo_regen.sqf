private _unit = if (typeName _this == "OBJECT") then { _this } else { if (count _this > 0) then { _this select 0 } else { objNull }; };

// Configurable cooldown settings
private _cooldown = 150;  // How often to regenerate ammo (in seconds)

// Validate unit
if (isNull _unit) exitWith { 
    systemChat "ERROR: _unit is NULL!"; 
    diag_log "ERROR: _unit is NULL!"; 
};

// Debugging start message
systemChat format ["DEBUG: Ammo Regen Script started for %1", name _unit];
diag_log format ["DEBUG: Ammo Regen Script started for %1", name _unit];

// Validate backpack
private _backpack = unitBackpack _unit;
if (isNull _backpack) exitWith { 
    systemChat format ["ERROR: %1 has no backpack!", name _unit]; 
    diag_log format ["ERROR: %1 has no backpack!", name _unit]; 
};

// ✅ Store initial magazines in the backpack only
private _originalMags = [];
{
    private _magClass = _x;
    if (!(_magClass in _originalMags)) then {
        _originalMags pushBack _magClass;  // ✅ Store only magazine type (not count-based)
    };
} forEach backpackItems _unit;

systemChat format ["INFO: Stored Backpack Magazines for %1: %2", name _unit, _originalMags];
diag_log format ["INFO: Stored Backpack Magazines for %1: %2", name _unit, _originalMags];

// ✅ Start regeneration loop
while {alive _unit} do {
    // Check if unit still has a backpack
    private _currentBackpack = unitBackpack _unit;
    if (isNull _currentBackpack) exitWith {
        systemChat format ["INFO: %1 lost their backpack, stopping ammo regen.", name _unit];
        diag_log format ["INFO: %1 lost their backpack, stopping ammo regen.", name _unit];
    };

    {
        private _magClass = _x;
        private _currentCount = { _x == _magClass } count (backpackItems _unit); // ✅ Count only backpack magazines

        systemChat format ["DEBUG: Checking %1, currently has %2", _magClass, _currentCount];

        // ✅ Dynamically add missing magazines only if there's space
        if (_unit canAddItemToBackpack _magClass) then {
            _unit addItemToBackpack _magClass;
            systemChat format ["INFO: Added %1 to %2's backpack", _magClass, name _unit];
        } else {
            systemChat format ["WARNING: Backpack full! Cannot add %1 to %2", _magClass, name _unit];
        };
    } forEach _originalMags;

    sleep _cooldown;
};
