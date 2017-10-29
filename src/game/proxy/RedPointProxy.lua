
RedPointProxy = class("RedPointProxy", BasicProxy)

function RedPointProxy:ctor()
    RedPointProxy.super.ctor(self)
    self.proxyName = GameProxys.RedPoint
    self:_initInfo()

    self._isFirst = false
end

function RedPointProxy:resetAttr()
	self:_initInfo()
end

function RedPointProxy:registerNetEvents()

end

function RedPointProxy:unregisterNetEvents()

end

--初始化红点个数
function RedPointProxy:_initInfo()

	self._allRedPoint = {}

    self._RedPointInfo ={}
	for i=1, 15 do
		self._RedPointInfo[i] = {}
		self._RedPointInfo[i].num = 0
		self._RedPointInfo[i].type = i
	end
end

---toolbar---调用给所有小红点赋值
function RedPointProxy:setToolbarRedPonintInfo()
	self:checkDungeonRedPoint() 		 --1--
	self:checkTeamRedPoint()  			 --2-- 
	self:checkTaskRedPoint()  			 --3
	self:checkMailRedPoint()  			 --4
	self:checkBagRedPoint()				 --5 
	self:checkFriendRedPoint()			 --6  
	self:lotteryEquipRedPoint() 		 --7 
	self:checkEquiipRedPoint()			 --8 
	self:checkFreeFindBoxRedPoint()	   	 --9
	self:checkOrdmamceRedPoint()		 --10   
	self:checkActivityRedPoint()		 --11 
	self:checkThirtyRedPoint()			 --12
	self:checkActivityLimitRedPoint()	 --13
	self:checkArmyBigRewardRedPoint()	 --14
    self:checkMapMilitrayRedPoint()	     --15
end


function RedPointProxy:getRedPointInfos()
	return self._RedPointInfo
end

function RedPointProxy:updateRedPointInfo(type, num)
	if self._RedPointInfo[type].num ~= num then
		self._RedPointInfo[type].num = num
		self:delaySendNotification(AppEvent.PROXY_REDPOINT_UPDATE, {})
	end
end

--关卡小红点数量计算    index = 1 没做更新
function RedPointProxy:checkDungeonRedPoint()
	local index, num = 1, 0 

    --远征副本 剩余次数
    local configs = ConfigDataManager:getConfigData(ConfigData.AdventureConfig)
    local dungeonProxy = self:getProxy(GameProxys.Dungeon)
    local num = 0

    for k,v in pairs(configs) do
        if v.ID ~= 4 then  --西域远征另计
            local times = dungeonProxy:getTimesById(v.ID)
            if times ~= -1 then
                num = num + times
            end
        end
    end

	--西域远征
	local limitExpProxy = self:getProxy(GameProxys.LimitExp)
	local limitExpInfos = limitExpProxy:getExinfos() --获取最新的60100的数据
	if limitExpInfos ~= nil then
		if limitExpInfos.fightCount ~= 0 or limitExpInfos.backCount ~= 0 then
			num = num + 1
		end
	else
		local roleProxy = self:getProxy(GameProxys.Role)
		num = num + roleProxy:getlimitExp() -- 没副本信息的时候，西域远征次数是这里拿的
	end

	local playerProxy = self:getProxy(GameProxys.Role)
    -- 民心是否开放
    local isUnlock = playerProxy:isFunctionUnLock(17, false, nil)
    -- 开启则加上
    if isUnlock then
        local supportNum = playerProxy:getRoleAttrValue(PlayerPowerDefine.POWER_support) or 0
        num = num + supportNum
    end
	self:updateRedPointInfo(index, num)
end

--部队小红点数量计算    index = 2     没做更新
function RedPointProxy:checkTeamRedPoint()
	local index, num = 2, 0 
	local soldierProxy = self:getProxy(GameProxys.Soldier)
	local taskTeamInfo = soldierProxy:getTaskTeamInfo()
	local badSoldierList = soldierProxy:getBadSoldiersList()
	for _,v in pairs(taskTeamInfo) do
		if v.type ~= 6 then
			num = num + 1
		end
	end
	for k,v in pairs(badSoldierList) do
		num = num + 1
	end
	self:updateRedPointInfo(index, num)
