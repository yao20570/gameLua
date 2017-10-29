-- /**
--  * @Author:    
--  * @DateTime:    0000-00-00 00:00:00
--  * @Description: 
--  */
TownTradePanel = class("TownTradePanel", BasicPanel)
TownTradePanel.NAME = "TownTradePanel"

function TownTradePanel:ctor(view, panelName)
    TownTradePanel.super.ctor(self, view, panelName, true)

    self:setUseNewPanelBg(true)
end

function TownTradePanel:finalize()
    TownTradePanel.super.finalize(self)
end

function TownTradePanel:initPanel()
	TownTradePanel.super.initPanel(self)
    self:setBgType(ModulePanelBgType.NONE)
    self:setTitle(true, "town_trade", true)

    self:addTabControl()
end

function TownTradePanel:registerEvents()
	TownTradePanel.super.registerEvents(self)
end
function TownTradePanel:doLayout()


end

function TownTradePanel:onShowHandler(extraMsg)
    if self._tabControl then
        if extraMsg == nil or extraMsg.panelName == nil then
            if self._tabControl:changeTabSelectByName(TownTradeResPanel.NAME) == false then
                self:getPanel(TownTradeResPanel.NAME):show()
            end
        elseif extraMsg.panelName ~= nil then
            if self._tabControl:changeTabSelectByName(extraMsg.panelName) == false then
                self:getPanel(extraMsg.panelName):show()
            end
        end
    end
end


function TownTradePanel:onClosePanelHandler()
    self:dispatchEvent(TownTradeEvent.HIDE_SELF_EVENT)
end


function TownTradePanel:addTabControl()
    local tabControl = UITabControl.new(self)
    tabControl:addTabPanel(TownTradeResPanel.NAME, self:getTextWord(500))
    self._tabControl = tabControl
end








