#include "script_component.hpp"
/*
 * Author: Ian Banks (foxhound.international), ported for KHP_position
 * Returns the Eden [x, y, z] rotation of an object derived from its
 * vectorDirAndUp.
 *
 * Arguments:
 * 0: Source <OBJECT>
 * 1: XY only <BOOL> (optional, default: false)
 *
 * Return Value:
 * [xRot, yRot, zRot] <ARRAY> (zRot omitted when XY only)
 *
 * Example:
 * [cursorTarget] call KHP_position_fnc_vector2Eden;
 *
 * Public: No
 */

params [
    ["_source", objNull, [objNull]],
    ["_xyOnly", false, [true]]
];

private _direction = vectorDir _source;
private _up = vectorUp _source;
private _aside = _direction vectorCrossProduct _up;
private ["_xRot", "_yRot", "_zRot"];

if (abs (_up select 0) < 0.999999) then {
    _yRot = -asin (_up select 0);
    private _signCosY = if (cos _yRot < 0) then { -1 } else { 1 };
    _xRot = (_up select 1 * _signCosY) atan2 (_up select 2 * _signCosY);
    _zRot = (_direction select 0 * _signCosY) atan2 (_aside select 0 * _signCosY);
} else {
    _zRot = 0;
    if (_up select 0 < 0) then {
        _yRot = 90;
        _xRot = (_aside select 1) atan2 (_aside select 2);
    } else {
        _yRot = -90;
        _xRot = (-(_aside select 1)) atan2 (-(_aside select 2));
    };
};

if (_xyOnly) exitWith { [_xRot, _yRot] };

[_xRot, _yRot, _zRot]
