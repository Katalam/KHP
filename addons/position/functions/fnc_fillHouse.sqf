#include "script_component.hpp"
/*
 * Author: Katalam
 * Spawns furniture for a house using CfgHouseData.
 * For every room a random variant is chosen and its furniture is created
 * relative to the house position and direction.
 * Offsets in CfgHouseData are plain SQM-order [x,z,y] values saved as
 * [east, up, north] relative to a direction-0 reference house.
 *
 * Arguments:
 * 0: House <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [cursorTarget] call KHP_position_fnc_fillHouse;
 *
 * Public: Yes
 */

params [
    ["_house", objNull, [objNull]]
];

if (isNull _house) exitWith {};
if (_house getVariable [QGVAR(furnitureFilled), false]) exitWith {};

private _buildingType = typeOf _house;
private _cfgRoot = configFile >> "CfgHouseData" >> _buildingType;

if !(isClass _cfgRoot) exitWith {};

private _roomIndex = 1;
while {isClass (_cfgRoot >> ("Room" + str _roomIndex))} do {
    private _cfgRoom = _cfgRoot >> ("Room" + str _roomIndex);

    private _variants = [];
    private _variantIndex = 1;
    while {isClass (_cfgRoom >> ("Variant" + str _variantIndex))} do {
        _variants pushBack (_cfgRoom >> ("Variant" + str _variantIndex));
        _variantIndex = _variantIndex + 1;
    };

    if (_variants isNotEqualTo []) then {
        private _cfgVariant = selectRandom _variants;

        private _types = getArray (_cfgVariant >> "types");
        private _xs    = getArray (_cfgVariant >> "x");
        private _ys    = getArray (_cfgVariant >> "y");
        private _zs    = getArray (_cfgVariant >> "z");
        private _yaws  = getArray (_cfgVariant >> "yaw");

        // Eden rotation of the house, the yaw of each item is added on top.
        ([_house] call FUNC(vector2Eden)) params ["_xRot", "_yRot", "_zRot"];

        private _count = count _types;

        for "_i" from 0 to (_count - 1) do {
            private _type = _types select _i;
            private _relX = _xs select _i; // east
            private _relY = _ys select _i; // up
            private _relZ = _zs select _i; // north
            private _yaw  = _yaws select _i;

            // Stored offsets are direction-0 [east, up, north] with sea-level
            // based heights (SQM config order). modelToWorldWorld expects
            // [east, north, up] and returns a sea-level based (ASL) position,
            // which matches both the extracted data and setPosASL.
            // modelToWorld would return AGL (terrain/wave relative) - do not use.
            private _itemPosASL = _house modelToWorldWorld [_relX, _relZ, _relY];

            if (is3DEN) then {
                private _furniture = create3DENEntity ["Object", _type, [0, 0, 0], true];

                // The Eden position attribute expects ATL.
                _furniture set3DENAttribute ["position", ASLToATL _itemPosASL];
                _furniture set3DENAttribute ["rotation", [_xRot, _yRot, _zRot + _yaw]];
                _furniture set3DENAttribute ["enableSimulation", false];
                _furniture set3DENAttribute ["objectIsSimple", true];
            } else {
                private _furniture = [_type, [0, 0, 0]] call BIS_fnc_createSimpleObject;
                _furniture setPosASL _itemPosASL;
                _furniture setVectorDirAndUp [vectorDir _house, vectorUp _house];

                // Rotate the furniture around its own up axis by the yaw.
                private _cos = cos _yaw;
                private _sin = sin _yaw;
                private _dir = vectorDir _furniture;
                private _up = vectorUp _furniture;
                private _newDir = (_dir vectorMultiply _cos) vectorAdd ((_dir vectorCrossProduct _up) vectorMultiply _sin);
                _furniture setVectorDirAndUp [_newDir, _up];

                { [_x, [[_furniture], true]] remoteExec ["addCuratorEditableObjects", 2] } forEach allCurators;
            };
        };
    };

    _roomIndex = _roomIndex + 1;
};

_house setVariable [QGVAR(furnitureFilled), true, true];
