module("server", package.seeall)

SoldierProxy = class("SoldierProxy", BasicProxy)

function SoldierProxy:ctor(soldierList)
	self._soldiers = {}
	self:initSoldiers(soldierList)
end

function SoldierProxy:initSoldiers(soldierList)
	for _,soldierInfo in pairs(soldierList) do
		self:addSoldierNum(soldierInfo.typeid, soldierInfo.num)
		local soldier = self:getSoldierByTypeId(soldierInfo.typeid)
		soldier.attack = soldierInfo.attack
		soldier.hp = soldierInfo.hp
		soldier.powerList = soldierInfo.powerList
	end
end

function SoldierProxy:updateSoldiers(soldierList)
    for _,soldierInfo in pairs(soldierList) do
        local soldier = self:getSoldierByTypeId(soldierInfo.typeid)
        if soldier == nil then
            self:addSoldierNum(soldierInfo.typeid, soldierInfo.num)
            soldier = self:getSoldierByTypeId(soldierInfo.typeid)
        end
        soldier.attack = soldierInfo.attack
        soldier.hp = soldierInfo.hp
        soldier.powerList = soldierInfo.powerList
    end
end

function SoldierProxy:getSoldierByTypeId(typeId)
    return self._soldiers[typeId]
end

function SoldierProxy:addSoldierNum(typeId, num)
	local soldier = self:getSoldierByTypeId(typeId)
	if soldier == nil then
		self:createSoldier(typeId, num)
	else
		soldier.num = soldier.num + num
	end
end

function SoldierProxy:reduceSoldierNum(typeId, num, lostNum)
	if num < 0 then
		num = -num
	end
	local soldier = self:getSoldierByTypeId(typeId)
	if soldier == nil then
		return 0
	end

	if num == 0 and lostNum == 0 then
		return typeId
	end
	local _num = soldier.num
	if num > _num then
		num = _num
	end
	soldier.num = _num - num

	return typeId
end

-- 创建佣兵
function SoldierProxy:createSoldier(typeId, num)
	local soldier = Soldier.new()
	soldier.typeId = typeId
	soldier.num = num

	self._soldiers[typeId] = soldier

	return soldier
end

--获取佣兵数量
function SoldierProxy:getSoldierNum(typeId)
	local soldier = self:getSoldierByTypeId(typeId)
	if soldier == nil then
		return 0
	end
	return soldier.num
end

function SoldierProxy:getSoldierInfoByTypeId(typeId)
    local soldier = self:getSoldierByTypeId(typeId)
    return self:getSoldierInfo(soldier)
end

function SoldierProxy:getSoldierInfo(soldier)
    local builder = {}
    builder.powerList = soldier.powerList
    builder.num = soldier.num
    builder.typeid = soldier.typeId
    builder.attack = soldier.attack
    builder.hp = soldier.hp

    return builder

    -- for i=SoldierDefine.POWER_hpMax, SoldierDefine.TOTAL_FIGHT_POWER do
    --     -- if i == SoldierDefine.POWER_hp or SoldierDefine.POWER_hpMax == i then
    --     -- 	local hp = self:getPowerValue(SoldierDefine.POWER_hp, soldier)
    --     -- 	table.insert(builder.powerList, hp)
    --     -- elseif i == SoldierDefine.POWER_load  then
    --     -- 	local load = self:getPowerValue()
    --     -- end
    --     table.insert(builder.powerList, self:getPowerValue(i, soldier)) --直接拿服务端的数据
    -- end

end

function SoldierProxy:getSoldierPowerValue(powerName, soldier)
    return soldier[powerName]
end

function SoldierProxy:getPowerValueByTypeId(power, soldierId)
    local soldier = self:getSoldierByTypeId(soldierId)
    return self:getPowerValue(soldier)
end

function SoldierProxy:getPowerValue(power, soldier)
    local powerName = SoldierDefine:getPowerName(power)
    if powerName == nil then
    	return 0
    end
    return self:getSoldierPowerValue(powerName, soldier)
end