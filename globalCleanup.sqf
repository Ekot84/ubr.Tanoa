// Global Cleanup Script
// Set cleanup timer
private _cleanupTime = 600; // 10 minutes in seconds

// Variables
private _deadBodies = []; // Track dead bodies
private _cleanupTimes = []; // Corresponding cleanup times for each body

// Main loop
while {true} do {
    // Get all dead units
    private _allDeadBodies = allDeadMen select {!(alive _x)};
    
    // Update dead bodies list and their cleanup times
    {
        if (!(_x in _deadBodies)) then {
            _deadBodies pushBack _x;
            _cleanupTimes pushBack (time + _cleanupTime);
        };
    } forEach _allDeadBodies;

    // Cleanup expired corpses
    {
        private _index = _forEachIndex;
        private _body = _x;
        private _cleanupTime = _cleanupTimes select _index;

        if (time >= _cleanupTime) then {
            deleteVehicle _body;
            _deadBodies deleteAt _index;
            _cleanupTimes deleteAt _index;
        };
    } forEach _deadBodies;

    sleep 10; // Check every 10 seconds to reduce performance impact
};
