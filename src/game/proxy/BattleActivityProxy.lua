---------created by zhangfan in 2016-08-09
---------群雄涿鹿 世界boss等战斗活动的数据代理

BattleActivityProxy = class("BattleActivityProxy", BasicProxy)

BattleActivityProxy.ActivityState_Close = 0 --关闭
BattleActivityProxy.ActivityState_Open = 1 --开启
BattleActivityProxy.ActivityState_Disable = 2 --未开启(开服到第一次开启前)

function BattleActivityProxy:ctor()
    BattleActivityProxy.super.ctor(self)

    self.timeKey = "BattleActivityTimeKey"     --倒计时key
    self.coldDownTimeKey = "coldDownTimeKey"     --倒计时key

    self.proxyName = GameProxys.BattleActivity
    
    self.allBossInfoMap = {}                   --世界boss
    self.allInspireData = {}                   --世界boss
    self.allRedPoint = {}


    self.warlordsMap = {}                      --群雄涿鹿
    self.warlordsSerialWinsMap = {}            --连胜排行榜
    self.warlordsLegionWinsMap = {}            --军团排行榜
    self.allReportInfos = {}                   --所有战况信息
    self.legionReportInfos = {}                --军团战况信息
    self.personalReportInfos = {}              --个人战况信息
    self.typeInfoslen = {{len = 0,lastLen = 0},{len = 0,lastLen = 0},{len = 0,lastLen = 0}}
    self._warlordsWorldState = 0
end

function BattleActivityProxy:initSyncData(data)
	BattleActivityProxy.super.initSyncData(self, data)
	self.activityState = {}					   --活动状态
	self.allActivityInfoList = {}              --所有活动数据
	local activityInfo = {}
	self.allRedPoint = {}
	activityInfo.rs = 0
	activityInfo.infos = data.serverActivityInfo
	self:onTriggerNet310000Resp(activityInfo)

	for _, v in pairs(data.serverActivityInfo) do
		if v.activityId == 2 then
			self._warlordsWorldState = v.realState
			self:sendNotification(AppEvent.PROXY_WARLORDSWORLD)
		end
	end
	 --群雄涿鹿的世界图标状态 1报名 3战斗
end

function BattleActivityProxy:registerNetEvents()

end

function BattleActivityProxy:unregisterNetEvents()

end

function BattleActivityProxy:resetAttr()
end

function BattleActivityProxy:resetCountSyncData()

end

function BattleActivityProxy:onTriggerNet310000Req()       --全服活动协议打开模块请求
	self:syncNetReq(AppEvent.NET_M31, AppEvent.NET_M31_C310000, {})
end

function BattleActivityProxy:onTriggerNet310000Resp(data)  --全服活动协议
	if data.rs == 0 then
		for k,v in pairs(data.infos) do
			self.allActivityInfoList[v.activityId] = v
		end
		self:sendNotification(AppEvent.PROXY_BATTLEACTIVITY_UPDATE_LISTVIEW)
		self:sendNotification(AppEvent.PROXY_BATTLE_ACTIVITY_UPDATE)
        self:sendNotification(AppEvent.PROXY_WARLORDSWORLD)
		-- self:setActivityRedPoint()
		local proxy = self:getProxy(GameProxys.RedPoint)
		proxy:updateServerActivity()
	end
	if data.rs == 0 then
		--群雄涿鹿的世界图标状态 1报名 3战斗
		for _ , v in pairs(data.infos) do
			if v.activityId == 2 or v.activityId == 3 or v.activityId == 4 or v.activityId == 6 then
				if v.activityId == 2 then
					self._warlordsWorldState = v.realState
				end
				--群雄涿鹿状态通知界面时会判断科举活动状态
				self:sendNotification(AppEvent.PROXY_WARLORDSWORLD)
			end

		end
	end

end

function BattleActivityProxy:onTriggerNet320000Req(data)
	self:syncNetReq(AppEvent.NET_M32, AppEvent.NET_M32_C320000, data)
end

