
EquipImgView = class("EquipImgView", BasicView)

function EquipImgView:ctor(parent)
    EquipImgView.super.ctor(self, parent)
end

function EquipImgView:finalize()
    EquipImgView.super.finalize(self)
end

function EquipImgView:registerPanels()
    EquipImgView.super.registerPanels(self)

    require("modules.equipImg.panel.EquipImgPanel")
    self:registerPanel(EquipImgPanel.NAME, EquipImgPanel)
end

function EquipImgView:initView()
    -- local panel = self:getPanel(EquipImgPanel.NAME)
    -- panel:show()
end

function EquipImgView:onShowView(extraMsg, isInit, isAutoUpdate)
    EquipImgView.super.onShowView(self,extraMsg, isInit, false)
    local panel = self:getPanel(EquipImgPanel.NAME)
    panel:show()
end

function EquipImgView:updateView(forceUpdate)
    -- local panel = self:getPanel(EquipImgPanel.NAME)
    -- local index = panel.curIndex or 1
    -- panel:updateView(index, forceUpdate)
end