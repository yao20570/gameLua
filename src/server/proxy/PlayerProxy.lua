-------------
----角色处理代理
-------------
module("server", package.seeall)

PlayerProxy = class("PlayerProxy", BasicProxy)

function PlayerProxy:ctor(actorInfo)
    self._attrInfoMap = {}
    self:setPlayerPowerValue(actorInfo.attrInfos)
end

function PlayerProxy:getPlayerPowerValue(power)
	return self._attrInfoMap[power] or 0
end

function PlayerProxy:getPowerValue(power)
    return self:getPlayerPowerValue(power)
end

function PlayerProxy:getAllPowerValue()
    local map = {}
    for power, value in pairs(self._attrInfoMap) do
    	map[power] = value
    end
    return map
end

function PlayerProxy:reducePowerValue(power, reduce)
	local value = self:getPowerValue(power)

	reduce = math.abs(reduce)

	if value < reduce  then
		value = 0
	else
		value = value - reduce
	end
	self:setPowerValue(power, value)
end

function PlayerProxy:addPowerValue(power, add)
	local value = self:getPowerValue(power)
	if add < 0 then
		add = 0
	end
	value = value + add

	--TODO other hander
	self:setPowerValue(power, value)

end

function PlayerProxy:setPowerValue(power, value)
    self._attrInfoMap[power] =  value
end


----------------------------
function PlayerProxy:setPlayerPowerValue(attrInfos)
    for _, attrInfo in pairs(attrInfos) do
    	self:setPowerValue(attrInfo.typeid, attrInfo.value)
    end
end

function PlayerProxy:getAutoBuildState()
    return self._autoBuild
end

function PlayerProxy:setAutoBuildState(state)
    self._autoBuild = state
end
