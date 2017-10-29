--[[
城主战：城池信息弹窗
]]
LordCityInfoPanel = class("LordCityInfoPanel", BasicPanel)
LordCityInfoPanel.NAME = "LordCityInfoPanel"

function LordCityInfoPanel:ctor(view, panelName)
    LordCityInfoPanel.super.ctor(self, view, panelName, 670)

end

function LordCityInfoPanel:finalize()
    LordCityInfoPanel.super.finalize(self)
end

function LordCityInfoPanel:initPanel()
	LordCityInfoPanel.super.initPanel(self)
	self._lordCityProxy = self:getProxy(GameProxys.LordCity)

end

function LordCityInfoPanel:registerEvents()
	LordCityInfoPanel.super.registerEvents(self)
end

function LordCityInfoPanel:onClosePanelHandler()
	self:hide()
end

function LordCityInfoPanel:onShowHandler()
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

function LordCityInfoPanel:onShowVotoPanel()
    local panel = self:getPanel(LordCityVotePanel.NAME)
	panel:show()
end

function LordCityInfoPanel:onShowChildPanel()
    local data = { }
    data.moduleName = ModuleName.LegionApplyModule
    data.srcModule = ModuleName.LordCityModule    -- 关闭目标模块，重新打开当前模块
    -- data.srcExtraMsg = {panelName = "LordCityInfoPanel"}
    self:dispatchEvent(LordCityEvent.SHOW_OTHER_EVENT, data)
end

function LordCityInfoPanel:onShowBattlePanel()
    local panel = self:getPanel(LordCityBattlePanel.NAME)
    panel:show()
    panel = self:getPanel(LordCityMainPanel.NAME)
    panel:hide()
end


function LordCityInfoPanel:onCityInfoUpdate()
    self:onShowHandler()
end

function LordCityInfoPanel:update()
    if self._uiLordCityInfo then
        self._uiLordCityInfo:update()
    end
end
