GeneralAndSoldierProxy = class("GeneralAndSoldierProxy", BasicProxy)

function GeneralAndSoldierProxy:ctor()
    GeneralAndSoldierProxy.super.ctor(self)
    self.proxyName = GameProxys.GeneralAndSoldier
    self.TheleagueConfig = require("excelConfig.TheleagueConfig")
    self.SynthesizeItemConfig = require("excelConfig.SynthesizeItemConfig")

    self.theleague = {}
end

function GeneralAndSoldierProxy:initSyncData(data)
	GeneralAndSoldierProxy.super.initSyncData(self, data)
	
    logger:info("init GeneralAndSoldierProxy================>天降神兵")
    self.theleague = data.theleague
end

-- 活动开启
function GeneralAndSoldierProxy:onTriggerNet230011Resp(data)    
    self:initSyncData(data)
end

function GeneralAndSoldierProxy:resetCountSyncData()
	-- for k,v in pairs(self.theleague) do
	-- 	local activityId = self.theleague[k].activityId
	-- 	local attr = self.theleague[k].attr
	-- 	local atype = attr.type
	-- 	self.theleague[k].free = 1
	-- end
	-- local redPoint = self:getProxy(GameProxys.RedPoint)
	-- redPoint:setSoldierRed()
end

function GeneralAndSoldierProxy:resetData()
	for k,v in pairs(self.theleague) do
		local activityId = self.theleague[k].activityId
		local attr = self.theleague[k].attr
		local atype = attr.type
		self.theleague[k].free = 1
	end
	local redPoint = self:getProxy(GameProxys.RedPoint)
	redPoint:setSoldierRed()
end

function GeneralAndSoldierProxy:getIsFree()
	for k,v in pairs(self.theleague) do
		if v.activityId == self.curActivityData.activityId then
			return v.free
		end
	end
	return 0
end

function GeneralAndSoldierProxy:usefree()
	for k,v in pairs(self.theleague) do
		if v.activityId == self.curActivityData.activityId then
			self.theleague[k].free = self.theleague[k].free - 1
		end
	end

	local redPoint = self:getProxy(GameProxys.RedPoint)
	redPoint:setSoldierRed()
end

function GeneralAndSoldierProxy:updateWithRecruit(data)
	if data.rs == 0 then
		local attr = data.attr 
		for k,v in pairs(self.theleague) do
			if v.activityId == self.activityId then
				for a,b in pairs(v.attr) do
					for c,d in pairs(attr) do
						if d.type == b.type then
							self.theleague[k].attr[a].value = d.value
						end
					end
				end
			end
		end
	end
end

function GeneralAndSoldierProxy:updateWithTrain(data)
	if data.rs == 0 then
		data.attr = {data.attr}
		self:updateWithRecruit(data)
	end
end

function GeneralAndSoldierProxy:updateCurActivityData()
	local proxy = self:getProxy(GameProxys.Activity)
	self.activityId = proxy.curActivityData.activityId
	self.curActivityData = proxy.curActivityData
end

function GeneralAndSoldierProxy:getLimitTimeStr()
	-- local str1 = TimeUtils:setTimestampToString(self.curActivityData.startTime)
	-- local str2 = TimeUtils:setTimestampToString(self.curActivityData.endTime)
	-- local str = str1.." - "..str2
	local str = TimeUtils.getLimitActFormatTimeString(self.curActivityData.startTime,self.curActivityData.endTime)
	return str
end

function GeneralAndSoldierProxy:getSuipianInfos()
	local effectId = self.curActivityData.effectId
	local compositionID
	for _, v in pairs(self.TheleagueConfig) do
		if v.effectgroup == effectId then
			compositionID = v.compositionID
		end
	end
	local tb = {}
	local roleProxy = self:getProxy(GameProxys.Role)
	for i = 1, #self.SynthesizeItemConfig do
		if self.SynthesizeItemConfig[i].effectgroup == compositionID then
			local needNum1 = self.SynthesizeItemConfig[i].expend
			local data2 = StringUtils:jsonDecode(self.SynthesizeItemConfig[i].synthesis)
			local info = ConfigDataManager:getConfigByPowerAndID(data2[1][1],data2[1][2])
			local currentNum1  = 0
			for k,v in pairs(self.theleague) do
				if v.activityId == self.activityId then
					for a, b in pairs(v.attr) do
						if b.type == self.SynthesizeItemConfig[i].pietype then
							currentNum1 = b.value
						end
					end
				end
			end
			table.insert(tb, {currentNum = currentNum1, needNum = needNum1, name = info.name,
				icon = info.icon,
				typeid = info.ID,
				ID = self.SynthesizeItemConfig[i].ID})
		end		
	end
	return tb
end

function GeneralAndSoldierProxy:getPrice( )
	local effectId = self.curActivityData.effectId
	for k,v in pairs(self.TheleagueConfig) do
		if v.effectgroup == effectId then
			return v.price, v.tenprice
		end
	end
end

function GeneralAndSoldierProxy:onTriggerNet230025Req(ID)
	local data = {}
	data.activityId = self.curActivityData.activityId
	data.id = ID
	self:syncNetReq(AppEvent.NET_M23, AppEvent.NET_M23_C230025, data)
end


function GeneralAndSoldierProxy:onTriggerNet230024Req(times)
	local data = {}
	data.activityId = self.curActivityData.activityId
	data.times = times
	self:syncNetReq(AppEvent.NET_M23, AppEvent.NET_M23_C230024, data)
end

function GeneralAndSoldierProxy:getAllRedPoint()
	local num = 0
	self.theleague = self.theleague or {}
	local redPoint = self:getProxy(GameProxys.RedPoint)
	for k,v in pairs(self.theleague) do
		num = num + v.free
		redPoint:setRedPoint(v.activityId, v.free)
	end
	return num
end