function BattleActivityProxy:onTriggerNet320000Resp(data)
	if data.rs == 0 then
		self.allBossInfoMap[data.info.activityId] = data.info
		self.allInspireData[data.info.activityId] = {}
		for k,v in pairs(data.info.inSpireinfos) do
			self.allInspireData[data.info.activityId][v.inSpireId] = v.level
		end
		--请求boss信息后设置队伍信息
		local proxy = self:getProxy(GameProxys.Soldier)
		proxy:setWorldBossTeam(data.info.members)

		if data.info.state == BattleActivityProxy.ActivityState_Open and data.info.endTime == 0 then
			logger:error("data.info.state == BattleActivityProxy.ActivityState_Open(1) and data.info.endTime == 0")
		end
		self:updateActivityTime(data.info)
		if data.info.coldDownTime ~= nil and data.info.coldDownTime > 0 then
			self:pushRemainTime(self.coldDownTimeKey .. data.info.activityId, data.info.coldDownTime)
		end
		self:sendNotification(AppEvent.PROXY_WORLDBOSS_SHOW_VIEW)
	else
		self:sendNotification(AppEvent.PROXY_WORLDBOSS_SHOW_VIEW, true)
	end
end

function BattleActivityProxy:onTriggerNet320001Req(data)
	self:syncNetReq(AppEvent.NET_M32, AppEvent.NET_M32_C320001, data)
end

function BattleActivityProxy:onTriggerNet320001Resp(data)
	if data.rs == 0 then
		self.myDamage = data.myDamage
		self.activityState[data.activityId] = data.state
		self:pushRemainTime(self.coldDownTimeKey .. data.activityId, data.coldDownTime)
		self:sendNotification(AppEvent.PROXY_WORLDBOSS_SHOW_MYATTACK, data)
	else
		self:sendNotification(AppEvent.PROXY_WORLDBOSS_SHOW_MYATTACK)
	end
end

function BattleActivityProxy:onTriggerNet320002Req(data)
	self.typeId = data.typeId
	self:syncNetReq(AppEvent.NET_M32, AppEvent.NET_M32_C320002, data)
end

function BattleActivityProxy:onTriggerNet320002Resp(data)
	if data.rs == 0 then
		self:sendNotification(AppEvent.PROXY_WORLDBOSS_UPDATE_INSPIREVIEW)
	end
end

function BattleActivityProxy:onTriggerNet320003Req(data)
	self.curData = data.members
	self:syncNetReq(AppEvent.NET_M32, AppEvent.NET_M32_C320003, data)
end

function BattleActivityProxy:onTriggerNet320003Resp(data)
	if data.rs == 0 then
		local proxy = self:getProxy(GameProxys.Soldier)
		proxy:setWorldBossTeam(self.curData)
		self:showSysMessage(TextWords:getTextWord(280104))
		self:sendNotification(AppEvent.PROXY_WORLDBOSS_SET_TEAM, data.icon)
	end
end

function BattleActivityProxy:onTriggerNet320004Resp(data)
	self.myRank = data.myRank
	self:sendNotification(AppEvent.PROXY_WORLDBOSS_UPDATE_BOSSINFO, data)
end

function BattleActivityProxy:onTriggerNet320005Resp(data)
	self:updateActivityState(self.curID)
	self:sendNotification(AppEvent.PROXY_WORLDBOSS_BOSS_DIED, data)
end

function BattleActivityProxy:onTriggerNet320006Req(data)
	self:syncNetReq(AppEvent.NET_M32, AppEvent.NET_M32_C320006, data)
end

function BattleActivityProxy:onTriggerNet320006Resp(data)
	if data.rs == 0 then
		self.rankData = data
		self:sendNotification(AppEvent.PROXY_WORLDBOSS_UPDATE_RANKVIEW, data)
	end
end

function BattleActivityProxy:onTriggerNet320007Req(data)
	self:syncNetReq(AppEvent.NET_M32, AppEvent.NET_M32_C320007, data)
end

function BattleActivityProxy:onTriggerNet320007Resp(data)
end

function BattleActivityProxy:onTriggerNet320008Req(data)
	self:syncNetReq(AppEvent.NET_M32, AppEvent.NET_M32_C320008, data)
end

function BattleActivityProxy:onTriggerNet320008Resp(data)
	self:sendNotification(AppEvent.PROXY_WORLDBOSS_UPDATE_AUTOBATTLE, data)
end

