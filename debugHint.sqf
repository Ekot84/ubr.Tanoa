if (hasInterface) then {
    [] spawn {
        private _player = player;

        while {true} do {
            private _allEnemies = allUnits select { side _x == east && alive _x };

            private _countAlive = count _allEnemies;  
            private _count200 = count (_allEnemies select { _x distance _player <= 200 });  
            private _count500 = count (_allEnemies select { _x distance _player <= 500 });  
            private _count1km = count (_allEnemies select { _x distance _player <= 1000 });  

            // **Retrieve stored hit data (ensure it exists)**
            private _hitData = _player getVariable ["hitStats", createHashMap];  

            // **Retrieve global `totalHits` safely**
            private _totalHits = _player getVariable ["globalTotalHits", 0];
            if (isNil "_totalHits" || {!(_totalHits isEqualType 0)}) then { _totalHits = 0; };

            // **Extract all stored hit parts safely**
            private _hitParts = keys _hitData;
            private _hitDetails = "";

            {
                private _hitCount = _hitData getOrDefault [_x, 0];
                if (!isNil "_hitCount" && {_hitCount isEqualType 0} && {_hitCount > 0}) then {  
                    _hitDetails = _hitDetails + format ["%1: %2\n", _x, _hitCount];
                };
            } forEach _hitParts; // Dynamically retrieves ALL stored hit parts

            if (_hitDetails == "") then { _hitDetails = "No hits recorded."; };

            hintSilent format [  
                "Enemies Alive: %1\nWithin 200m: %2\nWithin 500m: %3\nWithin 1km: %4\n\nGlobal Total Hits: %5\n%6",  
                _countAlive, _count200, _count500, _count1km,  
                _totalHits, _hitDetails  
            ];  

            sleep 1;
        };
    };
};
