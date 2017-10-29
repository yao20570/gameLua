
ScienceMuseumView = class("ScienceMuseumView", BasicView)

function ScienceMuseumView:ctor(parent)
    ScienceMuseumView.super.ctor(self, parent)
end

function ScienceMuseumView:finalize()
    ScienceMuseumView.super.finalize(self)
end

function ScienceMuseumView:registerPanels()
    ScienceMuseumView.super.registerPanels(self)

    require("modules.scienceMuseum.panel.ScienceMuseumPanel")
    self:registerPanel(ScienceMuseumPanel.NAME, ScienceMuseumPanel)
    
    require("modules.scienceMuseum.panel.ScienceBuildPanel")
    self:registerPanel(ScienceBuildPanel.NAME, ScienceBuildPanel)
    
    require("modules.scienceMuseum.panel.ScienceResearchPanel")
    self:registerPanel(ScienceResearchPanel.NAME, ScienceResearchPanel)
end

function ScienceMuseumView:initView()
    local panel = self:getPanel(ScienceMuseumPanel.NAME)
    panel:show()
end

--注册BuildingProxy内部的协议
function ScienceMuseumView:registerBuildingProxyEvent()
    local buildingProxy = self:getProxy(GameProxys.Building)
    buildingProxy:registerCurBuilingInfoChangeEvent(self, self.onUpdateBuildingInfo)
end
--在当前界面，才会收到相关的建筑信息更新
function ScienceMuseumView:onUpdateBuildingInfo()
    local panel = self:getPanel(ScienceMuseumPanel.NAME)
    panel:onUpdateBuildingInfo()

    local panel = self:getPanel(ScienceBuildPanel.NAME)
    panel:onUpdateBuildingInfo()

    local upSuccess = true
    local panel = self:getPanel(ScienceResearchPanel.NAME)
    panel:onUpdateBuildingInfo(upSuccess)

end

function ScienceMuseumView:onCloseView()
    ScienceMuseumView.super.onCloseView(self)
    -- local panel = self:getPanel(ScienceMuseumPanel.NAME)
    -- panel:changeTabSelectByName(ScienceBuildPanel.NAME)

    
    local buildingProxy = self:getProxy(GameProxys.Building)
    buildingProxy:clearEvent()
end

function ScienceMuseumView:onShowView(extraMsg, isInit)
    ScienceMuseumView.super.onShowView(self,extraMsg, isInit)
    
    self:registerBuildingProxyEvent()

    local panel = self:getPanel(ScienceMuseumPanel.NAME)
    panel:onUpdateBuildingInfo()

    local panel = self:getPanel(ScienceBuildPanel.NAME)
    panel:onUpdateBuildingInfo()
end