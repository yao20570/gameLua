-- /**
--  * @Author:    
--  * @DateTime:    0000-00-00 00:00:00
--  * @Description: 
--  */
CountryPanel = class("CountryPanel", BasicPanel)
CountryPanel.NAME = "CountryPanel"

function CountryPanel:ctor(view, panelName)
    CountryPanel.super.ctor(self, view, panelName, true)
    self:setUseNewPanelBg(true)
end

function CountryPanel:finalize()
    CountryPanel.super.finalize(self)
end

function CountryPanel:initPanel()
	CountryPanel.super.initPanel(self)
    self:setTitle(true, "country", true)
    self:addTabControl()
end

function CountryPanel:registerEvents()
	CountryPanel.super.registerEvents(self)
end


function CountryPanel:addTabControl()
    self._tabControl = UITabControl.new(self)
    self._tabControl:addTabPanel(CountryRoyalPanel.NAME, self:getTextWord(560000))
    self._tabControl:addTabPanel(CountryPrisonPanel.NAME, self:getTextWord(560001))

    self._tabControl:setTabSelectByName(CountryRoyalPanel.NAME)
end

function CountryPanel:onClosePanelHandler()
    self:dispatchEvent(CountryEvent.HIDE_SELF_EVENT)
end


