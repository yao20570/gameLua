-- /**
--  * @Author:    
--  * @DateTime:    0000-00-00 00:00:00
--  * @Description: 
--  */
EmperorReportPanel = class("EmperorReportPanel", BasicPanel)
EmperorReportPanel.NAME = "EmperorReportPanel"

function EmperorReportPanel:ctor(view, panelName)
    EmperorReportPanel.super.ctor(self, view, panelName, true)
    self:setUseNewPanelBg(true)
end

function EmperorReportPanel:finalize()
    EmperorReportPanel.super.finalize(self)
end

function EmperorReportPanel:initPanel()
	EmperorReportPanel.super.initPanel(self)

    self:setTitle(true, "huangcheng", true)
    self._emperorCityProxy = self:getProxy(GameProxys.EmperorCity)

    self:addTabControl()
end

function EmperorReportPanel:registerEvents()
	EmperorReportPanel.super.registerEvents(self)
end


function EmperorReportPanel:addTabControl()
    self._tabControl = UITabControl.new(self)
    self._tabControl:addTabPanel(EmperorLegionPanel.NAME, self:getTextWord(371006))
    self._tabControl:addTabPanel(EmperorPersonPanel.NAME, self:getTextWord(371001))

    self._tabControl:setTabSelectByName(EmperorLegionPanel.NAME)
end

function EmperorReportPanel:onClosePanelHandler()
    self:dispatchEvent(EmperorReportEvent.HIDE_SELF_EVENT)
end


function EmperorReportPanel:onShowHandler()
    self:setTabRedPoint()
end


-- 设置标签红点
function EmperorReportPanel:setTabRedPoint()
    -- 信息界面红点
    local count = self._emperorCityProxy:getUnreadReportNum()
    self._tabControl:setItemCount(2, true, count)
end
