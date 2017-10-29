-------------
----VIP相关处理代理
-------------

module("server", package.seeall)

VipProxy = class("VipProxy", BasicProxy)


--VIP特权次数
function VipProxy:getVipNum(str)
	local vipInfo = ConfigDataManager:getInfoFindByOneKey(ConfigData.VipDataConfig, "level", self:getVipLevel())
	if vipInfo ~= nil then
		return vipInfo[str]
	else
		return 0
	end
end

--获取当前VIP等级
function VipProxy:getVipLevel()
	local playerProxy = self:getProxy(ActorDefine.PLAYER_PROXY_NAME)
	return playerProxy:getPowerValue(PlayerPowerDefine.POWER_vipLevel)
end

--返回VIP最大等级
function VipProxy:getMaxVIPLv()
	if self._maxVippLv ~= nil then
		return self._maxVippLv
	end

	local vipAllInfo = ConfigDataManager:getConfigData(ConfigData.VipDataConfig)
	local level = 0
	for _, info in pairs(vipAllInfo) do
		if level < info.level then
			level = info.level
		end
	end
	self._maxVippLv = level
	return level
end
