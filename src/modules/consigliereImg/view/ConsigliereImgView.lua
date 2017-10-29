
ConsigliereImgView = class("ConsigliereImgView", BasicView)

function ConsigliereImgView:ctor(parent)
    ConsigliereImgView.super.ctor(self, parent)
end

function ConsigliereImgView:finalize()
    ConsigliereImgView.super.finalize(self)
end

function ConsigliereImgView:registerPanels()
    ConsigliereImgView.super.registerPanels(self)

    require("modules.consigliereImg.panel.ConsigliereImgAllPanel")
    self:registerPanel(ConsigliereImgAllPanel.NAME, ConsigliereImgAllPanel)

    require("modules.consigliereImg.panel.ConsigliereImgInfoPanel")
    self:registerPanel(ConsigliereImgInfoPanel.NAME, ConsigliereImgInfoPanel)
end

-- function ConsigliereImgView:initView()
--     local panel = self:getPanel(ConsigliereImgAllPanel.NAME)
--     panel:show()
-- end

function ConsigliereImgView:onShowView(extraMsg, isInit, isAutoUpdate)
    ConsigliereImgView.super.onShowView(self,extraMsg, isInit, false)
    local panel = self:getPanel(ConsigliereImgAllPanel.NAME)
    panel:show()
end