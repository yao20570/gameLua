module("server", package.seeall)

RewardProxy = class("RewardProxy", BasicProxy)

function RewardProxy:addItemToReward(reward, rewardInfo, num)
	if reward.addItemMap[rewardInfo] ~= nil then
		local _num = reward.addItemMap[rewardInfo]
		reward.addItemMap[rewardInfo] = num + _num
	else
		reward.addItemMap[rewardInfo] = num
	end
end

function RewardProxy:addSoldierToReward(reward, rewardInfo, num)
	if reward.soldierMap[rewardInfo] ~= nil then
		local _num = reward.soldierMap[rewardInfo]
		reward.soldierMap[rewardInfo] = num + _num
	else
		reward.soldierMap[rewardInfo] = num
	end
end

-- M2.M20007.S2C 
--TODO暂时处理 item
function RewardProxy:getRewardClientInfo(reward)
    local builder = {}
    builder.itemList = {}
    builder.soldierList = {}
    builder.equipinfos = {}
    builder.odpInfos = {}
    builder.odInfos = {}
    
    local itemProxy = self:getProxy(ActorDefine.ITEM_PROXY_NAME)
    for typeId, num in pairs(reward.addItemMap) do
    	local info = itemProxy:getItemInfo(typeId)
    	table.insert(builder.itemList, info)
    end

    local soldierProxy = self:getProxy(ActorDefine.SOLDIER_PROXY_NAME)
    for typeId, num in pairs(reward.soldierMap) do
    	local info = soldierProxy:getSoldierInfoByTypeId(typeId)
    	table.insert(builder.soldierList, info)
    end
    

    return builder
end