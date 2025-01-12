fnc_showKillfeed = {
    params ["_message", "_killer", "_victim"];

    // Helper function to determine side-based colors
    private _getSideColor = {
        params ["_unit"];
        switch (side _unit) do {
            case west: { "#007BFF" };       // BLUFOR (Blue)
            case east: { "#FF0000" };       // OPFOR (Red)
            case resistance: { "#00FF00" }; // INDEPENDENT (Green)
            case civilian: { "#FFFF00" };   // CIVILIAN (Yellow)
            default { "#FFFFFF" };          // Default (White)
        };
    };

    // Get colors for killer and victim
    private _killerColor = if (!isNull _killer) then { [_killer] call _getSideColor } else { "#FFFFFF" };
    private _victimColor = if (!isNull _victim) then { [_victim] call _getSideColor } else { "#FFFFFF" };

    // Format the killfeed message
    private _formattedMessage = if (!isNull _killer) then {
        format ["<t color='%1'>%2</t> was killed by <t color='%3'>%4</t>", _victimColor, name _victim, _killerColor, name _killer]
    } else {
        format ["<t color='%1'>%2</t> died.", _victimColor, name _victim];
    };

    // Log for debugging
    diag_log format ["[Killfeed] %1", _formattedMessage];

    // Display the message
    private _ctrl = uiNamespace getVariable ["Killfeed", displayNull];
    if (!isNull _ctrl) then {
        // Retrieve current text
        private _currentText = ctrlText (_ctrl displayCtrl 9001);
        _currentText = _formattedMessage + "\n" + _currentText;

        // Update the killfeed control
        (_ctrl displayCtrl 9001) ctrlSetText parseText _currentText;
    };
};
