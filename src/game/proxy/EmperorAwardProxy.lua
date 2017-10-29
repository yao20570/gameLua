-- 皇帝的封赏
EmperorAwardProxy = class("EmperorAwardProxy", BasicProxy)

function EmperorAwardProxy:ctor()
    EmperorAwardProxy.super.ctor(self)
    -- self.EmperorEnfeoffsConfig = require("excelConfig.EmperorEnfeoffsConfig")
    -- self.FixRewardConfig = require("excelConfig.FixRewardConfig")
    -- self.ChoiceRewardConfig = require("excelConfig.ChoiceRewardConfig")
    -- self.ChoiceContentConfig = require("excelConfig.ChoiceContentConfig")
    self.proxyName = GameProxys.EmperorAward
    self.chooseGetIDs = {}

    self.kindrewards = {}
end

function EmperorAwardProxy:initSyncData(data)
	EmperorAwardProxy.super.initSyncData(self, data)

    logger:info("init EmperorAwardProxy ================>皇帝的封赏")
    self.kindrewards = data.kindreward
	for k,v in pairs(self.kindrewards) do
		if _G.next(v.choiceInfo) then
			for a,b in pairs(v.choiceInfo) do
				self:setChooseGetIDs(b.choiceIds,b.id)
			end
		end	
	end
end

-- 活动开启
function EmperorAwardProxy:onTriggerNet230011Resp(data) 
    self:initSyncData(data)
end

function EmperorAwardProxy:resetCountSyncData()
	-- local roleProxy = self:getProxy(GameProxys.Role)
	-- roleProxy:setRoleAttrValue(PlayerPowerDefine.POWER_today_charge,0)
	-- self.chooseGetIDs = {}
	-- for k,v in pairs(self.kindrewards) do
	-- 	self.kindrewards[k] = {activityId = v.activityId,hasgetId = {},choiceInfo = {}}
	-- end
	-- self:onTriggerNet230023Resp({rs = 0})
    print("-----------------------------------resetCountSyncData-----------------------------")
    self:afterInitSyncData()
end

function EmperorAwardProxy:afterInitSyncData()
    self:addEventListener(AppEvent.PROXY_UPDATE_ROLE_INFO, self, self.updateRedRsp)
end

function EmperorAwardProxy:registerNetEvents()
end

function EmperorAwardProxy:unregisterNetEvents()
    -- self:unregisterNetEvent(AppEvent.NET_M2, AppEvent.NET_M2_C20200, self, self.onUpdateTipsResp)--所有小红点缓存
    self:removeEventListener(AppEvent.PROXY_UPDATE_ROLE_INFO, self, self.updateRedRsp)
end

--统一处理重置
function EmperorAwardProxy:resetData()

    local activityProxy = self:getProxy(GameProxys.Activity)

	local roleProxy = self:getProxy(GameProxys.Role)
	roleProxy:setRoleAttrValue(PlayerPowerDefine.POWER_today_charge,0)
	self.chooseGetIDs = {}
	for k,v in pairs(self.kindrewards) do
        local activityData = activityProxy:getLimitActivityInfoById(v.activityId)        
        if activityData.resetTime ~= 0 then
		    self.kindrewards[k] = {activityId = v.activityId,hasgetId = {},choiceInfo = {}}
        end
	end
	self:onTriggerNet230023Resp({rs = 0})
end

--设置已经领过的ID
function EmperorAwardProxy:setHasgetIds(id,choiceIds)
	for k, v in pairs(self.kindrewards) do
		if v.activityId == self.activityId then
			if not self.kindrewards[k].hasgetId then
				self.kindrewards[k].hasgetId = {}
			end
			table.insert(self.kindrewards[k].hasgetId,id)
			local choiceInfo = {}
			choiceInfo.id = id 
			choiceInfo.choiceIds = choiceIds
			if not self.kindrewards[k].choiceInfo then
				self.kindrewards[k].choiceInfo = {}
			end
			table.insert(self.kindrewards[k].choiceInfo,choiceInfo)
		end
	end
end

