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
private _cfgRoot = missionConfigFile >> "CfgHouseData" >> _buildingType;

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

        private _count = count _types;
        private _housePos = getPosWorld _house;
        private _houseDir = getDir _house;
        private _cos = cos _houseDir;
        private _sin = sin _houseDir;

        for "_i" from 0 to (_count - 1) do {
            private _type = _types select _i;
            private _relX = _xs select _i; // east
            private _relY = _ys select _i; // up
            private _relZ = _zs select _i; // north
            private _yaw  = _yaws select _i;

            // Stored offsets are direction-0 [east, up, north].
            // Rotate the horizontal components by the live house direction.
            private _worldX = _relX * _cos + _relZ * _sin;
            private _worldY = -_relX * _sin + _relZ * _cos;

            private _worldOffset = [_worldX, _worldY, _relY];
            private _worldPos = _housePos vectorAdd _worldOffset;

            private _furniture = [_type, [0, 0, 0]] call BIS_fnc_createSimpleObject;
            _furniture setDir (_houseDir + _yaw);
            _furniture setPosWorld _worldPos;
        };
    };

    _roomIndex = _roomIndex + 1;
};

_house setVariable [QGVAR(furnitureFilled), true, true];
