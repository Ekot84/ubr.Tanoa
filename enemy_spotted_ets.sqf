if (!isServer) exitWith {}; // Ensure this only runs on the server

private _updateInterval = 2; // Update interval
private _markerHeight = 2; // Height above enemy's head
private _markerObjects = createHashMap; // Stores active markers (can be optional if using client-side only tracking)

while {true} do {
    {
        private _group = _x;
        {
            private _unit = _x;
            private _knownEnemies = _unit targets [true, 200]; // Detects enemies within 200m

            {
                private _enemy = _x;
                private _markerName = format ["ETS_Marker_%1", _enemy];

                // Using knowsAbout to determine awareness level
                private _awareness = _unit knowsAbout _enemy;

                // Check if the enemy is known with some awareness (e.g., over 0.5)
                if (_awareness > 0.5) then {
                    // Ensure marker is created only once for each enemy
                    if (isNil {_markerObjects get _markerName}) then {
                        // Send the enemy and height to the client to create the marker
                        [_enemy, _markerHeight] remoteExec ["createMarkerAboveEnemy", 0, true];
                    };
                };
            } forEach _knownEnemies;
        } forEach units _group;
    } forEach allGroups;

    // Remove markers for enemies no longer spotted
    {
        private _markerName = _x;
        private _markerObj = _markerObjects get _markerName;
        private _enemyExists = false;

        {
            private _group = _x;
            {
                private _unit = _x;
                private _knownEnemies = _unit targets [true, 200];

                {
                    private _enemy = _x;  // Ensure _enemy is defined in the loop
                    if (_enemy in _knownEnemies) then {
                        _enemyExists = true;
                    };
                } forEach _knownEnemies;
            } forEach units _group;
        } forEach allGroups;

        if (!_enemyExists) then {
            // Remove the marker on all clients
            [_markerObj] remoteExec ["deleteVehicle", 0, true];
            _markerObjects deleteAt _markerName;
        };
    } forEach keys _markerObjects;

    sleep _updateInterval;
};

// Function to create the marker above the enemy
createMarkerAboveEnemy = {
    private _enemy = _this select 0;
    private _height = _this select 1;

    // Create the marker object above the enemy's head
    private _markerObj = createSimpleObject ["A3\Structures_F\Items\Sport\Football_01_F.p3d", [0, 0, 0]];

    // Attach marker above the enemy's head using the offset
    _markerObj attachTo [_enemy, [0, 0, _height]]; // Attach with offset
    _markerObj setObjectTextureGlobal [0, "#(argb,8,8,3)color(1,0,0,1)"]; // Set the texture

    // Store the marker object for later removal or checks (optional)
    private _markerName = format ["ETS_Marker_%1", _enemy];
    _markerObjects set [_markerName, _markerObj];
};
