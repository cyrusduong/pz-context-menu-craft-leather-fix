require("TimedActions/ISBaseTimedAction")

ISDryLeatherAction = ISBaseTimedAction:derive("ISDryLeatherAction")

function ISDryLeatherAction:isValid()
	return self.character:getInventory():contains(self.wetLeather)
end

function ISDryLeatherAction:update()
	self.character:faceLocation(self.rack:getX(), self.rack:getY())
end

function ISDryLeatherAction:start()
	self:setActionAnim("Loot")
end

function ISDryLeatherAction:stop()
	ISBaseTimedAction.stop(self)
end

function ISDryLeatherAction:perform()
	local inventory = self.character:getInventory()

	-- Remove wet leather
	inventory:Remove(self.wetLeather)

	-- Add dried leather
	local driedItem = inventory:AddItem(self.outputType)

	-- Sync for MP
	if sendAddItemToContainer then
		sendAddItemToContainer(inventory, driedItem)
	end

	-- Show feedback
	if HaloTextHelper then
		HaloTextHelper.addText(self.character, "Finished drying " .. self.wetLeather:getDisplayName(), HaloTextHelper.getGoodColor())
	end

	-- Needed for action queue
	ISBaseTimedAction.perform(self)
end

function ISDryLeatherAction:new(character, wetLeather, outputType, rack, time)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o.character = character
	o.wetLeather = wetLeather
	o.outputType = outputType
	o.rack = rack
	o.stopOnWalk = true
	o.stopOnRun = true
	o.maxTime = time
	if character:isTimedActionInstant() then
		o.maxTime = 1
	end
	return o
end
