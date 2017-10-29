
MapView = class("MapView", BasicView)

function MapView:ctor(parent)
    MapView.super.ctor(self, parent)
end

function MapView:finalize()
    MapView.super.finalize(self)
end

function MapView:registerPanels()
    MapView.super.registerPanels(self)

    require("modules.map.panel.MapPanel")
    self:registerPanel(MapPanel.NAME, MapPanel)
    
    require("modules.map.panel.MapInfoPanel")
    self:registerPanel(MapInfoPanel.NAME, MapInfoPanel)
    
    require("modules.map.panel.MapGoalInfoPanel")
    self:registerPanel(MapGoalInfoPanel.NAME, MapGoalInfoPanel)
    
    require("modules.map.panel.MapSearchPanel")
    self:registerPanel(MapSearchPanel.NAME, MapSearchPanel)

    require("modules.map.panel.BanditPanel")
    self:registerPanel(BanditPanel.NAME, BanditPanel)

    require("modules.map.panel.MiniMapPanel")
    self:registerPanel(MiniMapPanel.NAME, MiniMapPanel)
    
    require("modules.map.panel.BanditCityInfoPanel")
    self:registerPanel(BanditCityInfoPanel.NAME, BanditCityInfoPanel)

    require("modules.map.panel.MapRebelsFightPanel")
    self:registerPanel(MapRebelsFightPanel.NAME, MapRebelsFightPanel)

    require("modules.map.panel.MapRebelsPanel")
    self:registerPanel(MapRebelsPanel.NAME, MapRebelsPanel)

    --require("modules.map.panel.MapExplainPanel")
    --self:registerPanel(MapExplainPanel.NAME, MapExplainPanel)
        
    require("modules.map.panel.MapLordCityPanel")
    self:registerPanel(MapLordCityPanel.NAME, MapLordCityPanel)

    require("modules.map.panel.MapLordCityVotePanel")
    self:registerPanel(MapLordCityVotePanel.NAME, MapLordCityVotePanel)

    require("modules.map.panel.MapLordCityRewardPanel")
    self:registerPanel(MapLordCityRewardPanel.NAME, MapLordCityRewardPanel)

    require("modules.map.panel.MapCityWarPanel")
    self:registerPanel(MapCityWarPanel.NAME, MapCityWarPanel)
    
    require("modules.map.panel.MapMyTownPanel")
    self:registerPanel(MapMyTownPanel.NAME, MapMyTownPanel)

    require("modules.map.panel.MapPlayerInfoPanel")
    self:registerPanel(MapPlayerInfoPanel.NAME, MapPlayerInfoPanel)

    require("modules.map.panel.MapUseCitySkillPanel")
    self:registerPanel(MapUseCitySkillPanel.NAME, MapUseCitySkillPanel)

    require("modules.map.panel.MapCityWarOnPanel")
    self:registerPanel(MapCityWarOnPanel.NAME, MapCityWarOnPanel)
    
    require("modules.map.panel.MapEmperorWarOnPanel")
    self:registerPanel(MapEmperorWarOnPanel.NAME, MapEmperorWarOnPanel)

    require("modules.map.panel.MapEmperorWarPanel")
    self:registerPanel(MapEmperorWarPanel.NAME, MapEmperorWarPanel)
end

function MapView:initView()

    local panel = self:getPanel(MapInfoPanel.NAME)
    panel:show()
--    panel:hide()
    
    local panel = self:getPanel(MapPanel.NAME)
    panel:show()
    
end

function MapView:onWatchPlayerInfo(data)
    local panel = self:getPanel(MapPanel.NAME)
    panel:onWatchPlayerInfo(data)
end
-- 接收服务端坐标点建筑数据后率刷新80000
function MapView:onGetWorldTileInfosResp(worldTileInfos)
    local mapPanel = self:getPanel(MapPanel.NAME)
    mapPanel:onGetWorldTileInfosResp(worldTileInfos)
end

function MapView:onUpdateLocalResTile()
    local mapPanel = self:getPanel(MapPanel.NAME)
    mapPanel:onUpdateLocalResTile()
end

function MapView:initMap()
    local mapPanel = self:getPanel(MapPanel.NAME)
    mapPanel:initMap()
end

function MapView:onShowView(extraMsg, isInit)
    MapView.super.onShowView(self, extraMsg, isInit)

    local mapPanel = self:getPanel(MapPanel.NAME)
    mapPanel:show()

    if extraMsg ~= nil then --
        local tileX =extraMsg.tileX
        local tileY = extraMsg.tileY
        self:gotoTileXY(tileX, tileY)
    end
end

