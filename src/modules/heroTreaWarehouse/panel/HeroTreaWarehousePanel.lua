
HeroTreaWarehousePanel = class("HeroTreaWarehousePanel", BasicPanel)
HeroTreaWarehousePanel.NAME = "HeroTreaWarehousePanel"

function HeroTreaWarehousePanel:ctor(view, panelName)
    HeroTreaWarehousePanel.super.ctor(self, view, panelName,true)

end

function HeroTreaWarehousePanel:finalize()
    HeroTreaWarehousePanel.super.finalize(self)
end

function HeroTreaWarehousePanel:initPanel()
	HeroTreaWarehousePanel.super.initPanel(self)
	self:addTabControl()


end

function HeroTreaWarehousePanel:addTabControl()
    self._tabControl = UITabControlOld.new(self)
    self._tabControl:addTabPanel(HeroTreaAllItemPanel.NAME, self:getTextWord(3803))
    self._tabControl:addTabPanel(HeroTreaFragmentPanel.NAME, self:getTextWord(3806))
    self._tabControl:addTabPanel(HeroTreaMaterialPanel.NAME, self:getTextWord(3816))
    self._tabControl:setTabSelectByName(HeroTreaAllItemPanel.NAME)
    --self:setTitle(true, self:getTextWord(3805))
    self:setTitle(true, "cangku", true)

    
end

function HeroTreaWarehousePanel:registerEvents()
	HeroTreaWarehousePanel.super.registerEvents(self)
end
function HeroTreaWarehousePanel:onClosePanelHandler()
    self.view:dispatchEvent(HeroTreaWarehouseEvent.HIDE_SELF_EVENT)
end