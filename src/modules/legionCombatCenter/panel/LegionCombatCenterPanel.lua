
LegionCombatCenterPanel = class("LegionCombatCenterPanel", BasicPanel)
LegionCombatCenterPanel.NAME = "LegionCombatCenterPanel"

function LegionCombatCenterPanel:ctor(view, panelName)
    LegionCombatCenterPanel.super.ctor(self, view, panelName, true)
    
    self:setUseNewPanelBg(true)
end

function LegionCombatCenterPanel:finalize()
    LegionCombatCenterPanel.super.finalize(self)
end

function LegionCombatCenterPanel:initPanel()
	LegionCombatCenterPanel.super.initPanel(self)
    self._dungeonXProxy = self:getProxy(GameProxys.DungeonX)
    self:setBgType(ModulePanelBgType.NONE)
	self:addTabControl()
end

function LegionCombatCenterPanel:onShowHandler()
    -- 设置标签页红点
    self:updateTabItemCount()

    -- 判断标签页显示
    self:isShowActivityTab()
end

function LegionCombatCenterPanel:registerEvents()
	LegionCombatCenterPanel.super.registerEvents(self)
end

function LegionCombatCenterPanel:addTabControl()
    local tabControl = UITabControl.new(self)
    tabControl:addTabPanel(LegionCapterPanel.NAME, self:getTextWord(3600))
    tabControl:addTabPanel(LegionActivityPanel.NAME, self:getTextWord(123))
    tabControl:setTabSelectByName(LegionCapterPanel.NAME)
    self._tabControl = tabControl
    
    self:setTitle(true,"combatCenter",true)
end

function LegionCombatCenterPanel:setFirstPanelShow()
end

function LegionCombatCenterPanel:onClosePanelHandler()
    self.view:hideModuleHandler()
end

-- 是否显示战斗标签
function LegionCombatCenterPanel:isShowActivityTab()
    
    local data = self:getProxy(GameProxys.BattleActivity):getLegionFightActivity()
    if table.size(data) > 0 then
        self._tabControl:setTabVisibleByIndex(2,true)
    else
        self._tabControl:setTabVisibleByIndex(2,false)
    end
    --print("战斗标签数据量："..table.size(data))
end

-- 设置标签页红点
function LegionCombatCenterPanel:updateTabItemCount()
    local redCount = self._dungeonXProxy:canGetAllCurBoxCount()

    self._tabControl:setItemCount(1, true, redCount)
end

