
DayTurntablePanel = class("DayTurntablePanel", BasicPanel)
DayTurntablePanel.NAME = "DayTurntablePanel"

function DayTurntablePanel:ctor(view, panelName)
    DayTurntablePanel.super.ctor(self, view, panelName, true)
    
    self:setUseNewPanelBg(true)
end

function DayTurntablePanel:finalize()
    DayTurntablePanel.super.finalize(self)
end

function DayTurntablePanel:initPanel()
	DayTurntablePanel.super.initPanel(self)
	
	self:addTabControl()
end


function DayTurntablePanel:registerEvents()
	DayTurntablePanel.super.registerEvents(self)
end

function DayTurntablePanel:onClosePanelHandler()
    self.view:dispatchEvent(DayTurntableEvent.HIDE_SELF_EVENT)
end

function DayTurntablePanel:addTabControl()
    local function callback(panel, panelName, oldPanelName) 
        if panelName == DayTurntableRankPanel.NAME then
        local wheelPanel = self:getPanel(DayTurntableMainPanel.NAME)
	        if not wheelPanel.finish then
	        	self:showSysMessage(TextWords:getTextWord(280010))
	        	return false
	        end
            self:setBgType(ModulePanelBgType.NONE)
        else
            self:setBgType(ModulePanelBgType.ACTIVITY)
        end
        return true
    end
    
	local proxy = self:getProxy(GameProxys.Activity)
    local isRank = proxy.curActivityData.rankId

    self._tabControl = UITabControl.new(self, callback)
    self._tabControl:addTabPanel(DayTurntableMainPanel.NAME, self:getTextWord(18016))
    if isRank ~= 0 then
        self._tabControl:addTabPanel(DayTurntableRankPanel.NAME, self:getTextWord(18017))
    end
    self._tabControl:changeTabSelectByName(DayTurntableMainPanel.NAME)
    self:setTitle(true, "dayturntable", true) 
    self:setBgType(ModulePanelBgType.ACTIVITY)
end

function DayTurntablePanel:updateView(data)
	local panel = self:getPanel(DayTurntableMainPanel.NAME)
	panel:updateView(data)
end

function DayTurntablePanel:resetView()
    local panel = self:getPanel(DayTurntableMainPanel.NAME)
    panel:resetView()
end

function DayTurntablePanel:updateRankView()
    local panel = self:getPanel(DayTurntableRankPanel.NAME)
    panel:updateRankView()
end

function DayTurntablePanel:onShowHandler()
    if self._tabControl then
        self:getPanel(self._tabControl:getCurPanelName()):onShowHandler()
    end

end