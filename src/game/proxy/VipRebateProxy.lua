VipRebateProxy = class("VipRebateProxy", BasicProxy)

function VipRebateProxy:ctor()
    VipRebateProxy.super.ctor(self)
    self.proxyName = GameProxys.VipRebate
    self._vipRebateInfos = {}
end

function VipRebateProxy:initSyncData(data)
	VipRebateProxy.super.initSyncData(self, data)

    logger:info("init VipRebateProxy================>vip总动员信息")
    self._vipRebateInfos = data.vipgoInfoData
	for k,v in pairs(self._vipRebateInfos) do
		self.num = v.num
		self.allnum = v.allnum
	end
end

-- 活动开启
function VipRebateProxy:onTriggerNet230011Resp(data)
    self:initSyncData(data)
end

function VipRebateProxy:resetAttr()
	self._vipRebateInfos = {}
end
----每日凌晨四点重置
function VipRebateProxy:resetCountSyncData()
	-- self.num = 0
	-- for k,v in pairs(self._vipRebateInfos) do
	-- 	for i,j in pairs(v.vipgoinfo) do
	-- 		print(v.vipgoinfo[i].effctid)
	-- 		self._vipRebateInfos[k].vipgoinfo[i].isGet = 0
	-- 	end
	-- end
	-- self:sendNotification(AppEvent.PROXY_UPDATE_VIPREBATEVIEW, {})

	-- local redPoint = self:getProxy(GameProxys.RedPoint)
	-- redPoint:setVipRebateRed()
end

function VipRebateProxy:resetData()
	self.num = 0
	for k,v in pairs(self._vipRebateInfos) do
		for i,j in pairs(v.vipgoinfo) do
			print(v.vipgoinfo[i].effctid)
			self._vipRebateInfos[k].vipgoinfo[i].isGet = 0
		end
	end
	self:sendNotification(AppEvent.PROXY_UPDATE_VIPREBATEVIEW, {})

	local redPoint = self:getProxy(GameProxys.RedPoint)
	redPoint:setVipRebateRed()
end

----充值触发
function VipRebateProxy:onTriggerNet230020Resp(data)
	self.num = data.num
	self.allnum = data.allnum
	self:sendNotification(AppEvent.PROXY_UPDATE_VIPREBATEVIEW, {})
	local redProxy = self:getProxy(GameProxys.RedPoint)
	redProxy:setVipRebateRed()

	-- redProxy:setEmperorRed()
end

function VipRebateProxy:set230002Data(data)
	-- self.data = data
	-- self.startTime = data.startTime
	-- self.endTime = data.endTime
end

----活动领取
function VipRebateProxy:onTriggerNet230021Resp(data)
	if data.rs == 0 then
		local mark = true
		local index
		if data.info then
			local curData = nil
			for k,v in pairs(self._vipRebateInfos) do
				if v.activityid == self.curId then
					curData = v
					index = k
					break
				end
			end

			for k,v in pairs(curData.vipgoinfo) do
				if v.effctid == data.info.effctid then
					curData.vipgoinfo[k].isGet = data.info.isGet
					mark = false
				end
			end
		end 
		if data.allnumGet and mark then
			self._vipRebateInfos[index].allnumGet = data.allnumGet
		end
		local redProxy = self:getProxy(GameProxys.RedPoint)
		redProxy:setVipRebateRed()
	end
	self:sendNotification(AppEvent.PROXY_UPDATE_VIPREBATEVIEW, {})

end

----请求领取
function VipRebateProxy:onTriggerNet230021Req(data)
	self:syncNetReq(AppEvent.NET_M23, AppEvent.NET_M23_C230021, data)
end

--------------------------------------------------
function VipRebateProxy:getVipRebateInfos()
	return self._vipRebateInfos
end
----今日充值
function VipRebateProxy:getDarlyNum()
	return self.num
end
----累计充值
function VipRebateProxy:getTotalNum()
	return self.allnum
end
----累计充值是否已领取  0未领，1已领
function VipRebateProxy:isAllnumGet()
	for k,v in pairs(self._vipRebateInfos) do
		if v.activityid == self.curId then
			return v.allnumGet
		end
	end

    return 0
end
----获取每日充值领取状态列表
function VipRebateProxy:getDarlyList()
	-- return self.curData.vipgoinfo
	for k,v in pairs(self._vipRebateInfos) do
		if v.activityid == self.curId then
			return v.vipgoinfo
		end
	end

    -- 7891 【测试跨服聊天】VIP总动员结束后点击累计充值报错
    logger:error("==================>VipRebateProxy:getDarlyList() self.curId:%s", self.curId)
    return {}
end

----获取活动时间
function VipRebateProxy:getLimitTimeStr(data)
	-- local str1 = TimeUtils:setTimestampToString(data.startTime)
	-- local str2 = TimeUtils:setTimestampToString(data.endTime)
	-- local str = str1.." - "..str2
	local str = TimeUtils.getLimitActFormatTimeString(data.startTime,data.endTime)
	return str
end

----获取描述信息
function VipRebateProxy:getDescrible()
	return self.data.info
end

function VipRebateProxy:setCurData(id)
	self.curId = id
end

--根据ID获取vip总动员的小红点
--不传参数代表获取全部
function VipRebateProxy:getRedPoint(id)

	local VipGoConfig = ConfigDataManager:getConfigData("VipGoConfig")
	local totalCharge
	for k,v in pairs(VipGoConfig) do
		if v.type == 102 then
			totalCharge = v
			break
		end
	end

	--vip总动员
	local allVipRebateData = self:getVipRebateInfos()
	--获得今日已充值
	local todayNum = self:getDarlyNum()

	local RedPoint = self:getProxy(GameProxys.RedPoint)

	local data
	if allVipRebateData ~= nil then
		if id ~= nil then
			for k,v in pairs(allVipRebateData) do
				if v.activityid == id then
					data = v
					break
				end
			end
		else
			data = allVipRebateData
		end

		for k,v in pairs(data) do
			local onceNum = 0

			if v.allnumGet == 0 then
				local totalNum = self:getTotalNum()
				if totalCharge ~= nil then
					if totalNum >= totalCharge.charge then
						onceNum = onceNum + 1
					end
				end
			end
			for key,value in pairs(v.vipgoinfo) do
				--未可领
				--要比较表的数据来判断是否可以领  666
				if value.isGet == 0 then
					local vipConfig = VipGoConfig[value.effctid]
					if todayNum >= vipConfig.charge then
						onceNum = onceNum + 1
					end
				end
			end
			--在红点数据代理里面设置一下这个活动id对应的小红点
			RedPoint:setRedPoint(v.activityid, onceNum)
		end
	end

	return num
end