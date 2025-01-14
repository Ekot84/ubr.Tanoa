[] spawn {
    while {true} do {
        // Get the player's position
        private _playerPos = getPos player;

        // Find the nearest terrain object
        private _nearestObject = nearestTerrainObjects [_playerPos, [], 100]; // Empty array means all object types

        // Get object details if any are found
        if (count _nearestObject > 0) then {
            private _object = _nearestObject select 0; // Closest object
            private _objectType = typeOf _object; // Class name (e.g., Land_House_Small_02_F)
            
            // Get the model path using getModelInfo
            private _modelInfo = getModelInfo _object;
            private _objectModel = if (!isNil "_modelInfo") then { _modelInfo select 0 } else { "Unknown Model" }; // Get the .p3d path

            // Get object type description (if available)
            private _objectTypeName = getText (configFile >> "CfgVehicles" >> _objectType >> "destrType");

            // Get nearest location name
            private _nearestLocation = nearestLocations [_playerPos, ["NameCity", "NameVillage", "NameLocal"], 1000];
            private _locationName = if (count _nearestLocation > 0) then { text (_nearestLocation select 0) } else { "Unknown Area" };

            // Show hint with newlines
            hintSilent format [
                "Closest Object:\nType: %1\nType Name: %2\nModel: %3\n\nClosest Location:\n%4",
                _objectType,
                _objectTypeName,
                _objectModel,
                _locationName
            ];
        } else {
            // Show fallback hint if no object is nearby
            hintSilent "No objects nearby.";
        };

        // Wait for 30 seconds
        sleep 30;
    };
};
