// killTicker.sqf

// Array to store kill messages and their timestamps
_killMessages = [];

// Maximum number of messages to display at once
_maxMessages = 5;

// Time (in seconds) each message is displayed
_messageDuration = 10;

// Debugging Logs
diag_log "Kill Ticker script started.";

// Function to clean up expired messages
cleanKillMessages = {
    _killMessages = _killMessages select {
        time - (_x select 1) < _messageDuration
    };
};

// Function to display kill messages
displayKillMessages = {
    private _yOffset = 0.02; // Initial Y offset
    private _yStep = 0.03;   // Spacing between lines

    {
        private _message = _x select 0; // Extract the message text
        private _screenX = safeZoneX + 0.02; // Screen X position
        private _screenY = safeZoneY + _yOffset; // Calculate Y position

        // Debugging: Log message display
        diag_log format ["Displaying message: %1", _message];

        // Draw the message
        drawIcon3D [
            "",                      // No icon
            [1, 1, 1, 1],            // Text color (white)
            [_screenX, _screenY, 0], // Position (X, Y, Z)
            0, 0,                    // Icon size (irrelevant)
            0,                       // Direction (irrelevant)
            _message,                // Message text
            0,                       // Shadow (0 = none)
            0.03,                    // Text size
            "TahomaB"                // Font
        ];

        _yOffset = _yOffset + _yStep;
    } forEach _killMessages;
};

// Add an event handler to track kills
["EntityKilled", {
    params ["_killed", "_killer", "_instigator"];

    // Get weapon used (if applicable)
    private _weapon = if (!isNil "_instigator" && {_instigator isKindOf "Man"}) then {
        currentWeapon _instigator
    } else {
        "Unknown Weapon"
    };

    // Get names of killer and killed
    private _killerName = if (isNil "_killer") then {"Unknown"} else {name _killer};
    private _killedName = if (isNil "_killed") then {"Unknown"} else {name _killed};

    // Debugging: Log kill details
    diag_log format ["Kill Event: %1 killed %2 with %3", _killerName, _killedName, _weapon];

    // Add the message to the array
    _killMessages pushBack [format ["%1 killed %2 with %3", _killerName, _killedName, _weapon], time];

    // Limit the array to _maxMessages
    if (count _killMessages > _maxMessages) then {
        _killMessages deleteAt 0;
    };
}] call CBA_fnc_addEventHandler;

// Add a per-frame handler to clean up and display messages
[{
    call cleanKillMessages;
    call displayKillMessages;
}] call CBA_fnc_addPerFrameHandler;
