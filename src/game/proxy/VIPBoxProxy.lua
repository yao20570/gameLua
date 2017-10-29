VIPBoxProxy = class("VIPBoxProxy", BasicProxy)

function VIPBoxProxy:ctor()
    VIPBoxProxy.super.ctor(self)
    self.proxyName = GameProxys.VIPBox
    self.vipBoxTimesInfo = {}
end

function VIPBoxProxy:initSyncData(data)
	VIPBoxProxy.super.initSyncData(self, data)

    logger:info("init VIPBoxProxy================>vip宝箱活动信息")
    self.vipBoxTimesInfo = data.vipBoxTimesInfo
end

-- 活动开启
function VIPBoxProxy:onTriggerNet230011Resp(data)    
    self:initSyncData(data)
end

function VIPBoxProxy:resetCountSyncData()
	for k, v in pairs(self.vipBoxTimesInfo) do
		print("v.boxType===",v.boxType)
		self.vipBoxTimesInfo[k].boxTimes = 0 
	end
	self:sendNotification(AppEvent.PROXY_UPDATE_VIPBOXVIEW, {})
end

function VIPBoxProxy:updateTimes(vipBoxInfo)
	local activityId = vipBoxInfo.activityId
	local boxType = vipBoxInfo.boxType
	for k,v in pairs(self.vipBoxTimesInfo) do
		if v.activityId == activityId and v.boxType == boxType then
			self.vipBoxTimesInfo[k].boxTimes = vipBoxInfo.boxTimes
		end
	end
end

function VIPBoxProxy:onTriggerNet230014Resp(data)
	if data.rs == 0 then
		self:updateTimes(data.vipBoxInfo)
		self:sendNotification(AppEvent.PROXY_UPDATE_VIPBOXVIEW, {})
	end
end

function VIPBoxProxy:onTriggerNet230014Req(data)
	self:syncNetReq(AppEvent.NET_M23, AppEvent.NET_M23_C230014, data)
end


--------------------------------------------
function VIPBoxProxy:getActivityId()
	return self.curActivityData.activityId
end

function VIPBoxProxy:getVipLevel()
	local vipProxy = self:getProxy(GameProxys.Vip)
	local vipLevel = vipProxy:getVipLevel()
	return vipLevel
end

function VIPBoxProxy:getLimitTimeStr()
	-- local str1 = TimeUtils:setTimestampToString(self.curActivityData.startTime)
	-- local str2 = TimeUtils:setTimestampToString(self.curActivityData.endTime)
	-- local str = str1.." - "..str2
	local str = TimeUtils.getLimitActFormatTimeString(self.curActivityData.startTime,self.curActivityData.endTime)
	return str
end


function VIPBoxProxy:updateCurActivityData()
	local proxy = self:getProxy(GameProxys.Activity)
	self.activityId = proxy.curActivityData.activityId
	self.curActivityData = proxy.curActivityData
end

function VIPBoxProxy:getTimes(typeid)
    local effectId = self:getEffectId()
	local VipBoxLimitConfig = {}
    local config = ConfigDataManager:getConfigData("VipBoxLimitConfig")
    for k,v in pairs(config) do
        if effectId == v.effectgroup then
            table.insert(VipBoxLimitConfig, v)
        end
    end
	for _ ,v in pairs(self.vipBoxTimesInfo) do
		if v.activityId == self.curActivityData.activityId and v.boxType == typeid then
			local times 
			for _, e in pairs(VipBoxLimitConfig) do
				if e.type == typeid then
					local vipLv = self:getVipLevel()
					times = e["vip"..vipLv.."times"]
					return times - v.boxTimes
				end
			end
		end
	end
	return 0
end

function VIPBoxProxy:getEffectId()
	return self.curActivityData.effectId
end