#include "script_component.hpp"
/*
 * Author: Katalam
 * Module init function for the Fill House module (Zeus and Eden).
 * Resolves the building under the cursor (or nearest to the module) and
 * fills it with furniture via KHP_position_fnc_fillHouse.
 * Module logic is deleted after execution.
 *
 * Arguments:
 * 0: Mode <STRING> ("init" or "attributesChanged3DEN")
 * 1: Input <ARRAY> [logic <OBJECT>, isActivated <BOOL>, isCuratorPlaced <BOOL>]
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params [["_mode", "", [""]], ["_input", [], [[]]]];

switch _mode do {
    case "attributesChanged3DEN";
    case "init": {
        _input params [
            ["_logic", objNull, [objNull]],
            ["_isActivated", true, [true]],
            ["_isCuratorPlaced", false, [true]]
        ];

        // In MP only run for the local client.
        if (!local _logic) exitWith {};
        if (!_isActivated) exitWith {};

        // Resolve the building to fill.
        private _house = objNull;
        if (is3DEN) then {
            if (get3DENMouseOver # 0 == "Object") then { _house = get3DENMouseOver # 1; };
        } else {
            if (curatorMouseOver # 0 == "Object") then { _house = curatorMouseOver # 1; };
        };

        // Only buildings/things are valid targets.
        if !(isNull _house) then {
            if !(_house isKindOf "building" || _house isKindOf "thing") then { _house = objNull; };
        };

        // Fall back to the nearest valid building around the module.
        if (isNull _house) then {
            private _searchPos = if (is3DEN) then { screenToWorld getMousePosition } else { getPos _logic };
            private _candidates = nearestObjects [_searchPos, ["building"], 25, true] select {
                sizeOf typeOf _x > 2 || { _x buildingPos - 1 isNotEqualTo [] }
            };
            if (_candidates isNotEqualTo []) then { _house = _candidates select 0; };
        };

        // Delete the module to prevent any dependencies.
        if (_logic isKindOf "Logic") then {
            if (is3DEN) then { delete3DENEntities [_logic]; } else { deleteVehicle _logic; };
        };

        if (isNull _house) exitWith {
            private _msg = "KHP_position: Fill House - no valid building found within 25m";
            if (is3DEN || { !isMultiplayer }) then { systemChat _msg; } else { diag_log _msg; };
        };

        if (is3DEN) then {
            collect3DENHistory {
                _house call FUNC(fillHouse);
            };
        } else {
            // Simple objects are local only - run the fill on every machine.
            [_house] remoteExec [FUNC(fillHouse), 0];
        };
    };
};

true
