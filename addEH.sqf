// addEH.sqf
if (isServer) then {

    // **Define Global Function for AI Kill Handler**
    missionNamespace setVariable ["addKillHandler", {
        params ["_unit"];

        if (isNull _unit || {_unit getVariable ["MPKilledHandlerSet", false]}) exitWith {};

        _unit setVariable ["MPKilledHandlerSet", true, true];

        _unit addMPEventHandler ["MPKilled", {
            params ["_unit", "_killer", "_instigator", "_useEffects"];
            
            if (isNull _unit || {isNull _killer}) exitWith {}; 
            if (!isPlayer _killer) exitWith {}; // Only count player kills

            // **Prevent AI from being processed multiple times**
            if (_unit getVariable ["KillProcessed", false]) exitWith {};
            _unit setVariable ["KillProcessed", true, true];

            private _scoreUpdate = [0, 0, 0, 0, 0];

            // **Unit Type Tracking (Currently Scores Set to 0)**
            if (_unit isKindOf "Man") then {
                _scoreUpdate set [0, 0];  // Infantry Kill
            } else {
                if (_unit isKindOf "Car" || _unit isKindOf "Motorcycle") then {
                    _scoreUpdate set [1, 0];  // Soft Vehicle Kill
                } else {
                    if (_unit isKindOf "Tank" || _unit isKindOf "APC") then {
                        _scoreUpdate set [2, 0];  // Armor Kill
                    } else {
                        if (_unit isKindOf "Air") then {
                            _scoreUpdate set [3, 0];  // Air Kill
                        };
                    };
                };
            };

            // **Apply Score Update (Execute Only on Server)**
            [_killer, _scoreUpdate] remoteExec ["addPlayerScores", 0];
        }];
    }];

    // **Define Global Function for Player Death Handler**
    missionNamespace setVariable ["addPlayerHandler", {
        params ["_player"];

        if (isNull _player || {!isPlayer _player} || {_player getVariable ["MPKilledHandlerSet", false]}) exitWith {};

        _player setVariable ["MPKilledHandlerSet", true, true];

        _player addMPEventHandler ["MPKilled", {
            params ["_unit", "_killer", "_instigator", "_useEffects"];

            if (isNull _unit) exitWith {};

            // **Prevent Death Processing Multiple Times**
            if (_unit getVariable ["DeathProcessed", false]) exitWith {};
            _unit setVariable ["DeathProcessed", true, true];

            // **Handle Deaths (Only for Players)**
            [_unit, [0, 0, 0, 0, 1]] remoteExec ["addPlayerScores", 0];

            // **Debugging Logs**
            diag_log format ["[Player Death Log] %1 died. Death added.", name _unit];
        }];
    }];

    // **Apply MPKilled to All Existing AI (Ensuring Only One Handler per AI)**
    {
        if (!isPlayer _x && {!(_x getVariable ["MPKilledHandlerSet", false])}) then {
            [_x] call (missionNamespace getVariable "addKillHandler");
        };
    } forEach allUnits;

    // **Apply MPKilled to All Existing Players (Ensuring Only One Handler per Player)**
    {
        if (isPlayer _x && {!(_x getVariable ["MPKilledHandlerSet", false])}) then {
            [_x] call (missionNamespace getVariable "addPlayerHandler");
        };
    } forEach allPlayers;

    // **Handle New AI That Spawn Mid-Game**
    addMissionEventHandler ["EntityCreated", {
        params ["_entity"];

        if (_entity isKindOf "CAManBase" && {!isPlayer _entity} && {!(_entity getVariable ["MPKilledHandlerSet", false])}) then {
            _entity setVariable ["MPKilledHandlerSet", true, true];
            [_entity] call (missionNamespace getVariable "addKillHandler");

            // **Debugging Logs**
            diag_log format ["[DEBUG] New AI Spawned, Event Handler Assigned: %1", name _entity];
        };
    }];

    // **Handle Players Joining Mid-Game**
    addMissionEventHandler ["PlayerConnected", {
        params ["_id", "_uid", "_name", "_jip", "_owner"];
        private _player = _owner call BIS_fnc_getUnitByUID;

        if (!isNull _player && {isPlayer _player} && {!(_player getVariable ["MPKilledHandlerSet", false])}) then {
            _player setVariable ["MPKilledHandlerSet", true, true];
            [_player] call (missionNamespace getVariable "addPlayerHandler");

            // **Debugging Logs**
            diag_log format ["[DEBUG] Player Joined, Event Handler Assigned: %1", name _player];
        };
    }];
};
