
arenaShopPanel = class("arenaShopPanel", BasicPanel)
arenaShopPanel.NAME = "arenaShopPanel"

function arenaShopPanel:ctor(view, panelName)
    arenaShopPanel.super.ctor(self, view, panelName,true)

    self:setUseNewPanelBg(true)
end

function arenaShopPanel:finalize()
    arenaShopPanel.super.finalize(self)
end

function arenaShopPanel:initPanel()
	arenaShopPanel.super.initPanel(self)

	self._tabControl = UITabControl.new(self)
    self._tabControl:addTabPanel(arenaShopFightPanel.NAME, self:getTextWord(1810))
    self._tabControl:addTabPanel(arenaShopResPanel.NAME, self:getTextWord(1811))
    self._tabControl:addTabPanel(arenaShopGrowPanel.NAME, self:getTextWord(1812))
    self._tabControl:setTabSelectByName(arenaShopFightPanel.NAME)

    
    
    self:setTitle(true,"jifenduihuan",true)
    self:setBgType(ModulePanelBgType.NONE)
end

--打开arenaShopPanel时，这个自适应无效，打开arenaShopFightPanel再调一次即可
function arenaShopPanel:doLayout() 
    local tabsPanel = self:getUpPanel()
    local topPanel = self:getTopPanel()

    NodeUtils:adaptiveTopPanelAndListView(topPanel, nil, nil, tabsPanel)
end

function arenaShopPanel:onClosePanelHandler()
	self.view:hideModuleHandler()
end

function arenaShopPanel:setOpenModule()
	self._tabControl:changeTabSelectByName(arenaShopFightPanel.NAME)
end

function arenaShopPanel:updateRoleInfo()
    local proxy = self:getProxy(GameProxys.Role)
    local count = proxy:getRoleAttrValue(PlayerPowerDefine.POWER_arenaGrade)
    
    local topPanel = self:getTopPanel()
    local score = topPanel:getChildByName("score")
    score:setString(count)
end

function arenaShopPanel:getTopPanel()
    -- body
    local topPanel = self:getChildByName("topPanel")
    return topPanel
end

function arenaShopPanel:getUpPanel()
    return self._tabControl:getTabsPanel()
end