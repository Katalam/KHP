class CfgVehicles
{
	class Logic;
	class Module_F : Logic
	{
		class ModuleDescription;
	};

	class KHP_Module_FillHouse : Module_F
	{
		scope = 2;
		scopeCurator = 2;
		displayName = CSTRING(moduleFillHouse_displayName);
		category = "KHP_Position";

		function = QFUNC(moduleFillHouse);
		functionPriority = 1;
		isGlobal = 0;
		isTriggerActivated = 0;
		isDisposable = 0;
		is3DEN = 1;
		curatorCanAttach = 1;

		class ModuleDescription : ModuleDescription
		{
			description = CSTRING(moduleFillHouse_description);
		};
	};
};
