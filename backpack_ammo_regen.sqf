//[_this] execVM "backpack_ammo_regen.sqf";

_unit = _this select 0;
_interval = 10; // Check interval in seconds

if (isNull _unit || isNull (unitBackpack _unit)) exitWith {};

// Store the initial backpack contents (magazines only)
private _originalMags = [];
{
    if (_x in magazines _unit) then { // Filter out non-magazine items
        _originalMags pushBackUnique [_x, {_y == _x} count (magazines _unit)];
    };
} forEach backpackItems _unit;

// Debug: Uncomment to see stored items
// systemChat format ["Stored Backpack Contents: %1", _originalMags];

while {alive _unit} do {
    if (isNull (unitBackpack _unit)) exitWith {}; // Stop if no backpack

    {
        _magClass = _x select 0;
        _maxCount = _x select 1;
        _currentCount = {_y == _magClass} count (magazines _unit);
        
        if (_currentCount < _maxCount) then {
            _needed = _maxCount - _currentCount;
            for "_i" from 1 to _needed do {
                _unit addItemToBackpack _magClass;
            };
        };
    } forEach _originalMags;

    sleep _interval;
};
