// Global Cleanup Script with Equipment Cleanup
// Set cleanup timers
private _corpseCleanupTime = 60; // 10 minutes for corpses (600)
private _equipmentCleanupTime = 60; // 10 minutes for equipment (600)
private _playerDistance = 500; // Distance in meters for equipment cleanup

// Variables
private _deadBodies = []; // Track dead bodies
private _cleanupTimesBodies = []; // Corresponding cleanup times for each body

private _droppedEquipment = []; // Track dropped equipment
private _cleanupTimesEquipment = []; // Corresponding cleanup times for each equipment

// Main loop
while {true} do {
    // Get all dead units
    private _allDeadBodies = allDeadMen select {!(alive _x)};
    
    // Update dead bodies list and their cleanup times
    {
        if (!(_x in _deadBodies)) then {
            _deadBodies pushBack _x;
            _cleanupTimesBodies pushBack (time + _corpseCleanupTime);
        };
    } forEach _allDeadBodies;

    // Cleanup expired corpses
    {
        private _index = _forEachIndex;
        private _body = _x;
        private _cleanupTime = _cleanupTimesBodies select _index;

        if (time >= _cleanupTime) then {
            deleteVehicle _body;
            _deadBodies deleteAt _index;
            _cleanupTimesBodies deleteAt _index;
        };
    } forEach _deadBodies;

    // Get all objects on the ground (weapons, magazines, etc.)
    private _allEquipment = nearestObjects [[0,0,0], ["WeaponHolderSimulated", "WeaponHolder", "GroundWeaponHolder", "Box_NATO_Ammo_F"], 50000];

    // Update equipment list and their cleanup times
    {
        if (!(_x in _droppedEquipment)) then {
            _droppedEquipment pushBack _x;
            _cleanupTimesEquipment pushBack (time + _equipmentCleanupTime);
        };
    } forEach _allEquipment;

    // Cleanup expired equipment
    {
        private _index = _forEachIndex;
        private _equipment = _x;
        private _cleanupTime = _cleanupTimesEquipment select _index;

        // Check if no players are within the specified distance
        private _playersNearby = allPlayers select {(_x distance _equipment) <= _playerDistance};
        if ((_playersNearby isEqualTo []) && (time >= _cleanupTime)) then {
            deleteVehicle _equipment;
            _droppedEquipment deleteAt _index;
            _cleanupTimesEquipment deleteAt _index;
        };
    } forEach _droppedEquipment;

    sleep 10; // Check every 10 seconds to reduce performance impact
};