end

--任务小红点数量计算    index = 3
function RedPointProxy:checkTaskRedPoint()
	local index, num = 3, 0 
	local RoleProxy = self:getProxy(GameProxys.Role)
	local isLock = RoleProxy:isFunctionUnLock(10, false) -- 已开启true，未开启false

	local taskProxy = self:getProxy(GameProxys.Task)
	local mainList = taskProxy:getMainTaskList()
	local dailyList = taskProxy:getDailyTaskList()
	local activeState = taskProxy:getActiveState()
	local activeMaxID = taskProxy:getActiveMaxID()
	for _, v in pairs(mainList) do
		if v.state == 1 then
			num = num + 1
		end
	end

    -- 战功小红点个数
	local num2 = taskProxy:getCont2()
    --策划需求第一次打开战功小红点开启
	if not self._init and num2 == 0 then
		-- num = num + 1
		--self:setTaskInit(true)
	else
        if isLock then -- 战功任务开启后，才显示战功小红点
		    num = num + num2
        end
	end
	self:updateRedPointInfo(index, num)
end

function RedPointProxy:setTaskInit(isInit)
    self._init = isInit
end

--邮件小红点数量计算    index = 4   
function RedPointProxy:checkMailRedPoint()
	local index, num = 4, 0 
	--TODO根据数据计算num
	local mailProxy = self:getProxy(GameProxys.Mail)
	local mails = mailProxy:getAllShortData()
	for _,v in pairs(mails) do
		if v.state == 0 then
			num = num + 1
		end
        -- 系统邮件未领取也算一个红点
        if v.state == 1 and v.type == 1 then -- 
            if v.extracted == 0 then
                num = num + 1
            end
        end
	end
	self:updateRedPointInfo(index, num)
end

--背包小红点数量计算    index = 5     
function RedPointProxy:checkBagRedPoint()
	local index, num = 5, 0 
	--TODO根据数据计算num
	local itemProxy = self:getProxy(GameProxys.Item)
	local items = itemProxy:getAllItemList()
	for _, v in pairs(items) do 
		if itemProxy:isCanUse(v.typeid) then
			num = num + 1
		end
	end
	self:updateRedPointInfo(index, num)
end

--好友祝福小红点数量计算  index = 6    
function RedPointProxy:checkFriendRedPoint()
	local index, num = 6, 0 
	local friendProxy = self:getProxy(GameProxys.Friend)
	num = friendProxy:getBlessRedPointCount()

	self:updateRedPointInfo(index, num)
end

--拜访名将
--装备抽奖(武将)小红点数量计算 index = 7 
function RedPointProxy:lotteryEquipRedPoint()
	local index, num = 7, 0 
	--[[
	local lotteryProxy = self:getProxy(GameProxys.Lottery)
	local lotteryInfos = lotteryProxy:getNetInfos()
	for k,v in pairs(lotteryInfos) do
		if v.freeTimes then
			num = num + v.freeTimes
		end
	end
	]]
	self:updateRedPointInfo(index, num)	
end

-- （阵容）小红点数量计算 index = 8   
function RedPointProxy:checkEquiipRedPoint()
	local index, num = 8, 0 	
	--TODO根据数据计算num
	local heroProxy = self:getProxy(GameProxys.Hero)
	local unAdd = heroProxy:getUnAddHero()
	for _, v in pairs(unAdd) do
		num = num + v.num -- 有几个可上阵的武将
	end
    local canAddCount = heroProxy:getCanAddCount()-- 可上阵坑位
    -- 取空闲英雄数和可上阵坑位数的较小值
    if num > canAddCount then 
        num = canAddCount
    end
	self:updateRedPointInfo(index, num)
