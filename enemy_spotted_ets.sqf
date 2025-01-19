if (!isServer) exitWith {}; // Ensure this only runs on the server

private _updateInterval = 2; // Check every 2 seconds
private _markerHeight = 2; // Height above enemy's head
private _markerObjects = createHashMap; // Stores active markers

while {true} do {
    {
        private _group = _x;
        {
            private _unit = _x;
            private _knownEnemies = _unit targets [true, 200]; // Detects enemies within 200m

            {
                private _enemy = _x;
                private _markerName = format ["ETS_Marker_%1", _enemy];

                if (!(_markerObjects getOrDefault [_markerName, false])) then {
                    // Create a 3D marker above the enemy
                    private _markerObj = createSimpleObject ["A3\Structures_F\Items\Sport\Football_01_F.p3d", [0,0,0]];
                    _markerObj attachTo [_enemy, [0, 0, _markerHeight]];
                    _markerObj setObjectTextureGlobal [0, "#(argb,8,8,3)color(1,0,0,1)"];

                    _markerObjects set [_markerName, _markerObj];

                    // Sync marker to all clients
                    [_markerObj, _enemy] remoteExec ["attachTo", 0, true];
                };
            } forEach _knownEnemies;
        } forEach units _group;
    } forEach allGroups;

    // Remove markers for enemies no longer spotted
    {
        private _markerName = _x;
        private _markerObj = _markerObjects get _markerName;
        private _enemyExists = false;

        {
            private _group = _x;
            {
                private _unit = _x;
                private _knownEnemies = _unit targets [true, 200];
                if (_markerName in (map (_x) forEach _knownEnemies)) then {
                    _enemyExists = true;
                };
            } forEach units _group;
        } forEach allGroups;

        if (!_enemyExists) then {
            detach _markerObj;
            deleteVehicle _markerObj;
            _markerObjects deleteAt _markerName;
        };
    } forEach keys _markerObjects;

    sleep _updateInterval;
};
