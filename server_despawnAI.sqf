// server_despawnAI.sqf - Server-side function for despawning AI

private _despawnAI = {
    params ["_group"];
    {
        deleteVehicle _x; // Delete each unit in the group
    } forEach units _group;
    deleteGroup _group; // Delete the group itself
    diag_log format ["AI group removed at %1.", getPosATL _group];
};
