// client_triggerAI.sqf - Client-side script to request AI spawn on the server

private _playerPos = getPos player; // Get the player's position

// Trigger the spawn on the server using remoteExec
[ _playerPos ] remoteExec ["server_spawnAI.sqf", 2]; // 2 means "execute on server"
