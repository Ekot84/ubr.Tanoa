// Custom function to draw the marker above the enemy
if (!hasInterface) exitWith {}; // Ensure this runs only on the client

waitUntil { !isNull player && { alive player } };
diag_log format ["EKO Clientzx functions.sqf read"];

// Function that is triggered to add the Draw3D event handler for each marker
addMarkerEventHandler = {
    private _data = _this select 0;  // Extract the data passed from the server
    
    diag_log format ["[DEBUG] Client: Data received: %1", _data]; // Log received data

    // Check if the data is valid and non-empty
    if (typeName _data == "ARRAY" && count _data == 4) then {
        private _enemy = _data select 0;
        private _height = _data select 1;
        private _canSee = _data select 2;  // This won't be used for now
        private _canSeeVariable = _data select 3;  // This won't be used for now

        // Check if the data is valid and not empty
        if (alive _enemy && typeName _height == "SCALAR") then {
            diag_log format ["[DEBUG] Client: Received enemy: %1, height: %2", _enemy, _height];

            // Directly add the Draw3D event handler and draw the marker without the canSee checks
            addMissionEventHandler ["Draw3D", {
                diag_log "[DEBUG] Client: Drawing icon in event handler";

                // Check if the enemy is valid and alive before trying to get its position
                if (alive _enemy) then {
                    diag_log format ["[DEBUG] Client: Enemy is alive: %1", _enemy];  // Log the enemy

                    // Check if _enemy is a valid object (unit, vehicle, etc.)
                    if (typeName _enemy != "OBJECT") then {
                        diag_log "[DEBUG] Client: Invalid enemy object, skipping marker drawing.";
                    } else {
                        // Get the position of the enemy using getPosASLVisual for accurate rendering
                        private _enemyPos = _enemy getPosASLVisual;

                        // Ensure _enemyPos is valid (an array with 3 coordinates)
                        if (typeName _enemyPos == "ARRAY" && count _enemyPos == 3) then {
                            diag_log format ["[DEBUG] Client: Enemy position: %1", _enemyPos];  // Log the position

                            // Add _height to the Z coordinate (height above enemy's head)
                            private _targetPos = _enemyPos vectorAdd [0, 0, _height];
                            diag_log format ["[DEBUG] Client: Target position with height: %1", _targetPos];  // Log target position

                            // Get the distance between the player and the enemy to adjust icon size
                            private _distance = player distance _enemy;
                            private _iconSizeW = 10; // Increased icon width for testing
                            private _iconSizeH = 10; // Increased icon height for testing
                            diag_log "[DEBUG] Client: Drawing icon directly...";  // Log to ensure the icon is being drawn
                            drawIcon3D
                            [
                                "\A3\ui_f\data\map\markers\military\warning_CA.paa", // Icon path
                                [1, 0, 0, 1], // Color (red, opaque)
                                _targetPos,    // Icon position (3D position array)
                                _iconSizeW,    // Icon width (scalar)
                                _iconSizeH,    // Icon height (scalar)
                                getDirVisual player  // Direction for rotation (scalar)
                            ];
                        } else {
                            diag_log "[DEBUG] Client: Invalid position data for enemy."; // Log if position is invalid
                        };
                    };
                } else {
                    diag_log "[DEBUG] Client: Enemy not alive, skipping marker."; // Log if the enemy is not alive
                };
            }];
            diag_log "[DEBUG] Client: Draw3D event handler added"; // Confirm handler was added
        } else {
            diag_log "[DEBUG] Client: Invalid data received, skipping marker drawing."; // Log invalid data
        };
    };  // This closes the if check for _data being valid
};  // This closes the addMarkerEventHandler function
