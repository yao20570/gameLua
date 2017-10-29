
EquipSoulView = class("EquipSoulView", BasicView)

function EquipSoulView:ctor(parent)
    EquipSoulView.super.ctor(self, parent)
end

function EquipSoulView:finalize()
    EquipSoulView.super.finalize(self)
end

function EquipSoulView:registerPanels()
    EquipSoulView.super.registerPanels(self)

    require("modules.equipSoul.panel.EquipSoulPanel")
    self:registerPanel(EquipSoulPanel.NAME, EquipSoulPanel)
end

function EquipSoulView:initView()
    -- local panel = self:getPanel(EquipSoulPanel.NAME)
    -- panel:show()
end

function EquipSoulView:onShowView(extraMsg, isInit, isAutoUpdate)
    EquipSoulView.super.onShowView(self,extraMsg, isInit, false)
    local panel = self:getPanel(EquipSoulPanel.NAME)
    panel:show()
end

function EquipSoulView:updateView(data)
    local panel = self:getPanel(EquipSoulPanel.NAME)
    panel:updateView(data)
end

function EquipSoulView:resetView()
    local panel = self:getPanel(EquipSoulPanel.NAME)
    panel:onShowHandler()
end