function BattleActivityProxy:onTriggerNet320009Req(data)
	self:syncNetReq(AppEvent.NET_M32, AppEvent.NET_M32_C320009, data)
end

function BattleActivityProxy:onTriggerNet320009Resp(data)
	if data.rs == 0 then
		self:showSysMessage(TextWords:getTextWord(280105))
		self:sendNotification(AppEvent.PROXY_WORLDBOSS_CANCEL_COLDDOWN)
	end
end


------------------群雄涿鹿------------------------------------
function BattleActivityProxy:onTriggerNet330000Req(data)  --群雄涿鹿混战状态信息
	if data then
		self:syncNetReq(AppEvent.NET_M33, AppEvent.NET_M33_C330000, data)
		self._warlordsId = data.activityId
	else
		self:syncNetReq(AppEvent.NET_M33, AppEvent.NET_M33_C330000, {activityId = self._warlordsId})
	end
end

function BattleActivityProxy:onTriggerNet330000Resp(data)
	if data.rs == 0 then
		self._warloardsStatusData = data
		local legionMelee = data.legionMelee
		self.isEnroll = legionMelee.isEnroll       --是否报名了
		if legionMelee.nextStateTime > 0 then --下一个状态的剩余时间
			self:pushRemainTime(self._warlordsId.."nextStateTime", legionMelee.nextStateTime)
			TimerManager:addOnce(1000*legionMelee.nextStateTime, self.onTriggerNet330000Req, self)
		else
			self:onRemoveFun()
		end
		self:pushRemainTime(self._warlordsId.."enrollCoolTime", legionMelee.enrollCoolTime)

		if self:isModuleShow(ModuleName.WarlordsModule) then  --如果打开了模块就刷新数据
			self:sendNotification(AppEvent.PROXY_WARLORDSSIGN_OPEN,data)
		else
			self:sendNotification(AppEvent.PROXY_OPENWARLORDS)  --打开模块
			self:sendNotification(AppEvent.PROXY_WARLORDSSIGN_OPEN,data)
		end
	-- elseif data.rs == -100 then  --活动开启失败
	-- 	self._warloardsStatusData["isFailed"] = true
	-- 	self:sendNotification(AppEvent.PROXY_WARLORDSFAILED)
	end
end

function BattleActivityProxy:onRemoveFun()  --关闭模块的时候调用
	TimerManager:remove(self.onTriggerNet330000Req,self)
end

function BattleActivityProxy:onTriggerNet330001Req(data)
	self:syncNetReq(AppEvent.NET_M33, AppEvent.NET_M33_C330001, data)
end

function BattleActivityProxy:onTriggerNet330001Resp(data)  --玩家所在军团的其他成员报名情况
	if data.rs == 0 then
		self._mylegionMembers = data
		if #data.memberInfos >= 2 then
			table.sort(data.memberInfos,function(a,b) return a.capacity > b.capacity end)
		end
		self:sendNotification(AppEvent.PROXY_GETMYLEGIONLISTS)
	end
end

function BattleActivityProxy:onTriggerNet330002Req(data)
	self:syncNetReq(AppEvent.NET_M33, AppEvent.NET_M33_C330002, data)
end

function BattleActivityProxy:onTriggerNet330002Resp(data)  --军团报名列表
	if data.rs == 0 then
		self.legionInfosList = data.legionInfos
		if #self.legionInfosList >= 2 then
			table.sort(self.legionInfosList,function(a,b) return a.capacity > b.capacity end)
		end
		self:sendNotification(AppEvent.PROXY_GETLEGIONLISTS)
	end
end

function BattleActivityProxy:onTriggerNet330003Req(data)
	if data.type == 0 then  --报名
		self.preFightInfos = data.fightInfos
	end
	self:syncNetReq(AppEvent.NET_M33, AppEvent.NET_M33_C330003, data)
end

function BattleActivityProxy:onTriggerNet330003Resp(data)     --请求报名相关
	if data.rs == 0 then
		self.fightInfos = self.preFightInfos
		self.isEnroll = data.isEnroll  --0未报名 1已报名成功
		local num = self._warloardsStatusData.legionMelee.legionEnrollNum
		if self.isEnroll >= 1 then
			self._warloardsStatusData.legionMelee.legionEnrollNum = num + 1
		else
			self._warloardsStatusData.legionMelee.legionEnrollNum = num - 1
		end

		self:pushRemainTime(self._warlordsId.."enrollCoolTime", data.enrollCoolTime)  --冷冻时间
		self:sendNotification(AppEvent.PROXY_SETSIGNSUCCEED)
	end
