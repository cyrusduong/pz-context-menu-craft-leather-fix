---@meta
---@meta

-- Import Umbrella types for Project Zomboid API
require("ISUI/ISContextMenu")
require("LeatherDryingRackData")
require("TimedActions/ISDryLeatherAction")

---@class ISLeatherDryingRackMenu
ISLeatherDryingRackMenu = {}

-- Determine rack type based on entity name
---@param entity IsoObject
---@return string rackType
function ISLeatherDryingRackMenu.getRackType(entity)
	return LeatherDryingRackUtils.getRackType(entity)
end

-- Get compatible leather sizes for rack type
---@param rackType string
---@return table compatibleSizes
function ISLeatherDryingRackMenu.getCompatibleSizes(rackType)
	return LeatherDryingRackUtils.getCompatibleSizes(rackType)
end

-- Check if player is within interaction distance of rack
---@param player IsoPlayer
---@param rack IsoObject
---@return boolean isNear
function ISLeatherDryingRackMenu.isPlayerNearRack(player, rack)
	return LeatherDryingRackUtils.isPlayerNearRack(player, rack)
end

-- Get wet leather items from player inventory
---@param player IsoPlayer
---@return table wetLeatherItems
function ISLeatherDryingRackMenu.getWetLeatherItems(player)
	return LeatherDryingRackUtils.getWetLeatherItems(player)
end

-- Perform leather drying (via TimedAction)
---@param player IsoPlayer
---@param wetLeatherData table
---@param rack IsoObject
function ISLeatherDryingRackMenu.dryLeather(player, wetLeatherData, rack)
	if luautils.walkAdj(player, rack:getSquare()) then
		ISTimedActionQueue.add(
			ISDryLeatherAction:new(player, wetLeatherData.item, wetLeatherData.outputType, rack, 100)
		)
	end
end

-- Dry all compatible leather in inventory
---@param player IsoPlayer
---@param compatibleLeathers table
---@param rack IsoObject
function ISLeatherDryingRackMenu.dryAll(player, compatibleLeathers, rack)
	if luautils.walkAdj(player, rack:getSquare()) then
		for _, leatherData in ipairs(compatibleLeathers) do
			ISTimedActionQueue.add(ISDryLeatherAction:new(player, leatherData.item, leatherData.outputType, rack, 100))
		end
	end
end

