
LegionActivityPanel = class("LegionActivityPanel", BasicPanel)
LegionActivityPanel.NAME = "LegionActivityPanel"

function LegionActivityPanel:ctor(view, panelName)
    LegionActivityPanel.super.ctor(self, view, panelName)
    
    self:setUseNewPanelBg(true)
end

function LegionActivityPanel:finalize()
    if self.infoPanel ~= nil then
        self.infoPanel:finalize()
    end
    self.infoPanel = nil
    LegionActivityPanel.super.finalize(self)
end

function LegionActivityPanel:initPanel()
    LegionActivityPanel.super.initPanel(self)
end

function LegionActivityPanel:registerEvents()
    LegionActivityPanel.super.registerEvents(self)
end

function LegionActivityPanel:onClosePanelHandler()
    self:dispatchEvent(ActivityCenterEvent.HIDE_SELF_EVENT)
end

function LegionActivityPanel:onAfterActionHandler()
    self:onShowHandler()
end

function LegionActivityPanel:doLayout()    
    -- local tabsPanel = self:getTabsPanel()
    -- -- NodeUtils:adaptiveTopPanelAndListView(mainPanel, ListView, GlobalConfig.downHeight, tabsPanel)
    -- NodeUtils:adaptiveListView(self.infoPanel, GlobalConfig.downHeight, tabsPanel)
end

function LegionActivityPanel:onShowHandler()
    if self:isModuleRunAction() then
        return
    end
    local proxy = self:getProxy(GameProxys.BattleActivity)
    local data = proxy:getActivityInfo()
    local cloneData = {}
    for k,v in pairs(clone(data)) do
        local isBattle = v.isLegion or 0 -- 是否是公会作战所活动
        if isBattle ~= 0 then
            table.insert(cloneData, v)
        end
    end
    if self.infoPanel == nil then
        self.infoPanel = UIBattleActivityPanel.new(self, cloneData, self:getTabsPanel())
    else
        self.infoPanel:updateData(cloneData)
    end
end