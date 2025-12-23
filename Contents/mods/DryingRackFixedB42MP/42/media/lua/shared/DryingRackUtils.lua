 -- Shared utilities for all drying racks
 
 DryingRackUtils = {}
 
 ---@param entity IsoObject
 ---@return string category, string size
function DryingRackUtils.getRackInfo(entity)
	local entityFullType = ""
	if entity.getEntity and entity:getEntity() then
		local entityObj = entity:getEntity()
		if entityObj.getFullType then
			entityFullType = entityObj:getFullType()
		elseif entityObj.getEntityFullTypeDebug then
			entityFullType = entityObj:getEntityFullTypeDebug()
		end
	end

	local name = ""
	if entity.getName then
		name = entity:getName() or ""
	end

	local spriteName = ""
	if entity.getSpriteName then
		spriteName = entity:getSpriteName() or ""
	elseif entity.getSprite then
		local sprite = entity:getSprite()
		if sprite and sprite.getName then
			spriteName = sprite:getName() or ""
		elseif sprite and sprite.getSprite then
			spriteName = sprite:getSprite() or ""
		end
	end

	print("[DryingRackUtils.getRackInfo] entityFullType=" .. entityFullType .. ", name=" .. name .. ", spriteName=" .. spriteName)
 
	-- Match on entity types first (most reliable) - normalizing by removing spaces
	local typeNormalized = entityFullType:gsub("%s+", "")
	local nameNormalized = name:gsub("%s+", "")
	local spriteNormalized = spriteName:gsub("%s+", "")
 
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
 
 	-- Plant Racks based on exact entity name
 	if typeNormalized == "Base.Simple_Herb_Drying_Rack" then
 		return "plant", "small"
 	elseif typeNormalized == "Base.Herb_Drying_Rack" then
 		return "plant", "small"
 	elseif typeNormalized == "Base.Simple_Drying_Rack" then
 		return "plant", "large"
 	elseif typeNormalized == "Base.Drying_Rack" then
 		return "plant", "large"
 	end
 
	-- Fallback: Match on sprite index from texture atlas
	-- These are sprite indices in the vegetation_drying_01 texture
	--
	-- Tile patterns (observed from game):
	-- Small racks (herbs): 8, 9, 224, 225, 236
	-- Large racks (wheat/barley/rye): 20, 21, 22, 23, 237, 238, 239
	local prefix = ""
	if nameNormalized:find("vegetation_drying_01_") then
		prefix = nameNormalized:match("vegetation_drying_01_(%d+)")
	end

	print("[DryingRackUtils.getRackInfo] prefix=" .. tostring(prefix))
	-- Match based on name patterns first
 	if nameNormalized:find("Simple_Herb_Drying_Rack") then
 		return "plant", "small"
 	elseif nameNormalized:find("Herb_Drying_Rack") then
 		return "plant", "small"
 	elseif nameNormalized:find("Simple_Drying_Rack") then
 		return "plant", "large"
 	elseif nameNormalized:find("^Drying_Rack:") then
 		return "plant", "large"
	elseif nameNormalized:find("Drying_Rack") and nameNormalized:find("vegetation_drying") then
		-- Vanilla plant racks: match based on tile prefix
		-- Small racks (herbs): 8, 9, 224, 225, 236
		-- Large racks (wheat/barley/rye): 20, 21, 22, 23, 237, 238, 239
		local tileNum = tonumber(prefix)
		if tileNum and (tileNum == 8 or tileNum == 9 or tileNum == 224 or tileNum == 225 or tileNum == 236) then
			return "plant", "small"
		elseif tileNum then
			return "plant", "large"
		end
	end

	-- Match on sprite name for vanilla plant racks (fallback when entity name is empty)
	if spriteNormalized:find("vegetation_drying_01_") then
		local spritePrefix = spriteNormalized:match("vegetation_drying_01_(%d+)")
		print("[DryingRackUtils.getRackInfo] spritePrefix=" .. tostring(spritePrefix))
		local tileNum = tonumber(spritePrefix)
		if tileNum and (tileNum == 8 or tileNum == 9 or tileNum == 224 or tileNum == 225 or tileNum == 236) then
			return "plant", "small"
		elseif tileNum then
			return "plant", "large"
		end
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
 