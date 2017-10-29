-- CheckTeamPanel = class("CheckTeamPanel", BasicPanel)
-- CheckTeamPanel.NAME = "CheckTeamPanel"

-- -- 在队伍任务里面的team跳转的是CheckTeamPanel而不是这个CheckTeamPanel
-- -- 而CheckTeamPanel真正使用的UI资源是自身的结合UIteamMiPanel
-- function CheckTeamPanel:ctor(view, panelName)
--     CheckTeamPanel.super.ctor(self, view, panelName, true)
-- end

-- function CheckTeamPanel:finalize()
-- 	if self._uITeamMiPanel then
-- 	    self._uITeamMiPanel:finalize()
-- 	end
--     CheckTeamPanel.super.finalize(self)
-- end

-- function CheckTeamPanel:initPanel()
-- 	CheckTeamPanel.super.initPanel(self)
-- 	self:setLocalZOrder(1000)
-- 	self:setTitle(true,"teamInfo",true)
-- 	--self:setBgType(ModulePanelBgType.WHITE)
	
-- 	self._Panel_2 = self:getChildByName("Panel_2")
-- 	self._typeMap = {self:getTextWord(7050),self:getTextWord(7051),self:getTextWord(7052),self:getTextWord(7050),self:getTextWord(7053)}
--     self._typeHelp = { TextWords:getTextWord(4023), TextWords:getTextWord(4030)}
-- end

-- function CheckTeamPanel:onClosePanelHandler()
--     self:dispatchEvent(CheckTeamEvent.HIDE_SELF_EVENT)
-- end
-- -- 
-- function CheckTeamPanel:show(data)
-- 	CheckTeamPanel.super.show(self)
-- 	self:onUpdateData(data)
-- end

-- function CheckTeamPanel:onUpdateData(data)
-- 	local a = data.fightInfos[1].post
-- 	local fight = self._Panel_2:getChildByName("fight")
-- 	local count = self._Panel_2:getChildByName("count")
-- 	local countMax = self._Panel_2:getChildByName("countMax")
-- 	local weight = self._Panel_2:getChildByName("weight")
-- 	local status = self._Panel_2:getChildByName("status")
-- 	local weTime = self._Panel_2:getChildByName("weTime")
-- 	local walkTime = self._Panel_2:getChildByName("walkTime")
-- 	local walk = self._Panel_2:getChildByName("walk")
-- 	local timeStr = self._Panel_2:getChildByName("timeStr")

-- 	walkTime:setVisible(false)
-- 	weTime:setVisible(false)
-- 	walk:setVisible(false)
-- 	timeStr:setVisible(false)

-- 	fight:setString(StringUtils:formatNumberByK(data.capacity))
-- 	weight:setString(StringUtils:formatNumberByK(data.load))
--     if data.type == 6 then -- 6为驻防
--         status:setString(self._typeHelp[data.state])
--     else
-- 	    status:setString(self._typeMap[data.type])
--     end
-- 	count:setString(data.soldierNum)
-- 	countMax:setString("/"..data.maxSoldierNum)
-- 	local size = count:getContentSize()
-- 	local x,y = count:getPosition()
-- 	countMax:setPosition(x + size.width,y)

	
--     local soleierProxy = self:getProxy(GameProxys.Soldier)
--     local key = "teamTask"..data.id
--     local remainTime = soleierProxy:getRemainTime(key)
    
-- 	if data.type == 1 or data.type == 2 then
--         walkTime:setString(TimeUtils:getStandardFormatTimeString6(remainTime,true))
-- 		walkTime:setVisible(true)
-- 		walk:setVisible(true)
-- 	elseif data.type == 3 then
--         local count = math.ceil(remainTime)
--         weTime:setString(TimeUtils:getStandardFormatTimeString6(count,true))
--         weTime:setVisible(true)
--         timeStr:setVisible(true)
-- 		if data.alreadyTime >= data.totalTime then
-- 			status:setString(self:getTextWord(7054))
-- 		end
-- 	end
--     -- uimiteam
--     if self._uITeamMiPanel == nil then
-- 		self._uITeamMiPanel = UITeamMiPanel.new(self,nil,6,nil,nil)
-- 	end

--     self._uITeamMiPanel:setSoliderList(nil)
-- 	self._uITeamMiPanel:onCheckConsuData(data.fightInfos)
-- 	self._uITeamMiPanel:setSoliderList(data.fightInfos)
-- 	self._uITeamMiPanel:onShowConsuSuoImg(false)
-- end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
CheckTeamPanel = class("CheckTeamPanel", BasicPanel)
CheckTeamPanel.NAME = "CheckTeamPanel"

