[] spawn {
    while {true} do {
        // Ensure player exists and is alive
        if (!isNull player && alive player) then {
            private _player = player; // Reference to the player
            private _currentStamina = getStamina _player; // Get current stamina
            private _maxStamina = 1; // Max stamina value
            private _regenRate = 0.005; // Base stamina regeneration rate
            private _drainRate = 0.002; // Base stamina drain rate

            // Get the player's current speed (in meters per second)
            private _speed = speed _player; // Directly uses the `speed` function

            // Walking: Regenerate stamina
            if (_speed > 1 && _speed < 10) then {
                if (_currentStamina < _maxStamina) then {
                    private _newStamina = _currentStamina + (_regenRate * 2); // Walking regen
                    _player setStamina (_newStamina min _maxStamina); // Cap stamina at max
                };
            };

            // Running or Sprinting: Drain stamina
            if (_speed >= 10) then {
                if (_currentStamina > 0) then {
                    private _newStamina = _currentStamina - (_drainRate * 2); // Sprint drain
                    _player setStamina (_newStamina max 0); // Prevent stamina from going below 0
                };
            };

            // Standing still or resting: Normal regen
            if (_speed <= 1) then {
                if (_currentStamina < _maxStamina) then {
                    private _newStamina = _currentStamina + _regenRate; // Normal regen
                    _player setStamina (_newStamina min _maxStamina);
                };
            };
        };

        // Wait a short duration before repeating (lower CPU impact)
        sleep 0.1;
    };
};
