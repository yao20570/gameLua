-- 设置我方阵型信息
LordCityTeamSetPanel = class("LordCityTeamSetPanel", BasicPanel)
LordCityTeamSetPanel.NAME = "LordCityTeamSetPanel"
function LordCityTeamSetPanel:ctor(view, panelName)
    LordCityTeamSetPanel.super.ctor(self, view, panelName,true)
    self:setUseNewPanelBg(true)
end

function LordCityTeamSetPanel:finalize()
    if self.teamPanel then
        self.teamPanel:finalize()
    end
    LordCityTeamSetPanel.super.finalize(self)

end

function LordCityTeamSetPanel:initPanel()
    LordCityTeamSetPanel.super.initPanel(self)
    self:setTitle(true, "setTeam", true)
    self:setBgType(ModulePanelBgType.TEAM)
    self._lordCityProxy = self:getProxy(GameProxys.LordCity)
end

function LordCityTeamSetPanel:onShowHandler(data)
    self._type = data.type
    self._info = data.info
    self._cityId = self._lordCityProxy:getSelectCityId()
    
    self._lordCityProxy:setLordCityTeamUI(self._type == 12)  --进攻方设置标记

    local soldierProxy = self:getProxy(GameProxys.Soldier)
    local teamInfos = soldierProxy:getLordCityAttackTeam()


    if self.teamPanel == nil then
        local tabsPanel = self:topAdaptivePanel2()
        self.teamPanel = UITeamMiPanel.new(self, teamInfos, self._type, nil, tabsPanel)
    else
        self.teamPanel:onUpdateData(teamInfos, self._type)
    end

    if not self:isRunShowPanelAction() then
        self:showPanelAction()
    end
end

function LordCityTeamSetPanel:panelActionCallback()
end

function LordCityTeamSetPanel:onClosePanelHandler()
    local panel = self:getPanel(LordCityBattlePanel.NAME)
    panel:onCityInfoUpdate()
    self:hidePanel()
end

--保存阵型的回调
function LordCityTeamSetPanel:onTouchProtectBtnHandle(data)
    -- print(".................... --保存阵型的回调 ")
    local sendData = {}
    sendData.cityId = self._cityId
    sendData.members = data.info.members
    self._lordCityProxy:onTriggerNet360014Req(sendData)

    local soldierProxy = self:getProxy(GameProxys.Soldier)
    soldierProxy:setLordCityAttackTeam(sendData.members)

end

-- 出战按钮的回调
function LordCityTeamSetPanel:onTouchFightBtnHandle(data)
    local type = self._info.type --进攻类型  --1=攻打boss，2=攻打玩家，3=攻打城墙
    local playerId = self._info.id

    local sendData = {}
    sendData.infos = data.infos

    if type == 1 then --1=攻打boss
        sendData.cityId = self._cityId
        self._lordCityProxy:onTriggerNet360021Req(sendData)
    
    elseif type == 2 then --2=攻打玩家
        sendData.cityId = self._cityId
        sendData.playerId = playerId
        self._lordCityProxy:onTriggerNet360023Req(sendData)

    elseif type == 3 then --3=攻打城墙
        sendData.cityId = self._cityId
        self._lordCityProxy:onTriggerNet360022Req(sendData)
    
    end

    local soldierProxy = self:getProxy(GameProxys.Soldier)
    soldierProxy:setLordCityAttackTeam(sendData.infos)

    self:hidePanel()
end

function LordCityTeamSetPanel:hidePanel()
    self._lordCityProxy:setLordCityTeamUI(false)
    self:hide()
end