end
--酒馆小红点数量计算      index = 9 编号
function RedPointProxy:checkFreeFindBoxRedPoint()
	local index, num = 9, 0 
	
    local roleProxy = self:getProxy(GameProxys.Role)
    local isUnlock = roleProxy:isFunctionUnLock(5, false) -- 未开放不显示小红点
    if isUnlock == false then
        self:updateRedPointInfo(index, num)
        return -- pause
    end

    -- 免费次数
	local pubProxy = self:getProxy(GameProxys.Pub)
	local data = pubProxy:getPubFreeData()
	for k,v in pairs(data) do
		num = v.times + num 
	end

    -- 女儿红、竹叶青也算红点
    local isSpeUnlock = roleProxy:isFunctionUnLock(9, false) -- 酒馆盛宴是否开放
    if isSpeUnlock then
        num = num + pubProxy:getNorSpeItemCount()
    else
        num = num + pubProxy:getNorItemCount() -- 只计算女儿红
    end
    
	self:updateRedPointInfo(index, num)
end

--军械仓库小红点数量计算     index = 10    
function RedPointProxy:checkOrdmamceRedPoint()
	local index, num = 10, 0 
	--TODO根据数据计算num
	local partsProxy = self:getProxy(GameProxys.Parts)
	local notWearingPartsInfos = (partsProxy:getOrdnanceUnEquipInfos()) or {}
	--计算未装备军械数量
	for _, v in pairs(notWearingPartsInfos) do
		num = num + 1
	end
	self:updateRedPointInfo(index, num)	
end

--活动可领取小红点数量计算         index = 11
function RedPointProxy:checkActivityRedPoint()
	local index, num = 11, 0 
	--TODO根据数据计算num
	local activityProxy = self:getProxy(GameProxys.Activity)
	local data = activityProxy:getActivityInfo()
	for i=1,#data do
		if data[i].reveal == 0 then 
			if type(data[i].effectInfos) == "table" then
				for k,v in pairs(data[i].effectInfos) do
					if v.iscanget == 1 then
						num = num + 1
					end
				end
			end
			if type(data[i].buttons) == "table" then
				for k,v in pairs(data[i].buttons) do
					if v.type == 2 and data[i].uitype ~= 2 then
						num = num + 1
					end
				end
			end
		end
	end
    --周卡特殊处理领取数量
    local cardState = activityProxy:getWeekCardState()
    if cardState == 0 then
        num = num + 1
    end

    --礼包兑换也特殊处理 每次登陆只处理一次 详细见 7316
    if self._isFirst  then
        num = num + 1                                                                --//一个账号只会出现一次
        -- self._isFirst = false                                                     --//出现一次之后不再计算
    end
	self:updateRedPointInfo(index, num)
end

--30天活动小红点数量计算      index = 12  
function RedPointProxy:checkThirtyRedPoint()
	local index, num = 12, 0 
	--TODO根据数据计算num
	local roleProxy = self:getProxy(GameProxys.Role)
	local openServerList = roleProxy:getOpenServerList()
	for _, v in pairs(openServerList) do
		if v.state == 2 then
			num = num + 1
		end
	end
	local severData = roleProxy:getOpenServerData()
	if severData.allDay == 0 then
		num = num + 1
	end
	self:updateRedPointInfo(index, num)
end

--限时活动小红点数量计算      index = 13   待测
function RedPointProxy:checkActivityLimitRedPoint()
	local index, num = 13, 0 
	--TODO根据数据计算num
	-- local activityProxy = self:getProxy(GameProxys.Activity)
	-- local shareData = activityProxy:returnInfo()
	-- local labaData = activityProxy.labaXinxi
	-- num = #shareData
	-- for k,v in pairs(labaData) do
	-- 	if v.free == 1 then
	-- 		num = num + 1
	-- 	end
	-- end
	-- local info = activityProxy:getDayTurntableRedPoints()
	-- for k,v in pairs(info) do
	-- 	num = num + v
	-- end
	for k,v in pairs(self._allRedPoint) do
		num = num + v
	end
	self:updateRedPointInfo(index, num)
