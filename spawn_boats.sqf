/*
    Script: Spawn Boats at Closest Valid Water Position
    Description:
    Spawns B_Boat_Transport_01_F at all markers named 'boatSpawn_x_y' and ensures they spawn above water.
    If a marker is not in deep enough water, it searches for the closest valid water position.
    Also hides markers from the map.
*/

private _boatMarkers = allMapMarkers select {(_x find "boatSpawn_") == 0};

if (count _boatMarkers == 0) then {
    diag_log "[ERROR] No valid boat spawn markers found!";
} else {
    {
        private _spawnPos = getMarkerPos _x;
        if (_spawnPos isEqualTo [0,0,0]) then {
            diag_log format ["[WARNING] Marker %1 has an invalid position!", _x];
        } else {
            private _waterDepth = getTerrainHeightASL _spawnPos - getTerrainHeight _spawnPos;
            
            // Find closest valid water position if the original is not deep enough
            if (_waterDepth <= 0) then {
                private _radius = 5;
                private _validSpawn = false;
                private _newSpawnPos = _spawnPos;
                
                for "_i" from 1 to 20 do { // Search up to 100m in steps of 5m
                    private _searchPositions = [_spawnPos, _radius, 10, 1, 0, 0.5, 0] call BIS_fnc_findSafePos;
                    if (_searchPositions isEqualType []) then {
                        private _testDepth = getTerrainHeightASL _searchPositions - getTerrainHeight _searchPositions;
                        if (_testDepth > 0) then {
                            _newSpawnPos = _searchPositions;
                            _validSpawn = true;
                            break;
                        };
                    };
                    _radius = _radius + 5;
                };
                
                if (!_validSpawn) then {
                    diag_log format ["[WARNING] No valid water position found near marker %1. Skipping!", _x];
                    continue;
                } else {
                    diag_log format ["[INFO] Adjusted spawn position for marker %1 to nearest valid water at %2", _x, _newSpawnPos];
                };
                _spawnPos = _newSpawnPos;
            };
            
            private _boat = createVehicle ["B_Boat_Transport_01_F", _spawnPos, [], 0, "NONE"];
            _boat setDir (markerDir _x); // Align with marker direction if applicable
        };
        _x setMarkerAlpha 0; // Hide the marker from the map
    } forEach _boatMarkers;

    diag_log format ["Spawned %1 boats at designated locations.", count _boatMarkers];
}
