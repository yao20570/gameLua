PopularSupportProxy = class("PopularSupportProxy", BasicProxy)

function PopularSupportProxy:ctor()
    PopularSupportProxy.super.ctor(self)
    self.proxyName = GameProxys.PopularSupport
end

function PopularSupportProxy:initSyncData(data)
	PopularSupportProxy.super.initSyncData(self, data)
	self.supportReward = data.supportReward
	self.refreshTimes = data.actorInfo.supportRefresh
end

function PopularSupportProxy:resetCountSyncData()
	self.refreshTimes = 0
	local roleProxy = self:getProxy(GameProxys.Role)
	local maxSupport = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_supportLimit)
	local currentSupport = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_support)
	if maxSupport < currentSupport then
		maxSupport = currentSupport
	end
	roleProxy:setRoleAttrValue(PlayerPowerDefine.POWER_support, maxSupport)
end

function PopularSupportProxy:getRefreshTimes()
	local playerProxy = self:getProxy(GameProxys.Role)
	local militaryRank = playerProxy:getRoleAttrValue(PlayerPowerDefine.POWER_militaryRank)
 	local info = ConfigDataManager:getConfigById(ConfigData.PopularsupportConfig, militaryRank)
 	local resource = StringUtils:jsonDecode(info.resource)
 	local strArr = {}
 	for k,v in pairs(resource) do
 		local resourceInfo = ConfigDataManager:getConfigByPowerAndID(v[1],v[2])
 		strArr[k] = resourceInfo.name
 	end
	local str = string.format(TextWords:getTextWord(70101),resource[1][3],strArr[1])
	return info.freetime - self.refreshTimes, info.price,str
end

function PopularSupportProxy:getInfos()
	return self.supportReward
end

function PopularSupportProxy:addRefreshTimes()
	self.refreshTimes = self.refreshTimes + 1
end

function PopularSupportProxy:updateSupportReward(supportRewards)
	self.supportReward = supportRewards
end

function PopularSupportProxy:updateSupportGetReward(supportReward,id)
	local index
	for k,v in pairs(self.supportReward) do
		if v.id == id then
			index = k
			self._index = k
		end
	end
	table.remove(self.supportReward, index)
	table.insert(self.supportReward, index,supportReward)
end

function PopularSupportProxy:getIndex()
	return self._index
end

function PopularSupportProxy:onTriggerNet20600Req()
	self:syncNetReq(AppEvent.NET_M2, AppEvent.NET_M2_C20600, {})
end

function PopularSupportProxy:onTriggerNet20601Req(id)
	local data = {}
	data.id = id 
	self:syncNetReq(AppEvent.NET_M2, AppEvent.NET_M2_C20601, data)
end