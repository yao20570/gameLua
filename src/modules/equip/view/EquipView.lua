
EquipView = class("EquipView", BasicView)

function EquipView:ctor(parent)
    EquipView.super.ctor(self, parent)
end

function EquipView:finalize()
    EquipView.super.finalize(self)
end

function EquipView:registerPanels()
    EquipView.super.registerPanels(self)

    require("modules.equip.panel.EquipPanel")
    self:registerPanel(EquipPanel.NAME, EquipPanel)
    
    --require("modules.equip.panel.EquipMainPanel")
    --self:registerPanel(EquipMainPanel.NAME, EquipMainPanel) 

    require("modules.equip.panel.EquipMainPanelNewPanel")
    self:registerPanel(EquipMainPanelNewPanel.NAME, EquipMainPanelNewPanel)



    require("modules.equip.panel.EquipSelectPanel")
    self:registerPanel(EquipSelectPanel.NAME, EquipSelectPanel)
    require("modules.equip.panel.EquipUpNewPanel")
    self:registerPanel(EquipUpNewPanel.NAME, EquipUpNewPanel) 

    require("modules.equip.panel.EquipHeroChangePanel")
    self:registerPanel(EquipHeroChangePanel.NAME, EquipHeroChangePanel)

    require("modules.equip.panel.EquipAddPanel")
    self:registerPanel(EquipAddPanel.NAME, EquipAddPanel)

    require("modules.equip.panel.EquipHeroUpPanel")
    self:registerPanel(EquipHeroUpPanel.NAME, EquipHeroUpPanel)

    require("modules.equip.panel.EquipHeroGenghuanPanel")
    self:registerPanel(EquipHeroGenghuanPanel.NAME, EquipHeroGenghuanPanel)
    
end

function EquipView:initView()

end

function EquipView:hideModuleHandler()
    self:dispatchEvent(EquipEvent.HIDE_SELF_EVENT, {})
end

function EquipView:updateLevel(data)

end

function EquipView:wearResp(type)

end

function EquipView:exitWearResp()

end

function EquipView:equipSaleResp()

end

function EquipView:updateTouchState()
    local panel = self:getPanel(EquipMainPanelNewPanel.NAME)
    panel:addEventTochLayer()
end

function EquipView:onUpEquipResp()
    local panel = self:getPanel(EquipUpNewPanel.NAME)
    if panel:isVisible() == true then
        panel:playEquipLvUpEffect()
    end
end

function EquipView:onIncreaseResp(count)
    panel = self:getPanel(EquipAddPanel.NAME)
    if panel:isVisible() == true then
        panel:updateNums(count)
    end
end

function EquipView:onShowView(extraMsg, isInit, isAutoUpdate)
    EquipView.super.onShowView(self,extraMsg, isInit, false)
    local panel = self:getPanel(EquipHeroChangePanel.NAME)
    panel:show()
end

function EquipView:onUpdateAllEquips(type)
    local panel = self:getPanel(EquipUpNewPanel.NAME)
    if panel:isVisible() == true then
        panel:onOpenUpPanel()
    end
    panel = self:getPanel(EquipSelectPanel.NAME)
    if panel:isVisible() == true then
        panel:wearResp()
    end
    panel = self:getPanel(EquipMainPanelNewPanel.NAME)
    if panel:isVisible() == true then
        panel:updateInfosByPos()
    end
    panel = self:getPanel(EquipHeroChangePanel.NAME)
    if panel:isVisible() == true then
        panel:show()
    end    
    panel = self:getPanel(EquipAddPanel.NAME)
    if panel:isVisible() == true then
        panel:updateListData()
        panel:updateNums()
    end
end

function EquipView:onUpdateAllhero()
    local panel = self:getPanel(EquipHeroGenghuanPanel.NAME)
    if panel:isVisible() == true then
        panel:onShowHandler()
    end
    panel = self:getPanel(EquipHeroUpPanel.NAME)
    if panel:isVisible() == true then
        panel:updateView()
    end

    panel = self:getPanel(EquipHeroChangePanel.NAME)
    if panel:isVisible() == true then
        panel:show()
    end  
end

function EquipView:updateView()
    local panel = self:getPanel(EquipMainPanelNewPanel.NAME)
    panel:setInfos(panel._curentPageIndex)
end