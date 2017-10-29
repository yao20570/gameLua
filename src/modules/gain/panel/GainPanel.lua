
GainPanel = class("GainPanel", BasicPanel)
GainPanel.NAME = "GainPanel"

function GainPanel:ctor(view, panelName)
    GainPanel.super.ctor(self, view, panelName,true)

    self:setUseNewPanelBg(true)
end

function GainPanel:finalize()
    GainPanel.super.finalize(self)
end

function GainPanel:initPanel()
	GainPanel.super.initPanel(self)	
    self:setTitle(true, "gain", true)
    self:setBgType(ModulePanelBgType.NONE)

    local tabControl = UITabControl.new(self)

    -- 道具
    tabControl:addTabPanel(GainInfoPanel.NAME, self:getTextWord(1608))

    -- 荣誉
    local isLock = FunctionShieldConfig:isShield( FunctionShield.HONOUR )
    if not isLock then
        tabControl:addTabPanel(GainHonourPanel.NAME,self:getTextWord(1607))
    end

    tabControl:setTabSelectByName(GainInfoPanel.NAME)
    -- self.allPanel = {GainInfoPanel.NAME}
    self._tabControl = tabControl
end

function GainPanel:registerEvents()
	GainPanel.super.registerEvents(self)
end

--发送关闭系统消息
function GainPanel:onClosePanelHandler()
    self.view:dispatchEvent(GainEvent.HIDE_SELF_EVENT)
end