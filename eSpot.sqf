// Ensure this only runs on the server
if (!isServer) exitWith {}; 

// Initialize variables
private _updateInterval = 2; 
private _markerHeight = 2;
private _markerObjects = createHashMap;
private _showBehindCover = true;  // Set to true or false as needed

// Add event handler for Draw3D only when necessary
private _drawEvH = nil;
addDrawEventHandler = {
    if (isNil "_drawEvH") then {
        _drawEvH = addMissionEventHandler ["Draw3D", {
            private _enemy = _this select 0; // Enemy unit
            private _height = 2; // Default height above enemy's head
            private _canSee = 1; // Placeholder for visibility logic
            private _canSeeVariable = 1; // Placeholder for unit visibility

            // Call custom marker drawing function
            [_enemy, _height, _canSee, _canSeeVariable] call drawCustomMarker;
        }];
        diag_log "[DEBUG] Client: Draw3D event handler added";
    };
};

// Remove the Draw3D event handler when no longer needed
removeDrawEventHandler = {
    if (!isNil "_drawEvH") then {
        removeMissionEventHandler ["Draw3D", _drawEvH];
        diag_log "[DEBUG] Client: Draw3D event handler removed";
    };
};

// Custom function to draw the marker
drawCustomMarker = {
    private _enemy = _this select 0;  // Enemy unit
    private _height = _this select 1; // Height above the enemy's head
    private _canSee = _this select 2;  // Player visibility to the enemy
    private _canSeeVariable = _this select 3;  // Unit visibility to the enemy

    diag_log format ["[DEBUG] Client: Creating marker for enemy: %1", _enemy];
    diag_log format ["[DEBUG] Client: _height: %1, _canSee: %2, _canSeeVariable: %3", _height, _canSee, _canSeeVariable];

    // Define the icon and color
    private _icon = "\A3\ui_f\data\map\markers\military\warning_CA.paa"; // Path to icon
    private _color = [1, 0, 0, 1]; // Red color (fully red, fully opaque)

    // Get the position of the enemy using getPosASLVisual for accurate rendering
    private _enemyPos = _enemy getPosASLVisual;

    // Ensure the target position is valid
    if (typeName _enemyPos != "ARRAY" || count _enemyPos != 3) then {
        diag_log "[DEBUG] Client: _enemyPos is not a valid 3D position!";
        _enemyPos = [0, 0, 2];  // Default to a position 2 meters above the player
    };

    // Add _height to the Z coordinate (height above enemy's head)
    private _targetPos = _enemyPos vectorAdd [0, 0, _height];

    // Get the distance between the player and the enemy to adjust icon size
    private _distance = player distance _enemy;
    private _iconSizeW = 10; // Increased icon width for testing
    private _iconSizeH = 10; // Increased icon height for testing

    // Ensure icon size values are valid
    if (typeName _iconSizeW != "SCALAR" || typeName _iconSizeH != "SCALAR") then {
        _iconSizeW = 10;  // Default size if invalid
        _iconSizeH = 10;  // Default size if invalid
    };

    // Log the rotation direction
    private _direction = getDirVisual player;

    // Draw the icon above the enemy's head directly
    diag_log "[DEBUG] Client: Drawing icon directly...";  // Log to ensure the icon is being drawn
    drawIcon3D
    [
        _icon,         // Icon path (string)
        _color,        // RGBA color (array of 4 numbers)
        _targetPos,    // Icon position (3D position array)
        _iconSizeW,    // Icon width (scalar)
        _iconSizeH,    // Icon height (scalar)
        _direction     // Direction for rotation (scalar)
    ];
};

// The main loop running on the server
while {true} do {
    diag_log "Starting marker check loop";  // Log when the loop starts

    {
        private _group = _x;
        {
            private _unit = _x;
            private _knownEnemies = _unit targets [true, 200]; // Detects enemies within 200m

            diag_log format ["Server: Checking unit: %1", _unit];  // Log which unit is being checked

            {
                private _enemy = _x;
                private _markerName = format ["Custom_Marker_%1", _enemy]; // Unique marker name

                // Using knowsAbout to determine awareness level
                private _awareness = _unit knowsAbout _enemy;

                diag_log format ["Checking enemy: %1, Awareness: %2", _enemy, _awareness];  // Log awareness level

                // Check if the enemy is known with some awareness (e.g., over 0.5)
                if (_awareness > 0.5) then {
                    diag_log format ["Enemy known: %1", _enemy];  // Log when an enemy is known

                    // Check if the player can see the enemy
                    private _canSee = [player, "VIEW", _enemy] checkVisibility [eyePos player, eyePos _enemy];
                    private _canSeeVariable = [_unit, "VIEW", _enemy] checkVisibility [eyePos _unit, eyePos _enemy];

                    diag_log format ["Server: Can see player: %1, Can see unit: %2", _canSee, _canSeeVariable];  // Log visibility checks
                    
                    private _return = false;

                    // If _showBehindCover is true, the marker is shown
                    if (_showBehindCover) then {
                        _return = true;
                    };

                    // If _showBehindCover is false, only show if player can see or unit can see
                    if (!_showBehindCover && ((_canSee > 0) || (_canSeeVariable > 0))) then {
                        _return = true;
                    };

                    if (_return) then {
                        // Ensure marker is created only once for each enemy
                        if (isNil {_markerObjects get _markerName}) then {
                            diag_log format ["Server: Creating marker for enemy: %1", _enemy];  // Log when marker is created
                            // Pass necessary data to the client for icon drawing
                            [_enemy, _markerHeight, _showBehindCover, _canSee, _canSeeVariable] remoteExec ["createMarkerAboveEnemy", 2];  // Send to all clients
                        };
                    } else {
                        // Remove marker if enemy is behind cover
                        if (!isNil {_markerObjects get _markerName}) then {
                            diag_log format ["Removing marker for enemy: %1", _enemy];  // Log when marker is removed
                            private _markerObj = _markerObjects get _markerName;
                            [_markerObj] remoteExec ["deleteVehicle", 0, true];
                            _markerObjects deleteAt _markerName;
                        };
                    };
                };
            } forEach _knownEnemies;
        } forEach units _group;
    } forEach allGroups;

    sleep _updateInterval;
    diag_log "End of marker check loop";  // Log when the loop ends
};
