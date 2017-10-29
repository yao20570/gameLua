
ArenaShopView = class("ArenaShopView", BasicView)

function ArenaShopView:ctor(parent)
    ArenaShopView.super.ctor(self, parent)
end

function ArenaShopView:finalize()
    ArenaShopView.super.finalize(self)
end

function ArenaShopView:registerPanels()
    ArenaShopView.super.registerPanels(self)

    require("modules.arenaShop.panel.arenaShopPanel")
    self:registerPanel(arenaShopPanel.NAME, arenaShopPanel)
    require("modules.arenaShop.panel.arenaShopFightPanel")
    self:registerPanel(arenaShopFightPanel.NAME, arenaShopFightPanel)
    require("modules.arenaShop.panel.arenaShopResPanel")
    self:registerPanel(arenaShopResPanel.NAME, arenaShopResPanel)
    require("modules.arenaShop.panel.arenaShopGrowPanel")
    self:registerPanel(arenaShopGrowPanel.NAME, arenaShopGrowPanel)
end

function ArenaShopView:initView()
    local panel = self:getPanel(arenaShopPanel.NAME)
    panel:show()
    self._panelMap = {}
    self._panelMap["arenaShopFightPanel"] = self:getPanel(arenaShopFightPanel.NAME)
    self._panelMap["arenaShopResPanel"] = self:getPanel(arenaShopResPanel.NAME)
    self._panelMap["arenaShopGrowPanel"] = self:getPanel(arenaShopGrowPanel.NAME)
end

function ArenaShopView:hideModuleHandler()
	self:dispatchEvent(ArenaEvent.HIDE_SELF_EVENT, {})
end

function ArenaShopView:setOpenModule()
    local panel = self:getPanel(arenaShopPanel.NAME)
    if panel:isVisible() ~= true then
        panel:show()
    end
    panel:setOpenModule()
end

function ArenaShopView:onGetRoleInfo()
    for key,panel in pairs(self._panelMap) do
        if panel:isInitUI() == true then
            if panel:isVisible() == true then
                panel:updateRoleInfo()
            else
                local funMap = panel:getShowFunMapOpenFun()
                funMap["updateRoleInfo"] = {}
            end
        end
    end
    local panel = self:getPanel(arenaShopPanel.NAME)
    panel:updateRoleInfo()
end