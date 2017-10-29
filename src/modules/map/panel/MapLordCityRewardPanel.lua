--[[
城主战：投票奖励弹窗
]]
MapLordCityRewardPanel = class("MapLordCityRewardPanel", BasicPanel)
MapLordCityRewardPanel.NAME = "MapLordCityRewardPanel"

function MapLordCityRewardPanel:ctor(view, panelName)
    --MapLordCityRewardPanel.super.ctor(self, view, panelName, 300)
    
    local layer = view:getLayer(ModuleLayer.UI_3_LAYER)
    MapRebelsPanel.super.ctor(self, view, panelName, 300, layer)
end

function MapLordCityRewardPanel:finalize()
    MapLordCityRewardPanel.super.finalize(self)
end

function MapLordCityRewardPanel:initPanel()
	MapLordCityRewardPanel.super.initPanel(self)
	self:setTitle(true,self:getTextWord(370028))
end

function MapLordCityRewardPanel:registerEvents()
	MapLordCityRewardPanel.super.registerEvents(self)
end

function MapLordCityRewardPanel:onClosePanelHandler()
	self:hide()
end

function MapLordCityRewardPanel:onShowHandler()

    if self._uiLordCityReward == nil then
        self._uiLordCityReward = UILordCityReward.new(self)
    end
    self._uiLordCityReward:onLordCityRewardUpdate()
end