end

--军团大礼小红点数量计算      index = 14
function RedPointProxy:checkArmyBigRewardRedPoint()
	local index, num = 14, 0 
	--TODO根据数据计算num
	--print("军团红点===",num)
	local activityProxy = self:getProxy(GameProxys.Activity)
	local flag,data = activityProxy:getDataByCondition(ActivityDefine.LEGION_JOIN_CONDITION)
	if flag then
		-- for k,v in pairs(data) do
			if data.buttons then
				for key,value in pairs(data.buttons) do
					if value.type == 2 then
						num = num + 1
					end
				end
			end
		-- end
	end
	self:updateRedPointInfo(index, num)
end

--军功玩法      index = 15
function RedPointProxy:checkMapMilitrayRedPoint()
	local index, num = 15, 0 
	--TODO根据数据计算num
	--print("军团红点===",num)
	local mapMilitaryProxy = self:getProxy(GameProxys.MapMilitary)
	num = mapMilitaryProxy:getRewardNum()

	local num_ex = mapMilitaryProxy:getPlainsChapterRewardNum() --获取中原目标奖励数量
	num = num + num_ex 
	self:updateRedPointInfo(index, num)
end

--记录每个限时活动的小红点
function RedPointProxy:setRedPoint(id, num)    
    local activityProxy = self:getProxy(GameProxys.Activity)
    local activityInfo = activityProxy:getLimitActivityInfoById(id)
    if activityInfo == nil or GameConfig.serverTime >= activityInfo.endTime then        
        num = 0
    end

	self._allRedPoint[id] = num
end

function RedPointProxy:getRedPointById(id)
	return self._allRedPoint[id] or 0
end

function RedPointProxy:getAllRedData()
	return self._allRedPoint or {}
end

