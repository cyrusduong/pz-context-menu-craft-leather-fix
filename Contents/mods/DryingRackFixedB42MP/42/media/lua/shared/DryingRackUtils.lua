 -- Shared utilities for all drying racks
 
 DryingRackUtils = {}
 
 ---@param entity IsoObject
 ---@return string category, string size
function DryingRackUtils.getRackInfo(entity)
	local entityFullType = ""
	if entity.getEntity and entity:getEntity() then
		local entityObj = entity:getEntity()
		if entityObj.getEntityFullTypeDebug then
			entityFullType = entityObj:getEntityFullTypeDebug()
		elseif entityObj.getFullType then
			entityFullType = entityObj:getFullType()
		end
	end

	local displayName = ""
	if entity.getEntity and entity:getEntity() then
		local entityObj = entity:getEntity()
		if entityObj.getDisplayName then
			displayName = entityObj:getDisplayName() or ""
		end
	end

	local name = ""
	if entity.getName then
		name = entity:getName() or ""
	end

	print("[DryingRackUtils.getRackInfo] entityFullType=" .. entityFullType .. ", displayName=" .. displayName .. ", name=" .. name)
 
	-- Match on entity types first (most reliable) - normalizing by removing spaces
	local typeNormalized = entityFullType:gsub("%s+", "")
	local nameNormalized = name:gsub("%s+", "")
	local displayNameNormalized = displayName:gsub("%s+", "")

	-- Leather Racks
	if
		typeNormalized == "Base.ES_DryingRackSmall"
		or typeNormalized == "Base.DryingRackSmall"
		or nameNormalized == "DryingRackSmall"
		then
		return "leather", "small"
	elseif
		typeNormalized == "Base.ES_DryingRackMedium"
		or typeNormalized == "Base.DryingRackMedium"
		or nameNormalized == "DryingRackMedium"
		then
		return "leather", "medium"
	elseif
		typeNormalized == "Base.ES_DryingRackLarge"
		or typeNormalized == "Base.DryingRackLarge"
		or nameNormalized == "DryingRackLarge"
		then
		return "leather", "large"
	end

	-- Plant Racks based on entity type or display name
	if typeNormalized == "Base.Simple_Herb_Drying_Rack" or displayNameNormalized:find("SimpleSmallPlantDryingRack") then
		return "plant", "small"
	elseif typeNormalized == "Base.Herb_Drying_Rack" or displayNameNormalized:find("SmallPlantDryingRack") then
		return "plant", "small"
	elseif typeNormalized == "Base.Simple_Drying_Rack" or displayNameNormalized:find("SimpleLargePlantDryingRack") then
		return "plant", "large"
	elseif typeNormalized == "Base.Drying_Rack" or displayNameNormalized:find("LargePlantDryingRack") then
		return "plant", "large"
	end

	return "unknown", "unknown"
 end
 
 ---@param category string
 ---@param size string
 ---@return string
 function DryingRackUtils.getDisplayName(category, size)
 	local sizeStr = size:gsub("^%l", string.upper)
 	if category == "leather" then
 		return sizeStr .. " Drying Rack"
 	elseif category == "plant" then
 		if size == "large" then
 			return "Large Herb Drying Rack"
 		else
 			return "Herb Drying Rack"
 		end
 	end
 	return "Drying Rack"
 end
 
 ---@param player IsoPlayer
 ---@param rack IsoObject
 ---@return boolean
 function DryingRackUtils.isPlayerNearRack(player, rack)
 	if not player or not rack then
 		return false
 	end
 	local playerSquare = player:getCurrentSquare()
 	local rackSquare = rack:getSquare()
 	if not playerSquare or not rackSquare then
 		return false
 	end
 
 	local dist =
 		IsoUtils.DistanceTo(playerSquare:getX(), playerSquare:getY(), rackSquare:getX() + 0.5, rackSquare:getY() + 0.5)
 	return dist <= 3.0
 end
 