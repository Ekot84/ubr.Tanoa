[] execVM "spawnServerObjects.sqf";
[] execVM "addEH.sqf";
[] execVM "enemy_spotted_ets.sqf";


if (isServer) then {
    addMissionEventHandler ["PlayerConnected", {
        params ["_id", "_uid", "_name", "_jip", "_owner"];
        private _player = _owner call BIS_fnc_getUnitByUID;

        if (!isNull _player && {isPlayer _player}) then {
            [_player, [0, 0, 0, 0, 0]] remoteExec ["addPlayerScores", 2];
            diag_log format ["[DEBUG] Initialized scores for %1: %2", _name, getPlayerScores _player];
        };
    }];
};


