-- /**
--  * @Author:    
--  * @DateTime:    0000-00-00 00:00:00
--  * @Description: 
--  */
MilitaryPanel = class("MilitaryPanel", BasicPanel)
MilitaryPanel.NAME = "MilitaryPanel"

function MilitaryPanel:ctor(view, panelName)
    MilitaryPanel.super.ctor(self, view, panelName, true)
    self:setUseNewPanelBg(true)
end

function MilitaryPanel:finalize()
    MilitaryPanel.super.finalize(self)
end

function MilitaryPanel:initPanel()
	MilitaryPanel.super.initPanel(self)

    self:setTitle(true, "jungongsuo", true)
    self._militaryProxy = self:getProxy(GameProxys.Military)
    self:addTabControl()
end

function MilitaryPanel:registerEvents()
	MilitaryPanel.super.registerEvents(self)
end

function MilitaryPanel:onShowHandler(extraMsg)
    if self._tabControl then
        if extraMsg == nil or extraMsg.panelName == nil then
            if self._tabControl:changeTabSelectByName(MilitaryProjectPanel.NAME) == false then
                self:getPanel(MilitaryProjectPanel.NAME)._isHide = true
                self:getPanel(MilitaryProjectPanel.NAME):show()
            end
        elseif extraMsg.panelName ~= nil then
            if self._tabControl:changeTabSelectByName(extraMsg.panelName) == false then
                if extraMsg.panelName == MilitaryProjectPanel.NAME then
                    self:getPanel(MilitaryProjectPanel.NAME)._isHide = true
                end
                self:getPanel(extraMsg.panelName):show()
            end
        end
    end
end

function MilitaryPanel:onClosePanelHandler()
    self:dispatchEvent(MilitaryEvent.HIDE_SELF_EVENT)
end


function MilitaryPanel:addTabControl()
    local function callback(panel, panelName, oldPanelName) 
        if panelName == MilitaryProjectPanel.NAME then
            local panel = self:getPanel(MilitaryProjectPanel.NAME)
            if panel._mainPanel then
                panel._isHide = false
                panel._mainPanel:setVisible(true)
            end
        end
        return true
    end

    local tabControl = UITabControl.new(self, callback)
    tabControl:addTabPanel(MilitaryProjectPanel.NAME, self:getTextWord(510001))
    tabControl:addTabPanel(MilitarySynthesislPanel.NAME, self:getTextWord(510026))
    tabControl:setTabSelectByName(MilitaryProjectPanel.NAME)

    self._tabControl = tabControl
end