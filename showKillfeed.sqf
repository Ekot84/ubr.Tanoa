// showKillfeed.sqf
// Displays a killfeed message on the screen for all players using structured text and parseText

params [
    "_message",            // Message to display
    ["_killer", objNull],  // Killer (optional, defaults to null)
    ["_victim", objNull]   // Victim (optional, defaults to null)
];

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

// Reference the Killfeed control
private _ctrl = uiNamespace getVariable ["Killfeed", displayNull];
if (isNull _ctrl) exitWith {
    diag_log "[Killfeed] UI control not found.";
};

// Get the current text and ensure it's a string
private _currentText = ctrlText (_ctrl displayCtrl 9001);
if (typeName _currentText != "STRING") then {
    _currentText = "";  // Reset to empty string if it's not a valid string
};

// Append the new message to the feed
private _newText = _formattedMessage + "\n" + _currentText;

// Parse the combined messages for structured text
(_ctrl displayCtrl 9001) ctrlSetText parseText _newText;

// Optional: Limit the number of messages shown (e.g., last 10)
private _messages = _newText splitString "\n";  // Split the text into lines
private _maxMessages = 10;  // Limit to last 10 messages
if (count _messages > _maxMessages) then {
    _messages resize _maxMessages;
    (_ctrl displayCtrl 9001) ctrlSetText parseText (toString _messages joinString "\n");  // Rejoin limited messages
};
