// client_triggerDespawn.sqf - Client-side script to request AI cleanup on the server

private _group = your_ai_group_variable; // Reference to the AI group to despawn

// Trigger the despawn on the server
[_group] remoteExec ["server_despawnAI.sqf", 2]; // Execute the despawn on the server
