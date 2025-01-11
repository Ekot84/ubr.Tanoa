// Check if player can jump (e.g., not in a vehicle, on the ground)
if (!canMove player || !isTouchingGround player) exitWith {
    hint "You cannot jump right now!";
};

// Jump Parameters
private _jumpHeight = 1.5; // Height of the jump
private _jumpDistance = 2; // Forward distance of the jump
private _jumpDelay = 0.5; // Time before the player regains control

// Get player's current direction and position
private _dir = getDir player;
private _pos = getPos player;

// Calculate new position
private _newPos = [
    (_pos select 0) + _jumpDistance * sin(_dir * (pi / 180)), // Forward
    (_pos select 1) + _jumpDistance * cos(_dir * (pi / 180)), // Right/Left
    (_pos select 2) + _jumpHeight // Upward
];

// Temporarily disable player controls
player allowDamage false;
player setPos _newPos;
sleep _jumpDelay;
player allowDamage true;

// Optional: Add sound or animation
playSound3D ["A3\Sounds_F\weapons\Explosion\explosive_metal_small_3", player];
