// showKillfeed.sqf
// Displays a killfeed message on the screen for all players using structured text and parseText

// Retrieve parameters from the missionNamespace
private _message = missionNamespace getVariable ["showKillfeed_message", "Unknown"];
private _killer = missionNamespace getVariable ["showKillfeed_killer", objNull];
private _victim = missionNamespace getVariable ["showKillfeed_victim", objNull];

// Use the parameters for your logic
diag_log format ["[Killfeed] %1 was killed by %2", name _victim, name _killer];

// Determine side-based colors (unchanged logic follows)
private _getSideColor = {
    params ["_unit"];
    switch (side _unit) do {
        case west: { "#007BFF" };   // BLUFOR (Blue)
        case east: { "#FF0000" };   // OPFOR (Red)
        case resistance: { "#00FF00" };  // INDEPENDENT (Green)
        case civilian: { "#FFFF00" };  // CIVILIAN (Yellow)
        default { "#FFFFFF" };      // Default (White)
    };
};

private _killerColor = if (!isNull _killer) then { [_killer] call _getSideColor } else { "#FFFFFF" };
private _victimColor = if (!isNull _victim) then { [_victim] call _getSideColor } else { "#FFFFFF" };

// Format the message
private _formattedMessage = if (!isNull _killer) then {
    format ["<t color='%1'>%2</t> was killed by <t color='%3'>%4</t>", _victimColor, name _victim, _killerColor, name _killer]
} else {
    format ["<t color='%1'>%2</t> died.", _victimColor, name _victim]
};

// Display the killfeed message (existing code for UI updates remains unchanged)
