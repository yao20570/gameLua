-- /**
--  * @Author:    wzy
--  * @DateTime:    2016-12-03 15:03:00
--  * @Description:
--  */


MapLordCityPanel = class("MapLordCityPanel", BasicPanel)
MapLordCityPanel.NAME = "MapLordCityPanel"

function MapLordCityPanel:ctor(view, panelName)
    --MapLordCityPanel.super.ctor(self, view, panelName, 650)
    
    local layer = view:getLayer(ModuleLayer.UI_3_LAYER)
    MapRebelsPanel.super.ctor(self, view, panelName, 670, layer)
end

function MapLordCityPanel:finalize()
    MapLordCityPanel.super.finalize(self)
end

function MapLordCityPanel:initPanel()
	MapLordCityPanel.super.initPanel(self)
	self._lordCityProxy = self:getProxy(GameProxys.LordCity)
end

function MapLordCityPanel:registerEvents()
	MapLordCityPanel.super.registerEvents(self)

end

function MapLordCityPanel:onClosePanelHandler()
	self:hide()
end

function MapLordCityPanel:onShowHandler()
    self._cityId = self._lordCityProxy:getSelectCityId()
    local cityHost = self._lordCityProxy:getCityHostById(self._cityId)
    local cityInfo = self._lordCityProxy:getCityInfoById(self._cityId)
    if cityInfo == nil or cityHost == nil then
        local data = { cityId = self._cityId }
        -- 主界面 则弹城池列表信息
        self._lordCityProxy:onTriggerNet360010Req(data)
        -- 主界面 则弹城池详细信息
        self._lordCityProxy:onTriggerNet360011Req(data)
        -- 玩家信息
        self._lordCityProxy:onTriggerNet360042Req(data)    
    end
end

function MapLordCityPanel:onCityInfoUpdate()
    self._cityId = self._lordCityProxy:getSelectCityId()
    local cityHost = self._lordCityProxy:getCityHostById(self._cityId)
    local config = ConfigDataManager:getConfigById(ConfigData.CityBattleConfig, self._cityId)
	self:setTitle(true,config.name)

    if self._uiLordCityInfo == nil then
        self._uiLordCityInfo = UILordCityInfo.new(self)
        self._uiLordCityInfo:setBtnlVoteCallBack(function() self:onShowVotoPanel() end)
        self._uiLordCityInfo:setBtnlChildCallBack(function() self:onShowChildPanel() end)
        self._uiLordCityInfo:setBtnlBattleCallBack(function() self:onShowBattlePanel() end)
    end
    self._uiLordCityInfo:onCityInfoUpdate()
end

function MapLordCityPanel:onShowVotoPanel()
    local panel = self:getPanel(MapLordCityVotePanel.NAME)
    panel:show()
end

function MapLordCityPanel:onShowChildPanel()
    local data = { }
    data.moduleName = ModuleName.LegionApplyModule
    --data.srcModule = ModuleName.LordCityModule    -- 关闭目标模块，重新打开当前模块
    self:dispatchEvent(MapEvent.SHOW_OTHER_EVENT, data)
end

function MapLordCityPanel:onShowBattlePanel()
    
    local data = {}
    data.moduleName = ModuleName.LordCityModule
    data.extraMsg = {}
    data.extraMsg.panelName = "LordCityBattlePanel"

    self:dispatchEvent(MapEvent.SHOW_OTHER_EVENT, data)
end

function MapLordCityPanel:update()
    if self._uiLordCityInfo then
        self._uiLordCityInfo:update()
    end
end