end

function BattleActivityProxy:onTriggerNet330004Req(data)
	self:syncNetReq(AppEvent.NET_M33, AppEvent.NET_M33_C330004, data)
end

function BattleActivityProxy:onTriggerNet330004Resp(data)
	if data.rs == 0 then
		self.fightInfos = data.fightInfos                    --阵型队列
		self:sendNotification(AppEvent.PROXY_GETFIGHTINFOS)
	end
end

function BattleActivityProxy:onTriggerNet330005Req(data) --请求战况信息，进入界面时候刷新
	self:syncNetReq(AppEvent.NET_M33, AppEvent.NET_M33_C330005, data)
end

function BattleActivityProxy:onTriggerNet330005Resp(data)
	if data.rs == 0 then
		self.allReportInfos,self.typeInfoslen[1].len,self.typeInfoslen[1].lastLen = self:onSortInfos(data.allReportInfos,1)          --全服
		self.legionReportInfos,self.typeInfoslen[2].len,self.typeInfoslen[2].lastLen = self:onSortInfos(data.legionReportInfos,2)    --军团
		self.personalReportInfos,self.typeInfoslen[3].len,self.typeInfoslen[3].lastLen = self:onSortInfos(data.personalReportInfos,3)--个人
		self.combatProgress = data.combatProgress
		if data.combatProgress.roundTime ~= 0 and data.combatProgress.roundTime ~= nil then
			self:pushRemainTime(self.coldDownTimeKey .. "qxzl", data.combatProgress.roundTime)
		else
			self._remainTimeMap[self.coldDownTimeKey .. "qxzl"] = nil
		end

		self:sendAppEvent(AppEvent.MODULE_EVENT,AppEvent.MODULE_OPEN_EVENT,{moduleName = ModuleName.WarlordsFieldModule})
	end
end

-- function BattleActivityProxy:onTriggerNet330006Req(data)
-- 	self:syncNetReq(AppEvent.NET_M33, AppEvent.NET_M33_C330006, data)
-- end

function BattleActivityProxy:onTriggerNet330006Resp(serverData)  --服务端主动推送战况，只有停留在界面的时候才推送
	local roleProxy = self:getProxy(GameProxys.Role)
	local mylegionName = roleProxy:getLegionName()
	local function call(srcData,newData,type)
		local newList = {}
		if self.typeInfoslen[type].len == 20 then  --最大保存20条信息,fightInfo和eliminateInfo是同一条数据的含义
			if newData.type == 1 then
				table.insert(newList,{type = 1,fightInfo = newData.fightInfo,actorType = type}) 
			elseif newData.type == 2 then
				table.insert(newList, {type = 2,fightInfo = newData.eliminateInfo,actorType = type})
				table.insert(newList, {type = 1,fightInfo = newData.fightInfo,actorType = type})
			elseif newData.type == 3 then
				local isInsert = true
				if type == 2 then
					if newData.winnerLegionInfo.legionName ~= mylegionName then  --特殊
						isInsert = false
					end
				end
				if isInsert == true then
					table.insert(newList, {type = 3,fightInfo = newData.winnerLegionInfo,actorType = type})
				end
				table.insert(newList, {type = 2,fightInfo = newData.eliminateInfo,actorType = type})
				table.insert(newList, {type = 1,fightInfo = newData.fightInfo,actorType = type})
			end
			for index = 1,#srcData - self.typeInfoslen[type].lastLen do
				table.insert(newList,srcData[index])
			end
			self.typeInfoslen[type].lastLen = self:onFindLastType(newList)
		else
			if newData.type == 1 then
				table.insert(newList,{type = 1,fightInfo = newData.fightInfo,actorType = type}) 
			elseif newData.type == 2 then
				table.insert(newList, {type = 2,fightInfo = newData.eliminateInfo,actorType = type})
				table.insert(newList, {type = 1,fightInfo = newData.fightInfo,actorType = type})
			elseif newData.type == 3 then
				local isInsert = true
				if type == 2 then
					if newData.winnerLegionInfo.legionName ~= mylegionName then  --特殊
						isInsert = false
					end
				end
				if isInsert == true then
					table.insert(newList, {type = 3,fightInfo = newData.winnerLegionInfo,actorType = type})
				end
				table.insert(newList, {type = 2,fightInfo = newData.eliminateInfo,actorType = type})
				table.insert(newList, {type = 1,fightInfo = newData.fightInfo,actorType = type})
			end
			for index = 1,#srcData do
				table.insert(newList,srcData[index])
			end
			self.typeInfoslen[type].len = self.typeInfoslen[type].len + 1
			self.typeInfoslen[type].lastLen = self:onFindLastType(newList)
		end
		return newList
	end
 
 	local data = serverData.reportInfos
	if serverData.type == 1 then
		self.allReportInfos = call(self.allReportInfos,data,1)   --战报类型 1全服 2全服+军团 3全服+军团+个人
	elseif serverData.type == 2 then
		self.allReportInfos = call(self.allReportInfos,data,2)   
		self.legionReportInfos = call(self.legionReportInfos,data,2)
	elseif serverData.type == 3 then
		self.allReportInfos = call(self.allReportInfos,data,3)   
		self.legionReportInfos = call(self.legionReportInfos,data,3)
		self.personalReportInfos = call(self.personalReportInfos,data,3)
	end

	self:sendNotification(AppEvent.PROXY_FIGHTREPORTS_CHANGE)
