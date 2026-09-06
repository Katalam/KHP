#include "script_component.hpp"
    class CfgPatches {
        class ADDON {
            name = QUOTE(COMPONENT);
            units[] = {
                "KHP_Module_FillHouse"
            };
            weapons[] = {};
            requiredVersion = REQUIRED_VERSION;
            requiredAddons[] = {
                "CBA_settings",
                "A3_Modules_F",
            };
            author = ECSTRING(main,author);
            VERSION_CONFIG;
        };
    };


#include "CfgEventHandlers.hpp"
#include "CfgVehicles.hpp"
#include "CfgFactionClasses.hpp"
#include "CfgHouseData.hpp"