function MapView:gotoTileXY(tileX, tileY)
    local mapPanel = self:getPanel(MapPanel.NAME)
    mapPanel:gotoTileXY(tileX, tileY)
end

function MapView:updateTileInfos(infos)
    local mapSearchPanel = self:getPanel(MapSearchPanel.NAME)
    mapSearchPanel:updateTileInfos(infos)
end

function MapView:updateTeamInfos(timeInfoList)
    local mapPanel = self:getPanel(MapPanel.NAME)
    mapPanel:updateTaskInfos(timeInfoList)
end

function MapView:getReqTilePos()
    local mapPanel = self:getPanel(MapPanel.NAME)
    return mapPanel:getReqTilePos()
end

-- 资源更新
function MapView:onRoleInfoUpdateResp()
    local mapPanel = self:getPanel(MapInfoPanel.NAME)
    if mapPanel:isVisible() then
        mapPanel:onRoleInfoUpdateResp()
    end
end

function MapView:onUpdateBanditDungeon(data)
    if data == "battle" then  --由于战斗更新的数据，整理攻打成功了
        local banditPanel = self:getPanel(BanditPanel.NAME)
        banditPanel:hide()
    end

    --TODO 更新渲染

    local mapPanel = self:getPanel(MapPanel.NAME)
    mapPanel:refreshMap()
end

function MapView:hideBanditPanel()
    local panel = self:getPanel(MapInfoPanel.NAME)
    if panel:isVisible() then
        panel:hideBanditPanel()
    end
end

function MapView:onGetMarchTimeResp(data)
    --[[
    local panel = self:getPanel(MapRebelsFightPanel.NAME)
    if panel:isVisible() then
        panel:setMarchTime(data)
    end
    --]]
    local panel = self:getPanel(MapRebelsPanel.NAME)
    if panel:isVisible() then
        panel:setMarchTime(data)
    end
end

function MapView:showExpPanel()
    local proxy = self:getProxy(GameProxys.Role)
    local level = proxy:getRoleAttrValue(PlayerPowerDefine.POWER_level)
    if level >= 30 then
        return
    end
    --local panel = self:getPanel(MapExplainPanel.NAME)
    --panel:show()
end

function MapView:hideOtherPanel()
    local panels = { --[[MapExplainPanel.NAME,]] BanditPanel.NAME, MiniMapPanel.NAME, MapGoalInfoPanel.NAME, MapSearchPanel.NAME
                    , MapRebelsFightPanel.NAME, MapRebelsPanel.NAME, BanditCityInfoPanel.NAME, MapMyTownPanel.NAME}
    for k,v in pairs(panels) do
        local panel = self:getPanel(v)
        if panel:isVisible() then
            panel:hide()
        end
    end
end

function MapView:updateProtectTiles(data)
    local panel = self:getPanel(MapPanel.NAME)
    panel:updateProtectTiles(data)
end

function MapView:updateCityTiles()
    local panel = self:getPanel(MapPanel.NAME)
    panel:updateCityTiles()
end

function MapView:onSkillInfoUpdate(data)
    local panel = self:getPanel(MapPlayerInfoPanel.NAME)
    if panel:isVisible() then
        panel:onSkillInfoUpdate()
    end
end

function MapView:updateLordCityInfo(data)
    local mapLordCityPanel = self:getPanel(MapLordCityPanel.NAME)
    mapLordCityPanel:onCityInfoUpdate()
end

function MapView:onVoteInfoUpdate(data)
    local mapLordCityVotePanel = self:getPanel(MapLordCityVotePanel.NAME)
    mapLordCityVotePanel:onVoteInfoUpdate()
end

function MapView:onUpdateAllMarchLineResp(data)
    local panel = self:getPanel(MapPanel.NAME)
    if panel:isVisible() then
        panel:onUpdateAllMarchLineResp(data)
    end
end

function MapView:onUpdateMarchLineResp(data)
    local panel = self:getPanel(MapPanel.NAME)
    if panel:isVisible() then
        panel:onUpdateMarchLineResp(data)
    end
end

function MapView:mapPanelUnscheduleUpdate()
    local panel = self:getPanel(MapPanel.NAME)
    panel:unscheduleUpdate()
end

function MapView:onUpdataEmperorWorldNode(data)
    local panel = self:getPanel(MapPanel.NAME)
    panel:onUpdataEmperorWorldNode(data)
end

function MapView:showOtherModule(moduleName)
    self:dispatchEvent(ToolbarEvent.SHOW_OTHER_EVENT, moduleName)
end


function MapView:onUpdataMapSeason()
    local panel = self:getPanel(MapPanel.NAME)
    panel:onUpdataMapSeason()
end