
BarrackView = class("BarrackView", BasicView)

function BarrackView:ctor(parent)
    BarrackView.super.ctor(self, parent)
end

function BarrackView:finalize()
    if self._uiSoldierInfo ~= nil then
        self._uiSoldierInfo:finalize()
    end
    BarrackView.super.finalize(self)
end

function BarrackView:registerPanels()
    BarrackView.super.registerPanels(self)

    require("modules.barrack.panel.BarrackPanel")
    self:registerPanel(BarrackPanel.NAME, BarrackPanel)
    
    require("modules.barrack.panel.RecruitingPanel")
    self:registerPanel(RecruitingPanel.NAME, RecruitingPanel)
    
    require("modules.barrack.panel.BarrackBuildPanel")
    self:registerPanel(BarrackBuildPanel.NAME, BarrackBuildPanel)
    
    require("modules.barrack.panel.BarrackRecruitPanel")
    self:registerPanel(BarrackRecruitPanel.NAME, BarrackRecruitPanel)
    
    require("modules.barrack.panel.BarrackProductPanel")
    self:registerPanel(BarrackProductPanel.NAME, BarrackProductPanel)

    require("modules.barrack.panel.BarrackSoldierTipPanel")
    self:registerPanel(BarrackSoldierTipPanel.NAME, BarrackSoldierTipPanel)
    
    require("modules.barrack.panel.BarrackTipPanel")
    self:registerPanel(BarrackTipPanel.NAME, BarrackTipPanel)
end

function BarrackView:initView()
    local panel = self:getPanel(BarrackPanel.NAME)
    panel:show()
    
end

--注册BuildingProxy内部的协议
function BarrackView:registerBuildingProxyEvent()
    local buildingProxy = self:getProxy(GameProxys.Building)
    buildingProxy:registerCurBuilingInfoChangeEvent(self, self.onUpdateBuildingInfo)
end

--在当前界面，才会收到相关的建筑信息更新
function BarrackView:onUpdateBuildingInfo()
    local panel = self:getPanel(RecruitingPanel.NAME)
    if panel:isInitUI() then
        panel:onUpdateBuildingInfo()
    end
    
    local panel = self:getPanel(BarrackPanel.NAME)
    if panel:isInitUI() then
        panel:onUpdateBuildingInfo()
    end
    
    local panel = self:getPanel(BarrackRecruitPanel.NAME)
    if panel:isInitUI() then
        panel:onUpdateBuildingInfo()
    end
    
    local panel = self:getPanel(BarrackBuildPanel.NAME)
    if panel:isInitUI() then
        panel:onUpdateBuildingInfo()
    end
end


function BarrackView:onCloseView()
    BarrackView.super.onCloseView(self)
    -- local panel = self:getPanel(BarrackPanel.NAME)
    -- panel:changeTabSelectByName(BarrackBuildPanel.NAME)
    
    local panel = self:getPanel(RecruitingPanel.NAME)
    if panel:isInitUI() then
        panel:onResetPanel()
    end
    
    
    local buildingProxy = self:getProxy(GameProxys.Building)
    buildingProxy:clearEvent()
end

function BarrackView:onShowView(extraMsg, isInit)
    BarrackView.super.onShowView(self,extraMsg, isInit)
    
    self:registerBuildingProxyEvent()
    
    local panel = self:getPanel(BarrackPanel.NAME)
    panel:onUpdateBuildingInfo()
    
    local panel = self:getPanel(BarrackBuildPanel.NAME)
    panel:onUpdateBuildingInfo()
end

function BarrackView:showSoldierInfo(typeid)
    local soldierProxy = self:getProxy(GameProxys.Soldier)
    soldierProxy:showSoldierInfo(self, typeid)
end

-- 从招兵切换标签到招兵中 280006的返回触发这里
function BarrackView:buildingProdHandler()
    local panel = self:getPanel(BarrackProductPanel.NAME)
    panel:hide()
    local panel = self:getPanel(BarrackPanel.NAME)
    panel:changeTabSelectByName(RecruitingPanel.NAME)
end

-- 弹窗招兵时，断线重连，触发这里
function BarrackView:reconnectHandler()
    local panel = self:getPanel(BarrackProductPanel.NAME)
    if panel:isVisible() == true then
        panel:hide()
        local panel = self:getPanel(BarrackPanel.NAME)
        panel:changeTabSelectByName(BarrackBuildPanel.NAME)
    end
end