end
 
function BattleActivityProxy:onTriggerNet330007Req(data)  --请求连胜排名
	self:syncNetReq(AppEvent.NET_M33, AppEvent.NET_M33_C330007, data)
end

function BattleActivityProxy:onTriggerNet330007Resp(data)
	if data.rs == 0 then
		self.warlordsSerialWinsMap = data
		self:sendNotification(AppEvent.PROXY_WINSRANKMEMBERS,data)      
	end
end

function BattleActivityProxy:onTriggerNet330008Req(data)  --请求联盟排名
	self:syncNetReq(AppEvent.NET_M33, AppEvent.NET_M33_C330008, data)
end

function BattleActivityProxy:onTriggerNet330008Resp(data)
	if data.rs == 0 then
    	self.warlordsLegionWinsMap = data
    	self:sendNotification(AppEvent.PROXY_WINSRANKLEGIONS,data)
	end
end

function BattleActivityProxy:onTriggerNet330009Req(data)  --战斗重播
	self:syncNetReq(AppEvent.NET_M33, AppEvent.NET_M33_C330009, data)
end

function BattleActivityProxy:onTriggerNet330009Resp(data)
end

function BattleActivityProxy:onTriggerNet330010Req(data)  --领取连胜奖励
	self:syncNetReq(AppEvent.NET_M33, AppEvent.NET_M33_C330010, data)
end

function BattleActivityProxy:onTriggerNet330010Resp(data)
end

function BattleActivityProxy:onTriggerNet330100Resp(data)  --全服活动状态推送
	self._warlordsWorldState = data.activityState    
	self:sendNotification(AppEvent.PROXY_WARLORDSWORLD,data.activityState)
	local proxy = self:getProxy(GameProxys.RedPoint)
	proxy:updateServerActivity()
end

function BattleActivityProxy:onTriggerNet330101Resp(data)  --//军团混战进度信息
	self.combatProgress = data.combatProgress 

	if data.combatProgress.roundTime ~= 0 and data.combatProgress.roundTime ~= nil then
		self:pushRemainTime(self.coldDownTimeKey .. "qxzl", data.combatProgress.roundTime)
	else
		self._remainTimeMap[self.coldDownTimeKey .. "qxzl"] = nil
	end

	self:sendNotification(AppEvent.PROXY_WARLORDSCOMBAT)
end

--------------------获取数据的接口------------------------------


