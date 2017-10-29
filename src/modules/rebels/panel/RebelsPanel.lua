
RebelsPanel = class("RebelsPanel", BasicPanel)
RebelsPanel.NAME = "RebelsPanel"

function RebelsPanel:ctor(view, panelName)
    RebelsPanel.super.ctor(self, view, panelName, true)
    self:setUseNewPanelBg(true)
end

function RebelsPanel:finalize()
    RebelsPanel.super.finalize(self)
end

function RebelsPanel:initPanel()
	RebelsPanel.super.initPanel(self)
    self:addTabControl()
end

function RebelsPanel:registerEvents()
	RebelsPanel.super.registerEvents(self)
end

function RebelsPanel:addTabControl()
    self._tabControl = UITabControl.new(self)
    self._tabControl:addTabPanel(RebelsInfoPanel.NAME, self:getTextWord(401000))
    self._tabControl:addTabPanel(RebelsRankPanel.NAME, self:getTextWord(401001))
    self._tabControl:addTabPanel(RebelsRewardPanel.NAME, self:getTextWord(401002))
    self._tabControl:setTabSelectByName(RebelsInfoPanel.NAME)
    --self:setTitle(true,"叛军")
    self:setTitle(true, "dijunlaixi", true)
end

function RebelsPanel:onClosePanelHandler()
    self:dispatchEvent(RebelsEvent.HIDE_SELF_EVENT)
end

-- 更新叛军排行奖励小红点
function RebelsPanel:updateRewardRedCount()
    
    local rebelsProxy = self:getProxy(GameProxys.Rebels)
    local redCount = rebelsProxy:getRankRewardRedPointCount()
    if redCount > 0 then
        self._tabControl:setItemCount(3, true, redCount)
    else
        self._tabControl:setItemCount(3, false, 0)
    end 

end