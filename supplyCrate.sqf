// Configuration (Updated for Bug Testing)
crateDropInterval = [300, 900]; // Airdrop every 5-15 minutes
crateLifetime = 600; // Crate disappears after 10 minutes
planeType = "B_T_VTOL_01_infantry_F"; // Default plane, change to "C130J_Cargo" if using CUP mod

// **Configurable Drop Range & Height**
minAirdropDistance = 500;  
maxAirdropDistance = 2500;  
fixedPlaneAltitude = 3000;  // **Fixed safe altitude (no terrain checks)**
crateDropHeight = 600;  // **Crate always drops from 600m above ground**

fnc_AirdropCrate = {
    private _caller = selectRandom (allPlayers select {!(_x isKindOf "HeadlessClient_F")});
    if (isNull _caller) exitWith { systemChat "[ERROR] No valid player found for airdrop."; };

    private _randomDelay = selectRandom crateDropInterval; 
    systemChat format ["[LOGISTICS] A supply crate is inbound! It will enter range in %1 seconds.", _randomDelay];
    sleep _randomDelay; 

    private _dropPos = [];
    private _validPosition = false;

    while {!_validPosition} do {
        private _randomDir = random 360;
        private _randomDist = minAirdropDistance + random (maxAirdropDistance - minAirdropDistance);
        _dropPos = _caller getPos [_randomDist, _randomDir]; 

        _dropPos set [2, 0]; // **Ground level drop position**
        _validPosition = true;
    };

    systemChat format ["[DEBUG] Drop position found at %1", _dropPos];

    // **Plane always flies at a fixed safe altitude**
    private _planeSpawnPos = _dropPos vectorAdd [0, -2000, fixedPlaneAltitude];

    systemChat "[LOGISTICS] A supply plane is incoming at 3000m altitude! Look to the skies!";

    // **Spawn the plane**
    private _plane = createVehicle [planeType, _planeSpawnPos, [], 0, "FLY"];
    _plane setPosASL [_planeSpawnPos select 0, _planeSpawnPos select 1, fixedPlaneAltitude];
    _plane setVelocity [0, 200, 0];

    private _group = createGroup west;
    private _pilot = _group createUnit ["B_Pilot_F", _planeSpawnPos, [], 0, "NONE"];
    _pilot assignAsDriver _plane;
    _pilot moveInDriver _plane;

    private _waypoint = _group addWaypoint [_dropPos vectorAdd [0, 2000, fixedPlaneAltitude], 0];
    _waypoint setWaypointType "MOVE";

    waitUntil { (_plane distance2D _dropPos) < 250 }; 

    systemChat "[LOGISTICS] Supply crate is dropping now! Red smoke at the landing site.";

    // **Drop a red smoke grenade at the initial drop location**
    private _smokeStart = createVehicle ["SmokeShellRed", _dropPos, [], 0, "CAN_COLLIDE"];
    if (isNull _smokeStart) then { systemChat "[ERROR] Smoke grenade failed to spawn!"; };

    // **Create a map marker for the initial drop location**
    private _markerName = format ["crateMarker_%1", diag_tickTime];
    private _marker = createMarker [_markerName, _dropPos];
    _marker setMarkerType "mil_box";
    _marker setMarkerColor "ColorRed";
    _marker setMarkerText "Supply Drop (Drifting)";
    _marker setMarkerSize [1, 1];
    _marker setMarkerAlpha 1;
    systemChat format ["[LOGISTICS] Initial drop marker set at %1", _dropPos];

    // **Ensure crate spawns at the correct height**
    private _crateDropPos = _dropPos;
    _crateDropPos set [2, crateDropHeight];

    // **Create the larger crate**
    private _crate = createVehicle ["B_CargoNet_01_ammo_F", _crateDropPos, [], 0, "NONE"]; // **Larger crate**
    _crate setPosASL _crateDropPos;
    if (isNull _crate) then { systemChat "[ERROR] Crate failed to spawn!"; };

    // **Attach parachute**
    private _parachute = createVehicle ["B_Parachute_02_F", _crateDropPos, [], 0, "FLY"];
    _parachute setPosASL _crateDropPos;
    _crate attachTo [_parachute, [0, 0, 0]];

    // **Increase parachute descent speed to avoid trees**
    _parachute setVelocity [0, 0, -10];

    // **Wait for crate to land and determine final landing position**
    waitUntil { getPosATL _crate select 2 < 5 };  

    detach _crate;
    systemChat "[LOGISTICS] Crate has landed and parachute detached.";

    // **Adjust marker and spawn final smoke grenade**
    private _finalPos = getPosATL _crate;

    // **Move marker to final crate position**
    _marker setMarkerPos _finalPos;
    _marker setMarkerText "Supply Drop (Final)";

    // **Spawn smoke at final landing position**
    private _smokeFinal = createVehicle ["SmokeShellRed", _finalPos, [], 0, "CAN_COLLIDE"];
    if (isNull _smokeFinal) then { systemChat "[ERROR] Final smoke grenade failed to spawn!"; };

    // **Ensure the crate doesn't get stuck in trees**
    if (getTerrainHeightASL _finalPos > getPosASL _crate select 2) then {
        systemChat "[WARNING] Crate may be stuck in trees, adjusting position!";
        _crate setPos [_finalPos select 0, _finalPos select 1, (getTerrainHeightASL _finalPos) + 0.5];
    };

    // **Enable Virtual Arsenal on the crate using BIS_fnc_arsenal**
    ["AmmoboxInit", [_crate, true]] spawn BIS_fnc_arsenal;
    systemChat "[LOGISTICS] Virtual Arsenal enabled on the crate!";

    [_plane, _group, _pilot] spawn {
        params ["_plane", "_group", "_pilot"];
        sleep 60;
        deleteVehicle _plane;
        deleteVehicle _pilot;
        deleteGroup _group;
    };

    systemChat "[LOGISTICS] Crate has landed! Marker updated and smoke deployed.";

    [_crate, _parachute, _smokeStart, _smokeFinal, _marker] spawn {
        sleep crateLifetime;
        deleteVehicle _crate;
        deleteVehicle _parachute;
        deleteVehicle _smokeStart;
        deleteVehicle _smokeFinal;
        deleteMarker _marker;
        systemChat "[LOGISTICS] Crate and markers removed.";
    };
};

// **Repeating Airdrop Function**
[] spawn { while {true} do { sleep (selectRandom crateDropInterval); [] call fnc_AirdropCrate; }; };