--活动状态倒计时 1准备中  2进行中
function BattleActivityProxy:updateActivityTime(data)
	if data.state == BattleActivityProxy.ActivityState_Close then
		self.activityState[data.activityId] = data.state
		return 
	end
	self.activityState[data.activityId] = data.state
	if data.readTime > 0 then
		self:pushRemainTime(self.timeKey.."read"..data.activityId, data.readTime, AppEvent.NET_M32_C320001, {state = self.activityState[data.activityId], info = data}, self.readCall)
	end
	if data.endTime > 0 then
		self:pushRemainTime(self.timeKey.."end"..data.activityId, data.endTime, AppEvent.NET_M32_C320000, {state = 2, info = data}, self.endCall)
	end
end

function BattleActivityProxy:readCall(params)
	local param = params[1]
	self._remainTimeMap[self.timeKey.."read"..param.info.activityId] = nil
	self.activityState[param.info.activityId] = 2
	-- self:pushRemainTime(self.timeKey.."end"..param.info.activityId, param.info.endTime, AppEvent.NET_M32_C320000, {state = self.activityState[param.info.activityId], info = param.info}, self.endCall)
	self:sendNotification(AppEvent.PROXY_WORLDBOSS_SHOW_VIEW)
end

function BattleActivityProxy:endCall(params)
	local param = params[1]
	self._remainTimeMap[self.timeKey.."end"..param.info.activityId] = nil
	self:updateActivityState(param.info.activityId)
	local proxy = self:getProxy(GameProxys.Soldier)
	proxy:resetWorldBossTeam()
	self:sendNotification(AppEvent.PROXY_WORLDBOSS_ACTIVITY_END)
end

function BattleActivityProxy:getActivityInfo()                         --获取所有活动的状态数据
	return TableUtils:map2list(self.allActivityInfoList or {})
end

function BattleActivityProxy:getBossInfoById(id)                       --获取世界boss的单条数据
	return self.allBossInfoMap[id]
end

function BattleActivityProxy:setInspireData(id)                        --根据id增加鼓舞的等级
	self.allInspireData[id][self.typeId] = self.allInspireData[id][self.typeId] + 1
end

function BattleActivityProxy:getInspireLevelByType(id, typeId)             --根据type和id来拿鼓舞的等级
	local level = self.allInspireData[id][typeId]
	return level or 0
end

--根据活动id，拿鼓舞数据
function BattleActivityProxy:getInspireDataById(id)
	return self.allInspireData[id]
end

function BattleActivityProxy:getWarlordsLegionWins()                   --获取群雄涿鹿的军团排行榜数据
	return self.warlordsLegionWinsMap
end

function BattleActivityProxy:getWarlordsSerialWins()                   --获取群雄涿鹿的连胜排行榜数据
	return self.warlordsSerialWinsMap
end

function BattleActivityProxy:onGetFightReports(type)                        --获取战况信息 1：全服 2：军团  3：个人
	if type == 1 then
		return self.allReportInfos
	elseif type == 2 then
		return self.legionReportInfos
	elseif type == 3 then
		return self.personalReportInfos
	end
end

function BattleActivityProxy:onSortInfos(data,flag)
	local roleProxy = self:getProxy(GameProxys.Role)
	local mylegionName = roleProxy:getLegionName()
	local myPlayerId = roleProxy:getPlayerId()

	local sortData = {}
	local index = 1
	local count = 0
	local lastType = 0
	for _ , v in pairs(data) do
		local actorType = 1
		if v.fightInfo.attackTeam.legionName == mylegionName or v.fightInfo.defendTeam.legionName == mylegionName then
			if v.fightInfo.attackTeam.playerId == myPlayerId or v.fightInfo.defendTeam.playerId == myPlayerId then
				actorType = 3
			else
				actorType = 2
			end
		end
		lastType = v.type
		if v.type == 1 then
			sortData[index] = {type = 1,fightInfo = v.fightInfo,actorType = actorType}--v --v.fightInfo
			index = index + 1
		elseif v.type == 2 then
			sortData[index] = {type = 2,fightInfo = v.eliminateInfo,actorType = actorType}
			index = index + 1
			sortData[index] = {type = 1,fightInfo = v.fightInfo,actorType = actorType}
			index = index + 1
		elseif v.type == 3 then
			sortData[index] = {type = 3,fightInfo = v.winnerLegionInfo,actorType = actorType}
			index = index + 1
			sortData[index] = {type = 2,fightInfo = v.eliminateInfo,actorType = actorType}
			index = index + 1
			sortData[index] = {type = 1,fightInfo = v.fightInfo,actorType = actorType}
			index = index + 1
		end
		count = count + 1
	end
	if count == 0 then
		return sortData,0,0
	end
	return sortData,count,lastType
