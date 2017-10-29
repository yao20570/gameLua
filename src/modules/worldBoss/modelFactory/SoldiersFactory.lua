--
-- Author: zlf
-- Date: 2016年8月25日13:00:13
-- 佣兵工厂
SoldiersFactory = class("SoldiersFactory")

local percent = 0.3

function SoldiersFactory:create(parent, icon)
	local ret = SoldiersFactory.new()
	ret:init(parent, icon)
	return ret
end

function SoldiersFactory:destory()
	for k,v in pairs(self.modelQueue) do
		v:finalize()
	end
	self.modelQueue = {}
end

function SoldiersFactory:init(parent, icon)
	local config = ConfigDataManager:getConfigById(ConfigData.ModelGroConfig, icon)
	local queueCount = config.num
	self.modelQueue = {}
	self.center = 0
	for i=1,queueCount do
		local posInfo = ConfigDataManager:getInfoFindByTwoKey(ConfigData.ZhenfaConfig, "type", config.formationID, "eye", i)
		local model = SpineModel.new(icon, parent)
		local size = model:getContentSize()
		local y = posInfo.y
		local x = posInfo.x
		model.y = y
		model.x = x
		self.center = x + self.center
		model:setPosition(x, y)
		model:setDirection(-1)
		self.modelQueue[i] = model
	end
	self.center = self.center / queueCount
end

function SoldiersFactory:getNeedPos(queueCount, pos, size)
	local rated = 360/(queueCount - 1)
	local angle = pos * rated
	local y = math.cos(math.rad(angle)) * size.height * percent
	local x = math.sin(math.rad(angle)) * size.width * percent
	return x, y
end

function SoldiersFactory:runAction(name, isLoop, callbak, obj)
	for k,v in pairs(self.modelQueue) do
		v:playAnimation(name, isLoop, callbak, obj)
	end
end

function SoldiersFactory:getMaxHeight()
	local maxY = 0
	for k,v in pairs(self.modelQueue) do
		maxY = maxY < v.y and v.y or maxY
	end
	return self.modelQueue[1]:getContentSize().height + maxY
end

function SoldiersFactory:getMaxWidth()
	local maxX = 0
	for k,v in pairs(self.modelQueue) do
		maxX = maxX < v.x and v.x or maxX
	end
	return self.modelQueue[1]:getContentSize().width + maxX
end

function SoldiersFactory:getMinHeight()
	local minY = 0
	for k,v in pairs(self.modelQueue) do
		minY = minY > v.y and v.y or minY
	end
	return minY
end

function SoldiersFactory:getPosX()
	return self.center
end

function SoldiersFactory:getSize()
	return self.modelQueue[1]:getContentSize()
end