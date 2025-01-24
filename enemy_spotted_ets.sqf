// Ensure this only runs on the server
if (isServer) then {
    private _updateInterval = 2;
    private _markerHeight = 2;
    private _markerObjects = createHashMap;
    private _showBehindCover = true;  // Set to true or false as needed

    while {true} do {
        diag_log "Starting marker check loop";  // Log when the loop starts

        {
            private _group = _x;
            {
                private _unit = _x;
                private _knownEnemies = _unit targets [true, 200]; // Detects enemies within 200m

                //diag_log format ["Server: Checking unit: %1", _unit];  // Log which unit is being checked

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

                                // Prepare the data as an array and send it to the client
                                private _data = [_enemy, _markerHeight, _canSee, _canSeeVariable];  // Package data
                                diag_log format ["Server: Sending data: %1", _data];  // Log the data before sending
                                [_data] remoteExec ["addMarkerEventHandler", 2];  // Send the data to the client
                                //[_enemy, _markerHeight, _canSee, _canSeeVariable] remoteExec ["addMarkerEventHandler", 2];
                                diag_log format ["Server: RemoteExec E: %1, MH: %2, CS: %3, CSV: %4", _enemy, _markerHeight, _canSee, _canSeeVariable]; // Log to check sanity RemoteExec
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
};