end

function BattleActivityProxy:getStateById(id)
	return self.activityState[id]
end

function BattleActivityProxy:setStateById(id, state)
	self.activityState[id] = state
end

function BattleActivityProxy:onGetWorloardsStatus()   --获取群雄涿鹿的状态信息
	return self._warloardsStatusData
end

function BattleActivityProxy:onGetWorloardsActId()    --获取群雄涿鹿的活动id
	return self._warlordsId
end

function BattleActivityProxy:getLegionInfosList()    --获取群雄涿鹿参与的军团列表
	return self.legionInfosList
end

function BattleActivityProxy:getMyLegionInfosList()    --获取群雄涿鹿本军团其他人员的报名列表
	return self._mylegionMembers
end

function BattleActivityProxy:onGetFightInfos()         --获取群雄涿鹿阵型信息
	return self.fightInfos
end

function BattleActivityProxy:onGetIsEnroll()          --是否群雄涿鹿玩家报名了
	return self.isEnroll
end

function BattleActivityProxy:getRankData()    		  --获取世界boss排行榜数据
	return self.rankData
end

function BattleActivityProxy:cancelColdDown(id)
	self._remainTimeMap[self.coldDownTimeKey .. id] = nil
end

function BattleActivityProxy:initMyRank(rankNum)
	if rankNum == -1 then
        self.myRank = 0
    else
        self.myRank = rankNum
    end
end

function BattleActivityProxy:getMyRank()
	return self.myRank or 0
end

function BattleActivityProxy:updateActivityState(id)
	if self.allActivityInfoList[id] ~= nil then
		self.allActivityInfoList[id].state = BattleActivityProxy.ActivityState_Close
	end
	-- self:setActivityRedPoint()
	local proxy = self:getProxy(GameProxys.RedPoint)
	proxy:updateServerActivity()
	self:sendNotification(AppEvent.PROXY_BATTLEACTIVITY_UPDATE_LISTVIEW) 	
end

function BattleActivityProxy:getMyDamage()
	return self.myDamage or 0
end

function BattleActivityProxy:setCurActivityID(ID)
	self.curID = ID
end

function BattleActivityProxy:onSaveData(saveData)  --保存群雄涿鹿带兵量和战力
	self._saveData = saveData
end

function BattleActivityProxy:onGetSaveData()
	return self._saveData
end

function BattleActivityProxy:onGetWarlordsWorldState()
	return self._warlordsWorldState
end

function BattleActivityProxy:onFindLastType(data)
	local len = #data

	if len == 1 or len ==2 then
		return data[len].type
	elseif len >= 3 then
		if data[3].type == 3 then
			return 3
		elseif data[3].type == 1 then
			if data[2].type == 1 then
				return 1
			elseif data[2].type == 2 then
				return 2
			end
		else
			if data[2].type == 2 then
				return 2
			else
				return 1
			end
		end
	end
	return 0
end

function BattleActivityProxy:onGetCombatProgress()
	return self.combatProgress
end

-- 判定讨伐物资是否已开放，未开放则飘字提示
function BattleActivityProxy:isUnlock(isShowMsg)

    local info = ConfigDataManager:getConfigById("NewFunctionOpenConfig", 44)

    if info.type == 1 then  --type = 1 判定主公等级
        local unLockLevel = info.need
        local roleProxy = self:getProxy(GameProxys.Role)
        local currentLv = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_level)

        if currentLv < unLockLevel then
            if isShowMsg then
                self:showSysMessage(string.format(TextWords:getTextWord(340000),info.need,info.name))
            end
            return false
        end
        return true
    else
        return false
    end
end

