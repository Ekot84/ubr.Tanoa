private _enemy = player;  // For testing, use the player as the target
private _height = 2;  // Adjust height above the enemy's head

// Simple check to make sure the icon is drawn above the player
private _icon = "\A3\ui_f\data\map\markers\military\warning_CA.paa";  // Make sure the path is correct
//private _icon = "C:\Users\andre\Documents\Arma 3\mpmissions\ubr.Tanoa\icons\spott.paa";  // Make sure the path is correct

// Get the position above the player's head
private _targetPos = _enemy modelToWorldVisual [0, 0, _height];

// Size of the icon based on distance
private _distance = player distance _enemy;
private _iconSize = (_distance / 1000); // Adjust the size based on distance

// Draw the 3D icon above the player
drawIcon3D [_icon, [1, 0, 0, 1], _targetPos, _iconSize, _iconSize, 0, "", 0.1, 0.1, "TahomaB"];

iconPos = player getPos [10, 0] vectorAdd [0,0,2];
addMissionEventHandler ["draw3D",
{
	drawIcon3D
	[
		"\A3\ui_f\data\map\markers\military\warning_CA.paa",
		[0,0,1,1],
		iconPos,
		5,
		5,
		getDirVisual player,
		"COMPASS",
		0,
		0.3,
		"PuristaMedium",
		"center",
		true
	];
}];