--获取已经领取过的ID
function EmperorAwardProxy:getHasgetIds()
	for k,v in pairs(self.kindrewards) do
		if v.activityId == self.activityId then
			return self.kindrewards[k].hasgetId or {}
		end
	end
	return {}
end

function EmperorAwardProxy:getChoiceIdsByid(id)
	for k,v in pairs(self.kindrewards) do
		if v.activityId == self.activityId then
			-- return self.kindrewards[k].hasgetId or {}
			for _, info in pairs(v.choiceInfo) do
				if info.id == id then
					return info.choiceIds
				end
			end
		end
	end
	return false
end

--获取活动时间
function EmperorAwardProxy:getAwardTime()
	-- local str1 = TimeUtils:setTimestampToString(self.curActivityData.startTime)
	-- local str2 = TimeUtils:setTimestampToString(self.curActivityData.endTime)
	-- local str = str1.." - "..str2
	local str = TimeUtils.getLimitActFormatTimeString(self.curActivityData.startTime,self.curActivityData.endTime,true)
	return str
end

--获取今日充值
function EmperorAwardProxy:getChargeValue()
	local roleProxy = self:getProxy(GameProxys.Role)
	local chargeValue = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_today_charge)
	return chargeValue
end

--获取vip等级
function EmperorAwardProxy:getVipLevel()
	local vipProxy = self:getProxy(GameProxys.Vip)
	local vipLevel = vipProxy:getVipLevel()
	return vipLevel
end

function EmperorAwardProxy:updateCurActivityData()
	local proxy = self:getProxy(GameProxys.Activity)
	self.activityId = proxy.curActivityData.activityId
	self.curActivityData = proxy.curActivityData
end

function EmperorAwardProxy:getCurActivityData()
	local proxy = self:getProxy(GameProxys.Activity)
	return self.curActivityData
end

function EmperorAwardProxy:getEffectId()
	return self.curActivityData.effectId 
end

function EmperorAwardProxy:getActivityId()
	return self.curActivityData.activityId
end

function EmperorAwardProxy:setChooseGetIDs(tb,index)
	if _G.next(tb) then
		self.chooseGetIDs[index] = tb 
	end
end

function EmperorAwardProxy:getChooseGetIDs(index)
	return self.chooseGetIDs[index]
end

function EmperorAwardProxy:getAllRedPoint()
	local num = 0
	local function isGetEd(data, id)
		local rs = false
		for k,v in pairs(data) do
			if v == id then
				return true
			end
		end
		return rs
	end

	local VipProxy = self:getProxy(GameProxys.VipRebate)
	local chargeNum = self:getChargeValue() or 0
	local redPoint = self:getProxy(GameProxys.RedPoint)

	local activityProxy = self:getProxy(GameProxys.Activity)
	local configs = ConfigDataManager:getConfigData(ConfigData.EmperorEnfeoffsConfig)

	local function getData(id)
		local allActivityInfo = activityProxy:getLimitActivityInfo()
		if allActivityInfo == nil then
			return
		end
		for k,v in pairs(allActivityInfo) do
			if v.activityId == id then
				return v
			end
		end
	end

	self.kindrewards = self.kindrewards or {}
	for _,v in pairs(self.kindrewards) do
		local onceNum = 0
		local activityData = getData(v.activityId)
		if activityData ~= nil then
			local effectid = activityData.effectId
			for k,config in pairs(configs) do
				if config.effectgroup == effectid then
					if chargeNum >= config.recharge and isGetEd(v.hasgetId, config.ID) == false then
						num = num + 1
						onceNum = onceNum + 1
					end
				end
			end
			redPoint:setRedPoint(v.activityId, onceNum)
		end
	end
	

	return num
end

function EmperorAwardProxy:onTriggerNet230023Resp(data)
	if data.rs == 0 then
		local redPoint = self:getProxy(GameProxys.RedPoint)
		redPoint:setEmperorRed()
		self:sendNotification(AppEvent.PROXY_UPDATE_EMPERPRAWARD)
	end
end

function EmperorAwardProxy:updateRedRsp()
	self:onTriggerNet230023Resp({rs = 0})
end