function CheckTeamPanel:ctor(view, panelName)
    CheckTeamPanel.super.ctor(self, view, panelName, true)

    self:setUseNewPanelBg(true)
end

function CheckTeamPanel:finalize()
	if self._uITeamMiPanel then
	    self._uITeamMiPanel:finalize()
	end
    CheckTeamPanel.super.finalize(self)
end

function CheckTeamPanel:initPanel()
	CheckTeamPanel.super.initPanel(self)
	self:setTitle(true,"teamInfo",true)
	self:setBgType(ModulePanelBgType.TEAM)
	self:setLocalZOrder(1000)
	self._typeMap = {self:getTextWord(7050),self:getTextWord(7051),self:getTextWord(7052),self:getTextWord(7050),self:getTextWord(7053)}
end

function CheckTeamPanel:onClosePanelHandler()
	self:dispatchEvent(CheckTeamEvent.HIDE_SELF_EVENT)
end

function CheckTeamPanel:onClose()
	self:onClosePanelHandler()
end

function CheckTeamPanel:show(data)
	CheckTeamPanel.super.show(self)
	self:onUpdateData(data)
end

function CheckTeamPanel:onUpdateData(data)
	if self._uITeamMiPanel == nil then
		local tabsPanel = self:topAdaptivePanel2()
		self._uITeamMiPanel = UITeamMiPanel.new(self,nil,6,nil,tabsPanel,true)
	end

    self._uITeamMiPanel:setTaskType(data.type) -- #5117新增

	self._uITeamMiPanel:setSoliderList(nil)
	self._uITeamMiPanel:onCheckConsuData(data.fightInfos)
	self._uITeamMiPanel:setSoliderList(data.fightInfos)
	for k,v in pairs(data.fightInfos) do
		print(v.post)
	end
	self._uITeamMiPanel:onShowConsuSuoImg(false)

	local posData = {}
	for k,v in pairs(data.fightInfos) do
		posData[k] = v.num > 0
	end

	local adviserId, adviserLv
	for k,v in pairs(data.fightInfos) do
		if v.post == 9 then
			adviserId = v.typeid
			adviserLv = v.adviserLv
		end
	end	
    if adviserId ~= nil then
		self._uITeamMiPanel:setAdviserData(adviserLv, adviserId)
	else
		self._uITeamMiPanel:setAdviserData(0, -100)
	end	


	local soleierProxy = self:getProxy(GameProxys.Soldier)
	local key = "teamTask"..data.id
	local remainTime = soleierProxy:getRemainTime(key)

	local fightCap = data.capacity
	local target = data.name
	local weight = data.load
	local curNum = data.soldierNum
	local maxNum = data.maxSoldierNum
	local time,statusStr

	if data.type == 1 or data.type == 2 then
		statusStr = self._typeMap[data.type]
        time = remainTime
	elseif data.type == 3 then
        local count = math.ceil(remainTime)
        time = count
		statusStr = remainTime <= 0 and self:getTextWord(7054) or self:getTextWord(7052)
	elseif data.type == 4 then --4 出发驻防
		time = nil
		statusStr = nil
	elseif data.type == 5 then --5 驻防中
		time = nil
		statusStr = nil
	elseif data.type == 6 then --6 别人的驻军
		time = nil
		statusStr = nil		
	end

	self._uITeamMiPanel:clearTopInfo()
	self._uITeamMiPanel:setTargetCity(target)
	self._uITeamMiPanel:setCurrWeight(weight)
	self._uITeamMiPanel:setSolidertime(time)
	self._uITeamMiPanel:setCurrStatus(statusStr)

	self._uITeamMiPanel:setCurrFight(fightCap)
	self._uITeamMiPanel:setSolderCount(curNum,maxNum)

    self._uITeamMiPanel:setSubBattleType(0)
	local fightType = 0
    if data.targetType == 1 then    
        fightType = 5
    elseif data.targetType == 2 then 
    	local worldProxy = self:getProxy(GameProxys.World)
    	self._uITeamMiPanel:setSubBattleType(worldProxy:getSubBattleType(data.level)) -- 任务目标类型：1=玩家，2=矿点，3=空地OR容错,4,叛军
    elseif data.targetType == 4 then
        fightType = 14    
    elseif data.targetType == 5 then -- 16=郡城盟战pvp, 17=郡城盟战pve
        fightType = 16
    elseif data.targetType == 6 then
        fightType = 17
    end
	self._uITeamMiPanel:showLostInfo(true, fightType)



	self._uITeamMiPanel:setFirstNumber(data.initiative)


	self._uITeamMiPanel:updatePosOpenStatus(posData)

    self._uITeamMiPanel:onShowBtnAndLabel()

    -- 矿点显示前往按钮
    self._uITeamMiPanel:updateJumpBtn(data)
end
