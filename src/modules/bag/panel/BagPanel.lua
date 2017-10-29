
BagPanel = class("BagPanel", BasicPanel)
BagPanel.NAME = "BagPanel"

function BagPanel:ctor(view, panelName)
    BagPanel.super.ctor(self, view, panelName, true)
    self.isCanShowOtherPanel = true

    self:setUseNewPanelBg(true)
end

function BagPanel:finalize()
    BagPanel.super.finalize(self)
end

function BagPanel:initPanel()
	BagPanel.super.initPanel(self)
	
	self:addTabControl()
end

function BagPanel:addTabControl()
    self.isCanShowOtherPanel = false
    local tabControl = UITabControl.new(self)
    tabControl:addTabPanel(BagAllItemPanel.NAME, self:getTextWord(499))
    tabControl:addTabPanel(BagResourcePanel.NAME, self:getTextWord(500))
    tabControl:addTabPanel(BagGItemPanel.NAME, self:getTextWord(501))
    tabControl:addTabPanel(BagOItemPanel.NAME, self:getTextWord(502))
    tabControl:setTabSelectByName(BagAllItemPanel.NAME)
    
    self._tabControl = tabControl
    
    self:setTitle(true,"beibao",true)
    self:setBgType(ModulePanelBgType.NONE)
end

function BagPanel:onItemUpdate()
    local curPanelName = self._tabControl:getCurPanelName()
    local panel = self:getPanel(curPanelName)
    panel:onShowHandler()
end

function BagPanel:onClosePanelHandler()
    self.view:hideModuleHandler()
end

function BagPanel:useSurfaceGoods(data)
    local curPanelName = self._tabControl:getCurPanelName()
    local panel = self:getPanel(curPanelName)
    panel:useSurFaceGoods(data.typeId)
end