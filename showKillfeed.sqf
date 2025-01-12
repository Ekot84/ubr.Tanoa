// showKillfeed.sqf
// Displays a killfeed message on the screen for all players using structured text and parseText

params [
    "_message",            // Message to display
    ["_killer", objNull],  // Killer (optional, defaults to null)
    ["_victim", objNull]   // Victim (optional, defaults to null)
];

// Define a unique ID for the killfeed display
private _feedCtrlID = 9001;

// Determine side-based colors
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

// Get colors for killer and victim
private _killerColor = if (!isNull _killer) then { [_killer] call _getSideColor } else { "#FFFFFF" };
private _victimColor = if (!isNull _victim) then { [_victim] call _getSideColor } else { "#FFFFFF" };

// Format the message with colored names
private _formattedMessage = if (!isNull _killer) then {
    format ["<t color='%1'>%2</t> was killed by <t color='%3'>%4</t>", _victimColor, name _victim, _killerColor, name _killer]
} else {
    format ["<t color='%1'>%2</t> died.", _victimColor, name _victim]
};

// Find the main display (ID 46 is the main UI)
private _display = findDisplay 46;

// Check if the killfeed control already exists
private _ctrl = _display displayCtrl _feedCtrlID;
if (isNull _ctrl) then {
    // Create a new RscStructuredText control for better text formatting
    _ctrl = _display ctrlCreate ["RscStructuredText", _feedCtrlID];
    
    // Position the killfeed at the top-left corner
    _ctrl ctrlSetPosition [0.01, 0.01, 0.4, 0.2];
    _ctrl ctrlSetBackgroundColor [0, 0, 0, 0.3];  // Semi-transparent background
    _ctrl ctrlCommit 0;  // Apply changes
};

// Get the current text and ensure it's a string
private _currentText = ctrlText _ctrl;
if (typeName _currentText != "STRING") then {
    _currentText = "";  // Reset to empty string if it's not a valid string
};

// Parse the message for structured text
private _parsedMessage = parseText _formattedMessage;

// Convert the parsed text to a string
private _parsedMessageString = toString _parsedMessage;

// Append the parsed message to the feed
private _newText = _parsedMessageString + "\n" + _currentText;
_ctrl ctrlSetText _newText;

// Optional: Limit the number of messages shown (e.g., last 10)
private _messages = _newText splitString "\n";  // Split the text into lines
private _maxMessages = 10;  // Limit to last 10 messages
if (count _messages > _maxMessages) then {
    _messages resize _maxMessages;
    _ctrl ctrlSetText (toString _messages joinString "\n");  // Rejoin limited messages
};
