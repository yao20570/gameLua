
HeroTreaWarehouseView = class("HeroTreaWarehouseView", BasicView)

function HeroTreaWarehouseView:ctor(parent)
    HeroTreaWarehouseView.super.ctor(self, parent)
end

function HeroTreaWarehouseView:finalize()
    HeroTreaWarehouseView.super.finalize(self)
end

function HeroTreaWarehouseView:registerPanels()
    HeroTreaWarehouseView.super.registerPanels(self)

    require("modules.heroTreaWarehouse.panel.HeroTreaWarehousePanel")
    self:registerPanel(HeroTreaWarehousePanel.NAME, HeroTreaWarehousePanel)

    require("modules.heroTreaWarehouse.panel.HeroTreaAllItemPanel")
    self:registerPanel(HeroTreaAllItemPanel.NAME, HeroTreaAllItemPanel)

    require("modules.heroTreaWarehouse.panel.HeroTreaFragmentPanel")
    self:registerPanel(HeroTreaFragmentPanel.NAME, HeroTreaFragmentPanel)

    require("modules.heroTreaWarehouse.panel.HeroTreaMaterialPanel")
    self:registerPanel(HeroTreaMaterialPanel.NAME, HeroTreaMaterialPanel)

    require("modules.heroTreaWarehouse.panel.HTBatchSelectPanel")
    self:registerPanel(HTBatchSelectPanel.NAME, HTBatchSelectPanel)

    require("modules.heroTreaWarehouse.panel.HeroTreaDetailPanel")
    self:registerPanel(HeroTreaDetailPanel.NAME, HeroTreaDetailPanel)



end

function HeroTreaWarehouseView:initView()
    local panel = self:getPanel(HeroTreaWarehousePanel.NAME)
    panel:show()
end
function HeroTreaWarehouseView:treasureInfoChange()
    local heroTreaAllItemPanel = self:getPanel(HeroTreaAllItemPanel.NAME)
    heroTreaAllItemPanel:updateListView()
end
function HeroTreaWarehouseView:treasurePieceInfoChange()
    local heroTreaFragmentPanel = self:getPanel(HeroTreaFragmentPanel.NAME)
    heroTreaFragmentPanel:updateListView()
end