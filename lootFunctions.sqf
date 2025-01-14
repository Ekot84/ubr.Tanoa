// Spawn loot in a house based on building positions
spawnLootInHouse = {
    params ["_house", "_lootPool"];

    // Check if loot is already spawned
    if (!(_house getVariable ["lootSpawned", false])) then {
        _house setVariable ["lootSpawned", true];

        // Get all building positions for the house
        private _buildingPositions = [];
        private _index = 0;
        private _maxPositions = 50; // Safeguard for maximum positions

    while {_index < _maxPositions} do {
    private _pos = _house buildingPos _index;

    // Exit the loop when no more valid positions are found
    if (isNil "_pos") exitWith {};

    // Add position to the array
    _buildingPositions pushBack _pos;
    _index = _index + 1;
};

// Debugging: Log the number of positions found
diag_log format ["[Loot System] Found %1 positions in house %2.", count _buildingPositions, _house];

        // Limit loot spawn to 1-2 items per house
        private _lootToSpawn = [1, 2] call BIS_fnc_selectRandom;

        for "_i" from 1 to _lootToSpawn do {
            // Ensure there are positions left
            if (count _buildingPositions == 0) exitWith {};

            // Randomly select a position
            private _lootPos = selectRandom _buildingPositions;
            _buildingPositions = _buildingPositions - [_lootPos]; // Remove the position to avoid overlap

            // Randomly select a loot item
            private _lootItem = (selectRandom _lootPool) select 0;

            // Adjust loot position slightly above ground
            private _adjustedLootPos = [
                _lootPos select 0, 
                _lootPos select 1, 
                (_lootPos select 2) + 0.1
            ];

            // Spawn the loot
            private _loot = createVehicle [_lootItem, _adjustedLootPos, [], 0, "CAN_COLLIDE"];
            _loot setVariable ["parentHouse", _house]; // Link loot to the house

            // Log for debugging
            diag_log format ["[Loot Spawn] Spawned %1 at %2 in house %3", _lootItem, _adjustedLootPos, _house];
        };
    };
};


// Despawn loot from a house
despawnLootInHouse = {
    params ["_house"];

    // Check if loot exists in the house
    if (_house getVariable ["lootSpawned", false]) then {
        private _currentLoot = _house getVariable ["currentLoot", []];

        // Delete all loot items
        {
            deleteVehicle _x;
        } forEach _currentLoot;

        // Reset variables
        _house setVariable ["currentLoot", []];
        _house setVariable ["lootSpawned", false];
        diag_log format ["[Loot Despawn] Loot despawned in house %1.", _house];
    };
};

