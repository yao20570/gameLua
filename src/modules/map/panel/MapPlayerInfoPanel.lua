-- /**
--  * @Author:      fzw
--  * @DateTime:    2016-12-03 15:03:00
--  * @Description: 世界地图查看玩家的弹窗
--  */

MapPlayerInfoPanel = class("MapPlayerInfoPanel", BasicPanel)
MapPlayerInfoPanel.NAME = "MapPlayerInfoPanel"

function MapPlayerInfoPanel:ctor(view, panelName)
    local layer = view:getLayer(ModuleLayer.UI_3_LAYER)
    MapRebelsPanel.super.ctor(self, view, panelName, 500, layer)
end

function MapPlayerInfoPanel:finalize()
    MapPlayerInfoPanel.super.finalize(self)
end

function MapPlayerInfoPanel:initPanel()
    MapPlayerInfoPanel.super.initPanel(self)
    self:setTitle(true,self:getTextWord(506))
end

function MapPlayerInfoPanel:registerEvents()
    MapPlayerInfoPanel.super.registerEvents(self)
end

function MapPlayerInfoPanel:onClosePanelHandler()
    self:hide()
end

function MapPlayerInfoPanel:onShowHandler()
    -- local lordCityProxy = self:getProxy(GameProxys.LordCity)
    -- lordCityProxy:onTriggerNet360050Req({})
end

function MapPlayerInfoPanel:onWatchPlayerInfo(data)
    self._playerInfo = data
    if self._watchPlayInfoPanel == nil then
        local topLayer = self:getLayer(ModuleLayer.UI_2_LAYER)
        self._watchPlayInfoPanel = UIWatchWorldPlayerInfo.new(self)
    end
    self._watchPlayInfoPanel:showAllInfo(data)
end


function MapPlayerInfoPanel:useBtnCallback(data)
    local panel = self:getPanel(MapUseCitySkillPanel.NAME)
    panel:show(data)
end

function MapPlayerInfoPanel:onSkillInfoUpdate()
    self._watchPlayInfoPanel:useSkillResp()
end

--执行攻击
function MapPlayerInfoPanel:onAttackPlayerTouch(tileInfo)
    local panel = self:getPanel(MapPanel.NAME)
    panel:onAttackPlayerTouch(tileInfo)
end

--执行
function MapPlayerInfoPanel:onGoStationTouch(tileInfo)
    local panel = self:getPanel(MapPanel.NAME)
    panel:onGoStationTouch(tileInfo)
end

--执行
function MapPlayerInfoPanel:onSpyPriceTouch(tileInfo)
    local panel = self:getPanel(MapPanel.NAME)
    panel:onSpyPriceTouch(tileInfo)
end

--执行
function MapPlayerInfoPanel:onPlayerCollectTouch(tileInfo)
    local panel = self:getPanel(MapPanel.NAME)
    panel:onPlayerCollectTouch(tileInfo)
end
