-- Plant/Herb type mappings for drying racks

require("DryingRackUtils")

DryingRackData_Plants = {
	small = {
		inputs = {
			"Base.Tobacco",
			"Base.Basil",
			"Base.Oregano",
			"Base.Rosemary",
			"Base.Sage",
			"Base.Thyme",
			"Base.MintHerb",
			"Base.BlackSage",
			"Base.Plantain",
		},
		outputs = {
			"Base.TobaccoDried",
			"Base.BasilDried",
			"Base.OreganoDried",
			"Base.RosemaryDried",
			"Base.SageDried",
			"Base.ThymeDried",
			"Base.MintHerbDried",
			"Base.BlackSageDried",
			"Base.PlantainDried",
		},
	},
	large = {
		inputs = {
			"Base.WheatSheaf",
			"Base.BarleySheaf",
			"Base.RyeSheaf",
			"Base.OatsSheaf",
			"Base.GrassTuft",
		},
		outputs = {
			"Base.WheatSheafDried",
			"Base.BarleySheafDried",
			"Base.RyeSheafDried",
			"Base.OatsSheafDried",
			"Base.HayTuft",
		},
	},
}

---@type table<string, DryingRackMapping>
DryingRackMapping_Plants = {}
for size, data in pairs(DryingRackData_Plants) do
	for i, input in ipairs(data.inputs) do
		local output = data.outputs[i]
		if output then
			DryingRackMapping_Plants[input] = {
				output = output,
				size = size,
			}
		end
	end
end
