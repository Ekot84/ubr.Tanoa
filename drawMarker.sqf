//params ["_enemy", "_height", "_canSee", "_canSeeVariable"];  // Unpack the parameters
params ["_enemy", "_height"];


diag_log format ["[DEBUG] Client: Creating marker for enemy: %1", _enemy];
diag_log format ["[DEBUG] Client: _height: %1, _canSee: %2, _canSeeVariable: %3", _height, _canSee, _canSeeVariable];

// Define the icon
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

// Draw the icon above the enemy's head
diag_log "[DEBUG] Client: Drawing icon directly...";  // Log to ensure the icon is being drawn
drawIcon3D
[
    _icon,         // Icon path (string)
    _color,        // RGBA color (array of 4 numbers)
    _targetPos,    // Icon position (3D position array)
    _iconSizeW,    // Icon width (scalar)
    _iconSizeH,    // Icon height (scalar)
    getDirVisual player  // Direction for rotation (scalar)
];