-- Main context menu handler
---@param player number
---@param context ISContextMenu
---@param worldobjects table
---@param test boolean
function ISLeatherDryingRackMenu.OnFillWorldObjectContextMenu(player, context, worldobjects, test)
	if test and ISWorldObjectContextMenu.Test then
		return true
	end

	local playerObj = getSpecificPlayer(player)
	if not playerObj then
		return
	end

	if playerObj:getVehicle() then
		return false
	end

	-- Find drying rack objects first to avoid spamming on every click
	local dryingRacks = {}
	local seenSquares = {}
	local seenSizes = {}
	
	if #worldobjects > 0 then
		for i = 1, #worldobjects do
			local rootObj = worldobjects[i]
			local square = rootObj.getSquare and rootObj:getSquare()
			if square then
				local sqKey = square:getX() .. "," .. square:getY() .. "," .. square:getZ()
				if not seenSquares[sqKey] then
					seenSquares[sqKey] = true
					local sqObjs = square:getObjects()
					if sqObjs then
						for j = 0, sqObjs:size() - 1 do
							local obj = sqObjs:get(j)
							local entityObj = obj.getEntity and obj:getEntity()
							local entityName = "NONE"
							if entityObj then
								if entityObj.getFullType then
									entityName = entityObj:getFullType()
								elseif entityObj.getEntityFullTypeDebug then
									entityName = entityObj:getEntityFullTypeDebug()
								end
							end
							
							local name = obj:getName() or "UNNAMED"
							local spriteName = (obj:getSprite() and obj:getSprite():getName()) or "NO_SPRITE"
							
							-- Match against any variation of DryingRack
							local isMatch = false
							if string.find(entityName, "DryingRack") 
								or string.find(entityName, "Drying_Rack")
								or string.find(name, "DryingRack")
								or string.find(name, "Drying_Rack")
								or string.find(name, "Drying Rack")
								or string.find(spriteName, "drying_rack")
								or string.find(spriteName, "crafted_05") -- B42 crafted rack sprite range
							then
								isMatch = true
							end

							if isMatch then
								local rackType = ISLeatherDryingRackMenu.getRackType(obj)
								if not seenSizes[rackType] then
									seenSizes[rackType] = true
									table.insert(dryingRacks, obj)
								end
							end
						end
					end
				end
			end
		end
	end

	-- If no racks found, exit silently
	if #dryingRacks == 0 then
		return
	end

	-- Now that we know we clicked a rack, check for leather
	local wetLeatherItems = ISLeatherDryingRackMenu.getWetLeatherItems(playerObj)

	if #wetLeatherItems == 0 then
		if HaloTextHelper then
			HaloTextHelper.addText(playerObj, "I need wet leather to use this rack.", HaloTextHelper.getBadColor())
		end
		return
	end

	-- Process each drying rack
	for _, rack in ipairs(dryingRacks) do
		-- Use a slightly larger distance for the context menu to appear, 
		-- the TimedAction will handle walking to the exact spot.
		if ISLeatherDryingRackMenu.isPlayerNearRack(playerObj, rack) then
			local rackType = ISLeatherDryingRackMenu.getRackType(rack)
			local rackLabel = rackType:gsub("^%l", string.upper) -- capitalize
			local compatibleSizes = ISLeatherDryingRackMenu.getCompatibleSizes(rackType)
			
			-- Create main option for this rack
			local rackOption = context:addOptionOnTop("Dry Leather on " .. rackLabel .. " Rack", worldobjects, nil)
			local subMenu = ISContextMenu:getNew(context)
			context:addSubMenu(rackOption, subMenu)
			
			local compatibleLeathers = {}
			local incompatibleLeathers = {}

			-- Sort leathers by compatibility
			for _, leatherData in ipairs(wetLeatherItems) do
				if compatibleSizes[leatherData.size] then
					table.insert(compatibleLeathers, leatherData)
				else
					table.insert(incompatibleLeathers, leatherData)
				end
			end
			
			-- Add "Dry All" if multiple compatible items
			if #compatibleLeathers > 1 then
				subMenu:addOption(
					"Dry All (" .. #compatibleLeathers .. ")",
					playerObj,
					ISLeatherDryingRackMenu.dryAll,
					compatibleLeathers,
					rack
				)
			end

			-- Add compatible leather options
			for _, leatherData in ipairs(compatibleLeathers) do
				local option = subMenu:addOption(
					"Dry " .. leatherData.item:getDisplayName(),
					playerObj,
					ISLeatherDryingRackMenu.dryLeather,
					leatherData,
					rack
				)

				-- Add tooltip with leather info
				option.toolTip = ISWorldObjectContextMenu.addToolTip()
				option.toolTip:setName("Dry Leather")
				option.toolTip.description = "Transforms wet furred leather into dried leather using this drying rack. <LINE> Output: "
					.. leatherData.item:getDisplayName():gsub("Wet", "Dried")
			end

			-- Add disabled options for incompatible leathers
			for _, leatherData in ipairs(incompatibleLeathers) do
				local option =
					subMenu:addOption("Dry " .. leatherData.item:getDisplayName() .. " (Rack too small)", rack, nil)
				option.notAvailable = true
				option.toolTip = ISWorldObjectContextMenu.addToolTip()
				option.toolTip:setName("Rack Too Small")
				option.toolTip.description = "This leather requires a "
					.. leatherData.size
					.. " drying rack, but this is a "
					.. rackType
					.. " rack."
			end
		end
	end
end

-- Register to event handler
if Events and Events.OnFillWorldObjectContextMenu then
	Events.OnFillWorldObjectContextMenu.Add(ISLeatherDryingRackMenu.OnFillWorldObjectContextMenu)
end
