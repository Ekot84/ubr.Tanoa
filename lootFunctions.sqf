// Spawn loot in a house based on building positions
spawnLootInHouse = {
    params ["_house", "_lootPool"];

    // Check if loot is already spawned
    if (!(_house getVariable ["lootSpawned", false])) then {
        _house setVariable ["lootSpawned", true];

        // Get all building positions for the house
        private _buildingPositions = [];
        private _index = 0;
        private _maxPositions = 50; // Assume no building has more than 50 positions

        while {_index < _maxPositions} do {
            private _pos = _house buildingPos _index;

            // Exit the loop if no position is found
            if (isNil "_pos") exitWith {};

            // Adjust position to prevent items from spawning underground
            private _adjustedPos = _pos;
            _adjustedPos set [2, (_pos select 2) + 0.1]; // Raise by 0.1 meters

            _buildingPositions pushBack _adjustedPos;
            _index = _index + 1;
        };

        // Fallback if no building positions are valid
        if (count _buildingPositions == 0) then {
            _buildingPositions pushBack (getPos _house);
        };

        // Randomly determine the number of loot items to spawn (1-2 per house)
        private _lootToSpawn = [1, 2] call BIS_fnc_selectRandom;

        for "_i" from 1 to _lootToSpawn do {
            // Ensure there are positions left
            if (count _buildingPositions == 0) exitWith {};

            // Randomly select a position
            private _lootPosition = selectRandom _buildingPositions;
            _buildingPositions = _buildingPositions - [_lootPosition]; // Remove the position to avoid overlap

            // Randomly select a loot item
            private _lootItem = (selectRandom _lootPool) select 0;

            // Spawn the loot
            private _loot = createVehicle [_lootItem, _lootPosition, [], 0, "CAN_COLLIDE"];

            // Validate and adjust position if loot spawns underground
            private _groundZ = getTerrainHeightASL [_lootPosition select 0, _lootPosition select 1];
            private _lootZ = _lootPosition select 2;

            if (_lootZ < _groundZ) then {
                _lootPosition set [2, _groundZ + 0.1]; // Adjust to just above ground level
                _loot setPos _lootPosition;
            };

            // Link loot to the house for cleanup later
            private _currentLoot = _house getVariable ["currentLoot", []];
            _house setVariable ["currentLoot", _currentLoot + [_loot]];
        };

        diag_log format ["[Loot Spawn] Loot spawned in house %1.", _house];
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

