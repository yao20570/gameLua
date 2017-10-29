
TeamPanel = class("TeamPanel", BasicPanel)
TeamPanel.NAME = "TeamPanel"

function TeamPanel:ctor(view, panelName)
    TeamPanel.super.ctor(self, view, panelName, true)
    
    self:setUseNewPanelBg(true)
end

function TeamPanel:finalize()
    TeamPanel.super.finalize(self)
end

function TeamPanel:initPanel()
	TeamPanel.super.initPanel(self)
	self:addTabControl()
end

function TeamPanel:onClosePanelHandler()
    self.view:hideModuleHandler()
end

function TeamPanel:addTabControl()
    local function callback(panel, panelName)
        if panelName == TeamSetPanel.NAME then
	        self:setBgType(ModulePanelBgType.TEAM)
        else
	        self:setBgType(ModulePanelBgType.NONE)
        end
        return true
    end
    self._tabControl = UITabControl.new(self, callback)
    -- self._tabControl:setLocalZOrder(2)
    self._tabControl:addTabPanel(TeamSetPanel.NAME, self:getTextWord(700))
    self._tabControl:addTabPanel(TeamWorkPanel.NAME, self:getTextWord(701))
    self._tabControl:addTabPanel(TeamReparePanel.NAME, self:getTextWord(702))
    -- self._tabControl:addTabPanel(TeamSquirePanel.NAME, self:getTextWord(703))

    -- self._tabControl:setTabSelectByName(TeamSetPanel.NAME)
    self:setTitle(true,"budui", true)
	self:setBgType(ModulePanelBgType.TEAM)
end

function TeamPanel:setFirstPanelShow(type)
    if type == nil then
        local panel = self:getPanel(TeamSetPanel.NAME)
        --panel:setBtnVisible(true,false)
        self._tabControl:changeTabSelectByName(TeamSetPanel.NAME)
    else
--         local panel = self:getPanel(TeamSetPanel.NAME)
--         panel:hide()
         local panel = self:getPanel(TeamWorkPanel.NAME)
         panel:show()
        self._tabControl:changeTabSelectByName(TeamWorkPanel.NAME)
    end
end

function TeamPanel:updateItemCount()
    local soldierProxy = self:getProxy(GameProxys.Soldier)
    local data = soldierProxy:getBadSoldiersList()
    if data ~= nil then
        self._tabControl:setItemCount(3,true,table.size(data))
    end
end

function TeamPanel:onUpdateWorkCount(data)
    self._tabControl:setItemCount(2,true,table.size(data))
end