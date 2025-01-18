_dumpHandGrenadesToFile = {
    private _fileName = "handgrenades_dump.txt";
    private _file = ofstream_new _fileName;

    if (isNil "_file") exitWith {
        systemChat "Failed to create file handle!";
        diag_log "[ERROR] Failed to create file handle.";
    };

    diag_log format ["[DEBUG] Opened file for saving: %1", _fileName];
    _file ofstream_write "========== Hand Grenade Class Names ==========";

    private _grenades = [];
    private _cfgWeapons = configFile >> "CfgWeapons";
    private _count = count _cfgWeapons;

    for "_i" from 0 to (_count - 1) do {
        private _cfg = _cfgWeapons select _i;
        if (isClass _cfg) then {
            private _classname = configName _cfg;
            private _ammo = getText (_cfg >> "ammo");

            // Ensure that the item has ammo and that the ammo exists in CfgAmmo
            if (_ammo != "" && isClass (configFile >> "CfgAmmo" >> _ammo)) then {
                private _ammoType = getText (configFile >> "CfgAmmo" >> _ammo >> "simulation");

                // Check if it's a grenade (Simulation = "shotShell")
                if (_ammoType == "shotShell") then {
                    _grenades pushBack _classname;
                    _file ofstream_write format ["Grenade: %1", _classname];
                };
            };
        };
    };

    _file ofstream_write format ["Total Hand Grenades Found: %1", count _grenades];

    diag_log "========== Dump Complete ==========";
    hint format ["Dumped %1 Hand Grenades to file: %2", count _grenades, _fileName];
};

player addAction ["Dump Hand Grenades to File", _dumpHandGrenadesToFile];
