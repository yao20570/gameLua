
TeamInfosPanel = class("TeamInfosPanel", BasicPanel)
TeamInfosPanel.NAME = "TeamInfosPanel"

---------------------------------------------------------------------------------------
function TeamInfosPanel:ctor(view, panelName)
    TeamInfosPanel.super.ctor(self, view, panelName, true)
    
    self:setUseNewPanelBg(true)
end

function TeamInfosPanel:finalize()
	if self._uITeamMiPanel then
	    self._uITeamMiPanel:finalize()
	end
    TeamInfosPanel.super.finalize(self)
end

function TeamInfosPanel:initPanel()
	TeamInfosPanel.super.initPanel(self)
	self:setTitle(true,"teamInfo",true)
	self:setBgType(ModulePanelBgType.TEAM)
	self:setLocalZOrder(1000)
	-- self._Panel_2 = self:getChildByName("Panel_2")
	-- self._Panel_2:setVisible(false)
	self._typeMap = {self:getTextWord(7050),self:getTextWord(7051),self:getTextWord(7052),self:getTextWord(7050),self:getTextWord(7053)}
end

function TeamInfosPanel:onClosePanelHandler()
    self:hide()
end

function TeamInfosPanel:show(data)
	TeamInfosPanel.super.show(self)
	self:onUpdateData(data)
end

-- function TeamInfosPanel:onUpdateData(data)
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
-- 	status:setString(self._typeMap[data.type])

-- 	-- count:setString(data.soldierNum.."/"..data.maxSoldierNum)
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
-- 		local statusStr = remainTime <= 0 and self:getTextWord(7054) or self:getTextWord(7052)
-- 		status:setString(statusStr)
-- 	end


-- 	if self._uITeamMiPanel == nil then
-- 		local tabsPanel = self:getTabsPanel()
-- 		self._uITeamMiPanel = UITeamMiPanel.new(self,nil,6,nil,nil)
-- 	end
-- 	self._uITeamMiPanel:setSoliderList(nil)
-- 	self._uITeamMiPanel:onCheckConsuData(data.fightInfos)
-- 	self._uITeamMiPanel:setSoliderList(data.fightInfos)
-- 	self._uITeamMiPanel:onShowConsuSuoImg(false)
-- end


-- ע�⣺��ߵ��޸ģ���Ҫ˳��Ķ�CheckTeamPanel.lua����������һ��
-- ע�⣺��ߵ��޸ģ���Ҫ˳��Ķ�CheckTeamPanel.lua����������һ��
-- ע�⣺��ߵ��޸ģ���Ҫ˳��Ķ�CheckTeamPanel.lua����������һ��
function TeamInfosPanel:onUpdateData(data)
	if self:isVisible() ~= true then
		return
	end

	if self._uITeamMiPanel == nil then
		-- local tabsPanel = self:getTabsPanel()
		local tabsPanel = self:topAdaptivePanel2()
        self._uITeamMiPanel = UITeamMiPanel.new(self, nil, 6, nil, tabsPanel, true)
	end
	self._uITeamMiPanel:setSoliderList(nil)
	self._uITeamMiPanel:onCheckConsuData(data.fightInfos)
	self._uITeamMiPanel:setSoliderList(data.fightInfos)
	self._uITeamMiPanel:onShowConsuSuoImg(false)

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

	if data.type == 1 or data.type == 2 then  --1.����,2����
		statusStr = self._typeMap[data.type]
        time = remainTime
	elseif data.type == 3 then --3�ھ�
        local count = math.ceil(remainTime)
        time = count
		statusStr = remainTime <= 0 and self:getTextWord(7054) or self:getTextWord(7052)
	elseif data.type == 4 then --4 ����פ��
		time = nil
		statusStr = nil
	elseif data.type == 5 then --5 פ����
		time = nil
		statusStr = nil
	elseif data.type == 6 then --6 ���˵�פ��
		time = nil
		statusStr = nil		
	end

	-- logger:info("type,fightCap,target,weight,curNum,maxNum : %d %d %s %d %d %d",data.type,fightCap,target,weight,curNum,maxNum)

	self._uITeamMiPanel:clearTopInfo()
	self._uITeamMiPanel:setTargetCity(target)
	self._uITeamMiPanel:setFirstNumber(data.initiative)
	self._uITeamMiPanel:setCurrWeight(weight)
	self._uITeamMiPanel:setSolidertime(time)
	self._uITeamMiPanel:setCurrStatus(statusStr)

	self._uITeamMiPanel:setCurrFight(fightCap) -- ����ս�� TeamWorkPanel:onInfoClickHandle(sender)
	self._uITeamMiPanel:setSolderCount(curNum,maxNum)

    -- fightType��ֵ��Ӱ��ս����ʾ
    self._uITeamMiPanel:setSubBattleType(0)
    local fightType = 0
    if data.targetType == 1 then    
        fightType = 5
    elseif data.targetType == 2 then
        fightType = 4
    	local worldProxy = self:getProxy(GameProxys.World)
    	self._uITeamMiPanel:setSubBattleType(worldProxy:getSubBattleType(data.level))
    elseif data.targetType == 4 then
        fightType = 14
    elseif data.targetType == 5 then -- 16=������սpvp, 17=������սpve
        fightType = 16
    elseif data.targetType == 6 then
        fightType = 17
    end
	self._uITeamMiPanel:showLostInfo(true, fightType)
	



	
	self._uITeamMiPanel:onShowBtnAndLabel()

	-- �����ʾǰ����ť
	self._uITeamMiPanel:updateJumpBtn(data)
end

function TeamInfosPanel:onClose()
	self:hide()
	self:dispatchEvent(TeamEvent.HIDE_SELF_EVENT)
end
