if (!isServer) exitWith {}; // Only runs on the server

ammoUsageDB = createHashMap; // Store per-player ammo usage

"onPlayerConnected" addPublicVariableEventHandler {
    params ["_key", "_value"];
    private _playerUID = _key select [10]; // Extract UID from "ammoUsed_<UID>"
    
    if (!isNil "_playerUID") then {
        ammoUsageDB set [_playerUID, _value];
        diag_log format ["SERVER: Updated ammo usage for %1: %2", _playerUID, _value];
    };
};

// When player disconnects, store their data
"onPlayerDisconnected" addPublicVariableEventHandler {
    params ["_uid"];
    if (ammoUsageDB get _uid != nil) then {
        diag_log format ["SERVER: Storing final ammo count for %1: %2", _uid, ammoUsageDB get _uid];
    };
};
