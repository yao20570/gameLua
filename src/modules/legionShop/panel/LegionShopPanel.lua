
LegionShopPanel = class("LegionShopPanel", BasicPanel)
LegionShopPanel.NAME = "LegionShopPanel"

function LegionShopPanel:ctor(view, panelName)
    LegionShopPanel.super.ctor(self, view, panelName,true)
    self.isCanShowOtherPanel = true
    
    self:setUseNewPanelBg(true)
end

function LegionShopPanel:finalize()
    LegionShopPanel.super.finalize(self)
end

function LegionShopPanel:initPanel()
	LegionShopPanel.super.initPanel(self)
    self:setBgType(ModulePanelBgType.NONE)
	self:addTabControl()
end

function LegionShopPanel:addTabControl()
    self.isCanShowOtherPanel = false
    local tabControl = UITabControl.new(self)
    tabControl:addTabPanel(LegionGoodsPanel.NAME, self:getTextWord(3301))
    tabControl:addTabPanel(LegionTreasureNewPanel.NAME, self:getTextWord(3302))
    tabControl:setTabSelectByName(LegionGoodsPanel.NAME)
    
    self._tabControl = tabControl
    
    -- self:setTitle(true, self:getTextWord(3300))
    self:setTitle(true,"legionShop",true)
end

function LegionShopPanel:registerEvents()
	LegionShopPanel.super.registerEvents(self)
end
function LegionShopPanel:onClosePanelHandler()
    self:dispatchEvent(LegionShopEvent.HIDE_SELF_EVENT)
end

function LegionShopPanel:resetTabSelectByName(name)
    self._tabControl:setTabSelectByName(name)
end

function LegionShopPanel:setFirstPanelShow()
    if self._tabControl then
        self._tabControl:setTabSelectByName(LegionGoodsPanel.NAME)
    end
end
function LegionShopPanel:onUpdateShopInfo()
    if not self._tabControl then
        return
    end
    local curPanelName = self._tabControl:getCurPanelName()
    local panel = self:getPanel(curPanelName)
    panel:onUpdatePanel()
end