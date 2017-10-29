-- /**
--  * @Author:    wzy
--  * @DateTime:    2016-12-03 15:03:00
--  * @Description:
--  */

MapLordCityVotePanel = class("MapLordCityVotePanel", BasicPanel)
MapLordCityVotePanel.NAME = "MapLordCityVotePanel"

function MapLordCityVotePanel:ctor(view, panelName)
    --MapLordCityVotePanel.super.ctor(self, view, panelName, 650)
    
    local layer = view:getLayer(ModuleLayer.UI_3_LAYER)
    MapRebelsPanel.super.ctor(self, view, panelName, 810, layer)
end

function MapLordCityVotePanel:finalize()
    MapLordCityVotePanel.super.finalize(self)
end

function MapLordCityVotePanel:initPanel()
	MapLordCityVotePanel.super.initPanel(self)

    self:setTitle(true,self:getTextWord(370027))

	self._lordCityProxy = self:getProxy(GameProxys.LordCity)

    self._uiLordCityVote = nil
end

function MapLordCityVotePanel:registerEvents()
	MapLordCityVotePanel.super.registerEvents(self)
end

function MapLordCityVotePanel:onClosePanelHandler()
	self:hide()
end

function MapLordCityVotePanel:onShowHandler()

    if self._uiLordCityVote == nil then
        self._uiLordCityVote = UILordCityVote.new(self)
        self._uiLordCityVote:setCallbackReward(function() 
            local panel = self:getPanel(MapLordCityRewardPanel.NAME)
            panel:show() 
        end)
    end
    self._uiLordCityVote:onLordCityVoteUpdate()

end


---- 协议更新列表信息
function MapLordCityVotePanel:onVoteInfoUpdate()
	self:onShowHandler()
end
