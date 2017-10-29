TeamSetPanel = class("TeamSetPanel", BasicPanel) --设置部队界面
TeamSetPanel.NAME = "TeamSetPanel"

function TeamSetPanel:ctor(view, panelName)
    TeamSetPanel.super.ctor(self, view, panelName)
    
    self:setUseNewPanelBg(true)
end

function TeamSetPanel:finalize()
	if self.uITeamMiPanel then
	    self.uITeamMiPanel:finalize()
	end
	self.uITeamMiPanel = nil
    TeamSetPanel.super.finalize(self)
end

function TeamSetPanel:initPanel()
    TeamSetPanel.super.initPanel(self)

end

function TeamSetPanel:onShowHandler()	
	-- if self:isModuleRunAction() then
	-- 	return
	-- end
end

function TeamSetPanel:doLayout()
    if not self.uITeamMiPanel then
    	local tabsPanel = self:getTabsPanel()
        self.uITeamMiPanel = UITeamMiPanel.new(self,nil,10,nil,tabsPanel)
    end
end

function TeamSetPanel:onAfterActionHandler()
	self:onShowHandler()
end

function TeamSetPanel:onTabChangeEvent(tabControl)
    local downWidget = self:getChildByName("DownPanel")
    TeamSetPanel.super.onTabChangeEvent(self, tabControl, downWidget)

    --切换页的时候刷新一下队伍界面
    if self.uITeamMiPanel ~= nil and self._sendData ~= nil and self._uiType ~= nil then
		self.uITeamMiPanel:onUpdateData(self._sendData, self._uiType)
    elseif not self.uITeamMiPanel then
    	-- 从别的标签页切换过来，是第一次创建
    	local proxy = self:getProxy(GameProxys.Soldier)
    	proxy:setMaxFighAndWeight()
    	
		local forxy = self:getProxy(GameProxys.Soldier)
		local data = forxy:onGetTeamInfo()
		data = data[2].members   --防守阵型

		self:updateTeamSet(data, 2, nil, nil, nil)
	end
end 

function TeamSetPanel:updateTeamSet(Data, showType, subBattleType, otherCityStr, isNeedBody, isPlayerRes)
    self._uiType = showType
    local _data = { }
    _data.city = otherCityStr
    _data.isPlayerRes = isPlayerRes

    self._sendData = _data
    if not self.uITeamMiPanel then
        local tabsPanel = self:getTabsPanel()
        self.uITeamMiPanel = UITeamMiPanel.new(self, _data, showType, nil, tabsPanel)
        self.uITeamMiPanel:setSubBattleType(subBattleType or 0)
    else
        self.uITeamMiPanel:setSubBattleType(subBattleType or 0)
        self.uITeamMiPanel:onUpdateData(_data, showType)
    end
end

function TeamSetPanel:onBuyTimesResp(data)
    if data.type == 1 then
        local function callbk()
            self:dispatchEvent(TeamEvent.BUYTIMES_REQ,2)
        end
        self:showMessageBox(self:getTextWord(200105)..data.money..self:getTextWord(200106),callbk)
    elseif data.type == 2 then
        local proxy = self:getProxy(GameProxys.Dungeon)
        local currentTimes =  proxy:setCurrentTimes(data.advanceTimes)
    end
end

function TeamSetPanel:setSolidertime(time) --行军时间
    self.uITeamMiPanel:setSolidertime(time)
end

function TeamSetPanel:onTouchProtectBtnHandle(sendData) --保存防守阵型
    self:dispatchEvent(TeamEvent.KEEP_TEAM_REQ,sendData)
    self:dispatchEvent(TeamEvent.HIDE_SELF_EVENT,sendData)
end

function TeamSetPanel:onTouchFightBtnHandle(sendData) --出战
    self:dispatchEvent(TeamEvent.GOFIGHT_REQ,sendData)
end


