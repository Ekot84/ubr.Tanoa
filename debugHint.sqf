if (hasInterface) then {
    [] spawn 
    {  
        private _player = player;  
        _player setVariable ["lastHit", "No hits detected.", true]; // Initialize global variable  

        // Function to add HandleDamage event handler to AI (prevents duplicates)  
        private _addHitEH = {  
            params ["_unit"];  
            if (isNil (_unit getVariable "hitEH_added")) then // ✅ Fixed Syntax  
            {  
                _unit setVariable ["hitEH_added", true];  

                _unit addEventHandler ["HandleDamage", {  
                    params ["_unit", "_selection", "_damage", "_source", "_projectile"];  

                    if (!isNull _source && { _source isEqualTo player }) then  
                    {  
                        private _unitName = if (name _unit != "") then {name _unit} else {"Enemy"};  
                        private _hitText = format ["Hit: %1 | Body Part: %2 | Damage: %.2f", _unitName, _selection, _damage];  

                        _player setVariable ["lastHit", _hitText, true]; // Store persistently  

                        systemChat _hitText; // Debugging message  
                    };  

                    _damage // Ensure normal damage processing  
                }];  
            };  
        };  

        // Add HandleDamage to the player (prevents duplicate)  
        if (isNil (_player getVariable "hitEH_added")) then // ✅ Fixed Syntax  
        {  
            _player setVariable ["hitEH_added", true];  

            _player addEventHandler ["HandleDamage", {  
                params ["_unit", "_selection", "_damage", "_source", "_projectile"];  

                if (!isNull _source && { _source isEqualTo player }) then  
                {  
                    private _unitName = if (name _unit != "") then {name _unit} else {"Enemy"};  
                    private _hitText = format ["Hit: %1 | Body Part: %2 | Damage: %.2f", _unitName, _selection, _damage];  

                    _player setVariable ["lastHit", _hitText, true]; // Store persistently  

                    systemChat _hitText; // Debugging message  
                };  

                _damage // Ensure normal damage processing  
            }];  
        };  

        while {true} do  
        {  
            private _allEnemies = allUnits select { side _x == east && alive _x };  

            // Ensure all AI enemies have HandleDamage event handler  
            {  
                [_x] call _addHitEH;  
            } forEach _allEnemies;  

            private _countAlive = count _allEnemies;  
            private _count200 = count (_allEnemies select { _x distance _player <= 200 });  
            private _count500 = count (_allEnemies select { _x distance _player <= 500 });  
            private _count1km = count (_allEnemies select { _x distance _player <= 1000 });  

            // Retrieve last hit data from the persistent variable  
            private _hitInfo = _player getVariable ["lastHit", "No hits detected."];  

            // Silent hint display  
            hintSilent format [  
                "Enemies Alive: %1\nWithin 200m: %2\nWithin 500m: %3\nWithin 1km: %4\n\n%5",  
                _countAlive, _count200, _count500, _count1km, _hitInfo  
            ];  

            sleep 1; // Refreshes every 1 second for more responsive hit updates  
        };  
    }; // **Closing spawn block**  
};