--单独计算每个限时活动的小红点，放在一起算比较浪费
--有福同享
function RedPointProxy:setChargeShareRed()
	local activityProxy = self:getProxy(GameProxys.Activity)
	local shareData = activityProxy:returnInfo()--有福同享的红点

	--todo  有福同享  待优化
	local allActivityInfo = activityProxy:getLimitActivityInfo()
	for k,v in pairs(allActivityInfo) do
		if v.uitype == ActivityDefine.LIMIT_ACTION_LEGIONSHARE_ID then
			self:setRedPoint(v.activityId, #shareData)
			break
		end
	end
	self:delaySendNotification(AppEvent.PROXY_REDPOINT_UPDATE, {})
end

--拉霸
function RedPointProxy:setPullBarRed()
	local activityProxy = self:getProxy(GameProxys.Activity)
	local labaData = activityProxy.labaXinxi--拉霸的红点
	for k,v in pairs(labaData) do
		if v.free == 1 then
			self:setRedPoint(v.activityId, 1)
		else
			self:setRedPoint(v.activityId, 0)
		end
	end
	self:delaySendNotification(AppEvent.PROXY_REDPOINT_UPDATE, {})
end

--vip总动员
function RedPointProxy:setVipRebateRed()
	local vipRebateProxy = self:getProxy(GameProxys.VipRebate)
	local vipNum = vipRebateProxy:getRedPoint()
	self:delaySendNotification(AppEvent.PROXY_REDPOINT_UPDATE, {})
end

--每日轮盘
function RedPointProxy:setDayTrunRed()
    local activityProxy = self:getProxy(GameProxys.Activity)
    local info = activityProxy:getDayTurntableRedPoints()
    for k, v in pairs(info) do
        self:setRedPoint(k, v)
    end
    self:delaySendNotification(AppEvent.PROXY_REDPOINT_UPDATE, { })
end

--皇帝的新衣
function RedPointProxy:setEmperorRed()
	local EmperorProxy = self:getProxy(GameProxys.EmperorAward)
	local emperorNum = EmperorProxy:getAllRedPoint()
	self:delaySendNotification(AppEvent.PROXY_REDPOINT_UPDATE, {})
end

--天降奇兵
function RedPointProxy:setSoldierRed()
	local proxy = self:getProxy(GameProxys.GeneralAndSoldier)
	local soldierNum = proxy:getAllRedPoint()
	self:delaySendNotification(AppEvent.PROXY_REDPOINT_UPDATE, {})
end

--金鸡蛋黄派
function RedPointProxy:setSmashEggRed()
	local activityProxy = self:getProxy(GameProxys.Activity)
	local activityData = activityProxy:getLimitActivityDataByUitype( ActivityDefine.LIMIT_SMASHEGG_ID )
	if activityData then
		local number = activityProxy:getSmashEggNumber()
		self:setRedPoint( activityData.activityId, number )
		self:delaySendNotification(AppEvent.PROXY_REDPOINT_UPDATE, {})
	end
end

--迎春集福
function RedPointProxy:setCollectBlessRed()
	local activityProxy = self:getProxy(GameProxys.Activity)
	local activityData = activityProxy:getLimitActivityDataByUitype( ActivityDefine.LIMIT_COLLECTBLESS_ID )
	if activityData then
		local number = activityProxy:getCollectBlessFullNumber()
		-- print("刷新迎春红点", number)
		self:setRedPoint( activityData.activityId, number )
		self:delaySendNotification(AppEvent.PROXY_REDPOINT_UPDATE, {})
	end
end
--爆竹酉礼小红点
function RedPointProxy:setSpringSquibRed()
	local activityProxy = self:getProxy(GameProxys.Activity)
	local squibInfos = activityProxy:getSquibInfos()
	for k,v in pairs(squibInfos) do
		local redNum = activityProxy:getSquibCanTouchTime(v.activityId)
		self:setRedPoint(v.activityId, redNum)
	end	
	self:delaySendNotification(AppEvent.PROXY_REDPOINT_UPDATE, {})
end
--武学讲堂小红点
function RedPointProxy:setMartialRed()
	local activityProxy = self:getProxy(GameProxys.Activity)
	local martialInfos = activityProxy:getMartialInfos()
	for k,v in pairs(martialInfos) do
		local redNum = activityProxy:getMartialFreeTime(v.activityId)
		self:setRedPoint(v.activityId, redNum)
	end	
	self:delaySendNotification(AppEvent.PROXY_REDPOINT_UPDATE, {})
end
--煮酒论英雄小红点
function RedPointProxy:setCookingRed()
	local activityProxy = self:getProxy(GameProxys.Activity)
	local cookInfos = activityProxy:getCookInfos()
	for k,v in pairs(cookInfos) do
		local redNum = activityProxy:getCookFreeTime(v.activityId)
		self:setRedPoint(v.activityId, redNum)
	end	
	self:delaySendNotification(AppEvent.PROXY_REDPOINT_UPDATE, {})
end

--连续充值小红点
function RedPointProxy:setDayRechargeNumberRed()
	local activityProxy = self:getProxy(GameProxys.Activity)
	local activityData = activityProxy:getLimitActivityDataByUitype( ActivityDefine.LIMIT_DAYRECHARGE_ID )
	if activityData then
		local number = activityProxy:getDayRechargeNumber()
		self:setRedPoint( activityData.activityId, number )
		self:delaySendNotification(AppEvent.PROXY_REDPOINT_UPDATE, {})
	end
end
--国之重器小红点
function RedPointProxy:setBroadSealRed()
	local activityProxy = self:getProxy(GameProxys.Activity)
	local broadSealInfos = activityProxy:getBroadSealInfos()
	for k,v in pairs(broadSealInfos) do
		local redNum = activityProxy:getBroadSealFreeTime(v.activityId)
		self:setRedPoint(v.activityId, redNum)
	end	
	self:delaySendNotification(AppEvent.PROXY_REDPOINT_UPDATE, {})
end
--雄狮轮盘小红点
function RedPointProxy:setLionTurnRed()
	local activityProxy = self:getProxy(GameProxys.Activity)
	local lionTurnInfos = activityProxy:getLionTurnInfos()
	for k,v in pairs(lionTurnInfos) do
		local redNum = activityProxy:getLionTurnFreeTime(v.activityId)
		self:setRedPoint(v.activityId, redNum)
	end	
	self:delaySendNotification(AppEvent.PROXY_REDPOINT_UPDATE, {})
end
--幸运轮盘小红点
function RedPointProxy:setLuckTurnRed()
	local activityProxy = self:getProxy(GameProxys.Activity)
	local lionTurnInfos = activityProxy:getLionTurnInfos()
	for k,v in pairs(lionTurnInfos) do
		local redNum = activityProxy:getLionTurnFreeTime(v.activityId)
		self:setRedPoint(v.activityId, redNum)
	end	
	self:delaySendNotification(AppEvent.PROXY_REDPOINT_UPDATE, {})
end
--充值返利大放送小红点
function RedPointProxy:setRechargeRebateRed()
	local activityProxy = self:getProxy(GameProxys.Activity)
	local rechargeRebateInfos = activityProxy:getRechargeRebateInfos()
	for k,v in pairs(rechargeRebateInfos) do
		local redNum = activityProxy:getRechargeRebateRewardNum(v.activityId)
		self:setRedPoint(v.activityId, redNum)
	end	
	self:delaySendNotification(AppEvent.PROXY_REDPOINT_UPDATE, {})
end
--同盟致富小红点
function RedPointProxy:setLegionRichRed()
	local activityProxy = self:getProxy(GameProxys.Activity)

	local legionRichInfos = activityProxy:getLegionRichInfos()
	if next(legionRichInfos) == nil then
		--没有进盟没有活动数据
		local limitActivityInfos = activityProxy:getLimitActivityInfo()
		for i=1,#limitActivityInfos do
			local uitype = limitActivityInfos[i].uitype
			 if uitype == ActivityDefine.LIMIT_LEGIONRICH_ID then  
			 	self:setRedPoint(limitActivityInfos[i].activityId, 0)
			 end
		end
	else
		for k,v in pairs(legionRichInfos) do
			local redNum = activityProxy:getLegionRichRedNumById(v.activityId)
			self:setRedPoint(v.activityId, redNum)
		end
	end
	
	self:delaySendNotification(AppEvent.PROXY_REDPOINT_UPDATE, {})
end

--精绝古城小红点
function RedPointProxy:setJingJueRed()
	local activityProxy = self:getProxy(GameProxys.Activity)
	local jingJueInfos = activityProxy:getJingJueInfos()
	for k,v in pairs(jingJueInfos) do
		local redNum = activityProxy:getJingJueFreeTime(v.activityId)
		self:setRedPoint(v.activityId, redNum)
	end	
	self:delaySendNotification(AppEvent.PROXY_REDPOINT_UPDATE, {})
end
--礼贤下士小红点
function RedPointProxy:setConsortRed()
	local consrotProxy = self:getProxy(GameProxys.Consort)
    consrotProxy:setRedPoint()
end

--财源广进小红点
function RedPointProxy:setGetLotOfMoneyRed()
	local activityProxy = self:getProxy(GameProxys.Activity)
	local activityInfos = activityProxy:getGetLotOfMoneyInfos()
	local itemProxy = self:getProxy(GameProxys.Item)
	local itemNum = itemProxy:getItemNumByType(4703) --配置里没有  这里写死

	for k,v in pairs(activityInfos) do
		local info = activityProxy:getLimitActivityInfoById(v.activityId)
		if not info then
			return
		end 
		local effectId = info.effectId
		local activityConfigInfo = ConfigDataManager:getInfoFindByOneKey(ConfigData.BullionProportionConfig,"effectID",effectId)
		if activityConfigInfo then 
			local listInfo = ConfigDataManager:getInfosFilterByOneKey(ConfigData.LuckyLotteryDrawConfig,"lotteryID",activityConfigInfo.lotteryID)
			for _,value in pairs(listInfo) do
				local lotteryPrice = StringUtils:jsonDecode(value.lotteryPrice)
				if itemNum >= lotteryPrice[2] then
					self:setRedPoint(v.activityId,1)
					break
				else
					self:setRedPoint(v.activityId,0)
				end 
			end
		end
	end
	self:delaySendNotification(AppEvent.PROXY_REDPOINT_UPDATE, { })
end 

--聚宝盆小红点
function RedPointProxy:setCornucopiaRed()
	local activityProxy = self:getProxy(GameProxys.Activity)
	local activityInfos = activityProxy:getCornucopiaInfos()
	for k,v in pairs(activityInfos) do
		local info = activityProxy:getLimitActivityInfoById(v.activityId)
		if not info then
			return
		end
		self:setRedPoint(v.activityId,v.times)
	end
	self:delaySendNotification(AppEvent.PROXY_REDPOINT_UPDATE,{})
end 

function RedPointProxy:setPartsGodRed()
	local activityProxy = self:getProxy(GameProxys.Activity)
	local partsGodInfo = activityProxy:getPartsGodInfos()
	if partsGodInfo == nil or next(partsGodInfo) == nil then
		return
	end
	local redNum = activityProxy:getPartsGodFreeTime()
	self:setRedPoint(partsGodInfo.activityId, redNum)
	self:delaySendNotification(AppEvent.PROXY_REDPOINT_UPDATE, {})
end

function RedPointProxy:setAllLimitActivity()
	self:setPartsGodRed()
	self:setSoldierRed()
	self:setEmperorRed()
	self:setDayTrunRed()
	self:setVipRebateRed()
	self:setPullBarRed()
	self:setChargeShareRed()
	self:setSmashEggRed()
	self:setDayRechargeNumberRed()
	self:setCollectBlessRed()
	self:setSpringSquibRed()
	self:setMartialRed()
	self:setCookingRed()
	self:setBroadSealRed()
	self:setLionTurnRed()
	self:setLuckTurnRed()
	self:setJingJueRed()
    self:setConsortRed()
    self:setRechargeRebateRed()
	self:setLegionRichRed()

	local proxy = self:getProxy(GameProxys.BattleActivity)
	proxy:setActivityRedPoint()
	
	self:delaySendNotification(AppEvent.PROXY_REDPOINT_UPDATE, {})
end

function RedPointProxy:getAllLimitRedNum()
	local activityProxy = self:getProxy(GameProxys.Activity)
	local data = activityProxy:getLimitActivityInfo()
	local function findData(id)
		for k,v in pairs(data) do
			if v.activityId == id then
				return v
			end
		end
	end

	local num = 0
	for k,v in pairs(self._allRedPoint) do
		if findData(k) ~= nil then
			num = num + v
		end
	end
	return num
end

function RedPointProxy:updateServerActivity()
	local proxy = self:getProxy(GameProxys.BattleActivity)
	proxy:setActivityRedPoint()
	self:delaySendNotification(AppEvent.PROXY_REDPOINT_UPDATE, {})
end

function RedPointProxy:getServerActivityRedNum()
	local proxy = self:getProxy(GameProxys.BattleActivity)
	local data = proxy:getRedPointInfo()
	local num = 0
	for k,v in pairs(data) do
		num = num + v
	end
	return num
end

function RedPointProxy:updateCityBattleRedNum(number)
	self._lordCityRedNum = number
	self:updateServerActivity() -- 更新活动红点表格
end

--7938 屏蔽掉城主战 小红点
function RedPointProxy:getCityBattleRedNum()
	--return self._lordCityRedNum or 0                          --屏蔽代码
    return 0
end

function RedPointProxy:updateEmperorCityRedNum(number)
    self._emperorCityRedNum = number
    self:updateServerActivity() -- 更新活动红点表格
end

function RedPointProxy:getEmperorCityRedNum()
	return self._emperorCityRedNum or 0
end


return RedPointProxy