function BattleActivityProxy:setActivityRedPoint()
	self.allActivityInfoList = self.allActivityInfoList or {}
	self.allRedPoint = {}
	for k,v in pairs(self.allActivityInfoList) do
		if v.activityType == ActivityDefine.SERVER_ACTION_LEGION_WAR then
			if self._warlordsWorldState ~= 0 then
				self.allRedPoint[v.activityId] = 1
			else
				self.allRedPoint[v.activityId] = 0
			end
		else
			if v.state == BattleActivityProxy.ActivityState_Open then
				self.allRedPoint[v.activityId] = 1
			else
				self.allRedPoint[v.activityId] = 0
			end

            -- 叛军增加排行奖励红点
            if v.activityType == ActivityDefine.SERVER_ACTION_REBELS then
                local rebelsProxy = self:getProxy(GameProxys.Rebels)
                local count = rebelsProxy:getRankRewardRedPointCount()
                if count > 0 then
                    self.allRedPoint[v.activityId] = 1
                end
            end

			-- 城主战奖励小红点
			if v.activityType == ActivityDefine.SERVER_ACTION_LORDCITY_BATTLE then
				local redPointProxy = self:getProxy(GameProxys.RedPoint)
				local rednum = redPointProxy:getCityBattleRedNum()
				logger:info("城主戰 小紅點 0000")
				if rednum > 0 then
					logger:info("城主戰 小紅點 1111")
					self.allRedPoint[v.activityId] = rednum
				end
			end

            -- 皇城战奖励小红点
            if v.activityType == ActivityDefine.SERVER_ACTION_EMPEROR_CITY and v.state ~= BattleActivityProxy.ActivityState_Disable then -- 服务端待处理，客户端先做屏蔽操作
                local redPointProxy = self:getProxy(GameProxys.RedPoint)
                local num = redPointProxy:getEmperorCityRedNum()
                self.allRedPoint[v.activityId] = num
            elseif v.activityType == ActivityDefine.SERVER_ACTION_EMPEROR_CITY and v.state == BattleActivityProxy.ActivityState_Disable then
                self.allRedPoint[v.activityId] = 0
            end
		end		

	end
end

function BattleActivityProxy:getRedPointInfo()
	return self.allRedPoint
end

-- 获取活动的状态
function BattleActivityProxy:getBattleActivityByType(type)
    if self.allActivityInfoList ~= nil then
        for k, v in pairs(self.allActivityInfoList) do
            if v.type == type then
                return v
            end
        end
    end
    return nil
end

--是否在主城中显示科举快捷入口
function BattleActivityProxy:isShowExamEntrance()
    local isShow = false
    local provState = 0
    local palaceState = 0
    if self.allActivityInfoList == nil or self.allActivityInfoList[3] == nil then
    	provState = 0
    	else
		provState = self.allActivityInfoList[3].state	
    end
    if self.allActivityInfoList == nil or self.allActivityInfoList[4] == nil then
    	palaceState = 0
    	else
		palaceState = self.allActivityInfoList[4].state
    end
    local isShowProv = provState == 1
    local isShowPalace = palaceState == 1
    isShow = isShowProv or isShowPalace
    local activityId
    if isShow == true then
        activityId = isShowProv == true and 3 or 4
    end
    return isShow,activityId
end

--获取主城中显示科举快捷入口图标url
function BattleActivityProxy:getExamEntranceUrl()
    local url = "images/team/keju.png"
    --[[
    local provState = self.allActivityInfoList[3] == nil and 0 or self.allActivityInfoList[3].state
    local palaceState = self.allActivityInfoList[4] == nil and 0 or self.allActivityInfoList[4].state
    if provState == 1 then
        url = "images/team/keju.png"
    end
    if palaceState == 1 then
        url = "images/team/keju.png"
    end
    --]]
    return url
end

function BattleActivityProxy:getActivityInfoByUitype(uitype)
	for k,v in pairs(self.allActivityInfoList) do
		if v.activityType == uitype then
			self.curBattleData = v
			return v
		end
	end
end

function BattleActivityProxy:getCurBattleData()
	return self.curBattleData
end


-- 获取公会作战所的活动数据
function BattleActivityProxy:getLegionFightActivity()
    local actInfo = {}

    local activityInfo = self:getActivityInfo()
    for k, v in pairs( activityInfo) do
        local isBattle = v.isLegion or 0 -- 是否是公会作战所活动
        if isBattle ~= 0 then
            table.insert(actInfo, v)
        end
    end

    return actInfo
end