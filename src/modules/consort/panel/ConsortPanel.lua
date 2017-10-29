

ConsortPanel = class("ConsortPanel", BasicPanel)

ConsortPanel.NAME = "ConsortPanel"



function ConsortPanel:ctor(view, panelName)

    ConsortPanel.super.ctor(self, view, panelName, true)

    self:setUseNewPanelBg(true)
end



function ConsortPanel:finalize()

    ConsortPanel.super.finalize(self)

end



function ConsortPanel:initPanel()

	ConsortPanel.super.initPanel(self)

    self:addTabControl()

end



function ConsortPanel:registerEvents()

	ConsortPanel.super.registerEvents(self)

end



function ConsortPanel:addTabControl()
    local function callback(panel, panelName, oldPanelName) 
        if panelName == ConsortRankPanel.NAME then
            self:setBgType(ModulePanelBgType.NONE)
        else
            self:setBgType(ModulePanelBgType.ACTIVITY)
        end
        return true
    end

    
	local proxy = self:getProxy(GameProxys.Activity)
    local isRank = proxy.curActivityData.rankId

    self._tabControl = UITabControl.new(self, callback)
    self._tabControl:addTabPanel(ConsortInfoPanel.NAME, self:getTextWord(430000))
    if isRank ~= 0 then
        self._tabControl:addTabPanel(ConsortRankPanel.NAME, self:getTextWord(430001))
    end
    self._tabControl:setTabSelectByName(ConsortInfoPanel.NAME)

    --self:setTitle(true,"礼贤下士")

    self:setTitle(true, "consort", true)
    self:setBgType(ModulePanelBgType.ACTIVITY)

end



function ConsortPanel:onClosePanelHandler()

    self:dispatchEvent(ConsortEvent.HIDE_SELF_EVENT)

end