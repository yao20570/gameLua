

RegionView = class("RegionView", BasicView)



function RegionView:ctor(parent)

    RegionView.super.ctor(self, parent)

end



function RegionView:finalize()

    RegionView.super.finalize(self)

end



function RegionView:registerPanels()

    RegionView.super.registerPanels(self)



    require("modules.region.panel.RegionPanel")

    self:registerPanel(RegionPanel.NAME, RegionPanel)

    require("modules.region.panel.CenterRegionPanel")

    self:registerPanel(CenterRegionPanel.NAME, CenterRegionPanel)

    require("modules.region.panel.TravelPanel")

    self:registerPanel(TravelPanel.NAME, TravelPanel)

end



function RegionView:initView()

    local panel = self:getPanel(RegionPanel.NAME)

    panel:show()

end



--更新副本信息 
--更新民心
function RegionView:updateDungeonInfoList(dungeonInfoList)

    local CenterRegionPanel = self:getPanel(CenterRegionPanel.NAME)

    CenterRegionPanel:updateDungeonInfoList(dungeonInfoList)

    local RegionPanel = self:getPanel(RegionPanel.NAME)

    RegionPanel:updatePeopleRed()

    RegionPanel:updateRedPoint()
end

--角色信息改变,民心改变
function RegionView:updateRoleInfoHandler()

    local RegionPanel = self:getPanel(RegionPanel.NAME)

    RegionPanel:updatePeopleRed()

end

--刷新远征数据
function RegionView:updateInfoResp()

    local panel = self:getPanel(TravelPanel.NAME)

    panel:updateInfoResp()

end



function RegionView:onShowView(extraMsg, isInit, isAutoUpdate)

    RegionView.super.onShowView(self,extraMsg, isInit, false)

    self:updateRoleInfoHandler()

end

function RegionView:hideModuleHandler()
    self:dispatchEvent(RegionEvent.HIDE_SELF_EVENT, {})
end