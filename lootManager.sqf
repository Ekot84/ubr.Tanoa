[] spawn {
    private _lootPool = [
        ["FirstAidKit", 0.3],
        ["Medikit", 0.1],
        ["arifle_MX_F", 0.05],
        ["30Rnd_65x39_caseless_mag", 0.2],
        ["Binocular", 0.15],
        ["Chemlight_green", 0.4]
    ];

    private _lootSpawnRadius = 50;
    private _lootDespawnDelay = 300;
    private _lootCheckInterval = 10;
    private _activeHouses = [];

    while {true} do {
        private _players = allPlayers select {alive _x};

        {
            private _player = _x;
            private _nearHouses = nearestTerrainObjects [getPos _player, ["House", "Building"], _lootSpawnRadius];

            {
                private _house = _x;
                private _playersNear = _house nearEntities [["CAManBase"], _lootSpawnRadius];

                if (count _playersNear > 0) then {
                    // Spawn loot if not already spawned
                    if (!(_house getVariable ["lootSpawned", false])) then {
                        [_house, _lootPool] call spawnLootInHouse;
                        _house setVariable ["lastPlayerTime", diag_tickTime];
                        _activeHouses pushBackUnique _house;
                    };
                } else {
                    // Despawn loot if no players nearby
                    private _lastSeen = _house getVariable ["lastPlayerTime", 0];
                    if (diag_tickTime - _lastSeen > _lootDespawnDelay) then {
                        private _lootInHouse = _house nearObjects ["WeaponHolderSimulated_Scripted", 5];
                        { deleteVehicle _x } forEach _lootInHouse;
                        _house setVariable ["lootSpawned", false];
                        _activeHouses = _activeHouses - [_house];
                    };
                };
            } forEach _nearHouses;
        } forEach _players;

        // Debugging feedback
        hintSilent format [
            "Active Houses: %1\nPlayers: %2\nLoot Spawned: %3",
            count _activeHouses,
            count _players,
            count allMissionObjects "WeaponHolderSimulated_Scripted"
        ];

        sleep _lootCheckInterval;
    };
};
